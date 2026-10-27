local V={}
local C=require(script.Parent:WaitForChild("MenuTheme")).Settings
local function line(p,x,y,w,h,r)
 local f=Instance.new("Frame") f:SetAttribute("SettingsStyled",true) f.BackgroundColor3=C.Text f.BorderSizePixel=0 f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.fromScale(x,y) f.Size=UDim2.fromScale(w,h) f.Rotation=r or 0 f.Parent=p return f
end
function V.Icon(parent,id,size)
 local p=Instance.new("Frame") p.Name="CategoryIcon" p:SetAttribute("SettingsStyled",true) p.BackgroundTransparency=1 p.Size=UDim2.fromOffset(size or 28,size or 28) p.Parent=parent
 id=({Main="home",Resume="home",Options="gear",Controls="pad",Analog="pad",Bindings="keyboard",HUDSettings="grid",Camera="target",CameraCore="target",Aim="target",Reticle="target",Audio="audio",Progress="chart",Maps="map",Graphics="grid",Accessibility="access"})[id] or id
 if id=="home" then line(p,.3,.25,.48,.08,-43) line(p,.7,.25,.48,.08,43) line(p,.22,.64,.08,.5) line(p,.78,.64,.08,.5) line(p,.5,.88,.62,.08) line(p,.5,.73,.08,.3)
 elseif id=="pad" then
  local body=line(p,.5,.52,.9,.6) body.BackgroundTransparency=1 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(.3,0) c.Parent=body local s=Instance.new("UIStroke") s.Color=C.Text s.Thickness=2 s.Parent=body
  line(p,.3,.5,.27,.07) line(p,.3,.5,.07,.27) line(p,.68,.43,.1,.1) line(p,.8,.6,.1,.1)
 elseif id=="keyboard" or id=="grid" then
  for x=1,3 do for y=1,2 do line(p,x*.25,.2+y*.23,.17,.16) end end
 elseif id=="curve" or id=="chart" then
  if id=="chart" then for i=1,3 do line(p,i*.25,.9-i*.12,.13,i*.23) end
  else line(p,.25,.65,.44,.07,-50) line(p,.55,.5,.35,.07,35) line(p,.78,.36,.43,.07,-50) end
 elseif id=="reset" then
  local ring=line(p,.5,.55,.65,.65) ring.BackgroundTransparency=1 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=ring local st=Instance.new("UIStroke") st.Color=C.Text st.Thickness=2 st.Parent=ring
  line(p,.22,.22,.08,.3) line(p,.35,.34,.32,.08)
 elseif id=="audio" then line(p,.25,.55,.2,.3) line(p,.45,.55,.14,.65) line(p,.7,.55,.07,.4) line(p,.86,.55,.07,.65)
 elseif id=="map" then for i=1,3 do line(p,i*.25,.5,.08,.7) end line(p,.5,.2,.55,.07) line(p,.5,.8,.55,.07)
 else
  local ring=line(p,.5,.5,.62,.62) ring.BackgroundTransparency=1 local c=Instance.new("UICorner") c.CornerRadius=UDim.new(1,0) c.Parent=ring local st=Instance.new("UIStroke") st.Color=C.Text st.Thickness=2 st.Parent=ring
  line(p,.5,.13,.08,.25) line(p,.5,.87,.08,.25) line(p,.13,.5,.25,.08) line(p,.87,.5,.25,.08)
 end
 return p
end
V.Descriptions={Analog="Ajuste o comportamento dos analógicos do seu controle.",Bindings="Personalize os comandos de cada dispositivo.",HUDSettings="Organize os controles de toque e o HUD.",Aim="Ajuste a sensibilidade e a assistência de mira.",CameraCore="Personalize a perspectiva e o campo de visão.",Interface="Ajuste a escala e a apresentação da interface.",Audio="Equilibre música e efeitos sonoros.",Accessibility="Ajuste a leitura e o conforto visual.",Graphics="Escolha a apresentação gráfica.",Reticle="Personalize seu retículo de mira."}
V.Help={LeftStickDeadzone="Ignora pequenos movimentos do analógico esquerdo.",RightStickDeadzone="Ignora pequenos movimentos do analógico direito.",StickCurve="Define a curva de resposta da mira.",StickCurveStrength="Define a força da curva S aplicada.",FieldOfView="Ajusta a amplitude da visão da câmera.",LookSensitivity="Controla a velocidade do movimento da câmera.",AimSensitivity="Controla a velocidade ao mirar.",ReducedMenuMotion="Simplifica as transições da interface."}
return V
