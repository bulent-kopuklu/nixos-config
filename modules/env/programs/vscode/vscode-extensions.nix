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
      name = "better-cpp-syntax";
      publisher = "jeff-hykin";
      version = "1.15.19";
      sha256 = "13v1lqqfvgkf5nm89b39hci65fnz4j89ngkg9p103l1p1fhncr41";
    }
    {
      name = "Kotlin";
      publisher = "mathiasfrohlich";
      version = "1.7.1";
      sha256 = "0zi8s1y9l7sfgxfl26vqqqylsdsvn5v2xb3x8pcc4q0xlxgjbq1j";
    }
    {
      name = "cmake-tools";
      publisher = "ms-vscode";
      version = "1.13.3";
      sha256 = "13219kxbkw69rfifmk9i4wswamq68h30qa931zibv6fql8df3lpy";
    }
    {
      name = "cpptools-themes";
      publisher = "ms-vscode";
      version = "1.0.0";
      sha256 = "0nds0bx9zsnfgfqgpzlbd79wwnjnhsivf0qbnbiakhj2z8c0niqk";
    }
    {
      name = "makefile-tools";
      publisher = "ms-vscode";
      version = "0.6.0";
      sha256 = "07zagq5ib9hd3w67yk2g728vypr4qazw0g9dyd5bax21shnmppa9";
    }
    {
      name = "vscode-typescript-next";
      publisher = "ms-vscode";
      version = "4.9.20220907";
      sha256 = "1fi79jmg3wz0f4izp56j4qy21z326546438ar4vbwfri9z1cf5n8";
    }
    {
      name = "cmake";
      publisher = "twxs";
      version = "0.0.17";
      sha256 = "11hzjd0gxkq37689rrr2aszxng5l9fwpgs9nnglq3zhfa1msyn08";
    }
    {
      name = "vscode-gradle";
      publisher = "vscjava";
      version = "3.12.2022090700";
      sha256 = "0dz9q5km4sr1cglkyiv43gwh3w86cjszahajs8p6vf2dgj9skkfn";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.38.2022082703";
      sha256 = "0ls8l4jwd8f3z9szvgdcyf4vrzxgg2bdm9yvga3mlyg2saxiz38b";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.16.0";
      sha256 = "0fgpr356nbq8c2m8xqbhqnlgwrysc8cq78kngkmhv988hgm4kccv";
    }
  ];
})
