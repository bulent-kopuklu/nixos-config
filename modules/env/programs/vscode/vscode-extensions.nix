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
      version = "4.7.20220424";
      sha256 = "192gjdvm2229nn7s58ifpa8gvnl270fcbzzd3b9s24xkiip71g95";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022042500";
      sha256 = "170hknbq58d8x5xnbjyzcafp7d87108ph575lirhjn9izmpk5i8l";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.35.2022041103";
      sha256 = "15zzr8rmby4as1brgdpcvm9dabjc25xvrmb3i2bw7nkzihapqzc7";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.11.0";
      sha256 = "0qd9y0rb1j70iha8gqkxv2xvds6n4db8p0h8arlqcsfayljkn5v6";
    }
  ];
})
