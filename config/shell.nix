{ config, pkgs, ... }:

{
  programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;

  programs.zsh = {
    enable = true;
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
	"mercurial"
	"python" 
	"pip"
	"systemd"
      ];
      customPkgs = with pkgs; [
        nix-zsh-completions
      ];
    };
    promptInit = ''
      POWERLEVEL9K_MODE='nerdfont-complete'
      POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir docker_machine virtualenv vcs)
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status)
      POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="┌─"
      POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="└─ "
      if [[ "$TERM" != "linux" ]]; then
        source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    zsh-completions
  ];
}
