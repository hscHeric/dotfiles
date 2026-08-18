return {
	-- Add gruvbox.
	{ "ellisonleao/gruvbox.nvim" },
	{
		"Mofiqul/adwaita.nvim",
		lazy = false,
		priority = 1000,
	},

	-- Configure LazyVim to load gruvbox.
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "adwaita",
		},
	},
}
