return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	opts = function()
		local function generate_empty_lines(size)
			local fill = {}
			for _ = 1, size do
				table.insert(fill, "")
			end
			return fill
		end

		local function center_header(header)
			local size = math.floor(vim.o.lines / 2) - math.ceil(#header / 2) - 2
			local fill = generate_empty_lines(size)
			return vim.list_extend(fill, header)
		end
		-- url: http://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=neovim
		local logo = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]
		local opts = {
			theme = "doom",
			hide = {
				-- this is taken care of by lualine
				-- enabling this messes up the actual laststatus setting after loading a file
				statusline = false,
			},
			config = {
				header = center_header(vim.split(logo, "\n")),
				center = {
					{
						icon = " ",
						desc = "Files",
						action = "Telescope find_files",
						key = "f",
					},
					{ action = "ene | startinsert", desc = "New File", icon = " ", key = "n" },
					{ desc = "Lazy", icon = "󰒲 ", action = "Lazy update", key = "u" },
					{
						action = function()
							vim.api.nvim_input("<cmd>qa<cr>")
						end,
						desc = "Quit",
						icon = " ",
						key = "q",
					},
				},
				footer = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
				end,
			},
		}
		-- open dashboard after closing lazy
		if vim.o.filetype == "lazy" then
			vim.api.nvim_create_autocmd("WinClosed", {
				pattern = tostring(vim.api.nvim_get_current_win()),
				once = true,
				callback = function()
					vim.schedule(function()
						vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
					end)
				end,
			})
		end
		return opts
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
