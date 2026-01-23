--!strict
--[[

    Networking Router

    Griffin Dalby
    2025.08.06

    This module provides networking w/ a router object, which will allow
    the developer to easily "route" calls depending on the intent.

--]]

--]] Services
--]] Modules
local net_root = script.Parent.Parent

--> Networking logic
local types = require(net_root.types)
local middleware = require(script.Parent.middleware)

--> Sawdust
local __impl = net_root.Parent

local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Router
local router = {} :: types.methods_router
router.__index = router

function router.new(event: types.NetworkingEvent) : types.NetworkingRouter
    local self = setmetatable({} :: types.self_router, router)

    self.__middleware = middleware.new{'before'} --] Lock "before" phase

    self.__routes = {}
    self.__listener = event:handle(function(req, res)
        local intent = req.intent
        if (not self.__routes[intent]) and (not self.__on_any) then return nil end

        local success, return_pipeline: types.NetworkingPipeline = pcall(
            self.__middleware.run,
            self.__middleware, 'after',
            {_call = {intent = intent, data = req.data}} :: types.NetworkingCall
        )
            
        if not success then
            error(`failed to run middleware for router!{if (return_pipeline and type(return_pipeline)=='string') then
                `\nProvided error message: {return_pipeline}` else " No error was provided."}`)
            return nil
        end

        req.data = return_pipeline:getData()
        req.intent = return_pipeline:getIntent()

        if return_pipeline:isHalted() then
            if return_pipeline:getError() then
                error(`middleware has halted router execution!\nProvided error message: {return_pipeline:getError()}`)
            end

            return nil
        end

        if self.__routes[intent] then
            self.__routes[intent](req, res)
        elseif self.__on_any then
            self.__on_any(req, res)
        end

        return nil
    end)

    return self
end



function router:UseMiddleware(order: number, callback: (pipeline: types.NetworkingPipeline) -> types.NetworkingPipeline) : types.NetworkingRouter
    self.__middleware:use('after', order, callback,
        { internal = false, protected = false })
    return self
end

@deprecated
function router:useMiddleware(order: number, callback: (pipeline: types.NetworkingPipeline) -> nil) : types.NetworkingRouter
    return self:UseMiddleware(order, callback) end



function router:OnAny(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    assert(self, `Attempt to call :onAny() without constructing router!`)

    assert(callback, `:onAny() argument 1 missing! (callback: (req, res) -> nil)`)

    self.__on_any = callback
    return self
end

@deprecated
function router:onAny(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    return self:OnAny(callback) end




function router:On(intent: string, callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    assert(self, `Attempt to call :on() without constructing router!`)

    assert(intent, `:on() argument 1 missing! (intent: string)`)
    assert(callback, `:on() argument 2 missing! (callback: (req, res) -> nil)`)
    assert(not self.__routes[intent], `Router already has a route for intent "{intent}!"`)

    self.__routes[intent] = callback
    return self
end

@deprecated
function router:on(intent: string, callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    return self:On(intent, callback) end


    

function router:Discard()
    assert(self, `Attempt to call :destroy() without constructing router!`)

    self.__listener:disconnect()
    table.clear(self.__routes)
    table.clear(self)

    return nil
end

@deprecated
function router:discard()
    return self:discard() end

return router