self: super: {
  smartgithg = super.smartgithg.overrideAttrs(oldAttrs: rec {
    pname = "smartgithg";
    version = "21.1.1";
    src = super.fetchurl {
      url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.gz";
      sha256 = "0l4jcrkbvyhnaf9sxbc8qm2b2761l5bfd2cms0qc5367bpvsw0ra";
    };
  });
}
