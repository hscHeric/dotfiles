require("hscheric.options")
require("lazy-config")

local opts = {}
require("lazy").setup("plugins", opts)
require("hscheric.keymaps")

vim.cmd("colorscheme kanagawa-dragon")
