{ config, lib, pkgs, ... }:

{
  ##########################################################################
  # REPAIRED docker + NVIDIA.
  # Changes from your original:
  #   * virtualisation.docker.enableNvidia (deprecated/removed) ->
  #     hardware.nvidia-container-toolkit.enable
  #   * removed systemd.enableUnifiedCgroupHierarchy = false (that was a
  #     workaround for libnvidia-container <1.8.0; the current toolkit
  #     supports cgroups v2, and forcing v1 can break other services)
  #   * removed the hardware.opengl block (renamed to hardware.graphics and
  #     already set in nvidia.nix — no need to duplicate)
  ##########################################################################

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # GPU access inside containers (replaces enableNvidia).
  hardware.nvidia-container-toolkit.enable = true;
}
