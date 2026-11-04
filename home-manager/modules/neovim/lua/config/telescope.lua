local M = {}

function M.setup()
  require('telescope').setup {
    extensions = {
      fzf = {
        fuzzy = true;
        case_mode = 'smart_case',
      },
      file_browser = {
        hijack_netrw = false,
        dir_icon = "○",
      },
    },
  }

  require('telescope').load_extension('fzf')
  require('telescope').load_extension('file_browser')
end

return M
