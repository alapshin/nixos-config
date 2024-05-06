{ config, pkgs, ... }:
{
  environment.systemPackages = [
    (
      let
        # Specify the postgresql package you'd like to upgrade to.
        # Do not forget to list the extensions you need.
        newPostgres = pkgs.postgresql_16.withPackages (pp: [
          # pp.plv8
        ]);
      in
      pkgs.writeScriptBin "pg-upgrade-cluster" ''
        set -eux
        # It's perhaps advisable to stop all services that depend on postgresql
        systemctl stop postgresql

        export OLDBIN="${config.services.postgresql.package}/bin"
        export OLDDATA="${config.services.postgresql.dataDir}"

        export NEWBIN="${newPostgres}/bin"
        export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

        install -d -m 0700 -o postgres -g postgres "$NEWDATA"
        cd "$NEWDATA"
        sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

        sudo -u postgres $NEWBIN/pg_upgrade \
          --old-bindir $OLDBIN --new-bindir $NEWBIN \
          --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
          "$@"
      ''
    )
  ];
}
