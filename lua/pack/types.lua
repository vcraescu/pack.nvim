--- @class pack.Config
--- @field plugins? pack.Plugin.Config[]
--- @field after? pack.Hook

--- @class pack.Plugin.Config
--- @field src? string      GitHub shorthand (user/repo) or full URL
--- @field dir? string      Path to a local plugin directory
--- @field name? string     Override the derived module name
--- @field setup? fun()     Called after the plugin is added to the runtimepath
--- @field deactivate? fun() Called before the plugin is unloaded

--- @class pack.Plugin
--- @field private _config pack.Plugin.Config
--- @field new fun(config: pack.Plugin.Config): pack.Plugin

--- @alias pack.Hook fun()
