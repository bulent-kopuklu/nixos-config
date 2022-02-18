{ pkgs, ... }:

let
  theme = import ./theme.nix;
in pkgs.writeText "alacritty-config.yml" ''
  window:
    padding:
      x: 5
      y: 5
    title: Alacritty
    class:
      instance: Alacritty
      general: Alacritty
  
  scrolling:
    history: 5000

  font:
    size: 10.0


  colors:
    # Default colors
    primary:
      background: '${theme.colors.dark-theme.background1}'
      foreground: '${theme.colors.dark-theme.foreground}'

    normal:
      black:   '${theme.colors.black}'
      red:     '#cc6666'
#      red:     '${theme.colors.orange}'
      green:   '${theme.colors.green}'
      blue:    '${theme.colors.blue}'
      yellow:  '${theme.colors.lime}'
      magenta: '${theme.colors.magenta}'
      cyan:    '${theme.colors.cyan}'
  #    white:   '#c5c8c6'
      white:   '${theme.colors.white}'
''