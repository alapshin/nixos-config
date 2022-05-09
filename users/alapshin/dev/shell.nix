{
  config,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
  users.users."${username}".packages = with pkgs; [
    shellcheck
  ];
}
