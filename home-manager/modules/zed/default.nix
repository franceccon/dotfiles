{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.fra.programs.zed;
in
{
  options.fra.programs.zed.enable = mkEnableOption "zed";

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.zed-editor-fhs;
      extensions = [
        "nix"
        "catppuccin"
        "toml"
      ];
      userSettings = {
        cli_default_open_behavior = "new_window";
        project_panel.dock = "left";
        outline_panel.dock = "left";
        collaboration_panel.dock = "left";
        git_panel.dock = "left";
        terminal.dock = "right";
        icon_theme = "Zed (Default)";
        vim_mode = true;
        ui_font_size = 17;
        buffer_font_size = 17;
        buffer_line_height = "standard";
        ui_font_family = "Berkeley Mono";
        buffer_font_family = "Berkeley Mono";
        buffer_font_weight = 200;
        buffer_font_features = {
          calt = false;
          cv14 = true;
        };
        auto_update = false;
        theme = {
          mode = "light";
          light = "Catppuccin Latte";
          dark = "Catppuccin Latte";
        };
        edit_predictions = {
          provider = "zed";
          mode = "eager";
        };
        agent_servers.OpenCode = {
          type = "custom";
          command = "opencode";
          args = [ "acp" ];
        };
      };
    };
  };
}
