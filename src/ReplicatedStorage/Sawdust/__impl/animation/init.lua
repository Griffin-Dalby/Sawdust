--[[

    Sawdust Animation

    Griffin Dalby
    2025.06.24

--]]

--]] Services
--]] Modules
local cfanim = require(script.cfanim)
local scene = require(script.scene)
local timeline = require(script.timeline)

--]] Settings
--]] Module
local animation = {}

--[[ CFANIM ]]--
animation.cfanim = cfanim
export type CFAnimBuilder = cfanim.CFAnimBuilder
export type CFAnimTimeline = cfanim.CFAnimTimeline

--[[ SCENE ]]--
animation.scene = scene

--[[ TIMELINE ]]--
animation.timeline = timeline

return animation