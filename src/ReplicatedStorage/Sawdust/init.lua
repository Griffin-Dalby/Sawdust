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
local __service_manager = require(__internal.__service_manager)

--]] Implementations
local __impl = script.__impl

local networking = require(__impl.networking)
local builder = require(__impl.builder)
local signal = require(__impl.signal)
local cache = require(__impl.cache)
local util = require(__impl.util)
local cdn = require(__impl.cdn)

--]] Sawdust
local sawdust = {}

sawdust.networking = networking
export type SawdustEvent = networking.SawdustEvent
export type SawdustNetworkingMiddleware = networking.SawdustNetworkingMiddleware
export type SawdustNetworkingMiddlewarePipeline = networking.SawdustNetworkingMiddlewarePipeline
export type SawdustConnection = networking.SawdustConnection



sawdust.services = __service_manager.new() --> Create services
sawdust.builder = builder --> Expose service builder
export type SawdustSVCManager = __service_manager.SawdustSVCManager --> Expose SVCManager type
export type SawdustSVCInjection = builder.SawdustSVCInjection --> Expose SVCInjection type
export type SawdustService = builder.SawdustService --> Expose service type



sawdust.signal = signal
export type SawdustEmitter = signal.SawdustEmitter
export type SawdustSignal = signal.SawdustSignal
export type SawdustSignalConnection = signal.SawdustSignalConnection



sawdust.cache = cache
export type SawdustCache = cache.SawdustCache



sawdust.util = util
export type SawdustMaid = util.SawdustMaid



sawdust.cdn = cdn
export type SawdustCDNProvider = cdn.SawdustCDNProvider
export type SawdustCDNPreloader = cdn.SawdustCDNPreloader
export type SawdustCDNReturnTemplate = cdn.SawdustCDNReturnTemplate

return sawdust