return {
	"uga-rosa/translate.nvim",
	--+ brew install translate-shell
	cmd = { "Translate" },
	opts = {
		default = {
			command = "translate_shell",
		},
	},
	keys = {
		{ "<leader>t", ":'<,'>Translate zh-CN -comment<cr>", mode = "v", desc = "Translate" },
	},
}
