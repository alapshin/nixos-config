{ config, pkgs, ... }:

{
  boot.kernel.sysctl."sysrq"=1;
}
