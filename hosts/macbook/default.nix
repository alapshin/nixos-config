{
  lib,
  pkgs,
  config,
  ...
}:
{
  nix.enable = false;
  programs.bash.enable = true;
  programs.fish.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    info.enable = false;
  };

  networking.hostName = "macbook";

  environment.shells = with pkgs; [
    bash
    fish
  ];
  users.users."andrei.lapshin" = {
    home = "/Users/andrei.lapshin";
    shell = pkgs.fish;
  };
}
