local V={}
local C=require(script.Parent:WaitForChild("MenuTheme")).Settings
local Library=require(game.ReplicatedStorage.Crossgrounds.InterfaceIcons)
local libraryNames={Main="house",Resume="circle-play",Options="settings",Gameplay="gamepad-2",Controls="gamepad",Analog="joystick",Bindings="keyboard",HUDSettings="smartphone",Camera="camera",CameraCore="scan-eye",Aim="focus",Reticle="scan",Interface="layout-dashboard",Themes="palette",Audio="headphones",Progress="chart-no-axes-combined",Maps="map",AdminMaps="map-pinned",Graphics="monitor",Accessibility="accessibility",Development="code-xml",Loadout="backpack",Surrender="flag-off",Exit="log-out",gear="settings",pad="gamepad",grid="layout-dashboard",target="scan",keyboard="keyboard",chart="chart-no-axes-combined",curve="joystick",map="map",access="accessibility"}
local settingNames={AutoSprint="footprints",ReducedMenuMotion="pause",FieldOfView="view",AimSensitivity="mouse-pointer-2",LookSensitivity="move-3d",LeftStickDeadzone="circle-dot",RightStickDeadzone="circle-dashed",StickCurve="spline",StickCurveStrength="chart-spline",HighContrast="contrast",FontScale="type",MenuScale="scaling",MasterVolume="volume-2",MusicVolume="music-2",SFXVolume="audio-lines",MenuSFXVolume="bell",CameraShake="vibrate",DamageFlash="zap",ShowFPS="gauge",ShowPing="wifi",TouchSafeX="align-horizontal-space-around",TouchSafeY="align-vertical-space-around",MobileMenuScale="tablet-smartphone",ThemePreset="swatch-book",AccentHue="rainbow",AccentSaturation="pipette",AccentValue="sun",ToggleAim="crosshair",ToggleSprint="toggle-right",HoldToSprint="person-standing",InvertY="flip-vertical",InvertX="flip-horizontal",ReticleColor="paint-bucket",ReticleSize="maximize",ReticleStyle="shapes"}
local extraNames={AimAssist="magnet",AimAssistStrength="biceps-flexed",AimAssistSlowdown="turtle",AimAssistTracking="radar",AimAssistCentering="locate-fixed",MenuVolume="volume-1",Shoulder="rotate-3d",FirstPerson="eye",ShiftLock="lock-keyhole",CameraMotion="orbit",GraphicsQuality="monitor-cog",SimpleAnimations="clapperboard",WeaponAnimationIntensity="waves",FOVTransitionSpeed="fast-forward",WeaponFOVScale="scan-line",GameSFXVolume="speaker",BeastProximityVolume="ear",HUDScale="layout-template",KillFeedVisible="list",ReticleThickness="minus",ReticleGap="split",ReticleDot="dot",ReticleOutline="square-dashed",ReticleOpacity="blend",ReticleDynamic="expand"}
for key,name in extraNames do settingNames[key]=name end
function V.Icon(parent,id,size)
 local p=Instance.new("Frame") p.Name="CategoryIcon" p:SetAttribute("SettingsStyled",true) p.BackgroundTransparency=1 p.Size=UDim2.fromOffset(size or 28,size or 28)
 local image=Library.Image(p,settingNames[id]or libraryNames[id]or id,size or 28,C.Text)
 if not image then image=Library.Image(p,"sliders-horizontal",size or 28,C.Text)end
 image.Name="AtlasIcon"image.Size=UDim2.fromScale(1,1)
 p.Parent=parent return p
end
V.Descriptions={Themes="Escolha a identidade visual dos seus menus.",Analog="Ajuste o comportamento dos analógicos do seu controle.",Bindings="Personalize os comandos de cada dispositivo.",HUDSettings="Organize os controles de toque e o HUD.",Aim="Ajuste a sensibilidade e a assistência de mira.",CameraCore="Personalize a perspectiva e o campo de visão.",Interface="Ajuste a escala e a apresentação da interface.",Audio="Equilibre música e efeitos sonoros.",Accessibility="Ajuste a leitura e o conforto visual.",Graphics="Escolha a apresentação gráfica.",Reticle="Personalize seu retículo de mira."}
V.Help={LeftStickDeadzone="Ignora pequenos movimentos do analógico esquerdo.",RightStickDeadzone="Ignora pequenos movimentos do analógico direito.",StickCurve="Define a curva de resposta da mira.",StickCurveStrength="Define a força da curva S aplicada.",FieldOfView="Ajusta a amplitude da visão da câmera.",LookSensitivity="Controla a velocidade do movimento da câmera.",AimSensitivity="Controla a velocidade ao mirar.",ReducedMenuMotion="Simplifica as transições da interface."}
V.Help.AccentHue='Escolha a cor no círculo cromático, de 0 a 359 graus.'
V.Help.AccentSaturation='Controle a intensidade da cor, do cinza à cor plena.'
V.Help.AccentValue='Ajuste o brilho da cor. O foco mantém contraste para continuar legível.'
V.Help.MobileMenuScale='Tamanho dos menus no celular. O padrão de 60% reduz o menu em 40%.'
V.Help.TouchSafeX='Afaste menus e controles das bordas laterais, além da área segura do aparelho.'
V.Help.TouchSafeY='Afaste menus e controles das bordas superior e inferior.'
return V
