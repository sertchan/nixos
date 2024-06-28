# ############################################## TODO: THIS ALL CONFIG NEEDS TO BE MODULARIZED. ###############################################

{ config, lib, pkgs, ... }: {
  imports = [ ./system.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true; # ! use systemd-boot instead of grub
      efi.canTouchEfiVariables =
        true; # ? i'm not sure if this is really necessary
    };
    kernelPackages =
      pkgs.linuxPackages_latest; # ! use latest linux package avaliable in the repo
  };

  hardware = {
    wirelessRegulatoryDatabase = true;
    opengl = { # ! necessary for hardware video accelaretion
      enable = true;
      extraPackages = with pkgs; [ # sure it's intel drivers
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };

    bluetooth = {
      enable = true;
      package = pkgs.bluez5-experimental;
      powerOnBoot = true; # ! power bluetooth on boot
      disabledPlugins =
        [ "sap" ]; # there is nothing to do with sap feature so i'm disabling it

      settings = {
        General = {
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          Experimental = true; # for showing battery info
        };

        Headset = {
          AutoConnect =
            true; # ? it's not really worky. please learn what this really stands to do
          ReconnectAttempts = 5;
        };
        Audio = { A2dpSink = "SBC Bitpool=53"; }; # set sbc to max quality
      };
    };
  };

  users.defaultUserShell =
    pkgs.zsh; # use zsh as default user shell (for root and other users)
  users.users.seyhan = {
    isNormalUser = true;
    shell = pkgs.zsh; # use zsh as seyhan's shell
    extraGroups =
      [ "wheel" "networkmanager" ]; # ! give access to whell and networkmanager
  };

  networking = {
    hostName = "asli"; # ! set asli as hostname
    usePredictableInterfaceNames = true;
    nameservers = # ! for changing dns servers
      [ "94.140.14.140" "94.140.14.141" ]; # i'm using adguard dns non-filtering
    networkmanager.enable = true;
  };

  security = {
    sudo.extraRules = [{
      users = [ "seyhan" ];
      commands = [{
        command = "ALL";
        options = [
          "NOPASSWD"
        ]; # ! for using sudo without password, it could be dangerous!
      }];
    }];
    polkit.enable = true;
    rtkit.enable = true;
  };

  time.timeZone =
    "Europe/Istanbul"; # TODO: change time zone when geolocation is changed

  nix = {
    settings =
      { # ? i acctualy copy-pasted this section from raf's configuration. need's to be refactored
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
    gc =
      { # ! enable garbage collector since nix is regardlessly uses big spaces in ssd. better to clean garbage weekly
        automatic = true;
        persistent = true; # ! really important to make service persistent
        randomizedDelaySec = "30min"; # ? this's not really neccesarry
        dates = "weekly";
      };
  };

  nixpkgs = {
    config = {
      packageOverrides = pkgs: { # ! for hardware video acceleration
        intel-vaapi-driver =
          pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
      allowUnfree = true; # for using packages like spotify, discord etc
    };
  };

  environment = {
    systemPackages = with pkgs; [ # they're mostly system monitoring tools
      curl
      wget
      pciutils
      lshw
      man-pages
      dmidecode
      sysstat
      smartmontools
      bind.dnsutils
      traceroute
      tcpdump
      mtr
    ];
    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD"; # ! for hardware video acceleration
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      allowBitmaps = true;
      antialias = true; # ! important for better font rendering
      hinting = {
        enable = true;
        style = "slight"; # it's perfect hinting for almost all cases
      };
      subpixel = {
        rgba = "rgb"; # this isn't really necessary
        lcdfilter = "default"; # this isn't really necessary either
      };
      defaultFonts =
        { # noto fonts are very similar to seugue ui font family which used in windows, that's why my fonts looks pretty much similar to windows fonts
          serif = [ "Noto Serif" "DejaVu Serif" "Liberation Serif" ];
          sansSerif = [ "Noto Sans" "DejaVu Sans" "Liberation Sans" ];
          monospace = [ "Noto Sans Mono" "DejaVu Sans Mono" "Liberation Mono" ];
          emoji = [ "Apple Color Emoji" ];
        };
    };
    packages =
      with pkgs; [ # fonts that makes my setup more eye candy than other linux rices
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
      systemd-networkd.stopIfChanged =
        false; # ? i'm not sure this is makes difference
      systemd-resolved.stopIfChanged =
        false; # ? i'm not sure this is makes difference either
    };
    user = {
      services = {
        ###! critifcal section ###
        udiskie = {
          #! automounter for removable medias such as usb, phones etc.
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
          #! clipboard management for wayland environment 
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
          #! for making clipboard persistent
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
          #! polkit authentication agent for such tasks wants root permissions
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

        ###  not really critical section ###
        mpris-proxy = {
          # media player remote interfacing specification for bluetooth devices
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
          # for torrent managament, i prefer to use qbittorrent-nox
          # TODO: should be done as homemanager service 
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
          # my friend's discord bot which i really want to get rid of
          # TODO: should be done as homemanager service
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

  sound.enable = true;

  programs = {
    hyprland.enable = true; # ! it's neccesarry for using hyprland
    zsh = { # i prefer to use zsh as my shell
      enable = true;
      ohMyZsh.enable = true; # TODO: create a nix ohmyzsh configuration
      histSize = 1000;
      autosuggestions.enable = true;
    };
    nh = { # # use nixhelper, it really helps while building new nix generations
      enable = true;
      package = pkgs.nh;
      flake = "/home/seyhan/.nixos"; # TODO: make this veriable declarative
    };
  };

  services = {
    gvfs.enable = true; # ? i'm not sure what this used for
    greetd = { # ! for auto launching hyprland on login
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
      { # ! for changing dns, DO NOT TOUCH unless you know what you're doing
        enable = true;
        dnssec = "true";
        domains = [ "~." ];
        fallbackDns = [
          "94.140.14.140"
          "94.140.14.141"
        ]; # i'm using adguard dns non-filtering
        dnsovertls = "true";
      };

    pipewire = { # ! neccesary for sound and screen sharing
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    tlp = { # ! TLP is very important on laptops for better power consumption
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
    "24.11"; # ! DONT CHANGE STATE VERSION UNLESS YOU KNOW WHAT YOU'RE DOING
}
