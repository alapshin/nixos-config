{
  backup = import ./backup.nix;
  servarr = import ./services/misc/servarr;
  monica = import ./services/web-apps/monica5.nix;
  webhost = import ./services/web-server/webhost.nix;
}
