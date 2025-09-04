--[[

    Networking Router

    Griffin Dalby
    2025.08.06

    This module provides networking w/ a router object, which will allow
    the developer to easily "route" calls depending on the intent.

--]]

--]] Services
--]] Modules
--> Networking logic
local types = require(script.Parent.types)
local middleware = require(script.Parent.middleware)

--> Sawdust
local __impl = script.Parent.Parent

local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Router
local router = {}
router.__index = router

--[[ router.new()
    This will return a new router object. ]]
function router.new(event: types.NetworkingEvent) : types.NetworkingRouter
    local self = setmetatable({} :: types.self_router, router)

    self.__middleware = middleware.new{'before'} --] Lock "before" phase

    self.__routes = {}
    self.__listener = event:handle(function(req, res)
        local intent = req.intent
        if (not self.__routes[intent]) and (not self.__on_any) then return end

        local return_pipeline: types.NetworkingPipeline = pcall(
            self.__middleware.run,
            self.__middleware, 'after',
            {_intent = intent, _data = req.data})
            
        req.data = return_pipeline:getData()
        req.intent = return_pipeline:getIntent()

        if return_pipeline:isHalted() then
            error(`middleware has halted router execution!`)

            if return_pipeline:getError() then
                warn(`[{script.Name}] A message was provided: "{return_pipeline:getError()}"`)
                return end
        end

        self.__routes[intent](req, res)
        if self.__on_any then
            self.__on_any(req, res) end
    end)

    return self
end

--[[ router:useMiddleware(order: number, callback: (pipeline) -> nil)
    This will add a middleware that will run each time this router
    is activated.
    
    "activated" refers to when this event is called, and one of the
    routes are intended inside of the object. ]]
function router:useMiddleware(order: number, callback: (pipeline: types.NetworkingPipeline) -> nil) : types.NetworkingRouter
    self.__middleware:use('after', order, callback,
        { protected = false })
    return self
end

--[[ router:onAny(callback: (req, res) -> nil)
    Chainable function that will route any call to the remote despite
    intent to the provided callback. ]]
function router:onAny(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    assert(self, `Attempt to call :onAny() without constructing router!`)

    assert(callback, `:onAny() argument 1 missing! (callback: (req, res) -> nil)`)

    self.__on_any = callback
    return self
end

--[[ router:on(intent: string, callback: (req, res) -> nil)
    Chainable function that will add a new "route" to this router object.
    
    Whenever a new call is intercepted, it will be checked against the
    internal route list, and if a match is found it'll pass the req and res
    objects through. ]]
function router:on(intent: string, callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil) : types.NetworkingRouter
    assert(self, `Attempt to call :on() without constructing router!`)

    assert(intent, `:on() argument 1 missing! (intent: string)`)
    assert(callback, `:on() argument 2 missing! (callback: (req, res) -> nil)`)
    assert(not self.__routes[intent], `Router already has a route for intent "{intent}!"`)

    self.__routes[intent] = callback
    return self
end

--[[ router:discard()
    This will properly clean up the internal listener connection,
    and ]]
function router:discard()
    assert(self, `Attempt to call :destroy() without constructing router!`)

    self.__listener:disconnect()
    table.clear(self.__routes)
    table.clear(self)
end

return router