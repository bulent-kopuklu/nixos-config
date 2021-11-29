{ config, pkgs, lib, ... }:

# config, specialArgs, options, modulesPath,

pkgs.stdenv.mkDerivation rec {
  pname = "asusctl";
  version = "4.0.6";

  src = pkgs.fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "0mgyii74chyk5s9hkkggmjv8glkl74b4xzfk6knnv9mirg4sx2s6";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ libudev0-shim ];

  meta = with lib; {
    description = "asus controll";
    homepage = "https://gitlab.com/asus-linux/asusctl";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}