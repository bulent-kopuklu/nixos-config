{ 
  stdenv, 
  pkgs, 
  makeWrapper, 
  polybarFull, 
  gawk, 
  coreutils, 
  wifiSupport ? false, 
  cpuTemperaturePath ? "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon8/temp1_input", 
  soundSupport ? false, 
  battery ? { enable = false; name = "BAT0"; adapter = "AC"; } 
}:
let
  apps = pkgs.callPackage ./polybar-apps { wifiSupport = wifiSupport; };
  cfg = pkgs.callPackage ../../../config/polybar.nix { 
    cpuTemperaturePath = cpuTemperaturePath; 
    polybar-apps = apps; 
    soundSupport = soundSupport; 
    battery = battery; 
    };

  version =  polybarFull.version;

  polybar-wrapped-bin = stdenv.mkDerivation rec {
    pname = "polybar-wrapped-bin";
    version =  polybarFull.version;
    
    buildInputs = [ makeWrapper polybarFull ];
    buildCommand = ''
      mkdir -p $out/bin
      mkdir -p $out/libexec
      for cmd in $(ls ${polybarFull}/bin); do
        ln -s ${polybarFull}/bin/$cmd $out/bin/$cmd
      done

      wrapProgram $out/bin/polybar --add-flags "-q -c ${cfg}"
    '';
  };

  polybar-launcher = let  
    awk = "${gawk}/bin/awk";
    tee = "${coreutils}/bin/tee";
    echo = "${coreutils}/bin/echo";
    polybar = "${polybar-wrapped-bin}/bin/polybar";
    polybar-msg = "${polybar-wrapped-bin}/bin/polybar-msg";
  in pkgs.writeShellScriptBin "polybar-launcher" ''
    ${polybar-msg} cmd quit
    for m in $(${polybar} --list-monitors | ${awk} -F':' '{print $1}'); do
      MONITOR=$m ${polybar} top &
    done
  '';
# 2>&1 | ${tee} -a /tmp/polybar1.log & disown
#       MONITOR=$m ${polybar} bottom &
in pkgs.symlinkJoin {
  name = "polybar-wrapped";
  version = polybarFull.version;
  paths = [ polybar-launcher polybar-wrapped-bin ];
}

