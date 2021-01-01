{ config, pkgs, ... }:

{
  environment.variables = {
    EDITOR = "nvim";
    NIX_PAGER = "cat";
  };

  environment.systemPackages = with pkgs; [
    shellcheck
  ];

  programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestions = {
      enable = true;
    };
    enableCompletion = true;
    enableBashCompletion = true;
    syntaxHighlighting = {
      enable = true;
    };
    ohMyZsh = {
      enable = true;
      plugins = [
        "adb"
        "docker"
        "docker-compose"
        "docker-machine"
        "git"
        "gradle"
        "httpie"
        "man"
        "python"
        "pip"
        "systemd"
      ];
      customPkgs = with pkgs; [
        zsh-completions
        nix-zsh-completions
      ];
    };
    promptInit = ''
      if [[ "$TERM" != "linux" ]]; then
        source ~/.p10k.zsh
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      fi
    '';
  };
}
