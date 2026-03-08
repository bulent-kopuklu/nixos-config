# NixOS Configuration - AI Agent Instructions

## Architecture Overview

This is a **modular NixOS flake configuration** for managing multiple machines with shared and machine-specific configurations. The architecture follows a strict separation between system (`sys`) and environment (`env`) concerns.

### Directory Structure

- **`flake.nix`**: Defines three machine configurations (`bulentk-vm`, `bulentk-e14`, `bulentk-g14`) using NixOS 25.11 stable
- **`hosts/`**: Per-machine configurations - hardware specs, kernel params, autorandr display profiles
- **`modules/`**: Reusable configuration modules split into:
  - **`modules/sys/`**: System-level hardware abstraction (CPU, memory, sound, bluetooth, battery, NICs)
  - **`modules/env/`**: User environment (programs, services, xsession, roles)
- **`config/`**: Application configuration templates (i3wm, polybar, alacritty, dunst) written as Nix expressions returning config file text
- **`pkgs/`**: Custom packages and overlays:
  - **`pkgs/customs/`**: Custom derivations (x11apps like rofi menus, lock-screen, power-menu)
  - **`pkgs/wrappers/`**: Wrapped packages with injected config files (alacritty-wrapped, i3-wrapped, sxhkd-wrapped, dunst-wrapped, polybar-wrapped)
  - **`pkgs/overlays/`**: Nixpkgs overlays for patches or version pins

## Critical Patterns

### Hardware Abstraction via Options

Machine configs declare hardware capabilities using the `sys.hw.*` option namespace (see `modules/sys/hardware.nix`):

```nix
sys.hw = {
  cpu.cores = 22;
  cpu.sensorTemperaturePath = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon8/temp1_input";
  memorySize = 64;
  sound = true;
  wifi = true;
  bluetooth = true;
  battery.enable = true;
  keychron = true;  # Special udev rule for Keychron keyboards
  nics = [ ];
};
```

The module uses `mkIf` conditions to enable services conditionally (pipewire for sound, blueman for bluetooth, etc.).

### Role-Based Configuration

User environments use **role composition** (`modules/env/roles/`):

```nix
env.role = {
  workstation = true;
  development = true;
  virtualisation = true;
};
```

Each role is a separate module (workstation.nix, development.nix, game.nix, server.nix, virtualisation.nix) that enables related packages/services. Roles can force-enable other roles (e.g., `development` forces `virtualisation`).

### Config File Injection via Wrappers

Applications are wrapped with immutable config files from `config/` directory. See `pkgs/wrappers/default.nix`:

```nix
alacritty-wrapped = mkWrapped {
  name = "alacritty";
  package = super.alacritty;
  arg = "--config-file ${cfg}";  # cfg from config/alacritty.nix
};
```

**Never edit ~/.config files** - edit Nix expressions in `config/` and rebuild.

### Autorandr Display Profiles

Multi-monitor setups use autorandr profiles stored in `hosts/*/autorandr/`:
- `config.nix`: xrandr output configuration
- `setup.nix`: EDID fingerprints for auto-detection

Profiles are declared in host config:
```nix
env.programs.autorandr.profiles = {
  "encom" = {
    config = ./autorandr/encom/config.nix;
    setup = ./autorandr/encom/setup.nix;
  };
};
```

### Custom X11 Apps Package

`pkgs/customs/x11apps/` bundles rofi-based menus (app-launcher, show-windows, power-menu, lock-screen, audioctl) into a single `x11apps` package using `symlinkJoin`. Theme data from `config/theme.nix` is passed as function arguments.

## Build & Deploy Workflows

### Building for a Specific Host

```bash
make build host=bulentk-e14
# Equivalent to: nixos-rebuild build --flake ".#bulentk-e14"
```

### Switching System Configuration

```bash
make switch host=bulentk-e14
# Equivalent to: nixos-rebuild switch --use-remote-sudo --flake ".#bulentk-e14"
```

### Full Update Workflow

```bash
make update host=bulentk-e14
# Runs: nix flake update, then switch
```

**Always specify `host=` parameter** - Makefile won't default to current hostname.

### Testing in VM

```bash
make build-vm host=bulentk-vm
make start-vm host=bulentk-vm  # Allocates 8GB RAM
```

## File Editing Guidelines

### Adding a New Machine

1. Create `hosts/<hostname>/default.nix` with `sys.hw.*` and `env.*` options
2. Add `nixosConfigurations.<hostname>` entry to `flake.nix`
3. Consider nixos-hardware module imports (see bulentk-e14 example)

### Modifying Application Config

1. Edit Nix file in `config/` directory (e.g., `config/i3wm.nix`)
2. Config is a function returning text: `pkgs.writeText "i3-config" ''...''`
3. Reference theme variables: `theme = import ./theme.nix;`
4. Rebuild to apply changes - no manual config file edits needed

### Adding a Custom Package

1. Create derivation in `pkgs/customs/<category>/`
2. Export from `pkgs/customs/default.nix` as overlay
3. Reference in `environment.systemPackages` or role modules

### Creating Wrapped Package

1. Define in `pkgs/wrappers/default.nix` using `mkWrapped` pattern
2. Config file must be in `config/` directory
3. Update references to use `-wrapped` variant (e.g., `cfg.terminal.package = pkgs.alacritty-wrapped`)

## Known Quirks

- **i915 vs xe driver**: bulentk-e14 uses Intel Xe driver with `xe.force_probe=7d55` kernel param and blacklists i915
- **Keychron keyboard**: Requires udev rule that runs on USB attach to set `/sys/module/hid_apple/parameters/fnmode`
- **DHCP**: System-level DHCP disabled (`networking.useDHCP = false`), managed per-NIC in hardware module
- **Swappiness**: Systems with >=32GB RAM set `vm.swappiness = 1`
- **VSCode extensions**: Commented-out auto-update tool in Makefile (`install/vscode-extention-tool`)

## Testing Changes

Always test with `make build host=<hostname>` before `make switch`. Check for:
- Option type mismatches (use `lib.types.*` correctly)
- Missing imports in module default.nix files
- Circular dependencies in overlays
- Correct `mkIf` condition logic for hardware-dependent features

## Common Tasks

**Add package to all development machines**: Edit `modules/env/roles/development.nix`, add to `environment.systemPackages`

**Change i3 keybindings**: Edit `config/sxhkd.nix` (hotkey daemon config), not i3wm.nix

**Add new display profile**: Create dirs under `hosts/<host>/autorandr/<profile>/`, add config.nix and setup.nix (use `autorandr --save` to generate)

**Modify polybar**: Polybar has its own wrapper with custom apps in `pkgs/wrappers/polybar/`
