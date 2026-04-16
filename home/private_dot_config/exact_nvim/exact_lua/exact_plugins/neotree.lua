return {
	"nvim-neo-tree/neo-tree.nvim",
	lazy = false,
	branch = "v3.x",
	cmd = "Neotree",
	keys = {
		{ "<leader>n", nil, desc = "Neo-tree" },
		{ "<leader>nt", [[:Neotree toggle<CR>]], desc = "Toggle file tree" },
		{ "<leader>nf", [[:Neotree focus<CR>]], desc = "Focus file tree" },
	},
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "MunifTanjim/nui.nvim" },
		{
			"s1n7ax/nvim-window-picker",
			lazy = true,
			opts = {
				filter_rules = {
					bo = {
						filetype = {
							"neo-tree",
							"neo-tree-popup",
							"notify",
							"packer",
							"qf",
							"diff",
							"fugitive",
							"fugitiveblame",
						},
						buftype = { "nofile", "help", "terminal" },
					},
				},
			},
		},
	},
	opts = {
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function()
					vim.cmd([[setlocal relativenumber]])
				end,
			},
			{
				event = "neo_tree_window_after_open",
				handler = function(args)
					if args.position == "left" or args.position == "right" then
						vim.cmd("wincmd =")
					end
				end,
			},
			{
				event = "neo_tree_window_after_close",
				handler = function(args)
					if args.position == "left" or args.position == "right" then
						vim.cmd("wincmd =")
					end
				end,
			},
		},

		close_if_last_window = true,
		filesystem = {
			commands = {
				delete = function(state)
					local path = state.tree:get_node().path
					vim.fn.system({ "trash", path })
					require("neo-tree.sources.manager").refresh(state.name)
				end,
				system_open = function(state)
					local path = state.tree:get_node():get_id()
					local sysname = vim.uv.os_uname().sysname
					if sysname == "Darwin" then
						vim.api.nvim_command("silent !open -g " .. path)
					elseif sysname == "Linux" then
						vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
					else
						vim.notify("Unsupported OS: " .. sysname, vim.log.levels.ERROR)
					end
				end,
			},
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
			},
			follow_current_file = {
				enabled = true,
			},
		},
		window = { mappings = {
			["<2-LeftMouse>"] = "system_open",
			["z"] = "none",
		} },
	},
	config = function(_, opts)
		require("neo-tree").setup(opts)
		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				if package.loaded["neo-tree.sources.git_status"] then
					require("neo-tree.sources.git_status").refresh()
				end
			end,
		})
	end,
}
