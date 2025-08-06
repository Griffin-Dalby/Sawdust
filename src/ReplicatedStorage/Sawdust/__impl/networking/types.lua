local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
export type NetworkingChannel = typeof(setmetatable({} :: self_channel, channel))

function channel.get(channelName: string, settings: ChannelSettings)
end

--> Call
local call = {}
call.__index = call

export type self_call = {
    __event: RemoteEvent,
    __middleware: NetworkingMiddleware,

    --> Broadcast settings
    _globalBroadcast: boolean|nil,

    _targets: {Player}|nil,
    _filterType: 'include'|'exclude'|nil,

    --> Call data
    _data: {},
    _intent: string,
    _timeout: number,
}
export type NetworkingCall = typeof(setmetatable({} :: self_call, call))

function call:broadcastGlobally(): NetworkingCall end
function call:broadcastTo(targets: {Players}?): NetworkingCall end
function call:setFilterType(filterType: 'include'|'exclude'): NetworkingCall  end

function call:data(...): NetworkingCall end
function call:intent(intent: string): NetworkingCall end
function call:timeout(seconds: number): NetworkingCall end

function call:fire(): NetworkingPipeline end
function call:invoke(): promise.SawdustPromise end

--> Events
local event = {}
event.__index = event

export type self_event = {
    __event: RemoteEvent,
    __middleware: NetworkingMiddleware,
    __connections: {RBXScriptConnection},

    __invoke_resolvers: {}
}  
export type NetworkingEvent = typeof(setmetatable({} :: self_event, event))

function event.new(channel: NetworkingChannel, event: RemoteEvent)
end

function event:with() : NetworkingCall
end
function event:handle(callback: (req: ConnectionRequest, res: ConnectionResult) -> nil)
end
function event:route() : NetworkingRouter
end
function event:useMiddleware(phase: string, order: number, callback: (pipeline: NetworkingPipeline) -> nil, msettings: {protected: boolean})
end

--> Connection 
local connection = {}
connection.__index = connection

export type self_connection = {
    cache: cache.SawdustCache,
    connectionId: string,
    callback: (player: Player, ...any) -> nil,

    removeFromEvent: () -> nil,
    returnCall: (data: {}) -> nil
}
export type NetworkingConnection = typeof(setmetatable({} :: self_connection, connection))
export type ConnectionRequest = {
    caller: Player?,
    intent: string,
    data: {any: any},

}
export type ConnectionResult  = {
    intent: (intent: string) -> nil,
    data: (...any) -> nil,
    append: (key: string, value: any) -> nil,
    send: () -> nil,
    reject: () -> nil,
}

function connection:run(rawData: {})
end
function connection:disconnect()
end

--> Middleware
local middleware = {}
middleware.__index = middleware

export type __registered_func__ = {
    order: number,
    callback: (NetworkingPipeline) -> NetworkingPipeline,
    protected: boolean,
}
export type self_middleware = {
    __registry: {
        before: {__registered_func__},
        after:  {__registered_func__},
    },
}
export type NetworkingMiddleware = typeof(setmetatable({} :: self_middleware, middleware))

function middleware.new() : NetworkingMiddleware
end
function middleware:use(
    phase: string, order: number,
    callback: (NetworkingPipeline) -> NetworkingPipeline, 
    args: {internal: boolean, protected: boolean}) end
function middleware:run(phase: string, args: {any}): NetworkingPipeline end

--> Pipeline
local pipeline = {}
pipeline.__index = pipeline

export type self_pipeline = {
    phase: string,
    intent: string,
    data: {any},

    halted: boolean,
    errorMsg: string?,
}
export type NetworkingPipeline = typeof(setmetatable({} :: self_pipeline, pipeline))

function pipeline:setIntent(intent: string): boolean end
function pipeline:setData(args: {any}, ...): boolean end
function pipeline:setHalted(halted: boolean): boolean end

function pipeline:getIntent(): string end
function pipeline:getData(): {any} end
function pipeline:isHalted() : boolean end
function pipeline:getError() : string? end
function pipeline:getPhase(): string end

--> Intent Router
local router = {}
router.__index = router

export type self_router = {
    __routes: {[string]: (req: ConnectionRequest, res: ConnectionResult) -> nil},
    __listener: NetworkingConnection
}
export type NetworkingRouter = typeof(setmetatable({} :: self_router, router))

function router:on(intent: string, callback: (req: ConnectionRequest, res: ConnectionResult) -> nil): NetworkingRouter end
function router:discard() end

return types