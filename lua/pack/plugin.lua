local GITHUB_PREFIX = "https://github.com/"

--- @class pack.Plugin
local M = {
  --- @class pack.Plugin.Config
  --- @field src? string
  --- @field dir? string
  --- @field setup? fun()
  --- @field deactivate? fun()
  --- @field name? string
  _config = nil,
}

local function parse_name(path)
  local name = path:match("([^/]+)$") or ""

  return name:gsub("%.nvim$", ""):gsub("%.vim$", "")
end

--- @param config pack.Plugin.Config
function M.new(config)
  config = config or {}
  config.setup = config.setup or function() end
  config.deactivate = config.deactivate or function() end
  config.name = config.name or parse_name(config.src or config.dir or "")

  assert(config.src or config.dir, "Plugin must have either 'src' or 'dir'")

  return setmetatable({ _config = config }, { __index = M })
end

--- @return string
function M:name()
  return self._config.name
end

--- @return boolean
function M:is_local()
  return self._config.dir ~= nil and self._config.dir ~= ""
end

--- @return string
function M:src()
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
  self._config.setup()
end

function M:deactivate()
  self._config.deactivate()
end

function M:load_local()
  if not self:is_local() then
    return
  end

  vim.opt.runtimepath:append(vim.fs.normalize(self._config.dir))
end

function M:unload()
  local name = self:name()

  self:deactivate()

  package.loaded[name] = nil

  for module_name, _ in pairs(self:_get_modules()) do
    local module = package.loaded[module_name]

    if module and type(module.deactivate) == "function" then
      module.deactivate()
    end

    package.loaded[module_name] = nil
  end
end

--- @private
function M:_get_modules()
  local name = self:name()
  local modules = {}

  for mod, _ in pairs(package.loaded) do
    if mod == name or vim.startswith(mod, name .. ".") then
      table.insert(modules, mod)
    end
  end

  return modules
end

return M
