{
  lib,
  pkgs,
  config,
  ...
}:
let
  hostname = "freshrss.${config.services.webhost.basedomain}";
  cntools_extensions_src = pkgs.fetchFromGitHub {
    owner = "KayuHD";
    repo = "cntools_FreshRssExtensions";
    rev = "feb20b3e453ec7ebd71d25088efad88b420f3510";
    hash = "sha256-EqwQQv80RLfpsCbQDRo1XTMiIRSPJYMRVn122wfnh2I=";
  };
  official_extensions_src = pkgs.fetchFromGitHub {
    owner = "FreshRSS";
    repo = "Extensions";
    rev = "0557f8fbcd88993dae0545e1da393baca059769b";
    hash = "sha256-LvNFFXY+XRsx5Q89mUOnPybAKib3kZQ5gfQlesUV/jo=";
  };
in
{

  sops = {
    secrets = {
      "freshrss/admin_password" = {
        owner = config.services.freshrss.user;
      };
      "freshrss/oidc_client_secret" = {
      };

    };
    templates."freshrss.env".content = ''
      OIDC_CLIENT_SECRET=config.sops.placeholder."paperless/oidc_client_secret";
      OIDC_CLIENT_CRYPTO_KEY=insecure_crypto_key
    '';
  };

  services = {
    freshrss = {
      enable = true;
      authType = "form";
      baseUrl = "https://${hostname}";
      database = {
        type = "pgsql";
        host = "/run/postgresql";
      };
      webserver = "caddy";
      virtualHost = "${hostname}";
      passwordFile = config.sops.secrets."freshrss/admin_password".path;
      extensions = [
        (pkgs.freshrss-extensions.buildFreshRssExtension rec {
          pname = "colorfull-list";
          version = "0.3.2";
          FreshRssExtUniqueId = "Colorful List";
          src = official_extensions_src;
          sourceRoot = "${src.name}/xExtension-ColorfulList";
          meta = {
            homepage = "https://github.com/FreshRSS/Extensions/tree/master/xExtension-ColorfulList";
            license = lib.licenses.mit;
          };
        })
        (pkgs.freshrss-extensions.buildFreshRssExtension rec {
          pname = "reading-time";
          version = "1.6.1";
          FreshRssExtUniqueId = "ReadingTime";
          src = official_extensions_src;
          sourceRoot = "${src.name}/xExtension-ReadingTime";
          meta = {
            homepage = "https://github.com/FreshRSS/Extensions/tree/master/xExtension-ReadingTime";
            license = lib.licenses.mit;
          };
        })
        (pkgs.freshrss-extensions.buildFreshRssExtension rec {
          pname = "filter-title";
          version = "0.1.0";
          FreshRssExtUniqueId = "FilterTitle";
          src = cntools_extensions_src;
          sourceRoot = "${src.name}/xExtension-FilterTitle";
          meta = {
            homepage = "https://github.com/cn-tools/cntools_FreshRssExtensions/tree/master/xExtension-FilterTitle";
            license = lib.licenses.mit;
          };
        })
        (pkgs.freshrss-extensions.buildFreshRssExtension rec {
          pname = "af-readability";
          version = "0.1.0";
          FreshRssExtUniqueId = "Af_Readability";
          src = pkgs.fetchFromGitHub {
            owner = "Niehztog";
            repo = "freshrss-af-readability";
            rev = "65d4f6818c25febe93a760425601b91a874b7f92";
            hash = "sha256-K+sI65PvpUhlDIfSv42tjzJuWjJ6mQUfNwL2/k+4d0M=";
          };
          meta = {
            homepage = "https://github.com/Niehztog/freshrss-af-readability";
            license = lib.licenses.mit;
          };
        })
      ];
    };

    rss-bridge = {
      enable = true;
      config = {
        system.enabled_bridges = [
          "AssociatedPressNewsBridge"
          "DevToBridge"
          "HarvardBusinessReviewBridge"
          "HarvardHealthBlogBridge"
          "LWNprevBridge"
          "PhoronixBridge"
          "ReutersBridge"
          "TelegramBridge"
          "WikipediaBridge"
        ];
      };
      webserver = "caddy";
      virtualHost = "rssbridge.${config.services.webhost.basedomain}";
    };

    postgresql = {
      ensureDatabases = [ config.services.freshrss.database.name ];
      ensureUsers = [
        {
          name = config.services.freshrss.database.user;
          ensureDBOwnership = true;
        }
      ];
    };

    webhost.applications."rssbridge".auth = true;

    authelia.instances."main".settings = {
      identity_providers = {
        oidc = {
          clients = [
            {
              client_id = "freshrss";
              client_name = "FreshRSS";
              client_secret = "$pbkdf2-sha512$310000$xQ8NO2Qe0ugYdsYKEEXgJQ$e0ziGtIgAChw958WaYShQAEXOPW/.WL9SHN77xpHqKam.NpqA7ncbB/URJkaVewLwufMkxLailAu1H0M5ufpcg";
              authorization_policy = "one_factor";
              redirect_uris = [
                "https://freshrss.${config.services.webhost.basedomain}/i/oidc/"
              ];
            }
          ];
        };
      };
    };
  };

  systemd.services.phpfpm-freshrss.environment = {
    OIDC_ENABLED = "1";
    OIDC_CLIENT_ID = "freshrss";
    OIDC_PROVIDER_METADATA_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
    OIDC_SCOPES = "openid groups email profile";
    OIDC_REMOTE_USER_CLAIM = "preferred_username";
    OIDC_X_FORWARDED_HEADERS = "X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
  };

  systemd.services.freshrss-config.environment = {
    OIDC_ENABLED = "1";
    OIDC_CLIENT_ID = "freshrss";
    OIDC_PROVIDER_METADATA_URL = "https://${config.services.webhost.authdomain}/.well-known/openid-configuration";
    OIDC_SCOPES = "openid groups email profile";
    OIDC_REMOTE_USER_CLAIM = "preferred_username";
    OIDC_X_FORWARDED_HEADERS = "X-Forwarded-Host X-Forwarded-Port X-Forwarded-Proto";
  };
}
