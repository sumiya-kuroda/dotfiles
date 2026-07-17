# home.nix — Home Manager config for user "skuroda".
# This is the per-user layer: dotfiles, app configs, and per-app theming.
# `inputs` is passed in via home-manager.extraSpecialArgs in flake.nix.
{ config, pkgs, inputs, ... }:

{
  imports = [
    # Per-user Catppuccin — this is the one that themes 70+ apps (kitty,
    # bat, fzf, niri, etc.), unlike the system module.
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "skuroda";
  home.homeDirectory = "/home/skuroda";

  # Home Manager's own release version — independent of system.stateVersion.
  # Leave at the release you first set up HM with.
  home.stateVersion = "25.11";

  ##########################################################################
  # Catppuccin (per-user). Applies to any program below that HM manages.
  ##########################################################################
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  ##########################################################################
  # Starter examples — grow this over time. Anything you enable here gets
  # Catppuccin-themed automatically where a port exists.
  ##########################################################################
  programs.git = {
    enable = true;
    # userName = "Sumiya Kuroda";
    # userEmail = "s.kuroda@ucl.ac.uk";
  };

  # e.g. later:
  # programs.kitty.enable = true;
  # programs.bat.enable = true;
  # programs.zsh.enable = true;

  # User-scoped packages can also live here instead of system-wide, e.g.:
  # home.packages = with pkgs; [ ripgrep fd ];
}
