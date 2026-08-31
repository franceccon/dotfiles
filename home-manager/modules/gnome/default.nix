{ config, pkgs, lib, ... }:
with lib;
with lib.hm.gvariant;
let
  cfg = config.fra.programs.gnome;
in
{
  options.fra.programs.gnome.enable = mkEnableOption "gnome";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnomeExtensions.vitals
      gnomeExtensions.tiling-shell
    ];

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        sources = [
          (mkTuple [ "xkb" "us+dvorak" ])
          (mkTuple [ "xkb" "us" ])
          (mkTuple [ "ibus" "libpinyin" ])
        ];
      };

      "org/gnome/desktop/interface" = {
        monospace-font-name = "Monospace 14";
        font-name = "Noto Sans Medium 11 @wght=500";
        document-font-name = "Noto Sans Medium 11 @wght=500";
        color-scheme = "prefer-light";
        accent-color = "pink";
      };

      "org/gnome/desktop/wm/preferences" = {
        titlebar-font = "Noto Sans Bold 11";
        num-workspaces = 10;
        focus-mode = "mouse";
      };

      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          "Vitals@CoreCoding.com"
          "tilingshell@ferrarodomenico.com"
        ];
        favorite-apps = [
          "com.mitchellh.ghostty.desktop"
          "qalculate-gtk.desktop"
          "it.mijorus.smile.desktop"
        ];
      };

      # Shortcuts
      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Super>w" ];
        minimize = [ ];
        maximize = [ "<Super>m" ];
        unmaximize = [ "<Super><Shift>m" ];
        move-to-monitor-down = [ ];
        move-to-monitor-left = [ ];
        move-to-monitor-right = [ ];
        move-to-monitor-up = [ ];
        move-to-workspace-left = [ ];
        move-to-workspace-right = [ ];
        switch-to-workspace-left = [ ];
        switch-to-workspace-right = [ ];
        move-to-workspace-1 = [ "<Shift><Super>1" ];
        move-to-workspace-2 = [ "<Shift><Super>2" ];
        move-to-workspace-3 = [ "<Shift><Super>3" ];
        move-to-workspace-4 = [ "<Shift><Super>4" ];
        move-to-workspace-5 = [ "<Super><Shift>5" ];
        move-to-workspace-6 = [ "<Super><Shift>6" ];
        move-to-workspace-7 = [ "<Super><Shift>7" ];
        move-to-workspace-8 = [ "<Super><Shift>8" ];
        move-to-workspace-9 = [ "<Super><Shift>9" ];
        move-to-workspace-10 = [ "<Super><Shift>0" ];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-5 = [ "<Super>5" ];
        switch-to-workspace-6 = [ "<Super>6" ];
        switch-to-workspace-7 = [ "<Super>7" ];
        switch-to-workspace-8 = [ "<Super>8" ];
        switch-to-workspace-9 = [ "<Super>9" ];
        switch-to-workspace-10 = [ "<Super>0" ];
      };

      "org/gnome/shell/keybindings" = {
        toggle-overview = [ "<Super>e" ];
        toggle-application-view = [ ];
        toggle-message-tray = [ ];
        toggle-quick-settings = [ ];
        focus-active-notification = [ ];
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
      };

      "org/gnome/mutter" = {
        overlay-key = "Super_R";
        dynamic-workspaces = false;
      };

      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ ];
        toggle-tiled-right = [ ];
        switch-monitor = [ ];
      };

      "org/gnome/mutter/wayland/keybindings" = {
        restore-shortcuts = [ ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super><Shift>t";
        command = "ghostty";
        name = "term";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super><Shift>n";
        command = "${pkgs.obsidian}/bin/obsidian";
        name = "obsidian";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        screensaver = [ ];
        screenreader = [ ];
        magnifier = [ ];
        magnifier-zoom-in = [ ];
        magnifier-zoom-out = [ ];
        help = [ ];
      };

      "it/mijorus/smile" = {
        iconify-on-esc = true;
        load-hidden-on-startup = true;
      };

      "org/gnome/desktop/break-reminders" = {
        selected-breaks = [ ];
      };

      "org/gnome/desktop/break-reminders/movement" = {
        play-sound = true;
      };

      "org/gnome/desktop/break-reminders/eyesight" = {
        play-sound = true;
      };

      "com/github/libpinyin/ibus-libpinyin/libpinyin" = {
        enable-cloud-input = true;
      };
    };
  };
}
