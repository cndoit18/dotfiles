return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	init = function()
		require("nvim-treesitter.query_predicates")
	end,
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"cmake",
				"css",
				"dockerfile",
				"go",
				"html",
				"java",
				"javascript",
				"json",
				"jsonc",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"regex",
				"toml",
				"vim",
				"yaml",
				"rust",
			},
			highlight = {
				enable = true,
			},
			endwise = {
				enable = true,
			},
			indent = { enable = true },
			autopairs = { enable = true },
		})
	end,
}
