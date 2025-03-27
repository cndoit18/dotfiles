return {
	"folke/flash.nvim",
	event = "VeryLazy",
	init = function()
		vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr><esc>", { noremap = true })
	end,
	opts = {
		modes = {
			char = {
				jump_labels = true,
			},
			search = {
				enabled = false,
			},
		},
	},
}
