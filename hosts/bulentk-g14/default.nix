{ pkgs, config, ... }:

{
  imports = [
    ./nvidia.nix
  ];

  sys.hw = {
    cpu.cores = 16;
#    cpu.sensorTemperaturePath = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
    cpu.sensorTemperaturePath = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon5/temp1_input";

    memorySize = 16;
    sound = true;
    wifi = true;
    bluetooth = true;
    battery = {
      enable = true;
      name = "BAT0";
      adapter = "AC0";
    };
    
    keychron = true;
#    nics = [ "enp4s0f4u2u2" ];
    nics = [ ];
  };

  sys.disk = {
    layout = "btrfs-crypt";
    swapFileSize = 16384;
  };

  # zramSwap = {
  #   enable = true;
  #   algorithm = "zstd";
  #   memoryPercent = 50;
  #   priority = 5;
  # };

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

  networking.hostName = "bulentk-g14";

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  hardware.cpu.amd.updateMicrocode = true;
  # https://linrunner.de/tlp/
  # TODO bu halde bluetooth wifi de kullanilmayinca kapaniyor kapanmamasi icin ayri ayri yapmak gerekiyor olabilir
  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = "0";
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 60;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
 
  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
  };

  services.fstrim.enable = true;

  services.udev.extraHwdb = ''
    evdev:input:b*v0B05p19B6e*-*
      KEYBOARD_KEY_ff31007c=f20 #micmute
  '';

  systemd.user.services = {
    asus-insert-key = {
      wantedBy = [ "graphical-session.target" ];
      
      unitConfig = {
        PartOf = [ "graphical-session.target" ];
        Before = [ "sxhkd.service" ];
      };

      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.xorg.xmodmap}/bin/xmodmap -e "keycode 119 = Delete Insert Delete"
      '';
    };
  };

  #virtualisation.docker.enableNvidia = true;
  hardware.nvidia-container-toolkit.enable = true;

  services = {
    supergfxd.enable = true;
    asusd = {
      enable = true;
      enableUserService = true;
    };    
  };

  systemd.services.supergfxd.path = [ pkgs.pciutils ];

  environment.systemPackages = with pkgs; [
      globalprotect-openconnect
  ];


}
