{ pkgs, ... }:

let
  theme = import ./theme.nix;
in pkgs.writeText "alacritty-config.toml" ''
  [colors.normal]
  black = "${theme.colors.black}"
  blue = "${theme.colors.blue}"
  cyan = "${theme.colors.cyan}"
  green = "${theme.colors.green}"
  magenta = "${theme.colors.magenta}"
  red = "#cc6666"
  white = "#c5c8c6"
  yellow = "${theme.colors.yellow}"

  [colors.primary]
  background = "${theme.colors.dark-theme.background1}"
  foreground = "${theme.colors.dark-theme.foreground}"

  [font]
  size = 10.0

  [scrolling]
  history = 5000

  [window]
  title = "Alacritty"

  [window.class]
  general = "Alacritty"
  instance = "Alacritty"

  [window.padding]
  x = 5
  y = 5
''