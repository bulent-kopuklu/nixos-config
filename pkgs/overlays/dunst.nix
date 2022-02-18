self: super: {
  dunst = super.dunst.overrideAttrs(oldAttrs: rec {
    pname = "dunst";
    version = "1.7.3";

    src = super.fetchFromGitHub {
      owner = "dunst-project";
      repo = "dunst";
      rev = "v${version}";
      sha256 = "sha256-8s8g1J8vEogCp29tSwX5eqYTDf1dLoyBznnwAlCMQOU=";
    };
  });
}