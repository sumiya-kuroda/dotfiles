# desktop.nix — fonts, theming, and a few apps. X11 / XFCE setup.
{ config, pkgs, ... }:

{
  ##########################################################################
  # Fonts 
  ##########################################################################
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  ##########################################################################
  # Catppuccin theming .
  # Per-app theming can also be enabled per-user in home.nix.
  ##########################################################################
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  environment.systemPackages = with pkgs; [
    mpv    # media player
    imv    # image viewer 
  ];
}
