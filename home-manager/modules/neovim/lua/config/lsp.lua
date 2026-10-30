local M = {}

function M.setup()
  local cmp = require('cmp')
  require('cmp').setup {
    sources = {
      { name = 'nvim_lsp' },
    },
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm {
	select = true,
      },
    },
  }

  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  vim.lsp.config('*', {
    capabilities = capabilities,
  })
  vim.lsp.config('ts_ls', {
    root_dir = function(bufnr, on_dir)
      local deno_root = vim.fs.root(bufnr, { 'deno.json', 'deno.jsonc' })
      if not deno_root then
        local root = vim.fs.root(bufnr, { 'package.json' })
        if root then on_dir(root) end
      end
    end,
    workspace_required = true,
  })
  vim.lsp.enable { 'rust_analyzer', 'ts_ls', 'denols', 'pylsp', 'gopls', 'ocamllsp' }

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('config-lsp', { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
      end
    end,
  })
end

return M
