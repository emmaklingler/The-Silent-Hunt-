# Copilot Instructions — The Silent Hunt (Roblox)

## Overview
- Scope: Roblox server-side Lua game using Rojo (default.project.json) and the place file TSH.rbxl.
- Core modules in ServerScriptService: player profile loading via ProfileService, per-player runtime state as `Rabbit`, basic `GameManager` state.
- Primary data flows: ProfileService → `Manager.Profiles[player]` → `PlayerManager` creates/returns a `Rabbit` for per-session logic.

## Architecture & Data Flow
- Profiles: `src/ServerScriptService/ProfileService/ProfileScript.server.lua` loads profiles on join using the bundled `ProfileService.lua` and `ProfileTemplate.lua`, stores them in `ProfileService/Manager.lua` under `Manager.Profiles[player]`, and releases on leave.
- Player state: `src/ServerScriptService/Player/PlayerManager.lua` maps `Player` → `Rabbit` (see `RabbitClass.lua`). Use `:CreateRabbit(player, profile)`, `:GetRabbit(player)`, `:RemoveRabbit(player)`.
- Game flow: `src/ServerScriptService/Game/InitGame.server.lua` exposes `GameManager` with `State` = `Lobby | InGame | End` and `StartGame(player)`.
- Actions: `src/ServerScriptService/PlayerAction/` holds server actions (e.g., `EatCarrot.server.lua`) that should fetch the player’s `Rabbit` and mutate its stats and/or profile data.

## Workflows (Run/Sync)
- Studio run: Open `TSH.rbxl` in Roblox Studio and press Play (server scripts live under ServerScriptService).
- Rojo sync: `default.project.json` maps services. On Windows, from repo root:
  ```powershell
  rojo serve
  ```
  Then connect the Rojo plugin in Studio to port `34873` (or use the Serve UI). Create missing mapped folders (`src/ReplicatedStorage`, `src/StarterPlayer/StarterPlayerScripts`) as needed.

## Conventions & Patterns
- Module-as-class: tables with `.__index` and `.new(...)` constructors (e.g., `RabbitClass.lua`).
- Per-player state lives in memory: use `PlayerManager` (runtime) and `Manager.Profiles` (persistent profile) — do not write Roblox Instances or userdata to `profile.Data`.
- Profile keys: `"Player_" .. player.UserId`, store schema in `ProfileTemplate.lua` (currently `{ LogInTimes = 0 }`).
- Spawning: `Rabbit:Spawn()` pivots the character to `workspace.SpawnLocation` and resets stats.
- Remotes: `ProfileService/Manager.lua` references `ReplicatedStorage.Remote` — ensure a matching object exists under `src/ReplicatedStorage` and reference by name (e.g., `Remote:FireClient(...)`).

## How To Extend Safely
- Get per-player objects:
  ```lua
  local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
  local rabbit = PlayerManager:GetRabbit(player)
  if rabbit then rabbit:TakeHunger(10) end
  ```
- Update profile-backed values:
  ```lua
  local Manager = require(game.ServerScriptService.ProfileService.Manager)
  Manager.AddMoney(player, 10)
  ```
- Hook into join flow after profiles load (example pattern):
  ```lua
  local Players = game:GetService("Players")
  local PlayerManager = require(game.ServerScriptService.Player.PlayerManager)
  local Manager = require(game.ServerScriptService.ProfileService.Manager)
  Players.PlayerAdded:Connect(function(player)
      local profile = Manager.Profiles[player]
      if profile then
          local rabbit = PlayerManager:CreateRabbit(player, profile)
          rabbit:Spawn()
      end
  end)
  ```

## Pitfalls & Gotchas
- Always release profiles on leave (handled in `ProfileScript.server.lua`). Do not store Instances/userdata/functions in `Profile.Data` (see warnings in `ProfileService.lua`).
- Ensure `workspace.SpawnLocation` exists or adjust `Rabbit:Spawn()`.
- `PlayerAction/EatCarrot.server.lua` is incomplete — when implementing, fetch `Rabbit` via `PlayerManager` and adjust hunger/stress, then notify clients via `ReplicatedStorage.Remote` if needed.
- Keep server/client boundaries: this repo currently only includes server scripts. Place client code under `src/StarterPlayer/StarterPlayerScripts` via Rojo when adding UI/inputs.

## Key Files
- `default.project.json`: Rojo service mapping and port.
- `src/ServerScriptService/ProfileService/`: Profile loading, schema, and third-party `ProfileService.lua`.
- `src/ServerScriptService/Player/`: `PlayerManager.lua` (registry) and `RabbitClass.lua` (runtime state & stats).
- `src/ServerScriptService/Game/InitGame.server.lua`: minimal game state machine.
