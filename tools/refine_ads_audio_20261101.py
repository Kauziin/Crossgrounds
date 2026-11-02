from pathlib import Path
import shutil
def edit(name,fn):
 p=Path('src',name+'.luau'); b=Path('artifacts/ads-audio-2026-11-01/before',name+'.luau'); b.parent.mkdir(parents=True,exist_ok=True); shutil.copy2(p,b); p.write_text(fn(p.read_text(encoding='utf-8')),encoding='utf-8')
edit('StarterPlayer/StarterPlayerScripts/CombatPresentation',lambda s:s.replace('sight=sightProfile,firedAgo=', 'sight=sightProfile,sightActive=aiming,firedAgo=').replace('renderer.opticalAperture or nil)','renderer.opticalAperture or nil,aiming)'))
edit('StarterPlayer/StarterPlayerScripts/OpticalSight',lambda s:s.replace('progress,aperture)','progress,aperture,active)').replace('local transition=ADS.Sample(progress==nil and 1 or progress,profile)','local transition=ADS.Sample(progress==nil and 1 or progress,profile)\n transition.reticle=active==false and 0 or 1 transition.peripheral=transition.reticle').replace('local opacity=aperture and aperture.visible or transition.reticle','local opacity=active==false and 0 or (aperture and aperture.visible or transition.reticle)'))
def render(s):
 s=s.replace('local transition=ADS.Sample(params.sight and params.ads or 0,params.sight)','local transition=ADS.Sample(params.sight and params.ads or 0,params.sight)\n transition.reticle=params.sightActive and 1 or 0\n transition.lens=params.sightActive and 1 or 0')
 s=s.replace('aligned=aligned*CFrame.new(breath,breath*.55,0)', '''local tilt=math.rad(-4)*transition.alignment
  aligned=aligned*CFrame.new(self.optic.center)*CFrame.Angles(tilt,0,0)*CFrame.new(-self.optic.center)
  aligned=aligned*CFrame.new(breath,breath*.55,0)''')
 s=s.replace('or bore and transition.lens*(1-bolt.active)', '')
 s=s.replace('arm.part.LocalTransparencyModifier=self.optic and transition.arms*(1-bolt.active) or transition.arms','arm.part.LocalTransparencyModifier=self.optic and 0 or transition.arms')
 return s
edit('StarterPlayer/StarterPlayerScripts/FirstPersonRenderer',render)
