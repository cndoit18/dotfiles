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
	},
	event = "VeryLazy",
	config = function()
		local nn = require("notebook-navigator")
		nn.setup({})

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
