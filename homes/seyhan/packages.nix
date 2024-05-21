{
  pkgs,
  pkgs-stable,
  ...
}: let
  inherit (builtins) concatLists;
in {
  home.packages = let
    stable = with pkgs; [
      adwaita-qt
      adwaita-qt6
      gnome.adwaita-icon-theme
    ];

    unstable = with pkgs-stable; [
      firefox
      hyprland
      obsidian
      alacritty
      waybar
      swww
      (discord.override {withOpenASAR = true;})
      obs-studio
      spotify
      grimblast
      nitch
      qalculate-gtk
      unzip
      wl-clipboard
      wl-clip-persist
      wofi
      xdg-utils
      btop
      alejandra
      bc
      du-dust
      ffmpeg_5-full
      bluez
      bluez-tools
      gh
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
      taplo
      qbittorrent-nox
      ueberzugpp
      udiskie
      waifu2x-converter-cpp
      xdotool
      yamlfix
      zip
    ];
  in
    # Concatenate the lists to create one package list.
    concatLists [stable unstable];
}
