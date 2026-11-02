-- Creator Store sources verified 2026-10-27; all entries are local event cues.
-- Roblox UI SFX and Alexware's Human_Heartbeat_Full_01 (2936809023).
local function cue(id,gain,pitch,cooldown,scope)
 return {id="rbxassetid://"..id,gain=gain,pitch=pitch or 1,cooldown=cooldown or .25,scope=scope,fallback="rbxasset://sounds/volume_slider.ogg"}
end
return {
 FlagStolen=cue("10066926605",.85,.8,.5,"ctf"),
 FlagPickup=cue("10128760939",.65,1.1,.4,"ctf"),
 FlagDropped=cue("10066926605",.55,1,.4,"ctf"),
 FlagReturned=cue("10066968815",.65,.9,.4,"ctf"),
 FlagCaptured=cue("10066947742",.8,1,.5,"ctf"),
 FlagLost=cue("10066926605",.85,.65,.5,"ctf"),
 Eliminated=cue("10066926605",.65,.65,1,"combatMode"),
 Respawn=cue("10128766965",.4,.85,1,"combat"),
 RoundStart=cue("10128766965",.65,1,.8,"match"),
 RoundEnd=cue("10066968815",.65,.8,.8,"match"),
 Hurt=cue("10066936758",.24,.6,.5,"combat"),
 HackCheck=cue("10066931761",.5,1.25,.3,"get_out"),
 HackError=cue("10066926605",.6,.85,.7,"get_out"),
 ComputerComplete=cue("10066947742",.65,1,.5,"get_out"),
 Downed=cue("10066926605",.65,.7,.6,"get_out"),
 Captured=cue("10066926605",.7,.6,.6,"get_out"),
 Rescued=cue("10066968815",.6,1.1,.6,"get_out"),
 Escaped=cue("10066947742",.65,1.1,1,"get_out"),
 BeastEnraged=cue("10066926605",.65,.55,1,"get_out"),
 BeastPulse={id="rbxassetid://2936809023",gain=.9,pitch=1,cooldown=.28,scope="get_out",setting="BeastProximityVolume",fallback="rbxasset://sounds/action_footsteps_plastic.mp3"},
}
