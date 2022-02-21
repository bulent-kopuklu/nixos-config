{ pkgs, ... }:

let 
  theme = import ./theme.nix;
  i3 = {
    ws7 = "7 ${theme.icons.envelope}";
    ws8 = "8 ${theme.icons.comment}";
    ws9 = "9 ${theme.icons.music}";   
  };

in 
pkgs.writeText "i3-config" ''

  # This file has been auto-generated by i3-config-wizard(1).
  # It will not be overwritten, so edit it as you like.
  #
  # Should you change your keyboard layout some time, delete
  # this file and re-run i3-config-wizard(1).
  #

  # i3 config file (v4)
  #
  # Please see https://i3wm.org/docs/userguide.html for a complete reference!

  set $mod Mod4

  exec --no-startup-id ${pkgs.systemd}/bin/systemctl --user restart polybar
  exec --no-startup-id ${pkgs.thunderbird}/bin/thunderbird
  exec --no-startup-id ${pkgs.udiskie}/bin/udiskie -A -n -t -f nautilus
  exec --no-startup-id ${pkgs.blueman}/bin/blueman-applet
  
  font pango:DejaVuSansMono 12

  focus_follows_mouse yes

  default_border normal 3
  #pixel 4
  default_floating_border normal 2

  for_window [all] title_window_icon on
  for_window [all] title_window_icon padding 3px

  floating_modifier $mod

  gaps inner 6
  gaps outer 4

  smart_gaps on
  smart_borders on

  # class                 border  backgr. text    indicator child_border
  client.focused          ${theme.colors.amber} ${theme.colors.amber} ${theme.colors.black} ${theme.colors.green} ${theme.colors.amber}
  client.focused_inactive ${theme.colors.blueGray} #004052 ${theme.colors.white} ${theme.colors.green} ${theme.colors.blueGray}
  client.unfocused        ${theme.colors.blueGray} #004052 ${theme.colors.blueGray} ${theme.colors.green} ${theme.colors.blueGray}
  client.urgent           ${theme.colors.blueGray} #004052 ${theme.colors.white} ${theme.colors.green} ${theme.colors.blueGray}
  client.placeholder      ${theme.colors.blueGray} #004052 ${theme.colors.white} ${theme.colors.green} ${theme.colors.blueGray}

  client.background       ${theme.colors.white}

  assign [class="Thunderbird"]         ${i3.ws7}
  assign [class="vlc"]                 ${i3.ws9}
  assign [class="rhythmbox|Rhythmbox"] ${i3.ws9}
  for_window [instance="spotify|Spotify"] move to workspace ${i3.ws9}
  assign [class="Skype|skypeforlinux"] ${i3.ws8}
  assign [class="discord"]             ${i3.ws8}
  assign [class="slack|Slack"]         ${i3.ws8}

  for_window [class="feh"] floating enable, border normal
  #for_window [class="feh"] border normal
  for_window [class=".blueman-manager-wrapped"] floating enable, border normal
  #for_window [class=".blueman-manager-wrapped"] border normal
  for_window [class="pavucontrol|Pavucontrol"] floating enable, border normal
  #for_window [class="pavucontrol|Pavucontrol"] border normal
  for_window [class="gnome-calculator|Gnome-calculator"] floating enable, border normal
  #for_window [class="gnome-calculator|Gnome-calculator"] border normal
  for_window [window_role="pop-up"] floating enable, border normal
  #for_window [window_role="pop-up"] border enable

  mode "resize" {
    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
    bindsym Right resize grow width 10 px or 10 ppt

    # back to normal: Enter or Escape or $mod+r
    bindsym Escape mode "default"
  }

  bindsym $mod+r mode "resize"
  bindsym --release button3 kill
  bindsym --release button1 fullscreen

''
