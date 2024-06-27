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
    kernelParams = [ "mem_sleep_default=deep" ];
    extraModulePackages = [ ];
    tmp.useTmpfs = true;
  };
  zramSwap.enable = true;
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7e1a04ef-003f-4d92-af0a-4c6d381b51d0";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/434E-81A8";
      fsType = "vfat";
    };
    "/home/seyhan/Pictures/Screenshots" = {
      device = "tmpfs";
      fsType = "tmpfs";
      noCheck = true;
      options = [ "noatime" "nodev" "nosuid" "size=128M" ];
    };
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
