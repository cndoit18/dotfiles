local lsp_servers = {
	"rust_analyzer",
	"bashls",
	"dockerls",
	"jsonls",
	"gopls",
	"helm_ls",
	"pyright",
	"lua_ls",
	"yamlls",
	"harper_ls",
	"sqls",
	"ts_ls",
	"thriftls",
}

return {
	{
		"mason-org/mason.nvim",
		config = function()
			local tools = {
				-- Formatter
				"delve",
				"stylua",
				"sqlfluff",
				"shfmt",
				"gofumpt",
				"prettier",

				-- Lint
				"markdownlint",
				"golangci-lint",

				-- All
				"ruff",
				"codelldb",
			}
			require("mason").setup()
			local registry = require("mason-registry")
			local function install_ensured()
				for _, tool in ipairs(tools) do
					local p = registry.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if registry.refresh then
				registry.refresh(install_ensured)
			else
				install_ensured()
			end
		end,
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			{ "mason-org/mason.nvim" },
			{ "mason-org/mason-lspconfig.nvim", opts = { ensure_installed = lsp_servers } },
		},
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local b = { buffer = ev.buf }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("keep", { desc = "Hover" }, b))
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("keep", { desc = "Go to definition" }, b))
					vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("keep", { desc = "Go to type definition" }, b))
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("keep", { desc = "Go to implementation" }, b))
					vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("keep", { desc = "Go to references" }, b))
					vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, vim.tbl_extend("keep", { desc = "Code action" }, b))
				end,
			})
		end,
		config = function()
			local util = require("lspconfig/util")
			local path = util.path

			local function get_python_path(workspace)
				if vim.env.VIRTUAL_ENV then
					return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
				end
				for _, pattern in ipairs({ "*", ".*" }) do
					local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
					if match ~= "" then
						return path.join(path.dirname(match), "bin", "python")
					end
				end
				return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
			end

			for _, lsp in ipairs(lsp_servers) do
				local config = {
					settings = {},
					on_attach = function(client, bufnr)
						if client and client.server_capabilities.inlayHintProvider then
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end
					end,
				}
				if lsp == "pyright" then
					config.before_init = function(_, c)
						if c.root_dir then
							c.settings.python.pythonPath = get_python_path(c.root_dir)
						end
					end
				end
				if lsp == "harper_ls" then
					config.settings["harper-ls"] = {
						userDictPath = vim.fn.stdpath("data") .. "/user_dict.txt",
						codeActions = {
							forceStable = true,
						},
					}
				end
				vim.lsp.config(lsp, config)
			end
		end,
	},

	-- Diagnostics/problems list
	{
		"folke/trouble.nvim",
		dependencies = {
			"nvim-web-devicons",
			"nvim-telescope/telescope.nvim",
		},
		cmd = { "Trouble" },
		opts = {
			auto_preview = false,
			modes = {
				preview_diagnostics = {
					mode = "diagnostics",
					preview = {
						type = "split",
						relative = "win",
						position = "right",
						size = 0.3,
					},
				},
			},
		},
		keys = {
			{
				"[g",
				function()
					vim.diagnostic.goto_prev({
						severity = {
							min = vim.diagnostic.severity.WARN,
							max = vim.diagnostic.severity.ERROR,
						},
					})
				end,
				desc = "Previous diagnostic",
			},
			{
				"]g",
				function()
					vim.diagnostic.get_next({
						severity = {
							min = vim.diagnostic.severity.WARN,
							max = vim.diagnostic.severity.ERROR,
						},
					})
				end,
				desc = "Next diagnostic",
			},
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>", desc = "Diagnostics (Trouble)" },
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{ "<leader>ls", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
			{
				"<leader>lS",
				"<cmd>Trouble lsp toggle<cr>",
				desc = "LSP references/definitions",
			},
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						---@diagnostic disable-next-line: missing-parameter,missing-fields
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						---@diagnostic disable-next-line: missing-parameter,missing-fields
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},

	-- Linting
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				markdown = { "markdownlint" },
				go = { "golangcilint" },
				rust = { "clippy" },
				python = { "ruff" },
			}
			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					require("lint").try_lint()
				end,
			})
		end,
	},
}
