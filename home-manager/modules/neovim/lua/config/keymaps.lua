local M = {}

function M.setup()
  vim.g.mapleader = ','

  local keymap = vim.keymap.set

  -- general
  keymap('n', '<leader>b', ':noh<CR>', { noremap = true, desc = 'Clear highlight' })
  keymap('n', '<leader>s', ':w<CR>', { noremap = true, desc = 'Save' })

  -- tabs
  keymap('n', '<leader>tn', '<cmd>tabnew<CR>', { noremap = true, silent = true, desc = 'Create new tab' })
  keymap('n', '<leader>tc', '<cmd>tabclose<CR>', { noremap = true, silent = true, desc = 'Close tab' })
  keymap('n', '<leader>to', '<cmd>tabonly<CR>', { noremap = true, silent = true, desc = 'Only tab' })
  keymap('n', '<leader>t.', '<cmd>tabn<CR>', { noremap = true, silent = true, desc = 'Next tab' })
  keymap('n', '<leader>t,', '<cmd>tabp<CR>', { noremap = true, silent = true, desc = 'Prev tab' })
  keymap('n', '<leader>t>', '<cmd>+tabmove<CR>', { noremap = true, silent = true, desc = 'Move to next tab' })
  keymap('n', '<leader>t<', '<cmd>-tabmove<CR>', { noremap = true, silent = true, desc = 'Move to prev tab' })

  -- Undotree
  keymap('n', '<leader>u', vim.cmd.UndotreeToggle, { noremap = true, silent = true, desc = 'Toggle undo tree' })

  -- Telescope
  local telescope = require('telescope.builtin')
  keymap('n', '<leader>ff', telescope.find_files, { desc = 'Telescope find files' })
  keymap('n', '<leader>fg', telescope.live_grep, { desc = 'Telescope grep' })
  keymap('n', '<leader>fh', telescope.help_tags, { desc = 'Telescope help' })
  keymap('n', '<leader>ft', '<cmd>Telescope file_browser<CR>', { desc = 'Telescope file browser' })
  keymap('n', '<leader>fb', '<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>', { desc = 'Telescope file browser (current file)' })

  -- Neogit
  local neogit = require('neogit')
  keymap('n', '<leader>ns', function() neogit.open({ kind = 'tab' }) end, { noremap = true, desc = 'Open neogit status' })
  keymap('n', '<leader>nc', function() neogit.open({ 'commit' }) end, { noremap = true, desc = 'Open neogit commit' })

  -- Review (upstream recommended bindings; leader is comma).
  keymap('n', '<leader>rr', '<cmd>Review<CR>', { desc = 'Review working tree' })
  keymap('n', '<leader>rc', '<cmd>Review commits<CR>', { desc = 'Review commits' })
  keymap('n', '<leader>rb', '<cmd>Review branch<CR>', { desc = 'Review branch' })
  keymap({ 'n', 'v' }, '<leader>rn', ':Review note<CR>', { desc = 'Review: note here' })
  keymap('n', '<leader>re', '<cmd>Review edit<CR>', { desc = 'Review: edit comment' })
  keymap('n', '<leader>rd', '<cmd>Review delete<CR>', { desc = 'Review: delete comment' })
  keymap('n', '<leader>rx', '<cmd>Review export<CR>', { desc = 'Review: export' })

  -- File browser
  keymap('n', '<leader>pv', '<cmd>Telescope file_browser<CR>', { desc = 'Browse files' })

  -- LSP
  -- Goto X
  keymap('n','gd', vim.lsp.buf.definition, { desc = 'LSP goto definition' })
  keymap('n','gD', vim.lsp.buf.declaration, { desc = 'LSP goto declaration' })
  keymap('n','gi', vim.lsp.buf.implementation, { desc = 'LSP goto implementation' })
  keymap('n', 'gh', vim.lsp.buf.references, { desc = 'LSP finder' })
  -- Code
  keymap('n', 'K', vim.lsp.buf.hover, { desc = 'LSP hover' })
  keymap('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'LSP signature help' })
  keymap({'n','v'}, 'ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })
  keymap('n', 'ce', vim.lsp.buf.rename, { desc = 'LSP rename' })
  keymap('n', '<leader>cu', function() 
    vim.lsp.buf.format { async = true }
  end, { desc = 'LSP format' })
  -- Diagnostic
  keymap('n', '[e', function() vim.diagnostic.jump { count = -1, float = true } end, { desc = 'LSP prev diagnostic' })
  keymap('n', ']e', function() vim.diagnostic.jump { count = 1, float = true } end, { desc = 'LSP next diagnostic' })

  -- window picker
  keymap('n', '<leader>w', function()
    local window = require('window-picker').pick_window()
    if window then vim.api.nvim_set_current_win(window) end
  end, { silent = true, desc = 'Jump window' })
end

return M
