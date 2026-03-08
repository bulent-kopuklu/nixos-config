# NixOS Development Environment Architecture

## 🎯 Tasarım Hedefi

Sistem-wide minimal kurulum + per-project isolasyon ile farklı versiyonlar çakışmadan kullanabilme.

**Sorun:** `project-a` LLVM 18 istiyor, `project-b` LLVM 20 istiyor → Çözüm: Flake.nix + direnv

---

## 📐 Mimari Katmanlar

### 1. System-Level (NixOS Config)
**Dosya:** `modules/env/roles/development.nix`

**Ne Olmalı:**
- ✅ Generic text editor: VSCode (TÜM extension'lar yüklü)
- ✅ VCS: git, git-lfs
- ✅ Environment management: direnv, nix-direnv
- ✅ GUI Tools: meld, postman, dbeaver-bin
- ✅ Optional: Docker, VirtualBox (system services)

**Ne OLMAMALI:**
- ❌ Compiler'lar (gcc, clang, rustc...)
- ❌ Language runtimes (python3, nodejs, jdk...)
- ❌ Build tools (cmake, cargo, maven...)
- ❌ LSP servers (rust-analyzer, clangd... - but extensions yes!)

**Reason:** Proje bazlı versiyonlama gerekiyor.

---

### 2. Project-Level (flake.nix)
**Lokasyon:** `<project-root>/flake.nix`

**Ne Olmalı:**
- ✅ Compiler/toolchain (language-specific)
- ✅ LSP servers (binary'ler)
- ✅ Formatters/Linters (binary'ler)
- ✅ Project-specific VSCode instance
- ✅ Direnv ile $PATH integration

**Mimari:**
```
devShells.default
  ├── buildInputs (compiler, build tools)
  ├── packages.default (VSCode + extensions)
  └── shellHook (PATH exports)
```

---

## 🔧 VSCode Strategy

### System-Wide VSCode
```nix
# modules/env/programs/vscode/vscode-extensions.nix
vscodeExtensions = [
  # Generic (her projede)
  editorconfig.editorconfig
  github.copilot
  github.copilot-chat
  mkhl.direnv
  donjayamanne.githistory
  yzhang.markdown-all-in-one
  redhat.vscode-yaml
  dotjoshjohnson.xml
  tamasfe.even-better-toml
  jnoortheen.nix-ide
  vscode-icons-team.vscode-icons
  
  # Language extensions (binary olmasa da ok)
  rust-lang.rust-analyzer
  llvm-vs-code-extensions.vscode-clangd
  ms-python.python
  ms-python.vscode-pylance
  ms-vscode.cmake-tools
  redhat.java
  golang.go
  dbaeumer.vscode-eslint
  bradlc.vscode-tailwindcss
  prisma.prisma
  ms-azuretools.vscode-docker
];
```

**Avantaj:** 
- Extension'lar hafif (birkaç MB)
- Binary olmasa da zarar vermez
- Global settings korunur

**Dezavantaj:**
- Rust projektede clangd extension hata mesajı verebilir (binary yok)

### Project-Specific VSCode Derivation
```nix
# cpp-project/flake.nix
packages.default = pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    # Generic
    editorconfig.editorconfig
    github.copilot
    mkhl.direnv
    
    # C++ only
    llvm-vs-code-extensions.vscode-clangd
    ms-vscode.cmake-tools
  ];
};
```

**Çözüm:** Project-specific VSCode instance → sadece relevant extension'lar

---

## 📦 Template Struktur (nix-templates Repository)

Ayrı repository: `github.com/bulent-kopuklu/nix-templates`

```
nix-templates/
├── flake.nix
├── cpp/
│   ├── flake.nix
│   ├── default.nix          # VSCode + toolchain derivation
│   ├── .vscode/
│   │   ├── settings.json    # C++ specific settings
│   │   └── extensions.json  # Recommended extensions
│   └── src/
│       └── main.cpp
├── rust/
│   ├── flake.nix
│   ├── default.nix
│   ├── .vscode/
│   │   ├── settings.json
│   │   └── extensions.json
│   └── src/
│       └── main.rs
├── python/
│   ├── flake.nix
│   ├── default.nix
│   ├── .vscode/
│   │   └── settings.json
│   └── main.py
├── typescript/
├── java/
└── hybrid/
    ├── flake.nix
    ├── default.nix
    └── .vscode/
```

### Template flake.nix örnek (cpp):

```nix
{
  description = "C++ Development Environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # VSCode + C++ extensions
        cpp-vscode = pkgs.vscode-with-extensions.override {
          vscodeExtensions = with pkgs.vscode-extensions; [
            editorconfig.editorconfig
            github.copilot
            mkhl.direnv
            llvm-vs-code-extensions.vscode-clangd
            ms-vscode.cmake-tools
            ms-vscode.makefile-tools
            vscode-icons-team.vscode-icons
          ];
        };
        
        # Toolchain
        cpp-toolchain = pkgs.buildEnv {
          name = "cpp-toolchain";
          paths = with pkgs; [
            clang_18
            clangd
            cmake
            ninja
            gnumake
            gdb
            pkg-config
          ];
        };
      in {
        packages.default = pkgs.buildEnv {
          name = "cpp-dev-env";
          paths = [ cpp-vscode cpp-toolchain ];
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            clang_18
            clangd
            cmake
            ninja
            gnumake
            gdb
            pkg-config
            cpp-vscode
          ];
          
          shellHook = ''
            export CLANG_PATH="${pkgs.clang_18}/bin"
            export CLANGD_PATH="${pkgs.clangd}/bin/clangd"
          '';
        };
      }
    );
}
```

---

## 🚀 Kullanım Akışı

### Senaryo 1: Yeni C++ Projesi

```bash
# 1. Template'den başla
nix flake init -t github:bulent-kopuklu/nix-templates#cpp
# → flake.nix, .vscode/, src/main.cpp oluşur

# 2. Direnv allow
direnv allow
# → devShell'deki packages otomatik yüklenir

# 3. VSCode aç
code .
# → Project-specific VSCode açılır (C++ extensions hazır)
```

### Senaryo 2: Hybrid Proje (C++ + Rust)

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };
  
  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = 
      let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
      pkgs.mkShell {
        buildInputs = [
          # C++
          pkgs.clang_18
          pkgs.clangd
          pkgs.cmake
          
          # Rust
          pkgs.rustc
          pkgs.rust-analyzer
          pkgs.cargo
          
          # VSCode with both extensions
          (pkgs.vscode-with-extensions.override {
            vscodeExtensions = with pkgs.vscode-extensions; [
              editorconfig.editorconfig
              github.copilot
              mkhl.direnv
              llvm-vs-code-extensions.vscode-clangd
              rust-lang.rust-analyzer
              ms-vscode.cmake-tools
            ];
          })
        ];
      };
  };
}
```

### Senaryo 3: LLVM Versiyonları Arasında Geçiş

```bash
# project-a (LLVM 18)
cd ~/projects/project-a
direnv allow
which clangd  # → /nix/store/clang_18.../bin/clangd

# project-b (LLVM 20)
cd ~/projects/project-b
direnv allow
which clangd  # → /nix/store/clang_20.../bin/clangd
```

---

## 🧪 Test Plan

### Test 1: System-Level Setup
```bash
# Mevcut nixos-config ile
make build host=bulentk-e14
make switch host=bulentk-e14

# Kontrol et:
which git          # ✅ Mevcut olmalı
which clangd       # ❌ Olmamalı (system-wide)
code --version     # ✅ Çalışmalı
```

### Test 2: C++ Project
```bash
# Yeni flake.nix ile
mkdir /tmp/test-cpp
cd /tmp/test-cpp
nix flake init -t github:bulent-kopuklu/nix-templates#cpp
direnv allow

# Kontrol et:
which clangd       # ✅ Olmalı
which rustc        # ❌ Olmamalı
code .             # ✅ C++ extensions var, Rust yok
```

### Test 3: Rust Project
```bash
mkdir /tmp/test-rust
cd /tmp/test-rust
nix flake init -t github:bulent-kopuklu/nix-templates#rust
direnv allow

which rust-analyzer  # ✅ Olmalı
which clangd         # ❌ Olmamalı
code .               # ✅ Rust extensions var, C++ yok
```

### Test 4: Hybrid (C++ + Rust)
```bash
mkdir /tmp/test-hybrid
cd /tmp/test-hybrid

cat > flake.nix << 'EOF'
# Yukarıdaki Senaryo 2 flake.nix
EOF

direnv allow
which clangd       # ✅ Olmalı
which rust-analyzer # ✅ Olmalı
code .             # ✅ Her iki extension var
```

---

## 📋 Implementation Steps

1. **System-level'i temizle**
   - [ ] `modules/env/roles/development.nix` → sadece minimal tools
   - [ ] `modules/env/programs/vscode/vscode-extensions.nix` → TÜM extensions

2. **nix-templates repository oluştur**
   - [ ] github.com/bulent-kopuklu/nix-templates
   - [ ] cpp/, rust/, python/, typescript/, java/ templates

3. **Her template'de**
   - [ ] flake.nix (devShell + packages.default)
   - [ ] .vscode/settings.json (language-specific)
   - [ ] .vscode/extensions.json (recommended)
   - [ ] Boilerplate code (src/main.*)

4. **Test et**
   - [ ] System build
   - [ ] Template'lerden projects başlat
   - [ ] Direnv + VSCode integration

5. **Dokumentasyon**
   - [ ] README.md → her template'de
   - [ ] Quick start guide

---

## 🔗 Git Integration

```bash
# System-level flake.nix'e template'ler input olarak eklenebilir
inputs.cpp-template.url = "github:bulent-kopuklu/nix-templates/cpp";
inputs.rust-template.url = "github:bulent-kopuklu/nix-templates/rust";
```

Veya `nix flake init` ile doğrudan kullan.

---

## 📝 Notlar

- **Extension binary'si olmasa da:** VSCode çalışır, sadece feature'lar devre dışı
- **Global VSCode settings:** Project instance'lar devralır
- **PATH isolation:** Direnv her proje için ayrı PATH sağlar
- **Disk usage:** Extension'lar ~50-100MB toplam (negligible)
- **Build time:** İlk build ~2-3 dakika, sonra cache kullanılır

---

## ❓ Open Questions

1. Diğer projeler için başka languages?
2. Database tools (dbeaver) system-wide mi?
3. Android development nasıl integrate olacak?
4. Docker + Nix integration?
