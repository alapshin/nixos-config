{
  config,
  ...
}: {
  # Enforce XDG directories usage for some apps
  home.sessionVariables = {
    ANDROID_SDK_ROOT = "$HOME/opt/android-sdk";
    # ANDROID_PREFS_ROOT = "$XDG_CONFIG_HOME/android";
    # ANDROID_EMULATOR_HOME = "$XDG_DATA_HOME/android/emulator";

    AWS_CONFIG_FILE = "$XDG_CONFIG_HOME/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "$XDG_CONFIG_HOME/aws/credentials";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    DOCKER_CONFIG = "$XDG_CONFIG_HOME/docker";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    IPYTHONDIR = "$XDG_CONFIG_HOME/jupyter";
    JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";

    _JAVA_OPTIONS = ''-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java -Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'';
  };
}
