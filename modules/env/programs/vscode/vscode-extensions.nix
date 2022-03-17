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
      version = "4.7.20220316";
      sha256 = "0vr88ksrbd909052f7isnij56rilfpszrzl45h0rk1lhqbbvljzs";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.11.2022031600";
      sha256 = "0j6ilgm11nbh4aax123dsycma448xxwnw624s9apn9jn8prvlw74";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.35.2022031703";
      sha256 = "12v94wrd72q3gy91vx8x6cc9acac991jngfs6mpisg3rscq0334k";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.10.0";
      sha256 = "0n96jdmqqh2v7mni4qv08qjxyhp8h82ck9rhmwnxp66ni5ybmj63";
    }
  ];
})
