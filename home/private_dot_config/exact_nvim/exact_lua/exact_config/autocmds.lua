local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	group = numbertoggle,
	callback = function()
		if vim.o.nu then
			vim.opt.relativenumber = true
		end
	end,
})
vim.api.nvim_create_autocmd("InsertEnter", {
	pattern = "*",
	group = numbertoggle,
	callback = function()
		if vim.o.nu then
			vim.opt.relativenumber = false
		end
	end,
})

vim.diagnostic.config({ virtual_text = false })

local qfgroup = vim.api.nvim_create_augroup("changeQuickfix", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	group = qfgroup,
	callback = function()
		vim.cmd("wincmd J")
		vim.cmd("setlocal wrap")
		vim.keymap.set("n", "k", "<Up><CR>zz<C-w>p", { buffer = true })
		vim.keymap.set("n", "j", "<Down><CR>zz<C-w>p", { buffer = true })
	end,
})
