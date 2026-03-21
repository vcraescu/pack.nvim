local M = {
  --- @type pack.Plugin[]
  _plugins = {},

  --- @type pack.Hook fun()
  _after = nil,
}

--- @private
--- @param msg string
--- @param hl string
function M._notify(msg, hl)
  vim.api.nvim_echo({ { "[Pack] ", "Conceal" }, { msg, hl } }, true, {})
end

function M._load_plugins()
  local pack_plugins = {}

  for _, plugin in ipairs(M._plugins) do
    if plugin:is_local() then
      plugin:load_local()
    else
      table.insert(pack_plugins, { src = plugin:src() })
    end
  end

  vim.pack.add(pack_plugins, { load = true, confirm = false })

  for _, plugin in ipairs(M._plugins) do
    plugin:setup()
  end
end

--- @private
function M._unload_plugins()
  for _, plugin in ipairs(M._plugins) do
    plugin:unload()
  end
end

--- @private
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

--- @private
function M._create_pack_update_command()
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { force = true })
end

--- @private
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

--- @private
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

--- @private
function M._setup_commands()
  M._create_pack_reload_command()
  M._create_pack_update_command()
  M._create_pack_del_command()
  M._create_pack_get_command()
end

--- @param config pack.Config { plugins: pack.Plugin.Config[], after?: fun() }
function M.setup(config)
  config = config or {}
  config.plugins = config.plugins or {}

  for i, plugin in ipairs(M._plugins) do
    M._plugins[i] = M.new(plugin)
  end

  M._after = config.after or function() end

  M._load_plugins()
  M._setup_commands()
  M._after()
end

return M
