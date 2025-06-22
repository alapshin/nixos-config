{
  isNixOS,
  isLinux,
  isDarwin,
  username,
  ...
}@args:
{
  home-manager.extraSpecialArgs = {
    inherit
      isNixOS
      isLinux
      isDarwin
      username
      ;
  };
  home-manager.users."${username}" = import ./home.nix args;
}
