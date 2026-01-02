--[[

    State Manager Types

    Griffin Dalby
    2025.09.04

    This module will provide State Manager Types.

--]]

local signal = require(script.Parent.Parent.signal)

local types = {}

--[[ STATE ]]--
--#region
local state = {}
state.__index = state

export type StateEnvironment<TShEnv, TStEnv> = { --] Fill with packaged env data
    total_state_time: number, --] Total time in this state
    shared: TShEnv,           --] Shared data located in machine
} & TStEnv

export type self_state<TShEnv, TStEnv> = {
    name: string,
    machine: () -> StateMachine<TShEnv>,

    environment: StateEnvironment<TShEnv, TStEnv>,

    hooks: {
        enter:  {[string]: { id:string, call:(env: StateEnvironment<TShEnv, TStEnv>) -> nil }},
        exit:   {[string]: { id:string, call:(env: StateEnvironment<TShEnv, TStEnv>) -> nil }},

        update: {[string]: { id:string, call:(env: StateEnvironment<TShEnv, TStEnv>, delta_time: number) -> nil }}
    },

    transitions: {

    },

    state_updated: signal.SawdustSignal<any>,

}
export type SawdustState<TShEnv, TStEnv> = typeof(setmetatable({} :: self_state<TShEnv, TStEnv>, state))

function state.new<TShEnv, TStEnv>(state_machine: StateMachine<TShEnv>, state_name: string) : SawdustState<TShEnv, TStEnv> end

function state:hook<TShEnv, TStEnv>(
    to: string,
    id: string,
    callback: (env: StateEnvironment<TShEnv, TStEnv>) -> nil
) : SawdustState<TShEnv, TStEnv> end

function state:unhook<TShEnv, TStEnv>(
    id: string
) : SawdustState<TShEnv, TStEnv> end

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
    conditional: string|number|(env: StateEnvironment<any, any>)->boolean
}

export type self_transition = {
    __fetch_state: ('from'|'to') -> SawdustState<any, any>?,
    __fetch_machine: StateMachine<any>,
    __priority: number,

    conditions: { TransitionConditionData },
}
export type StateTransition = typeof(setmetatable({} :: self_transition, transition))

function transition.new() : StateTransition end

function transition:runTransition() end
function transition:runConditionals() end
function transition:eventCalled(event_id: string) end

function transition:priority(priority: number) : StateTransition end
function transition:when(conditional: (env: StateEnvironment<any, any>) -> boolean) : StateTransition end
function transition:on(event_id: string) : StateTransition end
function transition:after(time: number) : StateTransition end

--#endregion

--[[ MACHINE ]]--
--#region
local machine = {}
machine.__index = machine

export type self_machine<TShEnv> = {
    c_state: SawdustState<TShEnv, any>?,
    states: {
        [string] : SawdustState<TShEnv, any>
    },

    environment: TShEnv
}
export type StateMachine<TShEnv> = typeof(setmetatable({} :: self_machine<TShEnv>, machine))

function machine.new<TShEnv>() : StateMachine<TShEnv> end
function machine:state<TShEnv, TStEnv>(state_name: string) : SawdustState<TShEnv, TStEnv> end
function machine:event(event_name: string) end
function machine:switchState(state_name: string) end

--#endregion

return types