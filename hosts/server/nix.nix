{ lib, ... }:

{
  nix.daemonIOSchedClass = "best-effort";
  nix.daemonIOSchedPriority = 4;
  nix.daemonCPUSchedPolicy = "batch";
}
