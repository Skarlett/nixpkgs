{ config, lib, pkgs, ... }:
let
 epart = {
      fsType="tmpfs";
      device="none";
      options=["defaults" "size=1M" "mode=755" ];
  };

  part = label: {
    device="/dev/disk/by-label/${label}";
    fsType="f2fs";
  };
in
{
  fileSystems = {
    "/boot" = {
      fsType="vfat";
      device="/dev/disk-by/label/BOOT";
    };
    "/nix" = part "nixstore";
    "/" = epart;
    "/home" = epart "home";
    "/root" = epart "root";
  };
}
