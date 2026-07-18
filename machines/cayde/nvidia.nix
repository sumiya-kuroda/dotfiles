{ config, lib, pkgs, ... }:
{
  # Graphics stack (was hardware.opengl).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # MUST stay false: the open module only supports Turing (RTX 20) or
    # newer. The GTX 1080 is Pascal, so it uses the proprietary module.
    open = false;

    nvidiaSettings = true;

    # CRITICAL: the 590+ mainline driver no longer recognizes Pascal cards.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
  };
}
