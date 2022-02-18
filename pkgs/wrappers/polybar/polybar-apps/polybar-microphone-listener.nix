{ pkgs, theme, ... }:

let 
  awk = "${pkgs.gawk}/bin/awk";
  pacmd = "${pkgs.pulseaudio}/bin/pacmd";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  echo = "${pkgs.coreutils}/bin/echo";
  grep = "${pkgs.gnugrep}/bin/grep";
#  pidof = "${pkgs.procps}/bin/pidof";
#  kill = "${pkgs.util-linux}/bin/kill";

in

pkgs.writeShellScriptBin "polybar-microphone-listener" ''

  status() {
    MUTED=$(${pacmd} list-sources | ${awk} '/\*/,EOF {print}' | ${awk} '/muted/ {print $2; exit}')

    if [ "$MUTED" = "yes" ]; then
      ${echo} "%{F${theme.colors.blueGray}}${theme.icons.microphone-slash}%{F-}"
    else
      ${echo} "%{F${theme.colors.dark-theme.foreground}}${theme.icons.microphone}%{F-}"
    fi
  }

  status

  LANG=EN; ${pactl} subscribe | while read -r event; do
    if ${echo} "$event" | ${grep} -q "source" || ${echo} "$event" | ${grep} -q "server"; then
      status
    fi
  done
''