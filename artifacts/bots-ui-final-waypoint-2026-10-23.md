# Regressão final de waypoints

Suíte: 133/133. Snapshot da rodada de 30 segundos posterior à correção de altura de waypoint. Bots mortos durante a amostra não aparecem em travel; active=11 nesse instante é compatível com o intervalo de respawn. Sem comparação controlada de dificuldade ou performance.

```json
{
  "tests": {
    "passed": 133,
    "failed": 0,
    "run": 133,
    "results": [
      {
        "name": "GameCatalog_Test > CTF and Arena are prototypes with no fabricated Arena capacity",
        "passed": true
      },
      {
        "name": "GameCatalog_Test > planned games have no numeric capacity",
        "passed": true
      },
      {
        "name": "GameCatalog_Test > catalog snapshots are isolated",
        "passed": true
      },
      {
        "name": "SessionProtocol_Test > accepts join and ticket commands",
        "passed": true
      },
      {
        "name": "SessionProtocol_Test > rejects client destination injection",
        "passed": true
      },
      {
        "name": "SessionProtocol_Test > rejects malformed tickets",
        "passed": true
      },
      {
        "name": "SessionProtocol_Test > rejects invalid commands",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > requires readiness and consumes only once",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > rejects duplicate join",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > stale cancellation preserves the active ticket",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > cancel prevents delayed readiness",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > does not falsely cancel an ongoing transition",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > ignores failure for an old ticket",
        "passed": true
      },
      {
        "name": "QueueProvider_Test > isolates player and snapshot state",
        "passed": true
      },
      {
        "name": "TravelService_Test > rejects absent and external destinations",
        "passed": true
      },
      {
        "name": "TravelService_Test > rejects wrong Universe approval",
        "passed": true
      },
      {
        "name": "TravelService_Test > rejects disabled transport",
        "passed": true
      },
      {
        "name": "TravelService_Test > Studio never sends a real teleport",
        "passed": true
      },
      {
        "name": "TravelService_Test > membership lookup failure is recoverable",
        "passed": true
      },
      {
        "name": "TravelService_Test > local preparation has no teleport call",
        "passed": true
      },
      {
        "name": "TravelService_Test > verified request sends once and blocks duplicate",
        "passed": true
      },
      {
        "name": "TravelService_Test > late transport failure releases the player for retry",
        "passed": true
      },
      {
        "name": "TravelService_Test > unconfirmed travel times out",
        "passed": true
      },
      {
        "name": "TravelService_Test > transport exception does not leave a pending request",
        "passed": true
      },
      {
        "name": "TravelService_Test > forget prevents a late failure callback",
        "passed": true
      },
      {
        "name": "MapBallot_Test > rejects maps outside current options",
        "passed": true
      },
      {
        "name": "MapBallot_Test > repeated votes count once",
        "passed": true
      },
      {
        "name": "MapBallot_Test > changing a vote removes the old choice",
        "passed": true
      },
      {
        "name": "MapBallot_Test > departure removes a vote",
        "passed": true
      },
      {
        "name": "MapBallot_Test > majority determines the winner",
        "passed": true
      },
      {
        "name": "MapBallot_Test > ties prefer another map",
        "passed": true
      },
      {
        "name": "MapBallot_Test > fresh ballots reset counts",
        "passed": true
      },
      {
        "name": "Ballistics_Test > allies and their accessories do not consume penetration",
        "passed": true
      },
      {
        "name": "Ballistics_Test > ordinary guns stop at the first enemy",
        "passed": true
      },
      {
        "name": "Ballistics_Test > cover before targets blocks all damage",
        "passed": true
      },
      {
        "name": "Ballistics_Test > cover after first enemy stops penetration",
        "passed": true
      },
      {
        "name": "Ballistics_Test > rejected protected targets do not leak damage behind them",
        "passed": true
      },
      {
        "name": "Ballistics_Test > a character cannot be damaged twice through different body parts",
        "passed": true
      },
      {
        "name": "Ballistics_Test > ignored corpses allow a full damage first target",
        "passed": true
      },
      {
        "name": "Ballistics_Test > penetration composes with falloff and headshots",
        "passed": true
      },
      {
        "name": "MuzzleOrigin_Test > bounded first person muzzle origin is accepted",
        "passed": true
      },
      {
        "name": "MuzzleOrigin_Test > sideways and distant requests fall back to the real barrel",
        "passed": true
      },
      {
        "name": "MuzzleOrigin_Test > cover between head and barrel blocks a shot",
        "passed": true
      },
      {
        "name": "MuzzleOrigin_Test > an allied character between head and muzzle is ignored",
        "passed": true
      },
      {
        "name": "WeaponRecoil_Test > recoil returns to rest after a shot",
        "passed": true
      },
      {
        "name": "WeaponRecoil_Test > 30 and 144 fps produce similar peak kick",
        "passed": true
      },
      {
        "name": "WeaponRecoil_Test > sustained fire remains bounded and reset clears motion",
        "passed": true
      },
      {
        "name": "MapLibrary_Test > separates Arena and Get Out maps",
        "passed": true
      },
      {
        "name": "MapLibrary_Test > does not accept paths or unknown identifiers",
        "passed": true
      },
      {
        "name": "MapLibrary_Test > unprepared and disabled maps cannot enter voting",
        "passed": true
      },
      {
        "name": "MapSpawns_Test > authored spawn zones reject outside markers and respect rotation",
        "passed": true
      },
      {
        "name": "MapSpawns_Test > requires solid support below the character",
        "passed": true
      },
      {
        "name": "MapSpawns_Test > rejects a low ceiling intersecting character clearance",
        "passed": true
      },
      {
        "name": "MapSpawns_Test > indoor sampling stays below the roof and spreads points",
        "passed": true
      },
      {
        "name": "ArenaRewards_Test > training eliminations award 10 XP without PvP kills",
        "passed": true
      },
      {
        "name": "ArenaRewards_Test > body and headshot rewards accumulate within the session",
        "passed": true
      },
      {
        "name": "ArenaRewards_Test > Arena health allows a pistol body hit at the end of falloff",
        "passed": true
      },
      {
        "name": "Locomotion_Test > running sweep is slower and has a wide lateral travel",
        "passed": true
      },
      {
        "name": "Locomotion_Test > zero motion amount produces no carry animation",
        "passed": true
      },
      {
        "name": "Locomotion_Test > sprint pose returns when aiming and firing",
        "passed": true
      },
      {
        "name": "Locomotion_Test > run pose remains bounded at 30 and 144 fps",
        "passed": true
      },
      {
        "name": "Locomotion_Test > airborne character does not continue building sprint pose",
        "passed": true
      },
      {
        "name": "Locomotion_Test > camera has stronger running lean and resets pitch",
        "passed": true
      },
      {
        "name": "Locomotion_Test > camera motion is absent with the option disabled",
        "passed": true
      },
      {
        "name": "AimAssist_Test > allies corpses protection and inactive shooters are rejected",
        "passed": true
      },
      {
        "name": "AimAssist_Test > Arena targets require an active Arena shooter",
        "passed": true
      },
      {
        "name": "AimAssist_Test > walls behind-camera targets and maximum range prevent selection",
        "passed": true
      },
      {
        "name": "AimAssist_Test > near body window expands with apparent size rather than a fixed cone",
        "passed": true
      },
      {
        "name": "AimAssist_Test > anchor follows the player's chosen area instead of the center",
        "passed": true
      },
      {
        "name": "AimAssist_Test > stationary targets never attract aim even with right stick or strafe",
        "passed": true
      },
      {
        "name": "AimAssist_Test > moving target cannot rotate an idle player's camera",
        "passed": true
      },
      {
        "name": "AimAssist_Test > tracking helps matching input and yields to opposing input",
        "passed": true
      },
      {
        "name": "AimAssist_Test > tracking contribution is partial and rate-limited at close distance",
        "passed": true
      },
      {
        "name": "AimAssist_Test > distance removes rotation and tapers friction",
        "passed": true
      },
      {
        "name": "AimAssist_Test > zero master and independent component controls work",
        "passed": true
      },
      {
        "name": "AimAssist_Test > new target has a reaction interval and walls reset assistance immediately",
        "passed": true
      },
      {
        "name": "AimAssist_Test > changing the selected enemy does not inherit tracking velocity",
        "passed": true
      },
      {
        "name": "AimAssist_Test > large frame hitches produce no catch-up jump",
        "passed": true
      },
      {
        "name": "AimAssist_Test > fast manual turns receive less friction",
        "passed": true
      },
      {
        "name": "AimAssist_Test > tracking is consistent across 30 60 and 120 FPS",
        "passed": true
      },
      {
        "name": "AnalogFilter_Test > defaults suppress 5 percent left and 10 percent right drift",
        "passed": true
      },
      {
        "name": "AnalogFilter_Test > radial rescaling preserves direction and full tilt",
        "passed": true
      },
      {
        "name": "AnalogFilter_Test > zero deadzone and negative axis work without NaN",
        "passed": true
      },
      {
        "name": "AnalogFilter_Test > settings clamp out of range values and format percentages",
        "passed": true
      },
      {
        "name": "ArenaAccessibility_Test > Arena is first person for every weapon and firearms always lock",
        "passed": true
      },
      {
        "name": "ArenaAccessibility_Test > dynamic response is monotonic symmetric and preserves maximum speed",
        "passed": true
      },
      {
        "name": "ArenaAccessibility_Test > touch turns match screen fraction and sensitivity clamps at four",
        "passed": true
      },
      {
        "name": "ArenaAccessibility_Test > default touch buttons are separated across phone and tablet viewports",
        "passed": true
      },
      {
        "name": "ArenaAccessibility_Test > every editable HUD field rejects invalid values and stays inside limits",
        "passed": true
      },
      {
        "name": "ArenaRefinement_Test > Arena round, reload and cooldown are configured independently from CTF",
        "passed": true
      },
      {
        "name": "ArenaRefinement_Test > all six loadouts have names and both weapons",
        "passed": true
      },
      {
        "name": "ArenaRefinement_Test > reload returns exactly to rest and separates the magazine or cylinder",
        "passed": true
      },
      {
        "name": "ArenaRefinement_Test > standings sort deterministically and award the podium only once",
        "passed": true
      },
      {
        "name": "BugRegression_Test > bots have bounded deliberate misses and role-specific accuracy",
        "passed": true
      },
      {
        "name": "BugRegression_Test > a spawn with a single narrow way out is rejected",
        "passed": true
      },
      {
        "name": "ProgressionPolicy_Test > bots give 50 XP with no headshot bonus",
        "passed": true
      },
      {
        "name": "ProgressionPolicy_Test > training gives 10 XP and no combat kill",
        "passed": true
      },
      {
        "name": "ProgressionPolicy_Test > missing and unrelated records never qualify as played",
        "passed": true
      },
      {
        "name": "ProgressionPolicy_Test > friend limit applies to eligible records, not the first friends",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > all existing guns retain hitscan and their cadence",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > spread is repeatable across client/server and varies between pellets",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > ledger rejects replay, out of order, jumps and floods",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > cadence tolerance cannot accumulate a faster firing rate",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > predicted ammo is reserved and authoritative rejection restores it",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > travel and acceleration agree at 30, 60 and 120 simulated FPS",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > swept casts detect thin obstacles at high speed and variable dt",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > lifetime, range and cancellation stop logical projectiles",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > spherecast is selected for configured collision volume",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > penetration carries across simulation steps without double damage",
        "passed": true
      },
      {
        "name": "ShotPipeline_Test > a volume starting inside solid geometry terminates immediately",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > client timestamps cannot choose arbitrary rewind",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > oriented box intersection preserves range and direction",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > parallel rays outside a hitbox miss",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > history restores moving hitboxes but current walls still block",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > history preserves penetration loss and protected target blocking",
        "passed": true
      },
      {
        "name": "ShotHistory_Test > history never resurrects a dead target or crosses a large teleport",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > close targets behind the bot are outside the visual cone",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > difficulty and personality do not change weapon damage or health",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > utility preserves commitment and exits combat when vision is lost",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > aim rotation is bounded by angular speed and deltaTime",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > waypoint arrival tolerates root height without accepting another floor",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > perception loses covered targets without updating their hidden position",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > NPC shot uses shared ammo, cadence and real obstruction",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > NPC reload consumes finite reserve and cancels when invalidated",
        "passed": true
      },
      {
        "name": "BotIntelligence_Test > shared scheduler executes decisions and cancels the controller",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > old flat preferences migrate without losing device controls",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > global and mode overrides resolve without copying global values",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > restore a default differs from removing an override, including false",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > corrupt and unknown fields fall back safely",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > unimplemented modes and disallowed scope matrices cannot be written",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > scales and numeric values are finite, stepped and bounded",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > profiles and default tables are isolated between players",
        "passed": true
      },
      {
        "name": "PreferenceProfile_Test > registered options have explicit categories, scope and applicators",
        "passed": true
      }
    ]
  },
  "round": {
    "before": {
      "meanFirstShotDelay": 0,
      "targetChangesPerMinute": 0,
      "active": 0,
      "elapsed": 28.33350859998609,
      "pathsPerMinute": 60,
      "bands": {
        "Mid": {
          "hits": 0,
          "shots": 0
        },
        "Near": {
          "hits": 0,
          "shots": 0
        },
        "Far": {
          "hits": 0,
          "shots": 0
        }
      },
      "decisions": 1,
      "targetChanges": 0,
      "hits": 0,
      "activeHits": 0,
      "connected": false,
      "vision": 0,
      "meanTickMs": 0.2831833213955785,
      "navigation": {
        "concurrent": 0,
        "failures": 0,
        "maxConcurrent": 1,
        "abandoned": 0,
        "stuck": 0,
        "computations": 1,
        "queued": 0,
        "recoveries": 0
      },
      "activeShots": 0,
      "shots": 0,
      "peakTickMs": 1.3427999801933765,
      "activeSeconds": 0.4219868406653404,
      "decisionDelayMs": 48.77260001376271,
      "activeIdleSeconds": 0,
      "errors": 0
    },
    "cleanup": {
      "meanFirstShotDelay": 0.6408640799927525,
      "targetChangesPerMinute": 48.11381643914408,
      "active": 0,
      "elapsed": 59.56015629999456,
      "pathsPerMinute": 128.94502805690612,
      "bands": {
        "Mid": {
          "hits": 10,
          "shots": 15
        },
        "Near": {
          "hits": 0,
          "shots": 0
        },
        "Far": {
          "hits": 26,
          "shots": 316
        }
      },
      "decisions": 691,
      "targetChanges": 25,
      "hits": 36,
      "activeHits": 0,
      "connected": false,
      "vision": 771,
      "meanTickMs": 1.9580060463848112,
      "navigation": {
        "concurrent": 0,
        "failures": 0,
        "maxConcurrent": 2,
        "abandoned": 0,
        "stuck": 23,
        "computations": 67,
        "queued": 0,
        "recoveries": 20
      },
      "activeShots": 0,
      "shots": 331,
      "peakTickMs": 6.7857000103686005,
      "activeSeconds": 31.176076042465866,
      "decisionDelayMs": 49.227036569940054,
      "activeIdleSeconds": 0,
      "errors": 0
    },
    "after": {
      "meanFirstShotDelay": 0.6408640799927525,
      "targetChangesPerMinute": 48.25010546669619,
      "active": 11,
      "elapsed": 59.063349100004416,
      "pathsPerMinute": 129.3102826507458,
      "bands": {
        "Mid": {
          "hits": 10,
          "shots": 15
        },
        "Near": {
          "hits": 0,
          "shots": 0
        },
        "Far": {
          "hits": 26,
          "shots": 316
        }
      },
      "decisions": 691,
      "targetChanges": 25,
      "hits": 36,
      "activeHits": 29,
      "connected": true,
      "vision": 771,
      "meanTickMs": 1.962562703846635,
      "navigation": {
        "concurrent": 0,
        "failures": 0,
        "maxConcurrent": 2,
        "abandoned": 0,
        "stuck": 23,
        "computations": 67,
        "queued": 0,
        "recoveries": 20
      },
      "activeShots": 280,
      "shots": 331,
      "peakTickMs": 6.7857000103686005,
      "activeSeconds": 31.088014948181808,
      "decisionDelayMs": 49.227036569940054,
      "activeIdleSeconds": 187.60945440022624,
      "errors": 0
    },
    "travel": [
      {
        "state": "Objective",
        "name": "Red_AI_6",
        "waypoint": 8,
        "stuck": 2,
        "route": "goal_changed",
        "travel": 121.37794494628906,
        "idle": 14.27408010000363
      },
      {
        "state": "Objective",
        "name": "Blue_AI_11",
        "waypoint": 2,
        "stuck": 5,
        "route": "recover_2",
        "travel": 40.85495376586914,
        "idle": 21.063148600049317
      },
      {
        "state": "Objective",
        "name": "Red_AI_3",
        "waypoint": 3,
        "stuck": 2,
        "route": "recover_1",
        "travel": 134.40626525878906,
        "idle": 19.448247700056527
      },
      {
        "state": "Objective",
        "name": "Red_AI_5",
        "waypoint": 5,
        "stuck": 0,
        "route": "goal_changed",
        "travel": 41.98276901245117,
        "idle": 23.71057940000901
      },
      {
        "state": "Objective",
        "name": "Blue_AI_12",
        "waypoint": 12,
        "stuck": 5,
        "route": "goal_changed",
        "travel": 72.74628448486328,
        "idle": 16.777762900019297
      },
      {
        "state": "Objective",
        "name": "Blue_AI_9",
        "waypoint": 2,
        "stuck": 3,
        "route": "recover_1",
        "travel": 136.2907257080078,
        "idle": 19.51225910006906
      },
      {
        "state": "Retreat",
        "name": "Red_AI_4",
        "waypoint": 2,
        "stuck": 2,
        "route": "goal_changed",
        "travel": 194.2185821533203,
        "idle": 15.739321900036884
      },
      {
        "state": "Objective",
        "name": "Red_AI_2",
        "waypoint": 4,
        "stuck": 1,
        "route": "goal_changed",
        "travel": 230.70957946777344,
        "idle": 15.263079800002743
      },
      {
        "state": "Objective",
        "name": "Blue_AI_8",
        "waypoint": 3,
        "stuck": 1,
        "route": "recover_1",
        "travel": 157.2249755859375,
        "idle": 19.416686699929414
      },
      {
        "state": "Objective",
        "name": "Red_AI_1",
        "waypoint": 7,
        "stuck": 1,
        "route": "goal_changed",
        "travel": 196.48489379882812,
        "idle": 17.295122000039555
      }
    ],
    "states": {
      "Patrol": true,
      "Retreat": true,
      "Engage": true,
      "Search": true,
      "Objective": true
    }
  }
}
```
