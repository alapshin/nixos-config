{ lib
, pkgs
, config
, modulesPath
, ...
}:
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        devices = lib.mkForce [ ]; # disko adds /boot here, we want /boot1 /boot2
        mirroredBoots = [
          { path = "/boot1"; devices = [ "nodev" ]; }
          { path = "/boot2"; devices = [ "nodev" ]; }
        ];
      };
    };

    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            /etc/ssh/ssh_initrd_ed25519_key
          ];
        };
      };
      systemd = {
        enable = true;
        network = {
          enable = true;
        };
      };
      availableKernelModules = [
        "ahci"
        "igb"
        "e1000e"
        "nvme"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
    };
  };
}
