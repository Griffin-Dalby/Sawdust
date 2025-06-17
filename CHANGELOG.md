# Changelog

All notable changes to **Sawdust** will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/).

---

> ## [1.0.1] - 2025-07-16

> #### Additions
>
>> ##### **CDN** `src\ReplicatedStorage\Sawdust\__impl\cdn`
>> - Created a dynamic and quite efficient CDN system, utilizing the caching module internally.
>> - Allows you to get "**Providers**" whose main job is to provide assets utilizing AssetIDs.
>> - Provides a "**Preload**" feature, allowing you to preload assets in batches, or singulars
>> - I want to flex how efficent I made it actually, I love how it turned out so much 🙏
>
> #### Changes
> - `__impl\cache` Allowed finding caches within caches, basically allowing you to have objects much like tables.


---

> ## [1.0.0] - 2025-06-16

> #### Additions
> - Inital release of Sawdust framework
>
>> ##### **Networking** `src\ReplicatedStorage\Sawdust\__impl\networking`
>> - "**Middleware**" allowing developers to attach events to different points of an event's lifecycle
>> - Very easy to understand interface, splitting events into "channels" that you can easily access and connect.
>> - Event behavior is wrapped smartly, functions and events work the same, but their special behavior is kept in-tact.
>
>> ##### **Signaling** `src\ReplicatedStorage\Sawdust\__impl\signal`
>> - Provides the developer with "Emitters", that you can add events to for very simple, embedded event behavior.
>> - Smart memory handling and cleanup
>
>> ##### **Caching** `src\ReplicatedStorage\Sawdust\__impl\cache`
>> - Splits data into "Caches", from there you can simply get and set data.
>
>> ##### **Maid** `src\ReplicatedStorage\Sawdust\__impl\util\maid`
>> - Apart of the "Util" implementation, the Maid module lets the devloper create a new Maid instance.
>> - Said maid instance can take track of instances, connections, and callback functions.
>> - The developer can "tag" these tracked objects with names, and take action based off of the tags alone.
>> - You can call `:clean(tag: string|nil)` to cleanup all tracked data, or only tagged data.