{ config, lib, pkgs, inputs, ... }:

let
  cfg =  config.env;
in {

  options = {
    env.role.development = lib.mkEnableOption "development role";
  };

  config = lib.mkIf cfg.role.development {

    env.role.virtualisation = lib.mkForce true;

    programs.adb.enable = true;
    
    users.users.${cfg.user.name}.extraGroups = ["adbusers"];

    services.globalprotect = {
      enable = true;
      # if you need a Host Integrity Protection report
      csdWrapper = "${pkgs.openconnect}/libexec/openconnect/hipreport.sh";
    };

    env.programs.docker.enable = true;

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    env.programs.vscode.enable = true;

    environment.systemPackages = with pkgs; [
      git-lfs
      git
      git-lfs
      nixd
      nixfmt-rfc-style

      pkg-config           # build dependency çözümü için
      binutils-unwrapped
      gnumake

      jetbrains.idea-oss
      android-studio

      # xorg.libXrender
      # xorg.libX11
      # xorg.libXext
      # xorg.libXtst
      # xorg.libXi

      aider-chat-full

    ];
  };
}
