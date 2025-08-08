--[[

    Sawdust Plugin Manager

    Griffin Dalby
    2025.08.06

    This internal class will provide logic for registering and loading
    plugins for sawdust.

--]]

--]] Services
--]] Modules
--]] Settings
--]] Constants
--]] Variables
--]] Functions
--]] Module

local pluginManager = {}
pluginManager.__index = pluginManager

type self = {}
export type PluginManager = typeof(setmetatable({} :: self, pluginManager))

--[[ pluginManager.new() : PluginManager
    This function will create a new "Plugin Manager", which is internally
    used to register and start plugins. ]]
function pluginManager.new() : PluginManager
    
end

return pluginManager