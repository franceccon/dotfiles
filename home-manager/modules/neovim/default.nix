{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.fra.programs.neovim;
  # review.nvim needs the current CodeDiff API, newer than this nixpkgs pin.
  codediff = pkgs.vimPlugins.codediff-nvim.overrideAttrs {
    name = "vimplugin-codediff.nvim-4.0.6";
    version = "4.0.6";
    src = pkgs.fetchFromGitHub {
      owner = "esmuellert";
      repo = "codediff.nvim";
      tag = "v4.0.6";
      hash = "sha256-7jJrPKEhJup9p0GJhb3W0NvIPpOOzwqcDRKj9/qaOkc=";
    };
  };
  review = pkgs.vimUtils.buildVimPlugin {
    pname = "review.nvim";
    version = "1.12.0";
    src = pkgs.fetchFromGitHub {
      owner = "georgeguimaraes";
      repo = "review.nvim";
      tag = "v1.12.0";
      hash = "sha256-Rjqbcp7LS/LD2D3sctJrMytbYeO1fjtArQBAxo0g0L4=";
    };
    dependencies = [ codediff pkgs.vimPlugins.nui-nvim ];
  };
in
{
  options.fra.programs.neovim.enable = mkEnableOption "neovim";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Search tools used by Telescope.
      ripgrep
      fd

      # Other language servers can come from project development shells.
      rust-analyzer
      rustc
    ];

    # Keep legacy Packer files from loading alongside the Nix-managed plugins.
    home.activation.backupNeovimPacker = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      backup="${config.xdg.dataHome}/nvim/packer-backup"
      plugins="${config.xdg.dataHome}/nvim/site/pack/packer"
      loader="${config.xdg.configHome}/nvim/plugin/packer_compiled.lua"
      if [ -d "$plugins" ] || [ -f "$loader" ]; then
        run mkdir -p "$backup"
        if [ -d "$plugins" ]; then
          run mv -T --backup=numbered "$plugins" "$backup/plugins"
        fi
        if [ -f "$loader" ]; then
          run mv -T --backup=numbered "$loader" "$backup/packer_compiled.lua"
        fi
      fi
    '';

    programs.neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withPython3 = true;
      withRuby = false;

      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        lualine-nvim
        tabby-nvim
        plenary-nvim
        telescope-nvim
        telescope-fzf-native-nvim
        telescope-file-browser-nvim
        neo-tree-nvim
        neogit
        gitsigns-nvim
        diffview-nvim
        review
        which-key-nvim
        nvim-window-picker
        undotree
        nvim-lspconfig
        cmp-nvim-lsp
        nvim-cmp
        vim-vsnip
        (nvim-treesitter.withPlugins (grammars: with grammars; [
          c
          lua
          vim
          vimdoc
          query
          rust
          markdown
          markdown_inline
          typescript
          tsx
          javascript
          python
          bash
          json
          yaml
          nix
          go
          ocaml
        ]))
      ];

      extraConfig = ''
        lua require('config').setup()
      '';
    };

    home.file = {
      ".config/nvim/lua" = {
        recursive = true;
        source = ./lua;
        target = ".config/nvim/lua";
      };
      ".config/nvim/after" = {
        recursive = true;
        source = ./after;
        target = ".config/nvim/after";
      };
    };
  };
}
