local omp_win = {
	position = "right",
	width = 0.4,
}

-- Accumulated "path:start-end" refs queued from visual selections. The plugin
-- itself only tracks ONE selection (last one wins), so multiple refs are
-- queued here and flushed into the OMP terminal input in one go.
local omp_queue = {}

-- Find the Snacks terminal whose command is `omp` (also matches `omp -r` / `omp -c`).
local function omp_terminal()
	for _, term in ipairs(Snacks.terminal.list()) do
		if term:buf_valid() then
			local st = vim.b[term.buf].snacks_terminal
			local cmd = st and st.cmd
			if cmd then
				local first = type(cmd) == "table" and cmd[1] or cmd
				if first and first:match("^omp") then
					return term
				end
			end
		end
	end
end

local function omp_queue_selection()
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
	local ref = path .. ":" .. start_line .. "-" .. end_line
	if not vim.tbl_contains(omp_queue, ref) then
		omp_queue[#omp_queue + 1] = ref
	end
	vim.notify(("Queued %d OMP ref(s): %s"):format(#omp_queue, table.concat(omp_queue, " ")), vim.log.levels.INFO)
end

-- Paste the queue into the OMP terminal input as one bracketed-paste event, so
-- the TUI treats it as pasted text instead of keybindings. No trailing CR: the
-- user finishes the message and submits it.
local function omp_send_queue()
	if #omp_queue == 0 then
		vim.notify("OMP ref queue is empty", vim.log.levels.WARN)
		return
	end
	local term = omp_terminal()
	if not term then
		vim.notify("No OMP terminal running (<leader>at to start)", vim.log.levels.WARN)
		return
	end
	local payload = "\27[200~" .. table.concat(omp_queue, " ") .. "\27[201~"
	vim.api.nvim_chan_send(vim.b[term.buf].terminal_job_id, payload)
	vim.notify(("Sent %d OMP ref(s)"):format(#omp_queue), vim.log.levels.INFO)
	omp_queue = {}
	term:show():focus()
	vim.cmd("startinsert")
end

return {
	-- OMP terminal + Neovim context bridge
	"rauls-kjarners/omp.nvim",
	dependencies = { "folke/snacks.nvim" },
	event = "VeryLazy",
	config = function()
		require("omp").setup()
	end,
	keys = {
		{
			"<leader>at",
			function()
				Snacks.terminal.toggle({ "omp" }, { win = omp_win })
			end,
			desc = "Toggle Oh My Pi",
		},
		{
			"<leader>af",
			function()
				Snacks.terminal.focus({ "omp" }, { win = omp_win })
			end,
			desc = "Focus Oh My Pi",
		},
		{
			"<leader>ar",
			function()
				Snacks.terminal.toggle({ "omp", "-r" }, { win = omp_win })
			end,
			desc = "Resume OMP session",
		},
		{
			"<leader>aC",
			function()
				Snacks.terminal.toggle({ "omp", "-c" }, { win = omp_win })
			end,
			desc = "Continue OMP session",
		},
		{
			"<leader>as",
			omp_queue_selection,
			mode = "v",
			desc = "Queue selection for OMP",
		},
		{
			"<leader>as",
			omp_send_queue,
			desc = "Send queued refs to OMP",
		},
		{
			"<leader>ac",
			function()
				omp_queue = {}
				vim.notify("OMP ref queue cleared", vim.log.levels.INFO)
			end,
			desc = "Clear queued OMP refs",
		},
	},
}
