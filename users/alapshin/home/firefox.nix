{ config, dirs, myutils, pkgs, ... }:
let
  hmcfg = config.home-manager.users."${username}";
  username = myutils.extractUsername (builtins.toString ./.);
in
{
  home-manager.users."${username}" = {
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

            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;
            # Enable preinstalled addons
            "extensions.autoDisableScopes" = 0;
            # Enable userChrome.css support
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
          userChrome = builtins.readFile "${dirs.dotfiles}/mozilla/firefox/chrome/userChrome.css";
        };
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        cookie-autodelete
        decentraleyes
        https-everywhere
        keepassxc-browser
        temporary-containers
        tree-style-tab
        ublock-origin
        umatrix
      ];
    };
  };
}
