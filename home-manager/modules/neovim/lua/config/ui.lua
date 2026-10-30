local M = {}

function M.setup()
  vim.opt.termguicolors = true
  vim.opt.background = 'light'
  require('catppuccin').setup {
    flavour = "latte",
  }
  vim.cmd.colorscheme 'catppuccin-latte'

  -- show relative line numbers
  vim.opt.number = true
  vim.opt.relativenumber = true
  -- always enable mouse
  vim.opt.mouse = 'a'
  -- smartcase
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  -- cursor line
  vim.opt.cursorline = true
  -- persistent undofile
  vim.opt.undofile = true
  -- hide mode message
  vim.opt.showmode = false
  -- start with an empty buffer instead of the intro message
  vim.opt.shortmess:append('I')
  -- no wrapping
  vim.opt.wrap = false

  -- status line
  require('lualine').setup {
    options = {
      icons_enabled = false,
      theme = 'catppuccin-nvim',
      disabled_filetypes = {},
      component_separators = '|',
      section_separators = { left = '▒', right = '░'},
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'filename', 'branch' },
      lualine_c = {},
      lualine_x = {},
      lualine_y = { 'filetype', 'progress' },
      lualine_z = { 'vim.api.nvim_get_current_buf()' },
    },
    inactive_sections = {
      lualine_a = { 'filename' },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = { 'vim.api.nvim_get_current_buf()' },
    },
  }

  -- tab bar
  require('tabby.tabline').use_preset('active_wins_at_tail', {
    nerdfont = false,
  })

  -- window selector
  require('window-picker').setup {}
end

return M
