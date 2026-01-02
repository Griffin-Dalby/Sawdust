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

--]] Functions
function count_tbl(t: {}) local i=0; for _ in t do i+=1 end; return i end
function run_hooks(hook_tbl: {[string]: {id:string, call:(env: __type.StateEnvironment<any, any>) -> nil}}, ...)
    for id: string, hook in pairs(hook_tbl) do
        hook.call(...)
    end
end

--]] Interface
local state = {}
state.__index = state

--[[
    This will create a new state, and open a composer interface.

    @param state_machine State Machine this state is attributed to
    @param state_name Name of this state
]]
function state.new<TShEnv, TStEnv>(state_machine: __type.StateMachine<TShEnv>,
        state_name: string) : __type.SawdustState<TShEnv, TStEnv>

    local self = setmetatable({} :: __type.self_state<TShEnv, TStEnv>, state)

    --]] Setup Internal
    self.name = state_name
    self.machine = function() : __type.StateMachine<TShEnv>
        return state_machine end

    --]] Setup State
    self.environment = {} :: __type.StateEnvironment<TShEnv, TStEnv>
    self.environment.shared = state_machine.environment :: TShEnv

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

--[[ state:hook(to: string, id: string, callback: (env: StateEnvironment) -> nil)
    This will hook a function to a specific lifecycle event.

    &to will be searched for in the internal hooks, and if found the &callback
    will be attached with the specific &id. 
    
    @param to Identifier of the hook to embed this in
    @param id Identifier of this specific function
    @param callback Code that runs when hook is called
    
    @return SawdustState (Chained)
]]
function state:hook<TShEnv, TStEnv>(
        to: string,
        id: string,
        callback: (env: __type.StateEnvironment<TShEnv, TStEnv>) -> nil
    ) : __type.SawdustState<TShEnv, TStEnv>

    assert(to, `:hook() missing argument #1! This is the ID this hook will link to.`)
    assert(id, `:hook() missing argument #2! This is the ID this callback can be pointed to.`)
    assert(callback, `:hook() missing argument #3! This is what will be linked, if you meant to unhook it run :unhook().`)

    assert(self.hooks[to], `unable to find lifecycle hook "{to}"!`)
    assert(not self.hooks[to][id], `attempt to overwrite existing lifecycle hook "{id}" in "{id}"!`)

    local compiled_hook = { id=id, call=function(env, ...)
        callback(env :: __type.StateEnvironment<TShEnv, TStEnv>, ...)
    end }
    self.hooks[to][id] = compiled_hook

    return self
end

--[[
    This will unhook a function from a specific lifecycle event.

    &from will be searched for in the internal hooks, and if found &id will be
    searched for inside, and an attempt will be make to unhook the callback. 
    
    @param from Identifier of the hook to remove from
    @param id Identifier of the function to remove

    @return SawdustState (Chained)
]]
function state:unhook<TShEnv, TStEnv>(from: string, id: string) : __type.SawdustState<TShEnv, TStEnv>
        
    assert(from, `:unhook() missing argument #1! This is the ID pointing towards the hook list.`)
    assert(id, `:unhook() missing argument #2! This is the ID to unhook from the hook list.`)
    assert(self.hooks[from][id], `hook @ {from}.{id} isn't linked!`)

    self.hooks[from][id] = nil
    return self
end

--#endregion

--[[ HOOK EVENTS ]]--
--#region

--[[
    This will trigger the "entered" lifecycle for this state, and start the
    update loop. 
    
    @return Success (boolean)
]]
function state:entered() : boolean
    self.environment.total_state_time = 0

    if self.__update then
        self.__update:Disconnect() end

    local prioritized_list = {}
    local pl_check_list = {}
    for _, transition : __type.StateTransition in pairs(self.transitions) do
        if pl_check_list[transition.__priority] then
            error(`there are multiple transitions @ priority {tostring(transition.__priority)}!`)
            end
            
        pl_check_list[transition.__priority] = true
        table.insert(prioritized_list, transition)
    end
    table.sort(prioritized_list, function(a, b)
        return a.__priority > b.__priority end)

    self.__update = runService.Heartbeat:Connect(function(delta)
        if not self.environment then
            warn(`[{script.Name}] Environment was cleared, it has been rebuilt. (State ID: {self.name})`)
            self.environment = {}
            self.environment.shared = self.machine().environment end
        self.environment.total_state_time+=delta

        --] Run Update Hooks
        if count_tbl(self.hooks.update)>0 then
            run_hooks(self.hooks.update, self.environment, delta)
        end

        --] Run Transition Conditions
        local did_transition = false
        for priority: number, i_transition: __type.StateTransition in ipairs(prioritized_list) do
            did_transition = i_transition:runConditionals()
            if did_transition then break end
        end
    end)

    if count_tbl(self.hooks.enter)>0 then
        run_hooks(self.hooks.enter, self.environment)
    end

    return true
end

--[[
    This will trigger the "exited" lifecycle for this state, and stop the
    update loop. 

    @return Success (boolean)
]]
function state:exited() : boolean
    if self.__update then
        self.__update:Disconnect()
        self.__update = nil end

    if count_tbl(self.hooks.exit)>0 then
        run_hooks(self.hooks.exit, self.environment)
    end

    return true
end

--#endregion

--[[ TRANSITIONS ]]--
--#region

--[[
    Create a transition condition from the current state to another.

    @param state_name State to transition into

    @return StateTransition
]]
function state.transition<TShEnv>(self: __type.StateMachine<TShEnv>,
        state_name: string) : __type.StateTransition

    assert(state_name~=self.name, `cannot map transition to same state!`)
    assert(not self.transitions[state_name], `transition {self.name} -> {state_name} is already mapped!`)
    
    local machine = self.machine() :: __type.StateMachine<TShEnv>
    local found_state = machine.states[state_name] :: __type.SawdustState<TShEnv, any>

    assert(found_state, `failed to find state "{state_name}" inside state machine!`)

    local new_transition = transition.new{self, found_state}
    self.transitions[state_name] = new_transition
    new_transition:priority(count_tbl(self.transitions))

    return new_transition
end

--#endregion

return state