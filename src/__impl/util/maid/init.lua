--[[

    Sawdust Maid

    Griffin E. Dalby
    2025.06.16

    This implementation provides a small little cleaning business that
    lets you target certain things and clean it up easily when a object
    is destroyed.

--]]

--]] Internal
local __internal = script.Parent.Parent.Parent.__internal
local __settings = require(__internal.__settings)

local doDebug = __settings.global.debug and __settings.maid.debug

--]] Utility
function formatError(name: string, msg: string): string
    return `[Sawdust.{script.Name}]:{name}() {msg}`
end

--]] Tasks
local tasks = {}
tasks['RBXScriptConnection'] = function(connection: RBXScriptConnection)
    connection:Disconnect() end

tasks['Instance'] = function(instance: Instance)
    instance:Destroy() end

tasks['function'] = function(f: () -> nil)
    f() end

tasks['table'] = function(table: any)
    if typeof(table.discard) == 'function' then    --> Default Sawdust Deconstructor
        table:discard()
    elseif typeof(table.disconnect) == 'function' then --> Sawdust's Networking/Signal Event
        table:disconnect()
    elseif typeof(table.cancel) == 'function' then --> Sawdust's Timer Utility
        table:cancel()


    elseif typeof(table.Destroy) == 'function' then --> Maltyped Roblox Instance
        table:Destroy()
    elseif typeof(table.Disconnect) == 'function' then --> Maltyped Roblox Connection
        table:Disconnect()
    else
        error(`Unrecognized cleanup table!`)
    end
end

tasks['nil'] = function() end

--]] Maid Wrapper
local wrapper = {}
wrapper.__index = wrapper

type self_wrapper = {
    wrappedI: any,
    tags: {[number]: string}
}
export type SawdustMaidWrapper = typeof(setmetatable({} :: self_wrapper, wrapper))

function wrapper.wrap(wrapInstance: any)
    local self = setmetatable({} :: self_wrapper, wrapper)

    local itype = typeof(wrapInstance)
    local task = tasks[itype]
    
    assert(task, formatError('clean', `typeof({itype=='Instance' and wrapInstance.Name or 'WrappedInstance'}) == "{itype}", and maid doesn't support that type.`))

    self.wrappedI = wrapInstance
    self.tags = {}

    return self
end

function wrapper:clean()
    local itype = typeof(self.wrappedI)
    local task = tasks[itype]

    if doDebug then
        print(formatError('clean', `Cleaned up {itype=='Instance' and `"{self.wrappedI.Name}"` or 'wrapped instance.'} (Type: {itype})`)) end

    task(self.wrappedI)
    table.clear(self.tags)
    table.clear(self)
end

function wrapper:addTag(tag: string)
    assert(self.tags, formatError('addTag', 'Wrapped instance missing tag table!'))
    assert(self.wrappedI, formatError('addTag', 'Wrapped instance missing instance reference!'))
    assert(tag, formatError('addTag', 'Tag argument [1] missing!'))

    local tagExists = table.find(self.tags, tag)
    if tagExists then return false end

    table.insert(self.tags, tag)
    if doDebug then
        local itype = typeof(self.wrappedI)
        print(formatError('addTag', `Tag "{tag}" added to {itype=='Instance' and self.wrappedI.Name or 'wrapped instance'}.`)) end
    return true
end

function wrapper:hasTag(tag: string)
    assert(self.tags, formatError('hasTag', 'Wrapped instance missing tag table!'))
    assert(self.wrappedI, formatError('hasTag', 'Wrapped instance missing instance reference!'))
    assert(tag, formatError('hasTag', 'Tag argument [1] missing!'))

    if doDebug then
        local itype = typeof(self.wrappedI)
        print(formatError('hasTag', `Checked if {itype=='Instance' and `"{self.wrappedI.Name}"` or 'wrapped instance'} has tag "{tag}" (Result: {table.find(self.tags, tag)})`)) end
    return table.find(self.tags, tag) ~= nil
end

function wrapper:removeTag(tag: string)
    assert(self.tags, formatError('removeTag', 'Wrapped instance missing tag table!'))
    assert(self.wrappedI, formatError('removeTag', 'Wrapped instance missing instance reference!'))
    assert(tag, formatError('removeTag', 'Tag argument [1] missing!'))

    local itype = typeof(self.wrappedI)
    local iTag = table.find(self.tags, tag)
    if iTag then
        table.remove(self.tags, iTag)
        if doDebug then
            print(formatError('removeTag', `Removed tag "{tag}" from {itype=='Instance' and `"{self.wrappedI.Name}"` or 'wrapped instance.'}`)) end
        return true end
    
    warn(formatError('removeTag', `{itype=='Instance' and `Instance "{self.wrappedI.Name}"` or 'Wrapped instance'} doesn't have tag "{tag}"!`))
    return false
end

--]] Maid
local maid = {}
maid.__index = maid

type self = {
    tracked: {[number]: SawdustMaidWrapper},
    object: {}
}
export type SawdustMaid = typeof(setmetatable({} :: self, maid))

--[[ maid.new()
    Constructor for the Maid instance. ]]
function maid.new(object: {})
    local self = setmetatable({} :: self, maid)

    self.tracked = {}
    self.object = object

    return self
end

--[[ maid:add(item: any?)
    Adds *item* to this Maid instance. ]]
function maid:add(item: any)
    if not item then return end
    if self.tracked[item] then return item end

    local wrapped = wrapper.wrap(item)
    self.tracked[item] = wrapped

    if doDebug then
        print(formatError('add', `Now tracking {(typeof(item)=='Instance') and `"{item.Name}"` or 'new instance'} for Maid instance.`)) end
    return item
end

--[[ maid:tag(item: any?, tag: string)
    Tags *item* with *tag*, making it possible to clean-up per tag. ]]
function maid:tag(item: any, tag: string)
    assert(self.tracked[item], formatError(`addTag`, `{(typeof(item)=='Instance') and `Item {item.Name}` or 'Wrapped instance'} isn't tracked by this Maid instance!`))
    return self.tracked[item]:addTag(tag)
end

--[[ maid:hasTag(item: any?, tag: string)
    Check if *item* is tagged w/ *tag*. ]]
function maid:hasTag(item: any, tag: string)
    assert(self.tracked[item], formatError(`hasTag`, `{(typeof(item)=='Instance') and `Item {item.Name}` or 'Wrapped instance'} isn't tracked by this Maid instance!`))
    return self.tracked[item]:hasTag(tag)
end

--[[ maid:removeTag(item: any?, tag: string)
    Checks and removes tag w/ ID *tag* from *item*. ]]
function maid:removeTag(item: any, tag: string)
    assert(self.tracked[item], formatError(`removeTag`, `{(typeof(item)=='Instance') and `Item {item.Name}` or 'Wrapped instance'} isn't tracked by this Maid instance!`))
    return self.tracked[item]:removeTag(tag)
end

--[[ maid:clean(tag: string|nil)
    Cleans up everything thats being tracked.
    If *tag* is provided, it'll only clean everything tracked w/ that tag.
    
    Additionally, the provided object will be deeply disconnected, with each
    value being nullified & the metatable being cleared. ]]
function maid:clean(tag: string?)
    --> Clean Instances
    for cleanInstance: any, wrappedInstance: SawdustMaidWrapper in pairs(self.tracked) do
        --> Rawset
        local should_clean = (not tag or (tag and wrappedInstance:hasTag(tag)))
        if should_clean then
            if self.object then
                local find_clean_inst = table.find(self.object, cleanInstance)
                if find_clean_inst then
                    rawset(self.object, find_clean_inst, nil)
                end
            end
            wrappedInstance:clean()
        end
    end

    --> Clean Object
    if self.object then
        if not tag then --> Only on full clean
            setmetatable(self.object, {}) 
        end
    end
end

return maid