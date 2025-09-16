--[[

    Sawdust Service Manager

    Griffin E. Dalby
    2025.06.17

    This internal implementation will start all Services from the builder.
    It is to be called from the Sawdust module in a script, and gradually
    register services, and finally resolve them.

--]]

--]] Service Manager
local svcManager = {}
svcManager.__index = svcManager

type self = {
    _registry: {},
    _instances: {},
    _states: {}
}
export type SawdustSVCManager = typeof(setmetatable({} :: self, svcManager))

--[[ svcManager.new()
    Creates a new Service Manager, in which services can be gradually registered, and resolved.]]
function svcManager.new(): SawdustSVCManager
    local self = setmetatable({} :: self, svcManager)

    self._registry = {}
    self._instances = {}
    self._states = {}

    return self
end

--[[ svcManager:register(service: SawdustService)
    Registers a service to the Service Manager. ]]
function svcManager:register(service)
    self._registry[service.id] = service
end

--[[ svcManager:_resolve(id: string)
    Resolves a specific service, and invokes the "init" runtime. ]]
function svcManager:_resolve(id: string)
    if self._instances[id] then
        return self._instances[id] end

    if self._states[id] == 'init' then
        warn(`[{script.Name}] Circular dependency detected on "{id}"`)
        return end

    self._states[id] = 'init'

    local builder = self._registry[id]
    if not builder then
        warn(`[{script.Name}] Service "{id}" not registered!`)
        return end

    local deps = {}
    for _, depName in ipairs(builder.dependencies) do
        deps[depName] = self:_resolve(depName) end

    if builder._initfn then
        local returned = builder._initfn(builder, deps)
        for _, injection in pairs(builder.injections.init) do
            injection:run(builder, deps) end
    end

    self._instances[id] = builder
    self._states[id] = 'ready'

    return builder
end

--[[ svcManager:_start(id: string)
    Starts a specific resolved service. ]]
function svcManager:_start(id: string)
    local instance = self._instances[id]
    if not instance then
        warn(`[{script.Name}] Cannot start unresolved service "{id}"!`)
        return end
    
    local builder = self._registry[id]
    if builder._startfn then
        local returned = builder._startfn(instance)
        if returned then self._instances[id] = returned end
        for _, injection in pairs(builder.injections.start) do
            injection:run(instance) end
    end
end

--[[ svcManager:resolveAll()
    Resolves all registered, unresolved services. ]]
function svcManager:resolveAll()
    for name in pairs(self._registry) do
        self:_resolve(name)
    end
end

--[[ svcManager:startAll()
    Starts all resolved services. ]]
function svcManager:startAll()
    for name in pairs(self._registry) do
        self:_start(name)
    end
end

--[[ svcManager:getService(name: string)
    Gets a specific instantiated service. ]]
function svcManager:getService(name: string)
    local instance = self._instances[name]
    if not instance then
        warn(`[{script.Name}] Failed to find service w/ name "{name}"!`)
        return end

    return instance
end

return svcManager