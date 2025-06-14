{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./nix.nix
    ./backup.nix
    ./openssh.nix
    ./secrets.nix
    ./services.nix
    ./networking.nix
  ];

  boot = {
    # Enable the magic SysRq key
    kernel.sysctl = {
      "kernel.sysrq" = 438;
    };
    kernelModules = [
      "kvm-amd"
      "kvm-intel"
    ];
    kernelPackages = pkgs.linuxPackages_zen;
    initrd = {
      systemd = {
        enable = true;
      };
    };
    tmp.cleanOnBoot = true;
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  security = {
    sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults !tty_tickets 
        Defaults lecture = never
      '';
    };
    tpm2 = {
      enable = true;
      pkcs11.enable = false;
      tctiEnvironment.enable = true;
    };

    pam.loginLimits = [
      {
        domain = "@users";
        item = "nofile";
        type = "-";
        value = "8192";
      }
    ];
  };

  programs.nh.enable = true;

  systemd.user.extraConfig = "DefaultLimitNOFILE=8192";

  environment.systemPackages = with pkgs; [
    sbctl
    ntfs3g
    pciutils
  ];
}
