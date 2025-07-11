--[[

    Sawdust Networking Middleware

    Griffin E. Dalby
    2025.06.15

    This provides middleware functionality to the sawdust networking
    module, allowing developers to easily add code to run before/after
    events on either server or client.

    Also exposes access to a wrapped "pipeline" instance allowing said
    developer to modify many things, which will in fact be listed here.
    
    NOTE: These are all for the 'before' phase... you obviously can't
    modify data AFTER the event's been called.

    - args: Dictionary exposing the data being passed to it's destination.
            You can modify this to change what the other end will recieve
            from the specific request.

    - halted: If true, the event will not be sent to it's destination.
    - errorMessage: If provided, explains reason for halting.

    - writeLock: Don't change, only used to prevent unusual behavior.
                 Nothing good can come from modifying this value.

--]]

--]] Middleware Result
local pipeline = {}
pipeline.__index = pipeline

type self_middle_pipeline = {}
export type SawdustNetworkingMiddlewarePipeline = typeof(setmetatable({} :: self_middle_pipeline, pipeline))

function pipeline.new(phase: string, args: {[number]: any}) : SawdustNetworkingMiddlewarePipeline
    local self = setmetatable({} :: self_middle_pipeline, pipeline)

    self.args = phase == 'before' and args or nil
    self.res = phase == 'after' and args or nil

    self.halted = false
    self.errorMessage = nil

    self.writeLock = (phase == 'after')

    return self
end

function pipeline:setArguments(args: {[number]: any}) : boolean
    if self.writeLock then warn(`[{script.Name}] WriteLock enabled! Cannot set args.`) return false end
    self.args = args; return true end

function pipeline:setResult(res: {[number]: any}): boolean
    self.res = res; return true end

function pipeline:setHalted(halted: boolean) : boolean
    if self.writeLock then warn(`[{script.Name}] WriteLock enabled! Cannot halt.`) return false end
    self.halted = halted; return true end

function pipeline:setError(message: string) : boolean
    if self.writeLock then warn(`[{script.Name}] WriteLock enabled! Cannot set error.`) return false end
    self.errorMessage = message; return true end

function pipeline:getArguments() : ...any
    return self.args end
function pipeline:getResult(): {[number]: any}
    return self.res end
function pipeline:isHalted() : boolean
    return self.halted end
function pipeline:getError() : string?
    return self.errorMessage end
function pipeline:canWrite() : boolean
    return self.writeLock end

--]] Middleware
local middleware = {}
middleware.__index = middleware

type _registered_func_ = {
    order: number,
    callback: (SawdustNetworkingMiddlewarePipeline) -> SawdustNetworkingMiddlewarePipeline
}

type self = {
    __registry: {
        before: {[number]: _registered_func_},
        after: {[number]: _registered_func_}
    }
}
export type SawdustNetworkingMiddleware = typeof(setmetatable({} :: self, middleware))

--[[ middleware.new()
    This module provides a middleware handler for my networking module.
    It allows developers to attach functions to different parts of the event lifecycle. ]]
function middleware.new() : SawdustNetworkingMiddleware
    local self = setmetatable({} :: self, middleware)

    self.__registry = {
        before = {},
        after = {}
    }

    return self
end

--[[ Middleware:use(phase: string, order: number, callback: (pipeline) -> pipeline)
    Registers "callback" to be used through the middleware. ]]
function middleware:use(phase: string, order: number, callback: (SawdustNetworkingMiddlewarePipeline) -> SawdustNetworkingMiddlewarePipeline)
    assert(self.__registry[phase], `[{script.Name}] Phase "{phase or '<none provided>'}" isn't valid!`)
    local registeredFunc = {} :: _registered_func_

    registeredFunc.order = order
    registeredFunc.callback = function(pipeline)
        callback(pipeline)
        return pipeline
    end

    table.insert(self.__registry[phase], registeredFunc)
    table.sort(self.__registry[phase], function(a, b)
        return a.order < b.order
    end)
end

--[[ Middleware:run(phase: string)
    Only to be called internally for the event lifecycle.
    Please don't call thin unless you have a good reason! ]]
function middleware:run(phase: string, args: {[number]: any}): SawdustNetworkingMiddlewarePipeline
    assert(self.__registry[phase], `[{script.Name}] Phase "{phase or '<none provided>'}" isn't valid!`)

    local runphase = self.__registry[phase]
    local runpipeline = pipeline.new(phase, args)

    for i, data: _registered_func_ in ipairs(runphase) do
        data.callback(runpipeline)
    end

    return runpipeline
end

return middleware