--[[

    Sawdust Networking Implementation

    Griffin E. Dalby
    2025.06.14

    Easy to use networking module that splits events up into "Channels",
    with easy access to firing globally or directly, and smart connection 
    handling.

--]]

--]] Services
local runService = game:GetService('RunService')
local players = game:GetService('Players')
local https = game:GetService('HttpService')

--]] Settings
local isServer = runService:IsServer()

local __internal = script.Parent.Parent.__internal
local __settings = require(__internal.__settings)

--]] Modules
local __middleware = require(script.__middleware)

--]] Memory
local connections = {} :: {[RemoteEvent|RemoteFunction]: {[string]: (...any) -> nil}}
local middleware = {} :: {[RemoteEvent|RemoteFunction]: __middleware.SawdustNetworkingMiddleware}

--]] Sections
local event = {}
local connection = {}
event.__index = event
connection.__index = connection

--]] Event
type self_event = {
    attachedEvent: RemoteEvent|RemoteFunction,
    middleware: __middleware.SawdustNetworkingMiddleware }
export type SawdustEvent = typeof(setmetatable({} :: self_event, event))

type self_connection = {
    attachedEvent: RemoteEvent|RemoteFunction,
    callback: (...any) -> nil,
    uuid: string }
export type SawdustConnection = typeof(setmetatable({} :: self_connection, event))

--[[ event.attach(event: RemoteEvent|RemoteFunction) 
    Constructor function to create a new handled event
    based off of an existing event. ]]
function event.attach(aEvent: RemoteEvent|RemoteFunction) : SawdustEvent
    local self = setmetatable({} :: self_event, event)

    self.attachedEvent = aEvent
    
    if not middleware[aEvent] then
        middleware[aEvent] = __middleware.new() end
    self.middleware = middleware[aEvent]

    return self
end

--[[ event:fire(Player?, args...)
    Fires the remote function/event.
    If the first argument is a player, it'll fire to them.
    If it isn't, it'll be broadcasted globally.
    
    And of course, ]]
function event:fire(...) self = self :: self_event
    --> Parse args
    local args = {...}
    local player: Player = nil
    if isServer then
        if (typeof(args[1]) == "Instance") and (args[1]:IsA('Player')) and isServer then
            player = args[1]
            table.remove(args, 1)
        end
    end

    --> "Before" middleware phase
    local success, pipeline = pcall(self.middleware.run, self.middleware, 'before', args)
    if not success then
        warn(`[{script.Name}] "Before" middleware error: {pipeline}`)
        return
    end

    args = pipeline:getArguments()
    local halted = pipeline:isHalted()
    local errorMsg = pipeline:getError()

    if halted then
        warn(`[{script.Name}] "Before" middleware halted event call! ({self.attachedEvent.Parent.Name}.{self.attachedEvent.Name})`)
        warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
        return
    end

    --> Fire event
    if self.attachedEvent:IsA('RemoteEvent') or self.attachedEvent:IsA('UnreliableRemoteEvent') then
        local thisEvent = self.attachedEvent :: RemoteEvent

        if isServer then
            if player then
                thisEvent:FireClient(player, unpack(args)) else
                thisEvent:FireAllClients(unpack(args)) end
        else
            thisEvent:FireServer(unpack(args))
        end
    elseif self.attachedEvent:IsA('RemoteFunction') then
        local thisEvent = self.attachedEvent :: RemoteFunction

        if isServer then
            if player then
                thisEvent:InvokeClient(player, unpack(args)) else
                for _, tPlayer in pairs(players:GetPlayers()) do
                    thisEvent:InvokeClient(tPlayer, unpack(args))
                end end
        else
            local res = thisEvent:InvokeServer(unpack(args))
            
            success, pipeline = pcall(self.middleware.run, self.middleware, 'after', res)
            if not success then
                warn(`[{script.Name}] "After" middleware error: {pipeline}`)
                return 
            end

            res = pipeline.res
            halted = pipeline.halted
            errorMsg = pipeline.errorMessage

            if halted then
                warn(`[{script.Name}] "After" middleware halted event call! ({self.attachedEvent.Parent.Name}.{self.attachedEvent.Name})`)
                warn(`[{script.Name}] {errorMsg or 'No message was provided.'}`)
                return
            end

            return unpack(res)
        end
    end

    --> After
end

--[[ event:connect(callback: (...any) -> nil)
    Attaches a connection callback to the attached event. ]]
function event:connect(callback: (...any) -> nil): SawdustConnection
    local event = self.attachedEvent :: RemoteEvent|RemoteFunction
    local self = setmetatable({} :: self_connection, connection)

    self.attachedEvent = event
    self.callback = callback
    self.uuid = https:GenerateGUID(false)

    local function call(...) --> Base call, iterates and calls each callback.
        local args = {...}

        for uuid, connection: SawdustConnection in pairs(connections[event]) do
            coroutine.wrap(function()
                connection.callback(unpack(args))
            end)()
        end
    end

    if not connections[event] then
        connections[event] = {} 
        if event:IsA('RemoteEvent') then
            if isServer then
                connections[event].main = event.OnServerEvent:Connect(call) else 
                connections[event].main = event.OnClientEvent:Connect(call) end
        else
            if isServer then
                event.OnServerInvoke = call else 
                event.OnClientInvoke = call end
        end
    end

    connections[event][self.uuid] = self
    return connection
end

--[[ connection:disconnect()]]
function connection:disconnect()
    connections[self.attachedEvent][self.uuid] = nil
    table.clear(self)
end

--]] Module
local networking = {}

--[[ Channel.getChannel(channelName: string!)
    Fetches a specified channel with "channelName", and
    providing a special table to fetch events. ]]
function networking.getChannel(channelName: string)
    local self = {}
    
    local channel = __settings.networking.fetchFolder:FindFirstChild(channelName)
    for _, remote: RemoteEvent|RemoteFunction in pairs(channel:GetChildren()) do
        self[remote.Name] = event.attach(remote) end

    return self
end

return networking