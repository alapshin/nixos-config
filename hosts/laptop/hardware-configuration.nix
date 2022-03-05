{ config, lib, pkgs, ... }:

{
  boot = {
    # Use the GRUB 2 boot loader.
    loader.grub = {
      enable = true;
      version = 2;
      # Define on which hard drive you want to install Grub.
      device = "/dev/sda"; # or "nodev" for efi only
    };
  };

  fileSystems."/" = { 
    device = "/dev/disk/by-uuid/dbbc5826-8290-4c77-9ce9-31193f9f0579";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/home" = { 
    device = "/dev/disk/by-uuid/dbbc5826-8290-4c77-9ce9-31193f9f0579";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  swapDevices = [ 
    { device = "/dev/disk/by-uuid/f4295eea-039e-48f8-9bd9-88fb927990d0"; }
  ];
}
