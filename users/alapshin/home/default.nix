{
  username,
  ...
} @ args : {
  home-manager.users."${username}" = import ./home.nix args;
}
