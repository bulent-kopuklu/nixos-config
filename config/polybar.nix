{ 
  pkgs, 
  polybar-apps,
  cpuTemperaturePath, 
  soundSupport, 
  battery
}:

#  ; for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
#  ; for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
#  ; hwmon-path = /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon4/temp1_input

let

  theme = import ./theme.nix;

/*   foreground = {
    icon = theme.colors.black;
    text = theme.colors.blueGray;
    warn = theme.colors.orange;
  };
 */
  foreground = {
    icon-l = theme.colors.dark-theme.foreground;
    icon-d = theme.colors.dark-theme.background0;
    text = theme.colors.blueGray;
    warn = theme.colors.orange;
  };

  pavucontrol = if soundSupport == true then "${pkgs.pavucontrol}/bin/pavucontrol" else "";
  terminal = "${pkgs.alacritty-wrapped} -e";

  power-menu = "${pkgs.x11apps}/bin/power-menu";
  app-launcher-menu = "${pkgs.x11apps}/bin/app-launcher-menu";
  show-windows-menu = "${pkgs.x11apps}/bin/show-windows-menu";
  audioctl = "${pkgs.x11apps}/bin/audioctl";

  microphone-listener = "${polybar-apps}/bin/polybar-microphone-listener";
  network-listener = "${polybar-apps}/bin/polybar-network-listener";
  network-menu = "${polybar-apps}/bin/polybar-network-menu";

  battery-name = battery.name;
  adapter-name = battery.adapter;

  top-right-module0 = "keyboard temperature cpu memory ";
  top-right-module1 = if battery.enable == true then top-right-module0 + "battery " else top-right-module0;
  top-right-module2 = if soundSupport == true then top-right-module1 + "volume microphone " else top-right-module1;
  top-right-modules = top-right-module2 + "network powermenu";

  monitor = "\${env:MONITOR:}";

in pkgs.writeText "polybar-config" ''
  [global/vm]
  margin-bottom = 0
  margin-top = 0

  [settings]
  throttle-output = 5
  throttle-output-for = 10
  screenchange-reload = false
  compositing-background = source
  compositing-foreground = over
  compositing-overline = over
  compositing-underline = over
  compositing-border = over
  pseudo-transparency = false

  [bar/top]
  bottom = false

  monitor = ${monitor}
  enable-ipc = true
;  fixed-center = true
  width = 100%
  height = 30
  offset-x = 0%
  offset-y = 0%
  background = ${theme.colors.dark-theme.background0}
  foreground = ${foreground.text}
  font-0 = "DejaVuSansMono:weight=regular:size=10;1"
  font-1 = "${theme.icons-font-name}:weight=regular:size=15;2"

;  override-redirect = true
  wm-restack = i3
  padding-right = 1
  padding-left = 1

  module-margin-right = 1

  border-bottom-size = 3
  border-bottom-color = ${theme.colors.dark-theme.background4}

  line-size = 0

  modules-left = launcher i3
  modules-center = notification datetime
  modules-right = ${top-right-modules}

  tray-position = right
  tray-detached = false
  tray-offset-x = 0
  tray-offset-y = 0
  tray-padding = 0
  tray-scale = 1.0
  tray-background = ${theme.colors.dark-theme.background4}

  [module/i3]
  type = internal/i3
  pin-workspaces = true
  enable-click = true
  enable-scroll = false
  strip-wsnumbers = true

  label-focused-padding-right = 1
  label-focused-foreground = ${foreground.icon-d}
  label-focused-background = ${theme.colors.green}

  label-unfocused-padding-right = 1
  label-unfocused-foreground = ${foreground.text}

  label-visible-padding-right = 1
  label-visible-foreground = ${foreground.icon-d}
  label-visible-background = ${theme.colors.lime}

  label-urgent-padding-right = 1
  label-urgent-background = ${theme.colors.orange}
  label-urgent-foreground = ${foreground.icon-d}

  [module/xtittle]
  type = internal/xwindow
  format = <label>
  label = %title%
  label-maxlen = 70

  [module/temperature]
  type = internal/temperature
  interval = 2
;  thermal-zone = 0
  hwmon-path = ${cpuTemperaturePath}
  units = true
  format = <ramp> <label>
  format-warn = <ramp> <label-warn>
  label = %temperature-c%
  label-warn = %temperature-c%
  label-warn-foreground = ${foreground.warn}
  ramp-0 = ${theme.icons.thermometer-0}
  ramp-1 = ${theme.icons.thermometer-1}
  ramp-2 = ${theme.icons.thermometer-2}
  ramp-3 = ${theme.icons.thermometer-3}
  ramp-foreground = ${foreground.icon-l}
  
  [module/cpu]
  type = internal/cpu
  interval = 2
  format = <label>
  format-prefix = ${theme.icons.cpu}
  format-prefix-foreground = ${foreground.icon-l}
  format-prefix-padding = 1
  label = %percentage:02:3%%
  click-left = ${terminal} htop
  
  [module/memory]
  type = internal/memory
  interval = 2
  format = <label>
  format-prefix = ${theme.icons.ram}
  format-prefix-foreground = ${foreground.icon-l}
  format-prefix-padding = 1
  label = %gb_used%
  click-left = ${terminal} htop
  
  [module/battery]
  type = internal/battery
  full-at = 94
  battery = ${battery-name}
  adapter = ${adapter-name}
  poll-interval = 2

  time-format = %H:%M

  format-full-foreground = ${foreground.icon-l}
  label-full = ${theme.icons.battery-4} 100%
  label-full-foreground = ${foreground.text}

  format-charging = <animation-charging> <label-charging>
  format-charging-foreground = ${foreground.icon-l}
  label-charging = %percentage%% %time%
  label-charging-foreground = ${foreground.text}

  format-discharging = <ramp-capacity> <label-discharging>
  format-discharging-foreground = ${foreground.icon-l}
  label-discharging = %percentage%% %time%
  label-discharging-foreground = ${foreground.text}

  animation-charging-0 = ${theme.icons.battery-0}
  animation-charging-1 = ${theme.icons.battery-1}
  animation-charging-2 = ${theme.icons.battery-2}
  animation-charging-3 = ${theme.icons.battery-3}
  animation-charging-4 = ${theme.icons.battery-4}

  animation-charging-framerate = 500
  
  ramp-capacity-0 = ${theme.icons.battery-0}
  ramp-capacity-1 = ${theme.icons.battery-1}
  ramp-capacity-2 = ${theme.icons.battery-2}
  ramp-capacity-3 = ${theme.icons.battery-3}
  ramp-capacity-4 = ${theme.icons.battery-4}

  ramp-capacity-0-foreground = ${foreground.warn}

  [module/volume]
  type = internal/pulseaudio
  use-ui-max = false
  interval = 5

  format-volume = <ramp-volume>
  format-volume-foreground = ${foreground.icon-l}

  label-muted = ${theme.icons.volume-0}
  label-muted-foreground = ${foreground.text}

  ramp-volume-0 = ${theme.icons.volume-1}
  ramp-volume-1 = ${theme.icons.volume-2}
  ramp-volume-2 = ${theme.icons.volume-3}

  click-right = ${pavucontrol}

  [module/microphone]
  type = custom/script
  exec = ${microphone-listener}
  click-left = ${audioctl} --source-mute-toggle
  click-right = ${pavucontrol}  click-right = ${show-windows-menu}

  tail = true

  [module/keyboard]
  type = internal/xkeyboard
  blacklist-0 = num lock
  blacklist-1 = scroll lock
  format = <label-layout>
  format-prefix = ${theme.icons.keyboard}
  format-prefix-foreground = ${foreground.icon-l}
  format-prefix-padding = 1
  label-layout = %layout%

  [module/network]
  type = custom/script
  exec = ${network-listener}
  format-padding = 1
  click-left = ${network-menu}
  tail = true

  [module/powermenu]
  type = custom/text
  content = ${theme.icons.power}
  content-foreground = ${theme.colors.red}
  click-left = ${power-menu}

  [module/datetime]
  type = internal/date
  interval = 1.0

  format = <label>
  label = %date% %time%

  format-prefix = ${theme.icons.calendar}
  format-prefix-foreground = ${foreground.icon-l}
  format-prefix-padding = 1

  date = %d.%m.%Y
  date-alt = %A, %d %B

  time = %H:%M
  time-alt = %H:%M:%S
  
  [module/launcher]
  type = custom/text
  content = ${theme.icons.nixos}
  padding-left = 1
  content-foreground = ${theme.colors.amber}
  format-background = ${theme.colors.dark-theme.background4}
  click-left = ${app-launcher-menu}
  click-right = ${show-windows-menu}

  [module/notification]
  type = custom/text
  content = ${theme.icons.bell}
  content-foreground = ${foreground.icon-l}
  click-left = ${app-launcher-menu}

''