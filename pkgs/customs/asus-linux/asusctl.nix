{ lib, rustPlatform, fetchFromGitLab, pkg-config, libudev, systemd, coreutils }:

# config, specialArgs, options, modulesPath, , clang, libclang

rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.0.7";

  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "13x1g6n5qrwblcyzjzsshvar2h7himryhzg6hnjx7jrkq7wlw1m4";
  };

  nativeBuildInputs = [ pkg-config libudev ];
  buildInputs = [ libudev ];
  runtimeLibs = [ libudev ];
  
  doCheck = false;
#  cargoSha256 = "1wnlsp8kin8hqh1sjw98crl7sz2bndrmp7q5r96crpcwi9dkly1q"; #lib.fakeSha256;
  cargoHash = "sha256-bFfO6UAje+Wmcfi85IGgzK0GmE16dJxb8xDlcFHrX+M=";

  patchPhase = ''
    substituteInPlace data/asus-notify.service \
        --replace "/usr/bin/sleep" "${coreutils}/bin/sleep" \
        --replace "/usr/bin/asus-notify" "$out/bin/asus-notify"
    
    substituteInPlace data/asusd-user.service \
        --replace "/usr/bin/sleep" "${coreutils}/bin/sleep" \
        --replace "/usr/bin/asusd-user" "$out/bin/asusd-user"
    
    substituteInPlace data/asusd.service \
        --replace "/bin/sleep" "${coreutils}/bin/sleep" \
        --replace "/usr/bin/asusd" "$out/bin/asusd"
    
    substituteInPlace data/asusd.rules \
        --replace "systemctl restart" "${systemd}/bin/systemctl restart"

    substituteInPlace daemon/src/ctrl_anime/config.rs \
        --replace "/usr/share/asusd" "$out/share/asusd"

    substituteInPlace daemon-user/src/user_config.rs \
        --replace "/usr/share/asusd" "$out/share/asusd"
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    runHook preInstall

    DESTDIR=$out make install
    mv $out/usr/* $out/
    rm -r $out/usr

    runHook postInstall
  '';

#    rm -r $out/lib/systemd/system

/* 
  postInstall = ''
    cd $out/lib
    substituteInPlace systemd/system/asusd.service \
        --replace "/usr/bin/asusd" "$out/bin/asusd" \
        --replace "/bin/sleep" "${coreutils}/bin/sleep"

    substituteInPlace systemd/user/asusd-user.service \
        --replace "/usr/bin/asusd-user" "$out/bin/asusd-user" \
        --replace "/usr/bin/sleep" "${coreutils}/bin/sleep"

    substituteInPlace systemd/user/asus-notify.service \
        --replace "/usr/bin/asus-notify" "$out/bin/asus-notify" \
        --replace "/usr/bin/sleep" "${coreutils}/bin/sleep"
  
    substituteInPlace udev/rules.d/99-asusd.rules \
      --replace "systemctl restart" "${systemd}/bin/systemctl restart"
  '';
 */
  meta = with lib; {
    description = "asus controll";
    homepage = "https://gitlab.com/asus-linux/asusctl";
    license = licenses.mpl20;
    platforms = platforms.linux;
  };
}