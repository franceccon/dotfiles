local M = {}

function M.setup()
  require('config.keymaps').setup()
  require('config.ui').setup()
  require('config.telescope').setup()
  require('config.neogit').setup()
  -- Nix's plugin directory is read-only; use CodeDiff's polling fallback.
  vim.env.CODEDIFF_WATCHER_NO_AUTO_INSTALL = '1'
  require('codediff').setup {
    keymaps = {
      view = {
        -- toggle_explorer = '<leader>b', -- Conflicts with clear highlight.
        toggle_explorer = false,
      },
    },
  }
  require('review').setup {
    keymaps = {
      -- list_comments = 'c', -- Conflicts with the existing ca / ce LSP mappings.
      list_comments = false,
    },
  }
  require('config.lsp').setup()
  require('config.whichkey').setup()
  require('config.treesitter').setup()
end

return M
