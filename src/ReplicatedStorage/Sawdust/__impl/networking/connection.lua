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
            :intent(data.intent)
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
    req.intent = rawData[4]
    req.data = rawData[5]

    --> Create res
    local res: types.ConnectionResult  = {}

	local eventType = rawData[2]
	local returnId = rawData[3]
    local resData = {
        returnId = (eventType==2 and returnId) and returnId or nil,

        intent = '',
        data = {},
	}

    res.intent = function(intent: string) --> Sets intent
        assert(resData.closed==nil, `attempt to set intent on a closed request!`)
        resData.intent = intent end
    res.data = function(...) --> Sets data
        assert(resData.closed==nil, `attempt to set data on a closed request!`)
        local args = {...}
            
        if #args == 1 and type(args[1]) == 'table' then
                              resData.data = args[1]    --> Table
        elseif #args > 0 then resData.data = args       --> Tuple
        else                  resData.data = {} end end --> None
    res.append = function(key: string, value: any) --> Append data to response data
        assert(resData.closed==nil, `attempt to append to a closed request!`)
        resData.data[key] = value end
                
    res.send = function() --> Sends response
        assert(resData.closed==nil, `attempt to send a closed request!`)
        resData.closed = true

        self.returnCall(req.caller, resData)
	end
    res.reject = function() --> Reject response
        assert(resData.closed==nil, `attempt to reject to a closed request!`)
        resData.closed = true

        resData.intent = '__rejected__'
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