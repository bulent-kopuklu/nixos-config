{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "mkproject";
  src = ./mkproject;

  installPhase = ''
    mkdir -p $out/bin $out/share/templates
    cp mkproject.sh $out/bin/mkproject
    chmod +x $out/bin/mkproject

    cp -r templates $out/share/
    substituteInPlace $out/bin/mkproject \
      --replace "@templates@" "$out/share/templates"
  '';
}