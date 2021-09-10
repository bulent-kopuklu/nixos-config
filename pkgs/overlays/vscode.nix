self: super: {
  vscode = super.vscode.overrideAttrs(oldAttrs: rec {
    pname = "vscode";
    version = "1.60.0";
    src = super.fetchurl {
#      name= "VSCode_${version}_linux-x64.tar.gz"
      url = "https://update.code.visualstudio.com/${version}/linux-x64/stable";
      sha256 = "0g49765pnimh107pw3q7dlgd6jcmr5gagsvxrdx8i93mbxb0xm0c";
    };
  });
}
