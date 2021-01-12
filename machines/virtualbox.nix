
{ ... }:

{
    boot.loader.grub = {
        enable = true;
        version = 2;
        device = "/dev/sda1";
    };

    users.extraGroups.vboxusers.members = [
        "bulentk" 
    ];
    
    virtualisation.virtualbox.guest.enable = true;
}