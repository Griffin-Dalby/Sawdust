--[[

    Sawdust Service Builder

    Griffin E. Dalby
    2025.06.17

    This implementation allows developers to create new "Services" that
    can depend on eachother and functions can be injected into their
    runtimes.

--]]

--]] Settings
local __internal = script.Parent.Parent.__internal
local __settings = require(__internal.__settings)
local __service_manager = require(__internal.__service_manager)

--]] Injection
local injection = {}
injection.__index = injection

type self_injection = {
    fn: (...any) -> ...any
}
export type SawdustSVCInjection = typeof(setmetatable({} :: self_injection, injection))

function injection.new(fn: (...any) -> ...any)
    local self = setmetatable({} :: self_injection, injection)

    self.fn = fn

    return self
end

function injection:run(...)
    self.fn(...)
end

--]] Builder
local builder = {}
builder.__index = builder

type self = {
    id: string,

    _initfn: (self:  SawdustService, deps: {}, ...any) -> ...any,
    _startfn: (self: SawdustService, ...any) -> ...any,

    injections: {
        init: {SawdustSVCInjection},
        start: {SawdustSVCInjection}
    },

    dependencies: {[number]: string},
    meta: {string: {}}
}
export type SawdustService = typeof(setmetatable({} :: self, builder))

--[[
    Constructor for the builder object. This instance is used to construct new
    Sawdust Services, allowing you to compose the service before registering &
    starting it.

    @param id Internal identifier for this service

    @return SawdustService
]]
function builder.new(id: string): SawdustService
    local self = setmetatable({} :: self, builder)

    self.id = id

    self._initfn = function() end
    self._startfn = function() end

    self.injections = {
        init = {},
        start = {}
    }

    self.meta = {}
    self.dependencies = {}

    return self
end

--[[
    Requires that this service be loaded AFTER services defined in tuple.
    Also provides a direct reference to all dependencies in the initalization
    function.

    @param tuple<string> Dependencies
]]
function builder:dependsOn(...)
    self.dependencies = {...}
    return self
end

--[[
    Attaches a function into the initalize runtime, this is where you'll
    prepare the service to be started. Treat this like a constructor.

    @param init_fn Init function
]]
function builder:init(init_fn: (self: SawdustService, deps: {[string]: SawdustService}) -> ...any)
    self._initfn = init_fn
    return self
end

--[[
    Attaches a function to the start runtime, this is where all post-init
    & runtime logic should go.

    @param start_fn Start runtime function
]]
function builder:start(start_fn: (self: SawdustService) -> ...any)
    self._startfn = start_fn
    return self
end

--[[
    Adds a new method to this service, that can be called from outside
    of this service using the format: `service.method(args)`.

    The callback provides a direct reference to the service & it's properties
    (specifically for runtime properties) as the first argument.

    @param name Name of the method that will be attributed.
    @param callback Function that will be called when this method is invoked.
]]
function builder:method(name: string, callback: (self: SawdustService|{any}, ...any) -> ...any)
    if self[name] then
        warn(`[{script.Name}:method()] Cannot override value "{name}".`)
        return self end

    self[name] = function(...)
        return callback(self, ...) end
    return self
end

--[[
    Adds an injection into a specified phase, either 'init' or 'start'.
    An "injection" is code that runs before the phase occurs, allowing
    more flexability.

    @param phase Phase to inject into, either 'init' or 'start'.
    @param inject_fn Function to inject.
]]
function builder:inject(phase: string, inject_fn: (...any) -> ...any)
    if not self.injections[phase] then
        warn(`[{script.Name}] Invalid injection phase "{phase or '<none provided>'}"`)
        return self end

    local inj = injection.new(inject_fn)
    table.insert(self.injections[phase], inj)
    
    return self
end

--[[
    Loads asset metadata from a provided folder, allowing the service to access
    assets at runtime. This gets injected into the "meta" service parameter.
    
    @param meta Folder to scan & load meta.
]]
function builder:loadMeta(meta: Folder)
    for _, asset: Instance in ipairs(meta:GetChildren()) do
        if self.meta[asset.Name] then
            warn(`[{script.Name}:loadMeta()] Cannot override meta asset "{asset.Name}".`)
        return self end

        if asset:IsA("ModuleScript") then
            self.meta[asset.Name] = require(asset)
        else
            warn(`[{script.Name}:loadMeta()] Unsupported meta asset type "{asset.ClassName}" for asset "{asset.Name}".`)
        end
    end

    return self
end

return builder