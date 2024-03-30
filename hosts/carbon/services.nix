{ pkgs
, config
, ...
}: {
  services = {
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "";
          package = pkgs.nerdfonts;
        }
      ];
    };
    openssh = {
      enable = true;
    };
  };
}
