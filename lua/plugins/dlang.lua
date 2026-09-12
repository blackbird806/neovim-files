return {
	-- D Language LSP Configuration
	{
		'neovim/nvim-lspconfig',
		config = function()
			local lspconfig = require('lspconfig')
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

			-- Serve-D LSP for D language
			lspconfig.serve_d.setup({
				capabilities = capabilities,
				settings = {
					d = {
						-- Enable all D language features
						dcdClientPath = "",  -- Leave empty to use system dcd
						dcdServerPath = "",
						nothrowTemplate = true,
						gdfmt_args = { "--indent", "4" },
						dformat_args = {},
						dscanner_args = {},
						disableDfmt = false,
						disableDscanner = false,
						dubConfiguration = "default",
						enableAutoComplete = true,
						enableAutoImport = true,
					},
				},
				on_attach = function(client, bufnr)
					-- D-specific keymaps
					local map = function(keys, func, desc, mode)
						mode = mode or 'n'
						vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP D: ' .. desc })
					end

					-- D-specific commands
					map('<leader>ddf', function()
						vim.lsp.buf.format({ async = true })
					end, '[D]format [D]')
				end,
			})
		end,
	},

	-- DAP (Debug Adapter Protocol) support for D
	{
		'mfussenegger/nvim-dap',
		dependencies = {
			'rcarriga/nvim-dap-ui',
			'nvim-neotest/nvim-nio',
		},
		config = function()
			local dap = require('dap')
			local dapui = require('dapui')

			-- Setup DAP UI
			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			-- D language debugging with CodeLLDB (for D compiled with LDC)
			dap.adapters.codelldb = {
				type = 'server',
				host = '127.0.0.1',
				port = 13000,
				executable = {
					command = 'codelldb',
					args = { '--port', '13000' },
				}
			}

			-- D debugging configuration
			dap.configurations.d = {
				{
					name = 'Launch (LDC with CodeLLDB)',
					type = 'codelldb',
					request = 'launch',
					program = function()
						return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
					end,
					cwd = '${workspaceFolder}',
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
					console = 'integratedTerminal',
				},
				{
					name = 'Attach (LDC with CodeLLDB)',
					type = 'codelldb',
					request = 'attach',
					pid = require('dap.utils').pick_process,
					args = {},
				},
				{
					name = 'Launch with dub',
					type = 'codelldb',
					request = 'launch',
					program = function()
						-- Build with dub first
						vim.fn.system('dub build')
						return vim.fn.getcwd() .. '/.dub/builds/application-debug/application'
					end,
					cwd = '${workspaceFolder}',
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
					console = 'integratedTerminal',
				},
			}

			-- DAP keymaps
			vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP: Continue' })
			vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP: Step Over' })
			vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP: Step Into' })
			vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP: Step Out' })
			vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, { desc = 'DAP: Toggle Breakpoint' })
			vim.keymap.set('n', '<Leader>B', function()
				dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
			end, { desc = 'DAP: Set Breakpoint with Condition' })
			vim.keymap.set('n', '<Leader>lp', function()
				dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
			end, { desc = 'DAP: Set Logpoint' })
			vim.keymap.set('n', '<Leader>dr', dap.repl.open, { desc = 'DAP: Open REPL' })
		end,
	},

	-- Optional: D syntax highlighting enhancements
	{
		'JesseKPhillips/d.vim',
	},
}
