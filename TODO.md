# Development & System Configuration TODO

## Current Session Decisions (locked)
- [x] **No direct edits** to `modules/env/roles/development.nix` until TODO plan is finalized
- [x] **System-wide should stay minimal**; language toolchains must be project-level
- [x] **Project entry model** is `flake.nix` + `.envrc` (`direnv`)
- [x] Validate whether VSCode extensions are managed globally or via project-specific VSCode derivations

## Phase 1: Development Tooling Standardization

### 1.1 System-wide Packages (minimal, language-agnostic)
- [x] `git`
- [x] `direnv`
- [x] `nix-direnv`

### 1.1.1 Move out of system PATH (must be project-level only)
- [ ] Remove language toolchains from `modules/env/roles/development.nix` PATH set
  - `clang`, `clang-tools`, `gcc`, `cmake`, `ninja`, `gdb`
  - `rustc`, `cargo`, `rust-analyzer`, `clippy`, `rustfmt`
  - `python*`, `poetry`
  - `nodejs*`, `pnpm`, `typescript`
  - `jdk*`, `maven`, `gradle`
- [ ] Keep GUI/dev apps by policy decision only (e.g. `postman`, `dbeaver-bin`, `meld`)

### 1.2 Language-specific Tool Sets
- [ ] **C/C++**: `cmake`, `clang`, `clang-tools`, `ninja`, `gdb` (+ optional: `lldb`, `valgrind`)
- [ ] **Rust**: `rustc`, `cargo`, `rust-analyzer`, `clippy`, `rustfmt`
- [ ] **Python**: `python312`, `pip`, `virtualenv` (or `uv`), `poetry` (optional)
- [ ] **Java**: `jdk17`, `maven`, `gradle` (wrapped via overlay)
- [ ] **Node/TS**: `nodejs_20`, `pnpm` (or single standard npm/yarn)

### 1.2.1 Per-project flake template plan
- [ ] Define templates for: `cpp`, `rust`, `python`, `java`, `typescript`, `hybrid`
- [ ] Each template includes:
  - `devShells.default` (toolchain in PATH only inside project)
  - Optional `packages.default` for project-scoped VSCode
  - `.envrc` with `use flake`
- [ ] Add one real test project per template under `/tmp` and verify with `which` checks

### 1.3 Gradle Overlay Standard
- [x] Create `pkgs/overlays/gradle.nix` with wrapper
  - Wrapper default: `GRADLE_USER_HOME="$HOME/.local/share/gradle"`
  - Keep command name as `gradle`
- [x] Update `pkgs/overlays/default.nix` to import gradle overlay
- [x] Remove `GRADLE_USER_HOME` env from `modules/env/programs/gradle.nix`

### 1.4 GC / System Closure Strategy
- [ ] Create `development-tools/default.nix` in nixos-config root
  - Export `cpp`, `rust`, `python`, `java`, `node` tool sets
- [ ] Update `modules/env/roles/development.nix`
  - Use `system.extraDependencies` to keep tools in closure (GC-safe)
  - Tools NOT in PATH by default (only in project devShells)
- [ ] Verify project flakes import correctly

### 1.4.1 Version conflict proof (required)
- [ ] Create test A: LLVM 18 project
- [ ] Create test B: LLVM 20 project
- [ ] Verify isolation:
  - In A: `which clangd` points LLVM 18 store path
  - In B: `which clangd` points LLVM 20 store path
- [ ] Confirm no global `clangd` dependency required for project behavior

### 1.5 VSCode Extensions Cleanup
- [ ] Review current `modules/env/programs/vscode/vscode-extensions.nix`
- [ ] Remove unused/test extensions
- [ ] Add missing language-specific extensions (C++, Rust, Python, Java, Node)
- [ ] Verify no global extension pollution across projects

### 1.5.1 VSCode architecture decision checklist
- [x] Option G (global extensions): keep one system VSCode with broad extension set
- [ ] Option P (project VSCode): build `vscode-with-extensions` per project template
- [ ] Compare both with these criteria:
  - Global theme/settings stability (`$HOME/.config/Code/User/settings.json`)
  - Hybrid project ergonomics (C++ + Rust + TS together)
  - Missing-binary warning noise when extension installed but tool absent
  - Startup/build overhead
- [ ] Lock one strategy and document final rule in `ARCHITECTURE.md`

### 1.6 Android Shell (Terminal-first, Studio-free)
- [x] `android-shell.nix` in nix-templates working
  - ✅ Emulator, ADB, sdkmanager from terminal
  - ✅ Java dependency on jdk17
  - ✅ Writable AVD/config in `$HOME/.local/share/android`
  - ✅ Zsh enforced
- [x] Test emulator startup from shell

---

## Phase 2: Vulkan + Wayland Migration (separate sprint)

### 2.1 Wayland Session
- [ ] Remove x11 from default session
- [ ] Set up Wayland compositor (sway/hyprland)
- [ ] Migrate i3wm config → wayland equivalent

### 2.2 Vulkan Graphics Stack
- [ ] Replace X11 graphics deps with Vulkan
- [ ] Update display server / compositor config
- [ ] Test GPU acceleration

### 2.3 Clean x11 References
- [ ] Remove unused x11 packages from system
- [ ] Clean xsession configurations

---

## Notes
- **Development tools:** In system closure but NOT in PATH (avoids global polluting)
- **Project shells:** Use `buildInputs = devTools.cpp ++ devTools.rust` etc.
- **Gradle:** Wrapped once, works everywhere without role toggle
- **Android:** Terminal-only, no Studio dependency
- **Zsh:** All shell hooks enforced (no Bash-isms)
- **Do not touch `development.nix`** until the VSCode extension strategy is locked
