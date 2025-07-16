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

		minCompressionSize: number,
		dictionaryUpdateInterval: number,
		maxDictionarySize: number,
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
	debug = true,
	version = 4,
}

__settings.networking = {
	--> Basic fetch
	fetchFolder = root.Events,

	--> DNCL
	minCompressionSize = 50,
	dictionaryUpdateInterval = 10,
	maxDictionarySize = 1000
}

__settings.content = {
	fetchFolder = root.Content,
	debug = {
		cdn = true,
		preload = true
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