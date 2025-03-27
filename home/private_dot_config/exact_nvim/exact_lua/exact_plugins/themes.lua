return {
	"sainnhe/gruvbox-material",
	init = function()
		vim.g.gruvbox_material_background = "medium" -- hard, soft, medium
		vim.g.gruvbox_material_foreground = "material" -- original, mix, material
		vim.g.gruvbox_material_enable_italic = 1
		vim.g.gruvbox_material_sign_column_background = "none"
		vim.g.gruvbox_material_enable_italic = true
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

		vim.o.number = true
		vim.o.relativenumber = true
		vim.o.cursorline = true

		vim.o.list = true
		vim.o.listchars = [[tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%]]

		local augroup = vim.api.nvim_create_augroup("numbertoggle", {})

		vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "CmdlineLeave", "WinEnter" }, {
			pattern = "*",
			group = augroup,
			callback = function()
				if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
					vim.opt.relativenumber = true
				end
			end,
		})

		vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "CmdlineEnter", "WinLeave" }, {
			pattern = "*",
			group = augroup,
			callback = function()
				if vim.o.nu then
					vim.opt.relativenumber = false
					vim.cmd("redraw")
				end
			end,
		})

		-- Optionally configure and load the colorscheme
		-- directly inside the plugin declaration.
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
