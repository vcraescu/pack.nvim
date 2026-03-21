--- @class pack.Config
--- @field plugins pack.Plugin.Config[]
--- @field after? fun()

--- @class pack.Plugin
--- @field _config pack.Plugin.Config
--- @field new fun(config: pack.Plugin.Config): pack.Plugin
--- @field get_name fun(): string
--- @field is_local fun(): boolean
--- @field is_remote fun(): boolean
--- @field is_inline fun(): boolean
--- @field get_src fun(): string
--- @field setup fun()
--- @field deactivate fun()
--- @field load_local fun()
--- @field get_submodules fun(): string[]
--- @field get_module fun(): table?

--- @class pack.Plugin.Config
--- @field src? string
--- @field dir? string
--- @field setup? fun()
--- @field deactivate? fun()
--- @field name? string

--- @alias pack.Hook fun()
