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
      version = "5.3.20230808";
      sha256 = "0bdidvnl46j62hzr1sx6qlic2q1wmy52pp07w9grrgjqdx2fmpdl";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2023072100";
      sha256 = "00chxnvssaqqgz2d1m8zqpgr946sqad1xn2r1x9zv4nzzrg8846y";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "12.5.0";
      sha256 = "0fqawpfwqmj7hiv1g20z3zhs2rv3a9insqd93ad9416mhj89mcry";
    }
  ];
})
