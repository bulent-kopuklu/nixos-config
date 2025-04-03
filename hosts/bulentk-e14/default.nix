{ pkgs, config, ... }:

{
  sys.hw = {
    cpu.cores = 22;
    cpu.sensorTemperaturePath = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
#    cpu.sensorTemperaturePath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon5/temp1_input";

    memorySize = 64;
    sound = true;
    wifi = true;
    bluetooth = true;
    battery = {
      enable = true;
      name = "BAT0";
      adapter = "AC0";
    };
    
    keychron = true;
    nics = [ ];
  };

  sys.disk = {
    layout = "btrfs-crypt";
    swapFileSize = 32768;
  };

  env.terminal = {
    command = "alacritty";
    package = pkgs.alacritty-wrapped;
  };

  env.xsession = {
    enable = true;
    i3wm.enable = true;
  };

  env.role = {
    workstation = true;
    development = true;
    virtualisation = true;
  };


  env.user = {
    name = "bulentk";
    extraGroups = [ 
      "wheel" 
      "video"
      "audio"
      "vboxusers"
      "vboxsf"       
      "lp" # for bluetooth
      "bluetooth"
    ];
  };

  env.programs.autorandr.profiles = {
     "encom" = {
      config = ./autorandr/encom/config.nix;
      setup = ./autorandr/encom/setup.nix;
    };
    "home" = {
      config = ./autorandr/home/config.nix;
      setup = ./autorandr/home/setup.nix;
    };
  };

  networking.hostName = "bulentk-e14";

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "thunderbolt" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  hardware.graphics = {
    extraPackages = with pkgs; [
      vpl-gpu-rt
#      libvdpau-va-gl
#      intel-media-driver
#      intel-compute-runtime
    ];
#    extraPackages32 = with pkgs.pkgsi686Linux; [ intel-vaapi-driver ];
  };

  # https://linrunner.de/tlp/
  # TODO bu halde bluetooth wifi de kullanilmayinca kapaniyor kapanmamasi icin ayri ayri yapmak gerekiyor olabilir
  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = "0";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # services.throttled.enable = lib.mkDefault true;
  # boot.kernelParams = [
  #   # Force use of the thinkpad_acpi driver for backlight control.
  #   # This allows the backlight save/load systemd service to work.
  #   "acpi_backlight=native"
  # ];

  environment.systemPackages = with pkgs; [
      globalprotect-openconnect
  ];
}
