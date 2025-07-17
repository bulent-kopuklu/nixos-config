{config, lib, pkgs, ...}:

let
  cfg =  config.env.role;
in {

  options = {
    env.role.virtualisation = lib.mkEnableOption "virtualisation role";
  };

  config = lib.mkIf cfg.virtualisation {
    
    virtualisation.virtualbox.host.enable = true;
    virtualisation.virtualbox.host.enableExtensionPack = true;
    
    virtualisation.docker.enable = true;
#    virtualisation.docker.enableNvidia = true;

#    virtualisation.libvirtd.enable = true;
#    programs.virt-manager.enable = true;

    # dconf.settings = {
    #   "org/virt-manager/virt-manager/connections" = {
    #     autoconnect = ["qemu:///system"];
    #     uris = ["qemu:///system"];
    #   };
    # };


    users.users.${config.env.user.name}.extraGroups = ["libvirtd" "kvm"];

    environment.systemPackages = [
      pkgs.docker-compose

    ];

    environment.variables = {
      DOCKER_CONFIG = "$HOME/.config/docker";
    };
  };
}
