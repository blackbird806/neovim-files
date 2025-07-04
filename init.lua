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
plugins = {
	{ "https://github.com/neovim/nvim-lspconfig" },
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	{
		"nvim-lua/plenary.nvim"
	},
	{
		'nvim-telescope/telescope.nvim', tag = '0.1.5',
		requires = { 'nvim-lua/plenary.nvim' }
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { 'nvim-tree/nvim-web-devicons' }
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {}
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
			highlight = {
				multiline = true, -- enable multine todo comments
				multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
				multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
				before = "", -- "fg" or "bg" or empty
				keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
				after = "fg", -- "fg" or "bg" or empty
				pattern = [[.*<(KEYWORDS)\s*]], -- pattern or table of patterns, used for highlighting (vim regex)
				comments_only = true, -- uses treesitter to match keywords in comments only
				max_line_len = 400, -- ignore lines longer than this
				exclude = {}, -- list of file types to exclude highlighting
			},
			search = {
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
				},
				pattern = [[.*(KEYWORDS)]]
			}
		}
	},
	{
		'sudormrfbin/cheatsheet.nvim',
		dependencies = {
			{'nvim-telescope/telescope.nvim'},
			{'nvim-lua/popup.nvim'},
			{'nvim-lua/plenary.nvim'},
		}
	},
	{
		"SiegeEngineers/vim-aoe2-rms"
	},
	{
		-- C3 syntax highlight
		"https://github.com/Airbus5717/c3.vim"
	},
	{
		"https://github.com/dstein64/vim-startuptime"
	},
	{
		-- nvim comment
		"https://github.com/terrortylor/nvim-comment"
	},
	{
		"https://github.com/akinsho/toggleterm.nvim",
		version = "*",
		config = true
	},
	-- LSP Plugins
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		'folke/lazydev.nvim',
		ft = 'lua',
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = 'luvit-meta/library', words = { 'vim%.uv' } },
			},
		},
	},
	{ 'Bilal2453/luvit-meta', lazy = true },
	{
		-- Main LSP Configuration
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for Neovim
			{ 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
			'williamboman/mason-lspconfig.nvim',
			'WhoIsSethDaniel/mason-tool-installer.nvim',

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ 'j-hui/fidget.nvim', opts = {} },

			-- Allows extra capabilities provided by nvim-cmp
			'hrsh7th/cmp-nvim-lsp',
		},
		config = function()
			-- Brief aside: **What is LSP?**
			--
			-- LSP is an initialism you've probably heard, but might not understand what it is.
			--
			-- LSP stands for Language Server Protocol. It's a protocol that helps editors
			-- and language tooling communicate in a standardized fashion.
			--
			-- In general, you have a "server" which is some tool built to understand a particular
			-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
			-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
			-- processes that communicate with some "client" - in this case, Neovim!
			--
			-- LSP provides Neovim with features like:
			--  - Go to definition
			--  - Find references
			--  - Autocompletion
			--  - Symbol Search
			--  - and more!
			--
			-- Thus, Language Servers are external tools that must be installed separately from
			-- Neovim. This is where `mason` and related plugins come into play.
			--
			-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
			-- and elegantly composed help section, `:help lsp-vs-treesitter`

			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or 'n'
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

					-- Find references for the word under your cursor.
					map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

					-- Fuzzy find all the symbols in your current workspace.
					--  Similar to document symbols, except searches over your entire project.
					map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
						vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd('LspDetach', {
							group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
							callback = function(event1)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event1.buf }
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map('<leader>th', function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
						end, '[T]oggle Inlay [H]ints')
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				lua_ls = {
					-- cmd = {...},
					-- filetypes = { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = 'Replace',
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu.
			require('mason').setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				'stylua', -- Used to format Lua code
			})
			require('mason-tool-installer').setup { ensure_installed = ensure_installed }

			require('mason-lspconfig').setup {
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for ts_ls)
						server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
						require('lspconfig')[server_name].setup(server)
					end,
				},
			}
		end,
	},
	{ -- Autocompletion
		'hrsh7th/nvim-cmp',
		event = 'InsertEnter',
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				'L3MON4D3/LuaSnip',
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
						return
					end
					return 'make install_jsregexp'
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
						--   'rafamadriz/friendly-snippets',
						--   config = function()
							--     require('luasnip.loaders.from_vscode').lazy_load()
							--   end,
							-- },
						},
					},
					'saadparwaiz1/cmp_luasnip',

					-- Adds other completion capabilities.
					--  nvim-cmp does not ship with all sources by default. They are split
					--  into multiple repos for maintenance purposes.
					'hrsh7th/cmp-nvim-lsp',
					'hrsh7th/cmp-path',
				},
				config = function()
					-- See `:help cmp`
					local cmp = require 'cmp'
					local luasnip = require 'luasnip'
					luasnip.config.setup {}

					cmp.setup {
						snippet = {
							expand = function(args)
								luasnip.lsp_expand(args.body)
							end,
						},
						completion = { completeopt = 'menu,menuone,noinsert' },

						-- For an understanding of why these mappings were
						-- chosen, you will need to read `:help ins-completion`
						--
						-- No, but seriously. Please read `:help ins-completion`, it is really good!
						mapping = cmp.mapping.preset.insert {
							-- Select the [n]ext item
							['<C-n>'] = cmp.mapping.select_next_item(),
							-- Select the [p]revious item
							['<C-p>'] = cmp.mapping.select_prev_item(),

							-- Scroll the documentation window [b]ack / [f]orward
							['<C-b>'] = cmp.mapping.scroll_docs(-4),
							['<C-f>'] = cmp.mapping.scroll_docs(4),

							-- Accept ([y]es) the completion.
							--  This will auto-import if your LSP supports it.
							--  This will expand snippets if the LSP sent a snippet.
							['<C-y>'] = cmp.mapping.confirm { select = true },

							-- If you prefer more traditional completion keymaps,
							-- you can uncomment the following lines
							--['<CR>'] = cmp.mapping.confirm { select = true },
							--['<Tab>'] = cmp.mapping.select_next_item(),
							--['<S-Tab>'] = cmp.mapping.select_prev_item(),

							-- Manually trigger a completion from nvim-cmp.
							--  Generally you don't need this, because nvim-cmp will display
							--  completions whenever it has completion options available.
							['<C-Space>'] = cmp.mapping.complete {},

							-- Think of <c-l> as moving to the right of your snippet expansion.
							--  So if you have a snippet that's like:
							--  function $name($args)
							--    $body
							--  end
							--
							-- <c-l> will move you to the right of each of the expansion locations.
							-- <c-h> is similar, except moving you backwards.
							['<C-l>'] = cmp.mapping(function()
								if luasnip.expand_or_locally_jumpable() then
									luasnip.expand_or_jump()
								end
							end, { 'i', 's' }),
							['<C-h>'] = cmp.mapping(function()
								if luasnip.locally_jumpable(-1) then
									luasnip.jump(-1)
								end
							end, { 'i', 's' }),

							-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
							--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
						},
						sources = {
							{
								name = 'lazydev',
								-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
								group_index = 0,
							},
							{ name = 'nvim_lsp' },
							{ name = 'luasnip' },
							{ name = 'path' },
						},
					}
				end,
			},
			{
				"Mythos-404/xmake.nvim",
				lazy = true,
				event = "BufReadPost xmake.lua",
				config = true,
				dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
			},
		} -- plugins end
		require("lazy").setup(plugins, opts)

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
					["<CR>"] = actions.select_tab,
				}
			}
		}
	}
	require('telescope').setup()

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

	-- Disabe inline warings/errors
	-- see https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.Opts
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
		vim.lsp.diagnostic.on_publish_diagnostics, {
			virtual_text = false,
			signs = false,
			underline = false,
		}
	)

	require('nvim_comment').setup()

