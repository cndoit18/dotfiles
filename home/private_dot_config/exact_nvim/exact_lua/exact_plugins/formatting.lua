return {
	"mhartington/formatter.nvim",
	lazy = false,
	keys = {
		{
			"<leader>F",
			function()
				vim.g.enable_autoformat = not vim.g.enable_autoformat
				print("autoformat is " .. (vim.g.enable_autoformat and "on" or "off"))
			end,
			desc = "Toggle Autoformat",
		},
	},
	config = function()
		local prettier = require("formatter.defaults").prettier
		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = { require("formatter.filetypes.lua").stylua },
				sql = {
					{
						exe = "sqlfluff",
						args = {
							"format",
							"--disable-progress-bar",
							"--nocolor",
							"--dialect=postgres",
							"-",
						},
						stdin = true,
						ignore_exitcode = false,
					},
				},
				sh = { require("formatter.filetypes.sh").shfmt },
				python = { require("formatter.filetypes.python").ruff },
				go = { require("formatter.filetypes.go").gofumpt },
				rust = { require("formatter.filetypes.rust").rustfmt },

				glsl = { prettier },
				svelte = { prettier },
				javascript = { prettier },
				javascriptreact = { prettier },
				typescript = { prettier },
				typescriptreact = { prettier },
				astro = { prettier },
				vue = { prettier },
				css = { prettier },
				scss = { prettier },
				less = { prettier },
				html = { prettier },
				json = { prettier },
				jsonc = { prettier },
				yaml = { prettier },
				markdown = { prettier },
				graphql = { prettier },
				handlebars = { prettier },
				svg = { prettier },

				["*"] = {
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})

		vim.g.enable_autoformat = 1
		local format_augroup = vim.api.nvim_create_augroup("formatter", { clear = true })
		vim.api.nvim_create_autocmd({
			"BufWritePost",
		}, {
			group = format_augroup,
			command = "if get(g:,'enable_autoformat', 1) | :FormatWrite | endif",
		})
	end,
}
