self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.86.0";
    src = super.fetchurl {
      name = "VSCode_${version}_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0qykchhd6cplyip4gp5s1fpv664xw2y5z0z7n6zwhwpfrld8piwb";
    };

    buildInputs = oldAttrs.buildInputs ++ [ 
      super.pkgs.alsa-lib 
      super.pkgs.libkrb5 
      super.pkgs.mesa 
      super.pkgs.nss 
      super.pkgs.nspr 
      super.pkgs.systemd 
      super.pkgs.xorg.libxkbfile 
    ];

    runtimeDependencies = oldAttrs.runtimeDependencies ++ [
      super.pkgs.zlib
      super.pkgs.jdk17
      
    ];

  });
}


# nix-prefetch-url