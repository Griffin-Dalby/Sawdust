--[[

    State Manager Types

    Griffin Dalby
    2025.09.04

    This module will provide State Manager Types.

--]]

local types = {}

--[[ STATE ]]--
--#region
local state = {}
state.__index = state

export type StateEnvironment = { --] Fill with packaged env data
    total_state_time: number, --] Total time in this state
    shared: {},               --] Shared data located in machine
}

export type self_state = {
    name: string,
    machine: () -> StateMachine,

    environment: StateEnvironment,

    hooks: {
        enter:  { (env: StateEnvironment) -> nil },
        exit:   { (env: StateEnvironment) -> nil },

        update: { (env: StateEnvironment, delta_time: number) -> nil }
    },

    transitions: {

    }

}
export type SawdustState = typeof(setmetatable({} :: self_state, state))

function state.new(state_machine: StateMachine, state_name: string) : SawdustState end

function state:hook(to: string, callback: (env: StateEnvironment) -> nil) : SawdustState end
function state:unhook(id: string) : SawdustState end

function state:entered() : boolean end
function state:exited() : boolean end

function state:transition(state_name: string) : StateTransition end

--#endregion

--[[ TRANSITION ]]--
--#region
local transition = {}
transition.__index = transition

export type TransitionConditionData = {
    type: string,
    conditional: string|number|(env: StateEnvironment)->boolean
}

export type self_transition = {
    __fetch_state: ('from'|'to') -> SawdustState?,
    __fetch_machine: StateMachine,
    __priority: number,

    conditions: { TransitionConditionData },
}
export type StateTransition = typeof(setmetatable({} :: self_transition, transition))

function transition.new() : StateTransition end

function transition:runTransition() end
function transition:runConditionals() end
function transition:eventCalled(event_id: string) end

function transition:priority(priority: number) : StateTransition end
function transition:when(conditional: (env: StateEnvironment) -> boolean) : StateTransition end
function transition:on(event_id: string) : StateTransition end
function transition:after(time: number) : StateTransition end

--#endregion

--[[ MACHINE ]]--
--#region
local machine = {}
machine.__index = machine

export type self_machine = {
    c_state: SawdustState?,
    states: {
        [string] : SawdustState
    },

    environment: {}
}
export type StateMachine = typeof(setmetatable({} :: self_machine, machine))

function machine.new() : StateMachine end
function machine:state(state_name: string) : SawdustState end
function machine:event(event_name: string) end
function machine:switchState(state_name: string) end

--#endregion

return types