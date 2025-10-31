{
  pkgs,
  config,
  ...
}:
{
  services = {
    ssh-agent = {
      enable = pkgs.stdenv.hostPlatform.isLinux;
    };
  };

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };
        "github.com" = {
          user = "git";
          host = "github.com";
        };
        "gitlab.com" = {
          user = "git";
          host = "gitlab.com";
        };
        "bifrost" = {
          user = "root";
          hostname = "95.217.6.218";
        };
        "hel" = {
          user = "root";
          port = 2222;
          hostname = "37.27.114.205";
        };
        "niflheim" = {
          user = "root";
          hostname = "37.27.114.205";
        };
        "storagebox" = {
          user = "u399502";
          port = 23;
          hostname = "u399502.your-storagebox.de";
        };
      };
    };
  };
}
