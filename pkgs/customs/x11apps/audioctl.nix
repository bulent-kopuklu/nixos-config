{ pkgs, ... }:

let
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  awk = "${pkgs.gawk}/bin/awk";

in
pkgs.writeShellScriptBin "audioctl" ''

  function default_source() {
    ${wpctl} status | ${awk} '/Default Source:/ {print $3}'
  }

  function default_sink() {
    ${wpctl} status | ${awk} '/Default Sink:/ {print $3}'
  }

  case "$1" in
    --source-mute-toggle)
      ${wpctl} set-mute $(default_source) toggle
      ;;
    --source-volume-up)
      # +0.05 = %5 artış
      current_vol=$( ${wpctl} get-volume $(default_source) )
      # wpctl get-volume output örn: "0.500000"
      new_vol=$(awk "BEGIN {printf \"%.6f\", $current_vol + 0.05}")
      ${wpctl} set-volume $(default_source) $new_vol
      ;;
    --source-volume-down)
      current_vol=$( ${wpctl} get-volume $(default_source) )
      new_vol=$(awk "BEGIN {printf \"%.6f\", $current_vol - 0.05}")
      ${wpctl} set-volume $(default_source) $new_vol
      ;;

    --sink-mute-toggle)
      ${wpctl} set-mute $(default_sink) toggle
      ;;
    --sink-volume-up)
      current_vol=$( ${wpctl} get-volume $(default_sink) )
      new_vol=$(awk "BEGIN {printf \"%.6f\", $current_vol + 0.05}")
      ${wpctl} set-volume $(default_sink) $new_vol
      ;;
    --sink-volume-down)
      current_vol=$( ${wpctl} get-volume $(default_sink) )
      new_vol=$(awk "BEGIN {printf \"%.6f\", $current_vol - 0.05}")
      ${wpctl} set-volume $(default_sink) $new_vol
      ;;
  esac
''
