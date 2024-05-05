{ lib
, ...
}:
let
  # For tesing in VM
  # rawdisk1 = "/dev/vda";
  # rawdisk2 = "/dev/vdb";
  rawdisk1 = "/dev/nvme0n1";
  rawdisk2 = "/dev/nvme1n1";
  cryptdisk1 = "luks_disk1";
  cryptdisk2 = "luks_disk2";
in
{

  # Use label to mount btrfs device pool
  fileSystems = {
    "/" = {
      device = lib.mkForce "/dev/disk/by-label/pool";
    };
  };

  disko.devices = {
    disk = {
      "${rawdisk1}" = {
        type = "disk";
        device = rawdisk1;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              label = "esp1";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot1";
                mountOptions = [ "nofail" ];
              };
            };
            luks = {
              size = "100%";
              label = cryptdisk1;
              content = {
                type = "luks";
                name = cryptdisk1;
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                passwordFile = "/tmp/disk.key";
                extraOpenArgs = [ "--timeout 10" ];
              };
            };
          };
        };
      };

      "${rawdisk2}" = {
        type = "disk";
        device = rawdisk2;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "1G";
              label = "esp2";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot2";
                mountOptions = [ "nofail" ];
              };
            };
            luks = {
              size = "100%";
              label = cryptdisk2;
              content = {
                type = "luks";
                name = cryptdisk2;
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                passwordFile = "/tmp/disk.key";
                extraOpenArgs = [ "--timeout 10" ];
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "--force"
                    "--data raid1"
                    "--metadata raid1"
                    "--label pool"
                    "/dev/mapper/${cryptdisk1}"
                    "/dev/mapper/${cryptdisk2}"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

