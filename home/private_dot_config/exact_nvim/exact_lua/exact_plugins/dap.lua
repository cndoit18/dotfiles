return {
	{
		"mfussenegger/nvim-dap",
		keys = {
			{ "<leader>d", nil, desc = "Debug" },
			{
				"<leader>ds",
				function()
					require("dap").continue()
				end,
				desc = "Start/Continue",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>du",
				function()
					require("dapui").toggle({})
				end,
				desc = "Toggle DAP UI",
			},
		},
		config = function()
			local dap = require("dap")
			require("dap.ext.vscode").json_decode = require("json5").parse

			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/dlv",
					args = { "dap", "--check-go-version=false", "-l", "127.0.0.1:${port}" },
				},
			}
			dap.adapters.go = dap.adapters.delve

			dap.adapters.codelldb = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
			}
		end,
		dependencies = {
			{
				"Joakker/lua-json5",
				build = "./install.sh",
			},
			{
				"mr-u0b0dy/crazy-coverage.nvim",
				config = function()
					require("crazy-coverage").setup({
						hit_count = {
							display = "right_align",
						},
						show_branch_summary = true,
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
							texthl = "DiagnosticSignError",
						},
						rejected = {
							text = "",
							texthl = "DiagnosticSignHint",
						},
						stopped = {
							text = "⭐️",
							texthl = "DiagnosticSignInfo",
							linehl = "DiagnosticUnderlineInfo",
							numhl = "DiagnosticSignInfo",
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
