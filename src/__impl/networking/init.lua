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
local event = require(script.event)
local middleware = require(script.middleware)

--]] Constants
--]] Variables
--]] Functions
--]] Module
local networking = {}

networking.getChannel = channel.get

return networking