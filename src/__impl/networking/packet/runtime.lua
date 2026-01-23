--!strict
--[[

    Networking Initalizer

    Griffin Dalby
    2025.07.15

    This module will initalize the networking module, creating the
    event protocols.

--]]

--]] Services
local runService = game:GetService('RunService')

--]] Modules
local net_root = script.Parent.Parent

--> Local
local types = require(net_root.types)

--> Sawdust
local __impl = net_root.Parent

local __internal = __impl.Parent.__internal
local __settings = require(__internal.__settings)

local caching = require(__impl.cache)

--]] Constants
local isServer = runService:IsServer()
local warnTag = `[{script.Parent.Name}{script.Name}]`

--]] Initalizer
return function ()
    local networkingCache = caching.findCache('__networking_cache')
    local requestCache = networkingCache:createTable('requests')

    local connectionCache = networkingCache:createTable('connections')

    for _, category: Instance in pairs(__settings.networking.fetchFolder:GetChildren()) do
        if not category:IsA('Folder') then continue end
        
        for _, event: Instance in pairs(category:GetChildren()) do
            local eventPath = `{category.Name}.{event.Name}`

            if not (event:IsA('RemoteEvent') or event:IsA('UnreliableRemoteEvent')) then
                warn(`{warnTag} Instance @ {eventPath} isn't a RemoteEvent type!`)
                return end

            local eventTable = connectionCache:createTable(event)
            local function protocol(player: Player, data: types.raw_data & {[number]: any}) --> Actual function for connections.
                --> Allocate Player Properly
                if typeof(player) == 'Instance' and player:IsA('Player') then
                    --> Server, Player is first argument; Save to .caller
                    data.caller = player
                else
                    --> Client, Data is first argument (player)
                    data = player
                end
				
                --> Verify Sawdust header
                if not data or typeof(data) ~= 'table' then return end --> Table check

                local header = data[1] :: string
                local saw_id, timestamp = unpack(string.split(header, '@'))

                if not saw_id or not timestamp then return end --> Header format check
                if saw_id~=`saw{__settings.global.version}` then return end --> Sawdust ID check
                if not tonumber(timestamp) then return end --> Timestamp check
                
                data[1] = timestamp --> The header gets turned into the Timestamp
                                    --> If extra data in header ever gets introduced, create another library.

                --> Return protocol
                if data[2] == 3 then
                    local return_id = data[3]
                    if not eventTable:hasEntry(return_id) then
                        warn(`{warnTag} No resolver found for Return ID {return_id} in event {eventPath}!`)
                        return end

                    local resolver = eventTable:getValue(return_id)
                    
                    requestCache:setValue(return_id, {
                        caller = data.caller 
                    })

                    resolver(data) --> Resolve the returnId with the data
                    eventTable:setValue(return_id, nil) --> Remove resolver

                    return
                end --> Type 3 is for data returns

                --> Run connections
                for eventId: string, connection: types.NetworkingConnection in pairs(eventTable:getContents()) do
					if eventId:sub(1,2)=='__' then continue end --> Ignore internal entries
					if eventId:sub(1,event.Name:len())==event.Name then continue end --> Is returnId resolver

                    connection:run(data) --> Run w/ raw data
                end
            end

            eventTable:setValue(
                '__protocol',
                (isServer
                    and (event :: RemoteEvent).OnServerEvent:Connect(protocol)
                    or  (event :: RemoteEvent).OnClientEvent:Connect(protocol)) :: RBXScriptConnection )
        end
    end
end