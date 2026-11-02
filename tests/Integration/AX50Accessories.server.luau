-- Opt-in native authority smoke in a disposable Studio Play, never at startup.
if script:GetAttribute("RunAX50Accessories")~=true then return end
assert(game:GetService("RunService"):IsStudio())
local S=require(game.ReplicatedStorage.Crossgrounds.WeaponStats)
local A=require(game.ServerScriptService.Crossgrounds.ShotAuthority)
local F=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
local V=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
local result=Instance.new("StringValue",game.TestService) result.Name="AX50AccessoriesSmoke" result.Value="Running"
local rows={} local done=0
for _,capacity in {7,9} do task.spawn(function()
 local bot=Instance.new("Model") bot.Name="AX50AccessoriesQA" bot:SetAttribute("CTFBot",true)
 local ok,err=pcall(function()
  local humanoid=Instance.new("Humanoid",bot) humanoid.RequiresNeck=false
  for name,y in {Head=2000,HumanoidRootPart=1998} do local p=Instance.new("Part",bot) p.Name=name p.Position=Vector3.new(capacity*100,y,0) p.Anchored=true end
  local folder=workspace:FindFirstChild("CTFBots") or Instance.new("Folder",workspace) folder.Name="CTFBots"
  local tool=F:Create("ax_50")
  assert(V.Apply(tool,"ax_50",{magazine="magazines_"..capacity.."rnd_50_bmg_magazine",stock="model_forge_tac_hunter"}))
  tool.RequiresHandle=false tool.Parent=bot tool.Handle.CFrame=bot.Head.CFrame
  local d=S.ResolveTool(tool) assert(d.Magazine==capacity and d.AdsMotionMultiplier==.4)
  tool:SetAttribute("Ammo",1) tool:SetAttribute("ReserveAmmo",20)
  local function fire() return A.FireNPC({character=bot,tool=tool,direction=Vector3.new(0,1,0),aim=bot.Head.Position+Vector3.new(0,100,0),valid=function()return true end,classify=function()return "block" end,onHit=function()end}) end
  bot.Parent=folder
  local accepted,reason=fire() assert(accepted,tostring(reason)) assert(tool:GetAttribute("Ammo")==0)
  -- Keep the synthetic fixture outside the live bot manager between native calls.
  bot.Parent=game.ServerStorage
  task.wait(d.Cooldown+.05)
  bot.Parent=folder accepted,reason=fire() bot.Parent=game.ServerStorage
  assert(not accepted and reason=="ammo",tostring(reason))
  tool:SetAttribute("Ammo",3)
  assert(A.ReloadNPC(bot,tool,function()return bot.Parent~=nil end))
  assert(math.abs(tool:GetAttribute("ReloadDuration")-d.ReloadTime)<1e-6)
  local untilTime=os.clock()+8
  repeat task.wait(.05) until not tool:GetAttribute("Reloading") or os.clock()>untilTime
  assert(tool:GetAttribute("Ammo")==capacity and tool:GetAttribute("ReserveAmmo")==20-(capacity-3))
  -- Limited reserve cannot create ammunition.
  tool:SetAttribute("Ammo",0) tool:SetAttribute("ReserveAmmo",2)
  assert(A.ReloadNPC(bot,tool,function()return bot.Parent~=nil end))
  untilTime=os.clock()+8 repeat task.wait(.05) until not tool:GetAttribute("Reloading") or os.clock()>untilTime
  assert(tool:GetAttribute("Ammo")==2 and tool:GetAttribute("ReserveAmmo")==0)
  table.insert(rows,{capacity=capacity,acceptedShot=true,emptyRejected=true,partialRefill=true,limitedReserve=true,reloadSeconds=d.ReloadTime})
 end)
 bot:Destroy() done+=1
 if not ok then table.insert(rows,{capacity=capacity,error=tostring(err)}) end
 result.Value=game.HttpService:JSONEncode({done=done,rows=rows})
end) end
