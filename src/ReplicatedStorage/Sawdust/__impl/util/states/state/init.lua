--[[

    StateManager State Interface

    Griffin Dalby
    2025.09.04

    This module will provide an interface for the State object.

--]]

--]] Services
--]] Modules
local __type = require(script.Parent.types)

--]] Interface
local state = {}
state.__index = state

--[[ state.new()
    This will create a new state, and open a handler interface. ]]
function state.new(state_machine: __type.StateMachine, state_name: string) : __type.SawdustState
    local self = setmetatable({} :: __type.self_state, state)

    return self
end

return state