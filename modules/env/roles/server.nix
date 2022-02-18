{config, lib, ...}:

let
  cfg =  config.env.role;
in {

  options = {
    env.role.server = lib.mkEnableOption "server role";
  };

  config = lib.mkIf cfg.server {
    
  };
}
