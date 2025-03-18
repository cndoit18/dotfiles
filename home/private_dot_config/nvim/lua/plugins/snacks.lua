-- lazy.nvim
return {
	"folke/snacks.nvim",
	lazy = false,
	---@type snacks.Config
	opts = {
		scroll = {},
		lazygit = {},
		terminal = {},
	},
	keys = {
		{
			"<leader>lg",
			function()
				require("snacks").lazygit()
			end,
			desc = "LazyGit",
		},
		{
			"<leader><C-t>",
			function()
				require("snacks").terminal.toggle()
			end,
			desc = "Toggle terminal",
		},
	},
}
