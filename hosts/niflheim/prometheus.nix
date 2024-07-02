{ lib
, config
, domainName
, ...
}:
{
  services = {
    prometheus = {
      enable = true;
      listenAddress = "localhost";
      exporters = {
        node = {
          enable = true;
          listenAddress = "localhost";
        };
      };
      globalConfig.scrape_interval = "10s"; # "1m"
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };

    nginx-ext.applications."prometheus" = {
      auth = true;
      port = config.services.prometheus.port;
    };
  };
}
