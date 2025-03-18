return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	init = function()
		vim.api.nvim_create_user_command("Rg", function(opts)
			require("fzf-lua").live_grep_native({ search = opts.args })
		end, {
			nargs = "?",
			desc = "Grep for text in files.",
		})
	end,
}
