return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	branch = "main",
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
		}

		for _, parser in ipairs(parsers) do
			if not ts.get_installed(parser) then
				pcall(ts.install, parser)
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})
	end,
}
