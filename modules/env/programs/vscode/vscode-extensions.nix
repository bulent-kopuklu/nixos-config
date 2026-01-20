{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    bradlc.vscode-tailwindcss
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    dotjoshjohnson.xml
    editorconfig.editorconfig
    golang.go
    jnoortheen.nix-ide
    llvm-vs-code-extensions.vscode-clangd
    mkhl.direnv
    ms-azuretools.vscode-docker
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-vscode.cmake-tools
    ms-vscode.makefile-tools
    prisma.prisma
    redhat.java
    redhat.vscode-yaml
    ritwickdey.liveserver
    vscjava.vscode-gradle
    vscjava.vscode-maven
    vscode-icons-team.vscode-icons
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "cpp-helper";
      publisher = "amiralizadeh9480";
      version = "0.3.4";
      sha256 = "0f0b5zcp58z85vhfyd6f6yxa770bgagd2ymbqg66z3mh4xrclysd";
    }
    {
      name = "es7-react-js-snippets";
      publisher = "dsznajder";
      version = "4.4.3";
      sha256 = "1xyhysvsf718vp2b36y1p02b6hy1y2nvv80chjnqcm3gk387jps0";
    }
    {
      name = "cpp-class-creator";
      publisher = "fleexo";
      version = "1.4.0";
      sha256 = "1q8ccrcdlksg7z9l7p4h1nllfnwqfwqhd7vkvicyldphl7fdjs4b";
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
  ];
})
