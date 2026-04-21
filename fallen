setfflag('LuauStacklessPcall', 'true');

if (not LPH_OBFUSCATED) then
      LPH_ENCNUM = function(toEncrypt, ...)
          assert(type(toEncrypt) == "number" and #{...} == 0, "LPH_ENCNUM only accepts a single constant double or integer as an argument.")
          return toEncrypt
      end
      LPH_NUMENC = LPH_ENCNUM
  
      LPH_ENCSTR = function(toEncrypt, ...)
          assert(type(toEncrypt) == "string" and #{...} == 0, "LPH_ENCSTR only accepts a single constant string as an argument.")
          return toEncrypt
      end
      LPH_STRENC = LPH_ENCSTR
  
      LPH_ENCFUNC = function(toEncrypt, encKey, decKey, ...)
          assert(type(toEncrypt) == "function" and type(encKey) == "string" and #{...} == 0, "LPH_ENCFUNC accepts a constant function, constant string, and string variable as arguments.")
          return toEncrypt
      end
      LPH_FUNCENC = LPH_ENCFUNC
  
      LPH_JIT = function(f, ...)
          assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
          return f
      end
      LPH_JIT_MAX = LPH_JIT
  
      LPH_NO_VIRTUALIZE = function(f, ...)
          assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
          return f
      end
  
      LPH_NO_UPVALUES = function(f, ...)
          assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
          assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
          return f
      end
  
      LPH_CRASH = function(...)
          assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
      end
  end
  
  local Cheat = { GameName = 'None', Modules = { }, Globals = { } }
  
  game:GetService("ScriptContext").Error:Connect(LPH_NO_VIRTUALIZE(function(msg, trace, scr)
      if not scr or trace:find("''") or msg:find("''") or trace:find('ChocoSploit') or msg:find('ChocoSploit') then
          game:GetService("Players").LocalPlayer:Kick('error detected\n' .. msg)
      end
  end))
  
  local Players = game:GetService("Players")
  local HttpService = game:GetService("HttpService")
  local UserInputService = game:GetService("UserInputService")
  local RunService = game:GetService("RunService")
  local TweenService = game:GetService("TweenService")
  
  local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/mainstreamed/clones/refs/heads/main/bred/uiLibrary.lua'))()
  
  local flags = Library.Flags
  local Window = Library:Window({Name = 'luna.vip', Logo = '81336411204830'})
  local Watermark = Window:Watermark("luna.vip")
  local KeybindList = Window:KeybindList()
  local ArmorViewer = Window:ArmorViewer()
  
  local CombatPage = Window:Page({Name = 'Combat'})
  local VisualsPage = Window:Page({Name = 'Visuals'})
  local MiscPage = Window:Page({Name = 'Misc'})
  local SettingsPage = Library:CreateSettingsPage(Window, KeybindList, Watermark)
  
  local Debris, Players, Workspace, GuiService, RunService, UserInputService, ReplicatedStorage, Lighting, HttpService = game:GetService('Debris'), game:GetService('Players'), game:GetService('Workspace'), game:GetService('GuiService'), game:GetService('RunService'), game:GetService('UserInputService'), game:GetService('ReplicatedStorage'), game:GetService('Lighting'), game:GetService('HttpService')
  
  Cheat.Globals.QuickStackFunctions = {}
  Cheat.Globals.HookedStates = setmetatable({}, { __mode = "k" })

  Cheat.Globals.LastManip = tick()
  Cheat.Globals.LastAutoReload = tick()
  
  --// UI Elements
  do
      --// Combat
      do
          --// Main
          do
              local AimbotSection = CombatPage:Section({Name = "Aimbot", Side = 1, Fill = 0.5})
  
              AimbotSection:Toggle({Name = "Enabled", Flag = "AimbotEnabled", Default = false})
  
              AimbotSection:Slider({
                  Name = "Hit Chance",
                  Flag = "HitChance",
                  Min = 0,
                  Max = 100,
                  Default = 100,
                  Suffix = "%",
              })
  
              AimbotSection:Toggle({Name = "Force Penetration", Flag = "ForcePenetration"})
              AimbotSection:Toggle({Name = "Manipulation", Flag = "Manipulation"}):Colorpicker({
                  Name = "Manipulation Color",
                  Flag = "ManipulationIndicatorColor",
                  Default = Color3.fromRGB(0, 0, 0),
              })
              AimbotSection:Toggle({Name = "Target Teammates", Flag = "TargetTeammates", Default = true})
  
              AimbotSection:Toggle({Name = "Visible Check", Flag = "VisibleCheck"}):Colorpicker({
                  Name = "Visible Color",
                  Flag = "VisibleIndicatorColor",
                  Default = Color3.fromRGB(0, 0, 0),
              })
  
              AimbotSection:Toggle({Name = "Down Check", Flag = "DownCheck", Default = true})
              AimbotSection:Toggle({Name = "Armor Bar", Flag = "ArmorBarEnabled"})
              AimbotSection:Toggle({Name = "Flags", Flag = "CombatIndicators", Default = true})
  
              AimbotSection:Dropdown({
                  Name = "Target Parts",
                  Flag = "TargetParts",
                  Items = {
                      "Head","UpperTorso","LowerTorso",
                      "LeftUpperArm","LeftLowerArm","LeftHand",
                      "RightUpperArm","RightLowerArm","RightHand",
                      "LeftUpperLeg","LeftLowerLeg","LeftFoot",
                      "RightUpperLeg","RightLowerLeg","RightFoot"
                  },
                  Default = {"Head"},
                  Multi = true,
              })
  
              AimbotSection:Toggle({Name = "Draw Fov", Flag = "FovEnabled"}):Colorpicker({
                  Name = "Fov Color",
                  Flag = "FovColor",
                  Alpha = 0.3,
                  Default = Color3.fromRGB(255, 20, 147),
              })
  
              AimbotSection:Slider({
                  Name = "Fov Size",
                  Flag = "FovSize",
                  Min = 0,
                  Max = 500,
                  Default = 200,
                  Decimals = 1,
              })
  
              AimbotSection:Slider({
                  Name = "Thickness",
                  Flag = "FovThickness",
                  Min = 1,
                  Max = 5,
                  Default = 2,
                  Decimals = 0.1,
              })
          end
  
          --// Gun Mods
          do 
              local GunModsSection = CombatPage:Section({Name = "Gun Mods", Side = 2})
  
              GunModsSection:Toggle({
                  Name = "No Recoil",
                  Flag = "NoRecoil",
              })
  
              GunModsSection:Toggle({
                  Name = "No Spread",
                  Flag = "NoSpread",
              })
  
              GunModsSection:Toggle({
                  Name = "No Sway",
                  Flag = "NoSway",
              })
  
              GunModsSection:Toggle({
                  Name = "RPM",
                  Flag = "RPM",
              })
              
              GunModsSection:Slider({
                  Name = "Multiplier",
                  Flag = "RapidFireRate",
                  Min = 1,
                  Max = 1.5,
                  Default = 1,
                  Decimals = 0.1,
              })
  
              GunModsSection:Toggle({
                  Name = "Instant Bullet",
                  Flag = "InstantBullet",
              })
  
          end
      end
  
      --// Visuals
      do
          do --// Players
              local className = 'Players'
              local PlayersMain = VisualsPage:Section({Name = className, Side = 1})
  
              PlayersMain:Toggle({
                  Name = "Enable",
                  Flag = className .. "ESPEnabled",
              })
  
              PlayersMain:Toggle({
                  Name = "Boxes",
                  Flag = className .. "Boxes",
              })
              PlayersMain:Label("Box Fill"):Colorpicker({
                  Name = "Box Fill",
                  Flag = className .. "BoxColor1",
                  Default = Color3.fromRGB(90,120,255),
              })
              PlayersMain:Label("Box Outline"):Colorpicker({
                  Name = "Box Outline",
                  Flag = className .. "BoxColor2",
                  Default = Color3.fromRGB(180,90,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Chams",
                  Flag = className .. "Chams",
              })
  
              PlayersMain:Label("Cham Fill"):Colorpicker({
                  Name = "Cham Fill",
                  Flag = className .. "ChamsColor1",
                  Default = Color3.fromRGB(90,120,255),
              })
              PlayersMain:Label("Cham Outline"):Colorpicker({
                  Name = "Cham Outline",
                  Flag = className .. "ChamsColor2",
                  Default = Color3.fromRGB(180,90,255),
              })
  
  
              PlayersMain:Toggle({
                  Name = "Names",
                  Flag = className .. "Names",
              }):Colorpicker({
                  Name = "Name Color",
                  Flag = className .. "NameColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Health Bar",
                  Flag = className .. "Health",
              })
              PlayersMain:Label("Health Low"):Colorpicker({
                  Name = "Health Low",
                  Flag = className .. "HealthColor1",
                  Default = Color3.fromRGB(255,70,70),
              })
              PlayersMain:Label("Health Mid"):Colorpicker({
                  Name = "Health Mid",
                  Flag = className .. "HealthColor2",
                  Default = Color3.fromRGB(255,220,70),
              })
              PlayersMain:Label("Health High"):Colorpicker({
                  Name = "Health High",
                  Flag = className .. "HealthColor3",
                  Default = Color3.fromRGB(80,255,120),
              })
  
              PlayersMain:Toggle({
                  Name = "Distance",
                  Flag = className .. "Distance",
              }):Colorpicker({
                  Name = "Distance Color",
                  Flag = className .. "DistanceColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Weapon",
                  Flag = className .. "Weapon",
              }):Colorpicker({
                  Name = "Weapon Color",
                  Flag = className .. "WeaponColor",
                  Default = Color3.fromRGB(255,255,255),
              })
              
              PlayersMain:Slider({
                  Name = "Max Distance (studs)",
                  Flag = className .. "MaxDistance",
                  Min = 20,
                  Max = 10000,
                  Default = 10000,
                  Decimals = 1,
              })
          end
          do --// Boss
              local className = 'Boss'
              local PlayersMain = VisualsPage:Section({Name = className, Side = 1})
  
              PlayersMain:Toggle({
                  Name = "Enable",
                  Flag = className .. "ESPEnabled",
              })
  
              PlayersMain:Toggle({
                  Name = "Boxes",
                  Flag = className .. "Boxes",
              })
              PlayersMain:Label("Box Fill"):Colorpicker({
                  Name = "Box Fill",
                  Flag = className .. "BoxColor1",
                  Default = Color3.fromRGB(90,120,255),
              })
              PlayersMain:Label("Box Outline"):Colorpicker({
                  Name = "Box Outline",
                  Flag = className .. "BoxColor2",
                  Default = Color3.fromRGB(180,90,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Names",
                  Flag = className .. "Names",
              }):Colorpicker({
                  Name = "Name Color",
                  Flag = className .. "NameColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Health Bar",
                  Flag = className .. "Health",
              })
              PlayersMain:Label("Health Low"):Colorpicker({
                  Name = "Health Low",
                  Flag = className .. "HealthColor1",
                  Default = Color3.fromRGB(255,70,70),
              })
              PlayersMain:Label("Health Mid"):Colorpicker({
                  Name = "Health Mid",
                  Flag = className .. "HealthColor2",
                  Default = Color3.fromRGB(255,220,70),
              })
              PlayersMain:Label("Health High"):Colorpicker({
                  Name = "Health High",
                  Flag = className .. "HealthColor3",
                  Default = Color3.fromRGB(80,255,120),
              })
  
              PlayersMain:Toggle({
                  Name = "Distance",
                  Flag = className .. "Distance",
              }):Colorpicker({
                  Name = "Distance Color",
                  Flag = className .. "DistanceColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Weapon",
                  Flag = className .. "Weapon",
              }):Colorpicker({
                  Name = "Weapon Color",
                  Flag = className .. "WeaponColor",
                  Default = Color3.fromRGB(255,255,255),
              })
              
              PlayersMain:Slider({
                  Name = "Max Distance (studs)",
                  Flag = className .. "MaxDistance",
                  Min = 20,
                  Max = 10000,
                  Default = 10000,
                  Decimals = 1,
              })
          end
          do --// AI
              local className = 'AI'
              local PlayersMain = VisualsPage:Section({Name = className, Side = 1})
  
              PlayersMain:Toggle({
                  Name = "Enable",
                  Flag = className .. "ESPEnabled",
              })
  
              PlayersMain:Toggle({
                  Name = "Boxes",
                  Flag = className .. "Boxes",
              })
              PlayersMain:Label("Box Fill"):Colorpicker({
                  Name = "Box Fill",
                  Flag = className .. "BoxColor1",
                  Default = Color3.fromRGB(90,120,255),
              })
              PlayersMain:Label("Box Outline"):Colorpicker({
                  Name = "Box Outline",
                  Flag = className .. "BoxColor2",
                  Default = Color3.fromRGB(180,90,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Names",
                  Flag = className .. "Names",
              }):Colorpicker({
                  Name = "Name Color",
                  Flag = className .. "NameColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Health Bar",
                  Flag = className .. "Health",
              })
              PlayersMain:Label("Health Low"):Colorpicker({
                  Name = "Health Low",
                  Flag = className .. "HealthColor1",
                  Default = Color3.fromRGB(255,70,70),
              })
              PlayersMain:Label("Health Mid"):Colorpicker({
                  Name = "Health Mid",
                  Flag = className .. "HealthColor2",
                  Default = Color3.fromRGB(255,220,70),
              })
              PlayersMain:Label("Health High"):Colorpicker({
                  Name = "Health High",
                  Flag = className .. "HealthColor3",
                  Default = Color3.fromRGB(80,255,120),
              })
  
              PlayersMain:Toggle({
                  Name = "Distance",
                  Flag = className .. "Distance",
              }):Colorpicker({
                  Name = "Distance Color",
                  Flag = className .. "DistanceColor",
                  Default = Color3.fromRGB(255,255,255),
              })
  
              PlayersMain:Toggle({
                  Name = "Weapon",
                  Flag = className .. "Weapon",
              }):Colorpicker({
                  Name = "Weapon Color",
                  Flag = className .. "WeaponColor",
                  Default = Color3.fromRGB(255,255,255),
              })
              
              PlayersMain:Slider({
                  Name = "Max Distance (studs)",
                  Flag = className .. "MaxDistance",
                  Min = 20,
                  Max = 10000,
                  Default = 10000,
                  Decimals = 1,
              })
          end
          do
              local MiscESPSection = VisualsPage:Section({Name = "Misc", Side = 2})
              MiscESPSection:Toggle({Name = "Enabled", Flag = "MiscEnabledESP"})
              for i, v in next, {'Stone', 'Metal', 'Phosphate', 'Wool', 'Animals', 'Care Package', 'Drops', 'Body Bag', 'Salvaged Flycopter', 'Auto Turret', 'Shotgun Turret'} do
                  MiscESPSection:Toggle({Name = v, Flag = v .. "Enabled"}):Colorpicker({
                      Name = v .. " Color",
                      Flag = v .. "Color",
                  })
  
                  MiscESPSection:Slider({
                      Name = "Max Distance",
                      Flag = v .. "MaxDistance",
                      Min = 10,
                      Max = (v == 'Care Package' or v == 'Salvaged Flycopter') and 3000 or v == 'Body Bag' and 1000 or 400,
                      Default = (v == 'Care Package' or v == 'Salvaged Flycopter') and 3000 or 50,
                  })
              end
  
          end
          do
              local MiscVisualsSection = VisualsPage:Section({Name = "Misc Visuals", Side = 2})

              MiscVisualsSection:Toggle({
                  Name = "Remove Grass",
                  Flag = "RemoveGrass",
                  Callback = function(state)
                      pcall(function()
                          sethiddenproperty(workspace.Terrain, "Decoration", not state)
                      end)
                  end
              })

              MiscVisualsSection:Toggle({Name = "Remove Fog", Flag = "RemoveFog"})

              MiscVisualsSection:Toggle({Name = "Change Fog Density", Flag = "ChangeFogDensity"})
              MiscVisualsSection:Slider({Name = "Fog Density", Flag = "FogDensity", Min = 0, Max = 1, Default = 0.5, Decimals = 0.001})

              MiscVisualsSection:Toggle({Name = "Change Fog Haze", Flag = "ChangeFogHaze"})
              MiscVisualsSection:Slider({Name = "Fog Haze", Flag = "FogHaze", Min = 0, Max = 1, Default = 0.5, Decimals = 0.001})

              MiscVisualsSection:Toggle({Name = "Change Fog Glare", Flag = "ChangeFogGlare"})
              MiscVisualsSection:Slider({Name = "Fog Glare", Flag = "FogGlare", Min = 0, Max = 1, Default = 0.5, Decimals = 0.001})

              MiscVisualsSection:Toggle({Name = "Change Fog Color", Flag = "ChangeFogColor"}):Colorpicker({
                  Name = "Fog Color", Flag = "FogColor", Default = Color3.fromRGB(255, 255, 255)
              })

              MiscVisualsSection:Toggle({Name = "Change Fog Decay", Flag = "ChangeFogDecay"}):Colorpicker({
                  Name = "Fog Decay", Flag = "FogDecay", Default = Color3.fromRGB(255, 255, 255)
              })

              MiscVisualsSection:Toggle({
                  Name = "Ambience",
                  Flag = "AmbienceEnabled",
              }):Colorpicker({
                  Name = "Color",
                  Flag = "AmbienceColor",
                  Default = Color3.fromRGB(255, 255, 255),
              })
  
              MiscVisualsSection:Slider({
                  Name = "Brightness",
                  Flag = "AmbienceBrightness",
                  Min = 0,
                  Max = 1,
                  Default = 0.12,
                  Decimals = 0.001,
              })
  
              MiscVisualsSection:Slider({
                  Name = "Indoor Brightness",
                  Flag = "AmbienceIndoorBrightness",
                  Min = 0,
                  Max = 1,
                  Default = 0.035,
                  Decimals = 0.001,
              })
  
              MiscVisualsSection:Toggle({
                  Name = "Bullet Tracers",
                  Flag = "BulletTracers",
              }):Colorpicker({
                  Name = "Color",
                  Flag = "BulletTracersColor",
                  Default = Color3.fromRGB(255, 255, 255),
              })
  
              MiscVisualsSection:Slider({
                  Name = "Duration",
                  Flag = "BulletTracersDuration",
                  Min = 1,
                  Max = 5,
                  Default = 2,
                  Decimals = 1,
              })

              MiscVisualsSection:Toggle({
                  Name = "Arm Chams",
                  Flag = "ArmChams",
              }):Colorpicker({
                  Name = "Arm Accent",
                  Flag = "ArmAccent",
                  Default = Color3.fromRGB(170, 85, 255),
              })

              MiscVisualsSection:Toggle({
                  Name = "Weapon Chams",
                  Flag = "WeaponChams",
              }):Colorpicker({
                  Name = "Weapon Accent",
                  Flag = "WeaponAccent",
                  Default = Color3.fromRGB(255, 255, 255),
              })

MiscVisualsSection:Dropdown({
    Name = "Chams Material",
    Flag = "CustomModelMaterial",
    Items = {
        "ForceField",
        "Neon",
        "SmoothPlastic",
    },
    Default = "ForceField",
})
          end
      end
  
      --// Misc
      do
          --// Movement
          do
              local MovementSection = MiscPage:Section({Name = "Movement", Side = 1})
              MovementSection:Toggle({
                  Name = "Speed",
                  Flag = "SpeedEnabled",
              }):Keybind({
                  Name = "Speed Bind",
                  Flag = "SpeedBind",
                  Mode = "Toggle",
                  Default = Enum.KeyCode.B
              })
  
              MovementSection:Slider({
                  Name = "Speed",
                  Flag = "SpeedSpeed",
                  Min = 16,
                  Max = 30,
                  Default = 16,
              })
  
              MovementSection:Toggle({
                  Name = "Flight",
                  Flag = "FlightEnabled",
              }):Keybind({
                  Name = "Flight Bind",
                  Flag = "FlightBind",
                  Mode = "Toggle",
                  Default = Enum.KeyCode.V
              })
  
              MovementSection:Slider({
                  Name = "Speed",
                  Flag = "FlightSpeed",
                  Min = 1,
                  Max = 20,
                  Default = 10,
              })
  
              MovementSection:Toggle({
                  Name = "Zoom",
                  Flag = "ZoomEnabled",
              }):Keybind({
                  Name = "Keybind",
                  Flag = "ZoomKeybind",
                  Mode = "Hold",
                  Default = Enum.KeyCode.Z
              })
  
              MovementSection:Slider({
                  Name = "Fov",
                  Flag = "ZoomAmount",
                  Min = 1,
                  Max = 80,
                  Default = 30,
              })
              MovementSection:Toggle({
                  Name = "Freecam",
                  Flag = "Freecam",
              }):Keybind({
                  Name = "Freecam Bind",
                  Flag = "FreecamKeybind",
                  Mode = "Toggle",
                  Default = Enum.KeyCode.U
              })
  
              MovementSection:Slider({
                  Name = "Speed",
                  Flag = "FreecamSpeed",
                  Min = 1,
                  Max = 100,
                  Default = 10,
              })
  
              MovementSection:Toggle({
        Name = "Silent Walk",
        Flag = "SilentWalk",
        Default = false
    });



          end
          
          do --// Exploits
              local ExploitsSection = MiscPage:Section({Name = "Exploits", Side = 2})
              ExploitsSection:Toggle({
                  Name = "No Bob",
                  Flag = "NoBob"
              });
  
              ExploitsSection:Toggle({
                  Name = "Perfect Farm",
                  Flag = "PerfectFarm"
              })

              ExploitsSection:Toggle({
                  Name = "No Fall Damage",
                  Flag = "NoFall"
              })
  
              ExploitsSection:Toggle({
                  Name = "Instant loot",
                  Flag = "InstantLoot",
                  Callback = function(value)
                      local QuickStackFunctions = Cheat.Globals.QuickStackFunctions or {}
  
                      if #QuickStackFunctions > 0 then
                          for _, FUNCTION in QuickStackFunctions do
                              debug.setconstant(FUNCTION, 19, value and 0 or 0.9) -- 0.9
                              debug.setconstant(FUNCTION, 20, value and 0 or 0.3) -- 0.3
                              debug.setconstant(FUNCTION, 21, value and 0 or 0.1) -- 0.1
                          end
                      end
                  end;
              });
          end
      end
  end
  
  --// Game Code
  local Camera = Workspace.CurrentCamera
  local Client = Players.LocalPlayer
  
  local wsVFXFolder = Workspace:WaitForChild("VFX")
  local VMs = wsVFXFolder and wsVFXFolder:FindFirstChild('VMs')
  local Drops = workspace:FindFirstChild('Drops')
  local Plants = workspace:FindFirstChild('Plants')
  local Animals = workspace:FindFirstChild('Animals')
  
  local Modules = ReplicatedStorage:WaitForChild("Modules")
  local rsVFXFolder = ReplicatedStorage:WaitForChild("VFX")
  local Values = ReplicatedStorage:WaitForChild("Values")
  
  local ItemClass = Modules and require(Modules:WaitForChild("ItemClass"))
  local VFXModule = Modules and require(Modules.VFXModule)
  local ItemsModule = Modules and require(Modules.Items)
  local RaycastUtil = Modules and require(Modules.RaycastUtil)
  local SettingsModule = Modules and require(Modules.SettingsModule)
  local SoundModule = Modules and require(Modules.SoundModule)
  local ToolInfo = Modules and require(Modules.ToolInfo)
  
  if not (ItemClass and VFXModule and ItemsModule and RaycastUtil and SettingsModule and SoundModule) then
      Client:Kick("Failed to load game modules.")
      return
  end
  
  local clanController, clanControllerShared
  if Client:FindFirstChild("PlayerScripts") and Client.PlayerScripts:FindFirstChild("ClanController") then
      clanController = getsenv(Client.PlayerScripts:WaitForChild("ClanController"))
      clanControllerShared = clanController and clanController.shared
  else
      clanControllerShared = {cachedTeamModels = {}}
  end
  
  local isTeam = LPH_NO_VIRTUALIZE(function(player)
      if typeof(player) ~= 'Instance' or not player:IsA('Player') then return false end
      local teamCache = clanControllerShared and clanControllerShared.cachedTeamModels
      return teamCache and teamCache[player.UserId] or false
  end)

  local ViewmodelOriginalMaterials = setmetatable({}, { __mode = "k" })
  local ViewmodelOriginalColors = setmetatable({}, { __mode = "k" })
  local ViewmodelConnections = setmetatable({}, { __mode = "k" })

  local function revertViewmodelPart(part)
      if not part or not part:IsA("BasePart") then
          return
      end

      local originalMaterial = ViewmodelOriginalMaterials[part]
      if originalMaterial ~= nil then
          part.Material = originalMaterial
          ViewmodelOriginalMaterials[part] = nil
      end

      local originalColor = ViewmodelOriginalColors[part]
      if originalColor ~= nil then
          part.Color = originalColor
          ViewmodelOriginalColors[part] = nil
      end
  end

  local function updateViewmodelPart(descendant)
      if not descendant or not descendant:IsA("BasePart") then
          return
      end

      local armsAncestor = descendant:FindFirstAncestor("Arms")
      local weaponAncestor = descendant:FindFirstAncestor("Weapon")
      local materialName = flags.CustomModelMaterial or "ForceField"
      local material = Enum.Material[materialName]

      if armsAncestor and flags.ArmChams then
          ViewmodelOriginalMaterials[descendant] = ViewmodelOriginalMaterials[descendant] or descendant.Material
          ViewmodelOriginalColors[descendant] = ViewmodelOriginalColors[descendant] or descendant.Color

          if material then
              descendant.Material = material
          end

          descendant.Color = (flags.ArmAccent and flags.ArmAccent.Color) or Color3.fromRGB(170, 85, 255)
          return
      end

      if weaponAncestor and flags.WeaponChams then
          ViewmodelOriginalMaterials[descendant] = ViewmodelOriginalMaterials[descendant] or descendant.Material
          ViewmodelOriginalColors[descendant] = ViewmodelOriginalColors[descendant] or descendant.Color

          if material then
              descendant.Material = material
          end

          descendant.Color = (flags.WeaponAccent and flags.WeaponAccent.Color) or Color3.fromRGB(255, 255, 255)
          return
      end

      revertViewmodelPart(descendant)
  end

  local function rescanViewmodel(model)

      if not model then
          return
      end

      for _, descendant in model:GetDescendants() do
          updateViewmodelPart(descendant)
      end
  end

  local function disconnectViewmodel(model)
      local connections = ViewmodelConnections[model]
      if connections then
          for _, connection in connections do
              connection:Disconnect()
          end
          ViewmodelConnections[model] = nil
      end
  end

  local function watchViewmodel(model)
      if not model or not model:IsA("Model") then
          return
      end

      disconnectViewmodel(model)
      rescanViewmodel(model)

      ViewmodelConnections[model] = {
          model.DescendantAdded:Connect(function(descendant)
              updateViewmodelPart(descendant)
          end),
          model.DescendantRemoving:Connect(function(descendant)
              if descendant:IsA("BasePart") then
                  ViewmodelOriginalMaterials[descendant] = nil
                  ViewmodelOriginalColors[descendant] = nil
              end
          end),
      }
  end

  if VMs then
      for _, model in VMs:GetChildren() do
          watchViewmodel(model)
      end

      VMs.ChildAdded:Connect(function(model)
          task.wait()
          watchViewmodel(model)
      end)

      VMs.ChildRemoved:Connect(function(model)
          disconnectViewmodel(model)
      end)

      RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
          for _, model in VMs:GetChildren() do
              rescanViewmodel(model)
          end
      end))
  end
  
  local getgun = LPH_NO_VIRTUALIZE(function(character)
      if not character then return "None" end
      for _, model in character:GetChildren() do
          if not model:IsA('Model') then
              continue
          end

          if model.Name == 'Hair' or model.Name == 'HolsterModel' then
              continue
          end

          if not model.PrimaryPart then
              continue
          end

          if model:FindFirstChild("Detail") or model:FindFirstChild("Main") or model:FindFirstChild("Handle") or model:FindFirstChild("Attachments") or model:FindFirstChild("ArrowAttach") or model:FindFirstChild("Attach") then
              return model.Name
          end
      end

      return "None"
  end)
  
  local Targeting = {
      TargetPart = nil,
      TargetCharacter = nil,
      ManipulatedPosition = nil,
      ManipPos = nil,
      Targets = {},
  }

  local suppressImpactTracer = false
  local isViewmodelContext = LPH_NO_UPVALUES(function()
      local character = Cheat and Cheat.Globals and Cheat.Globals.ClientCharacter
      if not character then
          return false
      end

      local vm = character:FindFirstChild("ViewmodelController")
      if not vm then
          return false
      end

      local equipped = vm:GetAttribute("Equipped")
      if equipped == nil or equipped == 0 then
          return false
      end

      local gun = getgun(character)
      return gun and gun ~= "None"
  end)
  
  --// Gun Mods
  do
      local oldAttachmentStats = ItemClass.AttachmentStats
      ItemClass.AttachmentStats = LPH_NO_UPVALUES(function(v50, v51)
          local r = oldAttachmentStats(v50, v51)
          
          if r and isViewmodelContext() then
              if flags['RPM'] then
                  r.FireRateMult = flags['RapidFireRate'] - 1
              end
              
              if flags['InstantBullet'] then
                  r.SpeedMult = 100
              end
              
              if flags['NoRecoil'] then
                  r.RecoilMult = -1;
              end
              
              if flags['NoSpread'] then
                  r.AimSpreadMult = -1;
                  r.HipSpreadMult = -1;
              end
              
              if flags['NoSway'] then
                  r.SwayMult = -1;
              end
          end
  
          return r
      end)
  
      local oldGetSetting = SettingsModule.GetSetting
      SettingsModule.GetSetting = function(v34, v35, v36)
          if v34 == 'General' and v35 == 'Field Of View' and flags.ZoomEnabled and (flags.ZoomKeybind.active or flags.ZoomKeybind.Toggled) then
              return flags.ZoomAmount
          end
          return oldGetSetting(v34, v35, v36)
      end
  
      RunService.Heartbeat:Connect(function()
          -- debug.profilebegin("Auto Reload")
  
      end)
  end
  do --// Visuals
      --// Player ESP
      do
          local ESP = {}
  
          local ScreenGui = Instance.new('ScreenGui')
          ScreenGui.IgnoreGuiInset = true
          ScreenGui.Parent = gethui()
  
          local OUTLINE = 1
          local BOX_THICKNESS = 2
          local NAME_PADDING_X = 6
          local NAME_PADDING_Y = 2
  
          local function BoxMath(item)
              if not item then return nil, nil, false end
              local Torso =
                  item:FindFirstChild('HumanoidRootPart')
                  or item:FindFirstChild('UpperTorso')
                  or item:FindFirstChild('Torso')
              if not Torso then return nil, nil, false end
              local cf = Torso.CFrame
              local pos = Torso.Position
              local vTop = pos + (cf.UpVector * 2)
              local vBottom = pos - (cf.UpVector * 2.8)
              local top, topVisible = Camera:WorldToViewportPoint(vTop)
              local bottom, bottomVisible = Camera:WorldToViewportPoint(vBottom)
              if not topVisible and not bottomVisible then return nil, nil, false end
              local height = math.abs(bottom.Y - top.Y)
              if height <= 0 then return nil, nil, false end
              local width = height / 1.2
              return Vector2.new(
                  math.floor((top.X + bottom.X) * 0.5 - width * 0.5),
                  math.min(top.Y, bottom.Y)
              ), Vector2.new(width, height), true
          end
  
          local function createBox(parent, color)
              local box = Instance.new('Frame')
              box.BackgroundTransparency = 1
              box.Parent = parent
              local sides = {}
              for i = 1, 4 do
                  local f = Instance.new('Frame')
                  f.BorderSizePixel = 0
                  f.BackgroundColor3 = color
                  f.Parent = box
                  sides[i] = f
              end
              return box, sides
          end
  
          local function newText()
              local t = Instance.new('TextLabel')
              t.BackgroundTransparency = 1
              t.TextColor3 = Color3.new(1,1,1)
              t.TextTransparency = 0
              t.TextStrokeColor3 = Color3.new(0,0,0)
              t.TextStrokeTransparency = 0
              t.FontFace = Library.Font
              t.TextSize = 11
              t.TextXAlignment = Enum.TextXAlignment.Center
              t.TextYAlignment = Enum.TextYAlignment.Center
              return t
          end
  
          local function createESP(char, name, classname)
              local holder = Instance.new('Frame')
              holder.BackgroundTransparency = 1
              holder.Visible = false
              holder.Parent = ScreenGui
  
              local nameText = newText()
              nameText.Text = name
              nameText.Parent = holder
  
              local boxGroup = Instance.new('Frame')
              boxGroup.BackgroundTransparency = 1
              boxGroup.Parent = holder
  
              local outerBox, outerSides = createBox(boxGroup, Color3.new(0,0,0))
              local gradBox, gradSides = createBox(boxGroup, Color3.new(1,1,1))
              local innerBox, innerSides = createBox(boxGroup, Color3.new(0,0,0))
  
              local gradients = {}
              for i = 1, 4 do
                  local g = Instance.new('UIGradient')
                  g.Rotation = 90
                  g.Parent = gradSides[i]
                  gradients[i] = g
              end
  
              local healthBack = Instance.new('Frame')
              healthBack.BackgroundTransparency = 1
              healthBack.BorderSizePixel = 0
              healthBack.Parent = holder
  
              local healthOutline = Instance.new('Frame')
              healthOutline.BackgroundColor3 = Color3.new(0,0,0)
              healthOutline.BorderSizePixel = 0
              healthOutline.Parent = healthBack
  
              local healthInner = Instance.new('Frame')
              healthInner.BackgroundColor3 = Color3.fromRGB(35,35,35)
              healthInner.BorderSizePixel = 0
              healthInner.Parent = healthBack
  
              local healthFillHolder = Instance.new('Frame')
              healthFillHolder.BackgroundTransparency = 1
              healthFillHolder.BorderSizePixel = 0
              healthFillHolder.ClipsDescendants = true
              healthFillHolder.Parent = healthInner
  
              local healthFill = Instance.new('Frame')
              healthFill.BorderSizePixel = 0
              healthFill.AnchorPoint = Vector2.new(0,1)
              healthFill.Position = UDim2.fromScale(0,1)
              healthFill.Size = UDim2.fromScale(1,1)
              healthFill.BackgroundColor3 = Color3.new(1,1,1)
              healthFill.Parent = healthFillHolder
  
              local healthGradient = Instance.new('UIGradient')
              healthGradient.Rotation = 90
              healthGradient.Parent = healthFill
  
              local distText = newText()
              distText.Parent = holder
  
              local weaponText = newText()
              weaponText.Text = '[None]'
              weaponText.Parent = holder
  
              local cham = Instance.new('Highlight')
              pcall(function() cham.Parent = game:GetService("CoreGui") end)
              if not cham.Parent then cham.Parent = char end
              cham.Adornee = char
              cham.Enabled = false
              cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  
              ESP[char] = {
                  Holder = holder,
                  Name = nameText,
                  BoxGroup = boxGroup,
                  OuterBox = outerBox,
                  OuterSides = outerSides,
                  GradBox = gradBox,
                  GradSides = gradSides,
                  Gradients = gradients,
                  InnerBox = innerBox,
                  InnerSides = innerSides,
                  HealthBack = healthBack,
                  HealthOutline = healthOutline,
                  HealthInner = healthInner,
                  HealthFillHolder = healthFillHolder,
                  HealthFill = healthFill,
                  HealthGradient = healthGradient,
                  Distance = distText,
                  Weapon = weaponText,
                  Class = classname,
                  Cham = cham
              }
          end
  
          local function sizeSides(sides, w, h, t)
              sides[1].Position = UDim2.fromOffset(0,0)
              sides[1].Size = UDim2.fromOffset(w, t)
              sides[2].Position = UDim2.fromOffset(0, h - t)
              sides[2].Size = UDim2.fromOffset(w, t)
              sides[3].Position = UDim2.fromOffset(0,0)
              sides[3].Size = UDim2.fromOffset(t, h)
              sides[4].Position = UDim2.fromOffset(w - t,0)
              sides[4].Size = UDim2.fromOffset(t, h)
          end
  
          RunService.RenderStepped:Connect(function()
              for char, e in pairs(ESP) do
                  local class = e.Class
                  if not flags[class .. 'ESPEnabled'] then
                      e.Holder.Visible = false
                      if e.Cham then
                          e.Cham.Enabled = false
                      end
                      continue
                  end
  
                  local hum = char:FindFirstChildOfClass('Humanoid')
                  if not hum or hum.Health <= 0 then
                      e.Holder.Visible = false
                      if e.Cham then
                          e.Cham.Enabled = false
                      end
                      continue
                  end
  
                  local pos, size, ok = BoxMath(char)
                  if not ok then
                      e.Holder.Visible = false
                      if e.Cham then
                          e.Cham.Enabled = false
                      end
                      continue
                  end
                  local distance = (Camera.CFrame.Position - char:GetPivot().Position).Magnitude
                  if distance > flags[class .. 'MaxDistance'] then
                      e.Holder.Visible = false
                      if e.Cham then
                          e.Cham.Enabled = false
                      end
                      continue
                  end
  
                  local barW = 4
                  local gap = 4
                  local reservedLeft = barW + gap + OUTLINE
  
                  e.Holder.Position = UDim2.fromOffset(pos.X - reservedLeft, pos.Y)
                  e.Holder.Visible = true
  
                  e.BoxGroup.Position = UDim2.fromOffset(reservedLeft, 0)
                  e.BoxGroup.Size = UDim2.fromOffset(size.X, size.Y)
  
                  e.Name.Position = UDim2.fromOffset(reservedLeft - NAME_PADDING_X, -15 - NAME_PADDING_Y)
                  e.Name.Size = UDim2.fromOffset(size.X + NAME_PADDING_X*2, 14 + NAME_PADDING_Y*2)
                  e.Name.Visible = flags[class .. 'Names']
                  e.Name.TextColor3 = flags[class .. 'NameColor'].Color
  
                  e.OuterBox.Position = UDim2.fromOffset(-OUTLINE, -OUTLINE)
                  e.OuterBox.Size = UDim2.fromOffset(size.X + OUTLINE*2, size.Y + OUTLINE*2)
                  sizeSides(e.OuterSides, size.X + OUTLINE*2, size.Y + OUTLINE*2, OUTLINE)
  
                  e.GradBox.Position = UDim2.fromOffset(0,0)
                  e.GradBox.Size = UDim2.fromOffset(size.X, size.Y)
                  sizeSides(e.GradSides, size.X, size.Y, BOX_THICKNESS)
  
                  e.InnerBox.Position = UDim2.fromOffset(OUTLINE, OUTLINE)
                  e.InnerBox.Size = UDim2.fromOffset(size.X - OUTLINE*2, size.Y - OUTLINE*2)
                  sizeSides(e.InnerSides, size.X - OUTLINE*2, size.Y - OUTLINE*2, OUTLINE)
  
                  local on = flags[class .. 'Boxes']
                  e.OuterBox.Visible = on
                  e.GradBox.Visible = on
                  e.InnerBox.Visible = on
  
                  for _, g in ipairs(e.Gradients) do
                      g.Color = ColorSequence.new({
                          ColorSequenceKeypoint.new(0, flags[class .. 'BoxColor1'].Color),
                          ColorSequenceKeypoint.new(1, flags[class .. 'BoxColor2'].Color),
                      })
                  end
  
                  e.HealthBack.Visible = flags[class .. 'Health']
                  e.HealthBack.Position = UDim2.fromOffset(reservedLeft - barW - gap, 0)
                  e.HealthBack.Size = UDim2.fromOffset(barW, size.Y)
  
                  e.HealthOutline.Position = UDim2.fromOffset(0,0)
                  e.HealthOutline.Size = UDim2.fromOffset(barW, size.Y)
  
                  e.HealthInner.Position = UDim2.fromOffset(1,1)
                  e.HealthInner.Size = UDim2.fromOffset(barW - 2, size.Y - 2)
  
                  e.HealthFillHolder.Position = UDim2.fromOffset(0,0)
                  e.HealthFillHolder.Size = UDim2.fromScale(1,1)
  
                  local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                  e.HealthFill.Size = UDim2.fromScale(1, hp)
  
                  e.HealthGradient.Color = ColorSequence.new({
                      ColorSequenceKeypoint.new(0, flags[class .. 'HealthColor1'].Color),
                      ColorSequenceKeypoint.new(0.5, flags[class .. 'HealthColor2'].Color),
                      ColorSequenceKeypoint.new(1, flags[class .. 'HealthColor3'].Color),
                  })
  
                  if e.Cham then
                      if flags[class .. 'Chams'] then
                          e.Cham.Enabled = true
                          e.Cham.FillColor = flags[class .. 'ChamsColor1'].Color
                          e.Cham.OutlineColor = flags[class .. 'ChamsColor2'].Color
                          e.Cham.FillTransparency = flags[class .. 'ChamsColor1'].Transparency or 0.5
                          e.Cham.OutlineTransparency = flags[class .. 'ChamsColor2'].Transparency or 0
                      else
                          e.Cham.Enabled = false
                      end
                  end
  
                  e.Distance.Position = UDim2.fromOffset(reservedLeft, size.Y + 6)
                  e.Distance.Size = UDim2.fromOffset(size.X, 14)
                  e.Distance.Visible = flags[class .. 'Distance']
                  e.Distance.Text = math.floor(distance) .. ' studs'
                  e.Distance.TextColor3 = flags[class .. 'DistanceColor'].Color
  
                  e.Weapon.Position = UDim2.fromOffset(reservedLeft, size.Y + 20)
                  e.Weapon.Size = UDim2.fromOffset(size.X, 14)
                  e.Weapon.Visible = flags[class .. 'Weapon']
                  e.Weapon.Text = `[{getgun(char)}]`
                  e.Weapon.TextColor3 = flags[class .. 'WeaponColor'].Color
              end
          end)
  
          local function hookPlayer(p)
              if p == Client then return end
              p.CharacterAdded:Connect(function(c) createESP(c, p.Name, 'Players') end)
              p.CharacterRemoving:Connect(function(c) 
                  local e = ESP[c]
                  if e then 
                      e.Holder:Destroy() 
                      ESP[c] = nil
                      if e.Cham then
                          e.Cham:Destroy()
                      end
                  end 
              end)
              if p.Character then 
                  createESP(p.Character, p.Name, 'Players') 
              end
          end
  
          for _, p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
          Players.PlayerAdded:Connect(hookPlayer)
          Players.PlayerRemoving:Connect(function(p)
              if p.Character and ESP[p.Character] then 
                  local e = ESP[p.Character]
                  e.Holder:Destroy()
                  ESP[p.Character]=nil 
                  if e.Cham then
                      e.Cham.Enabled = false
                  end
              end
          end)
  
          local SoldierClassType = {
              Brutus = "Boss",
              Bruno = "Boss",
              BTR = "Boss",
              Boris = "Boss",
              Soldier = "AI",
          }
  
          local Military = workspace:FindFirstChild('Military')
          local Events = workspace:FindFirstChild('Events')
  
          if Military and Events then
              local function CacheSoldier(model)
                  if (not model) or (not model.Parent) then return end
                  local classType = SoldierClassType[model.Name]
                  if not classType then return end
                  if ESP[model] then return end
                  createESP(model, model.Name, classType)
              end
  
              local function OnModelAdded(model)
                  task.defer(function()
                      if model and model.Parent then
                          CacheSoldier(model)
                      end
                  end)
              end
  
              local function OnModelRemoved(model)
                  if model and ESP[model] then ESP[model].Holder:Destroy() ESP[model]=nil end
              end
  
              for _, obj in ipairs(Events:GetChildren()) do
                  if obj.Name == 'BTR' then
                      CacheSoldier(obj)
                  end
              end
  
              Events.ChildAdded:Connect(function(obj)
                  if obj.Name == 'BTR' then
                      OnModelAdded(obj)
                  end
              end)
  
              Events.ChildRemoved:Connect(function(obj)
                  if obj.Name == 'BTR' then
                      OnModelRemoved(obj)
                  end
              end)
  
              for _, folder in ipairs(Military:GetChildren()) do
                  for _, soldier in ipairs(folder:GetChildren()) do
                      if soldier:IsA('Model') then
                          CacheSoldier(soldier)
                      end
                  end
  
                  folder.ChildAdded:Connect(function(soldier)
                      if soldier:IsA('Model') then
                          OnModelAdded(soldier)
                      end
                  end)
  
                  folder.ChildRemoved:Connect(function(soldier)
                      if soldier:IsA('Model') then
                          OnModelRemoved(soldier)
                      end
                  end)
              end
          end
      end
  
      --// Fov Circle
      do
          local FovCircleOutline = Drawing.new('Circle')
          FovCircleOutline.Visible = false
          FovCircleOutline.NumSides = 64
          FovCircleOutline.ZIndex = 9
          FovCircleOutline.Filled = false
          FovCircleOutline.Transparency = 1
          FovCircleOutline.Radius = 200
          FovCircleOutline.Thickness = 4
          FovCircleOutline.Color = Color3.fromRGB(0, 0, 0)
  
          local FovCircle = Drawing.new('Circle')
          FovCircle.Visible = false
          FovCircle.NumSides = 64
          FovCircle.ZIndex = 10
          FovCircle.Filled = false
          FovCircle.Transparency = 1
          FovCircle.Radius = 200
          FovCircle.Thickness = 2
          FovCircle.Color = Color3.fromRGB(255, 20, 147)
  
          local textHolder = Instance.new('Frame')
          textHolder.BackgroundTransparency = 1
          textHolder.BorderSizePixel = 0
          textHolder.ZIndex = 3
          textHolder.AnchorPoint = Vector2.new(0.5, 0)
          textHolder.Size = UDim2.fromOffset(0, 0)
          textHolder.Position = UDim2.new(0.5, 0, 0.5, 10)
          textHolder.AutomaticSize = Enum.AutomaticSize.XY
          textHolder.Visible = true
          textHolder.Parent = gethui()
  
          local layout = Instance.new('UIListLayout')
          layout.FillDirection = Enum.FillDirection.Vertical
          layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
          layout.VerticalAlignment = Enum.VerticalAlignment.Top
          layout.Padding = UDim.new(0, 2)
          layout.Parent = textHolder
  
          local manipulationText = Instance.new('TextLabel')
          manipulationText.BackgroundTransparency = 1
          manipulationText.Size = UDim2.fromOffset(0, 0)
          manipulationText.AutomaticSize = Enum.AutomaticSize.XY
          manipulationText.TextWrapped = false
          manipulationText.FontFace = Library.Font
          manipulationText.TextSize = 12
          manipulationText.TextColor3 = Color3.new(1, 1, 1)
          manipulationText.TextStrokeTransparency = 0.6
          manipulationText.ZIndex = textHolder.ZIndex
          manipulationText.Parent = textHolder
  
          local visibleText = Instance.new('TextLabel')
          visibleText.BackgroundTransparency = 1
          visibleText.Size = UDim2.fromOffset(0, 0)
          visibleText.AutomaticSize = Enum.AutomaticSize.XY
          visibleText.TextWrapped = false
          visibleText.FontFace = Library.Font
          visibleText.TextSize = 12
          visibleText.TextColor3 = Color3.new(1, 1, 1)
          visibleText.TextStrokeTransparency = 0.6
          visibleText.ZIndex = textHolder.ZIndex
          visibleText.Parent = textHolder
  
          RunService.RenderStepped:Connect(function()
              local radius = flags.FovSize or 200
              local thickness = flags.FovThickness or 2
  
              local vp = Camera.ViewportSize
              local pos = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
  
              -- local yOff = math.floor(radius + (thickness) + (textHolder.AbsoluteSize.Y > 0 and 0 or 0))
              -- textHolder.Position = UDim2.fromOffset(math.floor(pos.X), math.floor(pos.Y + yOff))
  
              if flags.CombatIndicators then
                  if Targeting.ManipulatedPosition then
                      manipulationText.Text = 'Manipulated'
                      manipulationText.TextColor3 = flags.ManipulationIndicatorColor.Color
                      manipulationText.Visible = true
                  else
                      manipulationText.Visible = false
                  end
                  
                  if Targeting.TargetObject and Targeting.TargetObject.CoreInformation and Targeting.TargetObject.CoreInformation.Visible then
                      visibleText.Text = "Visible"
                      visibleText.TextColor3 = flags.VisibleIndicatorColor.Color
                      visibleText.Visible = true
                  else
                      visibleText.Visible = false
                  end
              else
                  manipulationText.Visible = false
                  visibleText.Visible = false
              end
  
              if (not flags.FovEnabled) then
                  FovCircle.Visible = false
                  FovCircleOutline.Visible = false
                  return
              end
  
              local col = flags.FovColor
  
              FovCircle.Position = pos
              FovCircleOutline.Position = pos
  
              FovCircle.Radius = radius
              FovCircleOutline.Radius = radius
  
              FovCircle.Thickness = thickness
              FovCircleOutline.Thickness = thickness + 2
  
              if col then
                  FovCircle.Color = col.Color
                  FovCircle.Transparency = (col.Transparency or 0)
                  FovCircleOutline.Transparency = FovCircle.Transparency
              end
  
              FovCircle.Filled = (flags.FovFilled == true)
              FovCircleOutline.Filled = false
  
  
              FovCircle.Visible = true
              FovCircleOutline.Visible = true
          end)
      end
  



      --// Ambience
      do
          local folder = Instance.new('Folder')
          folder.Parent = workspace
  
          local chunks = {}
          local lights = {}
          local bases = {}
  
          local rayParams = RaycastParams.new()
          rayParams.FilterType = Enum.RaycastFilterType.Blacklist
          rayParams.FilterDescendantsInstances = { folder }
  
          local function key(cx, cy, cz)
              return cx .. ':' .. cy .. ':' .. cz
          end
  
      local classify = function(pos)
          return Workspace:Raycast(pos, Vector3.new(0, 200, 0), rayParams) ~= nil
              and 'Indoor'
              or 'Outdoor'
      end
  
  local createNode = LPH_NO_VIRTUALIZE(function(pos)
              local p = Instance.new('Part')
              p.Size = Vector3.new(0.1, 0.1, 0.1)
              p.Anchored = true
              p.CanCollide = false
              p.Transparency = 1
              p.CFrame = CFrame.new(pos)
              p.Parent = folder
  
              local l = Instance.new('PointLight')
              l.Range = 140
              l.Shadows = false
  
              local t = classify(pos)
              local base =
                  (t == 'Indoor' and flags.AmbienceIndoorBrightness)
                  or flags.AmbienceBrightness
  
              l.Brightness = base
              l.Parent = p
  
              lights[l] = true
              bases[l] = base
  
              if flags.AmbienceEnabled then
                  l.Color = flags.AmbienceColor.Color
              end
  
              return p
          end)
  
  local buildChunk = LPH_NO_VIRTUALIZE(function(cx, cy, cz)
              local k = key(cx, cy, cz)
              if chunks[k] then return end
  
              local group = {}
              local basePos = Vector3.new(cx * 150, cy * 150, cz * 150)
  
              for x = 0, 150, 100 do
                  for y = 0, 150, 100 do
                      for z = 0, 150, 100 do
                          group[#group + 1] =
                              createNode(basePos + Vector3.new(x, y, z))
                      end
                  end
              end
  
              chunks[k] = group
          end)
  
  local destroyChunk = LPH_NO_VIRTUALIZE(function(k)
              local group = chunks[k]
              if not group then return end
              for i = 1, #group do
                  group[i]:Destroy()
              end
              chunks[k] = nil
          end)
  
          folder.DescendantRemoving:Connect(function(d)
              if d:IsA('PointLight') then
                  lights[d] = nil
                  bases[d] = nil
              end
          end)
  
  local sceneLuminance = LPH_NO_VIRTUALIZE(function()
              local t = Lighting.ClockTime
              local sun = math.clamp(
                  math.cos((t - 14) / 24 * math.pi * 2) * -0.5 + 0.5,
                  0,
                  1
              )
  
              local amb =
                  (Lighting.Ambient.R + Lighting.Ambient.G + Lighting.Ambient.B) / 3
  
              return math.max(
                  0.05,
                  (sun * 0.7 + amb * 0.3) * (2 ^ Lighting.ExposureCompensation)
              )
          end)
  
          local recomputeBases = LPH_NO_VIRTUALIZE(function()
              for light in pairs(lights) do
                  if (light.Parent) then
                      local t = light:GetAttribute('AmbienceType')
                      bases[light] =
                          (t == 'Indoor' and flags.AmbienceIndoorBrightness)
                          or flags.AmbienceBrightness
                  end
              end
          end)
  
          local lastCenter
          local scale = 1
          local lastAppliedScale = 1
          local acc = 0
          local savedflags = {
              AmbienceBrightness = flags.AmbienceBrightness,
              AmbienceIndoorBrightness = flags.AmbienceIndoorBrightness,
              AmbienceEnabled = flags.AmbienceEnabled,
              AmbienceColor = {
                  Color = flags.AmbienceColor.Color
              }
          }
  
          RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function(dt)
              local cam = Workspace.CurrentCamera
              if not cam then return end
  
              local pos = cam.CFrame.Position
              local center = Vector3.new(
                  math.floor(pos.X / 150),
                  math.floor(pos.Y / 150),
                  math.floor(pos.Z / 150)
              )
  
              if not lastCenter or center ~= lastCenter then
                  lastCenter = center
                  local needed = {}
  
                  for x = -2, 2 do
                      for y = -2, 2 do
                          for z = -2, 2 do
                              local k = key(center.X + x, center.Y + y, center.Z + z)
                              needed[k] = true
                              buildChunk(center.X + x, center.Y + y, center.Z + z)
                          end
                      end
                  end
  
                  for k in pairs(chunks) do
                      if not needed[k] then
                          destroyChunk(k)
                      end
                  end
  
                  acc = 0.11
              end
  
              acc = acc + dt
              if acc < 0.2 then return end
              acc = 0
  
              local desired = math.clamp(1.0 / sceneLuminance(), 0.25, 1.6)
              scale = scale + (desired - scale) * 0.6
  
              local flagschanged = false
  
              if (savedflags.AmbienceBrightness ~= flags.AmbienceBrightness) then
                  savedflags.AmbienceBrightness = flags.AmbienceBrightness
                  flagschanged = true
              end
  
              if (savedflags.AmbienceIndoorBrightness ~= flags.AmbienceIndoorBrightness) then
                  savedflags.AmbienceIndoorBrightness = flags.AmbienceIndoorBrightness
                  flagschanged = true
              end
  
              if (savedflags.AmbienceEnabled ~= flags.AmbienceEnabled) then
                  savedflags.AmbienceEnabled = flags.AmbienceEnabled
                  flagschanged = true
              end
  
              if (savedflags.AmbienceColor.Color ~= flags.AmbienceColor.Color) then
                  savedflags.AmbienceColor.Color = flags.AmbienceColor.Color
                  flagschanged = true
              end
  
              if (flagschanged) then
                  recomputeBases()
                  lastAppliedScale = -1
              end
  
                        if math.abs(scale - lastAppliedScale) < 0.02 then
                          return
                      end

                      lastAppliedScale = scale

                      for light in pairs(lights) do
                          if light.Parent then
                              if flags.AmbienceEnabled then
                                  light.Brightness = bases[light] * scale
                                  light.Color = flags.AmbienceColor.Color
                              else
                                  light.Brightness = 0
                              end
                          end
                      end
                  end))
              end

              --//Fog
              do
                  local LightingOrig = { FogEnd = Lighting.FogEnd };
                  local AtmosphereOrig = {};

                  RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
                      local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere");
                      if atmosphere and not AtmosphereOrig[atmosphere] then
                          AtmosphereOrig[atmosphere] = {
                              Density = atmosphere.Density,
                              Offset = atmosphere.Offset,
                              Glare = atmosphere.Glare,
                              Haze = atmosphere.Haze,
                              Color = atmosphere.Color,
                              Decay = atmosphere.Decay
                          };
                      end;

                      if flags.RemoveFog then
                          Lighting.FogEnd = 100000;
                          if atmosphere then
                              atmosphere.Density = 0;
                              atmosphere.Offset = 0;
                              atmosphere.Glare = 0;
                              atmosphere.Haze = 0;
                          end;
                      else
                          Lighting.FogEnd = LightingOrig.FogEnd;
                          if atmosphere and AtmosphereOrig[atmosphere] then
                              local orig = AtmosphereOrig[atmosphere];

                              if flags.ChangeFogDensity then
                                  atmosphere.Density = flags.FogDensity;
                              else
                                  atmosphere.Density = orig.Density;
                              end;

                              if flags.ChangeFogGlare then
                                  atmosphere.Glare = flags.FogGlare;
                              else
                                  atmosphere.Glare = orig.Glare;
                              end;

                              if flags.ChangeFogHaze then
                                  atmosphere.Haze = flags.FogHaze;
                              else
                                  atmosphere.Haze = orig.Haze;
                              end;

                              if flags.ChangeFogColor and flags.FogColor then
                                  atmosphere.Color = flags.FogColor.Color;
                              else
                                  atmosphere.Color = orig.Color;
                              end;

                              if flags.ChangeFogDecay and flags.FogDecay then
                                  atmosphere.Decay = flags.FogDecay.Color;
                              else
                                  atmosphere.Decay = orig.Decay;
                              end;

                              atmosphere.Offset = orig.Offset;
                          end;
                      end;
                  end))
              end

              --// Armor Bar
      do
          local textureToInfoMap = {}
          local GunTable = {}
          for _, gun in next, ItemsModule do
              if typeof(gun.Image) == 'table' then
                  GunTable[gun.Name] = gun.Image
              else
                  GunTable[gun.Name] = {['Default'] = gun.Image}
              end
          end
  
          for _, gunModel in ReplicatedStorage:WaitForChild("VMs"):GetChildren() do
              for _, skinModel in gunModel:GetChildren() do
                  local weaponFolder = skinModel:FindFirstChild("Weapon")
                  if weaponFolder and weaponFolder:IsA("Folder") then
                      for _, part in weaponFolder:GetChildren() do
                          local textureId = nil
                          pcall(function()
                              textureId = part.TextureID
                          end)
                          if textureId then
                              textureToInfoMap[textureId] = {
                                  gun = gunModel.Name,
                                  skin = skinModel.Name,
                              }
                          end
                      end
                  end
              end
          end
  
  local GetArmor = LPH_NO_VIRTUALIZE(function(Character)
              local final = {}
              local names = {}
              if not Character then return {} end
              if type(Character) == 'string' then
                  return {}
              end
              for _, child in Character:GetChildren() do
                  local armorNumber, skinName = child.Name:match('Armor_(%d+)/(.*)')
  
                  if armorNumber then
                      local key = tonumber(armorNumber)
                      if key then
                          local item = ItemsModule[key]
                          if item and item.Type == 'Armor' and not table.find(names, item.Name) then
                              local image = ''
                              if type(item.Image) == 'table' then
                                  if skinName and item.Image[skinName] then
                                      image = item.Image[skinName]
                                  elseif item.Image.Default then
                                      image = item.Image.Default
                                  end
                              elseif type(item.Image) == 'string' then
                                  image = item.Image
                              end
  
                              local id = string.match(image or '', '%d+')
                              local imageData = ''
  
                              table.insert(names, item.Name)
                              table.insert(final, {
                                  ['Skin'] = skinName,
                                  ['Name'] = item.Name,
                                  ['Type'] = item.ArmorType,
                                  ['Image'] = id
                              })
                          end
                      end
                  end
              end
  
              return final
          end)
  
          local lastarmor = ''
          RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
              ArmorViewer:SetVisibility(flags.ArmorBarEnabled and Targeting.TargetCharacter)
              if not flags.ArmorBarEnabled then return end
              local character = Targeting.TargetCharacter
              if not character then return end
              local armorData = GetArmor(character)
              local armorhash = HttpService:JSONEncode(armorData)
              if armorhash ~= lastarmor then
                  lastarmor = armorhash
                  ArmorViewer:ClearAllItems()
                  ArmorViewer:SetTitle(`{character.Name}'s inventory`)
                  for i, armor in ipairs(armorData) do
                      local imageUrl = ''
                      if armor.Image and tonumber(armor.Image) then
                          imageUrl = 'rbxassetid://' .. tostring(armor.Image)
                      elseif armor.Skin and GunTable[armor.Name] and GunTable[armor.Name][armor.Skin] then
                          imageUrl = GunTable[armor.Name][armor.Skin]
                      elseif GunTable[armor.Name] and GunTable[armor.Name]['Default'] then
                          imageUrl = GunTable[armor.Name]['Default']
                      end
  
                      ArmorViewer:Add(armor.Name, imageUrl)
                  end
              end
          end))
      end
  
      --// Misc ESP
      do
          local miscCache = {}
          local worldToViewportPoint = Camera.WorldToViewportPoint
  
          local ScreenGui = Instance.new('ScreenGui')
          ScreenGui.IgnoreGuiInset = true
          ScreenGui.Parent = gethui()
  
          local function espify(obj, staticname, manualflag)
              if not obj or miscCache[obj] then return end
  
              local flag = manualflag or obj.Name:gsub('_Node$', '')
  
              local label = Instance.new('TextLabel')
              label.BackgroundTransparency = 1
              label.TextSize = 12
              label.FontFace = Library.Font
              label.TextColor3 = Color3.new(1, 1, 1)
              label.AnchorPoint = Vector2.new(0.5, 0.5)
              label.AutomaticSize = Enum.AutomaticSize.XY
              label.Size = UDim2.fromOffset(0, 0)
              label.Visible = false
              label.Parent = ScreenGui
  
              local stroke = Instance.new('UIStroke')
              stroke.Thickness = 1
              stroke.Color = Color3.new(0, 0, 0)
              stroke.Parent = label
  
              miscCache[obj] = {
                  obj = obj,
                  label = label,
                  stroke = stroke,
                  flag = flag,
                  staticname = staticname
              }
          end
  
  
          local function removeEsp(obj)
              local data = miscCache[obj]
              if data then
                  data.label:Destroy()
                  miscCache[obj] = nil
              end
          end
  
          local nodes = workspace:FindFirstChild('Nodes')
          local bases = workspace:FindFirstChild('Bases')
  
          if nodes then
              local function addNode(v)
                  if v:IsA('BasePart') or v:IsA('Model') then
                      espify(v)
                  end
              end
  
              for _, v in nodes:GetChildren() do
                  addNode(v)
              end
  
              nodes.ChildAdded:Connect(addNode)
              nodes.ChildRemoved:Connect(removeEsp)
          end
  
          if bases then
                local function handleObject(obj)
                    if obj:IsA('Model') and (obj.Name == 'Care Package' or obj.Name == 'Salvaged Flycopter' or obj.Name == 'Body Bag' or obj.Name == 'Auto Turret' or obj.Name == 'Shotgun Turret') then
                        espify(obj)
                    end
                end

                local function handleFolder(folder)
                    for _, obj in folder:GetChildren() do
                        handleObject(obj)
                    end
                    folder.ChildAdded:Connect(handleObject)
                end

                for _, base in bases:GetChildren() do
                    for _, folder in base:GetChildren() do
                        handleFolder(folder)
                    end
                    base.ChildAdded:Connect(handleFolder)
                end
            end

            if Drops then Drops.ChildRemoved:Connect(removeEsp) end
            if Plants then Plants.ChildRemoved:Connect(removeEsp) end

            if Drops and Plants then
                RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
                  if not flags.MiscEnabledESP then return end
                  for _, item in pairs(Drops:GetChildren()) do
                      if item:IsA('Model') and not miscCache[item] then
                          local distance = (Camera.CFrame.Position - item:GetPivot().Position).Magnitude
                          if distance <= flags.DropsMaxDistance then
                              espify(item, item.Name, 'Drops')
                          end
                      end
                  end
                  for _, plant in pairs(Plants:GetChildren()) do
                      if plant:IsA('Model') and not miscCache[plant] then
                          local name = string.gsub(plant.Name, ' Plant', '')
                          local distance = (Camera.CFrame.Position - plant:GetPivot().Position).Magnitude
  
                          if name == 'Wool' and distance <= flags.WoolMaxDistance then
                              espify(plant, 'Wool', 'Wool')
                          end
                      end
                  end
              end))
          end
  
          if Animals then
              for _, animal in pairs(Animals:GetChildren()) do
                  if animal:IsA('Model') then
                      local name = animal.Name:lower():gsub('prefab_animal_', ''):gsub('_', ' ')
                      espify(animal, name, 'Animals')
                  end
              end
              Animals.ChildAdded:Connect(function(animal)
                  if animal:IsA('Model') then
                      local name = animal.Name:lower():gsub('prefab_animal_', ''):gsub('_', ' ')
                      espify(animal, name, 'Animals')
                  end
              end)
              Animals.ChildRemoved:Connect(removeEsp)
          end
  
          local step = 1 / 60
          local lastTick = tick()
          
          local function getWorldPosition(obj)
              if obj:IsA('BasePart') then
                  return obj.Position
              elseif obj:IsA('Model') then
                  return obj:GetPivot().Position
              end
          end
  
          RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
              local now = tick()
              if now - lastTick < step then return end
              lastTick = now
  
              local miscEnabled = flags.MiscEnabledESP
              local camPos = Camera.CFrame.Position
  
              for obj, data in pairs(miscCache) do
                  if not obj or not obj.Parent then
                      data.label:Destroy()
                      miscCache[obj] = nil
                      continue
                  end
  
                  if not miscEnabled or not flags[data.flag .. 'Enabled'] then
                      data.label.Visible = false
                      continue
                  end
  
                  local worldPos
                  if obj:IsA('BasePart') then
                      worldPos = obj.Position
                  else
                      worldPos = obj:GetPivot().Position
                  end
  
                  local screenPos, onScreen = worldToViewportPoint(Camera, worldPos)
                  if not onScreen then
                      data.label.Visible = false
                      continue
                  end
  
                  local dist = (camPos - worldPos).Magnitude
                  if dist > flags[data.flag .. 'MaxDistance'] then
                      data.label.Visible = false
                      continue
                  end
                  local name = data.staticname or data.flag
                  
                  data.label.Visible = true
                  data.label.Position = UDim2.fromOffset(screenPos.X, screenPos.Y)
                  data.label.Text = string.format('%s \n%.1f Studs', name, dist)
  
                  local col = flags[data.flag .. 'Color']
                  if col then
                      data.label.TextColor3 = col.Color
                  end
              end
          end))
      end
  end
  --// Targeting
  do
      Cheat.Globals.RaycastParams = RaycastParams.new()
      Cheat.Globals.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
      Cheat.Globals.RaycastParams.IgnoreWater = true
  
  local IsPartVisible = LPH_NO_VIRTUALIZE(function(Part, Origin)
          if not Part then return false end
          local Head = Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild('Head')
          if not Head then return false end
          Origin = Origin or Head.CFrame.Position
          local to = Part.CFrame.Position
          local dir = (to - Origin)
          local RayResult = workspace:Raycast(Origin, dir, Cheat.Globals.RaycastParams)
          if not RayResult then return true end
          local inst = RayResult.Instance
          return inst and inst:IsDescendantOf(Part.Parent) or false
      end)
  
  local GetDistanceFromCenter = LPH_NO_VIRTUALIZE(function(part)
          local position = part
          if typeof(part) == "Instance" then position = part.CFrame.Position end
          local sp, on = Camera:WorldToViewportPoint(position)
          if not on then return math.huge end
          local c = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
          return (c - Vector2.new(sp.X, sp.Y)).Magnitude
      end)
  
      local vectors = {
          Vector3.new(0.5, 0, 0), Vector3.new(-0.5, 0, 0),
          Vector3.new(0, 0, 0.5), Vector3.new(0, 0, -0.5),
          Vector3.new(0, 0.5, 0), Vector3.new(0, -0.5, 0),
          Vector3.new(0.5, 0.5, 0), Vector3.new(0.5, -0.5, 0),
          Vector3.new(-0.5, 0.5, 0), Vector3.new(-0.5, -0.5, 0),
          Vector3.new(0, 0.5, 0.5), Vector3.new(0, -0.5, 0.5),
          Vector3.new(0, 0.5, -0.5), Vector3.new(0, -0.5, -0.5),
          Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
          Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
          Vector3.new(0, 1, 0), Vector3.new(0, -1, 0),
      }
  
      local manipOffsets = {
          Vector3.new( 3, 0, 0), Vector3.new(-3, 0, 0),
          Vector3.new( 6, 0, 0), Vector3.new(-6, 0, 0),
          Vector3.new( 4, 0, 0), Vector3.new(-4, 0, 0),
          Vector3.new( 3, 2, 0), Vector3.new(-3, 2, 0),
          Vector3.new( 6, 2, 0), Vector3.new(-6, 2, 0),
          Vector3.new( 4, 2, 0), Vector3.new(-4, 2, 0),
          Vector3.new( 0.2, 3.9, 0),
          Vector3.new( 1.8, 4.1, 1),
          Vector3.new( 2.1, 4.4, 1.1),
          Vector3.new( 0.15, 5.2, 0.1),
          Vector3.new(-1.8, 5.4,-0.2),
          Vector3.new(-2.3, 6.0,-0.4),
          Vector3.new( 0.1, 6.0, 0.0),
          Vector3.new( 7, 0, 0), Vector3.new(-7, 0, 0),
          Vector3.new( 7, 2, 0), Vector3.new(-7, 2, 0),
          Vector3.new( 0.1, 7.5, 0.0),
          Vector3.new( 0.1, 8.0, 0.0),
      }
  
  local is_cframe_visible = LPH_NO_VIRTUALIZE(function(cfrom, cto)
          if not (cfrom and cto) then return false end
          local hit = workspace:Raycast(cfrom.Position, cto.Position - cfrom.Position, Cheat.Globals.RaycastParams)
          return not hit
      end)
  
  local is_part_visible = LPH_NO_VIRTUALIZE(function(originCF, target_part)
          if not (originCF and target_part) then return false end
          
          if typeof(originCF) == 'Vector3' then
              originCF = CFrame.new(originCF)
          elseif typeof(originCF) ~= 'CFrame' then
              return false
          end
  
          local originPos = originCF.Position
          local targetPos = target_part:GetPivot().Position
          local direction = targetPos - originPos
  
          local hit = workspace:Raycast(originPos, direction, Cheat.Globals.RaycastParams)
          if not hit then return true end
          return hit.Instance and hit.Instance.Parent == target_part.Parent or false
      end)
  
  local FindVisiblePosition = LPH_NO_VIRTUALIZE(function(Origin, Destination)
          local o = (typeof(Origin) == 'CFrame') and Origin or CFrame.new(Origin)
          for i = 1, #manipOffsets do
              local pos = o * manipOffsets[i]
              if IsPartVisible(Destination, pos) then
                  return pos
              end
          end
          return nil
      end)
  
      RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
          debug.profilebegin("Targeting Loop")
          Cheat.Globals.RaycastParams.FilterDescendantsInstances = {
              Camera, Cheat.Globals.ClientCharacter,
              workspace:FindFirstChild("VFX"),
              workspace:FindFirstChild("RocketFactoryPinkCardInvisWalls")
          }
  
          local Silent = (flags.AimbotEnabled) or false
          local TargetParts = flags.TargetParts or {'Head'}
          if not TargetParts or #TargetParts == 0 then return end
          local DesiredPartName = TargetParts[math.random(#TargetParts)] or "Head"
          local ManipulationActive = Silent and (flags.Manipulation == true) or false
          local UseVisibleCheck = flags.VisibleCheck == true
          local DownCheck = flags.DownCheck == true
          local ClosestDistance = (flags.FovSize or 0)
  
          local ClosestTarget = nil
          local EntityCharacter = nil
          local EntityData = nil
          local EntityInstance = nil
          local Manipulated = false
          local Visible = false
          local ManipulatedPart, ManipulatedPosition, ManipulatedPlayer = nil, nil, nil
          
          local now = tick()
  
          for Entity, Object in pairs(Targeting.Targets) do
              if not Object then continue end
              if not Object.Character or not Object.Character.Parent then
                  Object.Character = (Object.Class == "Player" and Object.Player.Character) or nil
              end
  
              local character = Object.Character
              if not character or not character.Parent then
                  Object.CoreInformation = { Visible = false, OnScreen = false, Root = nil }
                  continue
              end
  
              if now - (Object.LastUpdate or 0) > 1/30 then
                  Object.LastUpdate = now
                  local Humanoid = character:FindFirstChildOfClass("Humanoid")
                  if Humanoid then Object.Humanoid = Humanoid end
                  if Object.Class == "Player" or Object.Class == "AI" then
                      Object.Root = (Humanoid and Humanoid.RootPart) or character:FindFirstChild("HumanoidRootPart")
                  end
                  if not Object.Root then
                      Object.Root = character:FindFirstChild("RootPart") or character:FindFirstChild("HumanoidRootPart")
                  end
  
                  local root = Object.Root
                  if not root then
                      Object.CoreInformation = { Visible = false, OnScreen = false, Root = nil }
                  elseif (Camera.CFrame.Position - root.Position).Magnitude > 2000 then
                      Object.CoreInformation = { Visible = false, OnScreen = false, Root = root }
                  else
                      local parts = character:GetChildren()
                      local inf = math.huge
                      local minx, miny, minz = inf, inf, inf
                      local maxx, maxy, maxz = -inf, -inf, -inf
                      local rc = root.CFrame
                      for _, Part in ipairs(parts) do
                          if Part:IsA("BasePart") then
                              local Cf = rc:ToObjectSpace(Part.CFrame)
                              local sx, sy, sz = Part.Size.X, Part.Size.Y, Part.Size.Z
                              local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Cf:components()
                              local wsx = 0.5 * (math.abs(R00) * sx + math.abs(R01) * sy + math.abs(R02) * sz)
                              local wsy = 0.5 * (math.abs(R10) * sx + math.abs(R11) * sy + math.abs(R12) * sz)
                              local wsz = 0.5 * (math.abs(R20) * sx + math.abs(R21) * sy + math.abs(R22) * sz)
                              minx = math.min(minx, X - wsx) ; miny = math.min(miny, Y - wsy) ; minz = math.min(minz, Z - wsz)
                              maxx = math.max(maxx, X + wsx) ; maxy = math.max(maxy, Y + wsy) ; maxz = math.max(maxz, Z + wsz)
                          end
                      end
                      local minv = Vector3.new(minx, miny, minz)
                      local maxv = Vector3.new(maxx, maxy, maxz)
                      local middle = (maxv + minv) * 0.5
                      local cf = rc - rc.Position + rc * middle
                      local half = (maxv - minv) * 0.5
                      local hx, hy, hz = math.min(half.X, 5), math.min(half.Y, 10), math.min(half.Z, 5)
                      local offsets = {
                          Vector3.new( hx,  hy,  hz), Vector3.new( hx,  hy, -hz),
                          Vector3.new( hx, -hy,  hz), Vector3.new( hx, -hy, -hz),
                          Vector3.new(-hx,  hy,  hz), Vector3.new(-hx,  hy, -hz),
                          Vector3.new(-hx, -hy,  hz), Vector3.new(-hx, -hy, -hz),
                      }
                      local on = false
                      for i = 1, 8 do
                          local _, s = Camera:WorldToViewportPoint(cf * offsets[i])
                          if s then on = true break end
                      end
  
                      if not on then
                          local head = character:FindFirstChild("Head")
                          local vis = head and IsPartVisible(head) or false
                          Object.CoreInformation = { Root = root, RootPosition = root.Position, OnScreen = false, Visible = vis, VisiblePart = vis and head or nil }
                      else
                          if character:FindFirstChild(DesiredPartName) and IsPartVisible(character[DesiredPartName]) then
                              Object.CoreInformation = { Visible = true, VisiblePart = character[DesiredPartName], Root = root, RootPosition = root.Position, OnScreen = on }
                              continue
                          end
                          local visPart = nil
                          local names = { "HumanoidRootPart", "RightLowerLeg", "LeftLowerLeg", "RightUpperArm", "LeftUpperArm" }
                          for _, n in ipairs(names) do
                              local p = character:FindFirstChild(n)
                              if p and p:IsA("BasePart") and IsPartVisible(p) then visPart = p break end
                          end
                          Object.CoreInformation = { Visible = visPart ~= nil, VisiblePart = visPart, Root = root, RootPosition = root.Position, OnScreen = on }
                      end
                  end
              end
  
              local Core = Object.CoreInformation
              if not flags.TargetTeammates and isTeam(Entity) then continue end
              if not (Core and Core.Root and Entity ~= Client) then continue end
              if not (Core.OnScreen and not Object.Teammate and flags.AimbotEnabled) then continue end
  
              local humanoid = character:FindFirstChildOfClass("Humanoid")
              if not humanoid or humanoid.Health <= 0 then continue end
              if DownCheck and humanoid:GetAttribute('Downed') then continue end
  
              local Distance = GetDistanceFromCenter(Core.Root)
              if Distance >= ClosestDistance then continue end
  
              local tpart = nil
              if UseVisibleCheck and Core.Visible then
                  tpart = Core.VisiblePart
              elseif not UseVisibleCheck then
                  tpart = character:FindFirstChild(DesiredPartName)
              end

              if character.Name == "BTR" then
                  tpart = character:FindFirstChild("HumanoidRootPart")
              end
  
              if tpart then
                  ClosestDistance = Distance
                  ClosestTarget  = tpart
                  EntityCharacter = character
                  EntityData      = Object
                  EntityInstance  = Entity
                  Visible         = Core.Visible
              end
          end
  
          if not Visible and Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild('Head') and ClosestTarget and EntityData then
              if now - (EntityData.LastManip or 0) > 0.1 then
                  EntityData.LastManip = now
                  
                  if ManipulationActive then
                      local vp = FindVisiblePosition(Cheat.Globals.ClientCharacter.Head.CFrame, ClosestTarget)
                      if vp then
                          Manipulated = true
                          ManipulatedPart = ClosestTarget
                          ManipulatedPosition = vp
                          ManipulatedPlayer = EntityData.Pointer
                      end
                  end
  
                  EntityData.LastManipCFG = {
                      Manipulated = Manipulated,
                      ManipulatedPosition = ManipulatedPosition,
                      ManipulatedPart = ManipulatedPart,
                      ManipulatedPlayer = ManipulatedPlayer,
                  }
              elseif EntityData.LastManipCFG then
                  Manipulated = EntityData.LastManipCFG.Manipulated
                  ManipulatedPosition = EntityData.LastManipCFG.ManipulatedPosition
                  ManipulatedPart = EntityData.LastManipCFG.ManipulatedPart
                  ManipulatedPlayer = EntityData.LastManipCFG.ManipulatedPlayer
              end
          end
  
          Targeting.TargetPart = ClosestTarget
          Targeting.TargetCharacter = EntityCharacter
          Targeting.TargetObject = EntityData
          Targeting.ManipulatedPosition = Manipulated and ManipulatedPosition or nil
          debug.profileend()
      end))
  
      for _, Player in ipairs(Players:GetPlayers()) do
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end
  
      Players.PlayerAdded:Connect(function(Player)
          if Player ~= Client then
              Targeting.Targets[Player] = {
                  Class = "Player",
                  Player = Player,
                  Character = Player.Character,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
          end
      end)
  
      Players.PlayerRemoving:Connect(function(Player)
          Targeting.Targets[Player] = nil
      end)
      
      local SoldierClassType = {
              Brutus = "Boss",
              Bruno = "Boss",
              BTR = "Boss",
              Boris = "Boss",
              Soldier = "AI",
        }
  
        local Military = workspace:FindFirstChild("Military")
        if Military then
              local Events = workspace:FindFirstChild("Events")
              local CacheSoldier = function(Soldier)
                    local ClassType = SoldierClassType[Soldier.Name]
                    if not ClassType then return end
              
              Targeting.Targets[Soldier] = {
                  Class = ClassType,
                  Player = Soldier,
                  Character = Soldier,
                  LastUpdate = 0,
                  Root = nil,
                  CoreInformation = { Visible = false, OnScreen = false, Root = nil },
              }
              end;
  
              for Index, BTR in Events:GetChildren() do
                    if BTR.Name == "BTR" then
                          CacheSoldier(BTR)
                    end;
              end;
  
                  Events.ChildAdded:Connect(function(BTR)
                          task.wait(1)
                          if BTR.Name == "BTR" then
                                CacheSoldier(BTR)
                          end;
                    end)

                    Events.ChildRemoved:Connect(function(BTR)
                          Targeting.Targets[BTR] = nil
                    end)

                    for _, Folder in Military:GetChildren() do
                          for Index, Soldier in Folder:GetChildren() do
                                if Soldier:IsA("Model") then
                                      CacheSoldier(Soldier)
                                end;
                          end;

                          Folder.ChildAdded:Connect(function(Soldier)
                                task.wait(1)
                                if Soldier:IsA("Model") then
                                      CacheSoldier(Soldier)
                                end;
                          end)

                          Folder.ChildRemoved:Connect(function(Soldier)
                                Targeting.Targets[Soldier] = nil
                          end)
                    end;
              end;
  end
  
  --// Misc
  do 
      setreadonly(math, false)
      local oldabs = math.abs
      math.abs = function(x)
          if flags.NoBob and isViewmodelContext() then
              for level = 2, 4 do
                  if isvalidlevel(level) then
                      local stack = getstack(level)
                      local v = stack and stack[2]
                      if type(v) == 'boolean' then
                          setstack(level, 2, true)
                      end
                  end
              end
          end

          return oldabs(x)
      end
      setreadonly(math, true)
  
      do --// Movement
          RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
              local Character = Cheat.Globals.ClientCharacter
              local Root = Character and Character:FindFirstChild("HumanoidRootPart")
              local Humanoid = Character and Character:FindFirstChild("Humanoid")
              local IsFlying
              if Humanoid and Root and Humanoid.Health > 0 then
                  if
                      flags.SpeedEnabled
                      and flags["SpeedBind"].active
                      and not IsFlying
                      and Root
                  then
                      local x, z = 0, 0
                      if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                          x += 1
                      end
                      if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                          x -= 1
                      end
                      if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                          z += 1
                      end
                      if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                          z -= 1
                      end
  
                      if x ~= 0 or z ~= 0 then
                          local cf = Root.CFrame
                          local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
                          local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit

                          local move = (right * x + forward * z).Unit
                          local hv = move * flags.SpeedSpeed
                          Root.Velocity = Vector3.new(hv.X, Root.Velocity.Y, hv.Z)
                      end
                  end
                  
                  if
                      (flags["FlightEnabled"] and flags["FlightBind"].active)
                  then
                      task.spawn(function()
                          IsFlying = true
                          if Humanoid and Humanoid.Health > 0 then
                              local Delta = dt * flags.FlightSpeed * 3
                              local MoveVector = Vector3.zero
  
                              local look = Camera.CFrame.LookVector
                              local right = Camera.CFrame.RightVector
  
                              if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                                  MoveVector += Vector3.new(look.X, 0, look.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                                  MoveVector -= Vector3.new(look.X, 0, look.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                                  MoveVector -= Vector3.new(right.X, 0, right.Z)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                                  MoveVector += Vector3.new(right.X, 0, right.Z)
                              end
  
                              if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                  MoveVector += Vector3.new(0, 1, 0)
                              end
                              if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                                  MoveVector += Vector3.new(0, -1, 0)
                              end
  
                              if MoveVector.Magnitude > 0 then
                                  MoveVector = MoveVector.Unit
                              end
  
                              local MovementDelta = MoveVector * Delta
                              local Position = Root.CFrame.Position + MovementDelta
  
                              Humanoid.PlatformStand = false
                              Root.Velocity = Vector3.zero
                              Root.CFrame = CFrame.new(Position, Position + Vector3.new(look.X, 0, look.Z))
                          end
                      end)
                  end
  
                  if
                      flags.Freecam
                      and flags["FreecamKeybind"]
                      and flags["FreecamKeybind"].active
                      and not IsFlying
                  then
                      task.spawn(function()
                          if not Root then
                              return
                          end
  
                          Cheat.Globals.NeedToReturn = true
  
                          local CameraLookVector = Camera.CFrame.LookVector
                          local NormalCameraLookVector = CameraLookVector
  
                          if not Cheat.Globals.SavedPosition then
                              Cheat.Globals.SavedPosition = Root.CFrame
                          end
  
                          sethiddenproperty(Root, "NetworkIsSleeping", true)
  
                          local UpPos = Vector3.new(0, 1, 0)
                          local DownPos = Vector3.new(0, -1, 0)
                          local NonePos = Vector3.new(0, 0, 0)
  
                          local BaseCFrame = Root.CFrame
                          local IsUpPressed = UserInputService:IsKeyDown(Enum.KeyCode.E)
                          local IsDownPressed = UserInputService:IsKeyDown(Enum.KeyCode.Q)
                          local IsForwardPressed = UserInputService:IsKeyDown(119) -- W
                          local IsBackwardPressed = UserInputService:IsKeyDown(115) -- S
  
                          Root.Anchored = true
                          Root.Velocity = NonePos
  
                          local Delta = dt * flags.FreecamSpeed * 3
  
                          local MovementVector = (
                              Humanoid.MoveDirection
                              + (IsUpPressed and UpPos or NonePos)
                              + (IsDownPressed and DownPos or NonePos)
                              + (IsForwardPressed and Vector3.new(0, NormalCameraLookVector.Y, 0) or NonePos)
                              + (IsBackwardPressed and Vector3.new(0, -NormalCameraLookVector.Y, 0) or NonePos)
                          ) * Delta
  
                          BaseCFrame += MovementVector
                          local Position = BaseCFrame.p
                          Root.CFrame = CFrame.new(Position, Position + Vector3.new(CameraLookVector.X, 0, CameraLookVector.Z))
                          Humanoid.AutoRotate = false
                      end)
                  else
                      if Cheat.Globals.NeedToReturn then
                          Humanoid.AutoRotate = true
                          Cheat.Globals.NeedToReturn = false
                          sethiddenproperty(Root, "NetworkIsSleeping", false)
  
                          for _, Value in Character:GetChildren() do
                              if Value:IsA("BasePart") then
                                  sethiddenproperty(Value, "NetworkIsSleeping", false)
                              end
                          end
  
                                  Root.CFrame = Cheat.Globals.SavedPosition
                                  Root.Anchored = false
                                  Cheat.Globals.SavedPosition = nil
                              end
                          end

                          if flags.NoFall and not IsFlying then
                              local Origin = Root.Position
                              local Result = workspace:Raycast(Origin, Vector3.new(0, -1000, 0), Cheat.Globals.RaycastParams)
  
                      if Result and Result.Distance > 10 then
                          task.spawn(function()
                              local OldVel = Root.Velocity
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = Vector3.new(0, 9999, 0)
                                  end
                              end
                              RunService.RenderStepped:Wait()
                              for _, Part in Character:GetChildren() do
                                  if Part:IsA("BasePart") then
                                      Part.Velocity = OldVel
                                  end
                              end
                          end)
                      end
                  end
              end
          end))
      end
  end
  
  --// Main Hooks
  do
      --// Silent Walk
      do
          -- Make sure sound_table exists (it should be from SoundModule)
          local sound_table = SoundModule or getrenv()._G.SoundTable -- fallback if needed

          if sound_table then
              local old_toggle_footstep = sound_table.ToggleFootstep
              sound_table.ToggleFootstep = LPH_NO_VIRTUALIZE(function(self, character, sound, playback_speed)
                  if flags["SilentWalk"] and sound then
                      return sound_table:StopSound(sound)
                  end
                  return old_toggle_footstep(self, character, sound, playback_speed)
              end)

              local old_play_sound = sound_table.PlaySound
              sound_table.PlaySound = LPH_NO_VIRTUALIZE(function(self, sound, is_duplicate, playback_speed)
                  if flags["SilentWalk"] and sound and (sound.Name:find("Walk") or sound.Name == "WalkWater") then
                      return sound_table:StopSound(sound)
                  end
                  return old_play_sound(self, sound, is_duplicate, playback_speed)
              end)
          end
      end
      RaycastUtil.Raycast = LPH_NO_VIRTUALIZE(function(self, ...)
          local Arguments = {...};
  
          if (not checkcaller()) then
              if (flags.Reach and isViewmodelContext()) then
                  Arguments[2] = Arguments[2] * 10
              end;
  
              if (flags.PerfectFarm) then
                  local Output = {OldRaycast(self, ...)};
                  local HitInstance  = Output[1];
                  local HitPosition = Output[2];
  
                  if (not HitInstance or typeof(HitInstance) ~= 'Instance') then
                      return unpack(Output);
                  end;
  
                  if (not HitPosition or typeof(HitPosition) ~= 'Vector3') then
                      return unpack(Output);
                  end;
  
                  local Model = HitInstance.Parent;
                  if (not Model or (not Model:IsA('Model'))) then
                      return unpack(Output);
                  end;
  
                  local Folder = Model.Parent;
                  if (Folder and (Folder.Name == 'Trees' or Folder.Name == 'Nodes') and Folder:IsA('Folder')) then
                      local CriticalPart = Model:FindFirstChild('NodeSpark') or Model:FindFirstChild('TreeX')
                      if (CriticalPart and typeof(CriticalPart) == 'Instance' and CriticalPart:IsA('Model') and CriticalPart.PrimaryPart) then
                          Output[1] = CriticalPart.PrimaryPart;
                          return unpack(Output);
                      end;
                  end;
              end;
          end;
  
          return OldRaycast(self, unpack(Arguments));
      end);
  
      local bullettracersbind = Instance.new('BindableEvent', game:GetService('ReplicatedStorage'))

              bullettracersbind.Event:Connect(LPH_NO_VIRTUALIZE(function(position)
                  if (not flags.BulletTracers) then
              return;
          end;
  
          local character = Client.Character;
          if (not character) then
              return;
          end;
  
          local head = character:FindFirstChild('Head');
          if (not head) then
              return;
          end;
  
          local att0 = Instance.new('Attachment');
          att0.Name = 'IgnoreMe';
          att0.WorldPosition = head.Position;
          att0.Parent = VMs;
  
          local att1 = Instance.new('Attachment');
          att1.Name = 'IgnoreMe';
          att1.WorldPosition = position;
          att1.Parent = VMs;
  
          local beam = Instance.new('Beam');
          beam.Name = 'IgnoreMe';
          beam.Attachment0 = att0;
          beam.Attachment1 = att1;
          beam.Transparency = NumberSequence.new({
              NumberSequenceKeypoint.new(0, 0),
              NumberSequenceKeypoint.new(1, 0)
          })
  
          beam.Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0, flags.BulletTracersColor.Color),
              ColorSequenceKeypoint.new(1, flags.BulletTracersColor.Color),
          });
  
          beam.Texture = 'rbxassetid://115789305736770'
          beam.TextureSpeed = 1;
          beam.TextureLength = 4;
          beam.Width0 = 0.2;
          beam.Width1 = 0.2;
          beam.FaceCamera = true;
          beam.LightEmission = 1;
          beam.Parent = VMs;
          beam.Brightness = 1
          beam.TextureMode = Enum.TextureMode.Stretch
  
          local expiry = flags.BulletTracersDuration or 1;        
          Debris:AddItem(att0, expiry);
          Debris:AddItem(att1, expiry);
          Debris:AddItem(beam, expiry);
      end))

      local CreateBlood = VFXModule.CreateBlood
      VFXModule.CreateBlood = LPH_NO_UPVALUES(function(self, hit, position)
          if not suppressImpactTracer then
              bullettracersbind:Fire(position)
          end
  
          return CreateBlood(self, hit, position)
      end);
  
      local CreateHole = VFXModule.CreateHole
      VFXModule.CreateHole = LPH_NO_UPVALUES(function(self, hit, position, normal, material, item, impactOnly)
          if not suppressImpactTracer then
              bullettracersbind:Fire(position)
          end
  
          return CreateHole(self, hit, position, normal, material, item, impactOnly)
      end);
  
      local LastPredictionPos
      local CreateProjectile = VFXModule.CreateProjectile
      VFXModule.CreateProjectile = LPH_NO_UPVALUES(function(self, ...)
          local Args = {...}

          if isViewmodelContext() and Args[1].StepFunction ~= "FakeStepFunc" and Args[1].HitFunction ~= "FakeHitFunc" and not tostring(Args[1].HitFunction):find("Ignore") then
              local now = tick()
  
              if flags.ForcePenetration then
                  for _, v in ipairs(workspace:GetChildren()) do
                      if not v:IsA('Folder') then
                          continue
                      end
  
                      if v.Name == 'Military' or v.Name == 'Events' then
                          continue 
                      end
  
                      local skip = false
                      for _, c in ipairs(v:GetChildren()) do
                          if c:IsA('Model') and (
                              c.Name == 'Soldier'
                              or c.Name == 'Brutus'
                              or c.Name == 'Bruno'
                              or c.Name == 'Boris'
                              or c.Name == 'BTR'
                          ) then
                              skip = true
                              break
                          end
                      end
  
                      if not skip then
                          table.insert(Args[1].Filters, v)
                      end
                  end
                  table.insert(Args[1].Filters, workspace.Terrain);
              end;
  
              Cheat.Globals.ShouldHit = ((math.floor(Random.new():NextNumber(0, 1) * 100) / 100) <= (flags.HitChance / 100))
              local isvalidstack3 = isvalidlevel(3)
              local isvalidstack2 = isvalidlevel(2)
              local stacklevel = isvalidstack3 and 3 or isvalidstack2 and 2
  
              if (stacklevel and Targeting.TargetPart and Client.Character) then
                  LastPredictionPos = nil
                  local HitFunction = Args[1].HitFunction;
                  local startPos = Args[1].Position or Args[1].PositionFirst or Camera.CFrame.Position;
                  local manipPos = Targeting.ManipulatedPosition
                  local targetPos = Targeting.TargetPart and Targeting.TargetPart.Position
                  
                  -- if flags.InstantBullet then
                  --     Args[1].Speed = 9e9
                  --     Args[1].Gravity = 0
                  -- end
  
                  local gun = getgun(Client.Character)
                  local oldspeed = Args[1].Speed
                  if gun and ToolInfo[gun] and Cheat.Globals.ClientCharacter and Cheat.Globals.ClientCharacter:FindFirstChild("InventoryController") and Cheat.Globals.ClientCharacter:FindFirstChild("ViewmodelController") then
                      local InventoryController = Cheat.Globals.ClientCharacter.InventoryController
                      local ViewmodelController = Cheat.Globals.ClientCharacter.ViewmodelController
                      local v376 = InventoryController.Fetch:Invoke();
                      local v377;
                      if not v376 then
                          v377 = nil;
                      else
                          local l_Toolbar_5 = v376.Toolbar;
                          if not l_Toolbar_5 then
                              v377 = nil;
                          else
                              local v379 = l_Toolbar_5[ViewmodelController:GetAttribute("Equipped")];
                              v377 = false;
                              if v379 ~= nil then
                                  v377 = false;
                                  if v379 ~= 0 then
                                      v377 = v379;
                                  end;
                              end;
                          end;
                      end;
  
                      if v377 then
                          v376 = v377.Ammo;
                          v382 = ItemsModule[v377.ID];
                      end;
                      if v376 then
                          v381 = ItemsModule[v376.ID].AmmoStats;
                      end;
  
                      local bullet = ToolInfo[gun].Bullet
                      oldspeed = bullet.Speed * (v381.SpeedMult or 1)
                  end
                  
                  local Speed, Gravity = Args[1].Speed, Args[1].Gravity
                  local Distance = (Camera.CFrame.Position - targetPos).Magnitude
                  local TimeToHit = Distance / oldspeed
  
                  local G = Gravity * -196.2
                  local Drop = -0.5 * G * TimeToHit * TimeToHit
                  if tostring(Drop):find("nan") then
                      Drop = 0
                  end
  
                  LastPredictionPos = Vector3.new(0, Drop, 0)
                  
                  local Stack = debug.getstack(stacklevel);
                  local CameraIndex, HRPIndex, FlashIndex, MouseIndex
                  local CameraValue, HRPValue, FlashValue, MouseValue
  
                  for i = 1, 100 do
                      local v = rawget(Stack, i)
                      if v then
                          local t = typeof(v)
                          if t == "CFrame" and not CameraValue then
                              local ok, p = pcall(function()
                                  return v.p
                              end)
                              if ok and typeof(p) == "Vector3" then
                                  CameraValue = v
                                  CameraIndex = i
                              end
                          elseif t == "CFrame" and CameraValue and not HRPValue and v ~= CameraValue then
                              local ok, p = pcall(function()
                                  return v.p
                              end)
                              if ok and typeof(p) == "Vector3" then
                                  HRPValue = v
                                  HRPIndex = i
                              end
                          elseif t == "Vector3" and not FlashValue then
                              FlashValue = v
                              FlashIndex = i
                          elseif t == "Vector3" and FlashValue and v ~= FlashValue and not MouseValue then
                              MouseValue = v
                              MouseIndex = i
                          end
                      end
                  end
                  
                  if CameraValue and HRPValue and FlashValue and MouseValue and Targeting.TargetPart and Targeting.TargetPart.Position and LastPredictionPos then
                      local finalTarget = Targeting.TargetPart and Targeting.TargetPart.Position
                      if LastPredictionPos then
                          finalTarget = finalTarget + LastPredictionPos
                      end
  
                      local camPos = CameraValue.p
                      local hrpPos = HRPValue.p
                      local newFlash = CFrame.new(FlashValue, finalTarget).p
  
                      if manipPos then
                          local offC = camPos - FlashValue
                          local offH = hrpPos - FlashValue
                          local newCam = manipPos + offC
                          local newHrp = manipPos + offH
                          CameraValue = CFrame.new(newCam, finalTarget)
                          HRPValue = CFrame.new(newHrp, finalTarget)
                          newFlash = manipPos
                      else
                          CameraValue = CFrame.new(camPos, finalTarget)
                          HRPValue = CFrame.new(hrpPos, finalTarget)
                      end
                      debug.setstack(stacklevel, CameraIndex, CameraValue)
                      debug.setstack(stacklevel, HRPIndex, HRPValue)
                      debug.setstack(stacklevel, FlashIndex, newFlash)
                      debug.setstack(stacklevel, MouseIndex, finalTarget)
                  end
              end;
  
              if (Args[1]['Terminate']) then
                  Args[1]['Terminate'] = nil;
              end;
  
              if Targeting.TargetPart and Cheat.Globals.ShouldHit then
                  local p = Targeting.TargetPart
                  local predictedHit = p and p.Position

                  if p and predictedHit then
                      if LastPredictionPos then
                          predictedHit += LastPredictionPos
                      end

                      local shootPos = Args[1].Position
                      if Targeting.ManipulatedPosition or Targeting.ManipPos then
                          shootPos = Targeting.ManipulatedPosition or Targeting.ManipPos
                      end

                      local dir = (predictedHit - shootPos).Unit
                      Args[1].Position = shootPos
                      if Args[1].PositionFirst then
                          Args[1].PositionFirst = shootPos
                      end
                      Args[1].DirectionFirst = dir
                      Args[1].Direction = dir
                  end	 
              end
          end;
  
          suppressImpactTracer = true
          local ok, result = pcall(CreateProjectile, self, unpack(Args))
          suppressImpactTracer = false
          if not ok then
              error(result)
          end
          return result
      end);
      
  local UpdateChar = LPH_NO_VIRTUALIZE(function()
          local character = Client.Character or Client.CharacterAdded:Wait()
          Cheat.Globals.ClientCharacter = character

          local hum = character:FindFirstChildOfClass('Humanoid') or character:WaitForChild('Humanoid')
          local InventoryController = character:WaitForChild('InventoryController')
          local EquipArmor = InventoryController:WaitForChild('EquipArmor')

          Cheat.Globals.QuickStackFunctions = {}
          for _, conn in getconnections(EquipArmor.Event) do
              local f = conn.Function
              if not f then continue end
              for _, v in debug.getupvalues(f) do
                  if type(v) ~= 'function' then continue end
                  local Constants = debug.getconstants(v)
                  if Constants[1] == "ArmorEquip" and Constants[5] == "GetAttribute" then
                      if flags.InstantLoot then
                          debug.setconstant(v, 19, 0)
                          debug.setconstant(v, 20, 0)
                          debug.setconstant(v, 21, 0)
                      end;
                      table.insert(Cheat.Globals.QuickStackFunctions, v)
                  end
              end
          end

      end);
  
      UpdateChar();
      Client.CharacterAdded:Connect(UpdateChar);
  end
