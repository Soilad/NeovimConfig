-- nvim-treesitter `main` branch (the old `master` branch breaks on Neovim 0.12).
-- Requires the `tree-sitter` CLI (Arch: `pacman -S tree-sitter-cli`) to install parsers.
local parsers = {
	"bash", "c", "c_sharp", "cmake", "comment", "css", "dart", "fish", "gdscript",
	"gitignore", "godot_resource", "haskell", "html", "htmldjango", "hyprlang", "ini",
	"java", "javascript", "json", "kotlin", "lua", "markdown", "markdown_inline", "matlab",
	"properties", "python", "qmljs", "rust", "scss", "slint", "toml", "vim", "vimdoc",
	"xml", "xresources", "yuck",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- main branch does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		local ts = require("nvim-treesitter")
		local can_build = vim.fn.executable("tree-sitter") == 1
		if can_build then
			ts.install(parsers)
		else
			vim.notify("nvim-treesitter: install tree-sitter-cli to build parsers", vim.log.levels.WARN)
		end

		local available = {}
		for _, lang in ipairs(ts.get_available()) do
			available[lang] = true
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
			callback = function(args)
				local lang = vim.treesitter.language.get_lang(args.match) or args.match
				-- auto_install replacement: fetch missing parsers on first use
				if can_build and available[lang] and not vim.list_contains(ts.get_installed(), lang) then
					ts.install(lang):await(function()
						if vim.api.nvim_buf_is_valid(args.buf) then
							pcall(vim.treesitter.start, args.buf, lang)
						end
					end)
					return
				end
				pcall(vim.treesitter.start, args.buf, lang)
			end,
		})
	end,
}
