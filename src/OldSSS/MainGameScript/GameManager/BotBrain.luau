-- Compatibility entry point; shared runtime owns updates and cancellation.
local Runtime=require(game.ServerScriptService.Crossgrounds.BotRuntime)
local Brain={}
function Brain:Start(bot,team,slot,flags,isActive) return Runtime:Start(bot,team,slot,flags,isActive) end
function Brain:Stop(bot) Runtime:Stop(bot) end
function Brain:Snapshot() return Runtime:Snapshot() end
return Brain
