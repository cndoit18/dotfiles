return {
	"debugloop/telescope-undo.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
	init = function()
		local undodir = vim.fn.stdpath("data") .. "/undodir"
		local handle = io.open(undodir)
		if handle then
			handle:close()
		else
			os.execute("mkdir -p " .. undodir)
		end
		vim.opt.undodir = undodir
		vim.opt.undofile = true
	end,
	config = function()
		require("telescope").load_extension("undo")
		-- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
	end,
}
