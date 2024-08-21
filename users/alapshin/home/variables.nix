{ config, ... }:
{
  # Enforce XDG directories usage for some apps
  home.sessionVariables = {
    ANDROID_SDK_ROOT = "$HOME/opt/android-sdk";
    # ANDROID_PREFS_ROOT = "$XDG_CONFIG_HOME/android";
    # ANDROID_EMULATOR_HOME = "$XDG_DATA_HOME/android/emulator";

    AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    ELECTRUMDIR = "${config.xdg.dataHome}/electrum";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    # RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";

    _JAVA_OPTIONS = ''
      -Djava.util.prefs.userRoot=${config.xdg.configHome}/java 
      -Dawt.useSystemAAFontSettings=on 
      -Dswing.aatext=true 
      -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel
    '';
  };
}
