--[[

    Sawdust Tween Manager

    Griffin Dalby
    2025.08.22

    Intuitive tween manager with fully safe playback, deep customizability, topped
    off with a tasteful, expressive syntax.

--]]

local tween_m = {}
tween_m.__index = tween_m

type self = {
    environment: {
        info: {},
        objects: {},
    },


}
export type TweenTrack = typeof(setmetatable({} :: self, tween_m))

--[[ tween_m.newTrack(ui_element: UIBase)
    This will create a new Tween Track, which will take in tracks]]
function tween_m.newTrack(ui_element: UIBase) : TweenTrack
    local self = setmetatable({} :: self, tween_m)

    --]] Setup Environment
    self.environment = {}
    self.environment.info = {}
    self.environment.objects = {}

    return self
end



return tween_m