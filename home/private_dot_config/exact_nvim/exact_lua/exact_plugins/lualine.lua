local function search_result()
	if vim.v.hlsearch == 0 then
		return ""
	end
	local last_search = vim.fn.getreg("/")
	if not last_search or last_search == "" then
		return ""
	end
	local searchcount = vim.fn.searchcount({ maxcount = 9999 })
	return last_search .. "(" .. searchcount.current .. "/" .. searchcount.total .. ")"
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		extensions = {
			"lazy",
		},
		options = {
			icons_enabled = true,
			theme = "gruvbox-material",
			component_separators = { left = "", right = "" },
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			always_show_tabline = true,
			globalstatus = false,
			refresh = {
				statusline = 100,
				tabline = 100,
				winbar = 100,
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff", "diagnostics" },
			lualine_c = { { "filename", file_status = false, path = 1 } },
			lualine_x = { search_result },
			lualine_y = { "encoding", "fileformat", "filetype" },
			lualine_z = { "%l:%c", "%p%%/%L" },
		},
		inactive_sections = {
			lualine_c = { "%f %y %m" },
			lualine_x = {},
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
	},
	config = function(_, opts)
		require("lualine").setup(opts)
	end,
}
