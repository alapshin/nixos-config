{ lib, dirs, ... }:

{
  /* 
  Extract username from path
  */
  extractUsername = path: builtins.elemAt (lib.splitString "/" (lib.removePrefix dirs.users path)) 1;
}
