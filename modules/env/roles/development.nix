{ config, lib, pkgs, inputs, ... }:

let
  cfg =  config.env;
in {

  options = {
    env.role.development = lib.mkEnableOption "development role";
  };

  config = lib.mkIf cfg.role.development {

    env.role.virtualisation = lib.mkForce true;

    users.users.${cfg.user.name}.extraGroups = ["adbusers"];

    env.programs.docker.enable = true;

    programs.nix-ld.enable = true;
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    env.programs.vscode.enable = true;

    nixpkgs.config.permittedInsecurePackages = [
      "idea-oss-2025.3.4"
    ];

    environment.systemPackages = with pkgs; [
      inputs.development-tools.packages.${pkgs.system}.mkproject
      git-lfs
      git
      git-lfs
      nixd
      nixfmt

      pkg-config           # build dependency çözümü için
      binutils-unwrapped
      gnumake

#      jetbrains.idea-oss
      android-studio
      android-tools
      # xorg.libXrender
      # xorg.libX11
      # xorg.libXext
      # xorg.libXtst
      # xorg.libXi

      unityhub

      aider-chat-full
      unstable.claude-code
      nodejs_latest
      (python3.withPackages(python-pkgs: with python-pkgs; [ 
        pyyaml 
      ]))
      uv

    ];
  };
}
