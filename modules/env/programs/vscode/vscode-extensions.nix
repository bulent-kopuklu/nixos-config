{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    dotjoshjohnson.xml
    golang.go
    jnoortheen.nix-ide
    ms-azuretools.vscode-docker
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-vscode.cmake-tools
    ms-vscode.cpptools
    ms-vscode.makefile-tools
    redhat.java
    redhat.vscode-yaml
    twxs.cmake
    vscjava.vscode-gradle
    vscjava.vscode-maven
    vscode-icons-team.vscode-icons
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "cpp-class-creator";
      publisher = "fleexo";
      version = "1.4.0";
      sha256 = "1q8ccrcdlksg7z9l7p4h1nllfnwqfwqhd7vkvicyldphl7fdjs4b";
    }
    {
      name = "better-cpp-syntax";
      publisher = "jeff-hykin";
      version = "1.21.4";
      sha256 = "0l3ncf585p7bjjvzx82zmnns5z925sf986xs9kgi7sn2f6575a6p";
    }
    {
      name = "kotlin";
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
      version = "5.5.20240424";
      sha256 = "04cxxpvihbaibadyls8k4w5gx9nm6a50fwd151q882kgjd3ak3ww";
    }
  ];
})
