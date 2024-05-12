{ lib
, pkgs
, config
, domainName
, ...
}:
let
  mkServarr =
    { app
    , port
    , user ? null
    , group ? null
    ,
    }:
    let
      cfg = config.services."${app}";
    in
    {
      services = {
        "${app}" = {
          enable = true;
        } // lib.optionalAttrs (user != null) {
          inherit user;
        } // lib.optionalAttrs (group != null) {
          inherit group;
        };
      };

      users.users = lib.optionalAttrs (builtins.hasAttr "user" cfg) {
        "${cfg.user}".extraGroups = [ "media" ];
      };
    };
in
{
  config = lib.mkMerge [
    (mkServarr { app = "radarr"; port = 7878; })
    (mkServarr { app = "readarr"; port = 8787; })
    (mkServarr { app = "sonarr"; port = 8989; })
    (mkServarr { app = "prowlarr"; port = 9696; })
  ];
}
