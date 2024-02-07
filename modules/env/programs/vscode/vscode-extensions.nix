{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    dotjoshjohnson.xml
    eamodio.gitlens
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
    github.copilot
    github.copilot-chat
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "cpp-class-creator";
      publisher = "FleeXo";
      version = "1.1.0";
      sha256 = "094lycf2s260rmx7wnmlna8wfgqixdwznqnla1ilkrp1g1m35ixy";
    }
    {
      name = "better-cpp-syntax";
      publisher = "jeff-hykin";
      version = "1.21.1";
      sha256 = "13k0jj4jasq6z4ip9rvzx0g5rkg2fx5p3vl1vnfy3b0v1lz6pryb";
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
      version = "5.4.20240206";
      sha256 = "0xjlvk57jnq3ar2pxy7p069s651flxjmbdyni1y06s2qgrqdxp76";
    }
  ];
})
