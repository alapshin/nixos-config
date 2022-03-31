# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    kernelModules = [ "kvm-intel" ];
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
      luks.devices."luksroot".device = "/dev/disk/by-uuid/8119ac87-97bb-44fd-889f-79389f22588b";
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    };
  };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5952-0C32";
      fsType = "vfat";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6d4f3850-0279-46ed-9b2c-4e5382d1d2ad";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/6d4f3850-0279-46ed-9b2c-4e5382d1d2ad";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}