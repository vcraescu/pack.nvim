# Changelog

All notable changes to pack.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Initial implementation wrapping `vim.pack` (Neovim 0.11+)
- `setup()` entry point with declarative plugin list and `after` hook
- Support for GitHub shorthand (`user/repo`), full URLs, and local directories
- Per-plugin `setup` callback
- `:PackReload` command to hot-reload all Lua modules and re-run configuration
- `:PackUpdate` command to update installed plugins via `vim.pack.update()`
- `:PackDel` command with tab-completion to remove installed packages
- `:PackGet` command with tab-completion to inspect installed packages
- Vim help documentation (`doc/pack.txt`)
