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
    ./xray-client.nix
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
  };

  system = {
    switch = {
      enable = lib.mkDefault false;
      enableNg = lib.mkDefault true;
    };
    activationScripts.diff = {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        fi
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
    ntfs3g
  ];
}
