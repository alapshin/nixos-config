{ config, ... }:
{
  # Enforce XDG directories usage for some apps
  home.sessionVariables = {
    AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    DVDCSS_CACHE = "${config.xdg.dataHome}/dvdcss";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    # RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";

    _JAVA_OPTIONS = ''
      -Djava.util.prefs.userRoot=${config.xdg.configHome}/java 
      -Dawt.useSystemAAFontSettings=on 
      -Dswing.aatext=true 
    '';
  };
}
