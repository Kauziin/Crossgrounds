-- Weapon-space kick (studs/degrees) and recoverable camera displacement (degrees).
local Profiles={
 ak_47={Push=.85,Pitch=3,Roll=.65,Lift=.65,Restart=true,Spring=150,Damping=23,ReturnDelay=.10,Sustain=.15,CameraRise=2.0,CameraSide=.38},
 m13={Push=.20,Pitch=2.1,Roll=.25,Spring=230,Damping=30,ReturnDelay=.08,Sustain=.10,CameraRise=.35,CameraSide=.08},
 cr_56_amax={Push=.35,Pitch=8.2,Roll=.8,Spring=190,Damping=26,ReturnDelay=.13,Sustain=.22,CameraRise=1.5,CameraSide=.16},
 fr_5_56={Push=.28,Pitch=3.4,Roll=.35,Spring=155,Damping=25,ReturnDelay=.18,Sustain=.24,CameraRise=.7,CameraSide=.08},
 scar_h={Push=1.05,Pitch=2.8,Roll=.65,Spring=130,Damping=23,ReturnDelay=.16,Sustain=.13,CameraRise=.6,CameraSide=.14},
 ax_50={Push=1.05,Pitch=7,Roll=1.6,Spring=130,Damping=22,ReturnDelay=.16,Sustain=.15,CameraRise=2.2,CameraSide=.25},
 hdr={Push=.75,Pitch=4.5,Roll=.95,Spring=155,Damping=25,ReturnDelay=.14,Sustain=.12,CameraRise=1.4,CameraSide=.16},
 rytec_amr={Push=1.40,Pitch=9.4,Roll=2.1,Spring=120,Damping=21,ReturnDelay=.19,Sustain=.20,CameraRise=3.0,CameraSide=.32},
 barrett_m82={Push=1.40,Pitch=9.2,Roll=2.0,Spring=120,Damping=21,ReturnDelay=.19,Sustain=.20,CameraRise=2.9,CameraSide=.30},
 dragunov={Push=1.05,Pitch=8.6,Roll=1.7,Spring=140,Damping=23,ReturnDelay=.17,Sustain=.22,CameraRise=2.5,CameraSide=.28},
 kar98k={Push=.85,Pitch=5.8,Roll=1.25,Spring=155,Damping=24,ReturnDelay=.14,Sustain=.13,CameraRise=1.8,CameraSide=.20},
}
local API={Profiles=Profiles}
function API.Apply(weapons)
 for id,profile in Profiles do if weapons[id] then weapons[id].VisualRecoil=table.clone(profile) weapons[id].RecoverableRecoil=true end end
end
return API
