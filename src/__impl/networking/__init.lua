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
--> Local
local types = require(script.Parent.types)

--> Sawdust
local __impl = script.Parent.Parent

local __internal = __impl.Parent.__internal
local __settings = require(__internal.__settings)

local caching = require(__impl.cache)

--]] Constants
local isServer = runService:IsServer()
local warnTag = `[{script.Parent.Name}{script.Name}]`

--]] Initalizer
return function ()
    local networkingCache = caching.findCache('__networking_cache')
    local middlewareCache = networkingCache:createTable('middleware')
    local requestCache = networkingCache:createTable('requests')

    local connectionCache = networkingCache:createTable('connections')

    for _, category: Folder in pairs(__settings.networking.fetchFolder:GetChildren()) do
        for _, event: RemoteEvent in pairs(category:GetChildren()) do
            local eventPath = `{category.Name}.{event.Name}`

            if not event:IsA('RemoteEvent') then
                warn(`{warnTag} Instance @ {eventPath} isn't a RemoteEvent!`)
                return end

            local eventTable = connectionCache:createTable(event)
            local function protocol(player: Player, data: {}) --> Actual function for connections.
                --> Verify is sawdust event
                if typeof(player) ~= 'table' then
                    data.caller = player
                    player = nil
                else
                    data = player
                    
                end
				
                if not data or typeof(data) ~= 'table' then return end --> Table check
                if not data[1] or data[1] ~= __settings.global.version then return end --> Sawdust protocol check
                
                --> Return protocol
                if data[2] == 3 then
                    local returnId = data[3]
                    if not eventTable:hasEntry(returnId) then
                        warn(`{warnTag} No resolver found for returnId {returnId} in event {eventPath}!`)
                        return end

                    local resolver = eventTable:getValue(returnId)
                    
                    requestCache:setValue(returnId, {
                        caller = data.caller 
                    })
                    resolver(data) --> Resolve the returnId with the data
                    eventTable:setValue(returnId, nil) --> Remove resolver

                    return
                end --> Type 3 is for data returns

                --> Run connections
                for eventId: string, connection: types.NetworkingConnection in pairs(eventTable:getContents()) do
					if eventId:sub(1,2)=='__' then continue end
					if eventId:sub(1,event.Name:len())==event.Name then continue end --> Is returnId resolver

                    connection:run(data) --> Run w/ raw data
                end
            end

            eventTable:setValue(
                '__protocol',
                isServer
                    and event.OnServerEvent:Connect(protocol)
                    or  event.OnClientEvent:Connect(protocol) )
        end
    end
end