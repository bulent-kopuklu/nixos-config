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
      name = "cmake-tools";
      publisher = "ms-vscode";
      version = "1.12.18";
      sha256 = "098m05rx5kph87rm5r42bamh004xb624fqzgaxcfdbl20ix8axba";
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
      version = "0.5.0";
      sha256 = "18p0ayw20f2shsw7fysvdrh1mc9fyp1cjiv7xmh5yxda7q3h05m0";
    }
    {
      name = "vscode-typescript-next";
      publisher = "ms-vscode";
      version = "4.8.20220803";
      sha256 = "1p75mygg5vfzgvdg01imkm1zfhvywis0mlax67ai1p35qmbmbi9m";
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
      version = "3.12.2022080300";
      sha256 = "1wzhjiiib1xzla3kpx9qim1g36fxl9lqa8kip8hkwmq0ks5hrn5l";
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
      version = "11.14.0";
      sha256 = "1sbn40ix69cw2q6j3hq61p1f7da3fr3imrvzpp63ga73qynajbcr";
    }
  ];
})
