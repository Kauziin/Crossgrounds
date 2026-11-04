local View={}
local Theme=require(script.Parent.MenuTheme)
function View.new(parent,options)
 local nav=options.Navigation local self={} local dead=false local buttons={} local confirming=false
 local gui=Instance.new('ScreenGui') gui.Name='ClassOptionsOverlay' gui.IgnoreGuiInset=true gui.ResetOnSpawn=false gui.DisplayOrder=90 gui.Parent=game.Players.LocalPlayer.PlayerGui
 local shade=Instance.new('TextButton') shade.Name='ClassOptions' shade.Text='' shade.BackgroundColor3=Color3.new() shade.BackgroundTransparency=.45 shade.Size=UDim2.fromScale(1,1) shade.ZIndex=20 shade:SetAttribute('CascadeDecoration',true) shade.Parent=gui self.Root=shade
 local neo=Theme.Style.IsNova()
 local panel=Instance.new(neo and 'ScrollingFrame'or 'Frame') panel.Name='Panel' panel.Size=UDim2.new(1,-32,0,330) panel.AnchorPoint=Vector2.new(.5,.5) panel.Position=UDim2.fromScale(.5,.48) panel.BackgroundColor3=Color3.fromRGB(10,25,32) panel.ZIndex=21 panel:SetAttribute('CascadeDecoration',true) panel.Parent=shade
 if neo then panel.CanvasSize=UDim2.fromOffset(0,330)panel.ScrollBarThickness=3 panel.BorderSizePixel=0 end
 local mobileScale=Instance.new('UIScale',panel)
 local function resize()mobileScale.Scale=neo and 1 or Theme.MobileFactor()if neo then panel.Size=UDim2.new(1,-32,0,math.min(330,math.max(180,workspace.CurrentCamera.ViewportSize.Y-40)))end end
 local stopMobile=Theme.ObserveMobile(resize)local viewport=workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'):Connect(resize)panel.Destroying:Once(function()stopMobile()viewport:Disconnect()end)resize()
 local limit=Instance.new('UISizeConstraint',panel) limit.MaxSize=Vector2.new(400,330) Instance.new('UICorner',panel).CornerRadius=UDim.new(0,14)
 Theme.Surface(panel)
 local title=Instance.new('TextLabel') title.Name='Title' title.BackgroundTransparency=1 title.Text=options.Name title.Font=Enum.Font.GothamBold title.TextSize=20 title.TextColor3=Color3.new(1,1,1) title.Position=UDim2.fromOffset(16,12) title.Size=UDim2.new(1,-32,0,36) title.ZIndex=22 title.Parent=panel
 local function button(name,text,y,fn)
  local b=Instance.new('TextButton') b.Name=name b.Text=text b.Font=Enum.Font.GothamMedium b.TextSize=16 b.TextColor3=Color3.new(1,1,1) b.BackgroundColor3=Color3.fromRGB(20,51,61) b.Position=UDim2.fromOffset(16,y) b.Size=UDim2.new(1,-32,0,48) b.ZIndex=22 b:SetAttribute('CascadeDecoration',true) b:SetAttribute('ArsenalFocus',true) b.Parent=panel Instance.new('UICorner',b).CornerRadius=UDim.new(0,8) Theme.Button(b)if neo then b.BackgroundTransparency=1 b.TextXAlignment=Enum.TextXAlignment.Left end nav:Connect(b,fn) table.insert(buttons,b) return b
 end
 local rename
 rename=button('Rename','Renomear',58,function()
  local field=panel:FindFirstChild('NewName')
  if field then options.Action('rename',field.Text) return end
  field=Instance.new('TextBox') field.Name='NewName' field.Text=options.Name field.ClearTextOnFocus=false field.TextSize=16 field.TextColor3=Color3.new(1,1,1) field.BackgroundColor3=Color3.fromRGB(18,38,46) field.Position=UDim2.fromOffset(16,276) field.Size=UDim2.new(1,-32,0,40) field.ZIndex=23 field.Parent=panel rename.Text='Confirmar nome' nav:Register(field,function() field:CaptureFocus() end) field:CaptureFocus()
 end)
 button('Duplicate','Duplicar',114,function() options.Action('duplicate') end)
 local delete delete=button('Delete','Excluir',170,function() if not confirming then confirming=true delete.Text='Excluir? A confirma' else options.Action('delete') end end)
 button('Close','Voltar',226,function() options.Close() end)
 for i,b in buttons do b.NextSelectionUp=buttons[(i-2)%#buttons+1] b.NextSelectionDown=buttons[i%#buttons+1] b.NextSelectionLeft=b b.NextSelectionRight=b nav:SetActions(b,{options=options.Close}) end
 nav:SetFloatingRoot(shade,options.Close,buttons[1]) task.defer(function() if not dead then nav:Focus(buttons[1]) end end)
 function self:Destroy() if dead then return end dead=true nav:SetFloatingRoot(nil) gui:Destroy() end
 return self
end
return View
