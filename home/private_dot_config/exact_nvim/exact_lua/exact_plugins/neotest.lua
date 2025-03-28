return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-go",
			{ "rouge8/neotest-rust", build = "cargo install cargo-nextest --locked" },
		},
		opts = {
			adapters = {
				["neotest-go"] = {
					args = { "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" },
				},
				["neotest-rust"] = {},
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
			local neotest = require("neotest")
			neotest.setup(opts)

			vim.api.nvim_create_user_command("Test", function()
				neotest.run.run()
			end, {
				nargs = "?",
			})
			vim.api.nvim_create_user_command("TestFile", function()
				neotest.run.run(vim.fn.expand("%"))
			end, {
				nargs = "?",
			})

			vim.api.nvim_create_user_command("DebugTest", function()
				neotest.run.run({ strategy = "dap", suite = false })
			end, {
				nargs = "?",
			})
		end,
		cmd = {
			"Neotest",
			"Test",
			"TestFile",
			"DebugTest",
		},
	},
	{
		"mfussenegger/nvim-dap",
		config = function()
			local dap = require("dap")
			-- Go
			-- Requires:
			-- * You have initialized your module with 'go mod init module_name'.
			-- * You :cd your project before running DAP.
			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
				},
			}
			dap.adapters.go = dap.adapters.delve
			dap.configurations.go = {
				{
					type = "go",
					name = "Attach",
					request = "attach",
				},
				{
					type = "go",
					name = "Run (and debug)",
					request = "launch",
					program = "./${relativeFileDirname}",
				},
			}
			dap.adapters.codelldb = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
			}

			vim.api.nvim_create_user_command("DebugStart", function()
				dap.continue()
			end, {
				nargs = "?",
			})
			vim.api.nvim_create_user_command("DebugBreakpoint", function()
				dap.toggle_breakpoint()
			end, {
				nargs = "?",
			})
		end,
		dependencies = {
			{
				"andythigpen/nvim-coverage",
				version = "*",
				config = function()
					local cov = require("coverage")
					cov.setup({})

					local show_coverage = false
					vim.api.nvim_create_user_command("CoverageToggle", function()
						show_coverage = not show_coverage
						cov.load(show_coverage)
						if show_coverage then
							cov.show()
						else
							cov.hide()
						end
					end, {
						nargs = "?",
						desc = "Coverage Toggle",
					})
					vim.api.nvim_create_user_command("CoverageSummary", function()
						cov.load(show_coverage)
						cov.summary()
					end, {
						nargs = "?",
						desc = "Coverage Summary",
					})
				end,
			},
			{
				"rcarriga/nvim-dap-ui",
				dependencies = "nvim-neotest/nvim-nio",
				config = function(_, opts)
					local dap, dapui = require("dap"), require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						vim.cmd("Neotree close")
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end

					local dap_breakpoint = {
						error = {
							text = "🟥",
							texthl = "LspDiagnosticsSignError",
							linehl = "",
							numhl = "",
						},
						rejected = {
							text = "",
							texthl = "LspDiagnosticsSignHint",
							linehl = "",
							numhl = "",
						},
						stopped = {
							text = "⭐️",
							texthl = "LspDiagnosticsSignInformation",
							linehl = "DiagnosticUnderlineInfo",
							numhl = "LspDiagnosticsSignInformation",
						},
					}

					vim.fn.sign_define("DapBreakpoint", dap_breakpoint.error)
					vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)
					vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
				end,
			},
		},
	},
}
