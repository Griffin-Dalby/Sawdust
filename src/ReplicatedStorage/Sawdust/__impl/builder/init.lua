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
export type SawdustSVCInjection = typeof(setmetatable({} :: self, injection))

function injection.new(fn: (...any) -> ...any)
    local self = setmetatable({} :: self, injection)

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

    _initfn: (...any) -> ...any,
    _startfn: (...any) -> ...any,

    injections: {
        init: {SawdustSVCInjection},
        start: {SawdustSVCInjection}
    },

    dependencies: {[number]: string}
}
export type SawdustService = typeof(setmetatable({} :: self, builder))

--[[ builder.new(id: string)
    Constructor for the builder object.
    Service will be injected into the game w/ the *id*]]
function builder.new(id: string): SawdustService
    local self = setmetatable({} :: self, builder)

    self.id = id

    self._initfn = function() end
    self._startfn = function() end

    self.injections = {
        init = {},
        start = {}
    }

    self.dependencies = {}

    return self
end

--[[ builder:dependsOn(...string)
    Requires that this service be loaded AFTER services defined in tuple. ]]
function builder:dependsOn(...)
    self.dependencies = {...}
    return self
end

--[[ builder:init(fn)
    Attaches a function into the initalize runtime ]]
function builder:init(fn: (...any) -> ...any)
    self._initfn = fn
    return self
end

--[[ builder:start(fn)
    Attaches a function into the start runtime ]]
function builder:start(fn: (...any) -> ...any)
    self._startfn = fn
    return self
end

--[[ builder:method(name: string, callback: (self: self, ...any) -> ...any)
    Adds a new method to this service, that can be called from outside the service. ]]
function builder:method(name: string, callback: (self, ...any) -> ...any)
    if self[name] then
        warn(`[{script.Name}:method()] Cannot override value "{name}".`)
        return self end

    self[name] = function(...)
        return callback(self, ...) end
    return self
end

--[[ builder:inject(phase: string, fn)
    Adds an injection into a specified phase. ]]
function builder:inject(phase: string, fn: (...any) -> ...any)
    if not self.injections[phase] then
        warn(`[{script.Name}] Invalid injection phase "{phase or '<none provided>'}"`)
        return self end

    local inj = injection.new(fn)
    table.insert(self.injections[phase], inj)
    
    return self
end

return builder