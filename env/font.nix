{ config, pkgs, expr, buildVM, ... }:

{
    fonts = {
        enableDefaultFonts = true;
        enableFontDir = true;
        
        fonts = with pkgs; [
            noto-fonts-emoji

            # For fish powerline plugin
            powerline-fonts
            cascadia-code

            # Doom emacs
            emacs-all-the-icons-fonts
            material-icons
        ];

        fontconfig = {
            enable = true;
            defaultFonts.monospace = [ "DejaVuSansMono" ];
        };
    };
}