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
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"milanglacier/minuet-ai.nvim",
		},
		opts = {
			extensions = {
				"lazy",
				"mason",
				"neo-tree",
				"trouble",
			},
			options = {
				theme = "gruvbox-material",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
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
			},
		},
		config = function(_, opts)
			if package.loaded["minuet"] then
				table.insert(opts.sections.lualine_x, require("minuet.lualine"))
			end
			require("lualine").setup(opts)
		end,
	},

	{
		"folke/snacks.nvim",
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = {
				notify = true,
				size = 2 * 1024 * 1024,
				line_length = 1500,
				setup = function(ctx)
					vim.schedule(function()
						vim.bo[ctx.buf].filetype = ctx.ft
					end)
					vim.cmd("LspStop")
					vim.opt.swapfile = false
					vim.opt.writebackup = false
					vim.opt.spell = false
					vim.opt.laststatus = 1
					vim.opt.foldmethod = "manual"
					local ok, cmp = pcall(require, "cmp")
					if ok then
						cmp.setup.buffer({ enabled = false })
					end
				end,
			},
			terminal = {
				win = {
					keys = {
						term_normal = false,
					},
				},
			},
			scroll = {},
			lazygit = {},
			gitbrowse = {
				url_patterns = {
					[".*"] = {
						branch = "/tree/{branch}",
						file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
						permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
						commit = "/commit/{commit}",
					},
				},
			},
		},
	},
}
