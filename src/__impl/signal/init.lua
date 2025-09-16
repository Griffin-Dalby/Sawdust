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

type self_connection = {
    uuid: string,
    callback: (...any) -> nil,
}
export type SawdustSignalConnection = typeof(setmetatable({} :: self_connection, connection))

function connection.new(signal: SawdustSignal, callback: (...any) -> nil)
    local self = setmetatable({} :: self_connection, connection)

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

type self_signal = {
    uuid: string,
    connections: {[string]: SawdustSignalConnection}
}
export type SawdustSignal = typeof(setmetatable({} :: self_signal, signal))

function signal.new(emitter: SawdustEmitter) : SawdustSignal
    local self = setmetatable({} :: self_signal, signal)

    self.uuid = `_sawdust_signal_{https:GenerateGUID(false)}`
    self.connections = {}

    self.__discard = function()
        emitter.signals[self.uuid] = nil

        for _, signal : SawdustSignalConnection in pairs(self.connections) do
            signal:disconnect(); end
        
        table.clear(self)
    end

    emitter.signals[self.uuid] = self

    return self
end

function signal:connect(callback: (...any) -> nil) : SawdustSignalConnection
    local connection = connection.new(self, callback)
    self.connections[connection.uuid] = connection

    return connection
end

function signal:once(callback: (...any) -> nil) : SawdustSignalConnection
    local connection
    connection = self:connect(function(...)
        callback(...)
        self.connections[connection.uuid] = nil
    end)

    return connection
end

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

function signal:discard()
    self.__discard() end

--]] Emitter
local emitter = {}
emitter.__index = emitter

type self_emitter = {
    signals: {}
}
export type SawdustEmitter = typeof(setmetatable({} :: self_emitter, emitter))

--[[ emitter.new()
    Constructor to create a new emitter. ]]
function emitter.new() : SawdustEmitter
    local self = setmetatable({} :: self_emitter, emitter)

    self.signals = {}

    return self
end

--[[ emitter:newSignal()
    Creates a new event, and adds it to the emitter. ]]
function emitter:newSignal() : SawdustSignal
    local newSignal = signal.new(self)
    return newSignal
end

--[[ emitter:discard()
    Destroys all signals and renders emitter unusable. ]]
function emitter:discard()
    for _, signal: SawdustSignal in pairs(self.signals) do
        signal:discard() end
        
    table.clear(self.signals)
    table.clear(self)
end

return emitter