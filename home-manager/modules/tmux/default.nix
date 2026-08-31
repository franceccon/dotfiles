{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.fra.programs.tmux;
in
{
  options.fra.programs.tmux.enable = mkEnableOption "tmux";

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-h";
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.yank;
        }
      ];
      extraConfig = ''
        bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
        set-option -g default-terminal "screen-256color"

        set-option -g status-position top
        set-option -g status-style bg=default,fg=#4c4f69
        set-option -g status-justify absolute-centre
        set-option -g status-left ""
        set-option -g status-right ""

        set-option -g message-style bg=#1e66f5,fg=#eff1f5

        set-window-option -g window-status-current-style fg=#1e66f5
        set-window-option -g mouse on
      '';
    };
  };
}

