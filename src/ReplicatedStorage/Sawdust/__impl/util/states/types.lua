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

export type self_state = {}
export type SawdustState = typeof(setmetatable({} :: self_state, state))

function state.new(state_machine: StateMachine, state_name: string) : SawdustState end

--#endregion

--[[ MACHINE ]]--
--#region
local machine = {}

export type self_machine = {
    states: {
        [string] : SawdustState
    }
}
export type StateMachine = typeof(setmetatable({} :: self_machine, machine))

function machine.new() : StateMachine end
function machine:state(state_name: string) : SawdustState end

--#endregion

return types