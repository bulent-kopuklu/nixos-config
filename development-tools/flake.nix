# Centralized development tool sets

{
  description = "Centralized development tool sets for various programming languages and ecosystems.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system;};
      in {
        lib = {
          cpp = { stdenv ? "clang", targetArch ? null, extraPackages ? [] }:
            let
              cross-pkgs =
                if targetArch == null           then pkgs
                else if targetArch == "aarch64" then pkgs.pkgsCross.aarch64-multiplatform
                else if targetArch == "x86_64"  then pkgs.pkgsCross.gnu64
                else throw "Unsupported target architecture: ${targetArch}";

              cc =
                if stdenv == "clang" then cross-pkgs.clang
                else if stdenv == "gcc" then cross-pkgs.gcc
                else throw "Unsupported stdenv: ${stdenv}";

            in {
              packages = with pkgs; [
                cmake
                ninja
                gdb
                cc
              ] ++ extraPackages;

              shellHook = ''
                export CC="${cc}/bin/${if stdenv == "clang" then "clang" else "gcc"}"
                export CXX="${cc}/bin/${if stdenv == "clang" then "clang++" else "g++"}"
                ${if targetArch != null then ''
                  echo "Cross-compilation target: ${targetArch}"
                '' else ""}
              '';
            };    
          
          rust = { targetArch ? null, extraPackages ? [] }:
            let
              rust-target =
                if targetArch == null           then null
                else if targetArch == "aarch64" then "aarch64-unknown-linux-gnu"
                else if targetArch == "x86_64"  then "x86_64-unknown-linux-gnu"
                else throw "Unsupported target architecture: ${targetArch}";

              cross-pkgs =
                if targetArch == null           then null
                else if targetArch == "aarch64" then pkgs.pkgsCross.aarch64-multiplatform
                else if targetArch == "x86_64"  then pkgs.pkgsCross.gnu64
                else throw "Unsupported target architecture: ${targetArch}";

              linker =
                if cross-pkgs == null then null
                else "${cross-pkgs.stdenv.cc}/bin/${cross-pkgs.stdenv.cc.targetPrefix}cc";
            in {
              packages = with pkgs; [
                rustup
              ] 
              ++ (if cross-pkgs != null then [ cross-pkgs.stdenv.cc ] else []) 
              ++ extraPackages;
              shellHook = ''
                ${if rust-target != null then ''
                  mkdir -p .cargo
                  cat > .cargo/config.toml << EOF
[target.${rust-target}]
linker = "${linker}"
EOF
                  export CARGO_BUILD_TARGET="${rust-target}"
                '' else ""}
              '';
            };

          android = { apiLevel ? 21, ndkVersion ? "23.2.8568313", cmakeVersion ? "3.22.1", extraPackages ? [] }:
            let 
              androidSdk = pkgs.androidenv.androidPkgs {
                platformVersions = [ (toString apiLevel) ];
                ndkVersions = [ ndkVersion ];
                cmakeVersions = [ cmakeVersion ];
                includeNDK = true;
              };
              android-scripts = pkgs.stdenv.mkDerivation {
                name = "android-scripts";
                src = ./android-scripts;
                installPhase = ''
                  mkdir -p $out/bin
                  cp cmake $out/bin/cmake-android
                  cp definition $out/bin/definition
                  chmod +x $out/bin/cmake-android
                '';
              };
            in {
              packages = [
                androidSdk.androidsdk
                android-scripts
              ] ++ extraPackages;
              shellHook = ''
                export ANDROID_SDK_HOME="${androidSdk.androidsdk}/libexec/android-sdk"
                export ANDROID_NDK_VERSION="${ndkVersion}"
                export ANDROID_CMAKE_VERSION="${cmakeVersion}"
                export ANDROID_MIN_SDK="${toString apiLevel}"
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

          merge  = toolList: {
            packages = builtins.concatLists (map (t: t.packages) toolList);
            shellHook = builtins.concatStringsSep "\n" (map (t: t.shellHook) toolList);
          };

          run-zsh = ''
            export SHELL=${pkgs.zsh}/bin/zsh
            exec ${pkgs.zsh}/bin/zsh --login
          '';
        };
      }
    );
}
