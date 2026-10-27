from pathlib import Path
R=Path(r'C:\Users\Kauziin\Documents\ChatGPT\RobloxStudio');p=R/'artifacts/ctf-kills-alerts-2026-10-27/src/StarterPlayer/StarterPlayerScripts/CTFFlagNotice.luau';s=p.read_text(encoding='utf-8-sig')
s=s.replace('o.TextStrokeTransparency=1 o.Text=""','o.TextStrokeColor3=Color3.fromRGB(0,0,0) o.TextStrokeTransparency=.45 o.Text=""')
s=s.replace('self.Card=event','self.Card=event event.BackgroundTransparency=1',1)
s=s.replace('self.Edge=stroke(event,success,.46)','self.Edge=stroke(event,success,1)')
s=s.replace('self.Accent=accent','self.Accent=accent accent.Visible=false',1)
s=s.replace('self.Icon,self.Flag=flag(event)','self.Icon,self.Flag=flag(event) self.Icon.BackgroundTransparency=1',1)
s=s.replace('self.Action.TextColor3=muted','self.Action.TextColor3=muted self.Action.Visible=false',1)
s=s.replace('self.Time=object("Frame","Remaining",track)','track.Visible=false\n self.Time=object("Frame","Remaining",track)',1)
s=s.replace('local edge=stroke(row,success,.7)','local edge=stroke(row,success,1) row.BackgroundTransparency=1')
a=s.index('function Notice:Layout()');b=s.index('function Notice:SetEnabled(',a)
s=s[:a]+'''function Notice:Layout()
 local v=workspace.CurrentCamera.ViewportSize
 local scale=math.min(self.player:GetAttribute("SettingHUDScale")or 1,math.max(.65,(v.X-24)/300))
 local width=math.min(500,(v.X-24)/scale)self.Scale.Scale=scale
 local f=self.player:GetAttribute("SettingFontScale")or 1
 self.Root.Position=UDim2.new(.5,0,0,v.Y<500 and 108 or 122)self.Root.Size=UDim2.fromOffset(width,96*f)
 -- Forty pixels instead of the earlier 110+ px card, with no background panel.
 local height=40*f
 self.Card.Size=UDim2.new(1,0,0,height)self.Card.BackgroundTransparency=1 self.Edge.Transparency=1
 self.Heading.TextSize=9*f self.Heading.TextWrapped=false self.Heading.TextTruncate=Enum.TextTruncate.AtEnd
 self.Heading.Position=UDim2.fromOffset(34,0)self.Heading.Size=UDim2.new(1,-40,0,12*f)
 self.Message.TextSize=14*f self.Message.TextScaled=true self.Message.TextWrapped=true
 local bounds=self.Message:FindFirstChildOfClass("UITextSizeConstraint")or Instance.new("UITextSizeConstraint",self.Message)
 bounds.MinTextSize=11*f bounds.MaxTextSize=14*f
 self.Message.Position=UDim2.fromOffset(34,12*f)self.Message.Size=UDim2.new(1,-40,0,27*f)
 self.Action.Visible=false self.Icon.BackgroundTransparency=1 self.Icon.Size=UDim2.fromOffset(24,30*f)self.Icon.Position=UDim2.fromOffset(4,3*f)
 self.Icon.Pole.Position=UDim2.fromOffset(4,3*f)self.Icon.Pole.Size=UDim2.fromOffset(2,24*f)
 self.Flag.Position=UDim2.fromOffset(6,3*f)self.Flag.Size=UDim2.fromOffset(17,12*f)
 self.Host.Visible=not(v.Y<500 and self.Card.Visible)
 self.Host.Position=UDim2.fromOffset(0,self.Card.Visible and height+3 or 0)self.Host.Size=UDim2.new(1,0,0,44*f)
 local y=0
 for i,row in self.rows do
  local item=self.carriers[i]row.frame.Visible=item~=nil
  if item then
   row.title.Visible=false row.edge.Transparency=1 row.bar.Visible=false
   row.name.TextSize=12*f row.name.TextWrapped=false row.name.TextTruncate=Enum.TextTruncate.AtEnd
   row.name.Text=item.name.." · "..(item.priority==1 and "INTERCEPTE"or item.priority==2 and "LEVE À BASE"or"ESCOLTE")
   row.name.TextColor3=item.color
   row.frame.Position=UDim2.fromOffset(0,y)row.frame.Size=UDim2.new(1,0,0,18*f)row.frame.BackgroundTransparency=1
   row.name.Position=UDim2.fromOffset(5,0)row.name.Size=UDim2.new(1,-10,1,0)
   y+=19*f
  end
 end
end
''' +s[b:]
s=s.replace('self.Card.GroupTransparency=1 self.Card.Position=UDim2.fromOffset(0,-8)','self.Card.GroupTransparency=1 self.Card.Position=UDim2.fromOffset(0,-4)')
p.write_text(s,encoding='utf-8');(R/'src/StarterPlayer/StarterPlayerScripts/CTFFlagNotice.luau').write_text(s,encoding='utf-8')
p=R/'artifacts/ctf-kills-alerts-2026-10-27/src/StarterPlayer/StarterPlayerScripts/CTFFlagLabels.luau';s=p.read_text(encoding='utf-8-sig');s=s.replace('text.BackgroundTransparency=.08','text.BackgroundTransparency=1 text.TextStrokeColor3=Color3.new(0,0,0) text.TextStrokeTransparency=.45');p.write_text(s,encoding='utf-8');(R/'src/StarterPlayer/StarterPlayerScripts/CTFFlagLabels.luau').write_text(s,encoding='utf-8')
