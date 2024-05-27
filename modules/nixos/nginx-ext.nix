{ lib
, pkgs
, config
, ...
}:
let
  cfg = config.services.nginx-ext;

  inherit (lib)
    types
    attrsets
    mkIf
    mkOption
    nameValuePair
    ;
in
{
  options.services.nginx-ext = {
    basedomain = mkOption {
      type = types.str;
      description = "Base domain";
    };

    authdomain = mkOption {
      type = types.str;
      description = "Auth domain";
    };

    applications = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          port = mkOption {
            type = types.port;
            description = "Application listen port.";
          };

          auth = mkOption {
            type = types.bool;
            description = "Protect application with auth";
          };
        };
      });
    };
  };

  config = {
    services.nginx = {
      upstreams = attrsets.mapAttrs
        (app: opts: {
          servers = {
            "localhost:${toString opts.port}" = { };
          };
        })
        cfg.applications;

      virtualHosts = attrsets.mapAttrs'
        (app: opts: nameValuePair ("${app}.${cfg.basedomain}") {
          forceSSL = true;
          useACMEHost = cfg.basedomain;
          locations = {
            "/" = {
              proxyPass = "http://${app}";
              extraConfig = mkIf opts.auth ''
                # Headers
                proxy_set_header X-Forwarded-Ssl on;
                proxy_set_header X-Forwarded-Uri $request_uri;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;

                # Basic Proxy Configuration
                proxy_no_cache $cookie_session;
                proxy_cache_bypass $cookie_session;
                # Timeout if the real server is dead.
                proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;

                # Send a subrequest to Authelia to verify if the user is 
                # authenticated and has permission to access the resource.
                auth_request /authenticate;

                set $target_url $scheme://$http_host$request_uri;

                # Inject the response headers from the variables into the request made to the backend.
                proxy_set_header Remote-User $user;
                proxy_set_header Remote-Name $name;
                proxy_set_header Remote-Email $email;
                proxy_set_header Remote-Groups $groups;

                # Save the upstream response headers from Authelia to variables.
                auth_request_set $user $upstream_http_remote_user;
                auth_request_set $name $upstream_http_remote_name;
                auth_request_set $email $upstream_http_remote_email;
                auth_request_set $groups $upstream_http_remote_groups;

                # If the subreqest returns 200 pass to the backend, 
                # if the subrequest returns 401 redirect to the portal.
                error_page 401 =302 http://${cfg.authdomain}/?rd=$target_url;
              '';
            };

            "/authenticate" = mkIf opts.auth {
              proxyPass = "http://authelia/api/verify";
              extraConfig = ''
                # Essential Proxy Configuration
                internal;

                # Headers
                # The headers starting with X-* are required.
                proxy_set_header Content-Length "";
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Original-Method $request_method;
                proxy_set_header X-Forwarded-Uri $request_uri;
                proxy_set_header X-Forwarded-Method $request_method;

                # Basic Proxy Configuration
                proxy_pass_request_body off;
                proxy_no_cache $cookie_session;
                proxy_cache_bypass $cookie_session;
                # Timeout if the real server is dead
                proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
              '';
            };
          };
        })
        cfg.applications;
    };
  };
}
