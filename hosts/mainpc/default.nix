{
  config,
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
    kernelPackages = pkgs.linuxPackages_6_6;
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
        adwaita-qt
        adwaita-qt6
        gnome.adwaita-icon-theme
        go
        grimblast
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        linuxHeaders
        mullvad-vpn
        nitch
        nodejs_20
        pipewire
        polkit_gnome
        python3
        python3Packages.pip
        qalculate-gtk
        unzip
        wireplumber
        wl-clipboard
        wl-clip-persist
        wofi
        adw-gtk3
        xdg-utils
        beautysh
        black
        btop
        alejandra
        bc
        cargo
        deno
        du-dust
        eslint_d
        ffmpeg_5-full
        gcc
        bluez
        bluez-tools
        gh
        git
        gnumake
        inotify-tools
        isort
        jq
        just
        p7zip
        mako
        prettierd
        psmisc
        ranger
        rustc
        sassc
        starship
        pulsemixer
        stylua
        taplo
        qbittorrent
        ueberzugpp
        udiskie
        waifu2x-converter-cpp
        xdotool
        yamlfix
        aria2
        zip
      ];

      unstablePackages = with pkgs; [
        firefox
        obsidian
        alacritty
        waybar
        swww
        (discord.override {withOpenASAR = true;})
        hyprland
        identity
        imagemagick
        mpv
        neovim
        gnome.eog
        obs-studio
        spotify
        stirling-pdf
      ];
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
    user = {
      services = {
        flake_autoupgrade = {
          description = "Autoupgrade flakes (Triggered by flake_autoupgrade.timer)";
          enable = true;
          path = with pkgs-stable; [bash coreutils git nix nixos-install-tools];
          serviceConfig = {
            ExecStart = pkgs-stable.writeShellScript "update-flakes" ''
              function upgrade_flakes {
                nix flake update ~/.nixos
                cd ~/.nixos || exit
                git add . && git commit -m "Upgrade Flakes $(date +"%d/%m/%Y")" && git push
              }

              function rebuild_system {
                nixos-rebuild switch --flake ~/.nixos#asli --use-remote-sudo
                nix-collect-garbage --delete-older-than 7d
              }

              upgrade_flakes
              rebuild_system
            '';
            Restart = "on-failure";
            RestartSec = 5;
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
        flake_autoupgrade = {
          description = "Autoupgrade Flakes Weekly";
          wantedBy = ["timers.target"];
          timerConfig = {
            OnActiveSec = "7d";
            Persistent = true;
            Unit = "flake_autoupgrade.service";
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
