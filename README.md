<p align="center">
  <h1 align="center">
    <code>sprocket.nvim</code>
  </h1>

  <p align="center">
    <a href="https://github.com/stjude-rust-labs/sprocket.nvim/blob/main/LICENSE-APACHE"><img alt="Apache 2.0" src="https://img.shields.io/badge/license-Apache%202.0-blue.svg"></a>
    <a href="https://github.com/stjude-rust-labs/sprocket.nvim/blob/main/LICENSE-MIT"><img alt="MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
    <a href="https://neovim.io/"><img alt="Neovim 0.11+" src="https://img.shields.io/badge/Neovim-0.11+-green.svg?logo=neovim"></a>
  </p>

  <p align="center">
    WDL language support for Neovim via the Sprocket LSP
    <br />
    <br />
    <a href="https://github.com/stjude-rust-labs/sprocket.nvim/issues/new?labels=enhancement">Request Feature</a>
    ·
    <a href="https://github.com/stjude-rust-labs/sprocket.nvim/issues/new?labels=bug">Report Bug</a>
  </p>
</p>

## 🏠 Overview

`sprocket.nvim` provides comprehensive [WDL](https://openwdl.org/) (Workflow Description Language) support for Neovim, powered by the [Sprocket](https://github.com/stjude-rust-labs/sprocket) language server. WDL is widely used in bioinformatics for defining portable, reproducible analysis workflows.

## 🎨 Features

- **LSP Integration.** Completions, diagnostics, hover documentation, go-to-definition, and references powered by Sprocket
- **Syntax Highlighting.** Full support for WDL 1.0 through 1.3 via Vim regex patterns
- **Document Formatting.** Format WDL files on save or on demand via LSP or CLI
- **Commands.** Validate, lint, and format files directly from Neovim
- **Statusline Component.** Display LSP status in your statusline (lualine, etc.)
- **Plugin Integrations.** Works with `nvim-autopairs` for auto-closing `<<<`/`>>>` and `~{`/`}` pairs, and `Comment.nvim` for `#` comments

## 📚 Getting Started

### Requirements

- Neovim 0.11+
- [sprocket](https://github.com/stjude-rust-labs/sprocket/releases) binary

### Installation

<details>
<summary><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a> (recommended)</summary>

```lua
{
  "stjude-rust-labs/sprocket.nvim",
  ft = "wdl",
  opts = {},
}
```

</details>

<details>
<summary><a href="https://github.com/wbthomason/packer.nvim">packer.nvim</a></summary>

```lua
use {
  "stjude-rust-labs/sprocket.nvim",
  ft = "wdl",
  config = function()
    require("sprocket").setup({})
  end,
}
```

</details>

<details>
<summary><a href="https://github.com/junegunn/vim-plug">vim-plug</a></summary>

```vim
Plug 'stjude-rust-labs/sprocket.nvim'

" In your init.lua or after/plugin:
lua require("sprocket").setup({})
```

</details>

### Installing Sprocket

Download the latest release from [GitHub Releases](https://github.com/stjude-rust-labs/sprocket/releases) and ensure `sprocket` is in your `PATH`.

```bash
# Example for macOS/Linux
curl -LO https://github.com/stjude-rust-labs/sprocket/releases/latest/download/sprocket-<version>-<platform>.tar.gz
tar -xzf sprocket-*.tar.gz
mv sprocket ~/.local/bin/
```

Alternatively, enable `auto_install` in the plugin configuration to download automatically.

## ⚙️ Configuration

All options with their defaults:

```lua
require("sprocket").setup({
  binary = {
    path = nil,            -- Custom path to sprocket binary
    auto_install = false,  -- Auto-download from GitHub if not found
    check_updates = false, -- Check for updates on startup
  },
  server = {
    lint = false,        -- Enable additional linting via `--lint` flag
    log_level = "quiet", -- "quiet" | "info" | "verbose"
  },
  format_on_save = false,  -- Auto-format WDL files before saving
  status = {
    enabled = true, -- Enable statusline component
    icons = {
      ok = "󰗡",
      warning = "",
      error = "",
      loading = "󰑮",
    },
  },
  lsp = {
    capabilities = nil, -- Custom LSP capabilities (auto-detects cmp-nvim-lsp)
    on_attach = nil,    -- Callback when LSP attaches to buffer
    handlers = nil,     -- Custom LSP handlers (merged with defaults)
  },
})
```

### Example with Keymaps

```lua
{
  "stjude-rust-labs/sprocket.nvim",
  ft = "wdl",
  opts = {
    lsp = {
      on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "Find references")
        map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")

        -- Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, "Format buffer")

        -- Diagnostics
        map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
        map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic")
      end,
    },
  },
}
```

## 🔧 Commands

All commands use the `:Sprocket` prefix:

| Command                  | Description                                      |
| ------------------------ | ------------------------------------------------ |
| `:Sprocket info`         | Show version, binary path, and server status     |
| `:Sprocket restart`      | Restart the LSP server                           |
| `:Sprocket stop`         | Stop the LSP server                              |
| `:Sprocket version`      | Display installed sprocket version               |
| `:Sprocket update`       | Download and install the latest sprocket version |
| `:Sprocket check [path]` | Validate a WDL file (defaults to current buffer) |
| `:Sprocket lint [path]`  | Run linter on a WDL file                         |
| `:Sprocket format [path]`| Format a WDL file                                |
| `:Sprocket log`          | Open the LSP log file for debugging              |

## 📊 Statusline

Add the status component to your statusline to see LSP status at a glance:

```lua
-- lualine.nvim
require("lualine").setup({
  sections = {
    lualine_x = { require("sprocket").status },
  },
})
```

Icons indicate server status:
- 󰗡 Running normally
-  Warning
-  Error
- 󰑮 Starting/loading

## 🩺 Health Check

Run `:checkhealth sprocket` to verify your setup. The health check reports:

- Neovim version compatibility
- Binary availability and version
- Required tools (`curl`, `tar`/`unzip` for auto-install)
- LSP server status
- Optional dependencies (`nvim-cmp`)
- Current configuration

## 🔌 Optional Dependencies

| Plugin | Benefit |
| ------ | ------- |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) + [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp) | Enhanced completion with LSP integration |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto-close `<<<`/`>>>`, `~{`/`}`, `${`/`}` pairs |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments with `gc` mappings |

## 🐛 Troubleshooting

**LSP not starting?**
1. Verify sprocket is installed: `:Sprocket version`
2. Check the LSP log: `:Sprocket log`
3. Ensure the file has a `.wdl` extension
4. Run `:checkhealth sprocket`

**No completions?**
1. Confirm LSP is running: `:Sprocket info`
2. If using `nvim-cmp`, verify `cmp-nvim-lsp` is configured
3. Check for syntax errors in your WDL file

**Formatting not working?**
1. Check for syntax errors (formatting requires valid WDL)
2. Update sprocket: `:Sprocket update`
3. Check the LSP log: `:Sprocket log`

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a [Pull Request](https://github.com/stjude-rust-labs/sprocket.nvim/pulls).

## 📝 License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.

Copyright © 2026-Present [St. Jude Children's Research Hospital](https://www.stjude.org/).
