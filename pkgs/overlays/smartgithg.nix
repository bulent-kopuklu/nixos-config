self: super: {
  smartgithg = super.smartgithg.overrideAttrs(oldAttrs: rec {
    pname = "smartgithg";
    version = "20.2.5";
    src = super.fetchurl {
      url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.gz";
      sha256 = "05f3yhzf6mvr6c5v6qvjrx97pzrrnkh9mp444zlkbnpgnrsmdc6v";
    };
  });
}
