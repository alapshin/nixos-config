{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jetbrains.pycharm-professional

    (python3.withPackages(ps: with ps; [ 
      ipython 
      notebook
      numpy
      pandas
      tensorflowWithCuda
    ]))
  ];
}
