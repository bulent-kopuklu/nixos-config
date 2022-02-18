{ pkgs, theme, lock-screen, ... }:

let
  rofi-theme = import ./rofi-themes/power-menu.nix { inherit pkgs theme; };

  app = let

    echo = "${pkgs.coreutils}/bin/echo";
    rofi = "${pkgs.rofi}/bin/rofi -dmenu -theme ${rofi-theme}/share/power-menu.rasi";
    sed = "${pkgs.gnused}/bin/sed";
    awk = "${pkgs.gawk}/bin/awk";
    uptime = "${pkgs.coreutils}/bin/uptime";
    systemctl = "${pkgs.systemd}/bin/systemctl";
    i3-msg = "${pkgs.i3-gaps}/bin/i3-msg";

    icons = {
      poweroff = theme.icons.power;
      reboot = theme.icons.refresh;
      lock = theme.icons.lock;
      suspend = theme.icons.moon;
      signout = theme.icons.signout;
    };

    options="${icons.poweroff}\\n${icons.reboot}\\n${icons.lock}\\n${icons.suspend}\\n${icons.signout}";
  in
    pkgs.writeShellScriptBin "power-menu" ''
      uptime=$(${uptime} | ${sed} -e 's/\up  //g' | ${awk} -F',' '{print $1 $2}')
      chosen=$(${echo} -e "${options}" | ${rofi} -p "UP - $uptime" -selected-row 2)
      case $chosen in
        ${icons.poweroff})
          ${systemctl} poweroff
          ;;
        ${icons.reboot})
          ${systemctl} reboot
          ;;
        ${icons.lock})
          ${lock-screen}/bin/lock-secreen
        ;;
        ${icons.suspend})
          ${systemctl} suspend
        ;;
        ${icons.signout})
          ${i3-msg} exit
        ;;
      esac
    '';
in 

pkgs.symlinkJoin {
  name = "power-menu";
  version = "1";
  paths = [ rofi-theme app ];
}
