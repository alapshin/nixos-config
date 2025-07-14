{
  lib,
  pkgs,
  config,
  osConfig,
  ...
}:
{
  home.file =
    let
      self = config.programs.firefox;
      profile =
        self.configPath
        + (if pkgs.stdenv.hostPlatform.isDarwin then "/Profiles/" else "/")
        + self.profiles."default".path;
    in
    {
      "${profile}/chrome".source = "${pkgs.firefox-ui-fix}/chrome";
    };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    nativeMessagingHosts = lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux [
      pkgs.kdePackages.plasma-browser-integration
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
            clearurls
            metamask
            linkwarden
            sponsorblock
            skip-redirect
            languagetool
            ublock-origin
            tree-style-tab
            keepassxc-browser
            temporary-containers
            multi-account-containers
          ])
          ++ (lib.lists.optionals pkgs.stdenv.hostPlatform.isLinux (
            with pkgs.nur.repos.rycee.firefox-addons;
            [
              plasma-integration
            ]
          ));
        search = {
          force = true;
          default = "ddg";
          engines = {
            bing.metaData.hidden = true;
            google.metaData.hidden = true;

            nix-options = {
              name = "Nix Options";
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@no" ];
            };
            nix-packages = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
          };
        };
        settings = {
          # Set minimum font size
          "font.minimum-size.x-cyrillic" = 14;
          "font.minimum-size.x-western" = 14;
          "font.size.monospace.x-western" = 14;

          # Don't close window with last tab
          "browser.tabs.closeWindowWithLastTab" = false;
          # Disable URL encoding on copying
          "browser.urlbar.decodeURLsOnCopy" = true;
          #  Disable calculator in url bar
          "browser.urlbar.suggest.calculator" = false;
          # Enable preinstalled addons
          "extensions.autoDisableScopes" = 0;
          # Use hostname as device name for Firefox Sync
          "identity.fxaccounts.account.device.name" = osConfig.networking.hostName;
          # Enable userChrome.css support
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Firefox-Ui-Fix settings
          "userChrome.icon.menu.full" = true;
          "userChrome.icon.panel_full" = true;
          "userChrome.icon.panel_photon" = false;
          "userChrome.icon.global_menu" = false;
          "userChrome.icon.global_menubar" = false;
          "userChrome.hidden.tabbar" = true;
          "userChrome.hidden.sidebar_header" = true;
          "userChrome.theme.non_native_menu" = false;
        };
        extraConfig = builtins.readFile "${pkgs.firefox-ui-fix}/user.js";
      };
    };
  };
}
