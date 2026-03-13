{
  anki = import ./anki.nix;
  git = import ./git.nix;
  gnupg = import ./gnupg.nix;
  ssh = import ./ssh.nix;
  texlive = import ./texlive.nix;

  secrets = import ./secrets.nix;
  theming = import ./theming.nix;
  variables = import ./variables.nix;
}
