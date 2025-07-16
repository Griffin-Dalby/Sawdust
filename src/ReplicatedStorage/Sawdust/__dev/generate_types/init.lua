--[[

    Sawdust GenerateTypes

    Griffin Dalby
    2025.06.07

    Dynamically generates types for all implementations utilizing
    dynamic typechecking.

--]]

local sawdustRoot = script.Parent.Parent
local __internal = sawdustRoot.__internal

local __settings = require(__internal.__settings)

--> Generator
local generator = {}
generator.__index = generator

function generator.new()
    local self = setmetatable({}, generator)

    self.entries = {}

    return self
end

function generator:newEntry(entryName: string, types: {string})
    self.entries[entryName] = types
end

function generator:generate()
    
end

--> Generation
return function ()
    --> Check for __env
    local __env = sawdustRoot:FindFirstChild('__env')
    if not __env then
        __env = Instance.new('ModuleScript')
        __env.Name = '__env'
        __env.Parent = sawdustRoot end

    local gen = generator.new()

    --> Compile networking
    
end