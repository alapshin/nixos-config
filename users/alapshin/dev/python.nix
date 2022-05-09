{
  config,
  myutils,
  pkgs,
  ...
}: let
  username = myutils.extractUsername (builtins.toString ./.);
in {
  users.users."${username}".packages = with pkgs; [
    (python3.withPackages (ps:
      with ps; [
        ipython
        notebook
        matplotlib
        numpy
        pandas
        # pelican
        scikitlearn
        seaborn
      ]))
  ];
}
