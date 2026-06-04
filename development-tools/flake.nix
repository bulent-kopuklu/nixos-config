# Centralized development tool sets

{
  description = "Centralized development tool sets for various programming languages and ecosystems.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgs-android = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

      in {
        packages = {
          mkproject = pkgs.callPackage ./mkproject.nix { };
        };
        
        lib = rec {
          cpp = { targets ? [], clang-version ? null, extra-packages ? [] }:
            let
              llvmPackages = if clang-version == null then pkgs.llvmPackages
                   else pkgs.${"llvmPackages_${clang-version}"};
              clang = llvmPackages.clang;
              clang-tools = llvmPackages.clang-tools;
              bin-tools = llvmPackages.bintools;
              cross-toolchains = map (target:
                if target == "aarch64"    then pkgs.pkgsCross.aarch64-multiplatform.clang
                else if target == "armv7" then pkgs.pkgsCross.armv7l-hf-multiplatform.clang
                else throw "Unsupported target: ${target}"
              ) targets;

            in {
              packages = with pkgs; [
                gdb
                lldb
                cmake
                ninja
                gnumake
                pkg-config
                ccache
              ] ++ [ clang ] ++ [ clang-tools ] ++ [ bin-tools ] ++ cross-toolchains ++ extra-packages;

              shellHook = ''
                export CC="${clang}/bin/clang"
                export CXX="${clang}/bin/clang++"
              '';
            };

          rust = { targets ? [], extra-packages ? [] }:
            let
              cross-linkers = map (target:
                if target == "aarch64"    then pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
                else if target == "armv7" then pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc
                else throw "Unsupported target: ${target}"
              ) targets;

              rust-targets = map (target:
                if target == "aarch64"    then "aarch64-unknown-linux-gnu"
                else if target == "armv7" then "armv7-unknown-linux-gnueabihf"
                else throw "Unsupported target: ${target}"
              ) targets;

              linker-configs = map (target:
                if target == "aarch64" then ''
[target.aarch64-unknown-linux-gnu]
linker = "${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc}/bin/${pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}cc"
                ''
                else if target == "armv7" then ''
[target.armv7-unknown-linux-gnueabihf]
linker = "${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc}/bin/${pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix}cc"
                ''
                else throw "Unsupported target: ${target}"
              ) targets;

            in {
              packages = [ pkgs.rustup ] ++ cross-linkers ++ extra-packages;

              shellHook = ''
                rustup default stable 2>/dev/null || true
                rustup component add rust-analyzer rust-analyzer-lsp clippy rustfmt rust-src llvm-tools  2>/dev/null || true

                ${if targets != [] then ''
                  rustup target add ${builtins.concatStringsSep " " rust-targets} 2>/dev/null || true

                  # .cargo/config.toml - sadece [target.*] bolumlerini guncelle
                  if [ -f .cargo/config.toml ]; then
                    awk '/^\[target\./{skip=1} /^\[/ && !/^\[target\./{skip=0} !skip{print}' .cargo/config.toml > .cargo/config.toml.tmp
                    mv .cargo/config.toml.tmp .cargo/config.toml
                  else
                    mkdir -p .cargo
                    touch .cargo/config.toml
                  fi
                  cat >> .cargo/config.toml << EOF
${builtins.concatStringsSep "\n" linker-configs}
EOF
                '' else ""}
              '';
            };

          android = { api-level ? 21, ndk-version ? "23.2.8568313", cmake-version ? "3.22.1", extra-platform-versions ? [], build-tools-versions ? [], extra-packages ? [] }:
            let
              androidComposition = pkgs-android.androidenv.composeAndroidPackages {
                platformVersions = [ (toString api-level) ] ++ extra-platform-versions;
                buildToolsVersions = build-tools-versions;
                ndkVersions = [ ndk-version ];
                cmakeVersions = [ cmake-version ];
                includeNDK = true;
                includeEmulator = false;
              };
              android-sdk = androidComposition.androidsdk;
            in {
              packages = [
                android-sdk
                pkgs.jdk17
                pkgs.gradle
              ] ++ extra-packages;

              shellHook = ''
                export ANDROID_USER_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/android"
                export ANDROID_HOME="${android-sdk}/libexec/android-sdk"
                unset ANDROID_SDK_HOME
                export ANDROID_NDK_VERSION="${ndk-version}"
                export ANDROID_CMAKE_VERSION="${cmake-version}"
                export ANDROID_MIN_SDK="${toString api-level}"
                export JAVA_HOME="${pkgs.jdk17.home}"

                mkdir -p "$ANDROID_USER_HOME"
              '';
            };

          android-native = { api-level ? 21, ndk-version ? "23.2.8568313", cmake-version ? "3.22.1", extra-platform-versions ? [], build-tools-versions ? [], extra-packages ? [] }:
            let
              android-env   = android { inherit api-level ndk-version cmake-version extra-platform-versions build-tools-versions; };
              cpp-env       = cpp {};
              rust-env      = rust {};

              ndk-toolchain = "$ANDROID_HOME/ndk/${ndk-version}/toolchains/llvm/prebuilt/linux-x86_64/bin";

              android-rust-targets = [
                "aarch64-linux-android"
                "x86_64-linux-android"
                "i686-linux-android"
                "armv7-linux-androideabi"
              ];

              android-linker-configs = ''
[target.aarch64-linux-android]
linker = "${ndk-toolchain}/aarch64-linux-android${toString api-level}-clang"

[target.x86_64-linux-android]
linker = "${ndk-toolchain}/x86_64-linux-android${toString api-level}-clang"

[target.i686-linux-android]
linker = "${ndk-toolchain}/i686-linux-android${toString api-level}-clang"

[target.armv7-linux-androideabi]
linker = "${ndk-toolchain}/armv7a-linux-androideabi${toString api-level}-clang"
              '';
            in {
              packages = android-env.packages ++ cpp-env.packages ++ rust-env.packages ++ extra-packages;

              shellHook = android-env.shellHook + cpp-env.shellHook + rust-env.shellHook + ''
                rustup target add ${builtins.concatStringsSep " " android-rust-targets} 2>/dev/null || true

                if [ -f .cargo/config.toml ]; then
                  awk '/^\[target\./{skip=1} /^\[/ && !/^\[target\./{skip=0} !skip{print}' .cargo/config.toml > .cargo/config.toml.tmp
                  mv .cargo/config.toml.tmp .cargo/config.toml
                else
                  mkdir -p .cargo
                  touch .cargo/config.toml
                fi
                cat >> .cargo/config.toml << EOF
${android-linker-configs}
EOF
              '';
            };

          go = { extra-packages ? [] }: {
            packages = with pkgs; [
              go
              gopls
              golangci-lint
              delve
            ] ++ extra-packages;

            shellHook = ''
              export GOPATH="''${XDG_DATA_HOME:-$HOME/.local/share}/go"
              export GOBIN="$GOPATH/bin"
              export PATH="$GOBIN:$PATH"
            '';
          };

          python = {
            packages = with pkgs; [
              python312
              python312Packages.pip
              python312Packages.virtualenv
              poetry
            ];
            shellHook = ''
            '';
          };

          java = {
            packages = with pkgs; [
              jdk17
              maven
              gradle
            ];
            shellHook = ''
              export JAVA_HOME="${pkgs.jdk17.home}"
              export JDK_HOME="${pkgs.jdk17.home}"
            '';
          };

          node = {
            packages = with pkgs; [
              nodejs_20
              pnpm
              # npm is included in nodejs
            ];
            shellHook = ''
              export NODE_PATH=""
              export NPM_CONFIG_PREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/npm"
              export NPM_CONFIG_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/npm"
              export NPM_CONFIG_TMP="''${XDG_RUNTIME_DIR:-/tmp}/npm"
            '';
          };

          merge = toolList: {
            packages = builtins.concatLists (map (t: t.packages) toolList);
            shellHook = builtins.concatStringsSep "\n" (map (t: t.shellHook) toolList) + run-zsh;
          };

          run-zsh = ''
            if [ -z "$__NIX_DEVSHELL_ZSH" ]; then
              export __NIX_DEVSHELL_ZSH=1
              export SHELL=${pkgs.zsh}/bin/zsh
              exec ${pkgs.zsh}/bin/zsh --login
            fi
          '';
        };
      }
    );
}
