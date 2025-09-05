--[[

    StateManager State Interface

    Griffin Dalby
    2025.09.04

    This module will provide an interface for the State object.

--]]

--]] Services
local runService = game:GetService('RunService')

--]] Modules
local __type = require(script.Parent.types)
local transition = require(script.transition)

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
    self.environment.shared = state_machine.environment

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
function state:hook(to: string, callback: (env: __type.StateEnvironment) -> nil) : __type.SawdustState
    assert(to, `:hook() missing argument #1! This is the ID this hook will link to.`)
    assert(callback, `:hook() missing argument #2! This is what will be linked, if you meant to unhook it run :unhook().`)

    local compiled_hook = { callback }
    self.hooks[to] = compiled_hook
    return self
end

--[[ state:unhook(id: string)
    This will unhook a function from a specific lifecycle event. ]]
function state:unhook(id: string) : __type.SawdustState
    assert(id, `:unhook() missing argument #1! This is the ID to unhook.`)
    assert(self.hooks[id][1], `hook @ "{id}" isn't linked!`)

    self.hooks[id] = {}
    return self
end

--#endregion

--[[ HOOK EVENTS ]]--
--#region

--[[ state:entered()
    This will trigger the "entered" lifecycle for this state, and start the
    update loop. ]]
function state:entered() : boolean
    self.environment.total_state_time = 0

    if self.__update then
        self.__update:Disconnect() end

    local prioritized_list = {}
    local pl_check_list = {}
    for _, transition : __type.StateTransition in pairs(self.transitions) do
        if pl_check_list[transition.__priority] then
            error(`there are multiple transitions @ priority {tostring(transition.__priority)}!`)
            break end
            
        pl_check_list[transition.__priority] = true
        table.insert(prioritized_list, transition)
    end
    table.sort(prioritized_list, function(a, b)
        return a.__priority > b.priority end)

    self.__update = runService.Heartbeat:Connect(function(delta)
        self.environment.total_state_time+=delta

        --] Run Update Hooks
        if #self.hooks.update>0 then
            for _, update_hook in pairs(self.hooks.update) do
                update_hook(self.environment, delta) end
        end

        --] Run Transition Conditions
        local did_transition = false
        for priority: number, i_transition: __type.StateTransition in pairs(prioritized_list) do
            did_transition = i_transition:runConditionals()
            if did_transition then break end
        end
    end)

    if #self.hooks.enter>0 then
        for _, enter_hook in pairs(self.hooks.enter) do
            enter_hook(self.environment) end
    end

    return true
end

--[[ state:exited()
    This will trigger the "exited" lifecycle for this state, and stop the
    update loop. ]]
function state:exited() : boolean
    if self.__update then
        self.__update:Disconnect()
        self.__update = nil end

    if #self.hooks.exit>0 then
        for _, exit_hook in pairs(self.hooks.exit) do
            exit_hook(self.environment)
        end 
    end

    return true
end

--#endregion

--[[ TRANSITIONS ]]--
--#region

function state:transition(state_name: string) : __type.StateTransition
    assert(state_name~=self.name, `cannot map transition to same state!`)
    assert(not self.transitions[state_name], `transition {self.name} -> {state_name} is already mapped!`)
    
    local machine = self.machine() :: __type.StateMachine
    local found_state = machine.states[state_name] :: __type.SawdustState

    assert(found_state, `failed to find state "{state_name}" inside state machine!`)
    local new_transition = transition.new{self, found_state}
    self.transitions[state_name] = new_transition
    new_transition:priority(#self.transitions)

    return new_transition
end

--#endregion

return state