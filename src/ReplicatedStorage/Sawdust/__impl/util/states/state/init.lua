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

    --]] Setup Internal
    self.name = state_name
    self.machine = function() : __type.StateMachine
        return state_machine end

    --]] Setup State
    self.environment = {}

    self.hooks = {
        enter = {},
        exit = {},

        update = {},
    }

    self.transitions = {}

    return self
end

--[[ LIFECYCLE HOOKS ]]--
--#region

--[[ state:hook(to: string, callback: (env: StateEnvironment) -> nil)
    This will hook a function to a specific lifecycle event. ]]
function state:hook(to: string, callback: (env: __type.StateEnvironment) -> nil)
    assert(to, `:hook() missing argument #1! This is the ID this hook will link to.`)
    assert(callback, `:hook() missing argument #2! This is what will be linked, if you meant to unhook it run :unhook().`)

    local compiled_hook = { callback }
    self.hooks[to] = compiled_hook
end

--[[ state:unhook(id: string)
    This will unhook a function from a specific lifecycle event. ]]
function state:unhook(id: string)
    assert(id, `:unhook() missing argument #1! This is the ID to unhook.`)
    assert(self.hooks[id][1], `hook @ "{id}" isn't linked!`)

    self.hooks[id] = {}
end

--#endregion

--[[ INTERNAL CONTROLLER ]]--
--#region

--[[ state:entered()
    This will trigger the "entered" lifecycle for this state, and started the
    update loop. ]]
function state:entered()
    
end

--[[ state:exited()
    This will trigger the "exited" lifecycle for this state, and stop the
    update loop. ]]
function state:exited()
    
end

--#endregion

return state