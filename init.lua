require("core")

require("plugins")


vim.cmd("TSEnable highlight")
vim.cmd.colorscheme "catppuccin"

		--local builtin = require('telescope.builtin')
		--vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		--vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		--vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		--vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		local wk = require("which-key")
		wk.add({
			{ "<leader>f", group = "file" }, -- group
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
			{ "<leader>fb", function() print("hello") end, desc = "Foobar" },
			{ "<leader>fn", desc = "New File" },
			{ "<leader>f1", hidden = true }, -- hide this keymap
			{ "<leader>w", proxy = "<c-w>", group = "windows" }, -- proxy to window mappings
			{ "<leader>b", group = "buffers", expand = function()
				return require("which-key.extras").expand.buf()
			end
		},
		{
			-- Nested mappings are allowed and can be added in any order
			-- Most attributes can be inherited or overridden on any level
			-- There's no limit to the depth of nesting
			mode = { "n", "v" }, -- NORMAL and VISUAL mode
			{ "<leader>q", "<cmd>q<cr>", desc = "Quit" }, -- no need to specify mode since it's inherited
			{ "<leader>w", "<cmd>w<cr>", desc = "Write" },
		}
	})

	local actions = require "telescope.actions"
	require('telescope').setup{
		defaults = { 
			mappings = {
				i = {
					["<CR>"] = actions.select_default,
				}
			}
		}
	}

	-- good colors on wk, see: https://github.com/folke/which-key.nvim/issues/52#issuecomment-832570589
	vim.cmd([[
	hi WhichKeyFloat ctermbg=BLACK ctermfg=BLACK
	]])

	local xmake_component = {
		function()
			local xmake = require("xmake.project").info
			if xmake.target.tg == "" then
				return ""
			end
			return xmake.target.tg .. "(" .. xmake.mode .. ")"
		end,

		cond = function()
			return vim.o.columns > 100
		end,

		on_click = function()
			require("xmake.project._menu").init() -- Add the on-click ui
		end,
	}

	require('lualine').setup {
		options = {
			icons_enabled = true,
			theme = 'ayu_mirage',
			component_separators = { left = '', right = ''},
			section_separators = { left = '', right = ''},
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			globalstatus = false,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			}
		},
		sections = {
			lualine_a = {'mode'},
			lualine_b = {'branch', 'diff', 'diagnostics'},
			lualine_c = {'filename'},
			lualine_x = {xmake_component, 'encoding', 'fileformat', 'filetype'},
			lualine_y = {'progress'},
			lualine_z = {'location'}
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {'filename'},
			lualine_x = {'location'},
			lualine_y = {},
			lualine_z = {}
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {}
	}

	--require('lualine').setup()

	require'lspconfig'.serve_d.setup({
		--	d.dcdClientPath = "D:/dev/dcd",
		--	d.dcdServerPath = "D:/dev/dcd"
	})


	-- Global mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
	vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)


	require("toggleterm").setup{
		open_mapping = [[<c-\>]],
		shell = "powershell.exe"
	}

	-- Disable inline warnings/errors
	-- see https://neovim.io/doc/user/diagnostic.html
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.handlers["textDocument/publishDiagnostics"], {
			virtual_text = false,
			signs = false,
			underline = false,
		}
	)

	require('nvim_comment').setup()

