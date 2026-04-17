{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/2a601aafdc5605a5133a2ca506a34a3a73377247.tar.gz") {} }:

let
  app = import ./default.nix { inherit pkgs; };
in
pkgs.dockerTools.buildLayeredImage {
  name = "reproducible-app";
  tag = "latest";
  contents = [ app ];
  config = {
    Cmd = [ "${app}/bin/app" ];
  };
}
