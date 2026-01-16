--!strict
--[[

    Networking Event

    Griffin Dalby
    2025.07.06

    This module provides networking w/ an event object, allowing the
    usage of :fire(), :connect(), and such things.

--]]
    
--]] Services
local players = game:GetService('Players')
local https = game:GetService('HttpService')

local runService = game:GetService('RunService')
local isServer   = runService:IsServer()

--]] Modules
local net_root = script.Parent.Parent
local net_handle = net_root.handle
local net_packet = net_root.packet

--> Networking logic
local middleware = require(net_handle.middleware)
local router = require(net_handle.router)

local connection = require(net_packet.connection)

local types = require(net_root.types)

--> Sawdust implementations
local __impl = net_root.Parent

local promise = require(__impl.promise)
local caching = require(__impl.cache)

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Cache
local networkingCache = caching.findCache('__networking_cache')
local requestCache = networkingCache:findTable('requests')
local connectionCache = networkingCache:findTable('connections')

--]] Utility
function countTbl(t: {[any]: any})
    local i=0
    for _ in pairs(t) do i+= 1 end
    return i
end

--[[
    Smartly packs body data into a packet, ready to send.

    If you send just a table, it will unpack and all arguments in the
    table gets sent as the body data.<br>
    If you send multiple arguments, it will simply send all of them.
]]
function compileTableArgs(...) : {any}?
    local args = {...} :: {any}?
    if not args then 
        return nil end

    local arg_count = #args
    if arg_count<1 then
        return nil end

    if (args and #args==1) and type(args[1]) == 'table' then
        args = args[1] --> Table argument; send as first & only argument (prevent packing table)
    elseif arg_count > 0 then
        args = args    --> Multiple arguments, or single non-table argument. Send as-is
    else
        args = nil     --> No arguments. Send none
    end

    return args
end

--]] Event Call Object
local EventCall = {} :: types.methods_call
EventCall.__index = EventCall

--]] Constructor

--[[
    Creates a new EventCall instance, attributed to a NetworkingEvent.<br>
    This is what handles the data capture & fire/invocation of the event.

    @param event NetworkingEvent to attribute to.
    
    @return NetworkingCall
]]
function EventCall.new(event: types.NetworkingEvent) : types.NetworkingCall
    local self = setmetatable({} :: types.self_call, EventCall :: types.methods_call)

    self.__event = event.__event
    self.__middleware = event.__middleware
    self._return_id = nil
    
    --> Broadcast Settings
    self._broadcast = {
        global = true,    --> Default: Global Broadcast
        targets = nil,    --> Default: No targets selected
        filter_type = nil --> Default: No filter type selected
    }

    --> Call Data
    self._call = {
        data = {},   --> Default: Empty body data
        intent = '', --> Default: Empty intent ID

        timeout = 5, --> Default: 5 second event timeout
    }

    return self
end

--> Call broadcast settings
--#region

--[[ 
    Broadcast this event to all clients.
]]
function EventCall:broadcastGlobally() : types.NetworkingCall
    self._broadcast.targets = nil
    self._broadcast.filter_type = nil

    self._broadcast.global = true

    return self 
end

--[[ 
    Specify which players you want to target with this event.

    @param tuple<Player>|{Player} List of players to target
]]
function EventCall:broadcastTo(...: Player) : types.NetworkingCall
    -- if not isServer then
    --     warn(`[{script.Name}] Can't access broadcast functions on client!`)
	--     return end
	
    local targets = compileTableArgs(unpack{...}) :: {Player}
	if not targets then return self end

    self._broadcast.global = false

    self._broadcast.targets = targets
    self._broadcast.filter_type = self._broadcast.filter_type or 'include'
    return self 
end

--[[
    Sets the filter type of this call. 
    
    'include' Sends this event to ONLY the targets set.<br>
    'exclude' Sends this event to every EXCEPT the targets set.

    @param filter_type Either 'include' or 'exclude'
]]
function EventCall:setFilterType(filter_type: 'include'|'exclude') : types.NetworkingCall
    -- if not isServer then
    --     warn(`[{script.Name}] Can't access broadcast functions on client!`)
    --     return end

    assert(filter_type~=nil and (filter_type=='include' or filter_type=='exclude'),
        `Invalid filter type provided for NetworkingCall! (filter_type: {filter_type and filter_type or "<nil>"})`)

    self._broadcast.filter_type = filter_type
    return self end --#endregion

--> Call arguments
--#region

--[[
    Sets the "body" data of this call. Gets transpiled smartly depending
    on what you send.

    If you send just a table, it will unpack and all arguments in the
    table gets sent as the body data.<br>
    If you send multiple arguments, it will simply send all of them.

    @param tuple<any>|{any} Data to send in body.
]]
function EventCall:data(...) : types.NetworkingCall
    self._call.data = compileTableArgs(unpack{...}) or {}
    return self end

--[[
    Sets the intent of this event.

    @param intent Intent this event has.
]]
function EventCall:intent(intent: string) : types.NetworkingCall
    self._call.intent = intent
    return self end

--[[
    Sets the request timeout in seconds. If an invocation takes longer
    than this to come back, the promise will reject.

    @param timeout Length of timeout in seconds.
]]
function EventCall:timeout(timeout: number) : types.NetworkingCall
    self._call.timeout = timeout
    return self end

--[[
    Sets the return ID of this call for invoke responses. 
    
    @param return_id ID to return to.
]]
function EventCall:setReturnId(return_id: string) : types.NetworkingCall
    if not requestCache:getValue(return_id) then
        warn(`[{script.Name}] No request found for return ID: {return_id}`)
        return self end

    self._return_id = return_id
    return self end 
    
--#endregion

--> Finalize
function EventCall:fire() : types.NetworkingPipeline
    --> Args & Middleware
    local success, pipeline = pcall(
        self.__middleware.run,
        self.__middleware, 'before', self)
        
    if not success then
        warn(`[{script.Name}] "Before" middleware issue!`)
        warn(`[{script.Name}] {pipeline or 'No message was provided.'}`)
        return pipeline end

    local intent, data = pipeline:getIntent(), pipeline:getData()
    local halted, errorMsg = pipeline:isHalted(), pipeline:getError()

    if halted then
        local parent_n = self.__event.Parent and self.__event.Parent.Name or "<Parent Missing>"
        warn(`[{script.Name}] "Before" middleware halted event call! ({parent_n}.{self.__event.Name})`)
        warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
        return pipeline end

    --> Compile Event
    local return_id = self._return_id
    local final_data = { --> Compile event data
        --] Headers
        [1] = __settings.global.version, --> Version
        [2] = return_id and 3 or 1, --> Event type, 1 for "Fire", 2 for "Invoke", 3 for "Response"
        
        --] Body
        [3] = return_id,
        [4] = intent,
        [5] = data, 
    }
    
    --> Check off response
    local __request
    if return_id then
        --> Remove from cache
        __request = requestCache:getValue(return_id)
        if __request then
            requestCache:setValue(return_id, nil) end
    end

    --> Fire Event
    if isServer then --> Server call behavior
        --> Check for return
		if return_id then
            self.__event:FireClient(__request.caller, final_data)

            return pipeline
        end

        --> Check for targets
        local broadcast_targets = self._broadcast.targets
        if broadcast_targets then
            --> Check filter type
            local filter_type = self._broadcast.filter_type

            if filter_type == 'include' then

                --> Send events to all clients marked as targets.
                for _, target in pairs(broadcast_targets) do
                    self.__event:FireClient(target, final_data)
                end

            elseif filter_type == 'exclude' then

                --> Send event to all clients except targets.
                for _, target in pairs(players:GetPlayers()) do
                    if table.find(broadcast_targets, target) then continue end
                    self.__event:FireClient(target, final_data)
                end

            end
        elseif self._broadcast.global then

            --> Send event to all clients
            self.__event:FireAllClients(final_data)

        end
    else --> Client call behavior

        --> Check return
        if self._return_id then
            if not __request then
                warn(`[{script.Name}] No request found for return ID: {self._return_id}`)
                return pipeline end
        end

        --> Fire event
        self.__event:FireServer(final_data)

    end

    return pipeline
end

function EventCall:invoke() : promise.SawdustPromise
    --> Args & Middleware
    local success, pipeline = pcall(
        self.__middleware.run, 
        self.__middleware, 'before', self)

    if not success then
        warn(`[{script.Name}] "Before" middleware issue!`)
        warn(`[{script.Name}] {pipeline or 'No message was provided.'}`)
        return pipeline end

    local intent, data = pipeline:getIntent(), pipeline:getData()
    local halted, errorMsg = pipeline:isHalted(), pipeline:getError()

    local parent_n = self.__event.Parent and self.__event.Parent.Name or "<Parent Missing>"
    if halted then
        warn(`[{script.Name}] "Before" middleware halted event call! ({parent_n}.{self.__event.Name})`)
        warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
        return pipeline end

    --> Generate new Request ID
    local request_id = `{self.__event.Name}.{https:GenerateGUID(false)}`
    local final_data = {
        --] Headers
        [1] = __settings.global.version, --> SawD Version
        [2] = 2, --> Code for Invocation

        --] Body
        [3] = request_id,
        [4] = intent,
		[5] = data
    }
	
    --> Save Request to Cache
	requestCache:setValue(request_id, {
		caller = if isServer then nil else players.LocalPlayer.UserId,
	})

    --> Create Promise
    local promise = promise.new(function(resolve, reject)
        --> Return resolver
        local returned_data = {} :: {[Player]: {}}
        local expected_returns = 0
        local start_timestamp = tick()

		local timeout, resolver
		local this_cache = connectionCache:findTable(self.__event)
		
        local function clean()
            if timeout then timeout:Disconnect(); timeout = nil end
			if this_cache:hasEntry(request_id) then this_cache:setValue(request_id, nil) end
            
            connectionCache:findTable(self.__event):setValue(request_id, nil) --> Remove resolver
        end

        timeout = runService.Heartbeat:Connect(function()
            local thisTime = tick()
            if thisTime - start_timestamp >= self._call.timeout then
                clean() --> Clean up

                --> Reject
                if countTbl(returned_data) >= expected_returns then
                    return end --> Expectations met
                
                warn(`[{script.Name}] Request ({parent_n}.{self.__event.Name}) timed out after {self._call.timeout} seconds!`)
                reject(countTbl(returned_data)>0 and 
                    returned_data or 'timeout') --> Return incomplete data
            end
        end)
        resolver = function(raw_data: {[number]: any, 
                caller: Player}) --> Caller injected on Server.

            --> Parse Data
            local res_return_id = raw_data[3] :: string
            local res_intent = raw_data[4] :: string
            local res_data = raw_data[5] :: {any}

            if res_return_id ~= request_id then
                warn(`[{script.Name}] Resolver called with mismatched request ID! Expected {request_id}, got {res_return_id}`)
                return end
            
            local response = {
                intent = res_intent,
                data = res_data,
            } :: types.ConnectionRequest
            if isServer then --> Poll data on server
                returned_data[raw_data.caller] = response

                if countTbl(returned_data) < expected_returns then
                    return end --> Not enough data yet

                warn("SERVER INVOCATION POLL RETURN NOT IMPLEMENTED!")
            else --> Return data on client
                returned_data = response

                if type(returned_data) == 'table' then
                    if returned_data.intent == '__rejected__' then
                        reject(returned_data.data) else
                        resolve(returned_data.data) end
                else
                    resolve(returned_data.data) --> Resolve (there must be custom error handling)
                end
            end
                
            clean() --> Clean up
            
            -- if typeof(pipeline:getData()) == 'table' then
            --     returnedData = pipeline:getData() end
        end
		this_cache:setValue(
            request_id,
            resolver
        )

        --> Send invocation
        if isServer then
            local broadcast_targets = self._broadcast.targets

            if broadcast_targets then
                local filter_type = self._broadcast.filter_type

                if filter_type == 'include' then

                    --> Invoke all clients marked as targets
                    for _, target in pairs(broadcast_targets) do
                        expected_returns += 1
                        self.__event:FireClient(target, final_data)
                    end

                elseif filter_type == 'exclude' then

                    --> Invoke all clients except targets
                    for _, target in pairs(players:GetPlayers()) do
                        if table.find(broadcast_targets, target) then continue end
                        expected_returns += 1
                        self.__event:FireClient(target, final_data)
                    end

                end
            elseif self._broadcast.global then

                --> Global invocation
                expected_returns = countTbl(players:GetPlayers())
                self.__event:FireAllClients(final_data)

            end
        else

            --> Fire single and wait for server response
            expected_returns = 1
            self.__event:FireServer(final_data)

        end
    end)
    return promise
end

--]] Channel
local Event = {} :: types.methods_event
Event.__index = Event

function Event.new(channel: types.NetworkingChannel, _event: RemoteEvent) : types.NetworkingEvent
    local self = setmetatable({} :: types.self_event, Event)

    --> Event instance
    self.__event = _event
    self.__middleware = middleware.new()
    self.__connections = {}

    --> Invoke resolvers
    self.__invoke_resolvers = {}

    return self
end

function Event:with() : types.NetworkingCall
    return EventCall.new(self) end

function Event:handle(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> ...any) : types.NetworkingConnection
    local new_connection = connection.new(callback, self)

    self.__connections[new_connection.connectionId] = new_connection
    connectionCache:findTable(self.__event):setValue(new_connection.connectionId, new_connection)
    
    return new_connection
end

function Event:route() : types.NetworkingRouter
    local newRoute = router.new(self)
    return newRoute
end

function Event:useMiddleware(phase: string, order: number, callback: (pipeline: types.NetworkingPipeline) -> types.NetworkingPipeline, msettings: {protected: boolean})
	msettings = msettings or { protected = false }
	
	self.__middleware:use(phase, order, callback, {
        ['internal'] = false,
		['protected'] = msettings.protected or false
	})

    return nil
end

return Event