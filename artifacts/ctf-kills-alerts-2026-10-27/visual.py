from pathlib import Path
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-kills-alerts-2026-10-27\src')
p=R/'StarterPlayer/StarterPlayerScripts/CTFFlagLabels.luau';old=p.read_text(encoding='utf-8-sig');head=old[:old.index('-- Carrier indicators')]
a=old.index('local function forget(team)');b=old.index('local tick=0',a);forget=old[a:b]
s=head+'''-- The local presentation owns event cards and live carrier notices.
local Notice=require(script.Parent:WaitForChild("CTFFlagNotice")).new(player)
local indicators={}
local function participating()
 return player:GetAttribute("CrossgroundsMode")=="ctf" and player:GetAttribute("InMatch")==true and player:GetAttribute("AdminFreecam")~=true
end
local function color(team)return team=="Blue" and Color3.fromRGB(80,178,255) or Color3.fromRGB(255,103,91)end
local function flagName(team)return team=="Blue"and"AZUL"or"VERMELHA"end
'''+forget
s+='''local tick=0
Run.Heartbeat:Connect(function(dt)
 tick+=dt if tick<.15 then return end tick=0
 local on=participating() Notice:SetEnabled(on)
 local inRound=on and player:GetAttribute("InArena")==true and workspace:GetAttribute("RoundState")=="Playing"
 local current=workspace:FindFirstChild("CTFInfrastructure")local carriers={}
 for _,team in {"Blue","Red"}do
  local base=current and current:FindFirstChild(team.."Base")local ref=base and base:FindFirstChild("FlagCarrier")
  local carrier=ref and ref.Value local root=carrier and carrier:FindFirstChild("HumanoidRootPart")
  local valid=inRound and base~=nil and base:GetAttribute("FlagState")=="carried" and root~=nil
  local item=indicators[team]
  if item and (not valid or item.character~=carrier)then forget(team)item=nil end
  if valid then
   local own=player.Team and player.Team.Name==team
   if not item then
    local highlight=Instance.new("Highlight")highlight.Name="CTFFlagCarrierHighlight"highlight.Adornee=carrier highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency=.76 highlight.OutlineTransparency=0 highlight.FillColor=color(team)highlight.OutlineColor=own and Color3.fromRGB(255,220,110)or color(team)highlight.Parent=carrier
    local label=Instance.new("BillboardGui")label.Name="CTFCarrierMarker"label.Adornee=root label.Size=UDim2.fromOffset(210,48)label.StudsOffsetWorldSpace=Vector3.new(0,5.5,0)label.AlwaysOnTop=true label.MaxDistance=1400 label.Parent=carrier
    local text=Instance.new("TextLabel")text:SetAttribute("CascadeDecoration",true)text.Size=UDim2.fromScale(1,1)text.BackgroundColor3=Color3.fromRGB(10,23,32)text.BackgroundTransparency=.08 text.BorderSizePixel=0 text.TextColor3=color(team)text.Font=Enum.Font.GothamBold text.TextSize=13 text.TextWrapped=true text.Parent=label
    Instance.new("UICorner",text).CornerRadius=UDim.new(0,7)
    item={character=carrier,highlight=highlight,label=label,text=text}indicators[team]=item
   end
   local name=base:GetAttribute("FlagCarrierName")or carrier:GetAttribute("BotAlias")or carrier.Name
   item.text.Text=name.."\\nBANDEIRA "..flagName(team)
   local selfCarrier=carrier==player.Character
   table.insert(carriers,{priority=own and 1 or selfCarrier and 2 or 3,title=own and "INTERCEPTE · SUA BANDEIRA"or selfCarrier and "LEVE À SUA BASE"or"ESCOLTE O PORTADOR",name=(selfCarrier and "Você"or name).." · Bandeira "..string.lower(flagName(team)),color=own and Color3.fromRGB(255,112,101)or Color3.fromRGB(75,225,185)})
  end
 end
 table.sort(carriers,function(a,b)return a.priority<b.priority end)Notice:SetCarriers(carriers)
end)
task.spawn(function()
 game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("CTFFlagAlert").OnClientEvent:Connect(function(data)Notice:Notify(data)end)
end)
'''
p.write_text(s,encoding='utf-8')
