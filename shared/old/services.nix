{ config, lib, pkgs, ... }:

let 

  inherit (lib.modules) mkDefault;

in

{
  
  # Enable CUPS to print documents.
  services.printing.enable = mkDefault true;
  services.printing.drivers = [ pkgs.brlaser ];
}
