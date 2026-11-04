local crossgrounds=script.Parent:FindFirstChild("Crossgrounds")
if crossgrounds then
 game:GetService("Players").CharacterAutoLoads=false
 workspace:SetAttribute("CrossgroundsBootReady",false)
 workspace:SetAttribute("CrossgroundsBootPhase","Iniciando experiência")
 workspace:SetAttribute("CrossgroundsBootError",nil)
 local ok,err=xpcall(function()require(crossgrounds.HubBootstrap):Start(script.GameManager)end,debug.traceback)
 if not ok then
  workspace:SetAttribute("CrossgroundsBootError","Não foi possível preparar a experiência. Tente entrar novamente.")
  workspace:SetAttribute("CrossgroundsBootPhase","Falha ao iniciar")
  warn("Crossgrounds bootstrap: "..tostring(err))
 end
else
 -- Compatibility path for recovering the original CTF without the hub package.
 local GameManager = require(script.GameManager)
 
 GameManager:Initialize()
 
 while true do
 	repeat
 		GameManager:RunIntermission()
 	until GameManager:GameReady()
 	
 	GameManager:StopIntermission()
 	GameManager:StartRound()	
 	
 	repeat
 		GameManager:Update()
 		wait()
 	until GameManager:RoundOver()
 	
 	GameManager:RoundCleanup()
 end
end

