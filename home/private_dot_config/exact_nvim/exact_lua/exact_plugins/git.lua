return {
	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
		},
	},

	{ "sindrets/diffview.nvim" },

	{
		"folke/snacks.nvim",
		keys = {
			{
				"<leader>go",
				function()
					require("snacks").gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "v" },
			},
			{
				"<leader>gg",
				function()
					require("snacks").lazygit()
				end,
				desc = "LazyGit",
			},
		},
	},
}
