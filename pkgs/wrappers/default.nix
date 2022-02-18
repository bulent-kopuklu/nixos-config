self: super:

let
  mkWrapped = { name, cmd ? name, package, arg}:
    super.stdenv.mkDerivation {
      name = name + "-wrapped-" + (package.version or "");
      buildInputs = [ super.makeWrapper ];
      buildCommand = ''
        mkdir -p $out/bin

        for d in $(ls ${package}); do
          if [ $d != "bin" ]; then
            ln -s ${package}/$d $out/$d
          fi
        done
        for b in $(ls ${package}/bin); do
          ln -s ${package}/bin/$b $out/bin/$b
        done

        wrapProgram $out/bin/${cmd} --add-flags "${arg}"
      '';
    };

in {
  alacritty-wrapped = let
      cfg = super.callPackage ../../config/alacritty.nix {};
    in mkWrapped {
      name = "alacritty";
      package = super.alacritty;
      arg = "--config-file ${cfg}";
    };

  sxhkd-wrapped = let
      cfg = super.callPackage ../../config/sxhkd.nix {};
    in mkWrapped {
      name = "sxhkd";
      package = super.sxhkd;
      arg = "-c ${cfg}";
    };

  dunst-wrapped = let
      cfg = super.callPackage ../../config/dunst.nix {};
    in mkWrapped {
      name = "dunst";
      package = super.dunst;
      arg = "-config ${cfg}";
    };

  i3-wrapped = let
      cfg = super.callPackage ../../config/i3wm.nix {};
    in mkWrapped {
      name = "i3";
      package = super.i3-gaps;
      arg = "-c ${cfg}";
    };


  polybar-wrapped = super.callPackage ./polybar { };
}
