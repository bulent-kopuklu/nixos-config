{ config, pkgs, lib, ... }:

let
  nvidia_x11 = config.boot.kernelPackages.nvidiaPackages.stable;

  amdgpuBusId = "PCI:4:0:0";
  nvidiaBusId = "PCI:1:0:0";
  sinkGpuProviderName = "Unknown AMD Radeon GPU @ pci:0000:04:00.0";
  
in {
  
  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];

  hardware.nvidia.modesetting.enable = true;

  hardware.nvidia.prime = {
    offload.enable = false;
    sync.enable = true;
    amdgpuBusId = amdgpuBusId;
    nvidiaBusId = nvidiaBusId;
  };

  hardware.nvidia.powerManagement.enable = true;

  services.xserver.drivers = lib.mkForce [
    {
      name = "amdgpu";
      display = false;
      modules = [ pkgs.xorg.xf86videoamdgpu ];
      deviceSection = ''
        BusID "${amdgpuBusId}"
      '';
    }
    {
      name = "nvidia";
      modules = [ nvidia_x11.bin ];
      display = true;
      deviceSection = ''
        BusID "${nvidiaBusId}"
        Option "AllowExternalGpus" "true"
      '';
      screenSection = ''
        Option "RandRRotation" "on"
        Option "AllowEmptyInitialConfiguration" "true"
        Option "metamodes" "2560x1440 +1920+0 { ForceCompositionPipeline = On }, 2560x1440 +4480+0 { ForceCompositionPipeline = On }"
      '';
    }
  ];


  services.xserver.displayManager.setupCommands = lib.mkForce ''
    ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource "${sinkGpuProviderName}" NVIDIA-0
    ${pkgs.xorg.xrandr}/bin/xrandr --auto
  '';

  environment.systemPackages = with pkgs; [
    nvtop
  ];


/*   #https://github.com/NixOS/nixpkgs/pull/153091
  specialisation = {
    Internal-GPU-Only.configuration = {
      system.nixos.tags = [ "Internal-GPU-Only" ];
      hardware.nvidia.prime = {
        offload.enable = lib.mkForce true;
        sync.enable = lib.mkForce false;
        amdgpuBusId = amdgpuBusId;
        nvidiaBusId = nvidiaBusId;
      };

      hardware.nvidia.powerManagement.enable = lib.mkForce true;
    };
  };
 */ 
  hardware.opengl.package = lib.mkForce pkgs.mesa.drivers;
  hardware.opengl.package32 = lib.mkForce pkgs.pkgsi686Linux.mesa.drivers;

  hardware.opengl.extraPlibvulkan
  ackages = lib.mkForce [ nvidia_x11.out ];
  hardware.opengl.extraPackages32 = lib.mkForce [ nvidia_x11.lib32 ];
}