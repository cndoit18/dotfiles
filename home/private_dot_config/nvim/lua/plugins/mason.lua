return {
	"williamboman/mason.nvim",
	dependencies = {
		{ "nvim-lualine/lualine.nvim" },
	},
	init = function()
		table.insert(require("lualine").get_config().extensions, "mason")
	end,
	config = function()
		local tools = {
			-- Formatter
			"delve",
			"stylua",
			"sqlfmt",
			"shfmt",
			"gofumpt",
			"prettier",

			-- Lint
			"markdownlint",
			"golangci-lint",

			-- All
			"ruff",
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
}
