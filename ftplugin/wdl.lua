if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = true

local bo = vim.bo
local wo = vim.wo

-- Indentation settings
bo.tabstop = 4
bo.shiftwidth = 4
bo.softtabstop = 4
bo.expandtab = true

-- Comment string for commenting plugins
bo.commentstring = "# %s"

-- Keywords for motion commands
bo.iskeyword = bo.iskeyword .. ",_"

-- Format options
bo.formatoptions = bo.formatoptions .. "croql"

-- Match pairs for `%` motion
vim.b.match_words = "{:},<<<:>>>"

-- Folding based on indentation
wo.foldmethod = "indent"
wo.foldlevel = 99

-- Include path for `gf` command (go to file under cursor)
bo.include = "^\\s*import\\s*[\"']\\zs[^\"']*\\ze[\"']"

-- Set up undo for buffer-local options
vim.b.undo_ftplugin = "setlocal tabstop< shiftwidth< softtabstop< expandtab< commentstring< iskeyword< formatoptions< foldmethod< foldlevel< include< | unlet! b:match_words"
