--[[
	
	Sawdust Module
	
	Griffin E. Dalby
	6/12/25
	
	"Sawdust" is a collection of modules that I use,
	all combined in one, easy to use, streamlined module.
	
	It's all extremley modular and takes advantage of types
	as much as humanly possible for the easiest possible
	programming experience.
	
--]]

--]] Internals
local __internal = script.__internal

local __settings = require(__internal.__settings)

--]] Implementations
local __impl = script.__impl

local networking = require(__impl.networking)
local signal = require(__impl.signal)
local cache = require(__impl.cache)
local util = require(__impl.util)
local cdn = require(__impl.cdn)

--]] Sawdust
local sawdust = {}

sawdust.networking = function(): typeof(networking)
	return networking end
export type SawdustEvent = networking.SawdustEvent
export type SawdustConnection = networking.SawdustConnection

sawdust.signal = function() : typeof(signal)
	return signal end
export type SawdustEmitter = signal.SawdustEmitter
export type SawdustSignal = signal.SawdustSignal
export type SawdustSignalConnection = signal.SawdustSignalConnection

sawdust.cache = function(): typeof(cache)
	return cache end
export type SawdustCache = cache.SawdustCache

sawdust.util = function() : typeof(util)
	return util end
export type SawdustMaid = util.SawdustMaid

sawdust.cdn = function(): typeof(cdn)
	return cdn end
export type SawdustCDNProvider = cdn.SawdustCDNProvider
export type SawdustCDNPreloader = cdn.SawdustCDNPreloader
export type SawdustCDNReturnTemplate = cdn.SawdustCDNReturnTemplate

return sawdust