{
  lib,
  pkgs,
  config,
  ...
}:
{
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
    };
  };

  environment.systemPackages = [
    (
      let
        cfg = config.services.postgresql;
        # Specify the postgresql package you'd like to upgrade to.
        newPostgres = pkgs.postgresql_18.withPackages cfg.extensions;
      in
      pkgs.writeScriptBin "pg-upgrade-cluster" ''
        #!/usr/bin/env bash

        set -euox pipefail

        # It's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql

        declare -r OLDBIN="${cfg.finalPackage}/bin"
        declare -r OLDDATA="${cfg.dataDir}"

        declare -r NEWBIN="${newPostgres}/bin"
        declare -r NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"

        cd "$NEWDATA"
        sudo --user postgres "$NEWBIN/initdb" --pgdata "$NEWDATA" ${lib.escapeShellArgs cfg.initdbArgs}
        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          "$@"
      ''
    )
  ];
}
