--[[

    Networking Router

    Griffin Dalby
    2025.08.06

    This module provides networking w/ a router object, which will allow
    the developer to easily "route" calls depending on the intent.

--]]

--]] Services
--]] Modules
--> Networking logic
local types = require(script.Parent.types)

--> Sawdust
local __impl = script.Parent.Parent

local sawdust = __impl.Parent
local __internal = sawdust.__internal

local __settings = require(__internal.__settings)

--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Router
local router = {}
router.__index = router

--[[ router.new()
    This will return a new router object. ]]
function router.new() : types.NetworkingRouter
    local self = setmetatable({} :: types.self_router, router)



    return self
end

function router:on(intent: string)
    
end

return router