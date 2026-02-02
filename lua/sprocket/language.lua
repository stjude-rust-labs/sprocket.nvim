-- WDL language configuration.
-- Provides integration with `nvim-autopairs` and `Comment.nvim`.

local M = {}

M.brackets = {
  { "{", "}" },
  { "[", "]" },
  { "(", ")" },
  { "<<<", ">>>" },
  { '"', '"' },
  { "'", "'" },
}

M.auto_closing_pairs = {
  { open = "{", close = "}" },
  { open = "[", close = "]" },
  { open = "(", close = ")" },
  { open = '"', close = '"' },
  { open = "'", close = "'" },
  { open = "<<<", close = ">>>" },
  { open = "~{", close = "}" },
  { open = "${", close = "}" },
}

M.comments = {
  line = "#",
}

function M.setup()
  local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
  if has_autopairs then
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    autopairs.add_rules({
      Rule("<<<", ">>>", "wdl"),
      Rule("~{", "}", "wdl"):with_pair(cond.not_inside_quote()),
      Rule("${", "}", "wdl"):with_pair(cond.not_inside_quote()),
    })
  end

  local has_comment, _ = pcall(require, "Comment")
  if has_comment then
    local ft = require("Comment.ft")
    ft.set("wdl", "#%s")
  end
end

return M
