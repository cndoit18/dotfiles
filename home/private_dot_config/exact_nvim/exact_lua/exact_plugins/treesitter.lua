return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = "main",
	lazy = false,
	config = function()
		local ts = require("nvim-treesitter")

		local parsers = {
			"bash",
			"cmake",
			"css",
			"dockerfile",
			"go",
			"html",
			"java",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"regex",
			"toml",
			"vim",
			"yaml",
			"rust",
			"hurl",
			"zsh",
			"helm",
			"gotmpl",
			"sql",
		}
		ts.install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
