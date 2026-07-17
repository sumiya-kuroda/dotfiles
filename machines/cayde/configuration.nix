# /etc/nixos/configuration.nix
#
# Merged + repaired config for host "cayde".
# Built from flake.nix (see that file). Apply with:
#   sudo nixos-rebuild switch --flake /etc/nixos#cayde
#
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix   # your original, untouched
    ./docker.nix                   # repaired (see file)
    ./nvidia.nix                   # repaired (see file)
    ./desktop-extras.nix           # fonts, Niri, tuigreet, noctalia, etc.
    # NOTE: <home-manager/nixos> was removed — it needs a channel and clashes
    #   with the flake, and nothing here actually used it. Re-add as a flake
    #   input if you ever want Home Manager.
    # NOTE: the nixos-vscode-server tarball import was removed — flake.nix now
    #   supplies that module (services.vscode-server.enable still works).
  ];

  ############################################################################
  # Bootloader — kept exactly as your original (GRUB on /dev/sda).
  ############################################################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  ############################################################################
  # Networking
  ############################################################################
  networking.hostName = "cayde";
  networking.networkmanager.enable = true;

  ############################################################################
  # Locale / time (unchanged from your config)
  ############################################################################
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  ############################################################################
  # Nix — enable flakes (this system is built from flake.nix)
  ############################################################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree (nvidia, cuda, vscode, chrome, warp, rustdesk).
  # Single source of truth — the restrictive allowUnfreePredicate that was in
  # nvidia.nix has been removed (it would have blocked Chrome/VS Code/Warp).
  nixpkgs.config.allowUnfree = true;

  ############################################################################
  # Desktop: X11 + XFCE, plus Niri (Wayland) — see desktop-extras.nix.
  # The display manager is now greetd + tuigreet (also in desktop-extras.nix),
  # so LightDM has been removed — you can't run two display managers, and
  # tuigreet lets you pick XFCE or Niri at login.
  ############################################################################
  services.xserver.enable = true;                        # still needed for XFCE (X11)
  services.xserver.desktopManager.xfce.enable = true;

  # Keymap — FIXED: services.xserver.layout was renamed to xkb.layout.
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  ############################################################################
  # Printing
  ############################################################################
  services.printing.enable = true;

  ############################################################################
  # Sound — PipeWire.
  # FIXED: removed `sound.enable` (option no longer exists) and renamed
  # hardware.pulseaudio -> services.pulseaudio.
  ############################################################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################################################
  # Remote access
  ############################################################################
  services.openssh.enable = true;
  services.x2goserver.enable = true;

  # VS Code Remote-SSH server support (module comes from flake.nix).
  # Reminder: also run ONCE per user after first login (not declarative):
  #   systemctl --user enable --now auto-fix-vscode-server.service
  services.vscode-server.enable = true;

  ############################################################################
  # User account (kept; de-duplicated VS Code — see note in systemPackages)
  ############################################################################
  users.users.skuroda = {
    isNormalUser = true;
    description = "skuroda";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      firefox
      # Removed `vscode` and `vscode.fhs` here — they collided with the
      # vscode-with-extensions build in systemPackages (both provide `code`).
    ];
  };

  ############################################################################
  # System packages
  ############################################################################
  environment.systemPackages = with pkgs; [
    # --- your originals ---
    vim
    wget
    git
    unzip
    google-chrome
    ethtool
    cifs-utils

    # VS Code with your extensions (single install — no bare `vscode` next to
    # it, which was the collision). Dropped the pinned marketplace
    # remote-ssh-edit override: it hardcoded a version+sha that easily breaks
    # on channel bumps, and remote-ssh below already covers Remote-SSH.
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
      ];
    })

    # --- requested additions ---
    rustdesk-flutter          # RustDesk remote desktop
    warp-terminal             # Warp terminal (unfree)
    slack                     # Slack (unfree)

    # CUDA toolkit + libraries (nvcc, cuDNN). Does NOT flip
    # nixpkgs.config.cudaSupport (which would rebuild half of nixpkgs);
    # your Python GPU wheels from uv/pip/conda bring their own CUDA.
    cudaPackages.cudatoolkit
    cudaPackages.cudnn

    # Python tooling
    python3                   # system Python for quick use
    uv                        # fast Python package/venv manager
    conda                     # provides the `conda-shell` FHS wrapper
  ];

  ############################################################################
  # uv support
  ############################################################################
  # uv installs tool shims into ~/.local/bin.
  environment.localBinInPath = true;
  # uv's downloaded standalone Pythons are dynamically linked; nix-ld lets
  # them run on NixOS.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  ############################################################################
  # Misc programs (kept)
  ############################################################################
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  ############################################################################
  # Do NOT change — reflects the release of your FIRST install.
  # (You can build against nixpkgs 25.11 while leaving this at 23.05.)
  ############################################################################
  system.stateVersion = "23.05";
}
