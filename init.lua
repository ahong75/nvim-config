-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/
-- I'm following this blog for a lot of the config here
-- Installing packer
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local install_plugins = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  print('Installing packer...')
  local packer_url = 'https://github.com/wbthomason/packer.nvim'
  vim.fn.system({'git', 'clone', '--depth', '1', packer_url, install_path})
  print('Done.')

  vim.cmd('packadd packer.nvim')
  install_plugins = true
end

-- Line numbers
vim.opt.number = true
-- Mouse functionality. There are multiple modes
vim.opt.mouse = 'a'
-- Ignore uppercase letters when executing a search
vim.opt.ignorecase = true
-- Only works if ignorecase is enabled. Ignores uppercase unless search has uppercase
vim.opt.smartcase = true
-- Only highlights first search result
vim.opt.hlsearch = false
vim.opt.wrap = true
-- Wraps long lines
vim.opt.breakindent = true
-- The number of spaces a tab character occupies
vim.opt.tabstop = 2
-- The number of spaces nvim will use to indent with
vim.opt.shiftwidth = 2
-- Expands tab characters as spaces
vim.opt.expandtab = true
-- These two settings can screw with pasting
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.copyindent = true
-- Makes colorschemes look better if enabled. But with solarized-light, actually makes it look worse
vim.opt.termguicolors = false
-- Need this to make system clipboard connect to vim yank
vim.opt.clipboard = 'unnamedplus'
-- Prevents weird gray sidebar
vim.opt.signcolumn = 'no'
-- Mapping leader key
vim.g.mapleader = ' '
-- Cursorline (or else it's hard to see)
-- vim.opt.cursorline = true

-- vim.keymap.set({mode}, {lhs}, {rhs}, {opts})
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>')

-- Allows system clipboard to connnect to vim yank
-- https://mitchellt.com/2022/05/15/WSL-Neovim-Lua-and-the-Windows-Clipboard.html
IN_WSL = os.getenv('WSL_DISTRO_NAME') ~= nil

if IN_WSL then
    vim.g.clipboard = {
          name = 'wsl clipboard',
          copy =  { ["+"] = { "clip.exe" },   ["*"] = { "clip.exe" } },
          paste = { ["+"] = { "nvim_paste" }, ["*"] = { "nvim_paste" } },
          cache_enabled = true
      }
end

-- User commands
-- Syntax for creating commands
-- vim.api.nvim_create_user_command({name}, {command}, {opts})
-- Reloading config
vim.api.nvim_create_user_command('Rl', 'source $MYVIMRC', {})
vim.api.nvim_create_user_command('Rc', 'edit $MYVIMRC', {})

-- Where we install our plugins
require('packer').startup(function(use)
  ---
  -- List of plugins...
  -- Package Manager
  use 'wbthomason/packer.nvim'
  -- Status Line
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  -- Treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
  }
  -- Solarized Color Scheme
  use 'shaunsingh/solarized.nvim'
  -- LSP Stuff
  use {
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    }
  -- Toggleterm
  use {"akinsho/toggleterm.nvim", tag = '*', config = function()
    require("toggleterm").setup()
  end }
  -- Cursorline
  use 'yamatsum/nvim-cursorline'
  ---
  if install_plugins then
    require('packer').sync()
  end
end)

-- This prevents the script from continously executing when we are installing plugins. This is so we don't try to configure plugins that we haven't installed yet
-- We can remove this once we modulate things
if install_plugins then
  return
end

-- Plugin configurations

require('lualine').setup{
  options = {
    icons_enabled = true,
    theme = 'solarized_light'
  }
}

require('nvim-treesitter.configs').setup({
  highlight = {
    enable = true,
  },
  ensure_installed = {
    'javascript',
    'typescript',
    'tsx',
    'css',
    'json',
    'lua',
    'cpp',
    'c',
    'lua',
    'go',
    'java'
  },
})

require('toggleterm').setup{
  open_mapping = [[<C-t>]], 
}

require('nvim-cursorline').setup {
  cursorline = {
    enable = true,
    timeout = 1000,
    number = false,
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
}
-- LSP Global Config
local lsp_defaults = {
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  ),
  on_attach = function(client, bufnr)
    vim.api.nvim_exec_autocmds('User', {pattern = 'LspAttached'})
  end
}

local lspconfig = require('lspconfig')

lspconfig.util.default_config = vim.tbl_deep_extend(
  'force',
  lspconfig.util.default_config,
  lsp_defaults
)

-- LSP Servers
lspconfig.clangd.setup({})
-- lspconfig.sumneko_lua.setup({})

-- require('solarized').set()
