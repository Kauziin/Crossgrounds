local Settings={}
Settings.Order={"AutoSprint","ReducedMenuMotion","FieldOfView","AimSensitivity","LookSensitivity","LeftStickDeadzone","RightStickDeadzone","StickCurve","StickCurveStrength","AimAssist","AimAssistStrength","AimAssistSlowdown","AimAssistTracking","AimAssistCentering","MenuVolume","MenuSFXVolume","Shoulder","FirstPerson","ShiftLock","DamageFlash","CameraMotion"}
Settings.Rules={
 AutoSprint={Label="Corrida automática no toque",Default=false},
 ReducedMenuMotion={Label="Reduzir movimento dos menus",Default=false},
 FieldOfView={Label="Campo de visão (FOV)",Default=70,Min=60,Max=110,Step=1},
 AimSensitivity={Label="Sensibilidade ao mirar",Default=.55,Min=.1,Max=1.5,Step=.05},
 LookSensitivity={Label="Sensibilidade da câmera",Default=1,Min=.2,Max=4,Step=.1},
 LeftStickDeadzone={Label="Zona morta esquerda (%)",Default=.05,Min=0,Max=.4,Step=.01,Percent=true},
 RightStickDeadzone={Label="Zona morta direita (%)",Default=.10,Min=0,Max=.4,Step=.01,Percent=true},
 StickCurve={Label="Resposta do analógico direito",Default=1,Choices={-1,1},Labels={[-1]="LINEAR",[1]="DINÂMICA (CURVA S)"}},
 StickCurveStrength={Label="Intensidade da curva S (%)",Default=.65,Min=0,Max=1,Step=.05,Percent=true},
 AimAssist={Label="Assistência de mira (controle/toque)",Default=true},
 AimAssistStrength={Label="Intensidade da assistência (%)",Default=.45,Min=0,Max=1,Step=.05,Percent=true},
 AimAssistSlowdown={Label="Desaceleração perto do alvo (%)",Default=1,Min=0,Max=1,Step=.05,Percent=true},
 AimAssistTracking={Label="Acompanhamento do movimento (%)",Default=1,Min=0,Max=1,Step=.05,Percent=true},
 AimAssistCentering={Label="Atração suave ao alvo (%)",Default=.5,Min=0,Max=1,Step=.05,Percent=true},
 MenuVolume={Label="Música do lobby",Default=.22,Min=0,Max=.7,Step=.01},
 MenuSFXVolume={Label="Sons de navegação",Default=.18,Min=0,Max=.7,Step=.01},
 Shoulder={Label="Ombro",Default=1,Choices={-1,1},Labels={[-1]="ESQUERDO",[1]="DIREITO"}},
 FirstPerson={Label="Perspectiva inicial",Default=false,Labels={[false]="TERCEIRA PESSOA",[true]="PRIMEIRA PESSOA"}},
 ShiftLock={Label="Shift Lock padrão",Default=true},
 CameraMotion={Label="Oscilação da câmera",Default=.35,Min=0,Max=1,Step=.05},
 DamageFlash={Label="Intensidade do dano na tela",Default=.45,Min=.1,Max=.8,Step=.05},
}
Settings.Version=2
local extra={
 GraphicsQuality={Label="Qualidade gráfica",Default=2,Choices={1,2,3,4},Labels={[1]="DESEMPENHO",[2]="EQUILIBRADO",[3]="ALTO",[4]="VISUAL"},Category="Graphics"},
 SimpleAnimations={Label="Animações simples",Default=false,Category="Accessibility"},
 WeaponAnimationIntensity={Label="Movimento das armas",Default=1,Min=0,Max=1,Step=.05,Percent=true,Category="Accessibility"},
 FOVTransitionSpeed={Label="Velocidade do FOV",Default=1,Min=.15,Max=1,Step=.05,Percent=true,Category="Accessibility"},
 WeaponFOVScale={Label="FOV das armas",Default=1,Choices={.75,1,1.25},Labels={[.75]="MENOS INTENSO",[1]="NORMAL",[1.25]="MAIS INTENSO"},Category="Camera"},
 GameSFXVolume={Label="Sons da partida",Default=.5,Min=0,Max=1,Step=.05,Percent=true,Category="Audio"},
 BeastProximityVolume={Label="Proximidade da Besta",Default=.35,Min=0,Max=1,Step=.05,Percent=true,Category="Audio"},
 MenuScale={Label="Escala do menu",Default=1,Min=.8,Max=1.3,Step=.05,Percent=true,Category="Interface"},
 HUDScale={Label="Escala da HUD",Default=1,Min=.8,Max=1.3,Step=.05,Percent=true,Category="Interface",ModeOverride=true},
 FontScale={Label="Tamanho adicional do texto",Default=1,Min=.9,Max=1.35,Step=.05,Percent=true,Category="Accessibility"},
 HighContrast={Label="Alto contraste",Default=false,Category="Accessibility"},
 KillFeedVisible={Label="Mostrar killfeed",Default=true,Category="Interface",ModeOverride=true},
 ReticleColor={Label="Cor do retículo",Default=1,Choices={1,2,3,4,5,6},Labels={[1]="BRANCO",[2]="VERDE",[3]="CIANO",[4]="AMARELO",[5]="ROSA",[6]="VERMELHO"},Category="Reticle",ModeOverride=true},
 ReticleSize={Label="Comprimento do retículo",Default=4,Min=2,Max=16,Step=1,Category="Reticle",ModeOverride=true},
 ReticleThickness={Label="Espessura do retículo",Default=1,Min=1,Max=4,Step=1,Category="Reticle",ModeOverride=true},
 ReticleGap={Label="Abertura do retículo",Default=7,Min=2,Max=20,Step=1,Category="Reticle",ModeOverride=true},
 ReticleDot={Label="Ponto central",Default=true,Category="Reticle",ModeOverride=true},
 ReticleOutline={Label="Contorno do retículo",Default=true,Category="Reticle",ModeOverride=true},
 ReticleOpacity={Label="Opacidade do retículo",Default=1,Min=.2,Max=1,Step=.05,Percent=true,Category="Reticle",ModeOverride=true},
 ReticleDynamic={Label="Retículo dinâmico ao mover/disparar",Default=false,Category="Reticle",ModeOverride=true},
}
for key,rule in extra do Settings.Rules[key]=rule table.insert(Settings.Order,key) end
Settings.Rules.CameraMotion.ModeOverride=true Settings.Rules.DamageFlash.ModeOverride=true
local Layout=require(script.Parent.Crossgrounds.MobileLayout)
for action,data in Layout.Buttons do
 for _,field in {"X","Y","Size","Opacity"} do
  local limits=field=="Size" and {40,112} or field=="Opacity" and {.15,1} or {0,1}
  Settings.Rules[Layout.Key(action,field)]={Default=data[field],MobileLayout=true,Min=limits[1],Max=limits[2],Step=field=="Size" and 1 or field=="Opacity" and .01 or .0001}
 end
end
Settings.Groups={
 {Label="CÂMERA E VISUAL",Keys={"FieldOfView","CameraMotion","DamageFlash","FirstPerson","Shoulder","ShiftLock"}},
 {Label="MIRA E SENSIBILIDADE",Keys={"LookSensitivity","AimSensitivity","AimAssist","AimAssistStrength"}},
 {Label="CONTROLE · ANALÓGICOS",Keys={"LeftStickDeadzone","RightStickDeadzone","StickCurve","StickCurveStrength"}},
 {Label="ÁUDIO",Keys={"MenuVolume","MenuSFXVolume"}},
}
local Controls=require(script.Parent.ControlDefinitions)
for action,data in pairs(Controls.Actions) do
 for _,device in {"Gamepad","Keyboard"} do Settings.Rules[Controls:Attribute(action,device)]={Default=data[device],Device=device,Action=action} end
end
local categories={Gameplay={"AutoSprint"},Camera={"FieldOfView","WeaponFOVScale","FirstPerson","ShiftLock","Shoulder","CameraMotion"},Aim={"LookSensitivity","AimSensitivity","AimAssist","AimAssistStrength","AimAssistSlowdown","AimAssistTracking","AimAssistCentering"},Analog={"LeftStickDeadzone","RightStickDeadzone","StickCurve","StickCurveStrength"},Audio={"MenuVolume","MenuSFXVolume","GameSFXVolume","BeastProximityVolume"},Accessibility={"FontScale","HighContrast","ReducedMenuMotion","SimpleAnimations","WeaponAnimationIntensity","FOVTransitionSpeed","DamageFlash"},Interface={"MenuScale","HUDScale","KillFeedVisible"}}
categories.Reticle={"ReticleColor","ReticleSize","ReticleThickness","ReticleGap","ReticleDot","ReticleOutline","ReticleOpacity","ReticleDynamic"}
categories.Graphics={"GraphicsQuality"}
Settings.Categories=categories
Settings.Groups={}
for _,entry in {{"Gameplay","GERAL"},{"Camera","CÂMERA"},{"Aim","MIRA"},{"Reticle","RETÍCULO"},{"Analog","ANALÓGICOS"},{"Interface","INTERFACE"},{"Audio","ÁUDIO"},{"Graphics","GRÁFICOS"},{"Accessibility","ACESSIBILIDADE"}} do table.insert(Settings.Groups,{Label=entry[2],Keys=categories[entry[1]]}) end
for category,keys in categories do for _,key in keys do Settings.Rules[key].Category=category end end
for key,rule in Settings.Rules do
 rule.Id=key rule.Category=rule.Category or (rule.MobileLayout and "Touch" or rule.Device and "Bindings" or "Gameplay")
 rule.PreferenceDevice=rule.Device or rule.MobileLayout and "Touch" or table.find(categories.Analog,key) and "Gamepad" or key=="AutoSprint" and "Touch" or nil
 rule.Scope=rule.PreferenceDevice and "Device" or rule.ModeOverride and "Global+Mode" or "Global"
 rule.Type=rule.Device and "binding" or rule.Choices and "choice" or typeof(rule.Default)=="boolean" and "boolean" or "number"
 rule.Modes=rule.ModeOverride and {"ctf","arena"} or nil rule.Local=true rule.Experimental=false
 rule.Persistent=true rule.Apply="Setting"..key
end
function Settings:Allows(key,scope)
 local rule=self.Rules[key] if not rule then return false end
 if rule.PreferenceDevice then return scope=="Device:"..rule.PreferenceDevice end
 return scope=="Global" or rule.ModeOverride and (scope=="Mode:ctf" or scope=="Mode:arena") or false
end
function Settings:PreferenceAttribute(key,scope)
 return "Preference"..scope:gsub(":","")..key
end
function Settings:Sanitize(key,value)
 local rule=self.Rules[key] if not rule then return end
 if rule.Device then return Controls:IsAllowed(rule.Device,value,rule.Action) and value or nil end
 if typeof(rule.Default)=="boolean" then if typeof(value)=="boolean" then return value end return end
 if typeof(value)~="number" or value~=value or math.abs(value)==math.huge then return end
 if rule.Choices then return table.find(rule.Choices,value) and value or nil end
 return math.clamp(math.round((value-rule.Min)/rule.Step)*rule.Step+rule.Min,rule.Min,rule.Max)
end
function Settings:Format(key,value)
 local r=self.Rules[key] if r.Labels then return r.Labels[value] or tostring(value) end
 if typeof(value)=="boolean" then return value and "LIGADO" or "DESLIGADO" end
 if r.Percent or key=="MenuVolume" or key=="DamageFlash" or key=="CameraMotion" then return string.format("%d%%",value*100) end
 if key=="FieldOfView" then return string.format("%d°",value) end
 return string.format("%.2f",value)
end
return Settings

