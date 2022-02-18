{ config, lib, pkgs, ... }:

let 
  cfg = config.env;
in {
  imports = [
    ./programs
    ./services
    ./xsession
    ./roles
    ./user.nix
    ./std-env.nix
    ./std-console.nix
  ];

  options.env = {
    terminal = {
      command = lib.mkOption {
        type = lib.types.str;
        default = "alacritty";
      };

      package = lib.mkOption {
        type = lib.types.package;
        description = ''
          Which package to use for terminal application.
        '';
        default = pkgs.alacritty-wrapped;
      };
    };
  };

  config = {

    environment.variables = {
      TERMINAL = "${cfg.terminal.command}";
      EDITOR = "nvim";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME= "$HOME/.local/state";
      XDG_BIN_HOME = "$HOME/.local/bin";
    };

    environment.systemPackages = with pkgs; [
      bash
      git
      neovim
      wget
      coreutils-full
      cfg.terminal.package
    ];

    system.activationScripts.ldso = lib.stringAfter [ "usrbinenv" ] ''                       
      mkdir -m 0755 -p /lib64                                                                
      ln -sfn ${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2.tmp   
      mv -f /lib64/ld-linux-x86-64.so.2.tmp /lib64/ld-linux-x86-64.so.2 # atomically replace 
    '';                                                                                      
  };
}