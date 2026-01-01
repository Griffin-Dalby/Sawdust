--[[

    Networking Pipeline

    Griffin Dalby
    2025.07.06

    Provides a "pipeline" instance allowing the developer to modify
    downstream data such as call and return data, as well as halting
    and error messaging.

--]]
    
--]] Modules
--> Networking logic
local types = require(script.Parent.types)

--> Sawdust implementations
local __impl = script.Parent.Parent

--> Sawdust
local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Channel
local pipeline = {} :: types.methods_pipeline
pipeline.__index = pipeline

function pipeline.new(phase: string, call: types.NetworkingCall) : types.NetworkingPipeline
    local self = setmetatable({} :: types.self_pipeline, pipeline)

    self.phase = phase
    self.intent = call._intent
    self.data = call._data

    self.halted = false
    self.errorMsg = nil

    return self
end

function pipeline:setIntent(intent: string)
    self.intent = intent
    return true end
function pipeline:setData(data: {any}, ...): boolean
    local fixData
    if typeof(data) ~= 'table' then
        fixData = {...}
        table.insert(fixData, 1, data)
    end

    self.data = fixData or data
    return true end
function pipeline:setHalted(halted: boolean): boolean
    self.halted = halted; return true end
function pipeline:setError(message: string) : boolean
    self.errorMsg = message; return true end

function pipeline:getIntent(): ...any
    return self.intent end
function pipeline:getData(): {any}
    return self.data end
function pipeline:isHalted(): boolean
    return self.halted end
function pipeline:getError(): string?
    return self.errorMsg end
function pipeline:getPhase(): string
    return self.phase end

return pipeline