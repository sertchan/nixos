{ pkgs, ... }:
let inherit (builtins) concatLists;
in {
  config = {
    programs = {
      home-manager.enable = true;
      git.enable = true;
      firefox.enable = true;
      obs-studio.enable = true;
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
      nitch
      qalculate-gtk
      unzip
      cliphist
      wl-clip-persist
      wl-clipboard
      wofi
      xdg-utils
      btop
      bc
      du-dust
      ffmpegthumbnailer
      bluez
      bluez-tools
      inotify-tools
      isort
      jq
      ffsubsync
      ffmpeg_7-full
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
      waifu2x-converter-cpp
      xdotool
      yamlfix
      zip
      obsidian
      alacritty
      waybar
      ueberzugpp
      swww
      pulsemixer
      spotify

      #should be done with devshell
      gnumake42
      nodejs_20
      bun
      nodePackages_latest.node-gyp
      python3
      nixfmt
      gcc
    ];
  };
}
