{ lib, ... }:

{
  nix = {
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
    daemonCPUSchedPolicy = "idle";
  };
}
