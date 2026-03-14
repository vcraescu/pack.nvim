local M = {
  --- @type pack.Plugin[]
  _plugins = {},

  --- @type pack.Hook
  _after = nil,
}

function M._notify(msg, hl)
  vim.api.nvim_echo({ { "[Pack] ", "Conceal" }, { msg, hl } }, true, {})
end

function M._load_plugins()
  local GITHUB_PREFIX = "https://github.com/"
  local pack_plugins = {}

  for _, plugin in ipairs(M._plugins) do
    if plugin.dir then
      vim.opt.runtimepath:append(vim.fs.normalize(plugin.dir))
    elseif plugin.src then
      if not plugin.src:match("^%a+://") then
        plugin.src = GITHUB_PREFIX .. plugin.src
      end

      table.insert(pack_plugins, plugin)
    end
  end

  vim.pack.add(pack_plugins, { load = true, confirm = false })

  for _, plugin in ipairs(M._plugins) do
    if plugin.setup ~= nil then
      plugin.setup()
    end
  end
end

function M._plugin_module_name(plugin)
  local path = plugin.src or plugin.dir or ""
  local name = path:match("([^/]+)$") or ""

  return name:gsub("%.nvim$", ""):gsub("%.vim$", "")
end

function M._unload_plugins()
  local stems = {}

  for _, plugin in ipairs(M._plugins) do
    local mod = M._plugin_module_name(plugin)

    if mod ~= "" then
      stems[mod] = true
    end
  end

  for name, _ in pairs(package.loaded) do
    local mod_stem = name:match("^([^%.]+)")

    if mod_stem and stems[mod_stem] then
      package.loaded[name] = nil
      M._notify("Plugin unloaded " .. name, "WarningMsg")
    end
  end
end

function M._create_pack_reload_command()
  vim.api.nvim_create_user_command("PackReload", function()
    M._unload_plugins()
    M._load_plugins()
    M._setup_commands()
    M._after()

    vim.schedule(function()
      M._notify("Plugins reloaded", "OkMsg")
    end)
  end, { force = true })
end

function M._create_pack_update_command()
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { force = true })
end

function M._create_pack_del_command()
  vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
  end, {
    nargs = "+",
    complete = function()
      local pkgs = {}

      for _, pkg in ipairs(vim.pack.get()) do
        table.insert(pkgs, vim.fn.fnamemodify(pkg.path, ":t"))
      end

      return pkgs
    end,
  })
end

function M._create_pack_get_command()
  vim.api.nvim_create_user_command("PackGet", function(opts)
    if #opts.fargs > 0 then
      print(vim.inspect(vim.pack.get(opts.fargs)))
    else
      print(vim.inspect(vim.pack.get()))
    end
  end, {
    nargs = "*",
    complete = function()
      local pkgs = {}

      for _, pkg in ipairs(vim.pack.get()) do
        table.insert(pkgs, vim.fn.fnamemodify(pkg.path, ":t"))
      end

      return pkgs
    end,
  })
end

function M._setup_commands()
  M._create_pack_reload_command()
  M._create_pack_update_command()
  M._create_pack_del_command()
  M._create_pack_get_command()
end

--- @param config pack.Config
function M.setup(config)
  M._plugins = config.plugins or {}
  M._after = config.after or function() end

  M._load_plugins()
  M._setup_commands()
  M._after()
end

return M
