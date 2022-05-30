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
      version = "4.8.20220529";
      sha256 = "0n19rgp625sh0qad5ylfqw3csw7kh5yrqpvy96pp3qdqa6s05pzk";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022053002";
      sha256 = "0fg0z04v0pc3dy1vb5cyrc3n6lm1vgpda2lz384l98p8672qyhnx";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.35.2022053003";
      sha256 = "00zwl0zi2698aliy34bfi0ykf73dy6r86qipsz799vbd49pb53mc";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.12.0";
      sha256 = "121177jwcy73xp1cx8v1kcm5w63pqsa1ydhqwwnjdhazm6dkl9wg";
    }
  ];
})
