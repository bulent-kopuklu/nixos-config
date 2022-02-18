{ config, pkgs, ... }:

let
  theme = import ./theme.nix;
  
  app-launcher-menu = "${pkgs.x11apps}/bin/app-launcher-menu";
  show-windows = "${pkgs.x11apps}/bin/show-windows-menu";
  power-menu = "${pkgs.x11apps}/bin/power-menu";
  lock-screen = "${pkgs.x11apps}/bin/lock-screen";
  screenshot = "${pkgs.x11apps}/bin/screenshot";
  audioctl = "${pkgs.x11apps}/bin/audioctl";

  i3-msg = "${pkgs.i3-gaps}/bin/i3-msg";
  #TODO sound var mi
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  sleep = "${pkgs.coreutils}/bin/sleep";
  scrot = "${pkgs.scrot}/bin/scrot";
  awk = "${pkgs.gawk}/bin/awk";


in pkgs.writeText "sxhkd-config" ''

  ctrl+alt+Delete
    ${power-menu}
  
  super+Return
    $TERMINAL

  super+Insert
    ${app-launcher-menu}
  super + d
    ${app-launcher-menu}

  super+l
    ${lock-screen}

  super+Delete
    ${i3-msg} kill

  super+f
    ${i3-msg} fullscreen

  super+Down
    ${i3-msg} focus down
  super+Up
    ${i3-msg} focus up
  super+Left
    ${i3-msg} focus left
  super+Right
    ${i3-msg} focus right
  super+space
    ${i3-msg} focus mode_toggle
  super+a
    ${i3-msg} focus parent
  super+d
    ${i3-msg} focus child

  super+shift+Down
    ${i3-msg} move down
  super+shift+Up
    ${i3-msg} move up
  super+shift+Left
    ${i3-msg} move left
  super+shift+Right
    ${i3-msg} move right

  super+z
    ${i3-msg} workspace prev
  super+x
    ${i3-msg} workspace next

  super+{1-6}
    ${i3-msg} workspace '{1-6}'
  super+7
    ${i3-msg} workspace '7 ${theme.icons.envelope}'
  super+8
    ${i3-msg} workspace '8 ${theme.icons.comment}'
  super+9
    ${i3-msg} workspace '9 ${theme.icons.music}'

  super+shift+{1-6}
    ${i3-msg} move container to workspace '{1-6}'
  super+shift+7
    ${i3-msg} move container to workspace '7 ${theme.icons.envelope}'
  super+shift+8
    ${i3-msg} move container to workspace '8 ${theme.icons.comment}'
  super+shift+9
    ${i3-msg} move container to workspace '9 ${theme.icons.music}'

  super+h
    ${i3-msg} split h
  super+v
    ${i3-msg} split v

  super+s
    ${i3-msg} layout stacking
  super+w
    ${i3-msg} layout tabbed
  super+e
    ${i3-msg} layout toggle split

  super+shift+space
    ${i3-msg} floating toggle


  super+n
    ${i3-msg} focus output left
  super+m
    ${i3-msg} focus output right

  super+shift+n
    ${i3-msg} move workspace to output left
  super+shift+m
    ${i3-msg} move workspace to output right  

  super+Tab
    ${i3-msg} workspace back_and_forth
  super+shift+Tab
    ${i3-msg} move container to workspace back_and_forth
  alt+Tab
    ${show-windows}

  XF86AudioMicMute
    ${audioctl} --source-mute-toggle
  super+XF86AudioMicMute
    ${audioctl} --source-mute-toggle
  super+XF86AudioRaiseVolume 
    ${audioctl} --source-volume-up
  super+XF86AudioLowerVolume
    ${audioctl} --source-volume-down

  XF86AudioMute 
    ${audioctl} --sink-mute-toggle
  XF86AudioRaiseVolume
    ${audioctl} --sink-volume-up
  XF86AudioLowerVolume
    ${audioctl} --sink-volume-down


  Print 
    ${scrot} $HOME/Pictures/scrot-%Y-%m-%d_%T.png

  shift+Print
    ${sleep} 0.2;\
    ${scrot} -s $HOME/Pictures/scrot-%Y-%m-%d_%T.png

''
