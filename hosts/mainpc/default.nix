{ config, lib, pkgs, ... }: {
  imports = [ ./system.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

  hardware = {
    wirelessRegulatoryDatabase = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
    bluetooth = {
      enable = true;
      package = pkgs.bluez5-experimental;
      powerOnBoot = true;
      disabledPlugins = [ "sap" ];

      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          Experimental = true;
        };

        Headset = {
          AutoConnect = true;
          ReconnectAttempts = 5;
        };
        Audio = { A2dpSink = "SBC Bitpool=53"; };
      };
    };
  };

  users.defaultUserShell = pkgs.zsh;
  users.users.seyhan = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  networking = {
    hostName = "asli";
    usePredictableInterfaceNames = true;
    nameservers = [ "94.140.14.140" "94.140.14.141" ];
    networkmanager.enable = true;
  };

  security = {
    sudo.extraRules = [{
      users = [ "seyhan" ];
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" ];
      }];
    }];
    polkit.enable = true;
    rtkit.enable = true;
  };

  time.timeZone = "Europe/Istanbul";

  nix = {
    settings = {
      use-xdg-base-directories = true;
      flake-registry = "/etc/nix/registry.json";
      min-free = "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = "${toString (10 * 1024 * 1024 * 1024)}";
      auto-optimise-store = true;
      allowed-users = [ "root" "@wheel" "nix-builder" ];
      trusted-users = [ "root" "@wheel" "nix-builder" ];
      max-jobs = "auto";
      sandbox = true;
      sandbox-fallback = false;
      system-features = [ "nixos-test" "kvm" "recursive-nix" "big-parallel" ];
      extra-platforms = config.boot.binfmt.emulatedSystems;
      keep-going = true;
      connect-timeout = 5;
      log-lines = 30;
      extra-experimental-features = [
        "flakes"
        "nix-command"
        "recursive-nix"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
      ];
      warn-dirty = false;
      http-connections = 50;
      accept-flake-config = false;
      use-cgroups = true;
      keep-derivations = true;
      keep-outputs = true;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://cache.privatevoid.net"
        "https://nixpkgs-wayland.cachix.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://numtide.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
      ];
    };
  };

  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        intel-vaapi-driver =
          pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
      allowUnfree = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      curl
      wget
      pciutils
      lshw
      man-pages
      dmidecode
      sysstat
      smartmontools
      rsync
      bind.dnsutils
      traceroute
      tcpdump
      mtr
    ];
    sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  };

  fonts.packages = with pkgs; [
    noto-fonts-cjk
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  systemd = {
    services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
    user = {
      services = {
        qbittorrent-nox = {
          enable = false;
          description = "Autostarts Qbittorrent-nox";
          wants = [ "network-online.target" ];
          after =
            [ "local-fs.target" "network-online.target" "nss-lookup.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
            Restart = "on-failure";
            RestartSec = 30;
          };
        };
        polkit-gnome-authentication-agent-1 = {
          enable = true;
          description = "Polkit authentication agent for GNOME (graphical)";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart =
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        mpris-proxy = {
          enable = true;
          description = "MPRIS Proxy for Bluetooth devices";
          after = [ "network.target" "sound.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = { ExecStart = "${pkgs.bluez}/bin/mpris-proxy"; };
        };
      };
    };
  };

  sound.enable = true;

  programs = {
    hyprland.enable = true;
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
      histSize = 10000;
      autosuggestions.enable = true;
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      package = pkgs.nh;
      flake = "/home/seyhan/.nixos";
    };
  };

  services = {
    gvfs.enable = true;
    resolved = {
      enable = true;
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [ "94.140.14.140" "94.140.14.141" ];
      dnsovertls = "true";
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      };
    };
  };

  system.stateVersion = "24.05";
}
