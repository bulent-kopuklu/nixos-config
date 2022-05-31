{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    dbaeumer.vscode-eslint
    dotjoshjohnson.xml
    eamodio.gitlens
    golang.go
    haskell.haskell
    jnoortheen.nix-ide
    justusadam.language-haskell
    ms-azuretools.vscode-docker
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-vscode.cpptools
    redhat.java
    redhat.vscode-yaml
    scala-lang.scala
    scalameta.metals
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "vscode-direnv";
      publisher = "cab404";
      version = "1.0.0";
      sha256 = "0xikkhbzb5cd0a96smj5mr1sz5zxrmryhw56m0139sbg7zwwfwps";
    }
    {
      name = "haskell-linter";
      publisher = "hoovercj";
      version = "0.0.6";
      sha256 = "0fb71cbjx1pyrjhi5ak29wj23b874b5hqjbh68njs61vkr3jlf1j";
    }
    {
      name = "vscode-typescript-next";
      publisher = "ms-vscode";
      version = "4.8.20220530";
      sha256 = "0rw535x8r8dsmh4r7snvdygbwjcwchdxvkf0aa06z2kpq3g5zpwh";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022053100";
      sha256 = "1nqnnwsdl76aszrh80b6dqvrf8lvwxx6048qldgqcs50c0hh4lli";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.35.2022053103";
      sha256 = "11ag9r4bpibdi1mxpnrkd8kdff1h5kf02b96a0fk3pgb6zngir13";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.12.0";
      sha256 = "121177jwcy73xp1cx8v1kcm5w63pqsa1ydhqwwnjdhazm6dkl9wg";
    }
  ];
})
