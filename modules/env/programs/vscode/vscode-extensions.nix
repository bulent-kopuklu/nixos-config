{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    ms-vscode.cpptools
    redhat.java
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "nix-env-selector";
      publisher = "arrterian";
      version = "1.0.9";
      sha256 = "0kdfhkdkffr3cdxmj7llb9g3wqpm13ml75rpkwlg1y0pkxcnlk2f";
    }
    {
      name = "vscode-eslint";
      publisher = "dbaeumer";
      version = "2.2.6";
      sha256 = "0m16wi8slyj09r1y5qin9xsw4pyhfk3mj6rs5ghydfnppb45w9np";
    }
    {
      name = "xml";
      publisher = "DotJoshJohnson";
      version = "2.5.1";
      sha256 = "1v4x6yhzny1f8f4jzm4g7vqmqg5bqchyx4n25mkgvw2xp6yls037";
    }
    {
      name = "gitlens";
      publisher = "eamodio";
      version = "2022.10.2605";
      sha256 = "1kz7v9w10zd6dnhbxavcy2kns27p3nh18aq181ch5hvkbgn3140d";
    }
    {
      name = "go";
      publisher = "golang";
      version = "0.35.2";
      sha256 = "1nkf96wsnlaimganx0kn4lhdajpnps5rsm8dhyh0j8vdlw3wl0v1";
    }
    {
      name = "haskell";
      publisher = "haskell";
      version = "2.2.1";
      sha256 = "14p9g07zsb3da4ilaasgsdvh3wagfzayqr8ichsf6k5c952zi8fk";
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
      version = "1.16.3";
      sha256 = "1fdchrm3i7qlhqnyi2icgcmi4b0kr27bp0mgys7iyswfqh3nfji7";
    }
    {
      name = "nix-ide";
      publisher = "jnoortheen";
      version = "0.2.1";
      sha256 = "0bibb3r4cb7chnx6vpyl41ig12pc0cbg0sb8f2khs52c71nk4bn8";
    }
    {
      name = "language-haskell";
      publisher = "justusadam";
      version = "3.6.0";
      sha256 = "115y86w6n2bi33g1xh6ipz92jz5797d3d00mr4k8dv5fz76d35dd";
    }
    {
      name = "Kotlin";
      publisher = "mathiasfrohlich";
      version = "1.7.1";
      sha256 = "0zi8s1y9l7sfgxfl26vqqqylsdsvn5v2xb3x8pcc4q0xlxgjbq1j";
    }
    {
      name = "vscode-docker";
      publisher = "ms-azuretools";
      version = "1.22.2";
      sha256 = "13scns5iazzsjx8rli311ym2z8i8f4nvbcd5w8hqj5z0rzsds6xi";
    }
    {
      name = "python";
      publisher = "ms-python";
      version = "2022.17.13011006";
      sha256 = "1wq7k2855mxxb9d9d1v2ffhiyrddzgjp04zvzb5jkh4ar9fxp6vz";
    }
    {
      name = "vscode-pylance";
      publisher = "ms-python";
      version = "2022.10.41";
      sha256 = "1k89ygrffc7ljgkmh75y8mxc70jfip7v7nmsrizaly2hzicxsid5";
    }
    {
      name = "jupyter";
      publisher = "ms-toolsai";
      version = "2022.10.1103031027";
      sha256 = "066gk1d3bdxajipkb8xz3cl61i6pf1p3np0azg69xqclka0yn1d4";
    }
    {
      name = "cmake-tools";
      publisher = "ms-vscode";
      version = "1.13.19";
      sha256 = "05xz96i33gi9s9djchl6c7r0cdlxli5aj5xp4bbnjf0ybx4fjvi6";
    }
    {
      name = "cpptools-themes";
      publisher = "ms-vscode";
      version = "2.0.0";
      sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31";
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
      version = "4.9.20221018";
      sha256 = "0srnn6c8hygjc52w3ai1mgnw14gag1mgz2kch72wgswjzqhdylj5";
    }
    {
      name = "vscode-yaml";
      publisher = "redhat";
      version = "1.11.10112022";
      sha256 = "0i53n9whcfpds9496r4pa27j3zmd4jc1kpkf4m4rfxzswwngg47x";
    }
    {
      name = "scala";
      publisher = "scala-lang";
      version = "0.5.6";
      sha256 = "004zc3id5jk8hk6q27g4p36prvnlqdsgda0gd6xvs4gamhywhb3s";
    }
    {
      name = "metals";
      publisher = "scalameta";
      version = "1.20.2";
      sha256 = "14rxag5iph0cjg1l5fwanqbp32n805zkisa67splfq3nh8hqcl1k";
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
      version = "3.12.2022101400";
      sha256 = "1iaqcha1r6mvykgkdcr2w3b55v8kjgfacbfnmc8165pfq3krq14v";
    }
    {
      name = "vscode-maven";
      publisher = "vscjava";
      version = "0.39.2022101303";
      sha256 = "1grbr0xf19c0a3gx8053mya9v2yfgk27n1wxhdgasgx5vj8v4glh";
    }
    {
      name = "vscode-icons";
      publisher = "vscode-icons-team";
      version = "12.0.1";
      sha256 = "0dfgjawrykw4iw0lc3i1zpkbcvy00x93ylwc6rda1ffzqgxq64ng";
    }
    {
      name = "markdown-all-in-one";
      publisher = "yzhang";
      version = "3.4.4";
      sha256 = "0jw38vf3pzplw5dnhs8b9fxqc4z5b198wjw3y3ll14xjzxc5ymns";
    }
    { 
      name = "cpp-class-creator"; 
      publisher = "FleeXo"; 
      version = "1.1.0"; 
      sha256 = "094lycf2s260rmx7wnmlna8wfgqixdwznqnla1ilkrp1g1m35ixy"; 
    }

  ];
})
