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
#    ms-vscode.cmake-tools
    ms-vscode.cpptools
#    ms-vscode.makefile-tools
    redhat.java
    redhat.vscode-yaml
    scala-lang.scala
    scalameta.metals
#    twxs.cmake
#    vscjava.vscode-maven
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    # {
    #   name = "vscode-direnv";
    #   publisher = "cab404";
    #   version = "1.0.0";
    #   sha256 = "0xikkhbzb5cd0a96smj5mr1sz5zxrmryhw56m0139sbg7zwwfwps";
    # }
    {
      name = "haskell-linter";
      publisher = "hoovercj";
      version = "0.0.6";
      sha256 = "0fb71cbjx1pyrjhi5ak29wj23b874b5hqjbh68njs61vkr3jlf1j";
    }
    {
      name = "better-cpp-syntax";
      publisher = "jeff-hykin";
      version = "1.16.3";
      sha256 = "1fdchrm3i7qlhqnyi2icgcmi4b0kr27bp0mgys7iyswfqh3nfji7";
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
      version = "4.9.20221018";
      sha256 = "0srnn6c8hygjc52w3ai1mgnw14gag1mgz2kch72wgswjzqhdylj5";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022101400";
      sha256 = "1iaqcha1r6mvykgkdcr2w3b55v8kjgfacbfnmc8165pfq3krq14v";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "12.0.1";
      sha256 = "0dfgjawrykw4iw0lc3i1zpkbcvy00x93ylwc6rda1ffzqgxq64ng";
    }
#    {
#      name = "makefile-tools";
#      publisher = "ms-vscode";
#      version = "0.6.0";
#      sha256 = "0dfgjawrykw4iw0lc3i1zpkbcvy00x93ylwc6rda1ffzqgxq64ng";
#    }

  ];
})
