--[[

    Networking Channel

    Griffin Dalby
    2025.07.06

    This module provides networking w/ a channel object, providing
    NetworkingEvents.

--]]

--]] Modules
--> Networking logic
local types = require(script.Parent.types)
local event = require(script.Parent.event)

--> Sawdust implementations
local __impl = script.Parent.Parent

local caching = require(__impl.cache)

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Cache
local networkingCache = caching.findCache('__networking_cache')
local channelCache = networkingCache:createTable('channels')

--]] Channel
local channel = {}
channel.__index = channel

function channel.get(channelName: string, settings: types.ChannelSettings) : types.NetworkingChannel
    assert(channelName, `Missing channelName argument!`)

    --> Cache check
    local channelInCache = networkingCache:hasEntry(channelName)
    if channelInCache then
        if not settings or not settings.returnFresh then
            return channelInCache end
    end

    --> Fetch channel folder
    local fetchFolder = __settings.networking.fetchFolder

    local channelFolder = fetchFolder:FindFirstChild(channelName)
    assert(channelFolder, `Failed to find channel w/ name "{channelName}!"`)

    --> Construct self & find events
    local self = setmetatable({} :: types.self_channel, channel)

    self.__channel = channelFolder
    for _, ievent: RemoteEvent in pairs(channelFolder:GetChildren()) do
        self[ievent.Name] = event.new(self, ievent)
    end

    --> Finalize
    if not channelInCache
        or settings.replaceFresh then
        
        channelCache:setValue(channelName, self)
    end

    return self
end

return channel