--[[

    Networking Implementation

    Griffin Dalby
    2025.07.06

    This implementation will abstract the networking process utilizing
    other sawdust implementations.

    There's a middleware system, allowing you to "inject" code into certain
    parts of the networking event lifecycle, also exposes the "networking
    pipeline" which allows middleware to dynamically modify send and return
    values.

    Additionally, return value behavior found in RemoteFunctions is also
    abstracted, allowing more control and flud control over your networking
    calls.

--]]

--]] Services
--]] Modules
--> Networking logic
local types = require(script.types)

local channel = require(script.channel)

--]] Constants
--]] Variables
--]] Functions
--]] Module
local networking = {}

--]] Types
export type NetworkingChannel = types.NetworkingChannel
export type NetworkingCall = types.NetworkingCall
export type NetworkingEvent = types.NetworkingEvent
export type NetworkingRouter = types.NetworkingRouter
export type NetworkingConnection = types.NetworkingConnection
export type NetworkingMiddleware = types.NetworkingMiddleware
export type NetworkingPipeline = types.NetworkingPipeline

--]] Methods
networking.getChannel = channel.get

return networking