-- Minimal init for running tests
local plenary_path = os.getenv("PLENARY_PATH") or vim.fn.stdpath("data") .. "/lazy/plenary.nvim"

vim.opt.runtimepath:prepend(plenary_path)
vim.opt.runtimepath:prepend(vim.fn.getcwd())

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

vim.cmd.runtime("plugin/plenary.vim")
