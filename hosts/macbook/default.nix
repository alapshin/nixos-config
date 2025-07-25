{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  username = "andrei.lapshin";
in
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
  users.users."${username}" = {
    home = "/Users/${username}";
    shell = pkgs.fish;
  };
  system.primaryUser = username;
  # For correct PATH
  launchd.user.envVariables = {
    PATH = config.environment.systemPath;
  };

  homebrew = {
    enable = true;
    global = {
      autoUpdate = false;
    };
  };

  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
  };
}
