{ pkgs, theme, ... }:

let
  ip = "${pkgs.iproute2}/bin/ip";
  awk = "${pkgs.gawk}/bin/awk";
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  grep = "${pkgs.gnugrep}/bin/grep";
  echo = "${pkgs.coreutils}/bin/echo";
in

pkgs.writeShellScriptBin "polybar-network-listener" ''

  state=-1

  function status() {
    if [ "enabled" == $(${nmcli} networking) ]; then
      local default=$(${ip} route 2>/dev/null | ${awk} '/default/ {print $5}')
      if [ -n "$default" ]; then
        if [ $state != 1 ]; then
          ${echo} "%{F${theme.colors.dark-theme.foreground}}${theme.icons.network-up}%{F-}"
          state=1
        fi
      else
        if [ $state != 0 ]; then
          ${echo} "%{F${theme.colors.blueGray}}${theme.icons.network-down}%{F-}"
          state=0
        fi        
      fi
    else
      if [ $state != 2 ]; then
        ${echo} "%{F${theme.colors.blueGray}}${theme.icons.airplane}%{F-}"
        state=2
      fi
    fi
  }

  function listen() {
    ${nmcli} monitor | while read -r event; do
      if ${echo} $event  | ${grep} -q "Networkmanager is now in the"; then
        status
      fi
    done
  }

  status
  listen

''