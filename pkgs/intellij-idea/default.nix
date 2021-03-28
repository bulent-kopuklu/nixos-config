{ lib, stdenv, callPackage, fetchurl
, python
, jdk, cmake, libxml2, zlib, python3, ncurses5
, dotnet-sdk_3
, vmopts ? null
}:

with lib;

let
  mkJetBrainsProduct = callPackage ./common.nix { inherit vmopts; };

  buildIdea = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "IDEA";
      extraLdPath = [ zlib ];
      meta = with lib; {
        homepage = "https://www.jetbrains.com/idea/";
        inherit description license;
        longDescription = ''
          IDE for Java SE, Groovy & Scala development Powerful
          environment for building Google Android apps Integration
          with JUnit, TestNG, popular SCMs, Ant & Maven. Also known
          as IntelliJ.
        '';
        maintainers = with maintainers; [ edwtjo gytis-ivaskevicius ];
        platforms = [ "x86_64-darwin" "i686-darwin" "i686-linux" "x86_64-linux" ];
      };
    });

in {
  idea-community = buildIdea rec {
    name = "idea-community-${version}";
    version = "2020.3.2"; /* updated by script */
    description = "Integrated Development Environment (IDE) by Jetbrains, community edition";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
      sha256 = "0zkjmvi27b69xrkn4s6f5788n5yn044phgf48kamfqfs37q4xf1d"; /* updated by script */
    };
    wmClass = "jetbrains-idea-ce";
    update-channel = "IntelliJ IDEA RELEASE";
  };
}