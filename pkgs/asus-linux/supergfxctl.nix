{ lib, rustPlatform, fetchFromGitLab, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "2.0.3";

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname; #"asusctl";
    rev = version;
    sha256 = "0k71dycay204y4zhmx7w8v3nb0y9g9w1bi72als07kwlw4spbq2i";
  };

  nativeBuildInputs = [ pkg-config ];
#  buildInputs = [ libudev ];
#  runtimeLibs = [ libudev ];

  doCheck = false;
  cargoSha256 = "10cdn88rfls54hzam3rlf6vpz4cg4m8d12k1s0n0yhczjnfyijh0"; #lib.fakeSha256;

  installPhase = ''
    runHook preInstall

    install -D -m 755 chia_plot $out/bin/chia_plot

    runHook postInstall
  '';

  meta = with lib; {
    description = "asus controll";
    homepage = "https://gitlab.com/asus-linux/supergfxctl";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}