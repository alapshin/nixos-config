{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf
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
    histSize = 10000;
    histFile = "$ZDOTDIR/.zsh_history";
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
        "fzf"
        "git"
        "git-extras"
        "gradle"
        "httpie"
        "man"
        "python"
        "pip"
        "ripgrep"
        "systemd"
      ];
      customPkgs = with pkgs; [
        zsh-completions
        nix-zsh-completions
      ];
    };
    interactiveShellInit = ''
      export FZF_BASE="${pkgs.fzf}/share/fzf"
    '';
    promptInit = ''
      if [[ "$TERM" != "linux" ]]; then
        source $ZDOTDIR/p10k.zsh
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      fi
    '';
  };
}
