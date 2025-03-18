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
}

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim", opts = { ensure_installed = lsp_servers } },
	},
	init = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }

				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<leader>ac", vim.lsp.buf.code_action, opts)
			end,
		})
	end,
	config = function()
		local lspconfig = require("lspconfig")
		local util = require("lspconfig/util")

		local path = util.path

		local function get_python_path(workspace)
			-- Use activated virtualenv.
			if vim.env.VIRTUAL_ENV then
				return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
			end

			-- Find and use virtualenv in workspace directory.
			for _, pattern in ipairs({ "*", ".*" }) do
				local match = vim.fn.glob(path.join(workspace, pattern, "pyvenv.cfg"))
				if match ~= "" then
					return path.join(path.dirname(match), "bin", "python")
				end
			end

			-- Fallback to system Python.
			return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
		end

		for _, lsp in ipairs(lsp_servers) do
			lspconfig[lsp].setup({
				before_init = function(_, config)
					if lsp == "pyright" then
						config.settings.python.pythonPath = get_python_path(config.root_dir)
					end
					if lsp == "harper_ls" then
						config.settings["harper-ls"] = {
							userDictPath = vim.fn.stdpath("data") .. "/user_dict.txt",
							codeActions = {
								forceStable = true,
							},
						}
					end
				end,
				on_attach = function(client, bufnr)
					if client and client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
				end,
			})
		end
	end,
}
