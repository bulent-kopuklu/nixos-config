{ pkgs, theme, ... }:

pkgs.writeTextDir "share/power-menu.rasi" ''
  configuration {
    font:                           "Comfortaa 12";
    disable-history:                false;
    sidebar-mode:                   false;
  }

  * {
    title:                ${theme.colors.menu.title};
    accent:               ${theme.colors.menu.accent0};
    background:           ${theme.colors.menu.background};
    foreground:           ${theme.colors.menu.foreground};
  }

  * {
    background-color:     @background;
    text-color:           @foreground;
  }

  window {
    transparency:         "real";
    border-radius:        5px;
    location:             center;
    width:                420px;
  }

  mainbox {
    background-color:     @background;
    children:             [ inputbar, listview ];
    spacing:              12px;
    margin:               12px;
  }

  inputbar {
    children:             [ textbox-prompt-colon, prompt ];
    spacing:              0px;
    background-color:     ${theme.colors.orange};
    text-color:           @foreground;
    expand:               false;
    border:               2px 2px 2px 2px;
    border-radius:        5px;
    border-color:         @accent;
    margin:               0px 0px 0px 0px;
    padding:              0px;
    position:             center;
  }

  prompt {
    enabled:              true;
    padding:              10px;
    background-color:     ${theme.colors.orange};
    text-color:           ${theme.colors.black};
    border-radius:        0px;
    border-color:         @title;
  }

  textbox-prompt-colon {
    expand:               false;
    str:                  " System";
    background-color:     @title;
    text-color:           @background;
    padding:              12px 10px 0px 10px;
  }

  listview {
    columns:              5;
    lines:                1;
    spacing:              0px;
    cycle:                true;
    dynamic:              true;
    layout:               vertical;
  }

  element {
    orientation:          vertical;
    border-radius:        0px;
  }

  element-text {
    font:                 "${theme.icons-font-name} 32";
    expand:               true;
    horizontal-align:     0.5;
    vertical-align:       0.5;
    margin:               -2px 0px 10px 0px;
    highlight:            inherit;
  }

  element selected {
    background-color:     @accent;
  }
''
