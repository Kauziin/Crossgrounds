-- Shared display contract. Only the server records progress or grants prestige.
local S={Modes={"general","arena","get_out","duels","ctf"},Names={general="Geral",arena="Arena",get_out="Get Out",duels="Duels",ctf="Capture The Flag"},Primary={arena="Kills",get_out="Wins",duels="Wins",ctf="Captures"}}
S.Fields={"XP","Coins","Kills","Deaths","Captures","PlaySeconds","BotKills","TrainingKills","Wins","Losses","Escapes","SurvivorWins","BeastWins"}
S.Labels={XP="XP total",Level="Nível",Coins="Moedas",Kills="Eliminações",Deaths="Mortes",Captures="Bandeiras",PlaySeconds="Tempo jogado",BotKills="Contra bots",TrainingKills="Alvos de treino",Wins="Vitórias",Losses="Derrotas",Escapes="Fugas",SurvivorWins="Vitórias como sobrevivente",BeastWins="Vitórias como besta",Ratio="Relação E/M"}
S.Metrics={general={"XP","Level","Kills","Wins","Captures"},arena={"Kills","XP"},get_out={"Wins","Escapes","SurvivorWins","BeastWins"},duels={"Wins","Kills"},ctf={"Captures","Kills","Wins","XP"}}
S.Display={general={"Kills","Deaths","Ratio","Wins","Captures","Coins","PlaySeconds","TrainingKills","BotKills"},arena={"Kills","Deaths","Ratio","XP","PlaySeconds"},get_out={"Wins","Escapes","SurvivorWins","BeastWins","Losses","PlaySeconds"},duels={"Wins","Losses","Kills","Deaths","Ratio","PlaySeconds"},ctf={"Captures","Kills","Deaths","Ratio","Wins","XP","PlaySeconds"}}
function S.Key(mode,key) return mode=="general" and key or mode.."_"..key end
function S.Level(xp) return math.floor((xp/250)^(1/1.45))+1 end
function S.Value(data,mode,key)
 if key=="Level" then return S.Level(data[S.Key(mode,"XP")] or 0) end
 if key=="Ratio" then return (data[S.Key(mode,"Kills")] or 0)/math.max(1,data[S.Key(mode,"Deaths")] or 0) end
 return data[S.Key(mode,key)] or 0
end
function S.Format(key,value)
 if key=="Ratio" then return string.format("%.2f",value) end
 if key=="PlaySeconds" then return math.floor(value/60).." min" end
 return tostring(math.floor(value))
end
function S.Valid(mode,metric) return S.Metrics[mode] and table.find(S.Metrics[mode],metric)~=nil end
return S
