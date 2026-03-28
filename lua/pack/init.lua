local Plugin = require("pack.plugin")

local M = {}

--- @param msg string
--- @param hl string
local function notify(msg, hl)
  vim.api.nvim_echo({ { "[Pack] ", "Conceal" }, { msg, hl } }, true, {})
end

--- @param plugins pack.Plugin[]
local function load_plugins(plugins)
  local remote = {}

  for _, plugin in ipairs(plugins) do
    if plugin:is_local() then
      plugin:load_local()
    elseif plugin:is_remote() then
      remote[#remote + 1] = { src = plugin:get_src() }
    end
  end

  vim.pack.add(remote, { load = true, confirm = false })

  for _, plugin in ipairs(plugins) do
    plugin:setup()
  end
end

--- @param plugins pack.Plugin[]
local function unload_plugins(plugins)
  for _, plugin in ipairs(plugins) do
    plugin:unload()
  end
end

--- @param plugins pack.Plugin[]
--- @param after pack.Hook
local function setup_commands(plugins, after)
  vim.api.nvim_create_user_command("PackReload", function()
    unload_plugins(plugins)
    load_plugins(plugins)
    setup_commands(plugins, after)
    after()

    vim.schedule(function()
      notify("Plugins reloaded", "OkMsg")
    end)
  end, { force = true })

  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { force = true })

  local function installed_pkg_names()
    local names = {}
    for _, pkg in ipairs(vim.pack.get()) do
      names[#names + 1] = vim.fn.fnamemodify(pkg.path, ":t")
    end
    return names
  end

  vim.api.nvim_create_user_command("PackDel", function(opts)
    vim.pack.del(opts.fargs)
  end, {
    nargs = "+",
    complete = installed_pkg_names,
  })

  vim.api.nvim_create_user_command("PackGet", function(opts)
    if #opts.fargs > 0 then
      print(vim.inspect(vim.pack.get(opts.fargs)))
    else
      print(vim.inspect(vim.pack.get()))
    end
  end, {
    nargs = "*",
    complete = installed_pkg_names,
  })
end

--- @param config pack.Config
function M.setup(config)
  config = config or {}

  local plugins = {}
  for i, spec in ipairs(config.plugins or {}) do
    plugins[i] = Plugin.new(spec)
  end

  local after = config.after or function() end

  load_plugins(plugins)
  setup_commands(plugins, after)
  after()
end

return M
