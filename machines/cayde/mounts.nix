# mounts.nix — SWC Ceph + Synology NAS CIFS shares.
{ config, pkgs, ... }:

let
  cifsOptions = [
    "credentials=/home/skuroda/.smb_swc"
    "uid=1000"                      
    "gid=100"                      
    "file_mode=0664"
    "dir_mode=0775"
    "vers=3.0"
    "iocharset=utf8"
    "nofail"                         
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"     
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];

  # NAS uses a different credentials file and a newer SMB version,
  # so it gets its own list.
  nasOptions = [
    "credentials=/home/skuroda/.smb_ikora"
    "uid=1000"
    "gid=100"
    "file_mode=0664"
    "dir_mode=0775"
    "vers=3.1.1"                    
    "iocharset=utf8"
    "nofail"
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
  ];
in
{
  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/mnt/ceph" = {
    device = "//ceph-gw02.hpc.swc.ucl.ac.uk/mrsic_flogel";
    fsType = "cifs";
    options = cifsOptions;
  };

  fileSystems."/mnt/ikora_data" = {
    device = "//192.168.5.99/DATA";
    fsType = "cifs";
    options = nasOptions;
  };

  fileSystems."/mnt/ikora_scratch" = {
    device = "//192.168.5.99/WORKSTATION";
    fsType = "cifs";
    options = nasOptions;
  };
}
