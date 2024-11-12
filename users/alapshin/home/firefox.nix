{
  pkgs,
  osConfig,
  dotfileDir,
  ...
}:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = {
        nativeMessagingHosts.packages = [
          pkgs.kdePackages.plasma-browser-integration
        ];
      };
    };

    policies = {
      # Needed for ActivityWatch Addon
      "3rdparty" = {
        "Extensions" = {
          "{ef87d84c-2127-493f-b952-5b4e744245bc}" = {
            "consentOfflineDataCollection" = true;
          };
        };
      };
      "Cookies" = {
        "Locked" = true;
        "Behavior" = "reject-tracker-and-partition-foreign";
        "BehaviorPrivateBrowsing" = "reject-tracker-and-partition-foreign";
      };
      "DisablePocket" = true;
      "DisableSetDesktopBackground" = true;
      "DontCheckDefaultBrowser" = true;
      "EnableTrackingProtection" = {
        "Value" = true;
        "Locked" = true;
        "Cryptomining" = true;
        "Fingerprinting" = true;
        "EmailTracking" = true;
      };
      "ExtensionUpdate" = false;
      "FirefoxSuggest" = {
        "Locked" = true;
        "ImproveSuggest" = false;
        "WebSuggestions" = false;
        "SponsoredSuggestions" = false;
      };
      "Homepage" = {
        "Locked" = true;
        "StartPage" = "previous-session";
      };
      "NewTabPage" = false;
      "NoDefaultBookmarks" = true;
      "OfferToSaveLogins" = false;
      "PasswordManagerEnabled" = false;
      "PictureInPicture" = {
        "Locked" = true;
        "Enabled" = true;
      };
      "SearchSuggestEnabled" = false;
      "UserMessaging" = {
        "Locked" = true;
        "WhatsNew" = false;
        "MoreFromMozilla" = false;
        "UrlbarInterventions" = false;
        "FeatureRecommendations" = false;
        "ExtensionRecommendations" = false;
      };
    };
    profiles = {
      default = {
        id = 0;
        extensions =
          (with pkgs.firefox-addons; [ linguist-translator ])
          ++ (with pkgs.nur.repos.rycee.firefox-addons; [
            awesome-rss
            aw-watcher-web
            metamask
            sponsorblock
            languagetool
            ublock-origin
            tree-style-tab
            keepassxc-browser
            plasma-integration
            temporary-containers
            multi-account-containers
          ]);
        settings = {
          # Set minimum font size
          "font.minimum-size.x-cyrillic" = 14;
          "font.minimum-size.x-western" = 14;
          "font.size.monospace.x-western" = 14;

          # Disable default browser check due to
          # https://bugzilla.mozilla.org/show_bug.cgi?id=1516290
          "browser.shell.checkDefaultBrowser" = false;

          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;
          # Don't close window with last tab
          "browser.tabs.closeWindowWithLastTab" = false;
          # Disable URL encoding on copying
          "browser.urlbar.decodeURLsOnCopy" = true;
          # Enable preinstalled addons
          "extensions.autoDisableScopes" = 0;
          # Disable pocket
          "extensions.pocket.enabled" = false;
          # Use hostname as device name for Firefox Sync
          "identity.fxaccounts.account.device.name" = osConfig.networking.hostName;
          # Sync bookmarks using Floccus instead of Firefox Sync
          "services.sync.engine.bookmarks" = false;
          # Enable userChrome.css support
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = builtins.readFile "${dotfileDir}/mozilla/firefox/chrome/userChrome.css";
      };
    };
  };

  # Workaround for plasma-browser-integration when using Plasma6 and installing Firefox via home-manager
  home.file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
