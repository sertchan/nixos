{ pkgs, ... }:
let username = "seyhan";
in {
  imports = [ ./packages.nix ];
  config = {
    home = {
      inherit username;
      homeDirectory = "/home/${username}";
      pointerCursor = {
        package = pkgs.gnome.adwaita-icon-theme;
        name = "Adwaita";
        size = 16;
        gtk.enable = true;
        x11.enable = true;
      };

      stateVersion = "24.11";
    };

    qt = {
      enable = true;
      style.name = "adwaita-dark";
      style.package = pkgs.adwaita-qt;
    };

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };

      font = {
        name = "Noto Sans Medium";
        size = 9.5;
      };

      gtk3.extraConfig = {
        gtk-toolbar-style = "GTK_TOOLBAR_BOTH";
        gtk-toolbar-icon-size = "GTK_ICON_SIZE_SMALL_TOOLBAR";
        gtk-decoration-layout = "appmenu:none";
        gtk-button-images = 1;
        gtk-menu-images = 1;
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-error-bell = 0;
        gtk-enable-primary-paste = false;
      };

      gtk4.extraConfig = {
        gtk-decoration-layout = "appmenu:none";
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-enable-primary-paste = false;
        gtk-error-bell = 0;
      };
    };
  };
}
