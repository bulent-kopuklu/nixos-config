# Centralized development tool sets

{
  description = "Centralized development tool sets for various programming languages and ecosystems.";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system;};
      in {
        lib = {
          cpp = {
            packages = with pkgs; [
              cmake
              clang
              clang-tools
              ninja
              gdb
            ];
            shellHook = ''
              export CC="${pkgs.clang}/bin/clang"
              export CXX="${pkgs.clang}/bin/clang++"
            '';
          };
          rust = {
            packages = with pkgs; [
              cargo
              rustc
              rust-analyzer
              clippy
              rustfmt
              cargo-edit
              cargo-watch
              cargo-audit
              rust-bindgen
            ];
            shellHook = ''
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
