--[[

    Sawdust CDN Tests

    Griffin Dalby
    6/22/25

    Unit tests for the "CDN" implementation.

--]]

--]] Services
local replicatedStorage = game:GetService('ReplicatedStorage')

--]] Modules
local sawdust = require(replicatedStorage.Sawdust)
local __settings = require(replicatedStorage.Sawdust.__internal.__settings)

local CDN = sawdust.core.CDN

--]] Settings
--]] Tests
return function()
    
end