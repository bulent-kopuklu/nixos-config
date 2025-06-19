self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.99.0";
    src = super.fetchurl {
      name = "VSCode_${version}_linux-x64.tar.gz";
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "1fds83amgkzp9nz7cvs432ilr602lr45h916vkq8qhpbb84ildd2";
    };

    # runtimeDependencies = oldAttrs.runtimeDependencies ++ [
    #   super.pkgs.zlib
    #   super.pkgs.jdk17
    # ];

  });
}


# nix-prefetch-url https://update.code.visualstudio.com/1.91.1/linux-x64/stable


# nix-prefetch-url