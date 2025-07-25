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
--> Networking logic
local middleware = require(script.Parent.middleware)
local connection = require(script.Parent.connection)
local types = require(script.Parent.types)

--> Sawdust implementations
local __impl = script.Parent.Parent

local promise = require(__impl.promise)
local caching = require(__impl.cache)

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Cache
local networkingCache = caching.findCache('__networking_cache')
local middlewareCache = networkingCache:findTable('middleware')
local requestCache = networkingCache:findTable('requests')
local connectionCache = networkingCache:findTable('connections')

--]] Utility
function countTbl(t)
    local i=0
    for _ in pairs(t) do i+= 1 end
    return i
end

--]] Event Call
local call = {}
call.__index = call

function call.new(event: types.NetworkingEvent) : types.NetworkingCall
    local self = setmetatable({} :: types.self_call, call)

	self.__event = event.__event
    self.__dncl = event.__dncl
    self.__middleware = event.__middleware

    --> Broadcast settings
    self._globalBroadcast = true

    self._targets = nil
    self._filterType = nil

    --> Call data
    self._data = {}
    self._headers = ''

    self._timeout = 5
    self._returnId = nil

    return self
end

--> Call broadcast settings

--[[ call:broadcastGlobally()
    This call will be sent to all players in this server. ]]
function call:broadcastGlobally()
    -- if not isServer then
    --     warn(`[{script.Name}] Can't access broadcast functions on client!`)
    --     return end

    self._targets = nil
    self._filterType = nil

    self._globalBroadcast = true
    return self end

--[[ call:broadcastTo(targetData)
    Sets the targets of this call. ]]
function call:broadcastTo(targets: {Player})
    -- if not isServer then
    --     warn(`[{script.Name}] Can't access broadcast functions on client!`)
	--     return end
	
	if not targets then return self end

    self._globalBroadcast = nil

    self._targets = targets
    self._filterType = self._filterType or 'include'
    return self end

--[[ call:setFilterType(filterType)
    Sets the filter type of this call. ]]
function call:setFilterType(filterType: 'include'|'exclude')
    if not isServer then
        warn(`[{script.Name}] Can't access broadcast functions on client!`)
        return end

    assert(filterType)

    self._filterType = filterType
    return self end

--> Call arguments

--[[ call:data(...)
    Sets the send data of this call. ]]
function call:data(...)
    local args = {...}
    
    if #args == 1 and type(args[1]) == 'table' then --> Table argument
        self._data = args[1]
    elseif #args > 0 then --> Multiple arguments or single non-table argument
        self._data = args
    else --> No arguments
        self._data = {} end

    return self end

--[[ call:headers(string)
    Sets the headers of this call. ]]
function call:headers(string: string)
    self._headers = string
    return self end

--[[ call:timeout(seconds)
    Setings the request timeout in seconds. ]]
function call:timeout(seconds: number)
    self._timeout = seconds
    return self end

--[[ call:setReturnId(returnId: string)
    Sets the return ID of this call for invoke responses. ]]
function call:setReturnId(returnId: string)
    if not requestCache:getValue(returnId) then
        warn(`[{script.Name}] No request found for return ID: {returnId}`)
        return self end

    self._returnId = returnId
    return self end

--> Finalize
function call:fire() : types.NetworkingPipeline
    --> Args & Middleware
    local success, pipeline = pcall(
        self.__middleware.run,
        self.__middleware, 'before', self)
        
    if not success then
        warn(`[{script.Name}] "Before" middleware issue!`)
        warn(`[{script.Name}] {pipeline or 'No message was provided.'}`)
        return pipeline end

    local headers, data = pipeline:getHeaders(), pipeline:getData()
    local halted, errorMsg = pipeline:isHalted(), pipeline:getError()

    if halted then
        warn(`[{script.Name}] "Before" middleware halted event call! ({self.__event.Parent.Name}.{self.__event.name})`)
        warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
        return pipeline end

    --> Fire event
    local finalData = {
        [1] = __settings.global.version, --> Version
        [2] = self._returnId and 3 or 1, --> Event type, 1 for "Fire", 2 for "Invoke", 3 for "Response"
        [3] = self._returnId,
        [4] = headers,
        [5] = data, }
    
    local __request
    if self._returnId then
        --> Remove from cache
        __request = requestCache:getValue(self._returnId)
        if __request then
            requestCache:setValue(self._returnId, nil) end
    end

    if isServer then
        --> Check for return
		if self._returnId then
            self.__event:FireClient(players:GetPlayerByUserId(__request.caller), finalData)

            return pipeline
        end

        --> Check for targets
        if self._targets then
            if self._filterType == 'include' then
                for _, target in pairs(self._targets) do
                    self.__event:FireClient(target, finalData)
                end
            elseif self._filterType == 'exclude' then
                for _, target in pairs(players:GetPlayers()) do
                    if table.find(self._targets, target) then continue end
                    self.__event:FireClient(target, finalData)
                end
            end
        elseif self._globalBroadcast then
            self.__event:FireAllClients(finalData)
        end
    else
        if self._returnId then
            if not __request then
                warn(`[{script.Name}] No request found for return ID: {self._returnId}`)
                return pipeline end
        end

        self.__event:FireServer(finalData)
    end

    return pipeline
end

function call:invoke() : promise.SawdustPromise
    --> Args & Middleware
    local success, pipeline = pcall(
        self.__middleware.run, 
        self.__middleware, 'before', self)

    if not success then
        warn(`[{script.Name}] "Before" middleware issue!`)
        warn(`[{script.Name}] {pipeline or 'No message was provided.'}`)
        return pipeline end

    local headers, data = pipeline:getHeaders(), pipeline:getData()
    local halted, errorMsg = pipeline:isHalted(), pipeline:getError()

    if halted then
        warn(`[{script.Name}] "Before" middleware halted event call! ({self.__event.Parent.Name}.{self.__event.name})`)
        warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
        return pipeline end

    --> Create new call ID
    local requestId = `{self.__event.name}.{https:GenerateGUID(false)}`
    local finalData = {
        [1] = __settings.global.version,
        [2] = 2,
        [3] = requestId,
        [4] = headers,
		[5] = data}
	
	requestCache:setValue(requestId, {
		caller = if isServer then nil else players.LocalPlayer.UserId,
	})

    local promise = promise.new(function(resolve, reject)
        --> Return resolver
        local returnedData = {}
        local expectedReturns = 0
        local startTimestamp = tick()

		local timeout, resolver
		local thisCache = connectionCache:findTable(self.__event)
		
        local function clean()
            if timeout then timeout:Disconnect(); timeout = nil end
			if thisCache:getValue(requestId) then thisCache:setValue(requestId, nil) end
            connectionCache:findTable(self.__event):setValue(requestId, nil) --> Remove resolver
        end

        timeout = runService.Heartbeat:Connect(function()
            local thisTime = tick()
            if thisTime - startTimestamp >= self._timeout then
                clean() --> Clean up

                --> Reject
                if countTbl(returnedData) >= expectedReturns then
                    return end --> Expectations met
                    
                warn(`[{script.Name}] Request ({self.__event.Parent.Name}.{self.__event.name}) timed out after {self._timeout} seconds!`)
                reject(countTbl(returnedData)>0 and returnedData or 'timeout') --> Return incomplete data
            end
        end)
        resolver = function(rawData: {})
            local resolvedReqId = rawData[3]
            if resolvedReqId ~= requestId then
                warn(`[{script.Name}] Resolver called with mismatched request ID! Expected {requestId}, got {resolvedReqId}`)
                return end

            local response = {
                headers = rawData[4],
                data = rawData[5],
            } :: types.ConnectionRequest
            if isServer then
                returnedData[rawData.caller] = response
            else
                returnedData = response   
            end

            if countTbl(returnedData) < expectedReturns then
                return end --> Not enough data yet
                
            clean() --> Clean up
            
            if typeof(pipeline:getData()) == 'table' then
                returnedData = pipeline:getData() end
            resolve(returnedData) --> Resolve promise
        end
		thisCache:setValue(
            requestId,
            resolver
        )

        --> Send invocation
        if isServer then
            if self._targets then
                if self._filterType == 'include' then
                    for _, target in pairs(self._targets) do
                        expectedReturns += 1
                        self.__event:FireClient(target, finalData)
                    end
                elseif self._filterType == 'exclude' then
                    for _, target in pairs(players:GetPlayers()) do
                        if table.find(self._targets, target) then continue end
                        expectedReturns += 1
                        self.__event:FireClient(target, finalData)
                    end
                end
            elseif self._globalBroadcast then
                expectedReturns = countTbl(players:GetPlayers())
                self.__event:FireAllClients(finalData)
            end
        else
            expectedReturns = 1
            self.__event:FireServer(finalData)
        end
    end)
    return promise
end

--]] Channel
local event = {}
event.__index = event

function event.new(channel: types.NetworkingChannel, _event: RemoteEvent) : types.NetworkingEvent
    local self = setmetatable({} :: types.self_event, event)

    --> Event instance
    self.__event = _event
    self.__middleware = middleware.new()
    self.__connections = {}

    --> Invoke resolvers
    self.__invoke_resolvers = {}

    return self
end

function event:with() : types.NetworkingCall
    return call.new(self) end

function event:handle(callback: (req: types.ConnectionRequest, res: types.ConnectionResult) -> ...any)
    local newConn = connection.new(callback, self)
    self.__connections[newConn.connectionId] = newConn
    connectionCache:findTable(self.__event):setValue(newConn.connectionId, newConn)
end

function event:useMiddleware(phase: string, order: number, callback: (pipeline: types.NetworkingPipeline) -> nil, msettings: {protected: boolean})
	msettings = msettings or {}
	
	self.__middleware:use(phase, order, callback, {
		['protected'] = msettings.protected or false
	})
end

return event