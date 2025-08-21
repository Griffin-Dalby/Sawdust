---
sidebar_position: 1
---

# Networking

The **Networking** implementation is a very expressive, custom RPC layer built over Roblox's Remote Events. This system heavily resembles Node's Express module, and you'll see exactly what I mean in a second

## What is a "Channel"?

To understand what a "Channel" is, you need to know how Sawdust handles file structures.

What you'll find in a fresh Sawdust installation, are two folders named **"Events"** and **"Assets"**. Locate & open the `Sawdust.__internal.__settings.lua` module, and find the Networking settings. It'll look something like this:

```lua
__settings.networking = {
    fetchFolder = root.Events,
}
```

Whatever `fetchFolder` is set to, is where Sawdust will search for Channels.

Now finally, what actually is a Channel? Well, it's simply a wrapper for any folder that is parented to the `fetchFolder`, that allows you to further locate events! Making a new channel is very simple, seriously just make a new folder under the `fetchFolder`, name it whatever, and there's your new channel!

```lua
local sawdust = require(path.to.sawdust)
local networking = sawdust.core.networking

--[[ File Structure:
    Sawdust -
      events -
        mechanics -
          abilities: event
          movement: event
        replication -
          abilities: event
        game -
          round: event

      assets - *CDN Folder*
--]]

local mechanics_channel   = networking.getChannel('mechanics') --> This is how you fetch a Channel
local replication_channel = networking.getChannel('replication')
local game_channel        = networking.getChannel('game')

local abilities_event       = mechanics_channel.abilities --> This is how you fetch a Wrapped Event
local abilities_replication = replication_channel.abilities
local round_event           = game_channel.round

```

## RPC Layer

Internally, I've built a form of an RPC layer over Roblox's RemoteEvents. I won't go too in depth on this here, but if you'd like more info, check out the networking documentation.

When the Networking implementation initalizes, it'll go through the `fetchFolder` and automatically bind all found events to my custom networking handler, and it'll also wrap the events; this wrapped event is what you'll access to handle and send data.

As you've seen in the above chunk of code, you can access this wrapped event through: `channel.event`. Simple enough hopefully. You can learn more in [Networking Documentation](../implementation-docs/networking.md)

## Calling / Invoking Events

I've developed the call interface to reflect Axios' syntax as much as possible without losing the Roblox feel. I truly believe it's really intuitive.

`events` provide a `:call()` interface, from here, you can call these settings:
- `:broadcastGlobally()` **[SERVER]** - Sets broadcast target to all
- `:broadcastTo(players: ...|{Player})` **[SERVER]** - Sets broadcast targets to specific players, can be a table or a tuple
- `:setFilterType(filter: 'include'|'exclude')` **[SERVER]** - When the event is fired, include will send the data to the targets, while exclude will send it to everybody but the targets.
- `:data(...)` - Sets the downstream body data to a tuple argument.
- `:intent(intent: string)` - Sets the intent of the call.
- `:timeout(seconds: number)` - Sets the timeout length *(only for invocation)*
- `:fire()` - Compiles all data, fires, and forgets.
- `:invoke()` - Compiles all data, fires, and returns a promise for return data.