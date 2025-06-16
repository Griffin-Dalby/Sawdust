# Changelog

All notable changes to **Sawdust** will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

---

> ## [Unreleased]
> 
> #### Additions
>
>> `CDN`
>> - I need to create a custom content delivery module, Sawdust/Content will be where assets and metadata is placed.
>
> #### Changes
>
>> `Caching`
>> - I need to let the developer find caches inside caches, basically tables can be placed in caches, then tables in those tables.
>
> #### Fixes
>
>> `WARNING`
>> I'm not 100% sure all features in 1.0.0 work. I haven't been able to test because my computer keeps crashing, although all syntax looks right.

---

> ## [1.0.0] - 2025-06-16

> #### Additions
> - Inital release of Sawdust framework
>
>> `Networking`
>> - "**Middleware**" allowing developers to attach events to different points of an event's lifecycle
>> - Very easy to understand interface, splitting events into "channels" that you can easily access and connect.
>> - Event behavior is wrapped smartly, functions and events work the same, but their special behavior is kept in-tact.
>
>> `Signaling`
>> - Provides the developer with "Emitters", that you can add events to for very simple, embedded event behavior.
>> - Smart memory handling and cleanup
>
>> `Caching`
>> - Splits data into "Caches", from there you can simply get and set data.
>
>> `Maid`
>> - Apart of the "Util" implementation, the Maid module lets the devloper create a new Maid instance.
>> - Said maid instance can take track of instances, connections, and callback functions.
>> - The developer can "tag" these tracked objects with names, and take action based off of the tags alone.
>> - You can call `:clean(tag: string|nil)` to cleanup all tracked data, or only tagged data.