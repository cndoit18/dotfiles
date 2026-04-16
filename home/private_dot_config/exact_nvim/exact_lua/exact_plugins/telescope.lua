return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{
				"<leader>fg",
				function()
					require("fzf-lua").live_grep_native()
				end,
				desc = "Live Grep",
			},
		},
	},
}
