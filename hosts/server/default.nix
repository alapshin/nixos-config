{ lib, ... }:

{
  imports = [
    ./nix.nix

    ./backup.nix
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

  # No need for fonts on a server
  fonts.fontconfig.enable = lib.mkDefault false;

  environment = {
    noXlibs = lib.mkDefault true;
    stub-ld.enable = lib.mkDefault false;
  };
}
