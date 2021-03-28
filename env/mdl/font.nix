{ config, pkgs, expr, buildVM, ... }:

{
  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;

    fonts = with pkgs; [
      noto-fonts-emoji
      powerline-fonts
      cascadia-code
      emacs-all-the-icons-fonts
      material-icons
    ];

    fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "DejaVuSansMono" ];
    };
  };
}