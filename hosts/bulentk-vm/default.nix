{ config, lib, pkgs, modulesPath, ... }:

{
  sys.hw = {
    cpu.cores = 2;
#    cpu.sensorTemperaturePath = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
    cpu.sensorTemperaturePath = "";

    memorySize = 4;
    sound = false;
    wifi = false;
    bluetooth = false;
    battery.enable = false;
    keychron = false;
    nics = [ "enp0s3" ];
  };

  sys.disk = {
    layout = "vm";
    swapFileSize = 4;
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
    extraGroups = [ "wheel" "vboxsf" ];
  };

  powerManagement.enable = false;
  virtualisation.virtualbox.guest.enable = true;
  virtualisation.virtualbox.guest.x11 = true;    

  #TODO ????
  
  services.xserver.videoDrivers = lib.mkOverride 40 [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];

  boot.initrd.availableKernelModules = [ "ata_piix" "ohci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "bulentk-vm";


  services.openssh.enable = true;
}