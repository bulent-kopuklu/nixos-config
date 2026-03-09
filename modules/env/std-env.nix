{
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables = {
    LC_ALL = "en_US.UTF-8";
    TERM = "xterm-256color";
  };
  
  time.timeZone = "Europe/Istanbul";

  security.sudo.wheelNeedsPassword = false;
}