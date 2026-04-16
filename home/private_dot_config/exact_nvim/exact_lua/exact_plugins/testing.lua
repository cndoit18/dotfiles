return {
	"nvim-neotest/neotest",
	event = "LspAttach",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "fredrikaverpil/neotest-golang", dependencies = { "leoluz/nvim-dap-go" } },
		{ "rouge8/neotest-rust", build = "cargo install cargo-nextest --locked" },
	},
	opts = {
		adapters = {
			["neotest-golang"] = {
				go_test_args = {
					"-v",
					"-gcflags=all=-N -l",
					"-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
				},
				warn_test_name_dupes = false,
			},
			["neotest-rust"] = {},
		},
	},
	keys = {
		{
			"<leader>tt",
			function()
				require("neotest").run.run()
			end,
			desc = "Run Nearest",
		},
		{
			"<leader>tf",
			function()
				require("neotest").run.run(vim.fn.expand("%"))
			end,
			desc = "Run File",
		},
		{
			"<leader>td",
			function()
				require("neotest").run.run({ strategy = "dap", suite = false })
			end,
			desc = "Debug Nearest",
		},
	},
	config = function(_, opts)
		if opts.adapters then
			local adapters = {}
			for name, config in pairs(opts.adapters or {}) do
				if type(name) == "number" then
					if type(config) == "string" then
						config = require(config)
					end
					adapters[#adapters + 1] = config
				elseif config ~= false then
					local adapter = require(name)
					if type(config) == "table" and not vim.tbl_isempty(config) then
						local meta = getmetatable(adapter)
						if adapter.setup then
							adapter.setup(config)
						elseif meta and meta.__call then
							adapter(config)
						else
							error("Adapter " .. name .. " does not support setup")
						end
					end
					adapters[#adapters + 1] = adapter
				end
			end
			opts.adapters = adapters
		end
		require("neotest").setup(opts)
	end,
}
