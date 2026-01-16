--!strict
--[[

    Networking Channel

    Griffin Dalby
    2025.07.06

    This module provides networking w/ a channel object, providing
    NetworkingEvents.

--]]

--]] Modules
local net_root = script.Parent.Parent

--> Networking logic
local types = require(net_root.types)
local event = require(net_root.packet.event)

--> Sawdust implementations
local __impl = net_root.Parent

local caching = require(__impl.cache)

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Cache
local networking_cache = caching.findCache('__networking_cache')
local channel_cache = networking_cache:createTable('channels')

--]] Channel
local channel = {} :: types.methods_channel
channel.__index = channel

function channel.get(channel_name: string, settings: types.ChannelSettings?) : types.NetworkingChannel
    assert(channel_name, `Missing channelName argument!`)

    --> Cache check
    local channel_cached = channel_cache:hasEntry(channel_name)
    if channel_cached then
        if not settings or not settings.returnFresh then
            return channel_cache:getValue(channel_name) end
    end

    --> Fetch channel folder
    local fetch_folder = __settings.networking.fetchFolder

    local channel_folder = fetch_folder:FindFirstChild(channel_name) :: Folder?
    assert(channel_folder, `Failed to find channel w/ name "{channel_name}!"`)

    --> Construct self & find events
    local self = setmetatable({} :: types.self_channel, channel)

    self.__channel = channel_folder
    for _, i_event in pairs(channel_folder:GetChildren()) do
        if not i_event:IsA("RemoteEvent")
        or not i_event:IsA("UnreliableRemoteEvent") then
            continue end

        --> Register Event
        self[i_event.Name] = event.new(self, i_event)
    end

    --> Finalize
    if not channel_cached
        or (settings and settings.replaceFresh) then
        
        --> Update cache
        channel_cache:setValue(channel_name, self)
    end

    return self
end

return channel