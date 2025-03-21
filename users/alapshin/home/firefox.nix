{
  pkgs,
  osConfig,
  dotfileDir,
  ...
}:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    nativeMessagingHosts = with pkgs; [
      kdePackages.plasma-browser-integration
    ];

    policies = {
      "Cookies" = {
        "Locked" = true;
        "Behavior" = "reject-tracker-and-partition-foreign";
        "BehaviorPrivateBrowsing" = "reject-tracker-and-partition-foreign";
      };
      "DisableAppUpdate" = true;
      "DisablePocket" = true;
      "DisableSetDesktopBackground" = true;
      "DisplayBookmarksToolbar" = "never";
      "DNSOverHTTPS" = {
        "Enabled" = false;
      };
      "DontCheckDefaultBrowser" = true;
      "EnableTrackingProtection" = {
        "Value" = true;
        "Locked" = true;
        "Cryptomining" = true;
        "Fingerprinting" = true;
        "EmailTracking" = true;
      };
      "ExtensionUpdate" = false;
      "FirefoxHome" = {
        "Locked" = true;
        "Search" = false;
        "Highlights" = false;
        "Pocket" = false;
        "TopSites" = false;
        "Snippets" = false;
        "SponsoredPocket" = false;
        "SponsoredTopSites" = false;
      };
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
      "HttpsOnlyMode" = "force_enabled";
      "NewTabPage" = false;
      "NoDefaultBookmarks" = true;
      "OfferToSaveLogins" = false;
      "PasswordManagerEnabled" = false;
      "PictureInPicture" = {
        "Locked" = true;
        "Enabled" = true;
      };
      "PopupBlocking" = {
        "Locked" = true;
        "Default" = true;
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
        extensions.packages =
          (with pkgs.firefox-addons; [ linguist-translator ])
          ++ (with pkgs.nur.repos.rycee.firefox-addons; [
            metamask
            linkwarden
            sponsorblock
            skip-redirect
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

          # Don't close window with last tab
          "browser.tabs.closeWindowWithLastTab" = false;
          # Disable URL encoding on copying
          "browser.urlbar.decodeURLsOnCopy" = true;
          # Enable preinstalled addons
          "extensions.autoDisableScopes" = 0;
          # Use hostname as device name for Firefox Sync
          "identity.fxaccounts.account.device.name" = osConfig.networking.hostName;
          # Enable userChrome.css support
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = builtins.readFile "${dotfileDir}/mozilla/firefox/chrome/userChrome.css";
      };
    };
  };
}
