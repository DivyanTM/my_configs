vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = false,
				term_colors = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					telescope = true,
					treesitter = true,
					mason = true,
					lualine = true,
					which_key = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("lualine").setup({
				options = {
					theme = "catppuccin",
					section_separators = "",
					component_separators = "",
					globalstatus = true,
				},
			})
		end,
	},

	-- Shortcut helper
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			require("which-key").setup()
		end,
	},

	-- File search
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 32,
					side = "left",
				},
				renderer = {
					group_empty = true,
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
				filters = {
					dotfiles = false,
				},
			})
		end,
	},

	-- Git gutter signs
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "┃" },
					change = { text = "┃" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},

				signcolumn = true,
				numhl = false,
				linehl = false,
				word_diff = false,
				current_line_blame = false,

				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns

					local function map(mode, lhs, rhs, desc)
						vim.keymap.set(mode, lhs, rhs, {
							buffer = bufnr,
							desc = desc,
						})
					end

					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gs.nav_hunk("next")
						end
					end, "Next Git change")

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gs.nav_hunk("prev")
						end
					end, "Previous Git change")

					map("n", "<leader>gp", gs.preview_hunk, "Preview Git change")
					map("n", "<leader>gr", gs.reset_hunk, "Reset Git hunk")
					map("n", "<leader>gs", gs.stage_hunk, "Stage Git hunk")
					map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
					map("n", "<leader>gb", gs.blame_line, "Git blame line")
					map("n", "<leader>gd", gs.diffthis, "Git diff file")
				end,
			})
		end,
	},

	-- Syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local ok, configs = pcall(require, "nvim-treesitter.configs")
			if not ok then
				return
			end

			configs.setup({
				ensure_installed = {
					"c",
					"cpp",
					"lua",
					"javascript",
					"typescript",
					"dart",
					"java",
					"html",
					"css",
					"json",
					"yaml",
					"markdown",
					"markdown_inline",
				},
				auto_install = true,
				highlight = {
					enable = true,
				},
				indent = {
					enable = true,
				},
			})
		end,
	},

	-- Auto brackets
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Auto HTML/JSX/TSX tags
	{
		"windwp/nvim-ts-autotag",
		ft = {
			"html",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
		},
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
  formatters_by_ft = {
    lua = { "stylua" },

    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },

    html = { "prettier" },

    -- Angular template files
    htmlangular = { "prettier_angular" },

    css = { "prettier" },
    scss = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },

    java = { "google-java-format" },

    c = { "clang_format" },
    cpp = { "clang_format" },
  },

  formatters = {
    prettier_angular = {
      command = "prettier",
      args = {
        "--parser",
        "angular",
      },
      stdin = true,
    },
  },

  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
},
},

	-- Comment toggle
	{
		"numToStr/Comment.nvim",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		event = "VeryLazy",
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})

			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	},
	-- Floating terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<C-\>]],
				direction = "float",
				shade_terminals = true,
				float_opts = {
					border = "curved",
				},
			})
		end,
	},

	-- Diagnostics panel
	{
		"folke/trouble.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		cmd = "Trouble",
	},

	-- Mason / LSP
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"clangd",
					"ts_ls",
					"jdtls",
					"html",
					"cssls",
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
	},

	-- Autocomplete
	{
		"hrsh7th/nvim-cmp",
	},

	{
		"hrsh7th/cmp-nvim-lsp",
	},

	{
		"L3MON4D3/LuaSnip",
	},
}

require("lazy").setup(plugins, {})

local builtin = require("telescope.builtin")

-- File explorer
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", {
	noremap = true,
	silent = true,
	desc = "Toggle file explorer",
})

-- Telescope / VS Code-like search
vim.keymap.set("n", "<C-p>", builtin.find_files, {
	desc = "Find files",
})

vim.keymap.set("n", "<leader>fg", builtin.live_grep, {
	desc = "Search text in project",
})

vim.keymap.set("n", "<leader>fb", builtin.buffers, {
	desc = "Find open buffers",
})

vim.keymap.set("n", "<leader>fh", builtin.help_tags, {
	desc = "Find help",
})

vim.keymap.set("n", "<leader>fr", builtin.oldfiles, {
	desc = "Recent files",
})

-- Formatting
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({
		async = true,
		lsp_format = "fallback",
	})
end, {
	desc = "Format file",
})

-- Save / quit
vim.keymap.set("n", "<leader>w", ":w<CR>", {
	noremap = true,
	silent = true,
	desc = "Save file",
})

vim.keymap.set("n", "<leader>q", ":q<CR>", {
	noremap = true,
	silent = true,
	desc = "Quit file",
})

vim.keymap.set("n", "<leader>x", ":x<CR>", {
	noremap = true,
	silent = true,
	desc = "Save and quit",
})

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", {
	desc = "Move to left window",
})

vim.keymap.set("n", "<C-j>", "<C-w>j", {
	desc = "Move to lower window",
})

vim.keymap.set("n", "<C-k>", "<C-w>k", {
	desc = "Move to upper window",
})

vim.keymap.set("n", "<C-l>", "<C-w>l", {
	desc = "Move to right window",
})

-- Buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>", {
	noremap = true,
	silent = true,
	desc = "Next buffer",
})

vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", {
	noremap = true,
	silent = true,
	desc = "Previous buffer",
})

vim.keymap.set("n", "<leader>bd", ":bdelete<CR>", {
	noremap = true,
	silent = true,
	desc = "Close buffer",
})

-- Trouble diagnostics
vim.keymap.set("n", "<leader>xx", ":Trouble diagnostics toggle<CR>", {
	noremap = true,
	silent = true,
	desc = "Toggle diagnostics list",
})

vim.keymap.set("n", "<leader>xq", ":Trouble quickfix toggle<CR>", {
	noremap = true,
	silent = true,
	desc = "Toggle quickfix list",
})

-- Autocomplete
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},

	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),

		["<CR>"] = cmp.mapping.confirm({
			select = true,
		}),

		["<Tab>"] = cmp.mapping.select_next_item(),
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
	}),

	sources = cmp.config.sources({
		{
			name = "nvim_lsp",
		},
	}),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- C/C++
vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--log=verbose",
	},
	filetypes = {
		"c",
		"cpp",
		"objc",
		"objcpp",
		"cuda",
		"proto",
	},
	root_markers = {
		"compile_commands.json",
		"compile_flags.txt",
		".git",
	},
	capabilities = capabilities,
})
vim.lsp.enable("clangd")

-- JavaScript / TypeScript
vim.lsp.config("ts_ls", {
	cmd = {
		"typescript-language-server",
		"--stdio",
	},
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		".git",
	},
	capabilities = capabilities,
})
vim.lsp.enable("ts_ls")

-- Java
vim.lsp.config("jdtls", {
	cmd = {
		"jdtls",
	},
	filetypes = {
		"java",
	},
	root_markers = {
		"build.gradle",
		"pom.xml",
		".git",
	},
	capabilities = capabilities,
})
vim.lsp.enable("jdtls")

-- HTML
vim.lsp.config("html", {
	cmd = {
		"vscode-html-language-server",
		"--stdio",
	},
	filetypes = {
		"html",
		"templ",
	},
	root_markers = {
		"package.json",
		".git",
	},
	capabilities = capabilities,
})
vim.lsp.enable("html")

-- CSS
vim.lsp.config("cssls", {
	cmd = {
		"vscode-css-language-server",
		"--stdio",
	},
	filetypes = {
		"css",
		"scss",
		"less",
	},
	root_markers = {
		"package.json",
		".git",
	},
	capabilities = capabilities,
})
vim.lsp.enable("cssls")

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(event)
		local opts = {
			buffer = event.buf,
		}

		vim.keymap.set(
			"n",
			"gd",
			vim.lsp.buf.definition,
			vim.tbl_extend("force", opts, {
				desc = "Go to definition",
			})
		)

		vim.keymap.set(
			"n",
			"gD",
			vim.lsp.buf.declaration,
			vim.tbl_extend("force", opts, {
				desc = "Go to declaration",
			})
		)

		vim.keymap.set(
			"n",
			"gi",
			vim.lsp.buf.implementation,
			vim.tbl_extend("force", opts, {
				desc = "Go to implementation",
			})
		)

		vim.keymap.set(
			"n",
			"gr",
			vim.lsp.buf.references,
			vim.tbl_extend("force", opts, {
				desc = "Find references",
			})
		)

		vim.keymap.set(
			"n",
			"K",
			vim.lsp.buf.hover,
			vim.tbl_extend("force", opts, {
				desc = "Hover documentation",
			})
		)

		vim.keymap.set(
			"n",
			"<leader>rn",
			vim.lsp.buf.rename,
			vim.tbl_extend("force", opts, {
				desc = "Rename symbol",
			})
		)

		vim.keymap.set(
			"n",
			"<leader>ca",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, {
				desc = "Code action",
			})
		)

		vim.keymap.set(
			"n",
			"<leader>d",
			vim.diagnostic.open_float,
			vim.tbl_extend("force", opts, {
				desc = "Show diagnostic",
			})
		)

		vim.keymap.set(
			"n",
			"[d",
			vim.diagnostic.goto_prev,
			vim.tbl_extend("force", opts, {
				desc = "Previous diagnostic",
			})
		)

		vim.keymap.set(
			"n",
			"]d",
			vim.diagnostic.goto_next,
			vim.tbl_extend("force", opts, {
				desc = "Next diagnostic",
			})
		)
	end,
})
