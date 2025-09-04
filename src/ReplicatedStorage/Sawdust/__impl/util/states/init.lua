--[[

    Sawdust State Machine

    Griffin Dalby
    2025.09.04

    This implementation will provide a simple yet deeply flexible interface for
    creating state machines, with a flow system like Unity's state machines.

--]]

--]] Services
--]] Modules
local __type = require(script.types)
local state = require(script.state)

--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Implementation
local machine = {}
machine.__index = machine

--[[ machine.create() : StateMachine
    Constructor function for the State Machine. ]]
function machine.create() : __type.StateMachine
    local self = setmetatable({} :: __type.self_machine, machine)

    self.states = {}

    return self
end

--[[ machine:state(state_name: string)
    This will create a new state & open a handler. ]]
function machine:state(state_name: string) : __type.SawdustState
    assert(state_name, `attempt to create state with nil state_name!`)
    assert(type(state_name) == 'string', `state_name is a "{type(state_name)}", but it was expected to be a string!`)
    assert(not self.states[state_name], `attempt to create duplicate state "{state_name}"!`)

    local new_state = state.new(self, state_name)
end

return machine