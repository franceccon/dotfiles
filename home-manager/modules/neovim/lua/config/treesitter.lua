local M = {}

function M.setup()
  -- Parsers and queries are installed by Nix, not downloaded at runtime.
  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('config-treesitter', { clear = true }),
    pattern = {
      'c', 'lua', 'vim', 'help', 'query',
      'rust', 'markdown', 'typescript', 'typescriptreact',
      'javascript', 'javascriptreact', 'python',
      'sh', 'json', 'yaml', 'nix', 'go', 'ocaml',
    },
    callback = function(event)
      vim.treesitter.start(event.buf)
    end,
  })
end

return M
