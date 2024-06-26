{ config
, lib
, pkgs
, ...
}:
let
  # Mount options for external storage drives that could be missing during boot
  externalMountOptions = [
    "noatime"
    "nofail"
    "x-systemd.device-timeout=5"
  ];
in
{
  boot = {
    loader = {
      timeout = 15;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        configurationLimit = 10;
      };
    };
    initrd = {
      systemd = {
        enable = true;
      };
      network = {
        enable = true;
        ssh = {
          enable = true;
          hostKeys = [
            "/etc/secrets/initrd/host_ed25519"
          ];
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGlJo3xdypmwSS2lsHCzf6GsqyEGvr+HzvbU+TGuPjmA"
          ];
        };
      };
      kernelModules = [ "amdgpu" ];
      availableKernelModules = [
        "ahci"
        "nvme"
        "r8169"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
      luks.devices = {
        "luksroot" = {
          device = "/dev/disk/by-uuid/56cd0776-0e1a-46b2-8e61-56a1aab91c4a";
          keyFileSize = 4096;
          keyFile = "/dev/disk/by-uuid/2022-08-09-12-03-48-00";
          allowDiscards = true;
        };
        "luksdata" = {
          device = "/dev/disk/by-uuid/f8c9d40f-d397-46d2-a058-55a225d2670e";
          keyFileSize = 4096;
          keyFile = "/dev/disk/by-uuid/2022-08-09-12-03-48-00";
          allowDiscards = true;
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/20b4e7b3-3a81-468e-9ca9-2fdc1b6c2238";
      fsType = "btrfs";
      options = [ "subvol=root" "discard=async" ];
    };
    "/home" = {
      device = "/dev/disk/by-uuid/20b4e7b3-3a81-468e-9ca9-2fdc1b6c2238";
      fsType = "btrfs";
      options = [ "subvol=home" "discard=async" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/A0D1-44CF";
      fsType = "vfat";
    };
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/1a34979e-9d0a-47bf-a2a8-2034afddec19";
      fsType = "btrfs";
      options = [ "subvol=data" "discard=async" ];
    };
    "/mnt/bcache" = {
      device = "/dev/disk/by-uuid/fe06889b-37fe-4252-ba03-84ca1ae57264";
      fsType = "ext4";
      options = externalMountOptions;
    };
    "/mnt/hitachi" = {
      device = "/dev/disk/by-uuid/0c21a12f-488e-41f2-bd92-3a8ef4db020e";
      fsType = "ext4";
      options = externalMountOptions;
    };
  };
}
