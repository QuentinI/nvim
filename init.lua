local opt = vim.o

vim.g.mapleader = " "

-- Visual stuff
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.visualbell = true
opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·', nbsp = '⍽' }
-- Whatever it is
opt.termguicolors = true

-- Global statusline
opt.laststatus = 3

-- No tabs. Ever.
opt.tabstop = 4
opt.softtabstop = 4
opt.expandtab = true
opt.shiftwidth = 4
opt.autoindent = true

-- folding
vim.cmd[[set nofoldenable]]
opt.foldlevel = 99

-- System clipboard
opt.clipboard = opt.clipboard .. "unnamedplus"

require('plugins')
