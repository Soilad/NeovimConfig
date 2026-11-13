return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.diagnostic.config({
				virtual_text = true,
				update_in_insert = true,
			})
			-- Home dir is a git repo, so the default `.git` marker makes lua_ls
			-- pick $HOME as workspace, which it refuses to load. Never use $HOME.
			vim.lsp.config("lua_ls", {
				root_dir = function(bufnr, on_dir)
					local home = vim.fs.normalize(vim.env.HOME)
					local markers = {
						".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml",
						"stylua.toml", "selene.toml", "selene.yml", "lua", ".git",
					}
					local root = vim.fs.root(bufnr, markers)
					if not root or vim.fs.normalize(root) == home then
						root = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
					end
					on_dir(root)
				end,
			})

			-- Servers whose `cmd` is a function: name the binary explicitly.
			local exe_override = {
				html = "vscode-html-language-server",
				jsonls = "vscode-json-language-server",
				ts_ls = "typescript-language-server",
				tailwindcss = "tailwindcss-language-server",
				gdscript = "godot",
			}

			-- Enable a server only when its binary is installed, so opening a
			-- file never errors with "Spawning language server ... failed".
			local function enable(name)
				local exe = exe_override[name]
				if not exe then
					local cfg = vim.lsp.config[name]
					local cmd = cfg and cfg.cmd
					exe = type(cmd) == "table" and cmd[1] or nil
				end
				if not exe or vim.fn.executable(exe) == 1 then
					vim.lsp.enable(name)
				end
			end

			for _, name in ipairs({
				"ast_grep",
				"copilot",
				-- "codebook",
				"dprint",
				"hls",
				"rust_analyzer",
				"jinja_lsp",
				"ruff",
				"basedpyright",
				"pyright",
				"lua_ls",
				"ts_ls",
				"html",
				"tailwindcss",
				"jsonls",
				"gdscript",
				"gdshader_lsp",
				"clangd",
				"cmake",
				-- C#: roslyn.nvim starts the server itself (see plugins/roslyn.lua)
				"matlab_ls",
				"kotlin_lsp",
				"kotlin_language_server",
			}) do
				enable(name)
			end
		end,
	},
	{ "elkowar/yuck.vim" },
	{
		"cushycush/quickshell-completions.nvim",
		ft = "qml",
		dependencies = { "saghen/blink.cmp" },
		opts = {},
	},
	-- Formatting. Replaced wsdjeg/format.nvim: its dependency wsdjeg/notify.nvim
	-- provides a Lua module named `notify`, which noice.nvim mistakes for
	-- rcarriga/nvim-notify and calls with a numeric level, crashing at startup.
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				rust = { "rustfmt" },
				go = { "gofmt" },
				python = { "ruff_format" },
				json = { "prettier" },
				markdown = { "prettier" },
				toml = { "taplo" },
			},
			format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
		},
	},
}
