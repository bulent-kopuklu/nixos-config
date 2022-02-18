{ config, pkgs, lib, ... }:

let
  cfg = config.env.programs.vscode;
  vscode-packages = import ./vscode-extensions.nix { inherit pkgs; };
in {
  options.env.programs.vscode = {
    enable = lib.mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vscode-packages
    ];

#    env.user.files = {
#      user-settings = import ../../../config/gtk/gtk2-rc.nix;
#    };

  };
}