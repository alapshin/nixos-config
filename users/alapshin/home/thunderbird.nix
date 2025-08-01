{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.thunderbird;
in
{
  accounts = {
    email.accounts = {
      "GMail" = {
        flavor = "gmail.com";
        address = config.secrets.contents.email.gmail;
        realName = "Andrei Lapshin";
        thunderbird.enable = cfg.enable;
      };
      "Fastmail" = {
        flavor = "fastmail.com";
        address = config.secrets.contents.email.fastmail;
        primary = true;
        realName = "Andrei Lapshin";
        thunderbird.enable = cfg.enable;
      };
    };
    calendar.accounts = {
      "Nextcloud" = {
        primary = true;
        remote = rec {
          type = "caldav";
          url = "https://nextcloud.bitgarage.dev/remote.php/dav/calendars/${userName}/personal/";
          userName = "user1";
        };
        thunderbird.enable = cfg.enable;
      };
    };
    contact.accounts = {
      "Nextcloud" = {
        remote = rec {
          type = "carddav";
          url = "https://nextcloud.bitgarage.dev/remote.php/dav/addressbooks/users/${userName}/contacts/";
          userName = "user1";
        };
        thunderbird.enable = cfg.enable;
      };
    };
  };

  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird-latest;

    profiles = {
      default = {
        isDefault = true;
        settings = {
          "extensions.autoDisableScopes" = 0;

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

          # Check IMAP subfolder for new messages
          "mail.check_all_imap_folders_for_new" = true;
          "mail.server.default.check_all_folders_for_new" = true;
        };
        extensions = with pkgs; [
          # TODO: Add some extensions
        ];
      };
    };
  };

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = [
        "${config.programs.thunderbird.package}/share/applications/thunderbird.desktop"
      ];
    };
  };
}
