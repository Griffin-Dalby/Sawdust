--[[

    Sawdust Utilities Module

    Griffin E. Dalby
    2025.06.16

    This module provides a lot of small utilities, can be used in
    other scripts, however this will also be used heavily within Sawdust.

--]]

local maid = require(script.maid)

--]] Util
local util = {}

util.maid = maid
export type SawdustMaid = maid.SawdustMaid

return util