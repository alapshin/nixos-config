{
  config,
  pkgs,
  ...
}: {
  environment = {
    variables = {
      ZDOTDIR = "$HOME/.config/zsh";
    };
  };

  programs.ssh.startAgent = true;
  programs.gnupg.agent.enable = true;
}
