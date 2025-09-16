--[[

    CFrame Animator

    Griffin Dalby
    2025.06.24

    This module makes easy procedual animation easy to pull off with any
    rig, can be played on it's own, or as a part of a scene.

--]]

--]] Services
local runService = game:GetService('RunService')

--]] Modules
local modelPlanner = require(script.modelPlanner)

--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Modules
local cfAnim = {}

local keyframe = {}
local timeline = {}
local builder = {}
local animator = {}
keyframe.__index = keyframe
timeline.__index = timeline
builder.__index = builder
animator.__index = animator

--> Keyframe
type rigTable = {
    [string]: rigTable|CFrame
}

type self_keyframe = {
    _time: number,
    _goals: {[string]: rigTable}
}
export type CFAnimKeyframe = typeof(setmetatable({} :: self_keyframe, keyframe))

function keyframe.newKeyframe(time: number, goalTable: {}): CFAnimKeyframe
    local self = setmetatable({} :: self_keyframe, keyframe)

    self._time = time
    self._goals = goalTable

    return self
end

--> Timeline
type self_timeline = {
    _keyframes: {[number]: CFAnimKeyframe},
    _markers: {[number]: {string}},
    _joints: {[string]: CFrame},
    _rig: {},

    finished: boolean
}
export type CFAnimTimeline = typeof(setmetatable({} :: self_timeline, timeline))

function timeline.newTimeline(rig: {}) : CFAnimTimeline
    local self = setmetatable({} :: self_timeline, timeline)

    self._keyframes = {}
    self._markers = {}
    self._joints = {}
    self._rig = rig

    self.finished = false

    --> Compile joints
    local function walkJoints(path: {}, pathStack: {})
        pathStack = pathStack or {}
        local thisPath = path

        for name: string, val in pairs(thisPath) do
            if val.motor ~= nil then
                local fullPath = if #pathStack > 0 then `{table.concat(pathStack, '.')}.{name}` else name
                self._joints[fullPath] = val
            else
                thisPath = path[name]

                table.insert(pathStack, name)
                walkJoints(thisPath, pathStack)
                table.remove(pathStack)
            end
        end
    end

    walkJoints(rig._structure)

    return self
end

function timeline:apply(elapsedTime: number)
    --> Check if finished
    if elapsedTime >= self._keyframes[table.maxn(self._keyframes)]._time then
        self.finished = true return end
    self.finished = false

    --> Locate frames
   local lastTime, nextTime = -math.huge, math.huge
    for frameTime in pairs(self._keyframes) do
        if frameTime <= elapsedTime and frameTime > lastTime then
            lastTime = frameTime
        elseif frameTime > elapsedTime and frameTime < nextTime then
            nextTime = frameTime
        end
    end

    local lastFrame: CFAnimKeyframe, nextFrame: CFAnimKeyframe = self._keyframes[lastTime], self._keyframes[nextTime]

    --> Move joints
    local function walkGoals(goal: {}, parentPath: string?, out: {[string]: CFrame})
        for name, val in pairs(goal) do
            local path = parentPath and (`{parentPath}.{name}`) or name

            if typeof(val) == "CFrame" then
                out[path] = val
            elseif typeof(val) == "table" then
                walkGoals(val, path, out)
            end
        end
    end

    local flatLast, flatNext = {}, {}
    walkGoals(lastFrame._goals, nil, flatLast)
    if nextFrame then walkGoals(nextFrame._goals, nil, flatNext) end

    for jointPath, _ in pairs(flatLast) do
        local startTime, endTime = -math.huge, math.huge
        local startCF, endCF

        for frameTime, frame in pairs(self._keyframes) do
            local flat = {}
            walkGoals(frame._goals, nil, flat)
            local cf = flat[jointPath]
            if cf then
                if frameTime <= elapsedTime and frameTime > startTime then
                    startTime, startCF = frameTime, cf end
                if frameTime > elapsedTime and frameTime < endTime then
                    endTime, endCF = frameTime, cf end
            end
        end

        if startCF then
            local alpha = 0
            if endCF then
                local duration = endTime - startTime
                alpha = math.clamp((elapsedTime - startTime) / duration, 0, 1)
            else
                alpha = 1
            end

            local jointData = self._joints[jointPath]
            jointData.motor.C1 = jointData.initalC1 * (endCF and startCF:Lerp(endCF, alpha) or startCF)
        end
    end

end

--[[ timeline:keyframe(time: number, goals: {} )
    Creates a new keyframe @ the specified time w/
    the specified goals.]]
function timeline:keyframe(time: number, goals: {}): CFAnimKeyframe
    --> Parse goals
    local goalTable = {}
    local motorTable = {}

    local function scanGoal(goal: {}, output: {}, pathStack: {string}?)
        pathStack = pathStack or {}

        for name: string, val in pairs(goal) do
            if typeof(val) == 'CFrame' then
                local fullPath = if #pathStack > 0 then table.concat(pathStack, ".") .. "." .. name else name
                local parts = string.split(fullPath, ".")

                local target = output
                for i = 1, #parts - 1 do
                    target[parts[i]] = target[parts[i]] or {}
                    target = target[parts[i]]
                end
                target[parts[#parts]] = val

            elseif typeof(val) == "table" then
                table.insert(pathStack, name)
                scanGoal(val, output, pathStack)
                table.remove(pathStack)
            end
        end
    end

    --> Create keyframe
    scanGoal(goals, goalTable)
    local thisKeyframe = keyframe.newKeyframe(time, goalTable)
    self._keyframes[time] = thisKeyframe

    return thisKeyframe
end

--[[ timeline:marker(time: number, name: string)
    Creates a new named marker @ the specified time. ]]
function timeline:marker(time: number, name: string)
    if not self._markers[time] then
        self._markers[time] = {} end
    table.insert(self._markers[time], name)
end

--> Builder
type self_builder = {
    _environment: {},
    _timelines: {[string]: CFAnimTimeline},
}
export type CFAnimBuilder = typeof(setmetatable({} :: self_builder, builder))

function builder.newBuilder(): CFAnimBuilder
    local self = setmetatable({} :: self_builder, builder)

    self._environment = {}
    self._timelines = {}

    return self
end

--[[ builder:rig(rigName: string, rigModel: Model)
    Creates plan data for the rig and saves it into
    the animation environment. ]]
function builder:rig(rigName: string, rigModel: Model) : CFAnimBuilder
	local plannedRig = modelPlanner.plan(rigModel)
    self._environment[rigName] = plannedRig
    return self
end

--[[ builder:timeline(envKey: string, builder: (CFAnimTimeline) -> nil)
    Creates a new timeline interacting with]]
function builder:timeline(envKey: string, builderFn: (CFAnimTimeline) -> nil) : CFAnimBuilder
    assert(self._environment[envKey], `[{script.Name}] Nothing in environment w/ name '{envKey}'`)
    assert(not self._timelines[envKey], `[{script.Name}] There's already a timeline registered for object '{envKey}'`)

    local timeline = timeline.newTimeline(self._environment[envKey])
    builderFn(timeline)

    self._timelines[envKey] = timeline
    return self
end

--[[ builder:build()
    Returns a dynamic and editable animation object w/ playback
    controls and lifetime injections. ]]
function builder:build(): CFAnimator
    return animator.new(self) end

--> Animator
type self_animator = {
    _environment: {},
    _timelines: {[string]: CFAnimTimeline},

    _startTime: number,
    _pauseTime: number,
    _elapsedTime: number,
    _connections: {[string]: RBXScriptConnection},

    playing: boolean,
}
export type CFAnimator = typeof(setmetatable({} :: self_animator, animator))

function animator.new(builder: CFAnimBuilder): CFAnimator
    local self = setmetatable({} :: self_animator, animator)

    --> Adopt builder
    self._environment = builder._environment
    self._timelines = builder._timelines

    --> Initalize animator
    self._startTime = 0
    self._pauseTime = 0
    self._elapsedTime = 0
    self._connections = {}

    self.playing = false

    return self
end

function animator:step(elapsed: number)
    for _, timeline: CFAnimTimeline in pairs(self._timelines) do
        timeline:apply(elapsed)
    end
end

--[[ Playback Controls ]]--
function animator:play()
    if self.playing then
        warn(`[{script.Name}] Attempt to play an already playing CFAnim!`)
        return end

    if self._pauseTime then
        --> Resume from pause
        self._startTime = tick() - self._elapsedTime
        self._pauseTime = nil
    else
        --> First play
        self._startTime = tick()
        self._elapsedTime = 0
    end

    self.playing = true

    self._connections.renderStepped = runService.RenderStepped:Connect(function(deltaTime)
        if not self.playing then return end

        self._elapsedTime = tick() - self._startTime
        self:step(self._elapsedTime)

        --> Check if finished
        local allDone = true
        for _, timeline: CFAnimTimeline in pairs(self._timelines) do
            if not timeline.finished then
                allDone = false; break end
        end

        if allDone then
            self:cancel() --> Finished!
        end
    end)
end

function animator:pause()
    if not self.playing then return end

    self.playing = false
    self._pauseTime = tick()
    self._elapsedTime = self._pauseTime - self._startTime
end

function animator:cancel()
    self.playing = false
    self._pauseTime = 0
    self._startTime = 0

    for _, conn in pairs(self._connections) do conn:Disconnect() end
    table.clear(self._connections)
end

--[[ Technical Controls ]]--
function animator:getTimeline(timelineName: string): CFAnimTimeline
    if not timelineName or not self._timelines[timelineName] then
        warn(`[{script.Name}] Failed to find timeline '{timelineName or '<field empty>'}'!`)
        return end
    
    return self._timelines[timelineName]
end

--> CFAnim Root

--[[ cfAnim.newBuilder(): CFAnimBuilder
    This function will create a new timeline, which you can chain
    actions onto. ]]
cfAnim.newBuilder = builder.newBuilder :: CFAnimBuilder

return cfAnim