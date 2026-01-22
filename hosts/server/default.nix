{
  lib,
  pkgs,
  config,
  ...
}:

{
  imports = [
    ./nix.nix

    ./openssh.nix
    ./networking.nix
  ];

  # use TCP BBR has significantly increased throughput and reduced latency for connections
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  time.timeZone = lib.mkDefault "UTC";

  # No mutable users by default
  users.mutableUsers = false;
  services.userborn.enable = true;

  documentation.enable = false;
  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  environment = {
    stub-ld.enable = lib.mkDefault false;
  };

  # Work-around for missing subuid support in userbon
  # See https://github.com/nikstur/userborn/issues/7#issuecomment-2462106017
  environment.etc =
    let
      autosubs = lib.pipe config.users.users [
        lib.attrValues
        (lib.filter (u: u.uid != null && u.autoSubUidGidRange))
        (lib.concatMapStrings (u: "${toString u.uid}:${toString (100000 + u.uid * 65536)}:65536\n"))
      ];
    in
    {
      "subuid".text = autosubs;
      "subuid".mode = "0444";
      "subgid".text = autosubs;
      "subgid".mode = "0444";
    };

  environment.systemPackages = with pkgs; [
    bottom
    # Install ghostty terminfo
    ghostty
  ];
}
