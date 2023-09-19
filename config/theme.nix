rec {

  colors = {
    white       = "#FFFFFF";
    black       = "#000000";
    red         = "#FB0009";
    pink        = "#EC407A";
    purple      = "#BA68C8";
    blue        = "#42A5F5";
    cyan        = "#4DD0E1";
    teal        = "#00B19F";
    green       = "#61C766";
    lime        = "#B9C244";
    yellow      = "#B58900";
    amber       = "#FBC02D";
    orange      = "#E57C46";
    brown       = "#AC8476";
    indigo      = "#6C77BB";
    gray        = "#9E9E9E";
    magenta     = "#b294bb";
    blueGray    = "#6D8895";

    dark-theme = {
      background0 = "#00212B";
      background1 = "#002B36";
      background2 = "#073642";
      background3 = "#004052";
      background4 = "#264B54";

      foreground = "#EBDBB2";
      border = "#668790";
    };

    menu = {
      background  = "#EBDBB2";
      foreground  = "#00212B";
      accent1     = "#859900";
      accent0     = "#106466";
      title       = "#106466";
    };
  };

  icons-font-name = "M+1 Nerd Font";
# Iosevka Nerd Font Mono
  icons = {
    plant         = "";
    envira        = "";
    leaf          = "";

    bell          = "󰂜"; ##
    bell-ring     = "󰂟";
    bell-slash    = "󰪑";

    thermometer-0 = "";
    thermometer-1 = "";
    thermometer-2 = "";
    thermometer-3 = "";

#    thermometer-0 = "";
#    thermometer-1 = "";
#    thermometer-2 = "";

    volume-0      = "󰝟";
    volume-1      = "";
    volume-2      = "";
    volume-3      = "";

    headphone     = "󰋋";
    bt-audio      = "󰂱";

    battery-0     = "";
    battery-1     = "";
    battery-2     = "";
    battery-3     = "";
    battery-4     = "";


    # microphone = "";
    # microphone-slash = "";

    microphone = "󰍬";
    microphone-slash = "";

    cpu = "󰍛";
    hdd = "󰨆";
    ram = "󱒉";

#    keyboard = "";
     keyboard = "";
    search = "";

    envelope = "";
    comment = "";
    music = "";

    network-up = "󰀂";
    network-down = "󰯡";

    network-download = "󰱦";
    network-upload = "󰳘";
    network-offline = "󰱟";

    ethernet = "󰈀";
    wifi = "";
    cog = "";
    eye = "";
    airplane = "󰳇";

    calendar = "";
    rocket = "";

    apps = "󰀻";
    nixos = "";

    moon = "";
    power = "";
    refresh = "";
    signout = "";
    lock = "";
  };
}