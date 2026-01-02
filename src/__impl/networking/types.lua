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

--> Channels
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

export type NetworkingChannel = typeof(setmetatable({} :: self_channel, channel))

--> Call
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
        data: {},
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

    setReturnId: (self: NetworkingCall, return_id: string) -> NetworkingCall,
}
export type NetworkingCall = typeof(setmetatable({} :: self_call, {} :: methods_call))

--> Events
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
    __index: methods_event,
    new: (channel: NetworkingChannel, event: RemoteEvent) -> NetworkingEvent,

    with: (self: NetworkingEvent) -> NetworkingCall,
    handle: (self: NetworkingEvent, callback: (req: ConnectionRequest, res: ConnectionResult) -> nil) -> nil,
    route: (self: NetworkingEvent) -> NetworkingRouter,
    useMiddleware: (self: NetworkingEvent, phase: string, order: number, callback: (pipeline: NetworkingPipeline) -> nil, msettings: {protected: boolean}) -> nil,
}
export type NetworkingEvent = typeof(setmetatable({} :: self_event, {} :: methods_event))

--> Connection 
local connection = {}
connection.__index = connection

export type self_connection = {
    --> Properties
    cache: cache.SawdustCache,
    connectionId: string,
    callback: (player: Player, ...any) -> nil,

    --> Internal Methods
    removeFromEvent: () -> nil,
    returnCall: (data: {}) -> nil,

    --> Methods
    run: (raw_data: {}) -> nil,
    disconnect: () -> nil,
}
export type methods_connection = {
    __index: methods_connection,
    new: (callback: (req: ConnectionRequest, res: ConnectionResult) -> nil, event: NetworkingEvent) -> NetworkingConnection,

    --> Internal Methods
    removeFromEvent: () -> nil,
    returnCall: (data: {}) -> nil,

    --> Methods
    run: (raw_data: {}) -> nil,
    disconnect: () -> nil,
}
export type NetworkingConnection = typeof(setmetatable({} :: self_connection, connection))

-- req & res of Connections.
export type ConnectionRequest = {
    caller: Player?,
    intent: string,
    data: {[number]: any?},

}
export type ConnectionResult  = {
    intent: (intent: string) -> nil,
    data: (...any) -> nil,
    append: (key: string, value: any) -> nil,
    send: () -> nil,
    reject: (message: string) -> nil,
    assert: (condition: boolean, message: string) -> boolean,
}

--> Middleware
export type __registered_func__ = {
    order: number,
    callback: (NetworkingPipeline) -> NetworkingPipeline,
    protected: boolean,
}

export type self_middleware = {
    --> Registry
    __registry: {
        before: {__registered_func__},
        after:  {__registered_func__},
    },
}
export type methods_middleware = {
    __index: methods_middleware,
    new: (locked_phases: {}?) -> NetworkingMiddleware,

    use: (self: NetworkingMiddleware,
        phase: string, order: number,
        callback: (NetworkingPipeline) -> NetworkingPipeline,
        args: {internal: boolean, protected: boolean}) -> nil,
    run: (self: NetworkingMiddleware,
        phase: string, args: NetworkingCall) -> NetworkingPipeline
}
export type NetworkingMiddleware = typeof(setmetatable({} :: self_middleware, {} :: methods_middleware))

--> Pipeline
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
    new: (phase: string, call: NetworkingCall) -> NetworkingPipeline,

    --> Downstream Methods
    setIntent: (self: NetworkingPipeline, intent: string) -> boolean,
    setData:   (self: NetworkingPipeline, args: {any}, ...any) -> boolean,
    setHalted: (self: NetworkingPipeline, halted: boolean) -> boolean,

    --> Upstream Accessors
    getIntent: (self: NetworkingPipeline) -> string,
    getData:   (self: NetworkingPipeline) -> {any},
    isHalted:  (self: NetworkingPipeline) -> boolean,
    getError:  (self: NetworkingPipeline) -> string?,
    getPhase:  (self: NetworkingPipeline) -> string
}
export type NetworkingPipeline = typeof(setmetatable({} :: self_pipeline, {} :: methods_pipeline))

--> Intent Router
local router = {}
router.__index = router

export type self_router = {
    --> Properties
    __routes: {[string]: (req: ConnectionRequest, res: ConnectionResult) -> any?},
    __listener: NetworkingConnection
}
export type methods_router = {
    __index: methods_router,
    new: (event: NetworkingEvent) -> NetworkingRouter,

    on: (self: NetworkingRouter, intent: string, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    onAny: (self: NetworkingRouter, callback: (req: ConnectionRequest, res: ConnectionResult) -> any?) -> NetworkingRouter,
    useMiddleware: (self: NetworkingRouter, order: number, callback: (pipeline: NetworkingPipeline) -> any?) -> NetworkingRouter,
    discard: (self: NetworkingRouter) -> nil,
}
export type NetworkingRouter = typeof(setmetatable({} :: self_router, {} :: methods_router))

return types