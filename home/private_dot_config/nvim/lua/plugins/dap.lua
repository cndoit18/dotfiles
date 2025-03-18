return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "<leader>d", "", desc = "+Debug" },
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle Breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Continue",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step Into",
		},
		{
			"<leader>dn",
			function()
				require("dap").step_over()
			end,
			desc = "Step Over",
		},
		{
			"<leader>do",
			function()
				require("dap").step_out()
			end,
			desc = "Step Out",
		},
		{
			"<leader>du",
			function()
				require("dap").up()
			end,
			desc = "Up",
		},
		{
			"<leader>dr",
			function()
				require("dap").repl.toggle()
			end,
			desc = "Toggle REPL",
		},
		{
			"<leader>ds",
			function()
				require("dap").continue()
			end,
			desc = "Run",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to Cursor",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Run Last",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>dK",
			function()
				require("dap.ui.widgets").hover()
			end,
			desc = "Widgets",
		},
	},
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
		dap.configurations.go = {
			{
				type = "delve",
				name = "Compile module and debug this file",
				request = "launch",
				program = "./${relativeFileDirname}",
			},
			{
				type = "delve",
				name = "Compile module and debug this file (test)",
				request = "launch",
				mode = "test",
				program = "./${relativeFileDirname}",
			},
		}
	end,
	dependencies = {
		{
			"rcarriga/nvim-dap-ui",
			dependencies = "nvim-neotest/nvim-nio",
			keys = {
				{
					"<leader>du",
					function()
						require("dapui").toggle({})
					end,
					desc = "Dap UI",
				},
				{
					"<leader>dE",
					function()
						require("dapui").eval()
					end,
					desc = "Eval",
					mode = { "n", "v" },
				},
			},
			config = function(_, opts)
				local dap, dapui = require("dap"), require("dapui")
				dapui.setup(opts)
				dap.listeners.after.event_initialized["dapui_config"] = function()
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
}
