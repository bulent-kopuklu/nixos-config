#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="@templates@"

usage() {
  echo "Usage: mkproject <name> --env <env1,env2,...>"
  echo ""
  echo "Environments: cpp, rust, android-native, python, java, node"
  echo ""
  echo "Examples:"
  echo "  mkproject mylib --env cpp"
  echo "  mkproject mylib --env cpp,rust"
  echo "  mkproject mylib --env android-native"
  exit 1
}

if [ $# -lt 3 ]; then usage; fi

PROJECT_NAME="$1"
shift

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      IFS=',' read -ra ENVS <<< "$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

if [ -z "$PROJECT_NAME" ] || [ -z "$ENVS" ]; then usage; fi
if [ -d "$PROJECT_NAME" ]; then
  echo "Error: '$PROJECT_NAME' already exists."
  exit 1
fi

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# std dosyaları
cp "$TEMPLATES/std/.envrc"    .envrc
cp "$TEMPLATES/std/.gitignore" .gitignore

# env'e göre dosyaları kopyala
has_env() { for e in "${ENVS[@]}"; do [ "$e" = "$1" ] && return 0; done; return 1; }

if has_env "cpp" || has_env "android-native"; then
  cp "$TEMPLATES/cpp/.clangd"       .clangd
  cp "$TEMPLATES/cpp/.clang-format" .clang-format
  cp "$TEMPLATES/cpp/.editorconfig" .editorconfig
fi

if has_env "rust" || has_env "android-native"; then
  cp "$TEMPLATES/rust/rustfmt.toml" rustfmt.toml
  cp "$TEMPLATES/rust/Cargo.toml"   Cargo.toml
fi

# flake.nix generate et
generate_merge_line() {
  local lines=""
  for env in "${ENVS[@]}"; do
    case $env in
      cpp)            lines+="          (devenv.cpp { /* targets = [ \"aarch64\" \"armv7\" ]; */ })\n" ;;
      rust)           lines+="          (devenv.rust { /* targets = [ \"aarch64\" \"armv7\" ]; */ })\n" ;;
      android-native) lines+="          (devenv.android-native { /* api-level = 21; ndk-version = \"23.2.8568313\"; */ })\n" ;;
      python)         lines+="          (devenv.python)\n" ;;
      java)           lines+="          (devenv.java)\n" ;;
      node)           lines+="          (devenv.node)\n" ;;
    esac
  done

  # secilmeyenleri comment'li ekle
  all_envs=("cpp" "rust" "android-native" "python" "java" "node")
  for env in "${all_envs[@]}"; do
    if ! has_env "$env"; then
      case $env in
        cpp)            lines+="          # (devenv.cpp { /* targets = [ \"aarch64\" \"armv7\" ]; */ })\n" ;;
        rust)           lines+="          # (devenv.rust { /* targets = [ \"aarch64\" \"armv7\" ]; */ })\n" ;;
        android-native) lines+="          # (devenv.android-native { /* api-level = 21; ndk-version = \"23.2.8568313\"; */ })\n" ;;
        python)         lines+="          # (devenv.python)\n" ;;
        java)           lines+="          # (devenv.java)\n" ;;
        node)           lines+="          # (devenv.node)\n" ;;
      esac
    fi
  done
  echo -e "$lines"
}

cat > flake.nix << EOF
{
  description = "${PROJECT_NAME}";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    development-tools.url = "path:/home/bulentk/workspace/bulentk/nixos-config/development-tools";
  };
  outputs = { nixpkgs, flake-utils, development-tools, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        devenv = development-tools.lib.\${system};
        tools = devenv.merge [
$(generate_merge_line)
        ];
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = tools.packages;
          shellHook = tools.shellHook + ''
            echo "${PROJECT_NAME} development environment is ready."
          '';
        };
      }
    );
}
EOF

echo "Project '${PROJECT_NAME}' created."
echo "cd ${PROJECT_NAME} && nix develop"
