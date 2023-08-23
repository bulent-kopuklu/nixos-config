self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.78.2";
    src = super.fetchurl {
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "1khpn7j3rf0pb5ya4jzpgy0awhamx5dy3pspbxhxl943lzagyvq6";
    };
  });
}