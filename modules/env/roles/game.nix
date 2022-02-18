{config, lib, ...}:

let
  cfg =  config.env.role;
in {

  options = {
    env.role.game = lib.mkEnableOption "game role";
  };

  config = lib.mkIf cfg.game {
    
  };
}
