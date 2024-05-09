{ lib
, ...
}:
let
  dataDisk1 = "/dev/sda";
  luksData1 = "luks-data1";

  # For tesing in VM
  # systemDisk1 = "/dev/vda";
  # systemDisk2 = "/dev/vdb";
  systemDisk1 = "/dev/nvme0n1";
  systemDisk2 = "/dev/nvme1n1";
  luksSystem1 = "luks-system1";
  luksSystem2 = "luks-system2";
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
      "${systemDisk1}" = {
        type = "disk";
        device = systemDisk1;
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
              label = luksSystem1;
              content = {
                type = "luks";
                name = luksSystem1;
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

      "${systemDisk2}" = {
        type = "disk";
        device = systemDisk2;
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
              label = luksSystem2;
              content = {
                type = "luks";
                name = luksSystem2;
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
                    "/dev/mapper/${luksSystem1}"
                    "/dev/mapper/${luksSystem2}"
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

      "${dataDisk1}" = {
        type = "disk";
        device = dataDisk1;
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              label = luksData1;
              content = {
                type = "luks";
                name = luksData1;
                passwordFile = "/tmp/disk.key";
                content = {
                  type = "btrfs";
                  mountpoint = "/mnt/data";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}

