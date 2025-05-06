return {
	"jellydn/hurl.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	ft = "hurl",
	opts = {
		-- Show debugging info
		debug = false,
		-- Show notification on run
		show_notification = false,
		-- Show response in popup or split
		mode = "popup",
		-- Default mappings for the response popup or split views
		mappings = {
			close = "q", -- Close the response popup or split view
			next_panel = "<C-n>", -- Move to the next response popup window
			prev_panel = "<C-p>", -- Move to the previous response popup window
		},
	},
}
