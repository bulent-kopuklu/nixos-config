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
        pkgs = import nixpkgs { inherit system; };
        pkgs-android = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        std-files = pkgs.stdenv.mkDerivation {
          name = "std-files";
          src = ./std;
          installPhase = ''
            mkdir -p $out
            cp .envrc $out/.envrc
            cp .gitignore $out/.gitignore
          '';
        };

        cpp-files = pkgs.stdenv.mkDerivation {
          name = "cpp-files";
          src = ./cpp;
          installPhase = ''
            mkdir -p $out
            cp .clangd $out/.clangd
            cp .clang-format $out/.clang-format
            cp .editorconfig $out/.editorconfig
          '';
        };

        rust-files = pkgs.stdenv.mkDerivation {
          name = "rust-files";
          src = ./rust;
          installPhase = ''
            mkdir -p $out
            cp rustfmt.toml $out/rustfmt.toml
            cp Cargo.toml $out/Cargo.toml
          '';
        };

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
        packages = {
          mkproject = pkgs.callPackage ./mkproject.nix { };
        };
        
        lib = rec {
          cpp = { targets ? [], clang-version ? null, extra-packages ? [] }:
            let
              clang = if clang-version == null then pkgs.clang
                      else pkgs."clang_${clang-version}";

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
              ] ++ [ clang ] ++ cross-toolchains ++ extra-packages;

              shellHook = ''
                export CC="${clang}/bin/clang"
                export CXX="${clang}/bin/clang++"

                if [ ! -f .envrc ];          then cp ${std-files}/.envrc .;          fi
                if [ ! -f .gitignore ];      then cp ${std-files}/.gitignore .;      fi
                if [ ! -f .clangd ];         then cp ${cpp-files}/.clangd .;         fi
                if [ ! -f .clang-format ];   then cp ${cpp-files}/.clang-format .;   fi
                if [ ! -f .editorconfig ];   then cp ${cpp-files}/.editorconfig .;   fi

                if [ ! -f CMakeLists.txt ]; then
                  echo "CMakeLists.txt bulunamadı. 'cmake init' ile oluşturabilirsiniz."
                fi
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

                if [ ! -f .envrc ];       then cp ${std-files}/.envrc .;        fi
                if [ ! -f .gitignore ];   then cp ${std-files}/.gitignore .;    fi
                if [ ! -f rustfmt.toml ]; then cp ${rust-files}/rustfmt.toml .; fi
                if [ ! -f Cargo.toml ];   then cp ${rust-files}/Cargo.toml .;   fi

                ${if targets != [] then ''
                  rustup target add ${builtins.concatStringsSep " " rust-targets} 2>/dev/null || true

                  # .cargo/config.toml - sadece [target.*] bolumlerini guncelle
                  if [ -f .cargo/config.toml ]; then
                    awk '/^\[target\./,/^(\[|$)/{next} {print}' .cargo/config.toml > .cargo/config.toml.tmp
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

          android = { api-level ? 21, ndk-version ? "23.2.8568313", cmake-version ? "3.22.1", extra-packages ? [] }:
            let
              androidComposition = pkgs-android.androidenv.composeAndroidPackages {
                platformVersions = [ (toString api-level) ];
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
                android-scripts
              ] ++ extra-packages;

              shellHook = ''
                export ANDROID_SDK_HOME="${android-sdk}/libexec/android-sdk"
                export ANDROID_NDK_VERSION="${ndk-version}"
                export ANDROID_CMAKE_VERSION="${cmake-version}"
                export ANDROID_MIN_SDK="${toString api-level}"
                export JAVA_HOME="${pkgs.jdk17.home}"
              '';
            };

          android-native = { api-level ? 21, ndk-version ? "23.2.8568313", cmake-version ? "3.22.1", extra-packages ? [] }:
            let
              android-env   = android { inherit api-level ndk-version cmake-version; };
              cpp-env       = cpp {};
              rust-env      = rust {};

              ndk-toolchain = "$ANDROID_SDK_HOME/ndk/${ndk-version}/toolchains/llvm/prebuilt/linux-x86_64/bin";

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
                if [ ! -f .vscode/tasks-cmake.json ]; then
                  mkdir -p .vscode
                  cp ${android-scripts}/share/tasks-cmake.json .vscode/tasks-cmake.json
                  chmod 666 .vscode/tasks-cmake.json
                fi

                rustup target add ${builtins.concatStringsSep " " android-rust-targets} 2>/dev/null || true

                if [ -f .cargo/config.toml ]; then
                  awk '/^\[target\./,/^(\[|$)/{next} {print}' .cargo/config.toml > .cargo/config.toml.tmp
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
            export SHELL=${pkgs.zsh}/bin/zsh
            exec ${pkgs.zsh}/bin/zsh --login
          '';
        };
      }
    );
}
