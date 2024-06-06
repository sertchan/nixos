{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "rtsx_usb_sdmmc"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7e1a04ef-003f-4d92-af0a-4c6d381b51d0";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/434E-81A8";
      fsType = "vfat";
    };
    "/home/seyhan/.cache/BraveSoftware" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=128M" ];
    };
    "/home/seyhan/.cache/mozilla/firefox" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=128M" ];
    };
    "/home/seyhan/.cache/spotify" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=128M" ];
    };
    "/home/seyhan/.cache/mesa_shader_cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.cache/ranger" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.cache/thumbnails" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.cache/ueberzugpp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.config/obsidian/Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.config/obsidian/Code Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.config/obsidian/DawnCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
    "/home/seyhan/.config/obsidian/GPUCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=16M" ];
    };
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024;
  }];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
