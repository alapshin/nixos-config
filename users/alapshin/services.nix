{
  config,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
  services = {

    locate = {
      enable = true;
      locate = pkgs.mlocate;
      # To silence warning message
      # See https://github.com/NixOS/nixpkgs/issues/30864
      localuser = null;
    };

    syncthing = {
      enable = true;
      user = username;
      group = "users";
      dataDir = "/home/${username}";
      devices = {
          altdesk = {
              id = "K77LUC6-BZYZKY3-CHVAHJW-RXHUAPB-T6ZNZ6Q-KF77MQY-RCGE56Y-OV5XRAF";
          };
          carbon = {
              id = "BB37FLW-KTKMN6T-2PQERS2-4T4P4U7-6ZWJCDU-BVRFF5F-P7BFCU3-CJH5FQP";
          };
          desktop = {
              id = "SDAJAKH-WCN4BW6-H4H6QWF-43QC7DB-NWGL2RY-HOWYMNP-7TUWZZN-NC7MQAY";
          };
          oneplus = {
              id = "BUNDEAI-JNT4FBK-KL444PA-XY3YVQA-YSMS7BB-N2NAWRE-6DAXRRQ-WWRAUQK";
          };
      };
      folders = {
        "/home/${username}/Syncthing" = {
          id = "syncthing";
          label = "Syncthing";
          devices = [ "altdesk" "carbon" "desktop" "oneplus" ];
        };
      };
      overrideFolders = true;
      overrideDevices = false;
    };

  };
}
