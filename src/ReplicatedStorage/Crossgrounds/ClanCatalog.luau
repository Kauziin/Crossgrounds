-- Version 1 curve; changing it requires an explicit progression migration.
local C={Version=1}
C.IdentityReward={Level=3,ContributionXP=1000,Name="Identidade do clã"}
C.Emblems={star={name="Estrela",glyph="★"},diamond={name="Diamante",glyph="◆"},spark={name="Centelha",glyph="✦"}}
C.Colors={teal={name="Turquesa",rgb={48,205,195}},violet={name="Violeta",rgb={165,112,224}},gold={name="Ouro",rgb={239,193,75}},red={name="Carmim",rgb={224,94,107}}}
C.Fields={"XP","Kills","Deaths","Captures","Wins","BotKills"}
C.Modes={"arena","ctf","get_out","duels"}
function C.Threshold(level)return 5000*(math.max(1,math.floor(level))-1)^2 end
function C.Level(xp)return math.floor(math.sqrt(math.max(0,xp)/5000))+1 end
function C.Code(id)return id:gsub("%-",""):sub(1,8):upper()end
function C.Keys()
 local keys=table.clone(C.Fields)
 for _,mode in C.Modes do for _,field in C.Fields do table.insert(keys,mode.."_"..field)end end
 return keys
end
return C
