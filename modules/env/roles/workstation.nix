{config, lib, ...}:

let
  cfg =  config.env.role;
in {

  options = {
    env.role.workstation = lib.mkEnableOption "workstation role";
  };

  config = lib.mkIf cfg.workstation {
    
  };
}
