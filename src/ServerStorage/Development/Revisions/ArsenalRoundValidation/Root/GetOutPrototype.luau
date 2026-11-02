-- v0.5 vertical slice: provisional testing values, not approved balance.
return table.freeze({
 Version="0.5-p0", Status="proposed_test_only",
 DoorSecondsSurvivor=1.5, DoorSecondsBeast=1, DoorCloseSeconds=.6,
 CrawlSpeed=7, CrawlHeight=1.6, CrawlToggle=false,
 CrawlEnterSeconds=.32, CrawlExitSeconds=.24, CrawlStride=4.2,
 JumpHeight=2.4, WindowHeadClearance=8.6,
 DefaultBeastClass="Runner", RunnerSpeedMultiplier=2.5, RunnerSeconds=3,
 RunnerCooldownSeconds=20, WindowSpeedMultiplier=.4, WindowSlowSeconds=1.5,
 AttackRange=7, AttackCooldown=1.4, AttackWindup=.25, AttackArcCos=.35,
 DownedSeconds=25, LeashRange=6, DragLength=5, DragBreakDistance=14, DragWalkSpeed=12,
 PodSeconds=45, RescueSeconds=3, AntiCampRadius=12, CumulativeFreeze=true, PodReusable=true,
 HackSeconds=24, HackSlots=3, CheckInterval=6, CheckLead=1.4, CheckWindow=.8, ErrorSeconds=3,
 SpawnTimeout=20,
})
