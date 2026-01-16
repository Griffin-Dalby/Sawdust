--!strict
--[[

    Event Connection

    Griffin Dalby
    2025.07.09

    This module provides connection behavior for events.

--]]

--]] Services
local https = game:GetService('HttpService')

--]] Modules
local net_root = script.Parent.Parent

--> Local types
local types = require(net_root.types)

--> Sawdust
local __impl = net_root.Parent
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
local connection = {} :: types.methods_connection
connection.__index = connection

function connection.new(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil, event: types.NetworkingEvent) : types.NetworkingConnection
    local self = setmetatable({} :: types.self_connection, connection)

    self.cache = connectionCache:findTable(event.__event)
    self.connectionId = https:GenerateGUID(false)
    self.callback = callback

    self.removeFromEvent = function()
        local foundConn = event.__connections[self.connectionId]
        if not foundConn then return nil end

        event.__connections[self.connectionId] = nil

        return nil
    end

    self.returnCall = function(body: types.raw_data & { returnId: string? }, caller: Player?)
        local call = event:with()
        if caller then call:broadcastTo(caller) end

        call:intent(body.intent)
            :data(unpack(body.data))
            :setReturnId(body.returnId)

            :fire()

        return nil
    end

    return self
end

function connection:Run(rawData: {caller: Player?, [number]: any} )
    --> Create req
    local req: types.ConnectionRequest = {
        caller = rawData.caller,
        intent = rawData[4],
        data = rawData[5]
    }

    --> Translate Raw Data
    local eventType = rawData[2]
	local returnId = rawData[3]
    local resData = {
        returnId = (eventType==2 and returnId) and returnId or nil,

        intent = '',
        data = {},
	} :: types.raw_data & {
        closed: boolean?,
        returnId: string?,
    }

    --> Generate res object
    local res: types.ConnectionResult
    res = {

        intent = function(intent: string) --> Sets intent
            assert(resData.closed==nil, `attempt to set intent on a closed request!`)
            resData.intent = intent 

            return nil
        end,

        data = function(...) --> Sets data
            assert(resData.closed==nil, `attempt to set data on a closed request!`)
            local args = {...}
                
            if #args == 1 and type(args[1]) == 'table' then
                                    resData.data = args[1]    --> Table
            elseif #args > 0 then resData.data = args       --> Tuple
            else                  resData.data = {} end     --> None

            return nil
        end,

        append = function(value: any) --> Append data to response data
            assert(resData.closed==nil, `attempt to append to a closed request!`)
            table.insert(resData.data, value) 
            
            return nil
        end,
                    
        send = function(...) --> Sends response
            assert(resData.closed==nil, `attempt to send a closed request!`)

            if #{...}>0 then
                res.data(...) end
            self.returnCall(resData, req.caller)

            resData.closed = true
            return nil
        end,

        reject = function(...) --> Reject response
            assert(resData.closed==nil, `attempt to reject a closed request!`)
            resData.closed = true

            resData.intent = '__rejected__'
            if #{...}>0 then
                resData.data = { ... } end
            self.returnCall(resData, req.caller)

            return nil
        end,

        assert = function(condition: boolean, message: string) --> assert() for response
            assert(resData.closed==nil, `attempt to assert a closed request!`)
            
            if not condition then
                res.reject(message)
                return false
            end

            return true
        end

        }

	--> Register return
	if resData.returnId then
		requestCache:setValue(resData.returnId, {
            caller = req.caller,
        })
	end

    --> Run callback
    self.callback(req, res)

    return nil
end

function connection:run(rawData: {caller: Player?, [number]: any} )
    return self:Run(rawData) end

function connection:Disconnect()
    self.cache:setValue(self.connectionId, nil)
    self.removeFromEvent() 

    return nil
end

@deprecated
function connection:disconnect()
    return self:Disconnect() end

return connection