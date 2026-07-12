{ config, pkgs, ... }:
{
  home.file."Projects".source = pkgs.emptyDirectory;
}
