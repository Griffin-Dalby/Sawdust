--[[

    Networking Middleware

    Griffin Dalby
    2025.07.06


--]]
    
--]] Modules
--> Networking logic
local types = require(script.Parent.types)
local pipeline = require(script.Parent.pipeline)

--> Sawdust implementations
local __impl = script.Parent.Parent

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Channel
local middleware = {}
middleware.__index = middleware

--[[ middleware.new()
    "Middleware" provides a environment allowing developers to inject
    code into the event lifecycle, exposing access to the "pipeline"
    where you can further modify information about the call ]]
function middleware.new(locked_phases: {}?) : types.NetworkingMiddleware?
    local self = setmetatable({} :: types.self_middleware, middleware)

    self.__locked_phases = locked_phases or {}
    for i, v in pairs(self.__locked_phases) do
        if not table.find({'before', 'after'}, v) then
            error(`invalid phase lock "{v}"!`); return end
    end

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

--[[ middleware:use()
    Registers *callback to be used at the specified *order in the
    *phase. If the order's already in use, it'll be replaced by this
    one unless it's protected. ]]
function middleware:use(phase: string, order: number, callback: (types.NetworkingPipeline) -> types.NetworkingPipeline, args: {internal: boolean, protected: boolean})
    --> Check phase-lock
    if table.find(self.__locked_phases, phase) then
        error(`attempt to use a locked phase "{phase}"!`)
        return end

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
            warn(`[{script.Name}] Attempt to overwrite protected entry!`)    
        end
    else
        table.insert(registrar[phase], registeredFunc)
    end
    
    table.sort(registrar[phase], function(a, b)
        return a.order < b.order
    end)
end

--[[ Middleware:run(phase: string)
    Only to be called internally for the event lifecycle.
    Please don't call this unless you have a good reason! ]]
function middleware:run(phase: string, args: {[number]: any}): types.NetworkingPipeline
    assert(self.__registry[phase], `[{script.Name}] Phase "{phase or '<none provided>'}" isn't valid!`)

    local runphase = self.__registry[phase]
    local runpipeline = pipeline.new(phase, args)

    for i, data: types.__registered_func__ in ipairs(runphase) do
        data.callback(runpipeline)
    end

    return runpipeline
end

return middleware