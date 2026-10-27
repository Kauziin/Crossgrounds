# Evidências de testes — Bots e UI

Capturas estruturadas de execuções reais no Studio, Place 4375993208. Testes por Script/LocalScript normal; MCP usado para instalar os fixtures e coletar resultados. A execução em máquina local não mede produção ou desempenho em console/celular.

```json
{
  "finalRegression": {
    "runtime": "{\"meanFirstShotDelay\":0,\"targetChangesPerMinute\":0,\"active\":0,\"elapsed\":36.54530560001149,\"pathsPerMinute\":240,\"bands\":{\"Mid\":{\"hits\":0,\"shots\":0},\"Near\":{\"hits\":0,\"shots\":0},\"Far\":{\"hits\":0,\"shots\":0}},\"decisions\":1,\"targetChanges\":0,\"hits\":0,\"activeHits\":0,\"connected\":false,\"vision\":0,\"meanTickMs\":0.21075714279764466,\"navigation\":{\"concurrent\":0,\"failures\":4,\"maxConcurrent\":1,\"abandoned\":1,\"stuck\":1,\"computations\":4,\"queued\":0,\"recoveries\":1},\"activeShots\":0,\"shots\":0,\"peakTickMs\":1.1168000055477024,\"activeSeconds\":0.41899741999804976,\"decisionDelayMs\":6.704100000206381,\"activeIdleSeconds\":0,\"errors\":0}",
    "run": 132,
    "passed": 132,
    "failures": [],
    "failed": 0,
    "unreachable": "{\"stats\":{\"concurrent\":0,\"failures\":4,\"maxConcurrent\":1,\"abandoned\":1,\"stuck\":1,\"computations\":4,\"queued\":0,\"recoveries\":1},\"abandoned\":true,\"duration\":4.315050400007749,\"travel\":2.173828125,\"reason\":\"abandoned\"}"
  },
  "ui": {
    "scale": 1.2999999523162842,
    "rows": 12,
    "ctfColor": 2,
    "globalColor": 2,
    "layouts": [
      {
        "canvas": 1922.7000732421875,
        "backVisible": true,
        "viewport": 430.29998779296875,
        "width": 335.3999938964844,
        "panes": [
          "Detail"
        ],
        "size": "360, 640"
      },
      {
        "canvas": 1922.7000732421875,
        "backVisible": true,
        "viewport": 150.79998779296875,
        "width": 614.8999633789062,
        "panes": [
          "Detail"
        ],
        "size": "640, 360"
      },
      {
        "canvas": 1922.699951171875,
        "backVisible": true,
        "viewport": 559,
        "width": 441.9999694824219,
        "panes": [
          "Main",
          "Options",
          "Categories",
          "Detail"
        ],
        "size": "1024, 768"
      }
    ],
    "title": "CROSSGROUNDS  /  RETÍCULO",
    "focus": "Scope",
    "defaultArena": 1,
    "inheritedArena": 2,
    "textSize": 27,
    "arenaColor": 3
  },
  "inheritance": {
    "arenaFalse": false,
    "default": 1,
    "contrast": true,
    "reduced": true,
    "arena": 3,
    "inherited": 2,
    "global": 2
  },
  "transitions": {
    "obstacle": "{\"arrived\":true,\"stats\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":1,\"abandoned\":0,\"stuck\":0,\"computations\":3,\"queued\":0,\"recoveries\":0},\"duration\":6.143853599991417,\"distance\":1.9929497241973878,\"travel\":52.67778683453798,\"reason\":\"blocked\"}",
    "run": 132,
    "mode": "{\"hubAgain\":{\"color\":2,\"mode\":\"hub\",\"state\":true,\"hud\":1},\"returned\":{\"color\":2,\"mode\":\"hub\",\"state\":true,\"hud\":1},\"respawn\":{\"color\":3,\"mode\":\"arena\",\"state\":true,\"hud\":1.2000000000000002},\"ctf\":{\"color\":2,\"mode\":\"ctf\",\"state\":true,\"hud\":1},\"enterArena\":{\"ok\":true},\"hub\":{\"color\":2,\"mode\":\"hub\",\"state\":true,\"hud\":1},\"enterCTF\":{\"ok\":true},\"arena\":{\"color\":3,\"mode\":\"arena\",\"state\":true,\"hud\":1.2000000000000002}}",
    "passed": 132,
    "failed": 0
  },
  "round12": {
    "cleanup": "{\"active\":0,\"elapsed\":125.49919470000896,\"pathsPerMinute\":141.77423579849515,\"bands\":{\"Mid\":{\"hits\":13,\"shots\":111},\"Far\":{\"hits\":9,\"shots\":305},\"Near\":{\"hits\":0,\"shots\":0}},\"decisions\":829,\"hits\":22,\"activeHits\":0,\"connected\":false,\"vision\":747,\"meanTickMs\":1.8688657530856823,\"navigation\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":2,\"abandoned\":0,\"stuck\":33,\"computations\":86,\"queued\":0,\"recoveries\":29},\"activeShots\":0,\"peakTickMs\":5.255800002487376,\"shots\":416,\"decisionDelayMs\":51.67455300318714,\"activeSeconds\":36.39589359052479,\"errors\":0}",
    "samples": "[{\"at\":0.00014859999646432698,\"snapshot\":{\"active\":12,\"elapsed\":89.80017270002282,\"pathsPerMinute\":60,\"bands\":{\"Mid\":{\"hits\":7,\"shots\":71},\"Far\":{\"hits\":7,\"shots\":247},\"Near\":{\"hits\":0,\"shots\":0}},\"decisions\":1,\"hits\":0,\"activeHits\":0,\"connected\":true,\"vision\":0,\"meanTickMs\":0.20178571243637376,\"navigation\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":1,\"abandoned\":0,\"stuck\":0,\"computations\":1,\"queued\":0,\"recoveries\":0},\"activeShots\":0,\"peakTickMs\":1.039800001308322,\"shots\":0,\"decisionDelayMs\":44.994300027610737,\"activeSeconds\":0.41626027040183546,\"errors\":0},\"bots\":[{\"role\":\"Runner\",\"ammo\":32},{\"role\":\"Runner\",\"ammo\":32},{\"role\":\"Soldier\",\"ammo\":26},{\"role\":\"Soldier\",\"ammo\":26},{\"role\":\"Guardian\",\"ammo\":5},{\"role\":\"Guardian\",\"ammo\":5},{\"role\":\"Runner\",\"ammo\":32},{\"role\":\"Runner\",\"ammo\":32},{\"role\":\"Soldier\",\"ammo\":26},{\"role\":\"Soldier\",\"ammo\":26},{\"role\":\"Guardian\",\"ammo\":5},{\"role\":\"Guardian\",\"ammo\":5}]},{\"at\":10.167970600014087,\"snapshot\":{\"active\":12,\"elapsed\":99.96797090000473,\"pathsPerMinute\":146.31686312346458,\"bands\":{\"Mid\":{\"hits\":7,\"shots\":71},\"Far\":{\"hits\":7,\"shots\":247},\"Near\":{\"hits\":0,\"shots\":0}},\"decisions\":225,\"hits\":0,\"activeHits\":0,\"connected\":true,\"vision\":0,\"meanTickMs\":0.8427781247064559,\"navigation\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":2,\"abandoned\":0,\"stuck\":13,\"computations\":27,\"queued\":0,\"recoveries\":12},\"activeShots\":0,\"peakTickMs\":4.051500000059605,\"shots\":0,\"decisionDelayMs\":102.15258598961454,\"activeSeconds\":11.071861201897264,\"errors\":0},\"bots\":[{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":105.31166507507442,\"ammo\":32},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":113.72034843167057,\"ammo\":32},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":75.27791683017677,\"ammo\":26},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":75.62376366531135,\"ammo\":26},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":61.2433093194104,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":89.22901427745819,\"ammo\":5},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":74.7826548924204,\"ammo\":32},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":58.935949873019129,\"ammo\":32},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":83.13643948733807,\"ammo\":26},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"blocked\",\"fire\":\"not_visible\",\"travel\":91.93031567335129,\"ammo\":26},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":40.31831590586353,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":69.22617137432099,\"ammo\":5}]},{\"at\":20.425725100009005,\"snapshot\":{\"active\":12,\"elapsed\":110.22573970002122,\"pathsPerMinute\":134.9964549979225,\"bands\":{\"Mid\":{\"hits\":7,\"shots\":71},\"Far\":{\"hits\":7,\"shots\":247},\"Near\":{\"hits\":0,\"shots\":0}},\"decisions\":474,\"hits\":4,\"activeHits\":4,\"connected\":true,\"vision\":307,\"meanTickMs\":1.346395774023004,\"navigation\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":2,\"abandoned\":0,\"stuck\":17,\"computations\":48,\"queued\":0,\"recoveries\":15},\"activeShots\":116,\"peakTickMs\":4.066199995577335,\"shots\":116,\"decisionDelayMs\":65.72872118418742,\"activeSeconds\":21.333893545903267,\"errors\":0},\"bots\":[{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"burst_pause\",\"travel\":144.04067506099819,\"ammo\":3},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"burst_pause\",\"travel\":151.5019030500407,\"ammo\":17},{\"state\":\"Engaging\",\"role\":\"Soldier\",\"route\":\"goal_changed\",\"fire\":\"cadence\",\"travel\":183.13559640874429,\"ammo\":17},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"recover_1\",\"fire\":\"burst_pause\",\"travel\":142.2884584887015,\"ammo\":8},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":121.08109992304344,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"burst_pause\",\"travel\":146.03312782055583,\"ammo\":2},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"not_visible\",\"travel\":217.10587797197514,\"ammo\":27},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"fired\",\"travel\":100.90799470061757,\"ammo\":23},{\"state\":\"Engaging\",\"role\":\"Soldier\",\"route\":\"goal_changed\",\"fire\":\"burst_pause\",\"travel\":210.81367923845597,\"ammo\":23},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"blocked\",\"fire\":\"burst_pause\",\"travel\":127.78170090913773,\"ammo\":1},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"blocked\",\"fire\":\"not_visible\",\"travel\":53.31084623677634,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":178.3188200807199,\"ammo\":5}]},{\"at\":30.146262399997796,\"snapshot\":{\"active\":12,\"elapsed\":119.94627700001002,\"pathsPerMinute\":139.1891852716276,\"bands\":{\"Mid\":{\"hits\":7,\"shots\":71},\"Far\":{\"hits\":7,\"shots\":247},\"Near\":{\"hits\":0,\"shots\":0}},\"decisions\":708,\"hits\":14,\"activeHits\":14,\"connected\":true,\"vision\":600,\"meanTickMs\":1.7667974471930295,\"navigation\":{\"concurrent\":0,\"failures\":1,\"maxConcurrent\":2,\"abandoned\":0,\"stuck\":28,\"computations\":72,\"queued\":0,\"recoveries\":24},\"activeShots\":318,\"peakTickMs\":5.255800002487376,\"shots\":318,\"decisionDelayMs\":55.21325263955057,\"activeSeconds\":31.036894077435137,\"errors\":0},\"bots\":[{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"burst_pause\",\"travel\":152.5622435252444,\"ammo\":12},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"goal_changed\",\"fire\":\"fired\",\"travel\":163.50351118413529,\"ammo\":22},{\"state\":\"Engaging\",\"role\":\"Soldier\",\"route\":\"goal_changed\",\"fire\":\"burst_pause\",\"travel\":190.6350338601069,\"ammo\":22},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"recover_1\",\"fire\":\"cadence\",\"travel\":150.8725866301047,\"ammo\":9},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"goal_changed\",\"fire\":\"not_visible\",\"travel\":130.31022148141165,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"recover_1\",\"fire\":\"cadence\",\"travel\":153.1631305355395,\"ammo\":3},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"recover_1\",\"fire\":\"fired\",\"travel\":235.6105142000597,\"ammo\":0},{\"state\":\"Capturing\",\"role\":\"Runner\",\"route\":\"blocked\",\"fire\":\"burst_pause\",\"travel\":126.32949749160616,\"ammo\":29},{\"state\":\"Engaging\",\"role\":\"Soldier\",\"route\":\"goal_changed\",\"fire\":\"cadence\",\"travel\":216.90524626339505,\"ammo\":24},{\"state\":\"Capturing\",\"role\":\"Soldier\",\"route\":\"recover_1\",\"fire\":\"burst_pause\",\"travel\":136.74795871973039,\"ammo\":3},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"blocked\",\"fire\":\"not_visible\",\"travel\":71.20481478447073,\"ammo\":5},{\"state\":\"Guarding\",\"role\":\"Guardian\",\"route\":\"blocked\",\"fire\":\"not_visible\",\"travel\":241.13623723953789,\"ammo\":5}]}]"
  },
  "gamepad": {
    "method": "Roblox Studio user_keyboard_input ButtonA, normal LocalScript registered probe",
    "activations": 1,
    "focus": "SelectionProbe",
    "selectedObject": "SelectionProbe",
    "input": "Gamepad"
  }
}
```

Notas: os snapshots antigos da rodada de 12 bots compartilhavam a tabela `bands`; seus contadores escalares são válidos, mas as faixas históricas foram substituídas pelos valores finais por referência. A implementação final faz cópia profunda das faixas. Não usar essas faixas históricas para calcular precisão por instante. Uma falha de path anterior à rodada pertence ao fixture unitário em altitude, não ao mapa CTF.
