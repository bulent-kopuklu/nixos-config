{
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables = {
    EDITOR = "nvim"; # TODO
    LC_ALL = "en_US.UTF-8";
    TERM = "xterm-256color"; # TODO

    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME= "$HOME/.local/state";

    # TODO
    PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
  };
  
  time.timeZone = "Europe/Istanbul";

  security.sudo.wheelNeedsPassword = false;
}