{ pkgs, theme, ... }:

pkgs.writeTextDir "share/polybar-network-menu.rasi" ''
  configuration {
    font:                           "Comfortaa 12";
    disable-history:                false;
    sidebar-mode:                   false;
  }

  * {
    accent:                   ${theme.colors.menu.accent0};
    background:               ${theme.colors.menu.background};
    foreground:               ${theme.colors.menu.foreground};

    on:                       ${theme.colors.green};
    off:                      ${theme.colors.red};
  }


  * {
    background-color:               @background;
    text-color:                     @foreground;
  }

  window {
    transparency:                   "real";
    border-radius:                  5px;
    location:                       center;
    width:                          480px;
  }

  mainbox {
    background-color:               @background;
    children:                       [ inputbar, message, listview ];
    spacing:                        12px;
    margin:                         12px;
  }

  message {
    children:                       [ textbox ];
    border-color:                   @accent;
    border:                         2px 2px 2px 2px;
    border-radius:                  5px;
  }

  textbox {
    color:                          ${theme.colors.black};
    padding:                        5px;
  }

  inputbar {
    children:                       [ textbox-prompt-colon, prompt ];
    spacing:                        0px;
    background-color:               ${theme.colors.orange};
    text-color:                     ${theme.colors.blueGray};
    expand:                         false;
    border:                         2px 2px 2px 2px;
    border-radius:                  5px;
    border-color:                   @accent;
    margin:                         0px 0px 0px 0px;
    padding:                        0px;
    position:                       center;
  }

  prompt {
    enabled:                        true;
    padding:                        10px;
    background-color:               ${theme.colors.orange};
    text-color:                     ${theme.colors.black};
    border-radius:                  0px;
    border-color:                   @accent;
  }

  textbox-prompt-colon {
    expand:                         false;
    str:                            " Network ";
    background-color:               @accent;
    text-color:                     @background;
    padding:                        12px 10px 0px 10px;
  }

  listview {
    columns:                        6;
    lines:                          1;
    spacing:                        4px;
    cycle:                          true;
    dynamic:                        true;
    layout:                         vertical;
  }

  element {
    orientation:                    vertical;
    border-radius:                  0px;
  }

  element-text {
    font:                           "${theme.icons-font-name} 32";
    expand:                         true;
    horizontal-align:               0.5;
    vertical-align:                 0.5;
    margin:                         -2px 0px 10px 0px;
  }

  element selected {
    background-color:               @accent;
  }

  element normal.urgent,
  element alternate.urgent {
      background-color:             @off;
      text-color:                   @background;
      border-radius:                0px;
  }

  element normal.active,
  element alternate.active {
      background-color:             @on;
      text-color:                   @background;
  }

  element selected.urgent {
      background-color:             @on;
      text-color:                   @background;
  }

  element selected.active {
      background-color:             @off;
      color:                        @background;
  }


''
