self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.89.0";
    src = super.fetchurl {
      name = "VSCode_${version}_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0hy1ppv7wzyy581k3skmckaas0lwkx5l6w4hk1ml5f2cpkkxhq5w";
    };

    # runtimeDependencies = oldAttrs.runtimeDependencies ++ [
    #   super.pkgs.zlib
    #   super.pkgs.jdk17
    # ];

  });
}


# nix-prefetch-url