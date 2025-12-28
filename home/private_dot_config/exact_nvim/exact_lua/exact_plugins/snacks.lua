-- lazy.nvim
return {
	"folke/snacks.nvim",
	lazy = false,
	---@type snacks.Config
	opts = {
		scroll = {},
		lazygit = {},
		gitbrowse = {
			url_patterns = {
				[".*"] = {
					branch = "/tree/{branch}",
					file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
					permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
					commit = "/commit/{commit}",
				},
			},
		},
	},
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
			"<leader>lg",
			function()
				require("snacks").lazygit()
			end,
			desc = "LazyGit",
		},
	},
}
