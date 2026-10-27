local Avatar={}
local Players=game:GetService("Players")
local pool,seen,cache,loading={},{},{},{}
local aliases={"Eco","Nimbo","Rubi","Cobalto","Lince","Orion","Brisa","Atlas","Cedro","Rastro","Vega","Faísca"}
local skins={Color3.fromRGB(238,192,146),Color3.fromRGB(166,108,70),Color3.fromRGB(105,73,55),Color3.fromRGB(241,211,175)}
local function collect(player)
 if player.UserId<=0 then return end
 local ok,pages=pcall(function() return Players:GetFriendsAsync(player.UserId) end)
 if not ok then return end
 for _=1,2 do
  for _,friend in pages:GetCurrentPage() do if not seen[friend.Id] then seen[friend.Id]=true table.insert(pool,{id=friend.Id,alias=friend.DisplayName or friend.Username}) end end
  if pages.IsFinished then break end
  if not pcall(function() pages:AdvanceToNextPageAsync() end) then break end
 end
end
local function decorate(bot,team)
 local h=bot:FindFirstChildOfClass("Humanoid") if not h then return end
 h.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None
 local tint=team.TeamColor.Color
 local highlight=bot:FindFirstChild("TeamOutline") or Instance.new("Highlight")
 highlight.Name="TeamOutline" highlight.FillTransparency=1 highlight.OutlineTransparency=.5 highlight.OutlineColor=tint highlight.DepthMode=Enum.HighlightDepthMode.Occluded highlight.Parent=bot
 local torso=bot:FindFirstChild("UpperTorso") or bot:FindFirstChild("Torso")
 local old=bot:FindFirstChild("TeamBand") if old then old:Destroy() end
 if torso then
  local band=Instance.new("Part") band.Name="TeamBand" band.Size=Vector3.new(torso.Size.X*.9,.35,.12) band.CFrame=torso.CFrame*CFrame.new(0,.2,-torso.Size.Z/2-.06) band.Color=tint band.Material=Enum.Material.SmoothPlastic band.CanCollide=false band.CanTouch=false band.CanQuery=false band.Massless=true band.Parent=bot
  local weld=Instance.new("WeldConstraint") weld.Part0=torso weld.Part1=band weld.Parent=band
 end
 local head=bot:FindFirstChild("Head")
 if head then
  local old=head:FindFirstChild("TeamTag") if old then old:Destroy() end
  local tag=Instance.new("BillboardGui") tag.Name="TeamTag" tag.Size=UDim2.fromOffset(120,16) tag.StudsOffsetWorldSpace=Vector3.new(0,1.7,0) tag.MaxDistance=45 tag.AlwaysOnTop=false tag.Parent=head
  local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(1,1) text.BackgroundTransparency=1 text.TextSize=11 text.TextColor3=tint text.TextStrokeTransparency=.35 text.Font=Enum.Font.GothamMedium text.Text=(bot:GetAttribute("BotAlias") or "Sentinela").." · IA" text.Parent=tag
 end
end
function Avatar:Apply(bot,slot,team)
 local h=bot:FindFirstChildOfClass("Humanoid") if not h then return end
 local friend=#pool>0 and pool[math.random(#pool)]
 bot:SetAttribute("BotAlias",aliases[(slot-1)%#aliases+1])
 local body=bot:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors",bot)
 local skin=skins[math.random(#skins)] body.HeadColor3=skin body.LeftArmColor3=skin body.RightArmColor3=skin body.TorsoColor3=Color3.fromHSV(math.random(),.3,.35) body.LeftLegColor3=Color3.fromRGB(42,47,59) body.RightLegColor3=body.LeftLegColor3
 decorate(bot,team)
 if not friend then return end
 bot:SetAttribute("AvatarUserId",friend.id)
 task.spawn(function()
  if loading[friend.id] then
   local deadline=os.clock()+10 repeat task.wait(.2) until not loading[friend.id] or os.clock()>deadline or not bot.Parent
  end
  local description=cache[friend.id]
  if not description and not loading[friend.id] then
   loading[friend.id]=true
   local ok,result=pcall(function() return Players:GetHumanoidDescriptionFromUserIdAsync(friend.id) end)
   loading[friend.id]=nil if ok then cache[friend.id]=result description=result end
  end
  if not description or not bot.Parent or h.Health<=0 then return end
  local copy=description:Clone() copy.HeightScale=1 copy.WidthScale=1 copy.DepthScale=1 copy.HeadScale=1 copy.BodyTypeScale=0 copy.ProportionScale=0
  local ok=pcall(function() h:ApplyDescriptionAsync(copy) end) copy:Destroy()
  if ok and bot.Parent and h.Health>0 then
   bot:SetAttribute("BotAlias",friend.alias) decorate(bot,team)
   local tool=bot:FindFirstChildOfClass("Tool") if tool then tool.Parent=nil tool.Parent=bot h:EquipTool(tool) end
   local root=bot:FindFirstChild("HumanoidRootPart") if root then pcall(function() root:SetNetworkOwner(nil) end) end
  end
 end)
end
Players.PlayerAdded:Connect(function(p) task.spawn(collect,p) end)
for _,p in Players:GetPlayers() do task.spawn(collect,p) end
return Avatar