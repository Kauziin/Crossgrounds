# Validação da versão empacotada

Execução posterior à correção de cache de MoveTo e aos botões de 44 px da UI. Sem alegação de benchmark comparativo.

```json
{
  "tests": {
    "run": 133,
    "failed": 0,
    "passed": 133
  },
  "smoke": {
    "cleanup": {
      "meanFirstShotDelay": 0.5961677199957194,
      "targetChangesPerMinute": 43.93180536930671,
      "active": 0,
      "elapsed": 46.046733700000914,
      "pathsPerMinute": 135.45639988869567,
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
          "hits": 3,
          "shots": 106
        }
      },
      "decisions": 368,
      "targetChanges": 12,
      "hits": 3,
      "activeHits": 0,
      "connected": false,
      "vision": 256,
      "meanTickMs": 1.40101223619643,
      "navigation": {
        "concurrent": 0,
        "failures": 0,
        "maxConcurrent": 2,
        "abandoned": 0,
        "stuck": 7,
        "computations": 37,
        "queued": 0,
        "recoveries": 5
      },
      "activeShots": 0,
      "shots": 106,
      "peakTickMs": 4.184199991868809,
      "activeSeconds": 16.389037371613085,
      "decisionDelayMs": 52.58155711682933,
      "activeIdleSeconds": 0,
      "errors": 0
    },
    "after": {
      "meanFirstShotDelay": 0.5961677199957194,
      "targetChangesPerMinute": 44.071628079626294,
      "active": 12,
      "elapsed": 44.92954379998264,
      "pathsPerMinute": 135.88751991218106,
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
          "hits": 3,
          "shots": 106
        }
      },
      "decisions": 368,
      "targetChanges": 12,
      "hits": 3,
      "activeHits": 3,
      "connected": true,
      "vision": 256,
      "meanTickMs": 1.4069351692974046,
      "navigation": {
        "concurrent": 0,
        "failures": 0,
        "maxConcurrent": 2,
        "abandoned": 0,
        "stuck": 7,
        "computations": 37,
        "queued": 0,
        "recoveries": 5
      },
      "activeShots": 106,
      "shots": 106,
      "peakTickMs": 4.184199991868809,
      "activeSeconds": 16.337041116319597,
      "decisionDelayMs": 52.58155711682933,
      "activeIdleSeconds": 76.56447229985497,
      "errors": 0
    },
    "sample": [
      {
        "state": "Search",
        "idle": 3.821366499993019,
        "waypoint": 7,
        "speed": 0.05755435675382614,
        "distance": 2.4651529788970947,
        "travel": 188.94273922778666,
        "route": "goal_changed"
      },
      {
        "state": "Engage",
        "idle": 6.526598100026604,
        "waypoint": 2,
        "speed": 0.00010401441977592185,
        "distance": 3.5657992362976074,
        "travel": 148.50923359394073,
        "route": "goal_changed"
      },
      {
        "state": "Engage",
        "idle": 4.763387799990596,
        "waypoint": 2,
        "speed": 0.00013306320761330426,
        "distance": 3.0061590671539307,
        "travel": 168.85486769676208,
        "route": "goal_changed"
      },
      {
        "state": "Objective",
        "idle": 6.22310929998639,
        "waypoint": 10,
        "speed": 0.00010404919885331765,
        "distance": 3.5761799812316895,
        "travel": 134.94941586832283,
        "route": "goal_changed"
      },
      {
        "state": "Objective",
        "idle": 5.499724499997683,
        "waypoint": 9,
        "speed": 7.678538054278761e-7,
        "distance": 3.1932427883148193,
        "travel": 119.89437428116798,
        "route": "goal_changed"
      },
      {
        "state": "Objective",
        "idle": 7.859816299955128,
        "waypoint": 6,
        "speed": 0.00010399706661701202,
        "travel": 87.49693601601757,
        "route": "recover_2"
      },
      {
        "state": "Objective",
        "idle": 7.047481699933996,
        "waypoint": 5,
        "speed": 0.0002080389385810122,
        "distance": 4.608513832092285,
        "travel": 143.3388941475423,
        "route": "recover_1"
      },
      {
        "state": "Objective",
        "idle": 7.424866299988935,
        "waypoint": 4,
        "speed": 0.0002227560617029667,
        "distance": 5.014705657958984,
        "travel": 126.7519090619171,
        "route": "recover_1"
      },
      {
        "state": "Objective",
        "idle": 3.9455727000022307,
        "waypoint": 3,
        "speed": 0.013533564284443855,
        "distance": 4.829989433288574,
        "travel": 175.21651184558868,
        "route": "goal_changed"
      },
      {
        "state": "Engage",
        "idle": 2.2010204999824055,
        "waypoint": 3,
        "speed": 0.0001040141869452782,
        "distance": 5.641053199768066,
        "travel": 232.074646234978,
        "route": "goal_changed"
      },
      {
        "state": "Objective",
        "idle": 9.814778299973113,
        "waypoint": 8,
        "speed": 0.00010407125228084624,
        "travel": 59.4336579890296,
        "route": "goal_changed"
      },
      {
        "state": "Objective",
        "idle": 6.152378699975088,
        "waypoint": 20,
        "speed": 0.13638147711753845,
        "travel": 120.36134668168961,
        "route": "goal_changed"
      }
    ]
  },
  "ui": {
    "minusHeight": 57.19999694824219,
    "font": 27,
    "canvas": 2047.4998779296875,
    "viewport": 430.29998779296875,
    "defaultHeight": 57.19999694824219,
    "back": true,
    "panes": [
      "Detail"
    ]
  }
}
```
