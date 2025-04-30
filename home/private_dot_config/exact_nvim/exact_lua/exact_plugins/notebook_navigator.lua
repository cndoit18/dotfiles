return {
	"GCBallesteros/NotebookNavigator.nvim",
	keys = {
		{
			"]h",
			function()
				require("notebook-navigator").move_cell("d")
			end,
		},
		{
			"[h",
			function()
				require("notebook-navigator").move_cell("u")
			end,
		},
	},
	dependencies = {
		"echasnovski/mini.comment",
		{
			"hkupty/iron.nvim", -- repl provider
			config = function()
				local iron = require("iron.core")
				iron.setup({
					config = {
						scratch_repl = true,
						repl_definition = {
							python = {
								command = { "ipython" },
								format = require("iron.fts.common").bracketed_paste,
							},
						},
						repl_open_cmd = "vertical botright 80 split",
					},
				})
			end,
		},
		-- "akinsho/toggleterm.nvim", -- alternative repl provider
		-- "benlubas/molten-nvim", -- alternative repl provider
		-- "anuvyklack/hydra.nvim",
		{ "GCBallesteros/jupytext.nvim", build = "uv tool install jupytext", config = true, lazy = false },
	},
	event = "VeryLazy",
	config = function()
		local nn = require("notebook-navigator")
		nn.setup({
			repl_provider = "iron",
			syntax_highlight = true,
			cell_highlight_group = "Folded",
		})
		vim.api.nvim_create_user_command("JupyterCreate", function(opts)
			-- 获取用户传入的参数
			local full_path = opts.args
			-- 提取文件夹路径和文件名
			local dir_path = full_path:match("(.*/)") or ""
			local file_name = full_path:match("[^/]+$")
			-- 构建要执行的命令
			local command = string.format(
				'!echo \'{"cells":[],"metadata":{"kernelspec":{"display_name":"Python 3 (ipykernel)","language":"python","name":"python3"}},"nbformat":4,"nbformat_minor":5}\' | jupyter nbconvert --to notebook --execute --stdin --output-dir=%s --output=%s',
				dir_path,
				file_name
			)
			-- 执行命令
			vim.cmd(command)
		end, { nargs = 1, complete = "file", desc = "Create a Jupyter notebook with the given path and filename" })

		vim.api.nvim_create_user_command("RunCell", function()
			nn.run_cell()
		end, {
			nargs = "?",
		})
		vim.api.nvim_create_user_command("RunCellAndMove", function()
			nn.run_and_move()
		end, {
			nargs = "?",
		})
	end,
}
