-- Run only in an isolated Studio Play. Uses NPC authority to exercise real ammo.
-- Opt-in: live bot population can invalidate synthetic actors in a normal hub.
if script:GetAttribute("RunAR15Smoke")~=true then return end
assert(game:GetService("RunService"):IsStudio(),"Studio only")
local S=require(game.ReplicatedStorage.Crossgrounds.WeaponStats)
local A=require(game.ServerScriptService.Crossgrounds.ShotAuthority)
local F=require(game.ServerScriptService.MainGameScript.GameManager.WeaponFactory)
local V=require(game.ServerScriptService.Crossgrounds.ImportedWeaponVisuals)
local result=Instance.new("StringValue",game.TestService) result.Name="AR15MagazineSmoke" result.Value="Running"
local bot
local ok,err=pcall(function()
 local rows={}
 for _,id in {"magazines_ar15_pmag_10","magazines_ar15_pmag_40","magazines_ar15_surefire_60"} do
  bot=Instance.new("Model") bot.Name="AR15QA" bot:SetAttribute("CTFBot",true)
  local humanoid=Instance.new("Humanoid",bot) humanoid.RequiresNeck=false
  for name,y in {Head=2000,HumanoidRootPart=1998} do local p=Instance.new("Part",bot) p.Name=name p.Position=Vector3.new(0,y,0) p.Anchored=true end
  local folder=workspace:FindFirstChild("CTFBots") or Instance.new("Folder",workspace) folder.Name="CTFBots" bot.Parent=folder
  local tool=F:Create("m4a1") assert(V.Apply(tool,"m4a1",{magazine=id})) tool.RequiresHandle=false tool.Parent=bot tool.Handle.CFrame=bot.Head.CFrame
  local d=S.ResolveTool(tool) tool:SetAttribute("Ammo",d.Magazine) tool:SetAttribute("ReserveAmmo",d.Reserve)
  local function fire() return A.FireNPC({character=bot,tool=tool,direction=Vector3.new(0,1,0),aim=Vector3.new(0,3000,0),valid=function()return true end,classify=function()return "block" end,onHit=function()end}) end
  local count=0
  for i=1,d.Magazine do local accepted,reason=fire() assert(accepted,tostring(reason)) count+=1 task.wait(d.Cooldown+.025) end
  local accepted,reason=fire() assert(not accepted and reason=="ammo")
  assert(A.ReloadNPC(bot,tool,function()return true end)) repeat task.wait(.05) until not tool:GetAttribute("Reloading")
  assert(tool:GetAttribute("Ammo")==d.Magazine and tool:GetAttribute("ReserveAmmo")==d.Reserve-d.Magazine)
  table.insert(rows,{id=id,shots=count,refilled=tool:GetAttribute("Ammo"),reserve=tool:GetAttribute("ReserveAmmo"),movement=d.MovementSpeedMultiplier,ads=d.AdsSpeedMultiplier})
  result.Value=game.HttpService:JSONEncode({running=true,completed=rows})
  bot:Destroy() bot=nil
 end
 result.Value=game.HttpService:JSONEncode({running=false,completed=rows})
end)
if bot then bot:Destroy() end
if not ok then result.Value="FAILED: "..tostring(err) end
