{ pkgs, ... }:

(pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions; [
    bradlc.vscode-tailwindcss
    davidanson.vscode-markdownlint
    dbaeumer.vscode-eslint
    donjayamanne.githistory
    dotjoshjohnson.xml
    editorconfig.editorconfig
    fill-labs.dependi
    github.copilot
    github.copilot-chat
    golang.go
    jnoortheen.nix-ide
    llvm-vs-code-extensions.vscode-clangd
    mkhl.direnv
    ms-azuretools.vscode-docker
    ms-dotnettools.csdevkit
    ms-dotnettools.csharp
    ms-dotnettools.vscode-dotnet-runtime
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-vscode-remote.remote-ssh-edit
    ms-vscode.cmake-tools
    ms-vscode.makefile-tools
    prisma.prisma
    redhat.vscode-xml
    redhat.vscode-yaml
    ritwickdey.liveserver
    rust-lang.rust-analyzer
    tamasfe.even-better-toml
    vadimcn.vscode-lldb
    visualstudiotoolsforunity.vstuc
    vscode-icons-team.vscode-icons
    yzhang.markdown-all-in-one
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "es7-react-js-snippets";
      publisher = "dsznajder";
      version = "4.4.3";
      sha256 = "1xyhysvsf718vp2b36y1p02b6hy1y2nvv80chjnqcm3gk387jps0";
    }
    {
      name = "cpptools-themes";
      publisher = "ms-vscode";
      version = "2.0.0";
      sha256 = "05r7hfphhlns2i7zdplzrad2224vdkgzb0dbxg40nwiyq193jq31";
    }
    {
      name = "speckit-companion";
      publisher = "alfredoperez";
      version = "0.32.0";
      sha256 = "15v15mv6g56gdk33zac011mifpl0wihb6a04xifidwjml6xavyvh";
    }
  ];
})
