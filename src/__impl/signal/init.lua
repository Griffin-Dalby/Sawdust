--[[

    Sawdust Signaling Module

    Griffin E. Dalby
    2025.06.16

    This module is a lightweight, intuitive, embedded signaling module
    you can simply add into your modules to provide custom events that
    can easily be connected and fired.

--]]

--]] Services
local https = game:GetService('HttpService')

--]] Signal Connection
local connection = {}
connection.__index = connection

type self_connection<T> = {
    uuid: string,
    callback: (T) -> nil,
}
export type SawdustSignalConnection<T> = typeof(setmetatable({} :: self_connection<T>, connection))

function connection.new(signal: SawdustSignal<any>, callback: (...any) -> nil)
    local self = setmetatable({} :: self_connection<any>, connection)

    self.uuid = `_sawdust_connection_{https:GenerateGUID(false)}`
    self.callback = callback

    self.__disconnect = function()
        signal.connections[self.uuid] = nil

        table.clear(self)
    end

    return self
end

function connection:disconnect()
    self.__disconnect() end

--]] Signal
local signal = {}
signal.__index = signal

type self_signal<T> = {
    uuid: string,
    connections: {[string]: SawdustSignalConnection<T>}
}
export type SawdustSignal<T> = typeof(setmetatable({} :: self_signal<T>, signal))

--[[
    Creates a new Signal attributed to a Emitter. This is the instance
    you can Fire & Connect to.

    @param emitter Emitter to attribute to

    @return SawdustSignal<any>
]]
function signal.new(emitter: SawdustEmitter) : SawdustSignal<any>
    local self = setmetatable({} :: self_signal<any>, signal)

    self.uuid = `_sawdust_signal_{https:GenerateGUID(false)}`
    self.connections = {}

    self.__discard = function()
        emitter.signals[self.uuid] = nil

        for _, signal : SawdustSignalConnection<any> in pairs(self.connections) do
            signal:disconnect(); end
        
        table.clear(self)
    end

    emitter.signals[self.uuid] = self

    return self
end

--[[
    Creates a new Signal connection, which fires each time it gets called.

    @param callback Function to run on event

    @return SawdustSignalConnection
]]
function signal:connect(callback: (...any) -> nil) : SawdustSignalConnection<any>
    local connection = connection.new(self, callback)
    self.connections[connection.uuid] = connection

    return connection
end

--[[
    Creates a new Signal connection, that disconnects after the first fire.

    @param callback Function to run on event

    @return SawdustSignalConnection
]]
function signal:once(callback: (...any) -> nil) : SawdustSignalConnection<any>
    local connection
    connection = self:connect(function(...)
        callback(...)
        self.connections[connection.uuid] = nil
    end)

    return connection
end

--[[
    Fires the signal with arguments, which runs all attached code.

    @param tuple<any> Arguments
]]
function signal:fire(...)
    local args = {...}
    for connectionUUID: string, connection: (...any) -> nil in pairs(self.connections) do
        local s, e = pcall(function()
            connection.callback(unpack(args))
        end)

        if not s then
            warn(`[{script.Name}] Failure while firing sawdust signal!`)
            error(e)
        end
    end
end

--[[
    Discards this signal
]]
function signal:discard()
    self.__discard() end

--]] Emitter
local emitter = {}
emitter.__index = emitter

type self_emitter = {
    signals: {}
}
export type SawdustEmitter = typeof(setmetatable({} :: self_emitter, emitter))

--[[
    Constructor to create a new emitter, the base class that Signal Events
    derive from.

    @return SawdustEmitter
]]
function emitter.new() : SawdustEmitter
    local self = setmetatable({} :: self_emitter, emitter)

    self.signals = {}

    return self
end

--[[
    Creates a new event, and adds it to the emitter.

    @return SawdustSignal<any>
]]
function emitter:newSignal() : SawdustSignal<any>
    local newSignal = signal.new(self)
    return newSignal
end

--[[
    Destroys all signals and renders emitter unusable.    
]]
function emitter:discard()
    for _, signal: SawdustSignal<any> in pairs(self.signals) do
        signal:discard() end
        
    table.clear(self.signals)
    table.clear(self)
end

return emitter