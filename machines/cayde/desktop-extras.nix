# desktop-extras.nix
# Nerd Fonts, Niri (Wayland), greetd+tuigreet greeter, Noctalia shell,
# Catppuccin theming, and the imv / yazi / mpv tools.
#
# `inputs` is available here because flake.nix passes specialArgs = { inherit inputs; }.
{ config, pkgs, inputs, ... }:

{
  ##########################################################################
  # Fonts — Nerd Fonts.
  # nerdfonts was split into individual pkgs.nerd-fonts.* packages (25.05+).
  # Pick what you use; swap the filter comment in to install ALL of them.
  ##########################################################################
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.symbols-only     # icon glyphs for shells/status bars
  ];
  # To instead install every Nerd Font:
  # fonts.packages = builtins.filter pkgs.lib.attrsets.isDerivation
  #   (builtins.attrValues pkgs.nerd-fonts);

  ##########################################################################
  # Niri — scrollable-tiling Wayland compositor (from nixpkgs).
  # If your channel's nixpkgs doesn't have this module, use the flake instead:
  #   github:sodiboo/niri-flake (nixosModules.niri).
  ##########################################################################
  programs.niri.enable = true;

  ##########################################################################
  # Greeter — greetd + tuigreet (replaces LightDM).
  # tuigreet lists all installed sessions (XFCE xsession + Niri wayland
  # session), remembers your last choice, and shows the clock.
  ##########################################################################
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session \
          --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions
      '';
      user = "greeter";
    };
  };

  ##########################################################################
  # Noctalia — Quickshell desktop shell for Niri.
  # Installed as the flake package; launch it from inside Niri, e.g. add to
  # your ~/.config/niri/config.kdl:  spawn-at-startup "noctalia-shell"
  # Config lives in ~/.config/noctalia/ (see docs.noctalia.dev).
  ##########################################################################
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.system}.default
  ] ++ (with pkgs; [
    imv          # Wayland image viewer
    yazi         # terminal file manager
    mpv          # media player
  ]);

  ##########################################################################
  # Catppuccin theming (module comes from flake.nix).
  # At the NixOS level this themes system bits (TTY, greeter, etc.). For the
  # full 70+ app coverage you'd add the Home Manager module per-user.
  ##########################################################################
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  # NetworkManager is already enabled in configuration.nix — nothing to add.
}
