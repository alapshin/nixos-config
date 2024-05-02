{ pkgs
, config
, dotfileDir
, ...
}: {
  services = {
    ssh-agent = {
      enable = true;
    };
  };

  programs = {
      ssh = {
          enable = true;
          addKeysToAgent = "yes";
          matchBlocks = {
              "dedisrv" = {
                  user= "root";
                  hostname = "37.27.114.205";
              };
          };
      };
  };
}
