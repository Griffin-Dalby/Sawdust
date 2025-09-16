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
		debug: boolean,
		version: number,
	},
	
	networking: {
		fetchFolder: Folder,
	},
	
	content: {
		fetchFolder: Folder,
		debug: {
			cdn: boolean,
			preload: boolean
		}
	},
	
	cache: {
		
	},

	builder: {

	},

	maid: {
		debug: boolean,
	},
}
local __settings = {} :: __sawdustSettings

export type SawdustSettings = __sawdustSettings

--> Settings
__settings.global = {
	debug = false,
	version = 4,
}

__settings.networking = {
	--> Basic fetch
	fetchFolder = root.Events,
}

__settings.content = {
	fetchFolder = root.Content,
	debug = {
		cdn = false,
		preload = false
	}
}

__settings.cache = {
	
}

__settings.builder = {
	
}

__settings.maid = {
	debug = true
}

return __settings