;C000 - C09F get copied by OAM routine
SECTION "C000", WRAM0[$C000] ;C000 - C09F is ekkusu oam region
wOAMStart::
OAM_ENTRY_SIZE EQU 4
ds OAM_ENTRY_SIZE * 4 
wReticleOAMData:: ds OAM_ENTRY_SIZE*4 ;C010 - C01F is reticle
wTargetCompassOAMData :: ds OAM_ENTRY_SIZE ;C020
wAltimeterOAMData:: ds OAM_ENTRY_SIZE ;C024, the altimiter sprite
wMinimapPipsOAMData:: ds OAM_ENTRY_SIZE*8 ;C028 - C047 is OAM for map pips
wTimerOAMData:: ds OAM_ENTRY_SIZE * 14 ;C048 - C07F is OAM for the timer
;C080

;C0A0 is the first byte from the music data, pitch shift for all notes retrieved
;C0A1/C0A2 holds an address for table of values read by AX commands (note length table)
;C0A3 holds ????

;C0A7 holds a value that divides values read into C0A8 table
;C0A8 is a table of four bytes, one for each track channel. compared to XE, if unequal skips volume change

SECTION "C0AC", WRAM0[$C0AC]
wSpottedState:: db ;C0AC, 1 on first time, then set to 2
db ;C0AD, unknown but reset in the input handler?
CARGO_CRYSTAL EQU 1
CARGO_SCIENTIST EQU 2
CARGO_REACTOR_RODS EQU 2
CARGO_IMPOSTER EQU 3
CARGO_BOX EQU 4
wHasCargo:: db ;C0AE
LEVEL_ONE EQU 0*4 ;00
LEVEL_FOUR EQU 3*4 ;0C
LEVEL_FIVE EQU 4*4 ;10
LEVEL_SIX EQU 5*4 ;14
LEVEL_SEVEN EQU 6*4 ;18
LEVEL_EIGHT EQU 7*4 ;1C
LEVEL_NINE EQU 8*4 ;20
LEVEL_TEN EQU 9*4 ;24
LEVEL_ESCAPE EQU 10*4 ;28
LEVEL_TUTORIAL EQU 11*4 ;2C
wCurLevel:: db ;C0AF save file byte

wNoteDataStart:: db ;C0B0
;C0B0/B1, channel's section list pointer
;C0B2, frames left for note (starts at note length, C0B3 value)
;C0B3, note length
;C0B4 + C0B5, pointer into section data
;C0B6, reg volume
;C0B7, reg length
;C0B8, saved length
;C0B9/C0BA, reg freq.
;C0BB, if nonzero, uses a default volume of 8. written to by 01 command, used to retrieve a volume from table 5A6F
;C0BC/C0BD, loop point
;COBE progress?
;C0BF, loop number. top bit cleared by fadeout (channel 1?)

;C0C0/C0C1, another pointer from header.

;C0C4/C5, pointer copied from C0/C1
;C0C6, also loaded by fadeout using a table value

;C0CF, top bit cleared by fadeout (channel 2?)
;C0D0/D1, pointer from header

;C0D4/D5, pointer copied from D0/D1
;C0D6/D7, pointer to the last loaded channel 3 waveform (to restore after sfx?)

;C0DF, top bit set when playing a channel 3 sound? also during fadeout
;C0E0/C0E1 is a pointer loaded from music header

;C0E4/C0E5 is a copy of E0/E1, progress?

;C0EF, top bit set during fadeout, cleared at the end

SECTION "C0F0", WRAM0[$C0F0]
wHandledChannel:: db ;C0F0 used to check which channel we're handling
;C0F1 holds a queued track ID?

SECTION "C0F5", WRAM0[$C0F5]
wStereoSetting:: db ;C0F5 controls the next few bytes - 1 does nothing, 2 engages?
wStereoTicks:: db ;C0F6 is a counter that ticks up
wStereoThreshold:: db ;C0F7 is the counter limit, C0F6 is reset when it reaches it
wStereoSelector:: db ;C0F8 counts up every time the counter hits the limit
wStereoValues:: ds 4 ;C0F9, C0FA, C0FB, and C0FC are values that are output to Sound Output Terminal based on the lower bits of the lap counter

SECTION "hhhhhhh", WRAM0[$C100]
wQueueSFX:: db ;C100 interface sound effect to play
wCurrentSFX:: db ;C101, the currently playing sound effect
db
db
db ;C104, which register load we're on? (coarse progress)
ds 3
;$1 is selection change sound
;$2 is option selection sound
;$3 is speed change sound

;$5 is locking on
;$6 is bunp sound
;$7 is a deeper bunp, where is this used?
;$8 is shield pickup/item
;$9 is fuel pickup/item, also ring flythrough
;$A is lazer/pulse sound effect
;$B is quad beam sound effect
;$C is MESON sound effect
;$D is plasma ball sound effect
;$E is plasma duplicate?
;$F is target located sound effect
;$10 is deflected beam
;$11 is glider deploy sound effect
;$12 is reactor rod collect/consumable collect

;$19 is a particle emission sound effect base

;$1D is Insect Thing shoot sound

wQueueMusic:: db ;C108 main tune. $20 plays the level intro, $21 updates the track based on state.
TRACK_TITLE         EQU $01
TRACK_URGENT	    EQU $02
TRACK_FINAL_MISSION EQU $03
TRACK_RESULTS       EQU $04
TRACK_ALARM		    EQU $05
TRACK_BASE          EQU $06
;briefing? $07
TRACK_DEATH         EQU $08
TRACK_SCIENTIST     EQU $09
;ambient 1 intro $0A
;ambient 1 $B
;ambient 2 $C
;ambient 3 $D
TRACK_PRESENTS      EQU $0E
TRACK_TRAINING      EQU $0F
;ambient 3 intro $10
TRACK_IMPOSTER      EQU $11;like $09 but pitched up
TRACK_TUNNEL        EQU $12
;ambient 2 intro $13
TRACK_RECAP         EQU $14 ;text recap and planet select
TRACK_MISSION_COMPLETE EQU $15 ;arpeggio, $15? mission complete tune?
TRACK_ITEM_REVEAL   EQU $16
;boss level $17
TRACK_SILO_INTERIOR EQU $18 ;whine, $18
TRACK_ENCOUNTER     EQU $19 ;encounter $19
;ambient 4 intro $1A
;ambient 4 $1B
;gong? $1C
;fanfare? all clear? $1D
;credits $1E
TRACK_TUNNEL_DEMO   EQU $1F
TRACK_LEVEL_INTRO   EQU $20
TRACK_LEVEL_STATE   EQU $21
TRACK_BRIEFING_INTRO EQU $22
;shanty? $23
;ambient 5 intro $24
;ambient 5 $25
;placing power crystal $26
;briefing w/ arpeggio? $27
TRACK_TRAINING_PAGE EQU $28 ;training copy? final one

wCurrentTrack:: db ;C109
wAuxTimerLo:: db ;C10A, counter lo
wAuxTimerHi:: db ;C10B, counter hi
ds 3
wAuxTimerActive:: db ;C10F is a flag for counter?
;fadeout $01
;shopkeeper $02
;gliders in level 6 $04
;commander speech blips $07
wQueueWave:: db ;C110 general sound effect queued
wPlayingWave:: db ;C111, the playing sound
db ;C112
db ;C113
wWavElapsed:: db ;C114, the elapsed time
wWavScratch1:: db ;C115 \ 
wWavScratch2:: db ;C116  all three are used however needed by the sfx code
wWavScratch3:: db ;C117 /

wQueueNoise:: db ;C118 explosion sound effect to play; wQueueNoise
;2 is explosion (generic?)
;3 is enemy damage
;4 is liftoff, also used in credits
;5 is missile fire!
;6 is HIGHEX

;8 is TURBO
;9 is base enter

;B is item forming sound?

;D - 10 is drake noise

;11 - 14 is humantank footsteps

;15 is butterfly fire

;1D for splash!
wCurrentNoise:: db
ds 6

db ;C120 is a copy of speed tier used in sound engine
db ;C121 counts up to FF, reset upon speed change
db ;C122 makes channel 3 sfx load a different set of channel data if odd or even?
db ;C123 plays a whoosh sound when nonzero
wPlayingIntroJingle:: db ;C124, flag for C125. 
wIntroJingleTimer :: db ;C125, counts up when C124 set. when $E0, resets C124
wHalfVolume:: db ;C126 is half volume flag? set when paused
wDoCutVolume:: db ;C127 is only set for less than a frame when pause is triggered
db ;C128 is set to $33 (half volume) when paused
wLevelID:: db ;C129 is actual level number
db ;C12A is a possible backup of stereo volume? also flagged when timer is done for track $16
db
wFadeOutTicks:: db ;C12C increases when fading, every $8 it increases C12D
wFadeOutMusic:: db ;C12D fades out music when set

;C200 is the stack top!
SECTION "C200", WRAM0[$C200]
wStackTop:: ds 64 ;C200, saves $20 words

wEntityDestroyedFlags:: ds 32 ;C240, $20-byte table. if a bit is set, entity has been destroyed.

;C262-C269, C26D, and C26E set in serial code?
SECTION "more wram", WRAM0[$C270]
wInputCodePtr:: ;C270/C271
wInputCodePtrLo:: db
wInputCodePtrHi:: db
db ;C272, written to by radar base and junction?
db ;C273, written to when Power Crystal collected?
wTutLastRingZLo:: db ;C274
wTutLastRingZHi:: db ;C275
wTutEndTimer:: db ;C276
db
wTutSawAllRadarText:: db ;C278

wCharsetGraphicLo:: db
wCharsetGraphicHi:: db ;C279/C27A charset pointer?
wCharsetTable1Lo:: db
wCharsetTable1Hi:: db ;C27B/C27C charset pointer?
wCharsetTable2Lo:: db
wCharsetTable2Hi:: db ;C27D/C27E charset pointer?
wLoadedCharset:: db ;C27F, 0 for english

wFlash3DWindow:: db ;C280, a counter of how many flashes times 2
wJunctionPointer::
wJunctionPointerLo:: db
wJunctionPointerHi:: db ;C281/C282, the junction entity is backed up here upon entering 
;C283 increments each $7F kill, resets at $19?

SECTiON "C288", WRAM0[$C288]
wTutRegister:: db ;C288 used for comparisons?
wTutPos::
wTutPosLo:: db ;C289 where to return to in the script
wTutPosHi:: db
wTutLoopTimer:: db ;C28B tutorial loop timer
wTutLoopPos::
wTutLoopPosLo:: db ;C28C pointer of where to loop back to
wTutLoopPosHi:: db ;C28D
wTutSubLoopPos::
wTutSubLoopPosLo:: db ;C28E pointer of where to loop back to
wTutSubLoopPosHi:: db
wTutSubTimer:: db ;C290 is tutorial subroutine timer
wTutSubStack::
wTutSubStackLo:: db ;C291, ret address
wTutSubStackHi:: db ;C292
wTutFallbackPointerLo:: db ;C293 used if C312 is blank
wTutFallbackPointerHi:: db 
wTutProgress:: db ;C295
;C296 ???? checked in flying tutorial

SECTION "C297", WRAM0[$C297]
wTutRadarTextPage:: db ;C297, which page of text to show in the radar base, used in the tutorial
wTutComplete:: db ;C298 training complete flag?
wLevelStartTimer:: db ;C299 counts down to zero. disables pausing at the start of a mission.
wLevelClearCountdown:: db ;C29A
db ;C29B, is a model that gets drawn
wVBlankHandled:: db ;C29C
wCurrentInput:: db ;C29D
wChangedInputs:: db ;C29E

	ds 2

wUpdateCounter:: db ;C2A1 is used to select the current animation frame, incremented once every ~11 frames?
;C2A2 - C2A9 are four pointers/words

;C2AB set to 1 if game over level 1 with crystal

;C2AD - number of objectives left to collect/destroy?

SECTION "C2AF", WRAM0[$C2AF]
wCrosshairTarget::
wCrosshairTargetLo:: db ;C2AF - pointer to entity crosshair is over?
wCrosshairTargetHi:: db ;C2B0
wCrosshairDistanceLo:: db ;C2B1, set to FF every frame
wCrosshairDistanceHi:: db ;C2B2, set to FF every frame
db ;C2B3, set when using the payload item? damages enarest entity
db ;C2B4, set when using the Finder?
wNearestEntityPtr::
wNearestEntityLo:: db
wNearestEntityHi:: db ;C2B5/B6 holds an address pertaining to closest entity?
wHideEntities:: db ;C2B7 seems to hide models, possibly (set when exiting tunnels to process despawn)
;C2B8, gun entity doesn't shoot when this is zero. enables enemy logic?

SECTION "C2BA", WRAM0[$C2BA]
wScreenShakeCounter:: db ;C2BA, shifts screen to the right every few frames
db
wPitchLurch:: db ;C2BC, used when moving between speed tiers
wPitchAngle:: db ;C2BD, used in math for C902 area
wPitchAngleR:: db ;C2BE, used when tilted

SECTION "WRAMstars", WRAM0[$C2C3]
;C2C2, how many enemies killed?
wBigStars:: db ;C2C3, big stars.
wSmallStars:: db ;C2C4 
;C2C5, math'd by results/continue screen commands
;C2C6, math'd by results/continue screen commands
;C2C7 used to determine mission objectives? it's just a hostile kill count
;C2C8 is backup of bases left? also mothership?
;C2C9 is backup of entities left to kill?
;C2CA, used in mission 10. number of tunnels present?
;C2CB, used in mission 10. if junction is present?
SECTION "C2CC", WRAM0[$C2CC]
wRadarBaseCount:: db ;;C2CC, number of bases still present
wFlyingFlag:: db ;C2CD, 1 if we're flying, 0 if grounded
ds 2
BASES_TOTAL EQU 8
wRadarBasesTable:: ds BASES_TOTAL ;C2D0 - C2D7 determines what bases are present - high bit set to hide/destroy, other bits set when item used.
WEAPON_LOCKON EQU 0
WEAPON_HIGHEX EQU 1
WEAPON_JETPAC EQU 2
WEAPON_BOMB   EQU 3
WEAPON_NONE   EQU 4
wEquippedWeapon:: db ;C2D8 0 lockon, 1 high ex, 2 jetpac, 3 bomb, 4 blank
wJunctionBought:: db ;C2D9 checked by junction. what you've bought from the military store; 1 is shield, 2 is gas, 4 is missile
wLatestRadarDestroyed:: db ;C2DA is the area of latest destroyed radar base, used in level 3
;C2DB might be a flag for when you can try to drop the bomb in the tunnel?
SECTION "C2DC", WRAM0[$C2DC]
wHitInvinc:: db ;C2DC, timer for hitstun invincibility
db;C2DD is a timer for something
wScreenTextLine1Ptr:: dw ;C2DE/DF is a pointer to bank 9 text to draw on the screen 
wScreenTextLine1Val:: db ;C2E0 dunno what this signifies
wScreenTextLine2Ptr:: dw ;C2E1
wScreenTextLine2Val:: db ;C2E3
wScreenTextLine3Ptr:: dw ;C2E4
wScreenTextLine3Val:: db ;C2E6
wEntInLockonRange:: db ;C2E7 ??
wLevelIntroTimer:: db ;C2E8

wGoalCellTimer:: db ;C2E9, activates wGoalCellID
wGoalCellID:: db ;C2EA, what map cell to flash if wGoalCellActive is set
wGoalEntityID:: db ;C2EB, loaded during level load
wContinueOptionBaseY:: db ;C2EC
wTargetSCY:: db ;C2ED is target for rSCY scrolling
wSelectedContinueOption:: db ;C2EE, for start menu continue menu? 0 is YES

;C2F1, set to A on a speed change, decreses to 1 if up or down held

SECTION "C2F9", WRAM0[$C2F9]
wCrosshairYOffset:: db ;C2F9 related to C010 group, crosshair Y?
wCrosshairXOffset:: db ;C2FA related to C010 group, crosshair X?
db ;copy of crosshair Y?
db ;copy of crosshair X?
wTurnSpeed:: db ;C2FD, which direction and how fast we're turning. D0 - 2F
db ;C2FE, always moved towards 0?
wTunnelIntroTimer:: db ;C2FF
wHideCrosshair:: db ;C300 - 1 = hide, 2 = temp hide for flashing
wStationArea:: ;C301
wGoalEntityDistance:: db ;C301
wGoalEntityPointer::
wGoalEntityPointerLo:: db ;C302
wGoalEntityPointerHi:: db ;C303
wTunnelDemoMode:: db ;C304
db
db
wPlayerName:: ds 9 ;C307-C30F related to each other? name related, possibly for highscore entry?

;C311, what letter we're on?
SECTION "WRAM C312", WRAM0[$C312]
wTimerFrames:: ;C312
wTimerFramesLo:: db ;C312
wTimerFramesHi:: db ;C313
wTimerDigit1:: db ;C314
wTimerDigit2:: db ;C315
wTimerDigit3:: db ;C316
wTimerDigit4:: db ;C317
wTimerEnableFlag:: db ;C318
wTunnelBombSet:: db ;C319
db
wAimPitch:: db ;C31B, tilts view up or down
;C31C stores mirrored c1' during vert rotation
;C31D involves FFDB-FFE0
;C31E stores mirrored c2' during vert rotation
;C31F involves FFDB-FFE0
;C320 copied to speed of a new entity in butterfly code?
;C321 copied to speed of a new entity in butterfly code?
;C322 copied to speed of a new entity in butterfly code?
;C323 copied to speed of a new entity in butterfly code?


;C328 used in target locating? set to $8080
;C32A used in target locating? set to $8080

;C32C is number of target models destroyed?

SECTION "C331", WRAM0[$C331]
wModelScale:: db ;C331 is the 01 byte in a model header (number precision?)
wFaceEdges:: db ;C332 true number of edges in the face currently being loaded
wFaceIncrement:: db ;C333 number of edges to read past to get to the edge IDs of the face currently being loaded
db
wModelEdgesPointer::
wModelEdgesPointerLo:: db ;C335
wModelEdgesPointerHi:: db ;C336 both used in rendering code? saves model edge pointer
wFaceEdgesAlt:: db ;C337 is a backup of face edges

wAnimDisable:: db ;C338 disables animations (only in briefing)
;C339 incremented by 2 by unused func
;C33A incremented by 8 every eight C339 updates by unused func
;C33B/C33C used in word subtraction? distance from wall in tunnel

SECTION "C33E", WRAM0[$C33E]
wModelExploding:: db ;C33E used in vertex loader
;C33F, exploding/forming progress?

SECTION "C341", WRAM0[$C341]
wCurInvSlot:: db ;C341 is what inventory item to show, 0-4
wNextInvSlotFlag:: db ;C342 is a flag to advance selected inventory

SECTION "WRAM 1.5", WRAM0[$C345]
wClosestDist:: db ;C345 is a saved 'closest' distance
wViewDir:: db ;C346 is view direction

;C349 - C351 used to load the following pointer's values?
;C352/C353 is a pointer?
SECTION "C355", WRAM0[$C355]
wUseItem:: db ;C355 set when buttons pressed in the inventory checking code? flag to use item?
wEntityCollided:: db ;C356 cleared if ent not exploding, and set on collision
;C357/C358 these two store the X of the collided entity

SECTION "WRAM 2", WRAM0[$C400]
wNumEdges:: db ;C400 should say how many faces follow?

SECTION "C700", WRAM0[$C700]
wExplodedVertBuffer:: db ;C700 groups of 6 instead of groups of 4, used as scratch to move them before loading up wVertBuffer

SECTION "C900", WRAM0[$C900]
wVertBuffer:: db ;C900 holds vertex data when loading model to draw it

SECTION "WRAM CA00", WRAM0[$CA00]
wEdgeDrawFlags:: ds 7*6 ;CA00 holds flags stating if edges in currently loaded model should be drawn?
;CA2A end of flags
SECTION "CA81", WRAM0[$CA80]
wWeaponEnergy:: db ;CA80, gets +=7 in the item useage routine, caps at FF
wFuelAmount::
wFuelAmountLo:: db ;CA81
wFuelAmountHi:: db ;CA82
wBJustPressed:: db ;CA83 set if B pressed
wAJustPressed:: db ;CA84 set if A pressed
ds 3 ;CA85/86/87 store tunnel header bytes?
wLurchTarget:: db ;CA88 used in tunnel movement logic, possibly? zeroed at the end of the tunnel intro

;CA8C? has to do with launchers being spotted? set to FF when gun turret fires
SECTION "CA8D", WRAM0[$CA8D]
wCurrentLetter::
wTunnelTurnSpeed:: db ;CA8D
IF UNUSED == 1
wScore::
wScoreHundredThousands:: db ;CA8E, decimal number
wScoreTenThousands:: db ;CA8F
wScoreThousands:: db ;CA90
wScoreHundreds:: db ;CA91
wScoreTens:: db ;CA92
wScoreOnes:: db ;CA93
ENDC
SECTION "WRAM 2.5", WRAM0[$CA95]
wSelectedPlanet:: db ;CA95 holds planet selection
wFrameCounter::
wFrameCounterLo:: db ;CA96
wFrameCounterHi:: db ;CA97 is a frame counter
unkCoord1:: db
unkCoord2:: db ;ca98/99 is a coordinate, edited from the following one
unkMagnitude:: db ;ca9a/9b is a magnitude and angle
unkAngle:: db
db
wScrollYFlag:: db ;CA9D handles whether to scroll SCRY if equal to 3?
wParticleAge:: db ;CA9E? rolled when entity gets destroyed,
MAX_HEALTH EQU 8
wHealth:: db ;CA9F
wMaxHealth:: db ;CAA0, scrapped mechanic
db
db
db
wSerialControl1:: db ;CAA4 is set to what SerialControl is?
;CAA5 triggers a rect to be drawn in tunnels? scrapped? opponent racer?

SECTION "WRAM 3.125", WRAM0[$CAA7]
wFlightPitch:: db ;CAA7
wTutTextWait:: db ;CAA8

;CAAE/CAAF is far tunnel rotation word?
SECTION "CAB4", WRAM0[$CAB4]
db
wFarTunnelWidth:: db ;CAB5
db
wFarTunnelHeight:: db ;CAB7
db
wProxRange:: db ;CAB9 is a scrapped menu selection

;CAC2 far tunnel length
;CAC4/CAC5 backup address
SECTION "CAC5", WRAM0[$CAC5]
wTunnelDataPointer:: 
wTunnelPointerLo:: db ;CAC5/CAC6 stores tunnel pointer
wTunnelPointerHi:: db
wSerialControl2:: db ;CAC7
wMenuSelection:: db ;CAC8 0 is yes, 1 is no
wMenuOptions:: db ;CAC9, limit for junction menus

wProxLock:: db ;CACB is a scrapped menu selection
;CACC is used for Y postition of the garbage 3rd continue screen sprite

;CACE checked by satellite code
SECTION "CACF", WRAM0[$CACF]
wLockState:: db ;CACF, 1 by default? 3 when locked, 6 when lock lost
wLockTicks:: db ;CAD0, lock progress? increments each beep
wLockCancel:: db ;CAD1 instantly cancels lock when set
wLockedEntity:: dw ;CAD2/CAD3, locked entity pointer
;CAD4, CAD5, CAD6, CAD7, CAD8, CAD9 targeted entity position

SECTION "CAE0", WRAM0[$CAE0]
wEquippedItem:: db ;CAE0, appears to be used for Z button
wInventory:: db ;CAE1, used for the X button. $1E is lazer?
wInventory1:: db ;CAE2 is a byte list 5 long, inventory?
;CAE7

SECTION "CAEA", WRAM0[$CAEA]
wPowerBoost:: db ;CAEA is used when calculating entity damage? nonzero is triple damage

SECTION "CAED", WRAM0[$CAED]
wSubscreen:: db ;CAED: 0 normal, 1 junction, 2 ?, 3 unused shop, 4 gas station, 5+ radar base

;CAEF, tunnel outer loop counter
;CAF0, tunnel loop counter
;CAF1 incremented every frame we're in a tunnel

SECTION "CAF3", WRAM0[$CAF3]
wReportPointer:: 
wReportPointerLo:: db ;CAF3/F4 pointer based on level, used for ???
wReportPointerHi:: db
wLevelProgressFuncPointer::
wLevelProgressFuncPointerLo:: db ;CAF5/F6 level pointer for per-frame level-specific logic (progress & loss)
wLevelProgressFuncPointerHi:: db

SECTION "CAF8", WRAM0[$CAF8]
;$1C bytes wiped every frame
db ;CAF8, gun turret count
db ;CAF9, used in mission 10. set when mothership destroyed? count of ents
db ;CAFA, used in mission 5. number of warehouses
wEntsEnemyCount:: db ;CAFB, enemy count
db ;CAFC, number of alien gliders
db ;CAFD, number of insect things
db ;CAFE, used in mission 9, cruise missile count
db ;CAFF, number of mines left
db 
wMissionReactorRodCount:: db ;CB01, reactor rod count
wMissionBombCount:: db ;CB02, used as bomb counter in level 2
db ;CB03, used as humantank counter in level 3
db 
db ;CB05, Super Gun clears or sets this. crosshair must be over it.
db 
wCollisionType:: db ;CB07 set to 1 on hostile collision. 2 on scenery collision.
COLLISION_HOSTILE EQU 1
COLLISION_SCENERY EQU 2
wCrosshairTargetEntity::
wCrosshairTargetEntityLo:: db
wCrosshairTargetEntityHi:: db ;CB08/CB09 pointer to current (closest) entity under the crosshair
wMissionBasesLeft:: db ;CB0A, used as number of bases left in level 3
;CB0B, number of trucks (used in level 3)
;CB0C, number of trucks at destination?
;CB0D, number of butterflies in level 8
;CB0E, number of chrysalises in level 8
;CB0F, used in 9. game over if this becomes 0. silo count

;CB11, used in 10. tunnels count
;CB12, used in 10. junction count
;CB13, little man count

SECTION "CB17", WRAM0[$CB17]
wTunnelLightState:: db ;CB17 used in tunnel to keep track of starting light state
wDidTetamusTunnel:: db ;CB18, flags if tunnel to Tetamus II has been traveled yet?

SECTION "WRAM idk", WRAM0[$CB1B]
wTextBubbleHeight:: db ;CB1B
wTextBubbleX:: db ;CB1C

SECTION "WRAM 3.25", WRAM0[$CB21]
wHorizonTable:: ds $10 ;CB21 is a ten byte table (horizon?)
wBackupHorizonTable:: ds $10 ;CB31 is a backup of table CB21
wFlyTilt: db ;CB41 referenced in 3D math and horizon drawing. ranges from -2 to 2
wFlyTiltRaw:: db ;CB42 is copied to the fly tilt on update
wGroundTiltRaw:: db ;CB43, possibly a grounded turning tilt counter? is it used?
wLurchCounter:: db ;CB44, if unequal to LurchTarget, tilts view slightly.

;CB47 has to do with lockon, checked for flashing the reticle
SECTION "CB48", WRAM0[$CB48]
wKnockbackCounter:: db ;CB48, frames to bump player back. if > 14, tilt up too
wGameOverTimer:: db ;CB49, decremented in level loop
db
wGoalCompassPos:: db ;CB4B 
wGoalCompassOffset:: db ;CB4C

SECTION "WRAM 3.5", WRAM0[$CB4F]
MISSILES_MAX EQU 8
wMissileCount:: db ;CB4F is missile count

wFoundEntityPointerLo:: db ;CB50
wFoundEntityPointerHi:: db ;CB51
db ;? set to zero in the level loop. disables pitching and tilting?

ENTITY_SIZE EQU $19
ENTITY_SLOTS EQU $28
wEntityTable:: ds ENTITY_SIZE*ENTITY_SLOTS ;CB53, 3E8 bytes total
;entities are as follows:
;first byte is model ID (high bit set when exploding/forming)
;word for X position
;word for Z position
;word for Y position
;byte for x orientation
;byte for z orientation
;byte for y orientation
;word, pointer to entity logic
;byte for HP value
;byte?? bottom bit set when shot at
;byte for speed, can be used for other values ;D
;byte for speedup after getting shot? also used as turn direction for gliders and other things
;word for unknown (mapobj iterator can write to this) are these target positions? sometimes
;word for unknown (mapobj iterator can write to this)
;word for unknown (mapobj iterator can write to this)
;byte, unknown. decremented by 2 when forming?
;byte, bit 2 set when forming? bit 1 set when no targets left
;final byte is map object ID

;CEC2?

SECTION "CF3B", WRAM0[$CF3B]
PARTICLE_SIZE EQU $C
PARTICLE_SLOTS EQU $10
UNION
wParticleTable:: ds PARTICLE_SIZE*PARTICLE_SLOTS ;CF3B is a table for particles (debris, shots?)
;byte, passed A (random). counts down to zero?
;word, X Speed
;word, X
;word, Y Speed
;word, Z
;word, Y
;byte, type. 1 is debris, 2 is enemy shot. is zero the plasma balls? 
;CFFB
NEXTU
HISCORE_SIZE EQU $10
HISCORE_SLOTS EQU 5
wHiscores:: ds HISCORE_SIZE*HISCORE_SLOTS
.end ;CF8B
ENDU

MONO_BUFFER_HEIGHT EQU $58 ;88 pixels tall, or 11 tiles - the height in tiles of the 3D window
MONO_BUFFER_COLUMNS EQU 16 ;$10
MONO_BUFFER_ROWS EQU 11 ;$B
MONO_TILE_HEIGHT EQU 8
SECTION "D000", WRAM0[$D000]
wMonoBufferColumn1:: ds MONO_BUFFER_HEIGHT ;D000, the first monochrome buffer for 3D rendering and text. 11 tiles tall.

UNION
wMapTankCellPos:: ds 8 ;D058 is an eight byte group.. 
NEXTU
wRadarBuffer:: ds 8 * 16 ;D058, used for drawing static? base radar gets overlaid
;reused by other stuff maybe?? sixteen groups, goes until D0D5??
ENDU

SECTION "D100", WRAM0[$D100]
wMonoBufferColumn2:: ds MONO_BUFFER_HEIGHT ;D100, second monochrome buffer.
w3DTextBuffer:: db ;D158, used for countdown (and old score stuff?)
;D158, 59, 5A, and 5B also used in the LYC interrupt handler for flags 1 and 2
;D15C  and D15D show up in vblank handler
SECTION "D258", WRAM0[$D258]
wTunnelFrames:: ds 4*8 ;D258 the two corners (x1,y1)(x2,y2) in screenspace of each frame of tunnel
;D278 

SECTION "D358", WRAM0[$D358]
UNION
CREDIT_STARS EQU 40
wCreditStarPositions:: ds CREDIT_STARS*2 ;D358 two bytes (X, Y) for each of the 40 stars

NEXTU
wTunnelSeg1Distance:: db ;D358, for tunnel - length until next segment?
wTunnelSeg1Width:: 
wTunnelSeg1WidthLo:: db ;D359
wTunnelSeg1WidthHi:: db ;D35A
wTunnelSeg1Height::
wTunnelSeg1HeightLo:: db ;D35B
wTunnelSeg1HeightHi:: db ;D35C
wTunnelSeg1RotLo:: db 
wTunnelSeg1RotHi:: db ;D35D/D35E, tunnel rotation?
dw ;D35f/60 is ???
NEXTU
TUNNEL_SEGMENT_SIZE EQU 9
TUNNEL_SEGMENT_COUNT EQU 8
wTunnelSegmentData:: ds TUNNEL_SEGMENT_SIZE * TUNNEL_SEGMENT_COUNT
ENDU
;D3A0


;somewhere down here is the 1bpp buffer, includes D408
SECTION "D458", WRAM0[$D458]
TUNNEL_ENTITIES_SIZE EQU 12
TUNNEL_ENTITIES_COUNT EQU 10
wTunnelEntities:: ds TUNNEL_ENTITIES_SIZE * TUNNEL_ENTITIES_COUNT ;D458, 10 entries, all of size $C?
;first byte is distance
;word xpos
;word zpos
;byte unknown
;word width
;word height
;byte entity type
;byte fillpattern
;D4D0 end of this table? 
wTunnelEntitiesEnd:: db
SECTION "D500", WRAM0[$D500]
wMonoBufferColumn6:: ds MONO_BUFFER_HEIGHT ;D500
;D508, used in tunnel intro
;D518, used in nuclear silo
;D740's in tunnel intro
