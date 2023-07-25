{ config
, lib
, pkgs
, ...
}:
let 
  disk = "/dev/sda";
in
{
  boot = {
    loader = {
      grub = {
        devices = [ disk ];
      };
    };

    initrd = {
      availableKernelModules = [ "ahci" "nvme" "usbhid" "usb_storage" "xhci_pci" ];
    };
  };

  disko.devices = import ./disk-config.nix {
    disks = [ disk ];
  };
}
