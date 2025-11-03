--[[

    SawdustState Transition Interface

    Griffin Dalby
    2025.09.04

    This module will provide an interface for the transition manager for states.

--]]

--]] Services
--]] Modules
local __type = require(script.Parent.Parent.types)

--]] Interface
local transition = {}
transition.__index = transition

--[[ transition.new() : StateTransition
    This creates a new, blank transition data builder. ]]
function transition.new(targets: {}) : __type.StateTransition
    local self = setmetatable({} :: __type.self_transition, transition)

    --]] Parse targets
    local t_from: __type.SawdustState<any, any>, t_to: __type.SawdustState<any, any> =
        unpack(targets)

    assert(t_from, `malformed targets table! Failed to find t_from.`)
    assert(t_to, `malformed targets table! Failed to find t_to.`)

    --]] Build self
    self.__fetch_state = function(target_id: 'from'|'to') : __type.SawdustState<any, any>?
            if target_id == 'from' then return t_from
        elseif target_id == 'to'   then return t_to
        else   error(`attempt to locate target w/ invalid target_id "{target_id}"!`) end
    end

    self.__fetch_machine = function() : __type.StateMachine<any, any>
        return t_from.machine() end

    self.conditions = {}
    self.__priority = 1

    return self
end

--[[ LOGIC ]]--
--#region
function transition:runTransition()
    local machine = self.__fetch_machine() :: __type.StateMachine<any, any>
    machine:switchState(self.__fetch_state('to').name)
end

function transition:runConditionals()
    local do_transition = false
    local t_from = self.__fetch_state('from') :: __type.SawdustState<any, any>

    for _, condition_data in pairs(self.conditions) do
        if condition_data.type == 'custom' then
            do_transition = condition_data.conditional(self.__fetch_state('from').environment)
        elseif condition_data.type == 'time' then
            do_transition = t_from.environment.total_state_time >= condition_data.conditional
        end
    
        if do_transition then break end
    end

    if do_transition then
        self:runTransition() end
    return do_transition
end

function transition:eventCalled(event_id: string)
    local do_transition = false
    for _, condition_data in pairs(self.conditions) do
        if condition_data.type ~= 'event' then continue end
        if condition_data.conditional ~= event_id then continue end
            
        self:runTransition()
        do_transition = true; break
    end

    return do_transition
end

--#endregion

--[[ CONDITIONS ]]--
--#region

--[[ transition:priority(priority: number)
    This will set the priority of this transition, higher numbers will
    be called first. ]]
function transition:priority(priority: number) : __type.StateTransition
    assert(priority, `attempt to set priority to nil!`)
    assert(type(priority)=='number', `attempt to set priority to invalid type! (Provided: {type(priority)}, Expected a number.)`)

    self.__priority = priority
    return self
end

--[[ transition:when(conditional: (env) -> boolean)
    This will add a new condition where the result of the provided callback
    dictates if the transition occurs. ]]
function transition:when(conditional: (env: __type.StateEnvironment<any, any>) -> boolean) : __type.StateTransition
    local condition_data = {}
    condition_data.type = 'custom'
    condition_data.conditional = conditional

    table.insert(self.conditions, condition_data)
    return self
end

--[[ transition:on(event_id: string)
    This will add a new condition awaiting an event call within the state
    machine. ]]
function transition:on(event_id: string) : __type.StateTransition
    local condition_data = {}
    condition_data.type = 'event'
    condition_data.conditional = event_id

    table.insert(self.conditions, condition_data)
    return self
end

--[[ transition:after(time: number)
    This will add a new condition that will wait a certain time, then
    run. ]]
function transition:after(time: number) : __type.StateTransition
    local condition_data = {}
    condition_data.type = 'time'
    condition_data.conditional = time

    table.insert(self.conditions, condition_data)
    return self
end

--#endregion

return transition