if vim.g.loaded_sprocket then
  return
end
vim.g.loaded_sprocket = true

-- Defer setup until a WDL file is opened if user hasn't called setup()
vim.api.nvim_create_autocmd("FileType", {
  pattern = "wdl",
  once = true,
  callback = function()
    if not require("sprocket")._initialized then
      require("sprocket").setup({})
    end
  end,
})
