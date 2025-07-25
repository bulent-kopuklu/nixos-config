
{
  path = ".config/autorandr/encom/config";
  text = ''
    output HDMI-1
    off
    output DP-1
    off
    output DP-2
    off
    output DP-3
    off
    output DP-4
    off

    output DP-3-1
    crtc 0
    mode 2560x1440
    primary
    pos 0x0
    rate 59.95
    x-prop-audio auto
    x-prop-broadcast_rgb Automatic
    x-prop-max_bpc 12
    x-prop-non_desktop 0

    output DP-3-8
    crtc 1
    mode 2560x1440
    pos 2560x0
    rate 59.95
    x-prop-audio auto
    x-prop-broadcast_rgb Automatic
    x-prop-max_bpc 12
    x-prop-non_desktop 0

    output eDP-1
    crtc 2
    mode 1920x1200
    pos 5120x0
    rate 60.00
    x-prop-broadcast_rgb Automatic
    x-prop-colorspace Default
    x-prop-max_bpc 12
    x-prop-non_desktop 0
    x-prop-scaling_mode Full aspect
  '';
}
