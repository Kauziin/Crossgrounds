from pathlib import Path
p=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio\artifacts\ctf-flow-2026-10-27\src\ReplicatedFirst\CrossgroundsLoading.luau')
s=p.read_text(encoding='utf-8')
s=s.replace('local background=Instance.new("TextButton")','local coverGroup=Instance.new("CanvasGroup") coverGroup.Name="Transition" coverGroup.Size=UDim2.fromScale(1,1) coverGroup.BackgroundTransparency=1 coverGroup.Parent=gui\nlocal background=Instance.new("TextButton")',1)
s=s.replace('background.Parent=gui','background.Parent=coverGroup',1)
s=s.replace('local function show(value)\n if value==visible then return end visible=value gui.Enabled=value player:SetAttribute("ClientLoading",value)','''local fade local fadeSerial=0
local function show(value)
 if value==visible then return end visible=value fadeSerial+=1 local serial=fadeSerial
 if fade then fade:Cancel() end
 player:SetAttribute("ClientLoading",value)
 if value then gui.Enabled=true coverGroup.GroupTransparency=0
 elseif player:GetAttribute("SettingReducedMotion") then gui.Enabled=false
 else
  fade=game:GetService("TweenService"):Create(coverGroup,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{GroupTransparency=1})
  fade:Play() task.delay(.22,function() if serial==fadeSerial and not visible then gui.Enabled=false end end)
 end''',1)
p.write_text(s,encoding='utf-8')
