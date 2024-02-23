local opts = { noremap = true, silent = true}
local builtin = require('telescope.builtin')

--Split de janelas
vim.keymap.set('n', 'ss', ':split<cr>', opts) -- Horizontal
vim.keymap.set('n', 'sv', ':vsplit<cr>', opts) -- Vertical

-- Navegação entre janelas
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Tamanho das janelas
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Nvimtree
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<cr>')

-- Telescope
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

--Edição
vim.keymap.set("i", "jk", "<ESC>", opts) -- Retornar ao normal mode sem esc
vim.keymap.set("i", "kj", "<ESC>", opts) -- Retornar ao normal mode sem esc

