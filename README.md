# docker-vrising

>[!NOTE]
> This image features ✨**gracefully server shutdown**✨, meaning you should not experience rollbacks after an shutdown/restart.
<br>
A Docker container for hosting your own dedicated server using Ubuntu 24.04 and WineHQ 9.
<br>

## Acknowledgements
 - Base image from [CM2Walki/steamcmd](https://github.com/CM2Walki/steamcmd)
 - Code from [palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker)

## Getting Started

Follow this [docker-compose-yml](/deploy/docker/compose/docker-compose.yml) example and check [environment variables](#container-environment-variables) below for more information.

```yaml
services:
  vrising:
    image: zkoesters/docker-vrising:latest
    restart: unless-stopped # Required for the restarts to work
    stop_grace_period: 15s # Might need to increase with longer saves
    ports:
      - 9876:9876/udp
      - 9877:9877/udp
    environment:
      TZ: "America/Los_Angeles"
      PUID: 1001
      PGID: 1001
      VR_NAME: "V Rising Docker Server"
      VR_DESCRIPTION: "V Rising server hosted on Docker"
      VR_RCON_ENABLED: true
      VR_RCON_PASSWORD: "rconPassword"
      VR_RCON_PORT: 25575
      VR_GAME_PORT: 9876
      VR_QUERY_PORT: 9877
      VR_LIST_ON_EOS: true
      VR_LIST_ON_STEAM: true
      VR_SAVE_NAME: "dockerWorld"
    volumes:
    - ./awesome-vrising-server/server:/vrising/server
    - ./awesome-vrising-server/data:/vrising/data
    - ./awesome-vrising-server/announce:/vrising/announce # Only needed if you are using Auto Announce

```

>[!TIP]
> To manually change the `ServerGameSettings.json` and/or `ServerHostSettings.json` you need to set `COMPILE_GAME_SETTINGS` and/or `COMPILE_HOST_SETTINGS` to `false`.
>
> When setting `COMPILE_GAME_SETTINGS` or `COMPILE_HOST_SETTINGS` to `true` you are expected to use environment variables to configure the server without touching `ServerGameSettings.json` and/or `ServerHostSettings.json`

## Container Environment Variables

| Variable                        | Type/Default                                                 | Description                                                                                                                                                                                        |
|:--------------------------------|--------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PUID`                          | `1000`                                                       | UID used by the container to run the server as                                                                                                                                                     |
| `PGID`                          | `1000`                                                       | GID used by the container to run the server as                                                                                                                                                     |
| `TZ`                            | `Europe/Brussels`                                            | Timezone, important if you are running Cron tasks.                                                                                                                                                 |
| `UPDATE_ON_BOOT`                | `true`                                                       | Checks for updates on start and updates it if needed                                                                                                                                               |
| `COMPILE_HOST_SETTINGS`         | `false`                                                      | Disable the generation of `ServerHostSettings.json` using the env vars below. It does not affect the env vars starting with `VR_`, these env vars are used by the gameserver itself                |
| `COMPILE_GAME_SETTINGS`         | `false`                                                      | Disable the generation of `ServerGameSettings.json` using the env vars.                                                                                                                            |
| `AUTO_UPDATE_ENABLED`           | `false`                                                      | Enable/Disables Auto Update.<br>If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be manually restarted.<br>**Requires RCON**     |
| `AUTO_UPDATE_CRON_EXPRESSION`   | `0 * * * *`                                                  | Cron expression to when to run the update check.                                                                                                                                                   |
| `AUTO_UPDATE_WARN_MINUTES`      | `30,15,10,5,3,2,1`                                           | How many minutes until restart and announce intervals.<br>Example: `30,15,10,5,3,2,1` will shutdown the server in `30` minutes and announce the shut down at `30,15,10,5,3,2` and `1` minute mark. |
| `AUTO_UPDATE_WARN_MESSAGE`      | `Server will restart in ~{t} min. Reason: Scheduled Update`  | Message used to announce the restart.<br>`~{t}` will be replaced in the message by the remaining time until shutdown.                                                                              |
| `AUTO_REBOOT_ENABLED`           | `false`                                                      | Enable/Disable Auto Reboot.<br>If docker restart is not set to policy `always` or `unless-stopped` then the server will shutdown and will need to be manually restarted.<br>**Requires RCON**      |
| `AUTO_REBOOT_CRON_EXPRESSION`   | `0 0 * * *`                                                  | Cron expression to when to run the reboot.                                                                                                                                                         |
| `AUTO_REBOOT_WARN_MINUTES`      | `15,10,5,3,2,1`                                              | How many minutes until restart and announce intervals.<br>Example: `30,15,10,5,3,2,1` will shutdown the server in `30` minutes and announce the shut down at `30,15,10,5,3,2` and `1` minute mark. |
| `AUTO_REBOOT_WARN_MESSAGE`      | `Server will restart in ~{t} min. Reason: Scheduled Restart` | Message used to announce the restart.<br>`~{t}` will be replaced in the message by the remaining time until shutdown                                                                               |
| `AUTO_ANNOUNCE_ENABLED`         | `false`                                                      | Enable/Disable Auto Announce of messages.                                                                                                                                                          |
| `AUTO_ANNOUNCE_CRON_EXPRESSION` | `*/10 * * * *`                                               | Cron expression to when to announce messages.<br>Default is every 10 minutes.<br>**Requires RCON**                                                                                                 |



## Host Settings Environment Variables (Game Server)

>[!IMPORTANT]
> `VR_` prefixed environment variables are used by the **game** server itself, not added by the container.
>
> Because these are read by the game server itself, setting `COMPILE_HOST_SETTINGS` to `false` won't affect how these environment variables work. [Official Doc](https://github.com/StunlockStudios/vrising-dedicated-server-instructions/blob/master/1.0.x/INSTRUCTIONS.md#server-host-settings).
>
> These environment variables will **override** their respective values in `ServerHostSettings.json`.

| Variable                        | Type/Default                                                                                                                    | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|:--------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `VR_NAME`                       | `text`                                                                                                                          | Name of the server. The name that shows up in server list.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `VR_DESCRIPTION`                | `text`                                                                                                                          | Short server description. Shows up in details panel of server list when entry is selected. Also printed in chat when connecting to server.                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `VR_GAME_PORT`                  | `9876`                                                                                                                          | UDP port for game traffic.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `VR_QUERY_PORT`                 | `9877`                                                                                                                          | UDP port for Steam server list features.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `VR_ADDRESS`                    | `text`                                                                                                                          | Bind to a specific IP address.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `VR_HIDEIPADDRESS`              | `false`                                                                                                                         | When listing server on EOS server list, the IP address will not be shown/advertised. Players will connect via relay servers.                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `VR_MAX_USERS`                  | `40`                                                                                                                            | Max number of concurrent players on server. The maximum number technically supported is `128`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `VR_MAX_ADMINS`                 | `4`                                                                                                                             | Max number of admins to allow connect even when server is full.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `VR_FPS`                        | `30`                                                                                                                            | Target FPS for server.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| `VR_LOWER_FPS_WHEN_EMPTY`       | `false`                                                                                                                         | Run the server at a lower framerate target when no players are logged in.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `VR_LOWER_FPS_WHEN_EMPTY_VALUE` | `1`                                                                                                                             | Set the framerate target for when `LowerFPSWhenEmpty` is active.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `VR_PASSWORD`                   | `text`                                                                                                                          | Set a password or leave empty.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `VR_SECURE`                     | `true`                                                                                                                          | Enable VAC protection on server. VAC banned clients will not be able to connect.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `VR_LIST_ON_EOS`                | `false`                                                                                                                         | Register on EOS list server or not. The client looks for servers here by default, due to additional features available.                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `VR_LIST_ON_STEAM`              | `false`                                                                                                                         | Register on Steam list server or not.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `VR_PRESET`                     | `text`                                                                                                                          | Load a ServerGameSettings preset.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `VR_DIFFICULTY_PRESET`          | `text`                                                                                                                          | Load a GameDifficulty preset.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `VR_SAVE_NAME`                  | `world1`                                                                                                                        | Name of save file/directory. Must be a valid directory name.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `VR_SAVE_COUNT`                 | `20`                                                                                                                            | Number of autosaves to keep.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| `VR_SAVE_INTERVAL`              | `120`                                                                                                                           | Interval in seconds between each auto save.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `VR_AUTOSAVESMARTKEEP`          | `10:1:1` `30:0:1`<br>`60:0:1` `120:0:1`<br>`180:0:1` `240:0:1`<br>`360:0:1` `720:0:1` <br>`1440:0:1` `2880:0:1`<br>`43200:99:0` | .                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `VR_LAN_MODE`                   | `false`                                                                                                                         | Enable LAN mode.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `VR_RESET_DAYS_INTERVAL`        | `0`                                                                                                                             | Days between scheduled resets/wipes. When the server starts, and is about to load a save file, it checks if it is time to reset and start a new save file. The previous save file is backed up. Defaults to `0`, which means the feature is disabled.                                                                                                                                                                                                                                                                                                                                  |
| `VR_DAY_OF_RESET`               | `enum`                                                                                                                          | If you want the server to reset on Saturdays, every two weeks, but it is not Saturday when you initially set up you server then you can set `ResetDaysInterval` to `14` and then set this to `Saturday`. It will check that at least `ResetDaysInterval` days has passed and that it is the day of `DayOfReset`. If you do not want to restrict reset to a specific day, but just rely on the value of `ResetDaysInterval`, then set this to `Any`, which is also the default.<br>Possible values: `Any`, `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday` |
| `VR_RCON_ENABLED`               | `false`                                                                                                                         | Enable or disable Rcon functionality.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `VR_RCON_PORT`                  | `25575`                                                                                                                         | Rcon TCP port.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `VR_RCON_PASSWORD`              | `text`                                                                                                                          | Password to access RCON.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| `VR_RCON_BIND_ADDRESS`          | `text`                                                                                                                          | Binds RCON socket to specified address. Will override the "global" Address setting, if you want to bind to a separate internal interface for instance.                                                                                                                                                                                                                                                                                                                                                                                                                                 |

# Host Settings Environment Variables 

>[!IMPORTANT]
> The environment variables below are added by the container, when using any of these they will **overwrite** what's in the `ServerHostSettings.json` file.
>
> When using these environment variables any configuration manually made to `ServerHostSettings.json` will be **overwritten**, meaning you should only use environment variables to configure `ServerHostSettings.json`.
>
> If you want to **manually** change the `ServerHostSettings.json` file set `COMPILE_HOST_SETTINGS` to `false`, this will disable all environment variables below.

| Variable                                    | Type/Default | Description |
|:--------------------------------------------|:-------------|:------------|
| `FALLBACK_PORT`                             | `9878`       | Unknown     |
| `MIN_FREE_SLOTS_FOR_NEW_USERS`              | `0`          | Unknown     |
| `AI_UPDATES_PER_FRAME`                      | `200`        | Unknown     |
| `SERVER_BRANCH`                             | `text`       | Unknown     |
| `COMPRESS_SAVE_FILES`                       | `true`       | Unknown     |
| `RUN_PERSISTENCE_TESTS_ON_SAVE`             | `false`      | Unknown     |
| `DUMP_PERSISTENCE_SUMMARY_ON_SAVE`          | `false`      | Unknown     |
| `STORE_PERSISTENCE_DEBUG_DATA`              | `false`      | Unknown     |
| `GIVE_STARTER_ITEMS`                        | `false`      | Unknown     |
| `LOG_ALL_NETWORK_EVENTS`                    | `false`      | Unknown     |
| `LOG_ADMIN_EVENTS`                          | `true`       | Unknown     |
| `LOG_DEBUG_EVENTS`                          | `true`       | Unknown     |
| `ADMIN_ONLY_DEBUG_EVENTS`                   | `true`       | Unknown     |
| `EVERYONE_IS_ADMIN`                         | `false`      | Unknown     |
| `DISABLE_DEBUG_EVENTS`                      | `false`      | Unknown     |
| `ENABLE_DANGEROUS_DEBUG_EVENTS`             | `false`      | Unknown     |
| `TRACK_ARCHETYPE_CREATIONS_ON_STARTUP`      | `false`      | Unknown     |
| `SERVER_START_TIME_OFFSET`                  | `0.0`        | Unknown     |
| `PERSISTENCE_VERSION_OVERRIDE`              | `-1`         | Unknown     |
| `USE_TELEPORT_PLAYERS_OUT_OF_COLLISION_FIX` | `true`       | Unknown     |
| `REMOTE_BANS_URL`                           | `text`       | Unknown     |
| `REMOTE_ADMINS_URL`                         | `text`       | Unknown     |
| `AFK_KICK_TYPE`                             | `0`          | Unknown     |
| `AFK_KICK_DURATION`                         | `1 `         | Unknown     |
| `AFK_KICK_WARNING_DURATION`                 | `14`         | Unknown     |
| `AFK_KICK_PLAYER_RATIO`                     | `0.5`        | Unknown     |
| `ENABLE_BACKTRACE_ANR`                      | `false`      | Unknown     |
| `ANALYTICS_ENABLED`                         | `true`       | Unknown     |
| `ANALYTICS_ENVIRONMENT`                     | `"prod"`     | Unknown     |
| `ANALYTICS_DEBUG`                           | `false`      | Unknown     |
| `USE_DOUBLE_TRANSPORT_LAYER`                | `true`       | Unknown     |
| `PRIVATE_GAME`                              | `false`      | Unknown     |
| `API_ENABLED`                               | `false`      | Unknown     |
| `API_ADDRESS`                               | `"*"`        | Unknown     |
| `API_PORT`                                  | `9090`       | Unknown     |
| `API_BASE_PATH`                             | `"/"`        | Unknown     |
| `API_ACCESS_LIST`                           | `text`       | Unknown     |
| `API_PROMETHEUS_DELAY`                      | `30`         | Unknown     |
| `RCON_TIMEOUT_SECONDS`                      | `300`        | Unknown     |
| `RCON_MAX_PASSWORD_TRIES`                   | `99`         | Unknown     |
| `RCON_BAN_MINUTES`                          | `0`          | Unknown     |
| `RCON_SEND_AUTH_IMMEDIATELY`                | `true`       | Unknown     |
| `RCON_MAX_CONNECTIONS_PER_IP`               | `20`         | Unknown     |
| `RCON_MAX_CONNECTIONS`                      | `20`         | Unknown     |
| `RCON_EXPERIMENTAL_COMMANDS_ENABLED`        | `true`       | Unknown     |

# Game Settings Environment Variables

>[!IMPORTANT]
> The environment variables below are added by the container, when using any of these they will **overwrite** what's in the `ServerGameSettings.json` file.
>
> When using these environment variables any configuration manually made to `ServerGameSettings.json` will be **overwritten**, meaning you should only use environment variables to configure `ServerGameSettings.json`.
>
> If you want to **manually** change the `ServerGameSettings.json` file set `COMPILE_GAME_SETTINGS` to `false`, this will disable all environment variables below.


>[!NOTE]
> Not everything in `ServerGameSettings.json` can be configured using environment variables.
>
> If you need anything that's not covered feel free to open an Issue or PR.


| Variable                                                        | Type / Default            | Description                                           |
|:----------------------------------------------------------------|:--------------------------|:------------------------------------------------------|
| `GS_GAME_DIFFICULTY`                                            | `Normal`                  | Sets overall boss difficulty.                         |
| `GS_GAME_MODE_TYPE`                                             | `PvP`                     | Selects the player-interaction ruleset.               |
| `GS_CASTLE_DAMAGE_MODE`                                         | `Never`                   | When castles can take damage (PvP only).              |
| `GS_SIEGE_WEAPON_HEALTH`                                        | `Normal`                  | Sets siege golem HP.                                  |
| `GS_PLAYER_DAMAGE_MODE`                                         | `Always`                  | When players can hurt other players (PvP only).       |
| `GS_CASTLE_HEART_DAMAGE_MODE`                                   | `CanBeDestroyedByPlayers` | How Castle Hearts can be destroyed/seized (PvP only). |
| `GS_PVP_PROTECTION_MODE`                                        | `Medium`                  | Spawn/respawn PvP protection duration.                |
| `GS_DEATH_CONTAINER_PERMISSION`                                 | `Anyone`                  | Who may loot a dead player’s container.               |
| `GS_RELIC_SPAWN_TYPE`                                           | `Unique`                  | Max concurrent Soul Shards in world.                  |
| `GS_SOUL_SHARD___DURABILITY_LOSS_RATE`                          | `1.0`                     | Durability-loss multiplier for held shards.           |
| `GS_CAN_LOOT_ENEMY_CONTAINERS`                                  | `true`                    | Allow looting containers in enemy castles.            |
| `GS_BLOOD_BOUND_EQUIPMENT`                                      | `true`                    | Keep equipped gear on death.                          |
| `GS_TELEPORT_BOUND_ITEMS`                                       | `true`                    | Bound items block waygate & bat travel.               |
| `GS_BAT_BOUND_ITEMS`                                            | `false`                   | Bound items block bat travel only.                    |
| `GS_BAT_BOUND_SHARDS`                                           | `false`                   | Carry shards in bat form.                             |
| `GS_ALLOW_GLOBAL_CHAT`                                          | `true`                    | Enable global chat channel.                           |
| `GS_ALL_WAYPOINTS_UNLOCKED`                                     | `false`                   | Unlock all waygates by default.                       |
| `GS_FREE_CASTLE_RAID`                                           | `false`                   | Raids skip material cost.                             |
| `GS_FREE_CASTLE_CLAIM`                                          | `false`                   | Claiming empty plots is free.                         |
| `GS_FREE_CASTLE_DESTROY`                                        | `false`                   | Castle-heart destruction is free.                     |
| `GS_INACTIVITY_KILL_ENABLED`                                    | `true`                    | Toggles inactivity-kill system.                       |
| `GS_INACTIVITY_KILL_TIME_MIN`                                   | `3600`                    | Minimum AFK seconds before kill.                      |
| `GS_INACTIVITY_KILL_TIME_MAX`                                   | `604800`                  | Maximum AFK seconds before kill.                      |
| `GS_INACTIVITY_KILL_SAFE_TIME_ADDITION`                         | `172800`                  | Bonus safe time when logged out in own castle.        |
| `GS_INACTIVITY_KILL_TIMER_MAX_ITEM_LEVEL`                       | `84`                      | Item level for max AFK time.                          |
| `GS_STARTING_PROGRESSION_LEVEL`                                 | `0`                       | Initial progression level.                            |
| `GS_DISABLE_DISCONNECTED_DEAD_ENABLED`                          | `true`                    | Leave offline bodies vulnerable.                      |
| `GS_DISABLE_DISCONNECTED_DEAD_TIMER`                            | `60`                      | Delay before offline body becomes safe (if enabled).  |
| `GS_DISCONNECTED_SUN_IMMUNITY_TIME`                             | `300.0`                   | Sun immunity after disconnect (seconds).              |
| `GS_INVENTORY_STACKS_MODIFIER`                                  | `1.0`                     | Stack-size multiplier.                                |
| `GS_DROP_TABLE_MODIFIER___GENERAL`                              | `1.0`                     | General loot-drop multiplier.                         |
| `GS_DROP_TABLE_MODIFIER___STYGIAN_SHARDS`                       | `1.0`                     | Stygian Shard drop multiplier.                        |
| `GS_DROP_TABLE_MODIFIER___MISSIONS`                             | `1.0`                     | Servant-mission loot multiplier.                      |
| `GS_MATERIAL_YIELD_MODIFIER___GLOBAL`                           | `1.0`                     | Resource yield per swing multiplier.                  |
| `GS_BLOOD_ESSENCE_YIELD_MODIFIER`                               | `1.0`                     | Blood Essence drop multiplier.                        |
| `GS_JOURNAL_V___BLOOD_SOURCE_UNIT_MAX_DISTANCE`                 | `25.0`                    | Unused.                                               |
| `GS_PVP_VAMPIRE_RESPAWN_MODIFIER`                               | `1.0`                     | PvP respawn-time multiplier.                          |
| `GS_CASTLE_MINIMUM_DISTANCE_IN_FLOORS`                          | `2`                       | Deprecated.                                           |
| `GS_CLAN_SIZE`                                                  | `4`                       | Maximum clan members.                                 |
| `GS_BLOOD_DRAIN_MODIFIER`                                       | `1.0`                     | Passive blood drain multiplier.                       |
| `GS_DURABILITY_DRAIN_MODIFIER`                                  | `1.0`                     | Gear durability drain multiplier.                     |
| `GS_GARLIC_AREA_STRENGTH_MODIFIER`                              | `1.0`                     | Garlic damage multiplier.                             |
| `GS_HOLY_AREA_STRENGTH_MODIFIER`                                | `1.0`                     | Holy area damage multiplier.                          |
| `GS_SILVER_STRENGTH_MODIFIER`                                   | `1.0`                     | Silver carry damage multiplier.                       |
| `GS_SUN_DAMAGE_MODIFIER`                                        | `1.0`                     | Sunlight damage multiplier.                           |
| `GS_CASTLE_DECAY_RATE_MODIFIER`                                 | `1.0`                     | Castle decay speed multiplier.                        |
| `GS_CASTLE_BLOOD_ESSENCE_DRAIN_MODIFIER`                        | `1.0`                     | Castle Heart essence drain multiplier.                |
| `GS_CASTLE_SIEGE_TIMER`                                         | `420.0`                   | Breached-state duration (seconds).                    |
| `GS_CASTLE_UNDER_ATTACK_TIMER`                                  | `60.0`                    | “Under Attack” flag duration.                         |
| `GS_CASTLE_RAID_TIMER`                                          | `600.0`                   | Defense-disabled duration after raid.                 |
| `GS_CASTLE_RAID_PROTECTION_TIME`                                | `1800.0`                  | Post-raid protection window.                          |
| `GS_CASTLE_EXPOSED_FREE_CLAIM_TIMER`                            | `300.0`                   | Free-claim window for abandoned plots.                |
| `GS_CASTLE_RELOCATION_COOLDOWN`                                 | `10800.0`                 | Castle relocation cooldown.                           |
| `GS_CASTLE_RELOCATION_ENABLED`                                  | `true`                    | Allow castle relocation feature.                      |
| `GS_ANNOUNCE_SIEGE_WEAPON_SPAWN`                                | `true`                    | Broadcast siege golem creation.                       |
| `GS_SHOW_SIEGE_WEAPON_MAP_ICON`                                 | `false`                   | Show siege golem on map.                              |
| `GS_BUILD_COST_MODIFIER`                                        | `1.0`                     | Building cost multiplier.                             |
| `GS_RECIPE_COST_MODIFIER`                                       | `1.0`                     | Crafting cost multiplier.                             |
| `GS_CRAFT_RATE_MODIFIER`                                        | `1.0`                     | Crafting speed multiplier.                            |
| `GS_RESEARCH_COST_MODIFIER`                                     | `1.0`                     | Research cost multiplier.                             |
| `GS_REFINEMENT_COST_MODIFIER`                                   | `1.0`                     | Refinement input-cost multiplier.                     |
| `GS_REFINEMENT_RATE_MODIFIER`                                   | `1.0`                     | Refinement speed multiplier.                          |
| `GS_RESEARCH_TIME_MODIFIER`                                     | `1.0`                     | Unused.                                               |
| `GS_DISMANTLE_RESOURCE_MODIFIER`                                | `1.0`                     | Refund percentage when dismantling.                   |
| `GS_SERVANT_CONVERT_RATE_MODIFIER`                              | `1.0`                     | Servant conversion speed multiplier.                  |
| `GS_REPAIR_COST_MODIFIER`                                       | `1.0`                     | Equipment repair cost multiplier.                     |
| `GS_DEATH___DURABILITY_FACTOR_LOSS`                             | `0.125`                   | Durability lost on death.                             |
| `GS_DEATH___DURABILITY_LOSS_FACTOR_AS_RESOURCES`                | `1.0`                     | Fraction dropped as materials.                        |
| `GS_STARTER_EQUIPMENT_ID`                                       | `0`                       | Starter gear preset.                                  |
| `GS_STARTER_RESOURCES_ID`                                       | `0`                       | Starter resource bundle.                              |
| `GS_GAME_TIME_MODIFIERS__DAY_DURATION_IN_SECONDS`               | `1080.0`                  | Full day-night cycle length.                          |
| `GS_GAME_TIME_MODIFIERS__DAY_START_HOUR`                        | `9`                       | Day starts at hour.                                   |
| `GS_GAME_TIME_MODIFIERS__DAY_START_MINUTE`                      | `0`                       | Day starts at minute.                                 |
| `GS_GAME_TIME_MODIFIERS__DAY_END_HOUR`                          | `17`                      | Night starts at hour.                                 |
| `GS_GAME_TIME_MODIFIERS__DAY_END_MINUTE`                        | `0`                       | Night starts at minute.                               |
| `GS_GAME_TIME_MODIFIERS__BLOOD_MOON_FREQUENCY___MIN`            | `10`                      | Minimum days between Blood Moons.                     |
| `GS_GAME_TIME_MODIFIERS__BLOOD_MOON_FREQUENCY___MAX`            | `18`                      | Maximum days between Blood Moons.                     |
| `GS_GAME_TIME_MODIFIERS__BLOOD_MOON_BUFF`                       | `0.2`                     | Blood Moon stat-buff multiplier.                      |
| `GS_VAMPIRE_STAT_MODIFIERS__MAX_HEALTH_MODIFIER`                | `1.0`                     | Base max-health multiplier.                           |
| `GS_VAMPIRE_STAT_MODIFIERS__PHYSICAL_POWER_MODIFIER`            | `1.0`                     | Base physical-power multiplier.                       |
| `GS_VAMPIRE_STAT_MODIFIERS__SPELL_POWER_MODIFIER`               | `1.0`                     | Base spell-power multiplier.                          |
| `GS_VAMPIRE_STAT_MODIFIERS__RESOURCE_POWER_MODIFIER`            | `1.0`                     | Resource-damage multiplier.                           |
| `GS_VAMPIRE_STAT_MODIFIERS__SIEGE_POWER_MODIFIER`               | `1.0`                     | Unused.                                               |
| `GS_VAMPIRE_STAT_MODIFIERS__DAMAGE_RECEIVED_MODIFIER`           | `1.0`                     | Incoming damage multiplier.                           |
| `GS_VAMPIRE_STAT_MODIFIERS__REVIVE_CANCEL_DELAY`                | `5.0`                     | Delay before revive cancel permitted.                 |
| `GS_UNIT_STAT_MODIFIERS___GLOBAL__MAX_HEALTH_MODIFIER`          | `1.0`                     | Global unit health multiplier.                        |
| `GS_UNIT_STAT_MODIFIERS___GLOBAL__POWER_MODIFIER`               | `1.0`                     | Global unit power multiplier.                         |
| `GS_UNIT_STAT_MODIFIERS___GLOBAL__LEVEL_INCREASE`               | `0`                       | Flat unit-level increase.                             |
| `GS_UNIT_STAT_MODIFIERS___V_BLOOD__MAX_HEALTH_MODIFIER`         | `1.0`                     | V Blood health multiplier.                            |
| `GS_UNIT_STAT_MODIFIERS___V_BLOOD__POWER_MODIFIER`              | `1.0`                     | V Blood power multiplier.                             |
| `GS_UNIT_STAT_MODIFIERS___V_BLOOD__LEVEL_INCREASE`              | `0`                       | V Blood level increase.                               |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__MAX_HEALTH_MODIFIER`     | `1.0`                     | Gear max-health bonus multiplier.                     |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__RESOURCE_YIELD_MODIFIER` | `1.0`                     | Gear resource-yield bonus multiplier.                 |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__PHYSICAL_POWER_MODIFIER` | `1.0`                     | Gear physical-power bonus multiplier.                 |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__SPELL_POWER_MODIFIER`    | `1.0`                     | Gear spell-power bonus multiplier.                    |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__SIEGE_POWER_MODIFIER`    | `1.0`                     | Gear siege-power bonus multiplier.                    |
| `GS_EQUIPMENT_STAT_MODIFIERS___GLOBAL__MOVEMENT_SPEED_MODIFIER` | `1.0`                     | Unused.                                               |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__TICK_PERIOD`                | `5.0`                     | Castle check interval (seconds).                      |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__SAFETY_BOX_LIMIT`           | `1`                       | Lockbox limit per castle.                             |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__EYE_STRUCTURES_LIMIT`       | `1`                       | Eye of Twilight limit.                                |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__TOMB_LIMIT`                 | `12`                      | Tomb limit per castle.                                |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__VERMIN_NEST_LIMIT`          | `4`                       | Vermin Nest limit.                                    |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__PRISON_CELL_LIMIT`          | `24`                      | Prison Cell limit.                                    |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__CASTLE_HEART_LIMIT_TYPE`    | `User`                    | Castle limit applies per user or clan.                |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__CASTLE_LIMIT`               | `2`                       | Max castles per user/clan.                            |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__NETHER_GATE_LIMIT`          | `1`                       | Nether Gate limit.                                    |
| `GS_CASTLE_STAT_MODIFIERS___GLOBAL__THRONE_OF_DARKNESS_LIMIT`   | `1`                       | Throne of Darkness limit.                             |

## RCON Commands

>[!WARNING]
> RCON will only work if it's properly configured, either by setting it's environment variables (`VR_RCON_ENABLED`, `VR_RCON_PORT` and `VR_RCON_PASSWORD`) or by manually configuring it in the `ServerHostSettings.json` file.

To use RCON you can use docker exec:
```bash
docker exec -it container-name rcon-cli "<command> <value>"
```

If you need external RCON access, remember to expose it's port in the container.

| Command           | Parameters                            | Description                                                                                                                                                                                                  |
|-------------------|:--------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `help`            | [command]                             | List all commands, or additional information about a specific command.                                                                                                                                       |
| `announce`        | &lt;message&gt;                       | Sends a message to all players connected to the server.                                                                                                                                                      |
| `announcerestart` | &lt;number&gt;                        | Sends a pre-configured message that announces server restart in x minutes to all players connected to the server. Less flexible than announce but has the benefit of being localized to each users language. |
| `shutdown`        | &lt;message times&gt; &lt;message&gt; | Schedule shutdown of the server.                                                                                                                                                                             |
| `cancelshutdown`  | [message]                             | Cancel an active shutdown, with optional message.                                                                                                                                                            |
| `name`            | &lt;name&gt;                          | Set/change the server name during runtime.                                                                                                                                                                   |
| `description`     | &lt;description&gt;                   | Set/change the server description during runtime.                                                                                                                                                            |
| `password`        | [password] \| --clear                 | Set/change/clear the server password during runtime.                                                                                                                                                         |
| `version`         | -                                     | Show server version.                                                                                                                                                                                         |
| `time`            | -                                     | Show server time.                                                                                                                                                                                            |

## Auto Announce

>[!IMPORTANT]
>This requires RCON to be enabled !

Auto Announce works by reading text files with the extension `.announce`, each file is one message and the Auto Announce will rotate through each file in a loop.
<br>The folder containing the `.announce` files must be mounted inside the container to the path `/vrising/announce`.
<br>The time between each message can be configured using cron expression with the environment variable `AUTO_ANNOUNCE_CRON_EXPRESSION`.

It is recommended to follow this pattern to name the `.announce` files:
<br>`00-something.announce` `01-something.announce`
<br>The first 2 numbers will dictate the order of the message, meaning `00` will be the first message to be displayed and after the amount of time set with `AUTO_ANNOUNCE_CRON_EXPRESSION` the message `01` will be displayed.
<br>You can replace `something` in the file name with anything that helps you identify the message inside it.

>[!IMPORTANT]
>Announces are limited to 510 characters, this is a limit imposed by the game.

After mounting the `announce` folder with the messages, you can test each message by running the following command with the message number as the parameter (like `00` or `01`) while the server is running:
```bash
docker exec -it container-name testannounce <message number>
```

Messages can be modified while the server is running, but the cron expression (`AUTO_ANNOUNCE_CRON_EXPRESSION`) requires a restart to apply.
<br>More info about message formatting for the announcements (like colors!) [here](https://github.com/Diyagi/vrising-server-docker/wiki/Formatting-announce-messages).
