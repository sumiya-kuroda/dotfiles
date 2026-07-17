{ config, lib, pkgs, ... }:
{
  ##########################################################################
  # REPAIRED for 2x GTX 1080 (Pascal) on current NixOS.
  # Changes from your original:
  #   * hardware.opengl -> hardware.graphics; driSupport removed;
  #     driSupport32Bit -> enable32Bit
  #   * package: stable -> legacy_580 (mainline 590+ drops Pascal support)
  #   * removed the allowUnfreePredicate (it restricted unfree to only the
  #     3 nvidia packages, which would block Chrome/VS Code/Warp/RustDesk).
  #     allowUnfree = true now lives once in configuration.nix.
  ##########################################################################

  # Graphics stack (was hardware.opengl).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Kept as-is: desktops don't suspend, so this stays off.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # MUST stay false: the open module only supports Turing (RTX 20) or
    # newer. The GTX 1080 is Pascal, so it uses the proprietary module.
    open = false;

    nvidiaSettings = true;

    # CRITICAL: the 590+ mainline driver no longer recognizes Pascal cards.
    # 580 is the last branch that supports the GTX 1080 — pin it explicitly,
    # otherwise you boot to no display.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
}
