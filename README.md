<p align="center">
  <img src="assets/logo.png" width="84" alt="Oblivion">
</p>

<h1 align="center">Oblivion Hub UI Library</h1>

<p align="center">
  A clean, modern UI library for Roblox scripts.<br>
  One line to load, a few lines to build a full menu.
</p>

<p align="center">
  <a href="https://ossdiablo.github.io/OblivionHub-UI/"><b>Website and full guide</b></a>
</p>

---

## 1. Load the library

Put this at the top of your script.

```lua
local Oblivion = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/OblivionHub-UI/main/Source.luau"))()
```

## 2. Make a window

```lua
local Window = Oblivion:CreateWindow({
    Name = "My Hub",
    Subtitle = "v1.0",
    ToggleUIKeybind = "RightControl",
})
```

That's a working menu. It comes with the Oblivion button to hide and show it, and ready-made **Server**, **ESP** and **Settings** tabs. Add `Home = true` for a Home tab too.

Drag any empty spot to move it. Drag the bottom-right corner to resize it.

## 3. Add a tab

```lua
local Main = Window:CreateTab({ Name = "Main", Icon = "zap" })
```

`Icon` is any [Lucide](https://lucide.dev/icons) icon name.

You can also add sub-tabs along the top of a tab:

```lua
local Player = Main:CreateSubTab({ Name = "Player", Icon = "user" })
local Combat = Main:CreateSubTab({ Name = "Combat", Icon = "swords" })

Player:CreateButton({ Name = "Click me", Callback = function() end })
```

## 4. Add things to the tab

```lua
Main:CreateSection("Player")

Main:CreateButton({
    Name = "Say hi",
    Callback = function()
        print("hi")
    end,
})

Main:CreateToggle({
    Name = "Auto sprint",
    CurrentValue = false,
    Callback = function(Value)
        print("Auto sprint is", Value)
    end,
})

Main:CreateSlider({
    Name = "Walk speed",
    Range = { 16, 100 },
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end,
})
```

Every element works the same way: give it a `Name`, and a `Callback` that runs when the user changes it.

## 5. Show a notification

```lua
Oblivion:Notify({
    Title = "Loaded",
    Content = "Everything is ready",
    Type = "Success", -- "Info", "Success", "Warning" or "Error"
    Duration = 4,
})
```

## 6. Save the user's settings

Turn saving on in the window, give each element a `Flag`, then load at the end.

```lua
local Window = Oblivion:CreateWindow({
    Name = "My Hub",
    ConfigurationSaving = { Enabled = true, FolderName = "MyHub" },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "zap" })

Main:CreateToggle({ Name = "Auto sprint", Flag = "AutoSprint", Callback = function(v) end })

Window:LoadConfig() -- always last
```

---

## Full example

```lua
local Oblivion = loadstring(game:HttpGet("https://raw.githubusercontent.com/OSSDiablo/OblivionHub-UI/main/Source.luau"))()

local Window = Oblivion:CreateWindow({
    Name = "My Hub",
    Subtitle = "v1.0",
    ConfigurationSaving = { Enabled = true, FolderName = "MyHub" },
})

local Main = Window:CreateTab({ Name = "Main", Icon = "zap" })

Main:CreateSection("Movement")

Main:CreateSlider({
    Name = "Walk speed",
    Range = { 16, 100 },
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        local h = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Value end
    end,
})

Main:CreateToggle({
    Name = "Infinite jump",
    Flag = "InfJump",
    Callback = function(Value)
        print("Infinite jump", Value)
    end,
})

Main:CreateButton({
    Name = "Reset character",
    Style = "Danger",
    Callback = function()
        game.Players.LocalPlayer.Character:BreakJoints()
    end,
})

Oblivion:Notify({ Title = "My Hub", Content = "Loaded", Type = "Success" })

Window:LoadConfig()
```

[`Example.luau`](Example.luau) shows every element at once.

---

## All elements

| Element | Code | Callback gets |
| --- | --- | --- |
| SubTab | `Tab:CreateSubTab({ Name, Icon })` | |
| Section | `Tab:CreateSection("Title")` | |
| Divider | `Tab:CreateDivider()` | |
| Label | `Tab:CreateLabel("Text")` | |
| Paragraph | `Tab:CreateParagraph({ Title, Content })` | |
| Stats | `Tab:CreateStats({ Columns = 2, Stats = { { Name, Icon, Value }, ... } })` | |
| Button | `Tab:CreateButton({ Name, Callback })` | nothing |
| Toggle | `Tab:CreateToggle({ Name, CurrentValue, Callback })` | `true` / `false` |
| Slider | `Tab:CreateSlider({ Name, Range = {min, max}, Increment, CurrentValue, Callback })` | number |
| Stepper | `Tab:CreateStepper({ Name, Range, Increment, CurrentValue, Callback })` | number |
| Progress | `Tab:CreateProgress({ Name, CurrentValue })` | |
| Dropdown | `Tab:CreateDropdown({ Name, Options = {...}, CurrentOption, MultipleOptions, Callback })` | option, or a list |
| Input | `Tab:CreateInput({ Name, PlaceholderText, Callback })` | text |
| Keybind | `Tab:CreateKeybind({ Name, CurrentKeybind = "F", Callback })` | key |
| Color picker | `Tab:CreateColorPicker({ Name, Color, Callback })` | Color3 |
| Menu | `Tab:CreateMenu({ Name, Icon, Width, Row })` | |

Every element also takes:

- `Desc` for a small grey line under the name
- `Flag` so it gets saved
- `Locked = true` and `LockedReason = "Premium"` to lock it

And every element you create can be changed later:

```lua
local Speed = Main:CreateSlider({ Name = "Walk speed", Range = { 16, 100 } })

Speed:Set(50)          -- change the value
print(Speed:Get())     -- read the value
Speed:SetLocked(true)  -- lock it
Speed:SetVisible(false) -- hide it
```

Stats are the info cards from the Home tab, usable in any tab. Update them by name:

```lua
local Info = Main:CreateStats({
	Stats = {
		{ Name = "Coins", Icon = "coins", Value = 0 },
		{ Name = "Kills", Icon = "skull", Value = 0 },
	},
})

Info:Set("Coins", 120)            -- one card
Info:Set({ Coins = 125, Kills = 3 }) -- several at once
Info:Add({ Name = "Deaths", Icon = "heart-crack", Value = 0 })
Info:Remove("Deaths")
```

A Menu is a row that opens a side window glued to the main window (right if it fits, else left). The side window has its own tabs and takes any element. Only one Menu is open at a time. `Row = false` hides the row so you can open it from your own button.

```lua
local Fly = Main:CreateMenu({ Name = "Fly", Icon = "plane" })
local General = Fly:CreateTab({ Name = "General", Icon = "sliders-horizontal" })
General:CreateToggle({ Name = "Enabled", Callback = function(v) end })
General:CreateSlider({ Name = "Speed", Range = { 10, 200 } })

Fly:Open()
Fly:Close()
```

## Built-in tabs

| Tab | What it does | Turn it off |
| --- | --- | --- |
| Home | Greeting and live stats (FPS, ping, time in server) | off unless `Home = true` |
| Server | Rejoin, server hop, join the smallest server, live server list | `Server = false` |
| ESP | Boxes, names, distance, health, tracers, chams and outlines, with a live avatar preview | `Esp = false` |
| Music | Full songs from SoundCloud, your own files, queue, synced lyrics in a side window | `Music = false` |
| Settings | Theme, hide key, saved configs, unload | `Settings = false` |

```lua
Oblivion:CreateWindow({ Name = "My Hub", Home = true, Server = false })
```

### Music

Search plays full songs from SoundCloud. Your own `.mp3` and `.ogg` files go in `workspace/OblivionUI/Music` and show up in Library. Lyrics come from lrclib and open in a side window from the mic button.

SoundCloud streams are AAC, which Roblox can't play, so the tab downloads them, decodes them to WAV with [`aac/AAC.luau`](aac/AAC.luau) and plays that file. A 4 minute song takes about 20 seconds the first time. The last few decoded songs are kept, so replays start right away.

| Option | What it does | Default |
| --- | --- | --- |
| `Volume` | Starting volume, 0 to 100 | `50` |
| `Folder` | Where your own songs and the cache live | `"OblivionUI/Music"` |
| `CacheSongs` | How many decoded songs to keep | `4` |
| `Mono` | Decode to one channel (half the file size) | `false` |
| `AAC` | A decoder you already loaded | none |
| `AACUrl` | Where to load the decoder from | this repo |

```lua
Oblivion:CreateWindow({ Name = "My Hub", Music = { Volume = 30, CacheSongs = 8 } })

local Music = Window.Music
local results = Music:Search("daft punk get lucky")
Music:Play(results[1])
Music:Pause()
Music:Resume()
Music:Next()
Music:Previous()
Music:Add(results[2]) -- add to the queue
```

## Popups

```lua
Oblivion:Confirm({
    Title = "Unload?",
    Content = "The menu will close.",
    Callback = function()
        Window:Destroy()
    end,
})
```

## Themes

Built in: `Mono` (default), `Moss` (green, `"Default"` before), `Midnight`, `Crimson`, `Ember`, `Rose`. Passing `"Default"` still works and gives Mono.

```lua
Oblivion:SetTheme("Midnight")
Oblivion:SetTheme({ Accent = Color3.fromRGB(0, 227, 255) })
```

## Window options

| Option | What it does | Default |
| --- | --- | --- |
| `Name` | Name of the ScreenGui. The sidebar title is always Oblivion, use `Subtitle` for your script name | `"Oblivion"` |
| `Subtitle` | Small line under the title | none |
| `Icon` | Logo next to the title | Oblivion logo |
| `Theme` | Starting theme | `"Mono"` |
| `ToggleUIKeybind` | Key that hides and shows the menu | `"RightControl"` |
| `Size` | Starting size | `UDim2.fromOffset(640, 480)` |
| `ConfigurationSaving` | `{ Enabled, FolderName, FileName, AutoSave }` | off |
| `OpenButton` | The draggable Oblivion button. `false` removes it | on |
| `Loading` | Loading screen. `false` skips it | on |
| `Home`, `Server`, `Esp`, `Music`, `Settings` | Built-in tabs | see above |

## Window functions

| Code | What it does |
| --- | --- |
| `Window:Toggle()` | Hide or show the menu |
| `Window:SelectTab("Main")` | Open a tab |
| `Window:SetKeybind("RightShift")` | Change the hide key |
| `Window:SaveConfig()` / `Window:LoadConfig()` | Save or load settings |
| `Window:Destroy()` | Close and remove everything |

---

<p align="center">
  Based on <a href="https://github.com/PookiePepelsss/Airflow-UI">Airflow UI</a> by Pookie.
</p>

<p align="center">
  <code>aac/AAC.luau</code> is a Luau port of <a href="https://github.com/audiocogs/aac.js">aac.js</a> and is licensed LGPL-3.0, separate from the rest of the library.
</p>
