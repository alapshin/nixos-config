{ pkgs
, osConfig
, secretDir
, ...
}: 
let 
  accounts = builtins.fromJSON(builtins.readFile "${secretDir}/accounts.json");
in {
  accounts.email.accounts  = {
    "GMail" = {
      flavor = "gmail.com";
      address = accounts.gmail;
      realName = "Andrei Lapshin";
      thunderbird.enable = true;
    };
    "Fastmail" = {
      flavor = "fastmail.com";
      address = "alapshin@fastmail.com";
      primary = true;
      realName = "Andrei Lapshin";
      thunderbird.enable = true;
    };
  };

  programs.thunderbird = {
    enable = true;

    profiles = {
      default = {
        isDefault = true;
        settings = { 
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
