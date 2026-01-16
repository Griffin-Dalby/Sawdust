--!strict
--[[

    Networking Middleware

    Griffin Dalby
    2025.07.06


--]]
    
--]] Modules
local net_root = script.Parent.Parent

--> Networking logic
local types = require(net_root.types)
local pipeline = require(script.Parent.pipeline)

--> Sawdust implementations
local __impl = net_root.Parent

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Channel
local middleware = {} :: types.methods_middleware
middleware.__index = middleware

--[[
    "Middleware" provides a environment allowing developers to inject
    code into the event lifecycle, exposing access to the "pipeline"
    where you can further modify information about the call.
    
    @param locked_phases You can lock 'before' or 'after' phases from being hooked.

    @return NetworkingMiddleware
]]
function middleware.new(locked_phases: {string}?) : types.NetworkingMiddleware?
    local self = setmetatable({} :: types.self_middleware, middleware)

    self.__locked_phases = locked_phases or {}
    for i, v in pairs(self.__locked_phases) do
        if not table.find({'before', 'after'}, v) then
            error(`invalid phase lock "{v}"!`); return nil end
    end

    --> Generate Registry
    self.__registry = {
        __internal = {
            before = {},
            after = {},
        },

        before = {},
        after = {}
    }

    return self
end

--[[
    Registers a callback to be used in a specific order during a specific
    phase.<br>

    If the order's already in use, it'll be replaced by this
    one unless it's protected.

    @param phase Middleware's lifecycle; "before", or "after.
    @param order Order in execution chain
    @param callback Function to call during execution
]]
function middleware:Use(phase: string, order: number, callback: (types.NetworkingPipeline) -> types.NetworkingPipeline, args: {internal: boolean, protected: boolean})
    --> Check phase-lock
    if table.find(self.__locked_phases, phase) then
        error(`attempt to use a locked phase "{phase}"!`)
        return nil end

    --> Find registrar
    args = args or {
        internal = false,
        protected = false
    }
    local registrar = args.internal and self.__registry.__internal or self.__registry
    
    --> Create registeredFunc
    assert(registrar[phase], `[{script.Name}] Phase "{phase or '<none provided>'}" isn't valid!`)
    local registeredFunc = {} :: types.__registered_func__

    registeredFunc.order = order
    registeredFunc.callback = function(pipeline)
        callback(pipeline)
        return pipeline
    end
    registeredFunc.protected = args.protected

    --> Register
    local registered = registrar[phase][order]
    if registered then
        if not registered.protected then
            registrar[phase][order] = registeredFunc
        else
            error(`[{script.Name}] Attempt to overwrite protected entry!`)    
        end
    else
        table.insert(registrar[phase], registeredFunc)
    end
    
    table.sort(registrar[phase], function(a: {order: number}, b)
        return a.order < b.order
    end)

    return nil
end

--[[
    Only to be called internally for the event lifecycle.
    Please don't call this unless you have a good reason! 
    
    @param phase Either 'before' or 'after'
    @param args Call Arguments
]]
function middleware:Run(phase: 'before'|'after', args: types.NetworkingCall): types.NetworkingPipeline
    local registry = self.__registry :: {[string]: types.__registered_func__}
    local run_phase = registry[phase] :: {types.__registered_func__}
    
    assert(run_phase, `[{script.Name}] Phase "{phase or '<none provided>'}" isn't valid!`)

    local run_pipeline = pipeline.new(phase, args)

    for i, data in ipairs(run_phase) do
        data.callback(run_pipeline)
    end

    return run_pipeline
end

@deprecated
function middleware:run(phase: 'before'|'after', args: types.NetworkingCall): types.NetworkingPipeline
    return self:Run(phase, args) end

return middleware