{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python37.withPackages(ps: with ps; [ 
      ipython 
      notebook
      numpy
      pandas
    ]))
  ];
}
