exec((__import__('pathlib').Path(__file__).parent/'prepare.py').read_text().split("put('StarterPlayer.StarterPlayerScripts.InputMode'")[0])
name='StarterPlayer.StarterPlayerScripts.CombatPresentation'
edit(name,'local equippedAt=0 local firedAt=-100 local adsWeight=0','local equippedAt=0 local firedAt=-100 local adsWeight=0\nlocal poseRemote=game.ReplicatedStorage.Events:WaitForChild("CombatPose")\nlocal lastPoseAt=-100 local sentPitch=0 local sentAiming=false')
edit(name,'firedAt=os.clock()','firedAt=os.clock()\n  tool:SetAttribute("PresentationShotAt",workspace:GetServerTimeNow())')
edit(name,'if tool and tool.Parent and not already then Effects.Play(tool) Effects.PlaySound(tool) end','if tool and tool.Parent and not already then tool:SetAttribute("PresentationShotAt",workspace:GetServerTimeNow()) Effects.Play(tool) Effects.PlaySound(tool) end')
edit(name,'aimFrame=CFrame.new(cameraPosition)*rotation',r'''
 aimFrame=CFrame.new(cameraPosition)*rotation
 character:SetAttribute("CombatAimPitch",pitch)
 if os.clock()-lastPoseAt>=.10 and (math.abs(pitch-sentPitch)>.012 or aiming~=sentAiming or os.clock()-lastPoseAt>1) then
  poseRemote:FireServer(pitch,aiming) lastPoseAt=os.clock() sentPitch=pitch sentAiming=aiming
 end''')
edit('StarterPlayer.StarterPlayerScripts.AnalogMovement','if Mode:Get()~=Enum.PreferredInput.Gamepad then return original(self) end','if Mode:Get()~=Enum.PreferredInput.Gamepad then table.clear(gate) return Vector3.zero end')
# Add one more validated dependency from the main, for this copy only.
deps=json.loads((ROOT/'evidence.json').read_text())
(ROOT/'copy-dependencies.json').write_text(json.dumps(deps,indent=2),encoding='utf-8')
for name,entry in deps.items():
    put(name,entry['source'])
# The dependency is unchanged and must not be merged as our work.
baseline=json.loads((ROOT/'baseline.json').read_text()); baseline.update(deps)
(ROOT/'baseline.json').write_text(json.dumps(baseline,indent=2),encoding='utf-8')
print('Finished pose replication and copy dependencies')
