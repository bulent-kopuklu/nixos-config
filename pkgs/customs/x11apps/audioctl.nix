{ pkgs, ... }:

let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  awk = "${pkgs.gawk}/bin/awk";

in
pkgs.writeShellScriptBin "audioctl" ''

  function default_source() {
    ${pactl} info  | ${awk} '/Default Source:/ {print $3}'
  }

  function default_sink() {
    ${pactl} info  | ${awk} '/Default Sink:/ {print $3}'
  }

  case "$1" in
    --source-mute-toggle)
      ${pactl} set-source-mute $(default_source) toggle
      ;;
    --source-volume-up)
      ${pactl} set-source-volume $(default_source) +5%
      ;;
    --source-volume-down)
      ${pactl} set-source-volume $(default_source) -5%
      ;;

    --sink-mute-toggle)
      ${pactl} set-sink-mute $(default_sink) toggle
      ;;
    --sink-volume-up)
      ${pactl} set-sink-volume $(default_sink) +5%
      ;;
    --sink-volume-down)
      ${pactl} set-sink-volume $(default_sink) -5%
      ;;
  esac

''
