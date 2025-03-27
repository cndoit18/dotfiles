return {
	"nvim-neo-tree/neo-tree.nvim",
	lazy = false,
	branch = "v3.x",
	cmd = "Neotree",
	keys = {
		{ "<leader>nt", [[:Neotree toggle<CR>]] },
		{ "<leader>nf", [[:Neotree focus<CR>]] },
	},
	dependencies = {
		{ "nvim-lualine/lualine.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-tree/nvim-web-devicons" }, -- not strictly required, but recommended
		{ "MunifTanjim/nui.nvim" },
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		{
			"s1n7ax/nvim-window-picker",
			lazy = true,
			opts = {
				filter_rules = {
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
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

						-- if the buffer type is one of following, the window will be ignored
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
					vim.fn.system({ "trash", vim.fn.fnameescape(path) })
					require("neo-tree.sources.manager").refresh(state.name)
				end,
				system_open = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()
					local getOS = function()
						local handle = io.popen("uname -s")
						if handle == nil then
							vim.notify("Error while opening handler", vim.log.levels.ERROR)
							return ""
						end
						local uname = handle:read("*a")
						handle:close()
						uname = uname:gsub("%s+", "")
						if uname == "Darwin" then
							return "Darwin"
						elseif uname == "NixOS" then
							return "NixOS"
						elseif uname == "Linux" then
							return "Linux"
						else
							return ""
						end
					end
					if getOS() == "Darwin" then
						vim.api.nvim_command("silent !open -g " .. path)
					elseif getOS() == "Linux" then
						vim.api.nvim_command(string.format("silent !xdg-open '%s'", path))
					else
						vim.notify("Could not determine OS", vim.log.levels.ERROR)
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
	init = function()
		table.insert(require("lualine").get_config().extensions, "neo-tree")
	end,
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
