local Bootstrap={}
local started=false
function Bootstrap:Start(ctfRoot)
 if started then return end started=true
 local config=require(game.ServerStorage.CrossgroundsConfiguration)
 assert(table.find({"combinedPrototype","hub","ctf","arena","legacy"},config.PlaceRole),"PlaceRole inválido.")
 workspace:SetAttribute("CrossgroundsEnabled",true)
 workspace:SetAttribute("CrossgroundsPlaceRole",config.PlaceRole)
 workspace:SetAttribute("CrossgroundsBootstrapCount",(workspace:GetAttribute("CrossgroundsBootstrapCount") or 0)+1)
 local root=game.ReplicatedStorage.Crossgrounds
 local remotes=root:FindFirstChild("Remotes") or Instance.new("Folder") remotes.Name="Remotes" remotes.Parent=root
 local function remote(name,class) local value=remotes:FindFirstChild(name) or Instance.new(class) assert(value.ClassName==class,"Remote incompatível: "..name) value.Name=name value.Parent=remotes return value end
 local handles={Command=remote("Command","RemoteEvent"),State=remote("State","RemoteEvent"),GetState=remote("GetState","RemoteFunction")}
 local scene
 if config.PlaceRole=="combinedPrototype" or config.PlaceRole=="hub" then scene=require(script.Parent.HubScene):Ensure() end
 local context=require(script.Parent.PlayerContext) context:Initialize(config,scene)
 local coordinator=require(script.Parent.SessionCoordinator).new(context,require(script.Parent.TravelService).new(config),require(script.Parent.PreferenceAdapter),handles)
 if config.PlaceRole~="hub" then require(script.Parent.WeaponRig):Start() end
 local ctfAdapter
 if config.PlaceRole~="hub" and config.PlaceRole~="arena" then
  local adapter=require(script.Parent.CTFAdapter).new(ctfRoot,context)
  coordinator:Register(adapter) adapter:Start() ctfAdapter=adapter
 else
  -- Keeps the existing preference service/schema without loading CTF gameplay.
  require(ctfRoot.SettingsService)
 end
 if config.PlaceRole=="combinedPrototype" or config.PlaceRole=="arena" then
  local arena=require(script.Parent.ArenaAdapter).new(context,ctfRoot,config)
  coordinator:Register(arena) arena:Start(ctfAdapter and ctfAdapter.players)
 end
 if config.PlaceRole=="combinedPrototype" and config.EnableLocalGetOutPrototype then
  local getOut=require(script.Parent.GetOutAdapter).new(context,config)
  coordinator:Register(getOut) getOut:Start(ctfAdapter and ctfAdapter.players)
  if game:GetService("RunService"):IsStudio() then
   local ok,args=pcall(function() return game:GetService("StudioTestService"):GetTestArgs() end)
   if ok and args=="GetOutP0" then task.spawn(function() require(game.ServerStorage.GetOutP0Smoke).Run(getOut) end) end
  end
 end
 require(script.Parent.SpawnProtectionService):Start()
 require(script.Parent.ComfortLighting):Start()
 coordinator:Start()
 require(script.Parent.LoadoutService):Start()
 require(script.Parent.EquipmentService):Start()
 require(script.Parent.StandingsService):Start()
 require(script.Parent.ProgressionService):Start()
 require(script.Parent.DevelopmentService):Start(coordinator,ctfRoot)
 self.Coordinator=coordinator
end
return Bootstrap

