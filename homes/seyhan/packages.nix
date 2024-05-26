{ pkgs, pkgs-stable, ... }:
let inherit (builtins) concatLists;
in {
  config = {
    programs = {
      home-manager.enable = true;
      git.enable = true;
      starship.enable = true;
      neovim = {
        enable = true;
        extraPackages = with pkgs-stable; [
          stylua
          beautysh
          taplo
          rustfmt
          prettierd
          yamlfix
          alejandra
          nixfmt
          nixpkgs-fmt
          nodePackages.fixjson
          gcc
        ];
      };
      gpg = {
        enable = true;
        homedir = "home/seyhan/gnupg";
        settings = {
          keyserver = "hkps://keys.openpgp.org";
          personal-cipher-preferences = "AES256 AES192 AES";
          personal-digest-preferences = "SHA512 SHA384 SHA256";
          personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
          default-preference-list =
            "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
          cert-digest-algo = "SHA512";
          s2k-digest-algo = "SHA512";
          s2k-cipher-algo = "AES256";
          charset = "utf-8";
          fixed-list-mode = "";
          no-comments = "";
          no-emit-version = "";
          no-greeting = "";
          keyid-format = "0xlong";
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          with-fingerprint = "";
          require-cross-certification = "";
          no-symkey-cache = "";
          use-agent = "";
        };
        scdaemonSettings = { deny-admin = true; };
      };
    };
    home.packages =
      let
        stable = with pkgs-stable; [
          adwaita-qt
          adwaita-qt6
          nitch
          wireguard-tools
          qalculate-gtk
          libsForQt5.okular
          pinentry-curses
          unzip
          wl-clipboard
          wl-clip-persist
          wofi
          xdg-utils
          btop
          bc
          du-dust
          ffmpeg_5-full
          bluez
          bluez-tools
          inotify-tools
          isort
          jq
          just
          p7zip
          mako
          psmisc
          ranger
          identity
          gnome.eog
          mpv
          imagemagick
          grimblast
          qbittorrent-nox
          udiskie
          waifu2x-converter-cpp
          xdotool
          yamlfix
          zip
        ];

        unstable = with pkgs; [
          firefox
          hyprland
          obsidian
          alacritty
          waybar
          ueberzugpp
          swww
          (discord.override { withOpenASAR = true; })
          obs-studio
          spotify
        ];
      in
      concatLists [ stable unstable ];
  };
}
