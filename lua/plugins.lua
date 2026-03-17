-- Lazy Boot
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
--

plugins = {
	require("plugins.catppucin"),
	require("plugins.lualine"),
	require("plugins.plenary"),
	require("plugins.telescope"),
	require("plugins.todo-comments"),
	require("plugins.treesitter"),
	require("plugins.wich-key"),
	require("plugins.cheatsheet"),
	require("plugins.xmake-plug"),
	require("plugins.luvit-meta"),
	require("plugins.nvim-cmp"),
	require("plugins.toggleterm"),
	require("plugins.vim-startuptime"),
	require("plugins.nvim-comment"),
}

require("lazy").setup(plugins, opts)