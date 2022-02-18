{ lib, rustPlatform, fetchFromGitLab, pkg-config, libudev }:

# nix-prefetch-git https://gitlab.com/asus-linux/supergfxctl.git --rev 4.0.2

rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "4.0.2";

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "00sbk93zy2wlhv6mi27x3q95ixk7hj2blxjc3ibyx58xaga4a4kh";
  };

  nativeBuildInputs = [ pkg-config libudev ];
  buildInputs = [ libudev ];
  runtimeLibs = [ libudev ];

  doCheck = false;
  cargoHash = "sha256-e+NajTWnSLWb+Mw8/ha37Bc6+YW5E7cXhRk8HjkUcoo="; #lib.fakeSha256;

  patchPhase = ''
    substituteInPlace data/supergfxd.service \
        --replace "/usr/bin/supergfxd" "$out/bin/supergfxd"
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    runHook preInstall
    
    DESTDIR=$out make install
    mv $out/usr/* $out/
    rm -R $out/usr

    runHook postInstall
  '';
/* 
  postInstall = ''
    cd $out/lib
    substituteInPlace systemd/system/supergfxd.service \
        --replace "/usr/bin/supergfxd" "$out/bin/supergfxd" \
  '';
 */

  meta = with lib; {
    description = "control daemon, CLI tools, and a collection of crates for interacting with ASUS ROG laptops";
    homepage = "https://gitlab.com/asus-linux/supergfxctl";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}