{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.fra.programs.ghostty;
in
{
  options.fra.programs.ghostty.enable = mkEnableOption "ghostty";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.ghostty ];

    xdg.configFile."ghostty/config".text = ''
      font-family = "monospace"
      font-size = 13
      theme = "Catppuccin Latte"
      window-inherit-working-directory = false
    '';
  };
}
