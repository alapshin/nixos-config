{ lib, ... }:
{
  services.borgbackup.jobs = lib.mkForce { };
}
