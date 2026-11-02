local V={}
local C=require(script.Parent:WaitForChild("MenuTheme")).Settings
local MenuMap=require(script.Parent:WaitForChild("MenuIconAtlasMap"))
local SettingsMap=require(script.Parent:WaitForChild("SettingsIconAtlasMap"))
local aliases={Main="home",Resume="resume",Options="settings",Gameplay="gameplay",Controls="controls",Analog="analog",Bindings="bindings",HUDSettings="touch-hud",Camera="camera-category",CameraCore="camera-perspective",Aim="aim-sensitivity",Reticle="reticle",Interface="interface",Audio="audio",Progress="progress",Maps="maps",AdminMaps="admin-maps",Graphics="graphics",Accessibility="accessibility",Development="development",Loadout="loadout",Surrender="surrender",Exit="exit",gear="settings",pad="controls",grid="interface",target="reticle",keyboard="bindings",chart="progress",curve="analog",map="maps",access="accessibility"}
function V.Icon(parent,id,size)
 local entry=SettingsMap[id] local asset="rbxassetid://95339500252717"
 if not entry then entry=MenuMap[aliases[id] or id] or MenuMap.settings asset="rbxassetid://81260305871356" end
 local p=Instance.new("Frame") p.Name="CategoryIcon" p:SetAttribute("SettingsStyled",true) p.BackgroundTransparency=1 p.Size=UDim2.fromOffset(size or 28,size or 28)
 local image=Instance.new("ImageLabel") image.Name="AtlasIcon" image:SetAttribute("SettingsStyled",true) image.BackgroundTransparency=1 image.Size=UDim2.fromScale(1,1) image.Image=asset image.ImageRectOffset=Vector2.new(entry.x,entry.y) image.ImageRectSize=Vector2.new(entry.w,entry.h) image.ScaleType=Enum.ScaleType.Fit image.ImageColor3=C.Text image.Parent=p
 p.Parent=parent return p
end
V.Descriptions={Analog="Ajuste o comportamento dos analógicos do seu controle.",Bindings="Personalize os comandos de cada dispositivo.",HUDSettings="Organize os controles de toque e o HUD.",Aim="Ajuste a sensibilidade e a assistência de mira.",CameraCore="Personalize a perspectiva e o campo de visão.",Interface="Ajuste a escala e a apresentação da interface.",Audio="Equilibre música e efeitos sonoros.",Accessibility="Ajuste a leitura e o conforto visual.",Graphics="Escolha a apresentação gráfica.",Reticle="Personalize seu retículo de mira."}
V.Help={LeftStickDeadzone="Ignora pequenos movimentos do analógico esquerdo.",RightStickDeadzone="Ignora pequenos movimentos do analógico direito.",StickCurve="Define a curva de resposta da mira.",StickCurveStrength="Define a força da curva S aplicada.",FieldOfView="Ajusta a amplitude da visão da câmera.",LookSensitivity="Controla a velocidade do movimento da câmera.",AimSensitivity="Controla a velocidade ao mirar.",ReducedMenuMotion="Simplifica as transições da interface."}
return V
