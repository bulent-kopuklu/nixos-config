{ config, pkgs, expr, buildVM, ... }:

#let 
#    myscripts = pkgs.callPackage scripts/default.nix { inherit pkgs };
#in
{
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
        alsaSupport = false;
        pulseSupport = true;
      };
    };
  };

  services.xserver = {
    displayManager = {        
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        greeters.enso.enable = true;
      };

      sessionCommands = ''
        ${pkgs.feh}/bin/feh --bg-scale $XDG_DATA_HOME/wallpapers/cwp
        ${pkgs.xlibs.xset}/bin/xset dpms 0 0 0
        ${pkgs.xlibs.xset}/bin/xset s off
        ${pkgs.xlibs.xset}/bin/xset s off -dpmsuseGlamor
        # ${pkgs.xss-lock}/bin/xss-lock -n $XDG_BIN_HOME/lock-notify.sh -- $XDG_BIN_HOME/lock.sh &

        # gpg-agent for X session
        # gpg-connect-agent /bye
        # GPG_TTY=$(tty)
        # export GPG_TTY

        # use gpg-agent for SSH
        # NOTE: make sure enable-ssh-support is included in ~/.gnupg/gpg-agent.conf
        # unset SSH_AGENT_PID
        # export SSH_AUTH_SOCK="/run/user/1000/gnupg/S.gpg-agent.ssh"
      '';
    };

    windowManager.i3.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lxappearance
    xss-lock
    xlibs.xbacklight
    xlibs.xmodmap
    xlibs.xev
    xlibs.xinput
    xlibs.xmessage
    xlibs.xkill
    xlibs.xgamma

    xlibs.xset
    xlibs.xrandr
    xlibs.xrdb
    xlibs.xprop

    sxhkd
    dmenu
    networkmanager_dmenu
    scrot
    fontconfig
    udiskie 

    libnotify
    dunst

    i3lock
    libpulseaudio
    polybar
  ];

  services.accounts-daemon.enable = true; # needed by lightdm
}