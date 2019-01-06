{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python3.withPackages(ps: with ps; [ 
      ipython 
      notebook
      numpy
      pandas
    ]))
  ];
}
