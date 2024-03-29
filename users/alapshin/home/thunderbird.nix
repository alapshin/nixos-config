{ pkgs
, lib
, config
, osConfig
, secretDir
, ...
}:
let
  cfg = config.programs.thunderbird;
  enabled = builtins.elem osConfig.networking.hostName [
    "carbon"
  ];
  accounts =
    if !enabled then
      { }
    else
      builtins.fromJSON (builtins.readFile "${secretDir}/accounts.json");
in
{
  accounts.email.accounts = lib.mkIf cfg.enable {
    "GMail" = {
      flavor = "gmail.com";
      address = accounts.gmail;
      realName = "Andrei Lapshin";
      thunderbird.enable = true;
    };
    "Fastmail" = {
      flavor = "fastmail.com";
      address = accounts.fastmail;
      primary = true;
      realName = "Andrei Lapshin";
      thunderbird.enable = true;
    };
  };

  programs.thunderbird = {
    enable = enabled;

    profiles = {
      default = {
        isDefault = true;
        settings = {
          # 9205: Avoid information leakage in reply header
          "mailnews.reply_header_type" = 0;
          "mailnews.reply_header_originalmessage" = "";
          # Sort by date in descending order using threaded view
          "mailnews.default_sort_type" = 18;
          "mailnews.default_sort_order" = 2;
          "mailnews.default_view_flags" = 1;
          "mailnews.default_news_sort_type" = 18;
          "mailnews.default_news_sort_order" = 2;
          "mailnews.default_news_view_flags" = 1;
        };
      };
    };
  };
  home.file = {
    # ".thunderbird/default/user.js".source = "${dotfileDir}/thunderbird/user.js";
  };
}
