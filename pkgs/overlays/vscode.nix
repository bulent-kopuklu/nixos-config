self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.91.1";
    src = super.fetchurl {
      name = "VSCode_${version}_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0ighhwwmc8cxdabq2wkzzr21sv6zaj90pnqi2cy8krfwm88w6jc0";
    };

    # runtimeDependencies = oldAttrs.runtimeDependencies ++ [
    #   super.pkgs.zlib
    #   super.pkgs.jdk17
    # ];

  });
}


# nix-prefetch-url https://update.code.visualstudio.com/1.91.1/linux-x64/stable


# nix-prefetch-url