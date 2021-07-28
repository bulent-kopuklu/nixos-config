self: super: {
  discord = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.57.1";
    src = super.fetchurl {
#      name= "VSCode_${version}_linux-x64.tar.gz"
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0cklp0mp7qylzrqnfbvzs308q0bzpswlqw5n98qhl1jb5783svx1";
    };
  });
}
