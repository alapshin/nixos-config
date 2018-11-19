{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Moscow";
  time.hardwareClockInLocalTime = true;
}
