return {
	"sainnhe/gruvbox-material",
	init = function()
		vim.g.gruvbox_material_background = "medium" -- hard, soft, medium
		vim.g.gruvbox_material_foreground = "material" -- original, mix, material
		vim.g.gruvbox_material_enable_italic = 1
		vim.g.gruvbox_material_sign_column_background = "none"
		local grpid = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {})
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = grpid,
			pattern = "gruvbox-material",
			command = [[
				hi CursorLineNr                       guifg=#d8a657 |
				hi LineNrAbove                        guifg=#765c3d |
				hi LineNrBelow                        guifg=#88481e |
				]],
		})
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
