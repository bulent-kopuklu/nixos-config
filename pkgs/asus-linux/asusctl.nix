{ lib, rustPlatform, fetchFromGitLab, pkg-config, libudev }:

# config, specialArgs, options, modulesPath, , clang, libclang

rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.0.6";

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname; #"asusctl";
    rev = version; #"38d047cb8a4c6342dde6b78ff78302ebf8236a7b";
    sha256 = "0mgyii74chyk5s9hkkggmjv8glkl74b4xzfk6knnv9mirg4sx2s6";
  };

  nativeBuildInputs = [ pkg-config libudev ];
  buildInputs = [ libudev ];
  runtimeLibs = [ libudev ];

  #LIBCLANG_PATH = "${libclang.lib}/lib";

  doCheck = false;
  cargoSha256 = "1wnlsp8kin8hqh1sjw98crl7sz2bndrmp7q5r96crpcwi9dkly1q"; #lib.fakeSha256;

  meta = with lib; {
    description = "asus controll";
    homepage = "https://gitlab.com/asus-linux/asusctl";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}