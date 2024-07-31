{ pkgs
, config
, inputs
, ...
}: {

  disabledModules = [
    "${inputs.home-manager}/modules/services/syncthing.nix"
  ];

  imports = [
    "${inputs.home-manager-syncthing}/modules/services/syncthing.nix"
  ];


}
