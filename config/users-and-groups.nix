{ config, pkgs, ... }:

{
  users.users.alapshin = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "Andrei Lapshin";
    initialPassword = "12345678";
    extraGroups = [ 
      "adbusers"
      "audio"
      "docker"
      "networkmanager"
      "syncthing"
      "wheel" 
    ];
  };

  # Define environment variables for XDG directories.
  # We can't user environment.sessionVariable because we need to check for
  # $HOME existence.
  environment.loginShellInit = ''
    if [ -d $HOME ]; then
      export XDG_DATA_HOME="$HOME/.local/share"
      export XDG_CACHE_HOME="$HOME/.cache"
    fi
  '';
}
