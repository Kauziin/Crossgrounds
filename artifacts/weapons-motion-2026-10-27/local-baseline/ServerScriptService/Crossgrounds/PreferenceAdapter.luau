-- Reuses the existing schema/store; no cross-Universe data migration.
local Adapter={}
local definitions=require(game.ReplicatedStorage.ExperienceSettings)
function Adapter:Describe()
 return {scope="currentUniverse",universeId=game.GameId,store="CTF_ExperienceSettings_v1",studioSessionOnly=game:GetService("RunService"):IsStudio(),schemaChanged=true,schemaVersion=2}
end
function Adapter:Validate(key,value) return definitions:Sanitize(key,value) end
return Adapter

