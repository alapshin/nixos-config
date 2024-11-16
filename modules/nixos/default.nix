{
  backup = import ./backup.nix;
  servarr = import ./services/misc/servarr;
  nginx-ext = import ./nginx-ext.nix;
  monica5 = import ./services/web-apps/monica5.nix;
}
