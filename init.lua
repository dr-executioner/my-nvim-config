-- Set leader key
vim.g.mapleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- Bootstrap Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  -- LSP support
  { "neovim/nvim-lspconfig" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "L3MON4D3/LuaSnip" },

  -- Syntax highlighting
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Go support
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua" },
    config = function()
      require("go").setup({
        lsp_cfg = false, -- We are configuring gopls manually
        lsp_gofumpt = true,
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    config = function()
      require("nvim-tree").setup()
    end,
  },

  {
  "nvim-telescope/telescope.nvim",
  tag = '0.1.5',
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require('telescope').setup{}
  end
},


  -- Theme
  { "catppuccin/nvim", name = "catppuccin" },
})

-- Setup LSP for Go (gopls)
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

lspconfig.gopls.setup({
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod" },
  root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
})

-- Setup autocomplete
local cmp = require("cmp")
cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

-- Optional: Auto format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.cmd("GoFmt")
  end,
})

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
})

vim.cmd.colorscheme "catppuccin"

-- Remove all occurances of the word
vim.api.nvim_create_user_command("RemoveWord", function(opts)
  vim.cmd(":%s/\\<" .. opts.args .. "\\>//g")
end, { nargs = 1 })

-- Keymaps
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>r", ":GoRun<CR>", { desc = "Run Go file" })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true }) -- Alt + j
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true }) -- Alt + k
vim.keymap.set("n", "<leader>f", require("telescope.builtin").find_files, {})
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, {})
vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, {})

