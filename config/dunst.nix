{ pkgs, ... }:

let
  theme = import ./theme.nix;
in pkgs.writeText "dunst-config" ''
  [global]
    font = Comfortaa 10
    format = "<b>%a</b>\n%s\n<i>%b</i>"

    follow = mouse
    sticky_history = yes

    ### Geometry ###
    width = 256
    height = 256
    origin = top-right
    offset = 3x36
    scale = 0
    notification_limit = 0

    max_icon_size = 64

    progress_bar = true
    indicate_hidden = true

    icon_path = ${pkgs.numix-icon-theme}/share/icons/Numix/64/status:${pkgs.numix-icon-theme}/share/icons/Numix/64/devices

    sort = true
    show_indicators = yes
    icon_position = left

    dmenu = "${pkgs.dmenu}/bin/dmenu"
    browser = "${pkgs.firefox}/bin/firefox"
    corner_radius = 5

    transparency = 50
    background = "${theme.colors.dark-theme.background4}"
    foreground = "${theme.colors.dark-theme.foreground}"
    frame_width = 2
    frame_color = "${theme.colors.dark-theme.border}"

  [urgency_low]
    timeout = 10

  [urgency_normal]
    timeout = 10

  [urgency_critical]
    frame_color = "${theme.colors.red}"
    timeout = 0


  [history]
    appname = notifyctl
    summary = "history"
    script = dunst_espeak.sh
''
