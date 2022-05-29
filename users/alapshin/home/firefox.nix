{
  pkgs,
  dotfileDir,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
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
          # Enable userChrome.css support
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        userChrome = builtins.readFile "${dotfileDir}/mozilla/firefox/chrome/userChrome.css";
      };
    };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      cookie-autodelete
      https-everywhere
      keepassxc-browser
      localcdn
      plasma-integration
      temporary-containers
      tree-style-tab
      ublock-origin
      umatrix
    ];
  };
}
