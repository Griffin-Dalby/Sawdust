--[[

    Sawdust Tween Environment

    Griffin Dalby
    2025.09.03

    Intensely flexible environment manager for the Sawdust tween orchestrator.

--]]

--]] Services
--]] Modules
local sInfoTranslator = require(script.Parent.info)
local controller = require(script.controller)

--]] Environment
local environment = {}
environment.__index = environment

type self = {
    info: controller.EnvironmentController,
    targets: controller.EnvironmentController,
}
export type TweenEnvironment = typeof(setmetatable({} :: self, environment))

--[[ environment.new()
    Generates a new, empty environment. ]]
function environment.new() : TweenEnvironment
    local self = setmetatable({} :: self, environment)

    self.info = controller.new()
    self.targets = controller.new()

    return self
end

--[[ SETUP ]]--

--]] SINGLETS 
--#region

--[[ environment:registerInfo(id: string, tween_info: TweenInfo|TweenData)
    This will create & register info into the track environment.
    
    You can either use a vanilla TweenInfo, or map out the values
    you'd use in a TweenInfo into a table. ]]
function environment:registerInfo(id: string, tween_info: TweenInfo|sInfoTranslator.TweenData)
    assert(not self.info:has(id), `there is already info registered to the environment w/ ID "{id}"`)

    local translated_info = sInfoTranslator.new(tween_info)
    self.info:register(id, translated_info)
end

--[[ environment:registerTarget(id: string, target: Instance)
    This will register a target into the track environment. ]]
function environment:registerTarget(id: string, target: Instance)
    assert(not self.targets:has(id), `there is already a target registered to the environment w/ ID "{id}"`)
    self.targets:register(id, target)
end --#endregion

--]] BATCH
--#region

--[[ environment:registerInfos(batch: {id: TweenInfo|TweenData})
    This will create & register info into the track environment
    in batch. ]]
function environment:registerInfos(batch: {[string]: TweenInfo|sInfoTranslator.TweenData})
    for id, tween_info in pairs(batch) do
        self:registerInfo(id, tween_info) end
end

--[[ environment:registerTargets(batch: {id: Instance})
    This will register targets in batch into the track
    environment. ]]
function environment:registerTargets(batch: {[string]: Instance})
    for id, target in pairs(batch) do
        self:registerTarget(id, target) end
end --#endregion

--[[ CONTROLS ]]--
function environment:hasInfo(id: string) : boolean
    return self.info:has(id) end
function environment:getInfo(id: string) : sInfoTranslator.STweenInfo?
    return self.info:get(id) end
function environment:listInfos() : {[string]: sInfoTranslator.STweenInfo}
    return self.info:list() end
function environment:unregisterInfo(id: string)
    self.info:unregister(id) end

function environment:hasTarget(id: string) : boolean
    return self.targets:has(id) end
function environment:getTarget(id: string) : Instance?
    return self.targets:get(id) end
function environment:listTargets() : {[string]: Instance}
    return self.targets:list() end
function environment:unregisterTarget(id: string)
    self.targets:unregister(id) end

return environment