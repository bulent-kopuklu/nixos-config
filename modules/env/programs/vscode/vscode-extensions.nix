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
      version = "1.13.4";
      sha256 = "1z5c6lvpkyvkh2sn4fbl1vf1yx5fsd18hdgamvr2ymfmxsnwgdfc";
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
      version = "4.9.20220913";
      sha256 = "147z0zrqqpir2gq7ivf5z3716rrb2f9ra6xasr524masay30wiiz";
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
      version = "3.12.2022091400";
      sha256 = "07n6m38sxdbsg15zad1slxln3l86nmcnizwi4ps93z0cvcw88s1r";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.38.2022090603";
      sha256 = "04nrrsqpip03i2jsggsfxi3ify5i09hg14yvjwpnsqgpqs8cvqp1";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "11.17.0";
      sha256 = "1jd9q29pi6m6fng7653hfj7iy8db2lpcc1ql16lhhq1w0yf3z4ar";
    }
  ];
})
