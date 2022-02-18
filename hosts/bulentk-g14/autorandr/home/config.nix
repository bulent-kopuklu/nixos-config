{
  path = ".config/autorandr/home/config";
  text = ''
    output DP-0
    off
    output DP-1
    off
    output HDMI-A-1-0
    off
    output DP-0.1.8
    crtc 1
    mode 2560x1440
    pos 0x0
    rate 59.95
    output DP-0.8
    crtc 0
    mode 2560x1440
    pos 2560x0
    primary
    rate 59.95
    output eDP-1-0
    crtc 4
    mode 1920x1080
    pos 5120x0
    rate 60.01
  '';
}
