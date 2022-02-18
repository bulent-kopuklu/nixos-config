self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.64.0";
    src = super.fetchurl {
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0nszdd3bmixspv9wc837l9ibs996kr92awpnhx0c00mh823id9g8";
    };
  });
}