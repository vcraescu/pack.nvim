# pack.nvim

A thin wrapper around Neovim's built-in `vim.pack` (available in Neovim 0.11+) that provides a simple, declarative plugin configuration interface.

## Requirements

- Neovim >= 0.11

## Installation

Since `pack.nvim` is itself a plugin, bootstrap it by cloning the repository into your Neovim data directory:

```sh
git clone https://github.com/vcraescu/pack.nvim \
  "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/pack/pack/start/pack.nvim"
```

## Usage

Call `require("pack").setup()` in your `init.lua` with a configuration table:

```lua
require("pack").setup({
  plugins = {
    -- GitHub shorthand (user/repo)
    { src = "nvim-lua/plenary.nvim" },

    -- Full URL
    { src = "https://github.com/nvim-telescope/telescope.nvim" },

    -- Local directory
    { dir = "~/projects/my-plugin" },

    -- With setup callback
    {
      src = "nvim-telescope/telescope.nvim",
      setup = function()
        require("telescope").setup({})
      end,
    },
  },

  -- Optional: runs after all plugins are loaded and set up
  after = function()
    vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
  end,
})
```

## Configuration

### `pack.Config`

| Field     | Type                | Description                                      |
|-----------|---------------------|--------------------------------------------------|
| `plugins` | `pack.Plugin[]`     | List of plugin specifications                    |
| `after`   | `fun()` (optional)  | Hook called after all plugins are loaded/set up  |

### `pack.Plugin`

| Field   | Type                | Description                                                        |
|---------|---------------------|--------------------------------------------------------------------|
| `src`   | `string` (optional) | GitHub shorthand (`user/repo`) or full URL to the plugin repository |
| `dir`   | `string` (optional) | Absolute or `~`-prefixed path to a local plugin directory          |
| `setup` | `fun()` (optional)  | Callback invoked after the plugin is added to the runtime path     |

## Commands

| Command              | Description                                                  |
|----------------------|--------------------------------------------------------------|
| `:PackReload`        | Reload all Lua modules and re-run the full plugin setup      |
| `:PackUpdate`        | Update all installed plugins via `vim.pack.update()`         |
| `:PackDel {name...}` | Remove one or more installed packages by name                |
| `:PackGet [{name}]`  | Print information about installed packages                   |

## License

MIT
