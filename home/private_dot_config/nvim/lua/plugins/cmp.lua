return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },

		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{
			"folke/lazydev.nvim",
			dependencies = {
				"Bilal2453/luvit-meta",
			},
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					"lazy.nvim",
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
	},
	init = function()
		local lspconfig = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}
		for _, lsp in ipairs(require("mason-lspconfig").get_installed_servers()) do
			lspconfig[lsp].capabilities = capabilities
		end
	end,
	config = function()
		local cmp = require("cmp")
		cmp.setup({
			mapping = {
				["<C-y>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.confirm({
							select = true,
						})
					else
						fallback()
					end
				end),

				["<C-n>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<C-p>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end, { "i", "s" }),
			},

			sources = {
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{
					name = "lazydev",
					group_index = 0, -- set group index to 0 to skip loading LuaLS completions
				},
			},
		})
		-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline({ "/", "?" }, {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{ name = "cmdline" },
			}),
			---@diagnostic disable-next-line: missing-fields
			matching = { disallow_symbol_nonprefix_matching = false },
		})
	end,
}
