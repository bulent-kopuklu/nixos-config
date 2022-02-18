{config, lib, ...}:

let
  cfg =  config.env.role;
in {

  options = {
    env.role.virtualisation = lib.mkEnableOption "virtualisation role";
  };

  config = lib.mkIf cfg.virtualisation {
    
  };
}
