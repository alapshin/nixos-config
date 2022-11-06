{
  config,
  pkgs,
  ...
}: {
  services = {
    kmscon = {
      enable = true;
      hwRender = true;
    };
    openssh = {
      enable = true;
    };
  };
}
