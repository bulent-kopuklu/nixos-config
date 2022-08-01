self: super: {
  smartgithg = super.smartgithg.overrideAttrs(oldAttrs: rec {
    pname = "smartgithg";
    version = "21.2.3";
    src = super.fetchurl {
      url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.gz";
      sha256 = "1znkdjxwbzzdm3gg7a9bhbfixywr0z0ivhx0940p7by7xl0x98x5";
    };
  });
}