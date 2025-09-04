--[[

    Sawdust Tween Environment Controller

    Griffin Dalby
    2025.09.03

    Controller allowing intuitive control of individual environment groups.

--]]

local controller = {}
controller.__index = controller

type self = {
    values: {}
}
export type EnvironmentController = typeof(setmetatable({} :: self, controller))

--[[ controller.new()
    Generates a generic controller for the tween environment ]]
function controller.new() : EnvironmentController
    local self = setmetatable({} :: self, controller)

    self.values = {}

    return self
end

--[[ controller:has(id: string): boolean
    Returns boolean representing existence of value at provided id. ]]
function controller:has(id: string) : boolean
    assert(id~=nil, `attempt to :get() with a nil id!`)
    assert(type(id)=='string', `attempt to :get() with invalid type id! (provided: {type(id)}, expected: string)`)

    return self.values[id]~=nil
end

--[[ controller:get(id: string): any?
    Attempts to fetch & return a value w/ provided id. ]]
function controller:get(id: string) : any?
    assert(id~=nil, `attempt to :get() with a nil id!`)
    assert(type(id)=='string', `attempt to :get() with invalid type id! (provided: {type(id)}, expected: string)`)
    
    return self.values[id]
end

--[[ controller:list()
    Dumps a list of all values. ]]
function controller:list() : {[string]: any}
    return self.values end

--[[ controller:register(id: string, value: any)
    Registers value at id. ]]
function controller:register(id: string, value: any)
    assert(id, `attempt to :register() with nil id.`)
    assert(type(id)=='string', `attempt to :register() with invalid type id! (provided: {type(id)}, expected: string)`)

    assert(value, `attempt to :register() with nil value.`)
    assert(not self.values[id], `attempt to register id to "{id}", which is already occupied!`)

    self.values[id] = value
end

--[[ controller:unregister(id: string)
    Unregisters any existing value residing at provided id. ]]
function controller:unregister(id: string)
    assert(id~=nil, `attempt to :unregister() with a nil id!`)
    assert(type(id)=='string', `attempt to :unregister() with invalid type id! (provided: {type(id)}, expected: string)`)

    self.values[id] = nil
end

return controller