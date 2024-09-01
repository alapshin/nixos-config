{ lib, ... }:

{
  nix = {
    daemonIOSchedClass = "best-effort";
    daemonIOSchedPriority = 4;
    daemonCPUSchedPolicy = "batch";
  };
}
