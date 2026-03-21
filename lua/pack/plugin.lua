---@diagnostic disable: redundant-parameter, redundant-return-value
local GITHUB_PREFIX = "https://github.com/"

--- @type pack.Plugin
local M = {
  _config = {},
}

local function parse_name(path)
  local name = path:match("([^/]+)$") or ""

  return name:gsub("%.nvim$", ""):gsub("%.vim$", "")
end

--- @param config pack.Plugin.Config
function M.new(config)
  config = config or {}
  config.setup = config.setup
  config.deactivate = config.deactivate
  config.name = config.name or parse_name(config.src or config.dir or "")

  return setmetatable({ _config = config }, { __index = M })
end

--- @return string
function M:get_name()
  return self._config.name
end

--- @return boolean
function M:is_local()
  return self._config.dir ~= nil and self._config.dir ~= ""
end

function M:is_remote()
  return self._config.src ~= nil and self._config.src ~= ""
end

function M:is_inline()
  return not self:is_local() and not self:is_remote()
end

--- @return string
function M:get_src()
  if self:is_local() then
    return ""
  end

  local src = self._config.src or ""

  if not src:match("^%a+://") then
    src = GITHUB_PREFIX .. self._config.src
  end

  return src
end

function M:setup()
  local setup = self._config.setup

  if type(setup) ~= "function" then
    local mod = self:get_module()

    if mod and type(mod) == "table" then
      setup = mod.setup
    end
  end

  if type(setup) == "function" then
    setup()
  end
end

--- @return table?
function M:get_module()
  return package.loaded[self:get_name()]
end

function M:deactivate()
  local deactivate = self._config.deactivate

  if type(deactivate) ~= "function" then
    local mod = self:get_module()

    if mod and type(mod) == "table" then
      deactivate = mod.deactivate
    end
  end

  if type(deactivate) == "function" then
    deactivate()
  end
end

function M:load_local()
  if not self:is_local() then
    return
  end

  vim.opt.runtimepath:append(vim.fs.normalize(self._config.dir))
end

function M:unload()
  local name = self:get_name()

  self:deactivate()

  package.loaded[name] = nil

  for module_name, _ in pairs(self:get_submodules()) do
    local module = package.loaded[module_name]

    if module and type(module.deactivate) == "function" then
      module.deactivate()
    end

    package.loaded[module_name] = nil
  end
end

--- @return string[]
function M:get_submodules()
  local name = self:get_name()
  local modules = {}

  for mod, _ in pairs(package.loaded) do
    if mod == name or vim.startswith(mod, name .. ".") then
      table.insert(modules, mod)
    end
  end

  return modules
end

return M
