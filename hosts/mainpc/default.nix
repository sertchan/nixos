{ config, lib, pkgs, pkgs-stable, ... }: {
  imports = [ ./system.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };

  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs-stable; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  users.defaultUserShell = pkgs-stable.zsh;
  users.users.seyhan = {
    isNormalUser = true;
    shell = pkgs-stable.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  networking = {
    hostName = "asli";
    nameservers = [ "94.140.14.140" "94.140.14.141" ];
    networkmanager.enable = true;
    wg-quick.interfaces =
      let server_ip = "146.70.124.194";
      in {
        wg0 = {
          address = [ "10.66.208.166/32" "fc00:bbbb:bbbb:bb01::3:d0a5/128" ];
          dns = [ "10.64.0.1" ];
          listenPort = 51820;
          privateKeyFile = "/etc/mullvad-vpn.key";
          peers = [{
            publicKey = "Ekc3+qU88FuMfkEMyLlgRqDYv+WHJvUsfOMI/C0ydE4=";
            allowedIPs = [ "0.0.0.0/0" "::0/0" ];
            endpoint = "${server_ip}:51820";
            persistentKeepalive = 25;
          }];
        };
      };
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
        "notashelf.cachix.org-1:VTTBFNQWbfyLuRzgm2I7AWSDJdqAa11ytLXHBhrprZk="
        "neovim-flake.cachix.org-1:iyQ6lHFhnB5UkVpxhQqLJbneWBTzM8LBYOFPLNH4qZw="
        "nyx.cachix.org-1:xH6G0MO9PrpeGe7mHBtj1WbNzmnXr7jId2mCiq6hipE="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.notashelf.dev-1:DhlmJBtURj+XS3j4F8SFFukT8dYgSjtFcd3egH8rE6U="
        "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
      ];
    };
  };

  nixpkgs = {
    config = {
      packageOverrides = pkgs-stable: {
        intel-vaapi-driver =
          pkgs-stable.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
      allowUnfree = true;
    };
  };

  environment = {
    systemPackages =
      let
        stablePackages = with pkgs-stable; [
          curl
          wget
          openssl
          pciutils
          lshw
          man-pages
          rsync
          bind.dnsutils
        ];
        unstablePackages = [ ];
      in
      stablePackages ++ unstablePackages;

    variables = {
      PKG_CONFIG_PATH = "${pkgs-stable.openssl.dev}/lib/pkgconfig";
    };

    sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
  };

  fonts.packages = with pkgs-stable; [
    noto-fonts-cjk
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  systemd = {
    services."wg-quick-wg0".wantedBy = lib.mkForce [ ];
    user = {
      services = {
        qbittorrent-nox = {
          description = "Autostarts Qbittorrent-nox";
          enable = true;
          wants = [ "network-online.target" ];
          after =
            [ "local-fs.target" "network-online.target" "nss-lookup.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = "${pkgs-stable.qbittorrent-nox}/bin/qbittorrent-nox";
            Restart = "on-failure";
            RestartSec = 30;
          };
        };
        polkit-gnome-authentication-agent-1 = {
          description = "Polkit authentication agent for GNOME (graphical)";
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart =
              "${pkgs-stable.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        mpris-proxy = {
          description = "MPRIS Proxy for Bluetooth devices";
          after = [ "network.target" "sound.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = "${pkgs-stable.bluez}/bin/mpris-proxy";
          };
        };
      };
    };
  };

  xdg.portal.wlr.enable = true;
  sound.enable = true;

  programs = {
    hyprland.enable = true;
    zsh.enable = true;
    nh = {
      enable = true;
      package = pkgs.nh;
      flake = "/home/seyhan/.nixos";
    };
  };

  services = {
    gvfs.enable = true;
    mullvad-vpn.enable = true;

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
