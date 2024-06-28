{ config, lib, pkgs, ... }: {
  imports = [ ./system.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
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
    gc = {
      automatic = true;
      persistent = true;
      randomizedDelaySec = "30min";
      dates = "weekly";
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
    systemPackages = with pkgs; [ # They're mostly monitoring tools
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
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD"; # ! For Hardare Acceleration
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      allowBitmaps = true;
      antialias = true; # ! For better font rendering
      hinting = {
        enable = true;
        style = "slight"; # Its perfect hinting for almost all cases
      };
      subpixel = {
        rgba = "rgb"; # This is not really necessary
        lcdfilter = "default"; # This is not really necessary either
      };
      defaultFonts =
        { # Noto Fonts very similar to Seugue UI. My fonts looks pretty much similar to windows
          serif = [ "Noto Serif" "DejaVu Serif" "Liberation Serif" ];
          sansSerif = [ "Noto Sans" "DejaVu Sans" "Liberation Sans" ];
          monospace = [ "Noto Sans Mono" "DejaVu Sans Mono" "Liberation Mono" ];
          emoji = [ "Apple Color Emoji" ];
        };
    };
    packages = with pkgs; [ # * Fonts that i like to use in my setups
      noto-fonts
      noto-fonts-cjk
      dejavu_fonts
      liberation_ttf
      whatsapp-emoji-font
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };

  systemd = {
    services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };
    user = {
      services = {
        ##! Critifcal Section ##
        udiskie = {
          #! Automounter for removable medias such as usb, phones etc.
          enable = true;
          description = "Automounter for removable media";
          wantedBy = [ "default.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.udiskie}/bin/udiskie";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        cliphist = {
          #! Clipboard management for wayland environment 
          enable = true;
          description = "Clipboard history service";
          wantedBy = [ "default.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart =
              "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
        wl-clip-persist = {
          #! For making clipboard persistent
          description = "Persistent clipboard for Wayland";
          wantedBy = [ "default.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            ExecStart =
              "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        polkit-gnome-authentication-agent-1 = {
          #! Polkit Authentication Agent for such tasks wants root permissions
          enable = true;
          description = "Polkit authentication agent of Gnome";
          wantedBy = [ "default.target" ];
          after = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart =
              "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 5;
            TimeoutStopSec = 10;
          };
        };

        ##  Not Critical Section ##
        mpris-proxy = {
          # Media Player Remote Interfacing Specification for Bluetooth devices
          enable = true;
          description = "MPRIS Proxy for Bluetooth devices";
          wantedBy = [ "default.target" ];
          after = [ "network.target" "sound.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        qbittorrent-nox = {
          # For Torrent managament, i prefer to use qbittorrent-nox
          # TODO: Should be done as Home-Manager Service 
          enable = true;
          description = "Qbittorrent-nox";
          wants = [ "network-online.target" ];
          after =
            [ "local-fs.target" "network-online.target" "nss-lookup.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        valiant-room-service = {
          # My friend's Discord bot which i want to get rid of him
          # TODO: Should be done as Home-Manager Service
          enable = true;
          path = with pkgs; [ bash bun ];
          description = "Valiant Dicord Bot";
          wants = [ "network-online.target" ];
          after =
            [ "local-fs.target" "network-online.target" "nss-lookup.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            ExecStart = pkgs.writeShellScript "run-bot" ''
              function run_bot {
                cd /home/seyhan/.!SelfHost/valiant-room || exit
                bun src/index.ts
              }

              run_bot
            '';
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
      };
    };
  };

  sound.enable = true; # ! Enable sound

  programs = {
    hyprland.enable = true; # ! Enable hyprland window manager
    zsh = { # * I prefer to use zsh as my shell
      enable = true;
      ohMyZsh.enable = true;
      histSize = 10000; # Can be reduced
      autosuggestions.enable = true;
    };
    nh = { # ! Use nixhelper, it really helps while building new nix generations
      enable = true;
      package = pkgs.nh;
      flake = "/home/seyhan/.nixos";
    };
  };

  services = {
    gvfs.enable = true;

    greetd = { # ! Use greetd for auto launching Hyprland
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/hyprland";
          user = "seyhan";
        };
        default_session = initial_session;
      };
    };

    resolved =
      { # ! Use resolved project for dns, DO NOT touch unless you need to change dns
        enable = true;
        dnssec = "true";
        domains = [ "~." ];
        fallbackDns = [ "94.140.14.140" "94.140.14.141" ];
        dnsovertls = "true";
      };

    pipewire = { # ! Use Pipewire project for sound management
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    tlp = { # * Use TLP for better power consumption
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      };
    };
  };

  system.stateVersion =
    "24.11"; # !! DONT CHANGE IT UNLESS YOU KNOW WHAT YOU'RE DOING
}
