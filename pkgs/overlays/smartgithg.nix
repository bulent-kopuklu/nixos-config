self: super: {
  smartgithg = super.smartgithg.overrideAttrs(oldAttrs: rec {
    pname = "smartgithg";
    version = "21.2.2";
    src = super.fetchurl {
      url = "https://www.syntevo.com/downloads/smartgit/smartgit-linux-${builtins.replaceStrings [ "." ] [ "_" ] version}.tar.gz";
      sha256 = "10v6sg0lmjby3v8g3sk2rzzvdx5p69ia4zz2c0hbf30rk0p6gqn3";
    };
  });
}