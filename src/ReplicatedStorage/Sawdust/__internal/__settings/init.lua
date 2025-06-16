--[[
	
	Sawdust Settings
	
	Griffin E. Dalby
	6/12/25
	
	This module contains all settings for sawdust,
	and the individual implementations.
	
--]]

local root = script.Parent.Parent

--> Definition
type __sawdustSettings = {
	global: {
		debug: boolean
	},
	
	networking: {
		fetchFolder: Folder,
	},
	
	content: {
		fetchFolder: Folder,
	},
	
	cache: {
		
	},

	maid: {
		debug: boolean,
	}
}
local __settings = {} :: __sawdustSettings

export type SawdustSettings = __sawdustSettings

--> Settings
__settings.global = {
	debug = true
}

__settings.networking = {
	fetchFolder = root.Events
}

__settings.content = {
	fetchFolder = root.Content
}

__settings.cache = {
	
}

__settings.maid = {
	debug = true
}

return __settings