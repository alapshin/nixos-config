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
              "gelmir" = {
                  user = "root";
                  port = 2222;
                  hostname = "37.27.114.205";
              };
              "niflheim" = {
                  user= "root";
                  hostname = "37.27.114.205";
              };
          };
      };
  };
}
