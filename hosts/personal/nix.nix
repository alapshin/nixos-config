{ lib, ... }:

{
  nix.daemonIOSchedClass = "idle";
  nix.daemonIOSchedPriority = 7;
  nix.daemonCPUSchedPolicy = "idle";
}
