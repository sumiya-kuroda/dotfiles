# /etc/nixos/configuration.nix
# Edit this configuration file to define what should be installed

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Extension
      ./desktop.nix   
      ./nvidia.nix    
      ./mounts.nix 
    ];

  ############################################################################
  # Bootloader
  ############################################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################################################
  # Networking
  ############################################################################
  networking.hostName = "cayde"; # Define your hostname.
  networking.networkmanager.enable = true;

  ############################################################################
  # Time zone
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
  # Nix / flakes 
  ############################################################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  ############################################################################
  # Desktop
  ############################################################################
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  ############################################################################
  # Keymap / Printing / Sound
  ############################################################################
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  ############################################################################
  # Remote access
  ############################################################################
  services.openssh.enable = true;
  services.x2goserver.enable = true;
  networking.interfaces.enp8s0.wakeOnLan.enable = true;
  services.vscode-server.enable = true;

  # For Ikora
  networking.networkmanager.unmanaged = [ "interface-name:eno1" ];
  networking.interfaces.eno1.ipv4.addresses = [{
    address = "192.168.5.100";
    prefixLength = 24;
  }];
  ############################################################################
  # User account 
  ############################################################################
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.skuroda = {
    isNormalUser = true;
    description = "skuroda";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      firefox
      warp-terminal
    ];
  };


  ############################################################################
  # Software
  ############################################################################
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    google-chrome
    ethtool
    cifs-utils
    rustdesk-flutter         
    vscode             
    slack
    samba                  

    cudaPackages.cudatoolkit
    cudaPackages.cudnn

    python3                   # system Python for quick use
    uv                       
    conda                  
  ];

  # CUDA 12.6
  nixpkgs.overlays = [
      (final: prev: { cudaPackages = final.cudaPackages_12_6; })
  ];

  # uv installs tool shims into ~/.local/bin.
  environment.localBinInPath = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  # Shell
  programs.zsh.enable = true;

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
