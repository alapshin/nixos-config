{
  lib,
  pkgs,
  config,
  ...
}:

{
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.latest;
    settings = {
      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      max-jobs = 2;
      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;

      log-lines = lib.mkDefault 25;
      # Enable flakes and new 'nix' command
      experimental-features = lib.mkForce [
        "flakes"
        "nix-command"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];

      use-xdg-base-directories = true;
    };
  };

  # Make builds to be more likely killed than important services.
  # 100 is the default for user slices and 500 is systemd-coredumpd@
  # We rather want a build to be killed than our precious user sessions
  # as builds can be easily restarted.
  systemd.services.nix-daemon.environment.TMPDIR = "/var/tmp";
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
}
