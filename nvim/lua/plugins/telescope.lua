return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          prompt_prefix = ' ',
          selection_caret = ' ',
          file_ignore_patterns = {
            '.git/',
            'target/',
            'vendor/*',
            '%.lock',
            '__pycache__/*',
            '%.sqlite3',
            'node_modules/*',
            '%.jpg',
            '%.jpeg',
            '%.png',
            '%.svg',
            '%.otf',
            '%.ttf',
            '%.webp',
            '.gradle/',
            '.idea/',
            '.settings/',
            '.vscode/',
            '__pycache__/',
            'build/',
            'env/',
            'gradle/',
            'smalljre_*/*',
          },
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      }

      require("telescope").load_extension("ui-select")
    end
  }
}
