{ pkgs, theme, ... }:

let 
  pamixer = "${pkgs.pamixer}/bin/pamixer";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  echo = "${pkgs.coreutils}/bin/echo";
  grep = "${pkgs.gnugrep}/bin/grep";
in

pkgs.writeShellScriptBin "polybar-microphone-listener" ''

  status() {
    MUTED=$(${pamixer} --default-source --get-mute)
    
    if [ "$MUTED" = "true" ]; then
      ${echo} "%{F${theme.colors.blueGray}}${theme.icons.microphone-slash}%{F-}"
    else
      ${echo} "%{F${theme.colors.dark-theme.foreground}}${theme.icons.microphone}%{F-}"
    fi
  }

  status

  LANG=EN; ${pactl} subscribe | while read -r event; do
    if ${echo} "$event" | ${grep} -q "on source"; then
      status
    fi
  done
''
