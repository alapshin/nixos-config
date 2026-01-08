{
  backup = import ./services/backup/borgbackup.nix;
  vpn = import ./services/networking/vpn.nix;
  monica = import ./services/web-apps/monica5.nix;
  webhost = import ./services/web-server/webhost.nix;
}
