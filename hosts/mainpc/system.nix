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
    "/home/seyhan/.cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=2048M" ];
    };
    "/home/seyhan/.config/BraveSoftware/Brave-Browser/Default/Service Worker/CacheStorage" =
      {
        device = "tmpfs";
        fsType = "tmpfs";
        noCheck = true;
        options = [ "noatime" "nodev" "nosuid" "size=512M" ];
      };
    "/home/seyhan/.config/discord/Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=256M" ];
    };
    "/home/seyhan/.config/discord/Code Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/discord/DawnCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/discord/GPUCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/Code/CachedData" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=256M" ];
    };
    "/home/seyhan/.config/Code/Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=128M" ];
    };
    "/home/seyhan/.config/Code/CachedExtensionVSIXs" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/Code/CachedProfilesData" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/Code/Code Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/Code/DawnCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/Code/GPUCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/obsidian/Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/obsidian/Code Cache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/obsidian/DawnCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
    };
    "/home/seyhan/.config/obsidian/GPUCache" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=32M" ];
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
