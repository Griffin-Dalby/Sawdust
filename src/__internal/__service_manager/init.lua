--[[

    Sawdust Service Manager

    Griffin E. Dalby
    2025.06.17

    This internal implementation will start all Services from the builder.
    It is to be called from the Sawdust module in a script, and gradually
    register services, and finally resolve them.

--]]

--]] Modules
local promise = require(script.Parent.Parent.__impl.promise)

--]] Service Manager
local svcManager = {}
svcManager.__index = svcManager

type self = {
    _registry: {},
    _instances: {},
    _states: {}
}
export type SawdustSVCManager = typeof(setmetatable({} :: self, svcManager))

--[[
    Creates a new Service Manager, in which services can be gradually
    registered (initalized), and resolved. (started)

    @return SawdustSVCManager
]]
function svcManager.new(): SawdustSVCManager
    local self = setmetatable({} :: self, svcManager)

    self._registry = {}
    self._instances = {}
    self._states = {}

    return self
end

--[[
    Registers a service to the Service Manager.<br>
    Services are created through the **builder** interface.

    @param service Builder service constructor
]]
function svcManager:Register(service)
    self._registry[service.id] = service
end

@deprecated
function svcManager:register(service)
    return self:Register(service) end

--[[
    Resolves a specific service, and invokes the "init" runtime in the
    service's lifecycle.
    
    @param id ID of the service to resolve

    @return SawdustPromise
]]
function svcManager:_resolve(id: string) : promise.SawdustPromise
    return promise.new(function(resolve, reject)
        if self._instances[id] then
            resolve(self._instances[id])
            return end

        if self._states[id] == 'init' then
            reject(`Attempt to resolved an already initalizing service!\nThis may be due to a circular dependency, check your dependency tree!`)
            return end

        local builder = self._registry[id]
        if not builder then
            reject(`Attempt to resolve an unregistered service "{id}"!\nAlso make sure it is being properly registered to the Service Manager.\nMake sure the service name is correct.`)
            return end

        self._states[id] = 'init'

        local deps = {}
        for _, depName in ipairs(builder.dependencies) do
            local s, e = self:_resolve(depName):wait()
            if s then deps[depName] = e; continue end

            reject(`Failed to load dependency "{depName}", provided error:\n{e}`)
        end

        if builder._initfn then
            builder._initfn(builder, deps)
            for _, injection in pairs(builder.injections.init) do
                injection:run(builder, deps) end
        end

        self._instances[id] = builder
        self._states[id] = 'ready'

        resolve(builder)
    end)
end

--[[
    Starts a specific resolved service, invoking the "start" runtime in
    the service's lifecycle.
    
    @param id ID of the service to start

    @return SawdustPromise
]]
function svcManager:_start(id: string) : promise.SawdustPromise
    return promise.new(function(resolve, reject)
        local instance = self._instances[id]
        if not instance then
            reject(`Attempt to start unresolved service "{id}"!\nMake sure the service is being resolved somewhere along the chain before starting.\nAdditionaly, ensure the service name is correct.`)
            return end
        
        local builder = self._registry[id]
        if builder._startfn then
            local returned = builder._startfn(instance)
            if returned then self._instances[id] = returned end
            for _, injection in pairs(builder.injections.start) do
                injection:run(instance) end
            self._states[id] = 'started'
        end

        resolve()
    end)
end

--[[
    Resolves all registered, but unresolved (initalized) services.
    
    @param timeout? Maximum allowed time (in seconds) until timeout rejection gets triggered. Default is 3.
]]
function svcManager:ResolveAll(timeout: number?)
    timeout=timeout or 3

    for name in pairs(self._registry) do
        local s, e = self:_resolve(name):wait(timeout)
        if not s then
            error(`Issue occured while resolving service "{name}"!\n{e}`)
        end
    end
end

@deprecated
function svcManager:resolveAll(timeout: number?)
    return self:ResolveAll(timeout) end

--[[
    Starts all registered, and resolved (initalized) services. 
    
    @param timeout? Maximum allowed time (in seconds) until timeout rejection gets triggered. Default is 5
]]
function svcManager:StartAll(timeout: number?)
    timeout=timeout or 5

    for name in pairs(self._registry) do
        local s, e = self:_start(name):wait(timeout)
        if not s then
            error(`Issue occured while starting service "{name}"!\n{e}`)
        end
    end
end

@deprecated
function svcManager:startAll(timeout: number?)
    return self:StartAll(timeout) end

--[[
    Gets a specific registered, and started service.

    @param id ID of the service to fetch.
]]
function svcManager:GetService(id: string)
    local instance = self._instances[id]
    if not instance then
        warn(`[{script.Name}] Failed to find service w/ name "{id}"!`)
        return end

    return instance
end

@deprecated
function svcManager:getService(id: string)
    return self:GetService(id) end

return svcManager