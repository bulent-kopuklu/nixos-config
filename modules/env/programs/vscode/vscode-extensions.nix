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
      version = "4.7.20220302";
      sha256 = "19zgrzbwdc9jxpymjqcab12bppnj5c8c5lwk08f46d8hfqdz35qx";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.11.2022030100";
      sha256 = "1gf1pn5ayl096hhy8x1yqkd5djgbapk8yy1vwh2i1y3ih8rhlgra";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.35.1";
      sha256 = "164wp5whdf4nimga12s23yvzzjiim2h9bqwcy9330551jwa8sj8k";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.10.0";
      sha256 = "0n96jdmqqh2v7mni4qv08qjxyhp8h82ck9rhmwnxp66ni5ybmj63";
    }
  ];
})
