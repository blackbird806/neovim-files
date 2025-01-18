vim.wo.number = true
local set = vim.opt -- set options
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.guicursor = "" -- keep filled cursor on edit mode
set.undofile = true

-- Decrease update time
vim.opt.updatetime = 250

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- https://www.reddit.com/r/neovim/comments/1abd2cq/comment/kjo7moz/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
vim.api.nvim_create_autocmd('BufReadPost', {
	desc = 'Open file at the last position it was edited earlier',
	group = misc_augroup,
	pattern = '*',
	command = 'silent! normal! g`"zv'
})

-- C++ modules files are c++
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
	pattern = "*.ixx",
	callback = function()
		set.filetype = "cpp"
	end
})



