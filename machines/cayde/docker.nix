{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  virtualisation.docker.package = pkgs.docker_29;

  # GPU access inside containers (replaces enableNvidia).
  hardware.nvidia-container-toolkit.enable = true;
}
