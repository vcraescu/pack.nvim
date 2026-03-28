local GITHUB_PREFIX = "https://github.com/"

--- @class pack.Plugin
--- @field private _config pack.Plugin.Config
local M = {}
M.__index = M

--- @param path string
--- @return string
local function parse_name(path)
  local name = path:match("([^/]+)$") or ""
  return name:gsub("%.nvim$", ""):gsub("%.vim$", "")
end

--- @param config pack.Plugin.Config
--- @return pack.Plugin
function M.new(config)
  config = config or {}
  config.name = config.name or parse_name(config.src or config.dir or "")
  return setmetatable({ _config = config }, M)
end

--- @return string
function M:get_name()
  return self._config.name
end

--- @return boolean
function M:is_local()
  return self._config.dir ~= nil and self._config.dir ~= ""
end

--- @return boolean
function M:is_remote()
  return self._config.src ~= nil and self._config.src ~= ""
end

--- @return boolean
function M:is_inline()
  return not self:is_local() and not self:is_remote()
end

--- @return string
function M:get_src()
  local src = self._config.src or ""

  if not src:match("^%a+://") then
    src = GITHUB_PREFIX .. src
  end

  return src
end

--- @return table?
function M:get_module()
  return package.loaded[self:get_name()]
end

--- @return string[]
function M:get_submodules()
  local name = self:get_name()
  local modules = {}

  for mod in pairs(package.loaded) do
    if mod == name or vim.startswith(mod, name .. ".") then
      modules[#modules + 1] = mod
    end
  end

  return modules
end

function M:setup()
  local fn = self._config.setup

  if type(fn) ~= "function" then
    local mod = self:get_module()
    if mod and type(mod) == "table" then
      fn = mod.setup
    end
  end

  if type(fn) == "function" then
    pcall(fn)
  end
end

function M:deactivate()
  local fn = self._config.deactivate

  if type(fn) ~= "function" then
    local mod = self:get_module()
    if mod and type(mod) == "table" then
      fn = mod.deactivate
    end
  end

  if type(fn) == "function" then
    pcall(fn)
  end
end

function M:load_local()
  vim.opt.runtimepath:append(vim.fs.normalize(self._config.dir))
end

function M:unload()
  self:deactivate()

  for _, mod_name in ipairs(self:get_submodules()) do
    local mod = package.loaded[mod_name]

    if mod and type(mod) == "table" and type(mod.deactivate) == "function" then
      pcall(mod.deactivate)
    end

    package.loaded[mod_name] = nil
  end
end

return M
