--[[

    Event Connection

    Griffin Dalby
    2025.07.09

    This module provides connection behavior for events.

--]]

--]] Services
local https = game:GetService('HttpService')
local Players = game:GetService('Players')

--]] Modules
--> Local types
local types = require(script.Parent.types)

--> Sawdust
local __impl = script.Parent.Parent
local __internal = __impl.Parent.__internal
local __settings = require(__internal.__settings)

local caching = require(__impl.cache)

--]] Settings
--]] Constants
local networkingCache = caching.findCache('__networking_cache')
local connectionCache = networkingCache:findTable('connections')
local requestCache = networkingCache:findTable('requests')

--]] Variables
--]] Functions
--]] Module
local connection = {}
connection.__index = connection

function connection.new(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil, event: types.NetworkingEvent) : types.NetworkingConnection
    local self = setmetatable({} :: types.self_connection, connection)

    self.cache = connectionCache:findTable(event.__event)
    self.connectionId = https:GenerateGUID(false)
    self.callback = callback

    self.removeFromEvent = function()
        local foundConn = event.__connections[self.connectionId]
        if not foundConn then return end

        event.__connections[self.connectionId] = nil
    end

    self.returnCall = function(caller: number, data: {})
        event:with()
            :broadcastTo(caller and Players:GetPlayerByUserId(caller) or nil)
            :headers(data.headers)
            :data(unpack(data.data))
            :setReturnId(data.returnId)
            :fire()
    end

    return self
end

function connection:run(rawData: {})
    --> Create req
    local req: types.ConnectionRequest = {}

    local foundCaller = Players:GetPlayerByUserId(rawData.caller)
    assert(foundCaller, `:run() failed to find caller! ({foundCaller.UserId})`)

    req.caller = foundCaller
    req.headers = rawData[4]
    req.data = rawData[5]

    --> Create res
    local res: types.ConnectionResult  = {}

	local eventType = rawData[2]
	local returnId = rawData[3]
    local resData = {
        returnId = (eventType==2 and returnId) and returnId or nil,

        headers = {},
        data = {},
	}

    res.append = function(key: string, value: any) --> Append data to response data
        resData.data[key] = value end
    res.close = function() --> Close response
        resData = {closed = true} end

    res.headers = function(headers: string) --> Sets headers
        resData.headers = headers end
    res.data = function(...) --> Sets data
        local args = {...}
    
        if #args == 1 and type(args[1]) == 'table' then --> Table argument
            resData.data = args[1]
        elseif #args > 0 then --> Multiple arguments or single non-table argument
            resData.data = args
        else --> No arguments
            resData.data = {} end end

    res.send = function() --> Sends response
        if resData.closed then
            return end

        self.returnCall(req.caller, resData)
	end
	
	--> Register return
	if resData.returnId then
		requestCache:setValue(resData.returnId, {
            caller = req.caller,
        })
	end

    --> Run callback
    self.callback(req, res)
end

function connection:disconnect()
    self.cache:setValue(self.connectionId, nil)
    self.removeFromEvent() end

return connection