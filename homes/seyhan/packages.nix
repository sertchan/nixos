{
  pkgs,
  pkgs-stable,
  ...
}: let
  inherit (builtins) concatLists;
in {
  config = {
    programs = {
      home-manager.enable = true;
      git.enable = true;
      starship.enable = true;
      neovim = {
        enable = true;
        extraPackages = with pkgs-stable; [
          alejandra
          stylua
          beautysh
          taplo
          rustfmt
          prettierd
          yamlfix
          jq
        ];
      };
    };
    home.packages = let
      stable = with pkgs-stable; [
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
        ueberzugpp
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
        swappy
        swww
        (discord.override {withOpenASAR = true;})
        obs-studio
        spotify
      ];
    in
      # Concatenate the lists to create one package list.
      concatLists [stable unstable];
  };
}
