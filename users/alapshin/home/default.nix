{
  isNixOS,
  username,
  ...
}@args:
{
  home-manager.extraSpecialArgs = {
    inherit isNixOS username;
  };
  home-manager.users."${username}" = import ./home.nix args;
}
