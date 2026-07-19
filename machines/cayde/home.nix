# home.nix — Home Manager config for user "skuroda".
{ config, pkgs, inputs, ... }:

{
  imports = [
    # Per-user Catppuccin — this is the one that themes individual apps.
    inputs.catppuccin.homeModules.catppuccin
  ];

  home.username = "skuroda";
  home.homeDirectory = "/home/skuroda";
  home.stateVersion = "25.11";

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  # Enabling programs here lets Catppuccin theme them automatically.
  programs.mpv.enable = true;
}
