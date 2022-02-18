{ pkgs, theme, ... }:

pkgs.writeTextDir "share/app-launcher-menu.rasi" ''
  configuration {
    font:                    "Comfortaa 10";
    show-icons:              true;
    icon-theme:              "Adwaita";
    disable-history:         false;
    sidebar-mode:            false;

    display-drun:             "${theme.icons.nixos}";
  }

  * {
    title:                    ${theme.colors.menu.title};
    accent:                   ${theme.colors.menu.accent0};
    background:               ${theme.colors.menu.background};
    foreground:               ${theme.colors.menu.foreground};
    orange:                   ${theme.colors.orange};
    blueGray:                 ${theme.colors.blueGray};
    blue:                     ${theme.colors.blue};
  }

  window {
    transparency:             "real";
    border-radius:            5px;
    location:                 center;
    width:                    800px;
    background-color:         @background;
  }

  mainbox {
    background-color:         inherit;
    children:                 [ inputbar, listview ];
    spacing:                  12px;
    margin:                   12px;
  }

  inputbar {
    children:                 [ prompt, textbox-prompt-colon, entry ];
    spacing:                  0px;
    text-color:               @foreground;
    expand:                   false;
    background-color:         @orange;
    border:                   2px 2px 2px 2px;
    border-radius:            5px;
    border-color:             @title;
    margin:                   0px 0px 0px 0px;
    padding:                  0px;
    position:                 center;
  }

  prompt {
    enabled:                  true;
    font:                     "mplus Nerd Font Mono 18";
    padding: 						      0.25% 0.25% 0.25% 0.25%;
    background-color:         @title;
    text-color:               @blue;
    border-radius:            0px;
    border-color:             @accent;
  }

  textbox-prompt-colon {
    expand:                   false;
    background-color:         @title;
    text-color:               @background;
    padding: 						      0.60% 0.50% 0.25% 0%;
    str:                      "Applications";
    font:                     "Comfortaa 16";
  }

  entry {
    background-color:         @orange;
    text-color:               @foreground;
    placeholder-color:        @blueGray;
    expand:                   true;
    horizontal-align:         0;
    placeholder:              "Search";
    padding: 						      0.60% 0.5% 0.25% 0.5%;

    blink:                    true;
    font:                     "Comfortaa 16";
  }


  listview {
    background-color:         inherit;
    padding:                  0px;
    columns:                  4;
    lines:                    4;
    spacing:                  1%;
    spacing:                  0px;
    cycle:                    true;
    dynamic:                  true;
    layout:                   vertical;
    fixed-columns:            true;
  }

  element {
    background-color:         @background;
    text-color:               @foreground;
    orientation:              vertical;
    border-radius:            0%;
    padding:                  0%;
  }

  element-icon {
    size:                     64px;
    background-color:         @background;
    padding: 						      0% 0% 0% 2%;
  }

  element-text {
    expand:                   true;
    horizontal-align:         0.5;
    vertical-align:           0.5;
    margin:                   0.5% 0.25% 0.5% 0.25%;
    padding:                  1% 0.5% 1% 0.5%;
    background-color:         @background;
  }

  element-text selected {
    expand:                   false;
    horizontal-align:         0.5;
    vertical-align:           0.5;
    background-color:         @accent;
    text-color:               @background;
  }

''