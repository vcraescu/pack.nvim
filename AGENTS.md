# AGENTS.md — pack.nvim

Guidance for agentic coding agents working in this repository.

---

## Project Overview

`pack.nvim` is a thin declarative wrapper around Neovim's built-in `vim.pack` API
(Neovim >= 0.11). It lets users manage plugins via a single `setup()` call in `init.lua`
without an external plugin manager. The plugin has zero runtime dependencies.

```
lua/pack/
  init.lua    -- public API: M.setup(), all user commands
  plugin.lua  -- Plugin class (OOP via metatable)
  types.lua   -- LuaLS @class / @alias annotations only
doc/
  pack.txt    -- vimdoc help file
```

---

## Build / Lint / Test Commands

There is no build step. The plugin is pure Lua loaded at runtime by Neovim.

### Formatting

```sh
# Format all Lua files in-place
stylua lua/

# Check formatting without modifying files (use in CI)
stylua --check lua/
```

### Linting / Type Checking

```sh
# Run the Lua language server type checker
lua-language-server --check lua/
```

### Tests

There are currently no automated tests in this repository. When tests are added,
the conventional location for a Neovim plugin is `tests/` using
[plenary.nvim's test harness](https://github.com/nvim-lua/plenary.nvim):

```sh
# Run all tests (once a test suite exists)
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Run a single test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/plugin_spec.lua"
```

---

## Code Style

### Formatter — StyLua

All Lua must be formatted with **StyLua** using the project's `stylua.toml`:

| Setting | Value |
|---|---|
| `column_width` | 120 |
| `indent_type` | Spaces |
| `indent_width` | 2 |
| `line_endings` | Unix (LF) |
| `quote_style` | AutoPreferDouble |
| `call_parentheses` | Always |
| `collapse_simple_statement` | Never |

Always run `stylua lua/` before committing. Never commit unformatted Lua.

### EditorConfig

- LF line endings for all files.
- UTF-8 encoding.
- Files must end with a final newline.
- 2-space indentation for `.lua` files.

---

## Naming Conventions

- **Files / modules**: `snake_case` (e.g. `plugin.lua`, `pack.plugin`).
- **Local variables and functions**: `snake_case` (e.g. `parse_name`, `load_plugins`).
- **Class tables**: `PascalCase` (e.g. `Plugin`).
- **Module-level public API table**: `M` (single letter, conventional in Neovim plugins).
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g. `GITHUB_PREFIX`).
- **Private functions**: Defined as `local function` upvalues, _not_ as `M._xxx` methods
  on a module table. The `_` prefix does not enforce privacy in Lua.
- **User commands**: `PascalCase` with the `Pack` prefix (e.g. `PackReload`, `PackUpdate`).

---

## Module / OOP Pattern

Classes use the standard Lua metatable pattern:

```lua
--- @class pack.Foo
--- @field private _config pack.Foo.Config
local Foo = {}
Foo.__index = Foo           -- set __index directly on the class table

function Foo.new(config)    -- constructor is a plain function (dot syntax)
  return setmetatable({ _config = config }, Foo)
end

function Foo:method()       -- instance methods use colon syntax
  return self._config.value
end

return Foo
```

- `__index` is always assigned on the class table itself, not in a separate metatable.
- Constructors (`new`) use dot-call syntax and are plain functions, not methods.
- Instance methods use colon-call syntax.
- Do **not** type the class table as the class (`--- @type pack.Foo` on `local Foo = {}`);
  let LuaLS infer the type from the `@class` annotation and metatable assignment.

---

## Type Annotations (LuaLS)

- All public functions must have `--- @param` and `--- @return` annotations.
- Class definitions live in `lua/pack/types.lua`. Inline annotations on method
  definitions in implementation files are the authoritative signatures.
- Use `--- @class`, `--- @field`, `--- @alias` in `types.lua` for shared types.
- Do **not** duplicate method signatures as `@field` entries on `@class` blocks —
  LuaLS resolves instance methods through the `__index` chain automatically.
- Mark private fields with `--- @field private`.
- Optional fields use the `?` shorthand: `--- @field name? string`.
- Suppress diagnostics only as a last resort. Prefer fixing the root cause.
  The `.luarc.json` currently suppresses `duplicate-doc-alias` and
  `duplicate-doc-field` for known LuaLS quirks.

---

## Error Handling

- This plugin has no user-facing error paths that require structured error handling.
- Use `vim.api.nvim_echo` (via the `notify` local in `init.lua`) for user-visible
  messages, not `print` or `error`.
- Prefer defensive `if type(fn) == "function" then` guards over `pcall` for optional
  callbacks — the plugin should degrade silently when optional hooks are absent.
- Do not use `assert()` in production code paths; it produces unformatted stack traces
  without Neovim context.

---

## Key Invariants

1. **No module-level mutable state** in `init.lua`. State that belongs to a `setup()`
   call must be local to that call or passed explicitly as function arguments.
2. **`vim.pack.add`** is called once per `setup()` / `PackReload` with all remote
   plugins batched into a single call — do not call it per-plugin.
3. **`Plugin:unload()`** clears all submodules (anything in `package.loaded` whose key
   equals or starts with `plugin_name .. "."`) via `ipairs` over the list returned by
   `get_submodules()`.
4. **GitHub shorthand** (`user/repo`) is expanded to a full HTTPS URL by `Plugin:get_src()`.
   Any `src` that already contains `://` is passed through unchanged.
5. **Auto-setup fallback**: if no `setup` callback is given for a plugin, `Plugin:setup()`
   falls back to calling `module.setup()` on the loaded Lua module if it exists.

---

## What to Avoid

- Do not add runtime dependencies. The plugin wraps only `vim.pack` (built into Neovim 0.11+).
- Do not use `table.insert` where the `t[#t + 1] = v` idiom suffices; prefer the latter.
- Do not use `pairs()` to iterate a list-table; use `ipairs()`.
- Do not expose internal helpers on the public module table `M`. Use `local function`.
- Do not call `vim.pack.add` with an empty table unnecessarily.
- Do not add `---@diagnostic disable` banners; fix the type annotation instead.
