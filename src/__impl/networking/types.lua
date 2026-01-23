--!strict
--[[

    Sawdust Networking Types

    Griffin Dalby
    2025.07.06

    Provides types for the networking implementation.

--]]

local types = {}

--> Sawdust implementations
local __impl = script.Parent.Parent

local promise = require(__impl.promise)
local cache = require(__impl.cache)

--=========--
-- CHANNEL --
--=========--
--#region

local channel = {}
channel.__index = channel

export type ChannelSettings = {
    returnFresh: boolean,
    replaceFresh: boolean
}

export type self_channel = {
    __channel: Folder,
    [string]: NetworkingEvent
}
export type methods_channel = {
    __index: methods_channel,
    get: (channel_name: string, settings: ChannelSettings?) -> NetworkingChannel,
}

export type NetworkingChannel = typeof(setmetatable({} :: self_channel, {} :: methods_channel))

--#endregion

--======--
-- CALL --
--======--
--#region

local call = {}
call.__index = call

export type self_call = {
    __event: RemoteEvent,
    __middleware: NetworkingMiddleware,

    --> Internal
    _return_id: string?,

    --> Broadcast Settings
    _broadcast: {
        global: boolean,
        targets: {Player}|nil,
        filter_type: 'include'|'exclude'|nil
    },

    --> Call Data
    _call: {
        data: {any},
        intent: string,
        timeout: number
    },
}

export type methods_call = {
    __index: methods_call,
    new: (event: NetworkingEvent) -> NetworkingCall,

    broadcastGlobally: (self: NetworkingCall) -> NetworkingCall,
    broadcastTo: (self: NetworkingCall, ...Player) -> NetworkingCall,
    setFilterType: (self: NetworkingCall, filterType: 'include'|'exclude') -> NetworkingCall,

    data: (self: NetworkingCall, ...any) -> NetworkingCall,
    intent: (self: NetworkingCall, intent: string) -> NetworkingCall,
    timeout: (self: NetworkingCall, seconds: number) -> NetworkingCall,

    fire: (self: NetworkingCall) -> NetworkingPipeline,
    invoke: (self: NetworkingCall) -> promise.SawdustPromise,

    setReturnId: (self: NetworkingCall, return_id: string?) -> NetworkingCall,
}
export type NetworkingCall = typeof(setmetatable({} :: self_call, {} :: methods_call))

--#endregion

--=======--
-- EVENT --
--=======--
--#region
local event = {}
event.__index = event

export type self_event = {
    --> Properties
    __event: RemoteEvent,
    __middleware: NetworkingMiddleware,
    __connections: { [string]: NetworkingConnection },

    __invoke_resolvers: {},
}  

export type methods_event = {
    --> Constructor
    __index: methods_event,
    new: (channel: NetworkingChannel, event: RemoteEvent|UnreliableRemoteEvent) -> NetworkingEvent,

    --> Methods

    --[[
        Opens a new "NetworkingCall", which allows you to compose a
        event request & send it.

        @return NetworkingCall
    ]]
    With: (self: NetworkingEvent) -> NetworkingCall,

    --[[
        Returns a NetworkingConnection that routes every call that
        arrives at the event, no matter the intent.

        @return NetworkingConnection
    ]]
    Handle: (self: NetworkingEvent, callback: (req: ConnectionRequest, res: ConnectionResult) -> nil) -> NetworkingConnection,
    
    --[[
        Returns a NetworkingRouter which allows the developer to
        selectively respond to certain intents that arrive at the
        event.

        @return NetworkingRouter
    ]]
    Route: (self: NetworkingEvent) -> NetworkingRouter,

    --[[
        Injects a new Middleware object into a specific Phase & Order.

        @param phase Either "Before", or "After" the event gets handled.
        @param order Execution order of this Middleware.
        @param callback Callback to run when middleware gets executed.
    ]]
    UseMiddleware: (self: NetworkingEvent, phase: string, order: number, callback: (pipeline: NetworkingPipeline) -> NetworkingPipeline, msettings: {protected: boolean}) -> nil,

    --> Deprecated Methods
    with: (self: NetworkingEvent) -> NetworkingCall,
    handle: (self: NetworkingEvent, callback: (req: ConnectionRequest, res: ConnectionResult) -> nil) -> NetworkingConnection,
    route: (self: NetworkingEvent) -> NetworkingRouter,
    useMiddleware: (self: NetworkingEvent, phase: string, order: number, callback: (pipeline: NetworkingPipeline) -> NetworkingPipeline, msettings: {protected: boolean}) -> nil,
}
export type NetworkingEvent = typeof(setmetatable({} :: self_event, {} :: methods_event))

--#endregion

--============--
-- CONNECTION --
--============--
--#region
local connection = {}
connection.__index = connection

export type raw_data = {
    caller: Player?,
    intent: string,
    data: { [any]: any },
}

export type self_connection = {
    --> Properties
    cache: cache.SawdustCache,
    connectionId: string,
    callback: (req: ConnectionRequest, res: ConnectionResult) -> nil,
    middleware: NetworkingMiddleware,

    --> Internal Methods
    removeFromEvent: () -> nil,
    returnCall: (body: raw_data & { returnId: string? }, caller: Player?) -> nil,
}
export type methods_connection = {
    __index: methods_connection,
    new: (callback: (req: ConnectionRequest, res: ConnectionResult) -> nil, event: NetworkingEvent) -> NetworkingConnection,

    --> Methods
    Run: (self: NetworkingConnection, raw_data: {}) -> nil,
    Disconnect: (self: NetworkingConnection) -> nil,

    --> Deprecated Methods
    run: (self: NetworkingConnection, raw_data: {}) -> nil,
    disconnect: (self: NetworkingConnection) -> nil,
}
export type NetworkingConnection = typeof(setmetatable({} :: self_connection, {} :: methods_connection))

-- req & res of Connections.
export type ConnectionRequest = {
    -- Player who called this event
    caller: Player?,


    -- Time request was sent (from client, untrustable.)
    sent_time: number,

    -- Time request arrived (to server, trustable.)
    arrival_time: number,

    -- Latency of request (server_time-req_time)
    latency: number,


    -- Intent of request
    intent: string,

    -- Data body of request
    data: {[number]: any?},

    
    -- Unmodified, pre-middleware intent & data.
    unmod: {
        intent: string,
        data: {[number]: any?}
    }?

}
export type ConnectionResult  = {
    intent: (intent: string) -> nil,
    data: (...any) -> nil,
    append: (key: string, value: any) -> nil,
    send: (...any?) -> nil,
    reject: (...any?) -> nil,
    assert: (condition: boolean, ...any?) -> boolean,
}

--> Params of Connections.
--#endregion

--============--
-- MIDDLEWARE --
--============--
--#region
export type __registered_func__ = {
    order: number,
    callback: (NetworkingPipeline) -> NetworkingPipeline,
    protected: boolean,
}

export type self_middleware = {
    __locked_phases: {string},

    --> Registry
    __registry: {
        __internal: {
            before: {__registered_func__},
            after:  {__registered_func__}
        },

        before: {__registered_func__},
        after:  {__registered_func__},
    }
}
export type methods_middleware = {
    __index: methods_middleware,
    new: (locked_phases: {}?) -> NetworkingMiddleware,

    --> Methods
    Use: (self: NetworkingMiddleware,
        phase: string, order: number,
        callback: (NetworkingPipeline) -> NetworkingPipeline,
        args: {internal: boolean, protected: boolean}) -> number?,
    Run: (self: NetworkingMiddleware,
        phase: string, args: NetworkingCall | ConnectionRequest) -> NetworkingPipeline,

    --> Deprecated
    use: (self: NetworkingMiddleware,
        phase: string, order: number,
        callback: (NetworkingPipeline) -> NetworkingPipeline,
        args: {internal: boolean, protected: boolean}) -> number?,
    run: (self: NetworkingMiddleware,
        phase: string, args: NetworkingCall | ConnectionRequest) -> NetworkingPipeline,
}
export type NetworkingMiddleware = typeof(setmetatable({} :: self_middleware, {} :: methods_middleware))

--#endregion

--==========--
-- PIPELINE --
--==========--
--#region

local pipeline = {}
pipeline.__index = pipeline

export type self_pipeline = {
    --> Properties
    phase: string,
    intent: string,
    data: {[number]: any?},

    halted: boolean,
    errorMsg: string?
}
export type methods_pipeline = {
    __index: methods_pipeline,
    new: (phase: string, call: NetworkingCall | ConnectionRequest) -> NetworkingPipeline,

    --> Downstream Methods
    setIntent: (self: NetworkingPipeline, intent: string) -> boolean,
    setData:   (self: NetworkingPipeline, args: {any}, ...any) -> boolean,
    setHalted: (self: NetworkingPipeline, halted: boolean) -> boolean,
    setError:  (self: NetworkingPipeline, message: string) -> boolean,

    --> Upstream Accessors
    getIntent: (self: NetworkingPipeline) -> string,
    getData:   (self: NetworkingPipeline) -> {any},
    isHalted:  (self: NetworkingPipeline) -> boolean,
    getError:  (self: NetworkingPipeline) -> string?,
    getPhase:  (self: NetworkingPipeline) -> string
}
export type NetworkingPipeline = typeof(setmetatable({} :: self_pipeline, {} :: methods_pipeline))

--#endregion

--===============--
-- INTENT ROUTER --
--===============--
--#region

local router = {}
router.__index = router

export type self_router = {
    --> Properties
    __routes: {[string]: (req: ConnectionRequest, res: ConnectionResult) -> any?},
    __listener: NetworkingConnection,
    __middleware: NetworkingMiddleware,

    __on_any: ((req: ConnectionRequest, res: ConnectionResult) -> any?)?,
}
export type methods_router = {
    __index: methods_router,
    new: (event: NetworkingEvent) -> NetworkingRouter,

    --> Methods

    --[[
        Routes a specific intent to a callback function, with a req and res object.
        
        @param intent Intent to listen for
        @param callback Callback to run when intent gets called

        @return NetworkingRouter
    ]]
    On: (self: NetworkingRouter, intent: string, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    
    --[[
        Routes any intent into this callback.

        @param callback Callback to run when evnt gets called

        @return NetworkingRouter
    ]]
    OnAny: (self: NetworkingRouter, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    
    --[[
        Injects middleware into the router, which get injected into every
        route in the router. Always into the "after" phase.

        @param order Execution order of this middleware.
        @param callback Callback to run on middleware execution.

        @return NetworkingRouter
    ]]
    UseMiddleware: (self: NetworkingRouter, order: number, callback: (pipeline: NetworkingPipeline) -> any?) -> NetworkingRouter,
    
    --[[
        Discards this route and cleans up the NetworkConnection.
    ]]
    Discard: (self: NetworkingRouter) -> nil,

    --> Deprecated
    on: (self: NetworkingRouter, intent: string, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    onAny: (self: NetworkingRouter, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    useMiddleware: (self: NetworkingRouter, order: number, callback: (pipeline: NetworkingPipeline) -> any?) -> NetworkingRouter,
    discard: (self: NetworkingRouter) -> nil,
}
export type NetworkingRouter = typeof(setmetatable({} :: self_router, {} :: methods_router))

--#endregion

return types