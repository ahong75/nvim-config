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
vim.opt.tabstop = 4
-- The number of spaces nvim will use to indent with
vim.opt.shiftwidth = 2
-- Expands tab characters as spaces
vim.opt.expandtab = true
-- These two settings can screw with pasting
vim.opt.smartindent = true
vim.opt.autoindent = true
-- Makes colorschemes look better if enabled. But with solarized-light, actually makes it look worse
vim.opt.termguicolors = false
-- Need this to make system clipboard connect to vim yank
vim.opt.clipboard = 'unnamedplus'

-- Mapping leader key
vim.g.mapleader = ' '

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
  -- use 'shaunsingh/solarized.nvim'
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

-- require('solarized').set()
