-- lazy.nvim
return {
	"folke/snacks.nvim",
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = {
			notify = true,
			size = 2 * 1024 * 1024,
			line_length = 1500,
			setup = function()
				vim.cmd("LspStop")
				vim.treesitter.stop()
				vim.opt.swapfile = false
				vim.opt.writebackup = false
				vim.opt.spell = false
				vim.opt.laststatus = 1
				vim.opt.foldmethod = "manual"
				local ok, cmp = pcall(require, "cmp")
				if ok then
					cmp.setup.buffer({ enabled = false })
				end
			end,
		},
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
