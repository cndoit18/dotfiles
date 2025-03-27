return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lualine/lualine.nvim",
	},
	opts = {
		current_line_blame = true,
	},
}
