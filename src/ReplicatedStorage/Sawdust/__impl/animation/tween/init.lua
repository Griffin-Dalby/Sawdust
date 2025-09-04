--[[

    Sawdust Tween Manager

    Griffin Dalby
    2025.08.22

    Intuitive tween manager with fully safe playback, deep customizability, topped
    off with a tasteful, expressive syntax.

--]]

--]] Services
--]] Modules
local sInfoTranslator = require(script.info)
local environment = require(script.environment)

--]] Manager

local tween_m = {}
tween_m.__index = tween_m

type self = {
    environment: environment.TweenEnvironment,
}
export type TweenTrack = typeof(setmetatable({} :: self, tween_m))

--[[ tween_m.newTrack(ui_element: UIBase)
    This will create a new Tween Track. ]]
function tween_m.newTrack(ui_element: UIBase) : TweenTrack
    local self = setmetatable({} :: self, tween_m)

    --]] Setup Environment
    self.environment = environment.new()

    return self
end

return tween_m