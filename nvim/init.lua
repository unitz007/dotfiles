-- Minimal init.lua for Neovim
-- Bootstrap packer.nvim if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git','clone','--depth','1','https://github.com/wbthomason/packer.nvim',install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer can manage itself
  -- Add your plugins here
  use 'tpope/vim-sensible' -- sensible defaults
  -- Example: use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Basic settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = true