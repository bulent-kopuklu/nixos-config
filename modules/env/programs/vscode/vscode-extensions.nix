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
    ms-vscode.cmake-tools
    ms-vscode.cpptools
    ms-vscode.makefile-tools
    redhat.java
    redhat.vscode-yaml
    scala-lang.scala
    scalameta.metals
    twxs.cmake
    vscjava.vscode-maven
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "cpp-class-creator";
      publisher = "FleeXo";
      version = "1.1.0";
      sha256 = "094lycf2s260rmx7wnmlna8wfgqixdwznqnla1ilkrp1g1m35ixy";
    }
    {
      name = "haskell-linter";
      publisher = "hoovercj";
      version = "0.0.6";
      sha256 = "0fb71cbjx1pyrjhi5ak29wj23b874b5hqjbh68njs61vkr3jlf1j";
    }
    {
      name = "better-cpp-syntax";
      publisher = "jeff-hykin";
      version = "1.17.5";
      sha256 = "16dpgs4blis4yajw51yhby54pag28r74wwf6szx4nr79f44lgh7y";
    }
    {
      name = "Kotlin";
      publisher = "mathiasfrohlich";
      version = "1.7.1";
      sha256 = "0zi8s1y9l7sfgxfl26vqqqylsdsvn5v2xb3x8pcc4q0xlxgjbq1j";
    }
    {
      name = "cpptools-themes";
      publisher = "ms-vscode";
      version = "2.0.0";
      sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31";
    }
    {
      name = "vscode-typescript-next";
      publisher = "ms-vscode";
      version = "5.1.20230405";
      sha256 = "1b3zaa0w3bfxghckk7xcnym5q0abylc7pk8gjbi0pd1p9c2kfr9c";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2023032800";
      sha256 = "0zcvn6bmdgw6mvzawdphfxnpi0h3wxpamnbz5lrmmcn567fa9k28";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "12.2.0";
      sha256 = "12s5br0s9n99vjn6chivzdsjb71p0lai6vnif7lv13x497dkw4rz";
    }
  ];
})
