{
  config,
  lib,
  pkgs,
  pkgs-stable,
  ...
}: {
  imports = [
    ./system.nix
  ];

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
    extraGroups = ["wheel" "networkmanager"];
  };

  networking = {
    hostName = "asli";
    nameservers = ["94.140.14.140" "94.140.14.141"];
    networkmanager.enable = true;
    wg-quick.interfaces = let
      server_ip = "146.70.124.194";
    in {
      wg0 = {
        address = [
          "10.66.208.166/32"
          "fc00:bbbb:bbbb:bb01::3:d0a5/128"
        ];
        dns = ["10.64.0.1"];
        listenPort = 51820;
        privateKeyFile = "/etc/mullvad-vpn.key";
        peers = [
          {
            publicKey = "Ekc3+qU88FuMfkEMyLlgRqDYv+WHJvUsfOMI/C0ydE4=";
            allowedIPs = ["0.0.0.0/0" "::0/0"];
            endpoint = "${server_ip}:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  security = {
    sudo.extraRules = [
      {
        users = ["seyhan"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
    polkit.enable = true;
    rtkit.enable = true;
  };

  time.timeZone = "Europe/Istanbul";

  nix = {
    settings.auto-optimise-store = true;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  nixpkgs = {
    config = {
      packageOverrides = pkgs-stable: {
        intel-vaapi-driver = pkgs-stable.intel-vaapi-driver.override {enableHybridCodec = true;};
      };
      allowUnfree = true;
    };
  };

  environment = {
    systemPackages = let
      stablePackages = with pkgs-stable; [
        curl
        wget
        pciutils
        lshw
        man-pages
        rsync
        bind.dnsutils
      ];
      unstablePackages = [];
    in
      stablePackages ++ unstablePackages;

    sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };
  };

  fonts.packages = with pkgs-stable; [
    noto-fonts-cjk
    (nerdfonts.override {fonts = ["JetBrainsMono"];})
  ];

  systemd = {
    services = {
      wg-quick-wg0.wantedBy = lib.mkForce [];
    };
    user = {
      services = {
        flake_autoupdate = {
          description = "Autoupdate flakes (Triggered by flake_autoupdate.timer)";
          enable = true;
          path = with pkgs-stable; [bash coreutils git nix nixos-install-tools];
          serviceConfig = {
            ExecStart = pkgs-stable.writeShellScript "update-flakes" ''
              function update_flakes {
                nix flake update ~/.nixos
                cd ~/.nixos || exit
                git add . && git commit -m "flake.nix: update flakes" && git push
              }

              function rebuild_system {
                nixos-rebuild switch --flake ~/.nixos#asli --use-remote-sudo
                nix-collect-garbage --delete-older-than 21d
              }

              update_flakes
              rebuild_system
            '';
            Restart = "on-failure";
            RestartSec = 5;
          };
        };
        qbittorrent-nox = {
          description = "Autostarts Qbittorrent-nox";
          enable = true;
          wants = ["network-online.target"];
          after = ["local-fs.target" "network-online.target" "nss-lookup.target"];
          wantedBy = ["default.target"];
          serviceConfig = {
            ExecStart = "${pkgs-stable.qbittorrent-nox}/bin/qbittorrent-nox";
            Restart = "on-failure";
            RestartSec = 30;
          };
        };
        polkit-gnome-authentication-agent-1 = {
          description = "Polkit authentication agent for GNOME (graphical)";
          wantedBy = ["graphical-session.target"];
          after = ["graphical-session.target"];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs-stable.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
        mpris-proxy = {
          description = "MPRIS Proxy for Bluetooth devices";
          after = ["network.target" "sound.target"];
          wantedBy = ["default.target"];
          serviceConfig = {
            ExecStart = "${pkgs-stable.bluez}/bin/mpris-proxy";
          };
        };
      };
      timers = {
        flake_autoupdate = {
          description = "Autoupdate flakes weekly";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnActiveSec = "7d";
            Persistent = true;
            Unit = "flake_autoupdate.service";
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
  };

  services = {
    gvfs.enable = true;
    mullvad-vpn.enable = true;

    resolved = {
      enable = true;
      dnssec = "true";
      domains = ["~."];
      fallbackDns = ["94.140.14.140" "94.140.14.141"];
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
