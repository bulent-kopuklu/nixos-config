self: super: {
  smartgithg = super.smartgithg.overrideAttrs(oldAttrs: rec {
    pname = "smartgithg";
    version = "20.2.4";
    src = super.fetchurl {
      url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.gz";
      sha256 = "1iamj1by5clb7avddm749fhw1gyg2m0i1lkyk867vzap966wp7b4";
    };
  });
}
