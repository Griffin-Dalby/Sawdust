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

    self.c_state = nil
    self.states = {}
    self.environment = {}

    return self
end

--[[ STATE CONTROL ]]--
--#region

--[[ machine:state(state_name: string)
    This will create a new state & open a handler. ]]
function machine:state(state_name: string) : __type.SawdustState
    assert(state_name, `attempt to create state with nil state_name!`)
    assert(type(state_name) == 'string', `state_name is a "{type(state_name)}", but it was expected to be a string!`)
    assert(not self.states[state_name], `attempt to create duplicate state "{state_name}"!`)

    local new_state = state.new(self, state_name)
    self.states[state_name] = new_state

    return new_state
end

--[[ machine:switchState(state_name: string)
    This will switch this machine's state to state_name. ]]
function machine:switchState(state_name: string)
    assert(state_name, `attempt to switch state with nil state_name!`)
    assert(type(state_name) == 'string', `state_name is a "{type(state_name)}", but it was expected to be a string!`)
    assert(self.states[state_name], `attempt to switch to an invalid state "{state_name}"!`)

    local state_locked = false
    if self.c_state then
        --> Cleanup last state
        state_locked = not self.c_state:exited()
    end
    if state_locked then
        return end

    self.c_state = self.states[state_name]
    self.c_state:entered()
end

--#endregion

return machine