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
      version = "4.8.20220723";
      sha256 = "1lyyzc3pmap4dcnxxnxs9bhnlss3c39wz2ir8nqx2kqj1nz7s8hs";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022072600";
      sha256 = "0nn8ljkzmix8nbd2wrnph022rpi0bakxhj2krybnljv134wad7rw";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.37.2022072603";
      sha256 = "1dxjjprn2s3mq2wybaz90fa4rx429v2ppnv5yg6ana4r8hmjyh1r";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.13.0";
      sha256 = "1nsp0bb5b3h9ihncxgnnybxmqryvdd8x4bgw9wb771kvm35lk0is";
    }
  ];
})
