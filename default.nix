{ config, pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.vim
  ];

  services.nix-daemon.enable = true;
  programs.zsh.enable = true;  # default shell on catalina
  system.stateVersion = 4;
}
