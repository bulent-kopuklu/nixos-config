{ pkgs, config, lib, ... }:

{
  sys.hw = {
    cpu.cores = 22;
    cpu.sensorTemperaturePath = "/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon8/temp1_input";
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

  sys.disk.enable = false;
  boot.initrd.systemd.enable = true; 
  boot.initrd.luks.devices = {
    "system" = {
      device = "/dev/disk/by-partlabel/cryptsys";
      allowDiscards = true;
    };
    "hammal" = {
      device = "/dev/disk/by-partlabel/crypthml";
      allowDiscards = true;
      keyFile = "/etc/secrets/hammal.key";
    };
  };

  # hammal keyfile'ını initrd'ye dahil et
  boot.initrd.secrets = {
    "/etc/secrets/hammal.key" = "/etc/secrets/hammal.key";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/system";
    fsType = "btrfs";
    options = [ "subvol=@" "autodefrag" "noatime" "nodiratime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/system";
    fsType = "btrfs";
    options = [ "subvol=@nix" "autodefrag" "noatime" "nodiratime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = { 
    device = "/dev/disk/by-label/hammal";
    fsType = "btrfs";
    options = [ "subvol=@home" "autodefrag" "noatime" "nodiratime" "compress=zstd:1" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/var" = { 
    device = "/dev/disk/by-label/hammal";
    fsType = "btrfs";
    options = [ "subvol=@var" "autodefrag" "noatime" "nodiratime" "compress=zstd:1" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home/bulentk/workspace" = {
    device = "/dev/disk/by-label/system";
    fsType = "btrfs";
    options = [ "subvol=@workspace" "autodefrag" "noatime" "nodiratime" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/boot" = { 
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/.swapfile";
    size = 32 * 1024; # 32 GB
  }];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.enable = false;
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

  #boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  boot.initrd.availableKernelModules = [ 
    "nvme" 
    "xhci_pci" 
    "usb_storage" 
    "usbhid" 
    "sd_mod"
    "thunderbolt" 
  ];

  boot.kernelModules = [ "xe" "kvm_intel" ];
  
  boot.blacklistedKernelModules = [ 
    "i915" 
  ];

  boot.kernelParams = [
    "xe.force_probe=7d55"
    "i915.force_probe=!7d55"
    "transparent_hugepage=always"
    "nvme_core.default_ps_max_latency_us=0"
    "elevator=none"
  ];

  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics.enable = true;
  hardware.intelgpu.driver = "xe";
  services.xserver.videoDrivers = [ "xe" ];


  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";  # veya "powersave"
  };

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

  environment.systemPackages = with pkgs; [
    linuxPackages.cpupower
    gpclient
    ollama-vulkan
    nvme-cli
    dmidecode
    openconnect
  ];


}
