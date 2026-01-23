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
local middleware = require(net_root.handle.middleware)

--> Sawdust
local __impl = net_root.Parent
local __internal = __impl.Parent.__internal
local __settings = require(__internal.__settings)

local caching = require(__impl.cache)

--]] Settings
--]] Constants
local networkingCache = caching.findCache('__networking_cache')
local connectionCache = networkingCache:createTable('connections', true)
local requestCache = networkingCache:createTable('requests', true)

--]] Variables
--]] Functions
--]] Module
local connection = {} :: types.methods_connection
connection.__index = connection

function connection.new(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> nil, event: types.NetworkingEvent) : types.NetworkingConnection
    local self = setmetatable({} :: types.self_connection, connection)

    self.cache = connectionCache:createTable(event.__event, true)
    self.connectionId = https:GenerateGUID(false)
    self.callback = callback

    self.middleware = middleware.new()

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

function connection:Run(raw_data: {caller: Player?, [number]: any} )
    --> Create req
    local arrival = workspace:GetServerTimeNow()
    local req: types.ConnectionRequest = {
        caller = raw_data.caller,

        sent_time = raw_data[1],
        arrival_time = arrival,
        latency = arrival-raw_data[1],

        intent = raw_data[4],
        data = raw_data[5],
    }

    --> Run Middleware
    local success, pipeline = pcall(
        self.middleware.Run,
        self.middleware, 'before', req
    )
    req.intent = pipeline:getIntent()
    req.data = pipeline:getData()

    if not success or pipeline:isHalted() then
        --> Halt execution.
        local err = pipeline:getError()
        if err then
            error(`[{script.Name}] Connection Middleware halted w/ Error.\n{err}`)
        end

        return nil
    end

    req.unmod = {
        intent = raw_data[4],
        data = raw_data[5]
    }

    --> Translate Raw Data
    local event_type = raw_data[2]
	local return_id = raw_data[3]
    local res_data = {
        returnId = (event_type==2 and return_id) and return_id or nil,

        intent = '',
        data = {},
	} :: types.raw_data & {
        closed: boolean?,
        
        intent: string?,
        returnId: string?,
    }

    --> Generate res object
    local res: types.ConnectionResult
    res = {

        intent = function(intent: string) --> Sets intent
            assert(res_data.closed==nil, `attempt to set intent on a closed request!`)
            res_data.intent = intent 

            return nil
        end,

        data = function(...) --> Sets data
            assert(res_data.closed==nil, `attempt to set data on a closed request!`)
            local args = {...}
                
            if #args == 1 and type(args[1]) == 'table' then
                                  res_data.data = args[1]  --> Table
            elseif #args > 0 then res_data.data = args     --> Tuple
            else                  res_data.data = {} end   --> None

            return nil
        end,

        append = function(value: any) --> Append data to response data
            assert(res_data.closed==nil, `attempt to append to a closed request!`)
            table.insert(res_data.data, value) 
            
            return nil
        end,
                    
        send = function(...) --> Sends response
            assert(res_data.closed==nil, `attempt to send a closed request!`)

            if #{...}>0 then
                res.data(...) end
            self.returnCall(res_data, req.caller)

            res_data.closed = true
            return nil
        end,

        reject = function(...) --> Reject response
            assert(res_data.closed==nil, `attempt to reject a closed request!`)
            res_data.closed = true

            res_data.intent = '__rejected__'
            if #{...}>0 then
                res_data.data = { ... } end
            self.returnCall(res_data, req.caller)

            return nil
        end,

        assert = function(condition: boolean, ...) --> assert() for response
            assert(res_data.closed==nil, `attempt to assert a closed request!`)
            
            if not condition then
                res.reject(...)
                return false
            end

            return true
        end

    }

	--> Register return
	if res_data.returnId then
		requestCache:setValue(res_data.returnId, {
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