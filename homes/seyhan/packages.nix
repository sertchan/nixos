{ pkgs, ... }:
let inherit (builtins) concatLists;
in {
  config = {
    programs = {
      home-manager.enable = true;
      git.enable = true;
      firefox.enable = true;
      vscode.enable = true;
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

    home.packages = with pkgs; [
      adwaita-qt
      adwaita-qt6
      nitch
      qalculate-gtk
      unzip
      wl-clipboard
      wl-clip-persist
      wofi
      xdg-utils
      btop
      bc
      du-dust
      ffmpeg_7-full
      ffmpegthumbnailer
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
      xdragon
      identity
      gnome.eog
      mpv
      imagemagick
      grimblast
      qbittorrent-nox
      udiskie
      nixfmt
      nixpkgs-fmt
      waifu2x-converter-cpp
      xdotool
      yamlfix
      zip
      brave
      obsidian
      alacritty
      waybar
      ueberzugpp
      swww
      pulsemixer
      prismlauncher
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      obs-studio
      spotify
    ];
  };
}
