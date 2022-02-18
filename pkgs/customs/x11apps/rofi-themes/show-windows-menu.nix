{ pkgs, theme, ... }:

pkgs.writeTextDir "share/show-windows-menu.rasi" ''
  configuration {
    font:                    "Comfortaa 10";
    show-icons:              true;
    icon-theme:              "Papirus-Dark";
    disable-history:         false;
    sidebar-mode:            false;
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
    children:                 [ textbox-prompt-colon, entry ];
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

  textbox-prompt-colon {
    expand:                   false;
    background-color:         @title;
    text-color:               @background;
    padding: 						      0.60% 0.50% 0.25% 0.25%;
    str:                      "Windows";
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
    columns:                  1;
    lines:                    5;
    spacing:                  1%;
    spacing:                  0px;
    cycle:                    true;
    dynamic:                  true;
    fixed-columns:            true;
  }

  element {
    background-color:         @background;
    text-color:               @foreground;
    border-radius:            0%;
    padding:                  0%;
  }

  element-icon {
    size:                     48px;
    background-color:         @background;
  }

  element-text {
    expand:                   true;
    margin:                   0.5% 0.25% 0.5% 0.25%;
    padding:                  0.5% 0.5% 0.5% 0.5%;
    background-color:         @background;
    font:                     "Comfortaa 12";
  }

  element-text selected {
    expand:                   false;
    background-color:         @accent;
    text-color:               @background;
    font:                     "Comfortaa 12";
  }

''