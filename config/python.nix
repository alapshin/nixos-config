{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python36.withPackages(ps: with ps; [ 
      ipython 
      notebook
      numpy
      pandas
      tensorflowWithCuda
    ]))
  ];
}
