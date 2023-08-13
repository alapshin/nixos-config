{ pkgs
, osConfig
, dotfileDir
, ...
}: let
  isNixOS = builtins.hasAttr "system" osConfig;
in {

  programs.firefox = {
    enable = isNixOS;
    package = pkgs.firefox.override {
      cfg = {
        enablePlasmaBrowserIntegration = true;
      };
    };

    profiles = {
      default = {
        id = 0;
        extensions =
          (with pkgs.firefox-addons; [
            linguist-translator
            bypass-paywalls-clean
          ])
          ++ (with pkgs.nur.repos.rycee.firefox-addons; [
            keepassxc-browser
            languagetool
            metamask
            multi-account-containers
            plasma-integration
            sponsorblock
            temporary-containers
            tree-style-tab
            ublock-origin
          ]);
        settings = {
          # Use system's dpi for UI fonts
          "layout.css.dpi" = 115;
          # Setup font dpi for web content
          "ui.textScaleFactor" = 115;
          "layout.css.devPixelsPerPx" = "1.2";
          "browser.display.os-zoom-behavior" = 0;
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
