{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  zramSwap.enable = true;

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = lib.mkForce [ ]; # disko adds /boot here, we want /boot1 /boot2
        mirroredBoots = [
          {
            path = "/boot1";
            devices = [ "nodev" ];
          }
          {
            path = "/boot2";
            devices = [ "nodev" ];
          }
        ];
      };
    };

    initrd.availableKernelModules = [
      "ahci"
      "igb"
      "e1000e"
      "nvme"
      "usbhid"
      "usb_storage"
      "xhci_pci"
    ];
  };

  hardware = {
    graphics.enable = true;
    amdgpu.opencl.enable = true;
  };
}
