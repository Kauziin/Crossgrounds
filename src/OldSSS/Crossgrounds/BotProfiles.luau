local Profiles={}
Profiles.Default="Regular"
Profiles.Difficulties={
 Recruit={Reaction={.7,1.1},Scan=.38,AimRate=85,TurnRate=100,Error=3.8,Lead=.03,Memory=2.8},
 Regular={Reaction={.45,.8},Scan=.28,AimRate=120,TurnRate=130,Error=2.6,Lead=.07,Memory=3.5},
 Veteran={Reaction={.3,.55},Scan=.24,AimRate=155,TurnRate=155,Error=1.8,Lead=.11,Memory=4},
 Elite={Reaction={.22,.4},Scan=.22,AimRate=180,TurnRate=170,Error=1.3,Lead=.14,Memory=4.5},
}
Profiles.Personalities={
 Aggressive={Engage=.2,Objective=-.05,Risk=.22,Cover=-.1},
 Defensive={Engage=-.08,Objective=.05,Risk=-.12,Cover=.25},
 Flanker={Engage=.08,Objective=.1,Risk=.06,Cover=.05},
 Objective={Engage=-.12,Objective=.28,Risk=-.04,Cover=.1},
 Support={Engage=-.03,Objective=.15,Risk=-.08,Cover=.15},
 Cautious={Engage=-.12,Objective=.02,Risk=-.2,Cover=.3},
}
Profiles.PersonalityOrder={"Aggressive","Defensive","Flanker","Objective","Support","Cautious"}
Profiles.Budget={PathsPerSecond=4,ConcurrentPaths=2,VisionPerSecond=120,DecisionInterval=.4,Tick=.05}
function Profiles.Resolve(difficulty,personality)
 return Profiles.Difficulties[difficulty] or Profiles.Difficulties[Profiles.Default],Profiles.Personalities[personality] or Profiles.Personalities.Objective
end
return Profiles
