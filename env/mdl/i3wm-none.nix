{ config, pkgs, expr, buildVM, ... }:

#let 
#    myscripts = pkgs.callPackage scripts/default.nix { inherit pkgs };
#in
{
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
      };
    };
  };

  services.xserver = {
    displayManager = {        
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        greeters.enso.enable = true;
        background = /home/bulentk/.local/share/wallpapers/cls.png;
      };
    };

    windowManager.i3.enable = true;

    sessionCommands = ''
      # ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
      ${pkgs.feh}/bin/feh --bg-scale $XDG_DATA_HOME/wallpapers/cwp
      # Send notification after 10 mins of inactivity,
      # lock the screen 10 seconds later.
      ${pkgs.xlibs.xset}/bin/xset s 600 10
      # ${pkgs.xss-lock}/bin/xss-lock -n $XDG_BIN_HOME/lock-notify.sh -- $XDG_BIN_HOME/lock.sh &

      # disable PC speaker beep
      # ${pkgs.xlibs.xset}/bin/xset -b

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

#        sxhkd
    dmenu
    networkmanager_dmenu
    scrot
    fontconfig
    udiskie 
 
    dunst
    libnotify

    i3lock
    polybar
  ];

  services.accounts-daemon.enable = true; # needed by lightdm

  # Required for our screen-lock-on-suspend functionality
  services.logind.extraConfig = ''
    LidSwitchIgnoreInhibited=False
    HandleLidSwitch=suspend
    HoldoffTimeoutSec=10
  '';
}
