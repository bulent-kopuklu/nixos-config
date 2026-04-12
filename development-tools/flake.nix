# Centralized development tool sets

{
  description = "Centralized development tool sets for various programming languages and ecosystems.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = import nixpkgs { inherit system;};
      in {
        lib = rec {
          cpp = { targets ? [], clang-version ? null, extra-packages ? [] }:
            let
              clang-pkgs = if clang-version == null then pkgs.clang
                      else pkgs.clang.override { version = clang-version; };

              cross-toolchains = map (target:
                if target == "aarch64"    then pkgs.pkgsCross.aarch64-multiplatform.clang
                else if target == "armv7" then pkgs.pkgsCross.armv7l-hf-multiplatform.clang
                else throw "Unsupported target: ${target}"
              ) targets;

            in {
              packages = with pkgs; [
                clang-tools
                gdb
                lldb
                cmake
                ninja
                gnumake
                pkg-config
                ccache
                glibc.static
                musl
              ] ++ [ clang-pkgs ] ++ cross-toolchains ++ extra-packages;

              shellHook = ''
                export CC="${clang-pkgs}/bin/clang"
                export CXX="${clang-pkgs}/bin/clang++"
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
                rustup component add rust-analyzer clippy rustfmt 2>/dev/null || true
                ${if targets != [] then ''
                  rustup target add ${builtins.concatStringsSep " " rust-targets} 2>/dev/null || true
                  mkdir -p .cargo
                  cat > .cargo/config.toml << EOF
          ${builtins.concatStringsSep "\n" linker-configs}
          EOF
                '' else ""}
              '';
            };

          android = { apiLevel ? 21, ndkVersion ? "23.2.8568313", cmakeVersion ? "3.22.1", extraPackages ? [] }:
            let 
              pkgs-android = import nixpkgs {
                inherit system;
                config = {
                  android_sdk.accept_license = true;
                  allowUnfree = true;
                };
              };
              androidComposition = pkgs-android.androidenv.composeAndroidPackages {
                platformVersions = [ (toString apiLevel) ];
                ndkVersions = [ ndkVersion ];
                cmakeVersions = [ cmakeVersion ];
                includeNDK = true;
                includeEmulator = false;
              };
              android-sdk = androidComposition.androidsdk;
              android-scripts = pkgs.stdenv.mkDerivation {
                name = "android-scripts";
                src = ./android-scripts;
                installPhase = ''
                  mkdir -p $out/bin $out/share
                  cp cmake-android $out/bin/cmake-android
                  cp definition $out/bin/definition
                  cp tasks.json $out/share/tasks-cmake.json
                  chmod +x $out/bin/cmake-android
                '';
              };
            in {
              packages = [
                android-sdk 
                pkgs.jdk17
                android-scripts
              ] ++ extraPackages;
              shellHook = ''
                export ANDROID_SDK_HOME="${android-sdk}/libexec/android-sdk"
                export ANDROID_NDK_VERSION="${ndkVersion}"
                export ANDROID_CMAKE_VERSION="${cmakeVersion}"
                export ANDROID_MIN_SDK="${toString apiLevel}"
                export JAVA_HOME="${pkgs.jdk17.home}"
                if [ ! -f .vscode/tasks-cmake.json ]; then
                  mkdir -p .vscode
                  cp ${android-scripts}/share/tasks-cmake.json .vscode/tasks-cmake.json
                  chmod 666 .vscode/tasks-cmake.json
                fi
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
              npm
            ];
            shellHook = ''
              export NODE_PATH=""
              # npm config (XDG-compliant paths) - UPPERCASE variables required!
              export NPM_CONFIG_PREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/npm"
              export NPM_CONFIG_CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/npm"
              export NPM_CONFIG_TMP="''${XDG_RUNTIME_DIR:-/tmp}/npm"
            '';
          };

          run-zsh = ''
            export SHELL=${pkgs.zsh}/bin/zsh
            exec ${pkgs.zsh}/bin/zsh --login
          '';

          merge  = toolList: {
            packages = builtins.concatLists (map (t: t.packages) toolList);
            shellHook = builtins.concatStringsSep "\n" (map (t: t.shellHook) toolList) + run-zsh;
          };
        };
      }
    );
}
