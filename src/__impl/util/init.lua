--[[

    Sawdust Utilities Module

    Griffin E. Dalby
    2025.06.16

    This module provides a lot of small utilities, can be used in
    other scripts, however this will also be used heavily within Sawdust.

--]]

local debounce = require(script.debounce)
local enumMap = require(script.enum_map)
local timer = require(script.timer)
local uuid = require(script.uuid)
local maid = require(script.maid)

--]] Util
local util = {}

util.enumMap = enumMap
export type SawdustEnumMap = enumMap.SawdustEnumMap



util.timer = timer
export type SawdustTimer = timer.SawdustTimer



util.maid = maid
export type SawdustMaid = maid.SawdustMaid



util.debounce = debounce
export type DebounceTracker = debounce.DebounceTracker


return util