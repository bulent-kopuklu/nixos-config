# Development & System Configuration TODO

## Current Session Decisions (locked)
- [x] **No direct edits** to `modules/env/roles/development.nix` until TODO plan is finalized
- [x] **System-wide should stay minimal**; language toolchains must be project-level
- [x] **Project entry model** is `flake.nix` + `.envrc` (`direnv`)
- [x] Validate whether VSCode extensions are managed globally or via project-specific VSCode derivations

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
