{
  username,
  ...
}@args:
{
  home-manager.extraSpecialArgs = {
    inherit username;
  };
  home-manager.users."${username}" = import ./home.nix args;
}
