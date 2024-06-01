{ pkgs, ... }:
let inherit (builtins) concatLists;
in {
  config = {
    programs = {
      home-manager.enable = true;
      git.enable = true;
      starship.enable = true;
      neovim = {
        enable = true;
        extraPackages = with pkgs; [
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
    };
    services = {
      #template
    };

    home.packages = with pkgs; [
      adwaita-qt
      adwaita-qt6
      nitch
      wireguard-tools
      qalculate-gtk
      libsForQt5.okular
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
      firefox
      hyprland
      obsidian
      alacritty
      waybar
      ueberzugpp
      swww
      prismlauncher
      (discord.override { withOpenASAR = true; })
      obs-studio
      spotify
    ];
  };
}
