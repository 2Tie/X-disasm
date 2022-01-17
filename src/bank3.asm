SECTION "bank 3 top", ROMX[$4000], BANK[3]
TimeOverTextPointers: ;text pointers for game over text, two pointers each level. escape and tutorial skipped.
	dw TimerOverText1_1, TimerOverText1_2 
	dw TimerOverText2_1, TimerOverText2_2 
	dw TimerOverText3_1, TimerOverText3_2
	dw TimerOverText4_1, TimerOverText4_2 
	dw $0000, $0000 ;five has no timer
	dw TimerOverText6_1, TimerOverText6_2 
	dw TimerOverText7_1, TimerOverText7_2
	dw TimerOverText3_1, TimerOverText3_2 ;reuses 3's
	dw TimerOverText9_1, TimerOverText9_2
	dw TimerOverText10_1, TimerOverText10_2
	
;4028 - 407C are 1's or 0's, signifying if lazers can damage a given entity
	db 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
;407D is something for subscreen state 2
	db $15, $16, $1A, $09, 0
;4082 is unused?
	db $01, $02, $03, $04, $05, $0E, $0D, $0C, $0B, 0
;408C is something for subscreen state 3
	db $05, $06, $13, $17, $18, $19, $0F, $10, 0
;4095 is something for subscreen state 4 (these all end with a 0)
	db $07, $08, $1B, $1C, 0

HandleShopState: ;409A
	call ShopkeepNPCLogic
	ld hl, $408C ;? is this an item?
	call c, EmptyPromptFunc ;called if A pressed at the prompt
	jp CallRestoreGUIAndMusic ;reload GUI for exiting
	
HandleState2: ;40A6
	ld hl, $407D ;?
	call EmptyPromptFunc
	jp CallRestoreGUIAndMusic
	
HandleState4: ;40AF, gas station?
	ld hl, $4095 ;?
	call EmptyPromptFunc
	jp CallRestoreGUIAndMusic
	
HandleJunctionState: ;40B8
	call LoadUnusedJunctionTiles
	ld a, TRACK_RESULTS
	ld [wQueueMusic], a
	jr .entry
	pop hl
.returnpoint ;40C3, pushed as a return point?
	call CallDisableLCD
.entry
	ld hl, JunctionStockedTilemap ;use this tilemap if nothing bought yet
	ld a, [wJunctionBought]
	or a
	jr z, .settilemap
	ld hl, JunctionBoughtTilemap ;else use this tilemap
.settilemap
	call LoadBank7TilesetOffset80
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	loadpalette 0, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
.loop
	xor a
	ldh [hGameState], a
	cpl
	ld [$CACC], a ;FF to this i guess
	ld a, $64
	ld [$C272], a
	ld a, $01
	ld [wMenuSelection], a 
	ld a, $03
	ld [wMenuOptions], a
	ld a, $55
	ld [wContinueOptionBaseY], a
	xor a
	ldh [$FFD1], a ;write 0 here
	call CallHandleContinueScreenInput
	ld a, $02
	ld [wQueueSFX], a
	ret c ;selected exit
	ld a, [wMenuSelection]
	or a
	jr nz, .selectedshop
	call CallHandleJunctionTunnelSel
	ret c 
	jp HandleJunctionState ;else loop
	
.selectedshop
	dec a
	ret nz ;we selected the shop
	ld hl, wJunctionBought
	ld a, [hl]
	or a
	jr nz, .loop ;if selected the shop, but already bought from it, loop again
	;that jump prevents seeing a bunch of english dialogue
	cpl
	and $07 ;it will now always be $07
	jp nz, .junctionshop
	ld hl, JunctionTextThisBase ;what bank, 5? this base has run
	ld c, $32
	call CallTryWriteScreenText
	ld hl, JunctionTextNoStock ;out of supplies
	ld c, $32
	call CallTryWriteScreenText
	ret
	
.junctionshop ;we're in the shop now.
	ld hl, .returnpoint
	push hl ;push a return point
	call CallDisableLCD
	ld hl, JunctionShopTilemap ;tileset
	call LoadBank7TilesetOffset80
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	loadpalette 0, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	xor a
	ldh [hGameState], a
	ld [wMenuSelection], a
	cpl
	ld [$CACC], a ;$FF to this again
	ld a, $03
	ld [wMenuOptions], a
	ld a, $54
	ld [wContinueOptionBaseY], a
	xor a
	ldh [$FFD1], a ;clear on entering the shop
	call CallHandleContinueScreenInput
	ret c
	ld a, $09
	ld [wQueueSFX], a
	ld hl, wJunctionBought ;time to test this
	ld a, [wMenuSelection]
	or a
	jp nz, .checkGas
	bit 0, [hl] ;we selected option 1
	jr z, .buyShield
	ld hl, JunctionTextThisBase ;this base has run
	ld c, $32
	call CallTryWriteScreenText
	ld hl, JunctionTextNoShield ;out of materials
	ld c, $32
	call CallTryWriteScreenText
	ret
.buyShield
	set 0, [hl]
	ld a, MAX_HEALTH
	ld [wHealth], a ;full refill!
	ld hl, JunctionTextGotShield
	ld c, $32
	call CallTryWriteScreenText
	ret
.checkGas ;41A3
	dec a
	jp nz, .checkMissiles
	bit 1, [hl]
	jr z, .buyGas
	ld hl, JunctionTextThisBase ;this base has run 
	ld c, $32
	call CallTryWriteScreenText
	ld hl, JunctionTextNoFuel ;out of fuel supplies
	ld c, $32
	call CallTryWriteScreenText
	ret
.buyGas
	set 1, [hl]
	ld a, $FF
	ld [wFuelAmountLo], a
	ld [wFuelAmountHi], a ;full refill!
	ld hl, JunctionTextGotGas
	ld c, $32
	call CallTryWriteScreenText
	ret
.checkMissiles ;41CF
	dec a
	ret nz
	bit 2, [hl]
	jr z, .buyMissiles
	ld hl, JunctionTextThisBase ;this base has run
	ld c, $32
	call CallTryWriteScreenText
	ld hl, JunctionTextNoFuel ;out of fuel supplies
	ld c, $32
	call CallTryWriteScreenText
	ret
.buyMissiles
	set 2, [hl]
	ld a, MISSILES_MAX
	ld [wMissileCount], a ;full refill!
	ld hl, JunctionTextGotMissiles
	ld c, $32
	call CallTryWriteScreenText
	ret


ShopkeepNPCLogic: ;41F6
	call CallDisableLCD
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	xor a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call ClearAllVRAM
	call LoadGuiSpecials
	call CallDrawCompass
	call CallDrawFuel
	call CallEmpty1022D
	call CallSetAlertTiles
	ld a, $FF
	ldh [hGameState], a
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	set LCD_STAT, a
	ldh [rIE], a
	call CallClear3DBG
	call CallDrawRadarBG
	call CallCheckRadarStatic
	call CallDrawRadarStatic
	call CallCopyWRAMToVRAM
	call CallCopyWRAMToVRAM
	loadpalette 3, 2, 1, 0
	ldh [rBGP], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld hl, ShopkeepGreeting
	ld bc, $0000
	call HandleShopkeepTextPage
	call CallDrawHalf3D
	call ConvoWaitAnyInput
	ld hl, ShopkeepPrompt
	ld bc, $0000
	call HandleShopkeepTextPage
	call CallDrawHalf3D
	call ConvoInputPrompt ;carry set if A on prompt
	ret
;4264

SECTION "3:4286", ROMX[$4286], BANK[3]
ConvoWaitAnyInput: ;4286
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d ;get new presses
	and $0F
	jr z, ConvoWaitAnyInput ;loop until button to advance text
	ret
ConvoInputPrompt: ;4296
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d ;get new presses
	rra
	ret c ;return with carry set if A pressed
	rra
	jr nc, ConvoInputPrompt ;loop until A or B pressed
	ccf
	ret ;return with carry clear if B pressed

ShopkeepGreeting: ;42A8
db  "    WELCOME     ", \
	"   EARTHLING    ", \
	"                ", \
	"I AM FVARG YOUR ", \
	"   FRIENDLY     ", \
	" NEIGHBOURHOOD  ", \
	"    ALIEN", 00
ShopkeepPrompt: ;4312
db  " DO YOU WISH TO ", \
	" PURCHASE SOME  ", \
	" SUPERB QUALITY ", \
	"    PODULES     ", \
	"                ", \
	"                ", \
	"   A FOR YES    ", \
	"   B FOR NO", 00
	
HandleShopkeepTextPage: ;438E
	push bc
	push hl
	call .looktoscreen ;reversed at the end of this routine
	pop hl
	pop bc
.textloop
	push bc
	call UpdateInputs
	pop bc
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d ;d is pressed inputs
	and $0F ;mask to non-directions
	jr z, .nonepressed ;if none pressed, skip
.allcharsloop
	ld a, [hl+] ;read next byte from string
	or a
	jp z, .stringprinted ;if eof, jump ahead
	push hl
	push bc
	call CopyLetterToWRAM ;else print it
	pop bc
	inc c
	ld a, c
	cp $10
	jr c, .nextchar ;if at 16 chars, newline
	inc b
	ld c, $00
.nextchar
	pop hl
	jr .allcharsloop
.nonepressed
	ld a, [hl+]
	or a
	jr z, .stringprinted ;eof, jump
	push hl
	push bc
	cp " " ;space
	jr z, .space
	call CopyLetterToWRAM
	ld a, $02
	ld [wQueueWave], a
	ld a, [wFrameCounterLo]
	and $18 ;will only be 0, 8, 10, or 18. an offset for frames?
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	jr .checknewline
.space
	call CopyLetterToWRAM
	call CallDrawConvoScreen
.checknewline ;6
	pop bc
	inc c
	ld a, c
	cp $10
	jr c, .speaknextchar
	inc b ;A0
	ld c, $00
.speaknextchar
	pop hl
	jr .textloop
.stringprinted ;43FB, the full string has been printed
	call .wait4blanks
	ld a, $20
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $28
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $30
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $38
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	ret
	
.wait4blanks ;4428
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	ret
	
.looktoscreen ;4435
	call .wait4blanks
	ld a, $38
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $30
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $28
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	call .wait4blanks
	ld a, $20
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	xor a
	call CallLoadShopkeepFrame
	call CallDrawConvoScreen
	ret
;4469

SECTION "3:4473", ROMX[$4473], BANK[3]
EmptyPromptFunc: ;4473, called if A pressed at shopkeep prompt
	ret
;4474

SECTION "3:448D", ROMX[$448D], BANK[3]
LoadUnusedJunctionTiles: ;448D
	call CallDisableLCD
	call ClearAllVRAM
	call LoadUnusedTextTiledata
	call WipeWholeScreenTiles
	ld hl, InterfaceUnusedGFX
	ld de, $8000
	ld b, $20
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ret
;44A8

SECTION "3:44D1", ROMX[$44D1], BANK[3]
IF UNUSED == 1
OpenOptions: ;44D1
	ld a, [$CACE]
	or a
	jp nz, ShowSatellite
	call LoadUnusedJunctionTiles
	jr OptionsMenu.entry
OptionsMenu: ;44DD
	pop hl
	call CallDisableLCD
.entry ;4
	ld hl, tilesetMainInterface
	call LoadBank7TilesetOffset80
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	xor a
	ldh [hGameState], a ;paused?
	cpl
	ld [$CACC], a
	ld a, [$CACA]
	ld [wMenuSelection], a
	ld a, $43
	ld [wContinueOptionBaseY], a
	ld a, $05
	ld [wMenuOptions], a
	call CallHandleContinueScreenInput
	ld a, [wMenuSelection]
	ld [$CACA], a
	ld hl, CallRestoreGUIAndMusic
	push hl
	ret c
	ld a, [wMenuSelection]
	or a
	jp z, ProximityLockMenu ;selected first option
	dec a
	jp z, ProximityRangeMenu ;selected second option
	dec a
	jp z, CallGetAdvice ;selected third option
	dec a
	jp z, PickedSatellite ;selected fourth option
	dec a
	jp z, JettisonCargo ;selected fifth option
	ret
	
;4532
	pop hl
	call CallDisableLCD
	call ClearAllVRAM
	call LoadUnusedTextTiledata
	call WipeWholeScreenTiles
	ld a, $A3
	call CallFlashScreen
	call WaitForStartPress
	jp OpenOptions
ENDC

FindEntityWithModelA: ;454A
	ld c, a
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop
	ld a, [hl]
	cp c
	jr z, .found
	ld a, l
	add a, ENTITY_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jr nz, .loop
	and a
	ret
.found ;D
	scf
	ret
	
IF UNUSED == 1
JettisonCargo: ;4563
	ld a, [wHasCargo]
	or a
	ret z
	call GetFreeEntity
	ret c
	ld a, [wHasCargo]
	dec a
	jr z, .crystalmodel ;if crystal
	dec a
	jr z, .rodsmodel ;reactor rods
	dec a
	jr z, .thirdmodel ;imposter?
	ld a, $13 ;black box? model
	jr .savemodel
.crystalmodel ;A
	ld a, $0C ;crystal model
	jr .savemodel
.rodsmodel ;B
	ld a, $10 ;reactor rods model
	jr .savemodel
.thirdmodel ;C
	ld a, $11 ;??? model
.savemodel ;A, 6, 2
	ld [hl+], a ;save model
	push hl
	call CallPlaceEntityInView
	pop hl
	call CallTestEntityHasCollisions
	jr nc, .clearCargo
	ld a, [wHasCargo]
	cp CARGO_REACTOR_RODS
	jr nz, .wipeEnt
	dec hl
	ld a, [hl+]
	cp $18 ;silo
	jr nz, .wipeEnt ;if not the right ent, jump
	push de
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [$C2C2]
	inc a
	ld [$C2C2], a
	dec a
	rlca
	rlca
	add a, LOW(ReactorRodsOffsets)
	ld l, a
	ld a, HIGH(ReactorRodsOffsets)
	adc a, $00
	ld h, a ;HL 45FB
	ld a, [hl+]
	add a, c
	ld c, a
	ld a, [hl+]
	adc a, b
	ld b, a
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, [hl+]
	adc a, d
	ld d, a
	pop hl
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a
	ld a, l
	add a, $05
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, LOW(CollectReactorRod)
	ld [hl+], a
	ld a, HIGH(CollectReactorRod)
	ld [hl+], a ;load 1C8E into logic?
	ld hl, RodInsertedText
	ld a, [$C2C2]
	cp $04
	jr nz, .text
	xor a
	ld [wTimerEnableFlag], a
	ld hl, SiloSafeText
.text ;7
	ld c, $32
	call CallTryWriteScreenText
.clearCargo ;61
	xor a
	ld [wHasCargo], a
	ret
.wipeEnt ;5F, 59
	dec de
	xor a
	ld [de], a ;wipe the spawned ent
	ret
ReactorRodsOffsets: ;45FB, table of four-byte entries
	dw -100, -100
	dw  100, -100
	dw -100,  100
	dw  100,  100
	
ProximityLockMenu: ;460B, first option
	call CallDisableLCD
	ld hl, JunctionStockedTilemap
	call LoadBank7TilesetOffset80
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld a, $54
	ld [wContinueOptionBaseY], a
	ld a, $03
	ld [wMenuOptions], a
	ld a, [$CACB]
.loop
	ld [$CACC], a
	call CallHandleContinueScreenInput
	jp c, OptionsMenu
	ld a, [wMenuSelection]
	ld [$CACB], a
	cp $02
	jp z, SpecifyObject
	jr .loop
ProximityRangeMenu: ;4645, second option
	call CallDisableLCD
	ld hl, JunctionStockedTilemap
	call LoadBank7TilesetOffset80
	ld a, $A3
	call CallFlashScreen
	ld a, $54
	ld [wContinueOptionBaseY], a
	ld a, $03
	ld [wMenuOptions], a
	ld a, [wProxRange]
.loop
	ld [$CACC], a
	call CallHandleContinueScreenInput
	jp c, OptionsMenu
	ld a, [wMenuSelection]
	ld [wProxRange], a
	jr .loop
ENDC


HandleContinueScreenInput: ;4671
	;returns if a pressed
	;returns with clear flag if b or start pressed
	ld a, [$CACC]
	cp $FF
	jr z, .loop
	ld [wMenuSelection], a
.loop
	halt
	call UpdateInputs
	ld a, [wMenuSelection]
	ld c, a
	ld a, [wMenuOptions]
	ld b, a
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld d, a ;d is our inputs
	jr z, .skeep ;if no inputs, don't need to handle them
	bit 7, d ;up?
	jr z, .handle6
	ld a, $03
	ld [$C100], a
	inc c
	ld a, c
	cp b
	jr c, .handle6
	ld c, b
	dec c
.handle6
	bit 6, d ;down?
	jr z, .handleothers
	ld a, $03
	ld [$C100], a
	dec c
	ld a, c
	cp b
	jr c, .handleothers
	ld c, $00
.handleothers
	xor a
	bit 0, d ;a
	ret nz
	scf
	bit 3, d ;start
	ret nz
	bit 1, d ;b
	ret nz
.skeep
	ld a, c
	ld [wMenuSelection], a
	ld hl, $C000
	ld a, c
	swap a
	add a, c ;mirror the bit to both nybbles?
	ld c, a
	ld a, [wContinueOptionBaseY] ;base Y for selection
	add a, c ;add our 0 or 11 offset
	ld c, a
	ld [hl+], a ;store the Y
	ld a, $12
	ld [hl+], a ;store X of $12
	xor a
	ld [hl+], a ;tile 0
	ld [hl+], a ;attrib 0
	ld a, c
	ld [hl+], a ;store Y
	ld a, $96
	ld [hl+], a ;store X of $96
	xor a
	ld [hl+], a ;tile 0
	ld a, $20
	ld [hl+], a ;x-flip attribute
	ld a, [$CACC] ;now draw the garbage sprite
	cp $FF
	jr nz, .skeep2
	ld a, $08
.skeep2
	ld c, a
	swap a
	add a, c
	ld c, a ;88 or FE?
	ld a, [wContinueOptionBaseY]
	add a, c
	ld [hl+], a
	ld a, $8E ;X $8E?
	ld [hl+], a
	ld a, $01 ;tile 1?
	ld [hl+], a
	xor a
	ld [hl+], a ;attribute 0?
	jp .loop
	
	nop

;46FE - 4ABD: planet graphics
INCBIN "build/gfx/PlanetSpin.2bpp"
InterfaceGFX: ;4ABE
INCBIN "build/gfx/Reticles.2bpp"
INCBIN "build/gfx/Indicators.2bpp"
INCBIN "build/gfx/FuelBars.2bpp"
INCBIN "build/gfx/CargoGem.2bpp"
INCBIN "build/gfx/TopTimer.2bpp"
INCBIN "build/gfx/InterfaceMisc.2bpp"
InterfaceSegmentNumsGFX: ;4E5E
INCBIN "build/gfx/SegmentNumbers.2bpp"
.end
InterfaceUnusedGFX: ;4F9E
INCBIN "build/gfx/InterfaceUnused.2bpp"

LoadTunnelHealthGFX: ;4FBE
	ld hl, $4FD4
	ld de, $8870
	ld b, $20
.loop
	ldh a, [rSTAT]
	and $02
	jr nz, .loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .loop
	ret
;4FD4 - 5013: tunnel health graphics (second half unused??)
INCBIN "build/gfx/TunnelHealth.2bpp"
InterfaceMainGFX: ;5014 - 0x5153: interface graphics, bottom status
INCBIN "build/gfx/InterfaceMain.2bpp"
;5154

SECTION "3:517A", ROMX[$517A], BANK[3]
IF UNUSED == 1
SpecifyObject: ;517A
	pop hl
	ld a, $01
	call HandleRadarBase.usepassedprecision
	jp OpenOptions
ShowSatellite: ;5183
	call HandleRadarBase
	jp CallRestoreGUIAndMusic
PickedSatellite: ;5189
	pop hl
	call HandleRadarBase
	jp OpenOptions
ENDC

SECTION "3:5190", ROMX[$5190], BANK[3]
HandleRadarBase: ;5190, radar base logic
	xor a
.usepassedprecision
	ldh [$FF97], a
	call CallDisableLCD
	ld a, $08
	ldh [rSCX], a
	xor a
	ldh [rSCY], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a ;wipe all these
	call ClearAllVRAM
	call CallLoadGameplayGUIgfx
	ld hl, RadarBaseTilemap
	ld bc, $009F
	call LoadBank7TilesetOffset80.skip
	ld hl, $9863
	ld bc, $0880
	ld a, $00
.outertileloop
	push bc
	ld b, $10
.tileloop
	ld [hl+], a
	add a, $08
	dec b
	jr nz, .tileloop
	ld bc, $0010
	add hl, bc
	pop bc
	inc c
	ld a, c
	add a, $80
	dec b
	jr nz, .outertileloop
	call CallMonoBufferToRadarScreen
	xor a
	ld [$C297], a
	ld a, $21
	ld [wTextBubbleX], a
	ld hl, $7981
	ld c, $60
	call CallHandleTitleText
	ld b, $22
	call CallDrawTitleLetters
	call CallHandleRadarLevelText
	call CallMonoBufferToRadarScreen
	ldh a, [hXPosHi]
	add a, $80
	rlca
	and $01
	ld c, a
	ldh a, [hYPosHi]
	add a, $80
	cpl
	inc a
	swap a
	rrca
	and $06
	add a, c
	ld [wStationArea], a ;the math above determines which station we're in?
	xor a
	ld [wBJustPressed], a
	ld [wAJustPressed], a
	ld hl, $9832
	ld a, $81
	ld [hl+], a
	add a, $02
	ld [hl+], a
	dec a
	ld hl, $9852
	ld [hl+], a
	add a, $02
	ld [hl+], a
	ld a, [wStationArea]
	swap a ;make it a nybble each?
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl ;$40 * station ID
	ld bc, AreaNumbersGFX ;area num gfx's
	add hl, bc
	ld de, $8810 ;tile gfx data
	ld b, $40
.copyareanumGFX ;5230
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .copyareanumGFX
	ld hl, BasePipGFX ;the + gfx
	ld de, $8000
	ld bc, $0020
.piploop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .piploop
	ld c, $48
	ld b, $78
	ld e, $00
	call DrawMinimapPips
	ld a, $FF
	ldh [hGameState], a
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	set LCD_STAT, a
	ldh [rIE], a
	ld hl, $99A9
	ld de, $001C
	ld b, $04
.minimaploop ;5266
	ld a, $92
	ld [hl+], a
	ld a, $8F
	ld [hl+], a
	ld a, $92
	ld [hl+], a
	ld a, $8F
	ld [hl+], a
	add hl, de
	dec b
	jp nz, .minimaploop
	ld hl, $99A9
	ld b, $00
	ld a, [wStationArea]
	ld e, a
	and $01
	rlca
	ld c, a
	ld a, e
	and $FE
	rlca
	rlca
	rlca
	rlca
	add a, c
	ld c, a
	add hl, bc
	ld a, $93
	ld [hl+], a
	ld a, $90
	ld [hl+], a
	call CallSetupRadarItemGFX
	xor a
	ld [wMenuSelection], a ;wMenuSelection, CAC8
	ldh [$FF97], a ;?
	call HandleRadarItems
	loadpalette 2, 1, 0, 3
	ldh [hBGP], a
	loadpalette 2, 1, 0, 3
	ldh [hIntP], a
	ldh [rBGP], a
	loadpalette 2, 1, 3, 3
	ldh [rOBP0], a
	loadpalette 2, 1, 0, 3
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld a, $64
	ld [$C272], a ;?
	ld a, [wTutProgress]
	cp $06
	jr nz, .updatedTutProgress
	ld a, $07
	ld [wTutProgress], a
.updatedTutProgress
	ld a, $01
	ld [$D058], a
	xor a
	ld [wUpdateCounter], a
.mainloop ;52D1, main loop
	ld a, [wTutRadarTextPage] ;tutorial text page
	cp $02
	jr c, .checkpageTime
	cp $06
	jr c, .checkpageInput
.checkpageTime ;4, page 0 or 1, or 6 or 7 (advances over time)
	ld a, [wFrameCounterLo]
	and $01
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	jr nz, .checkInputs ;every other frame, jump 2D
	jr .printText ;otherwise jump 0C?
.checkpageInput;10, pages 3, 4, 5, and 6 (the Equip texts?), advances by press
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	and (1 << INPUT_A)
	jr z, .checkInputs
.printText ;C
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr nz, .checkInputs ;if not tutorial, skip
	ld a, $21
	ld [wTextBubbleX], a
	ld hl, $7981
	ld c, $60
	call CallHandleTitleText
	ld b, $22
	call CallDrawTitleLetters
	call CallHandleRadarLevelText
	call CallMonoBufferToRadarScreen
.checkInputs
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld d, a ;pressed buttons in D
	ld a, [wTutSawAllRadarText]
	or a
	jr nz, .checkLeave
	ld a, [wTutRadarTextPage]
	cp $08
	jr z, .checkLeave
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .inpUp ;make sure we see all the tutorial text!
.checkLeave
	bit INPUT_START, d
	ret nz
	bit INPUT_B, d
	ret nz ;leave station if START or B pressed
.inpUp
	ld a, [wMenuSelection]
	push af
	bit INPUT_UP, d
	jp z, .inpDown
	ld a, [wMenuSelection]
	dec a
	and $03 ;loop if needed
	ld [wMenuSelection], a
	ld a, $01 ;beep
	ld [wQueueSFX], a
	ld a, $FF
	ld [$D058], a
.inpDown
	ld a, d
	and (1<<INPUT_DOWN) | (1<<INPUT_SELECT)
	jp z, .vertDone
	ld a, [wMenuSelection]
	inc a
	and $03
	ld [wMenuSelection], a
	ld a, $01 ;beep
	ld [wQueueSFX], a
	ld a, $01
	ld [$D058], a
.vertDone
	ld a, [wMenuSelection]
	and $03
	ld c, a ;the vert is in C
	pop af
	and $FC ;grab the old horiz
	or c
	ld [wMenuSelection], a ;and update selection
	ld a, d
	and (1<<INPUT_LEFT) | (1<<INPUT_RIGHT)
	jr z, .horizDone
	ld a, [wMenuSelection]
	xor $04
	ld [wMenuSelection], a ;swap sides
	ld a, $01 ;beep
	ld [wQueueSFX], a
	ld a, $01
	ld [$D058], a
.horizDone
	ld a, d
	and (1<<INPUT_A)
	jp z, .loopend ;jump if A was not pressed
	ld a, $02 ;beep
	ld [wQueueSFX], a
	ld a, [wStationArea]
	add a, LOW(wRadarBasesTable)
	ld l, a
	ld a, $00
	adc a, HIGH(wRadarBasesTable)
	ld h, a ;HL is now pointed at our base data byte
	ld a, $01
	ld [$D058], a
	ld a, [wMenuSelection]
	or a
	jr z, .sel0
	dec a
	jr z, .sel1
	dec a
	jr z, .sel2
	dec a
	jr nz, .selWeapons
	ld a, [wTutSawAllRadarText] ;else selection 3, EXIT. test leave cases.
	or a
	ret nz
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ret nz
	ld a, [wTutRadarTextPage]
	cp $08
	jp nz, .loopend
	ret
.selWeapons ;selection 4 or above
	dec a
	ld [wEquippedWeapon], a ;set equipped weapon to selection - 4
	xor a
	ld [$D058], a
	ld a, $02 ;beep
	ld [wQueueSFX], a
	jr .loopend
.sel0 ;missiles
	bit BASE_MISSILE, [hl]
	jr nz, .loopend ;if already obtained, jump 541D
	set BASE_MISSILE, [hl]
	ld a, [wMissileCount]
	inc a
	cp MISSILES_MAX + 1
	adc a, $FF
	ld [wMissileCount], a ;increment to 8, no more. you can waste missiles this way.
	jp .loopend
.sel1 ;fuel
	bit BASE_FUEL, [hl]
	jr nz, .loopend
	set BASE_FUEL, [hl]
	ld a, [wFuelAmountHi]
	add a, $40
	jr nc, .cappedfuel
	ld a, $FF ;max
.cappedfuel
	ld [wFuelAmountHi], a
	jp .loopend
.sel2 ;shield
	bit BASE_SHIELD, [hl]
	jr nz, .loopend
	set BASE_SHIELD, [hl]
	ld a, [wHealth]
	inc a
	cp MAX_HEALTH + 1
	adc a, $FF
	ld [wHealth], a
.loopend ;541D
	call HandleRadarItems
	jp .mainloop
	
HandleRadarItems: ;5423
	ld a, [wStationArea]
	add a, LOW(wRadarBasesTable)
	ld l, a
	ld a, $00
	adc a, HIGH(wRadarBasesTable)
	ld h, a ;hl is pointed at this base's data byte
	bit BASE_MISSILE, [hl]
	ld b, $02
	jr z, .missile
	ld b, $00
.missile
	push hl ;save position
	ld c, $00;b is 0 if set, 2 if not. c is zero 
	call HandleRadarItemLeft
	pop hl
	bit BASE_FUEL, [hl]
	ld b, $02
	jr z, .fuel
	ld b, $00
.fuel
	push hl
	ld c, $01
	call HandleRadarItemLeft
	pop hl
	bit BASE_SHIELD, [hl]
	ld b, $02
	jr z, .shield
	ld b, $00
.shield
	ld c, $02
	call HandleRadarItemLeft
	ld c, $03
	ld b, $02
	call HandleRadarItemLeft
	ld c, $04
	ld b, $02
	call HandleRadarItemRight
	ld c, $05
	ld b, $02
	call HandleRadarItemRight
	ld c, $06
	ld b, $02
	call HandleRadarItemRight
	ld c, $07
	ld b, $02
	call HandleRadarItemRight
	ret
	
HandleRadarItemLeft: ;547D
	ld a, [wMenuSelection]
	cp c
	jr nz, .done ;if not on the option we're checking, skip
	push bc
	ld a, [wFrameCounterLo]
	swap a
	and $01
	inc a
	ld c, a
	ld a, b
	or a
	ld a, c
	pop bc
	ld b, a
	jr nz, .done
	ld a, [$D058]
	ld e, a
	ld a, [wMenuSelection]
	and $FC
	ld d, a ;d is high bits (side)
	ld a, [wMenuSelection]
	add a, e ;offset
	and $03
	or d ;keep old high bits
	ld [wMenuSelection], a ;store
	ld b, $00
.done
	call CallDrawRadarBaseItem
	ret
;54AE
	
SECTION "3:5546", ROMX[$5546], BANK[3]
HandleRadarItemRight: ;5546
	ld a, [wMenuSelection]
	cp c
	jr nz, .nothilighted
	ld a, [wFrameCounterLo]
	swap a
	and $01
	inc a
	ld b, a
	ld a, [wEquippedWeapon]
	add a, $04
	cp c
	jr nz, .done
	dec b
	jr .done
.nothilighted
	ld a, [wEquippedWeapon]
	add a, $04
	cp c
	jr nz, .done
	ld b, $00
	ld a, [wMenuSelection]
	cp c
	jr nz, .done
	ld a, [$D058]
	ld e, a
	ld a, [wMenuSelection]
	and $FC
	ld d, a
	ld a, [wMenuSelection]
	add a, e
	and $03
	or d
	ld [wMenuSelection], a
.done
	call CallDrawRadarBaseItem
	ret


WriteOAMEntry: ;5588
	ld a, b
	ld [hl+], a ;xloc
	ld a, c
	ld [hl+], a ;yloc
	ld a, e
	ld [hl+], a ;tile
	xor a
	ld [hl+], a ;attribute
	ret
;5591

SECTION "3:5A4E", ROMX[$5A4E], BANK[3]
BasePipGFX: ;5A4E: + tile
INCBIN "build/gfx/pip.2bpp"
;5A5E: o tile
INCBIN "build/gfx/point.2bpp"
IF UNUSED == 1
HexValuesGFX: ;5A6E: 2bpp hex value tiles
INCBIN "build/gfx/hex.2bpp"
ENDC
BlankTileGFX1bpp: ;5B6E: blank 1bpp tile
INCBIN "build/gfx/blanktile.1bpp"
AlphabetGFX1bpp: ;5B76 - 5C65: 1bpp letters
INCBIN "build/gfx/alphabet.1bpp"
;5C66 - 5CAD: 1bpp misc
INCBIN "build/gfx/misc.1bpp"
INCBIN "build/gfx/specialS.1bpp"
INCBIN "build/gfx/boxChars.1bpp"
NumbersGFX1bpp: ;5CAE - 5D05: 1bpp numbers
INCBIN "build/gfx/numbers.1bpp"
DollarGFX1bpp: ;1bpp dollar
INCBIN "build/gfx/dollar.1bpp"
;5D05

SECTION "3:5D86", ROMX[$5D86], BANK[3]
SetEquipmentItem: ;5D86
	ld a, [wEquippedWeapon]
	cp WEAPON_NONE
	jr c, .haveitem
	xor a
	ld [wInventory1], a
	ret
.haveitem ;5
	add a, LOW(EquipmentItemsTable)
	ld l, a
	ld a, $00
	adc a, HIGH(EquipmentItemsTable)
	ld h, a
	ld a, [hl+]
	ld [wInventory1], a
	ret
	
EquipmentItemsTable: ;5D9F
	db $1F, $20, $1D, $1A
;5DA3

SECTION "3:5DE3", ROMX[$5DE3], BANK[3]
ItemTypes: ;5DE3, item types
	;type of 0 will only activate on pressing B?
	;type of 1/5 will only activate on pressing A
	;type of 2 will always be active when equipped
	;type of 3 will always be active when in inventory
	;fives: d beam, q beam, mainlaser
	;threes: x power, finder, bomb, jetpac, lock on, high ex
	db 0, 0, 0, 5, 5, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 3, 5, 3, 3

UseCrystalText: ;5E03 - 5E76, english crystal use text
	db "ONE CRYSTAL", 00 
	db "WILL RESTORE", 00
	db "YOUR SHIELD", 00
	db "TO MAXIMUM", 00
	db "START  CANCELS", 00
	db "A  CONTINUES", 00
	db " YOU HAVE NO  ", 00
	db "CRYSTAL TO USE", 00
	db "YOUR FUEL", 00

UseItem: ;5E77
	ld a, [$CAE0]
	cp $FF
	ret z ;if item zero, return
	add a, $E3
	ld l, a
	ld a, $5D
	adc a, $00
	ld h, a ;HL is now 5DE3 + our item
	ld a, [hl]
	ldh [$FFAE], a ;store table value
	ld a, [$CAE0]
	sla a
	add a, LOW(ItemFuncs)
	ld l, a
	ld a, HIGH(ItemFuncs)
	adc a, $00
	ld h, a ;HL = 5F03 + our item
	di
	ld a, [wHideCrosshair]
	res 0, a ;show
	bit 2, a
	jr z, .saveCH
	set 0, a ;hide
.saveCH ;2
	res 2, a ;clear bit 2
	ld [wHideCrosshair], a ;save it
	ei
	xor a
	ld [$CACE], a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl ;jump to our pointer from the table
	
CheckInventoryForItemTypeThree: ;5EAF
	xor a
	ld [wPowerBoost], a ;reset this every frame, it'll get activated by this func if in inventory
	ld a, [wInventory]
	or a
	call nz, DoItemTypeThree
	ld a, [wInventory + 1]
	or a
	call nz, DoItemTypeThree
	ld a, [wInventory + 2]
	or a
	call nz, DoItemTypeThree
	ld a, [wInventory + 3]
	or a
	call nz, DoItemTypeThree
	ld a, [wInventory + 4]
	or a
	call nz, DoItemTypeThree
	ld a, [wInventory + 5]
	or a
	call nz, DoItemTypeThree
	ret
	
DoItemTypeThree: ;5EDE
	dec a
	ld [$CAE0], a
	add a, LOW(ItemTypes)
	ld l, a
	ld a, HIGH(ItemTypes)
	adc a, $00
	ld h, a
	ld a, [hl]
	ldh [hItemType], a
	and $03
	cp $03
	ret nz ;return if not type three
	ld a, [$CAE0]
	sla a
	add a, LOW(ItemFuncs)
	ld l, a
	ld a, HIGH(ItemFuncs)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl ;otherwise activate it

ItemFuncs: ;5F03, item function pointer table
	dw Item_PlasmaBalls, Item_Pulse, Item_Lazer, Item_Lazer, Item_QuadBeam, Item_Meson, Item_Fuel, Item_HP, Item_XPower, Item_Finder, Item_4Torp, Item_3Torp, Item_2Torp, Item_1Torp, Item_Proxy2, Item_Proxy1, Item_MakeCrystal, Item_UnusedXPUTER, Item_Cubify, Item_WarpNearest.beacon, Item_WarpNearest.junction, Item_WarpNearest, Item_ThreeMines, Item_TwoMines, Item_OneMine, Item_Bomb, Item_XFuel, Item_XHP, Item_Jetpac, Item_MainLazer, Item_Missile, Item_HighEX
Item_HighEX: ;5F43, item 32
	ld a, [wBJustPressed]
	or a
	ret z ;must be B pressed
	xor a
	ld [wBJustPressed], a
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ret z ;do nothing in tutorial
	ld a, [wMissileCount]
	sub $08
	jr nc, .hasammo
	ld hl, NotEnoughMissilesText
	ld c, $32
	call CallTryWriteScreenText
	ret
.hasammo ;9, had eight missiles
	ld [wMissileCount], a
	call GetFreeEntity
	ret c
	ld a, $24 ;copy of missile?
	ld [hl+], a
	ldh a, [hXPosLow]
	ld [hl+], a
	ldh a, [hXPosHi]
	ld [hl+], a
	ldh a, [hYPosLow]
	ld [hl+], a
	ldh a, [hYPosHi]
	ld [hl+], a
	ldh a, [hZPosLow]
	cpl
	add a, $01
	ld [hl+], a
	ldh a, [hZPosHi]
	cpl
	adc a, $00
	ld [hl+], a ;invert Z?
	xor a
	ld [hl+], a
	ld a, [wViewDir]
	ld [hl+], a
	xor a
	ld [hl+], a ;XYZ orientation set
	ld a, $C4
	ld [hl+], a
	ld a, $1B
	ld [hl+], a
	ld a, $04
	ld [hl+], a ;three values
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;wipe the rest, leave the last byte since it's not a map object
	ld a, [wLurchCounter]
	bit 7, a
	jr z, .set
	xor a
.set
	sub $40
	ld [wLurchCounter], a
	ld a, $28
	ld [wKnockbackCounter], a
	ld a, $06
	ld [wQueueNoise], a
	ret
	
Item_Missile: ;5FBA
	ld hl, TutRefPoint2 ;before radar base brief?
	call CallCheckTutScriptProgress
	ret nc ;not authorized to use missiles i guess
	ld a, [wMissileCount]
	or a
	jr nz, .havemissile
	ld a, [wLockState] ;?
	or a
	call nz, $60C9
	ld a, [wBJustPressed]
	or a
	ret z
	xor a
	ld [wBJustPressed], a
	ld hl, NoMissilesText
	ld c, $32
	call CallTryWriteScreenText
	ret
.havemissile ;19
	call HandleLockOn
	ret
	
HandleLockOn: ;5FE4
	ld a, [$CAD1]
	or a
	jr nz, .reset
	ld a, [wLockState]
	or a
	jr z, .zero ;zero
	dec a
	jr z, .one ;one
	dec a
	jr z, .startlock ;two
	dec a
	jp z, .handlelock ;three
	dec a
	jp z, .four ;four
	dec a
	jp z, .five ;five
	dec a
	jp z, .six ;six
.reset ;1C, CAD1 was nonzero, so reset everything?
	xor a
	ld [$CAD1], a
	ld [wLockState], a
	ld [$CB19], a
	ld [$CAD2], a
	ld [$CAD3], a
	ret
.four ;6017
	ld a, $01
	ld [wLockState], a
	jr .one
.one ;also fell out of four or two
	xor a
	ld [wLockTicks], a ;clear this
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load crosshair target pointer into HL
	call ValidateTarget
	jr nc, .valid
	xor a
	ld [wEntInLockonRange], a
	jr .checkB
.valid
	ld a, [wEntInLockonRange]
	or a
	jr nz, .setinrange
	ld a, $05 ;chirp
	ld [wQueueSFX], a
.setinrange
	ld a, $01
	ld [wEntInLockonRange], a
	call DrawLock
.checkB
	ld a, [wBJustPressed]
	or a
	ret z
	xor a ;if B pressed, let's lock!
	ld [wBJustPressed], a
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr nz, .havetarget
	jp .notarget ;pressed B with no target?
.havetarget ;3
	call ValidateTarget
	ret c ;doublecheck the target is valid
	ld a, $02
	ld [wLockState], a ;stage 2 of lock
	jr .startlock
.zero ;76
	ld a, $04
	ld [wLockState], a
	jr .four ;to 6017
.startlock ;77, 7, pressed B on a valid target or we fell out of state 2
	xor a
	ld [wLockTicks], a ;reset lock ticks
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jp z, .unlock ;jump if no target,
	call ValidateTarget
	jp c, .unlock ;or if no longer valid
	ld a, l
	ld [$CAD2], a
	ld a, h
	ld [$CAD3], a ;set locked entity
	ld a, $03
	ld [wLockState], a ;stage 3 of lock
	xor a
	ld [wBJustPressed], a
	jr .handlelock ;to 60F2
.five ;6094
	ld a, $02
	ld [wQueueSFX], a
	ld a, [wLockTicks]
	inc a
	ld [wLockTicks], a
	cp $05
	jp nc, .unlock
	ld hl, $C328
	ld a, $F8 ;-8
	ld [hl+], a
	ld [hl+], a
	ld a, $08 ;+8
	ld [hl+], a
	ld [hl+], a
	call DrawLock
	ret
.six ;60B4
	ld hl, $75BB ;lock off
	ld bc, $0A04
	call CallCopyEnglishStringToWRAM
	ld a, [wLockTicks]
	sub $01
	ld [wLockTicks], a
	cp $80
	jr c, .untick ;to 60E3
.notarget ;60C9
	xor a
	ld [wLockState], a
	ld [$CB19], a
	ld [$CB1A], a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	ld [$C31B], a
	ld [$CB19], a
	ld [$CB47], a
	ret
.untick ;60E3
	ld hl, $C328
	ld a, $F8
	ld [hl+], a
	ld [hl+], a
	ld a, $08
	ld [hl+], a
	ld [hl+], a
	call DrawLock
	ret
.handlelock ;60F2
	ld a, [wCurrentInput]
	bit INPUT_SELECT, a
	jp nz, .unlock ;select forces un-lock
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld e, l
	ld d, h ;DE is target ent
	ld hl, $CAD2
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;hl is locked ent
	cp e
	jr z, .equal
	ld a, h
	cp d
	jp nz, .unlock ;if they don't match, un-lock
.equal ;5
	ld a, d
	or e
	jp z, .unlock ;if target ent is null, un-lock
	dec de
	ld a, [de]
	or a
	jp z, .unlock ;if target ent's model is zero, un-lock
	bit 7, a ;if target ent is flagged to be hidden, un-lock
	jp nz, .unlock
	dec hl
	ld a, [hl] ;load locked model into A
	call CallCheckEntityLockable
	cp $01
	jp nz, .unlock ;if we locked onto a nonlockable, un-lock
	ld hl, $C328 ;usually F8 F8 for first two values?
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	cp $80
	jp z, .unlock ;if $80 instead, un-lock
	ld e, l
	ld d, h ;two vals into DE
	ld a, e
	sub $08
	cp $80
	jr c, .underoverflow ;underflow, jump
	ld a, [wCrosshairYOffset]
	add a, $08
	ld c, a
	ld a, d
	sub a, c
	cp $80
	jr c, .underoverflow ;underflow, jump
	ld hl, $C32A ;08 08 for second two values?
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	add a, $08
	cp $80
	jr nc, .underoverflow ;overflow, jump
	ld a, [wCrosshairYOffset]
	sub $08
	ld c, a
	ld a, h
	sub a, c
	cp $80
	jr c, .flashret
.underoverflow ;25, 19, C
	xor a
	ld [wBJustPressed], a
	ld [$CB47], a
	jr .adjustcrosshair 
.flashret ;9
	ld a, $01
	ld [$CB47], a
.adjustcrosshair ;5
	ld hl, $C32A ;second two values
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;usually 08 08
	add a, e
	sra a
	ld l, a
	ld a, h
	add a, d
	sra a
	ld h, a ;hl += DE, /= 2?
	ld a, [wPitchAngle]
	add a, h
	cp $58
	jp nc, .unlock ;too low, un-lock?
	ld a, l
	add a, $40
	cp $80
	jp nc, .unlock ;too high, un-lock?
	ld a, [wPitchAngle]
	sub $34
	add a, h
	ld [wCrosshairYOffset], a
	ld a, l
	ld [wCrosshairXOffset], a
	ld a, [wCrosshairXOffset]
	ld e, $01
	add a, $80
	cp $78
	jr c, .chxc
	cp $88
	jr c, .saveCB1A 
	ld e, $03
	jr .saveCB1A 
.chxc ;8
	ld e, $02
.saveCB1A ;6, 2
	ld a, e
	ld [$CB1A], a
	jr .checkticks
.unlock ;61B9
	ld a, $06
	ld [wLockState], a
	xor a
	ld [$CB47], a
	ld [$CB46], a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	jp .six
.checkticks
	ld a, [wLockTicks]
	inc a
	cp $04
	jr nz, .saveticks
	ld a, $02 ;at 4
	ld [wQueueSFX], a
	ld a, $04
.saveticks
	cp $05
	adc a, $FF
	ld [wLockTicks], a
	cp $04
	jr nc, .drawlock
	ld a, $02
	ld [wQueueSFX], a
.drawlock
	call DrawLock
	ld hl, wLockedEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	dec hl
	ld a, [hl+]
	bit 7, a ;if ent hidden,
	jp nz, .unlock ;then unlock
	call CallGetDistanceFromPlayer
	cp $0D
	jr nc, .checkcounter ;jump if far?
	ld a, [$CB47]
	or a
	ld hl, $75AD ;object locked
	ld bc, $0A02
	call nz, CallCopyEnglishStringToWRAM
	ld a, [wBJustPressed]
	or a
	jr z, .checkorbit ;b wasn't pressed, so jump
;fire missile!
	ld a, [wMissileCount]
	sub $01
	jr c, .checkorbit ;oops, had none??
	ld [wMissileCount], a
	ld hl, $0000 ;no target
	call CallFireMissile
	xor a
	ld [wAJustPressed], a
	ld a, $05
	ld [wQueueNoise], a
	ld a, [wLurchCounter]
	bit 7, a
	jr z, .setrecoil
	xor a
.setrecoil
	sub $20
	ld [wLurchCounter], a
	ld a, $19
	ld [wKnockbackCounter], a
	jp .unlock
.checkcounter ;41
	ld a, [wFrameCounterLo]
	and $3F
	cp $20
.checkorbit ;35, 2E
	call CallOrbitTarget
	ret
	
ValidateTarget: ;6250
	;carry set if invalid target
	push hl
	call CallGetDistanceFromPlayer
	pop hl
	cp $0E
	jp nc, .setcarry
	dec hl ;we're close, now test something else
	ld a, [hl+]
	call CallCheckEntityLockable ;1 if targetable with lockon
	dec a
	jp nz, .setcarry
	xor a
	ret
.setcarry
	scf
	ret
	
Item_MainLazer: ;6267
	ld a, [wAJustPressed]
	or a
	ret z
	call Item_Lazer ;if A, call.
	xor a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	ret
	
Item_Jetpac: ;6277
	ld a, [wBJustPressed]
	or a
	ret z
	xor a
	ld [wBJustPressed], a
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ret z ;useless in tutorial :(
	call CallPlayerJump
	ret
	
Item_Bomb: ;628A
	ld a, [wBJustPressed]
	or a
	ret z
	xor a
	ld [wBJustPressed], a
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ret z
	xor a
	ld [wInventory1], a ;consume item?
	ld a, WEAPON_NONE
	ld [wEquippedWeapon], a
	call GetFreeEntity
	ret c
	ld a, $09 ;bomb
	ld [hl+], a
	push hl
	ldh a, [hXPosLow]
	ld [hl+], a
	ldh a, [hXPosHi]
	ld [hl+], a
	ldh a, [hYPosLow]
	ld [hl+], a
	ldh a, [hYPosHi]
	ld [hl+], a
	ldh a, [hZPosLow]
	cpl
	add a, $01
	ld c, a
	ldh a, [hZPosHi]
	cpl
	adc a, $00
	ld b, a ;BC is Z
	ld a, c
	add a, $1E
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;+= 1E
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a ;save
	xor a
	ld [hl+], a
	ld a, [wViewDir]
	ld [hl+], a
	xor a
	ld [hl+], a ;orientation
	ld a, $67
	ld [hl+], a
	ld a, $2B
	ld [hl+], a
	ld a, $04
	ld [hl+], a ;three bytes, idk
	xor a
	ld [hl+], a ;status byte
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;four words
	ld [hl+], a
	ld [hl+], a ;two bytes
	ld [hl+], a ;map ID 0
	ld a, [wLurchCounter]
	bit 7, a
	jr z, .recoil
	xor a
.recoil
	sub $40
	ld [wLurchCounter], a
	pop hl
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;DE is HL + 000D.. unknown word
	ld a, $F0
	ld [de], a ;write $F0 to it
	call CallPlaceEntityInView
	ld a, [wFlyingFlag]
	or a
	jr z, .notflying
	ld a, $14
	ld [wQueueSFX], a
	ret
.notflying ;6
	ld a, $13
	ld [wQueueSFX], a
	ret
	
;631A

SECTION "3:635B", ROMX[$635B], BANK[3]
Item_ThreeMines: ;635B
	ld a, $18 ;item $18
	jr Item_LayMine
Item_TwoMines: ;635F
	ld a, $19 ;item $19
	jr Item_LayMine
Item_OneMine: ;6363
	xor a ;item $00
	jr Item_LayMine
Item_LayMine: ;6366
	push af
	call GetFreeEntity
	jr c, .nofree
	pop af
	call SetSelectedInventoryItem
	ld a, $12 ;mine
	ld [hl+], a
	call CallPlaceEntityInView
	ret
.nofree ;B
	pop af
	ret
	
Item_WarpNearest: ;6379, teleport to nearest entity?
	ld hl, wNearestEntityPtr
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ret z ;return if no nearby entities
	dec hl
	jr .warp
.beacon ;6385
	ld a, $08 ;crystal tree?
	jr .find
.junction ;6389
	ld a, $0B ;junction
.find ;2
	call FindEntityWithModelA
.warp ;9
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;inc HL? at position now
	ld a, [hl+]
	ldh [hXLoCopy], a
	ld a, [hl+]
	ldh [hXHiCopy], a
	ld a, [hl+]
	ldh [hYLoCopy], a
	ld a, [hl+]
	dec a
	ldh [hYHiCopy], a
	ld a, [hl+]
	ldh [hXLoCopy], a
	ld a, [hl+]
	ldh [hXHiCopy], a
	ld a, $0D ;ambient 3?
	ld [wQueueMusic], a
	xor a ;clear item
	call SetSelectedInventoryItem
	ret
	
Item_MakeCrystal: ;63B3, turns fuel into a crystal?
	ld a, [wHasCargo]
	or a
	ret nz ;if already have one, return??
	ld a, [wFuelAmountHi]
	sub $40
	ret c
	ld [wFuelAmountHi], a
	ld a, CARGO_CRYSTAL
	ld [wHasCargo], a ;uses a quarter of fuel, produces a crystal
	xor a
	call SetSelectedInventoryItem
	ret
	
Item_UnusedXPUTER: ;63CB, XPUTER
	ret
	
Item_Cubify: ;63CC, CUBIFY, turns all tanks into power cubes
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop
	ld a, [hl]
	cp $02 ;tank?
	jr nz, .next
	push hl
	ld a, $01 ;cube!
	ld [hl+], a
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL + 9, this jumps to unknown byte pair
	ld a, $EE
	ld [hl+], a
	ld a, $72
	ld [hl+], a ;load up values
	pop hl
.next
	ld a, l
	add a, ENTITY_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jr nz, .loop
	xor a
	call SetSelectedInventoryItem
	ret
	
Item_Fuel: ;63F9, FUEL
	ld a, [wFuelAmountHi]
	add a, $80 ;half max fuel
	ld [wFuelAmountHi], a
	jr c, Item_XFuel
	xor a
	call SetSelectedInventoryItem
	ld a, $09
	ld [wQueueSFX], a
	ret
Item_XFuel: ;640D
	ld a, $FF
	ld [wFuelAmountLo], a
	ld [wFuelAmountHi], a
	xor a
	call SetSelectedInventoryItem
	ld a, $09
	ld [wQueueSFX], a
	ret
	
Item_HP: ;641F, HP
	ld a, [wMaxHealth] ;max
	ld b, a ;max into b
	srl a ;half max
	ld c, a ;half max into c
	ld a, [wHealth]
	add a, c
	cp b
	jr c, .save ;cap at max
	ld a, b
.save
	ld [wHealth], a
	xor a
	call SetSelectedInventoryItem
	ld a, $08
	ld [wQueueSFX], a
	ret
Item_XHP: ;643B, X HP
	ld a, [wMaxHealth] ;max
	ld [wHealth], a
	xor a
	call SetSelectedInventoryItem
	ld a, $08
	ld [wQueueSFX], a
	ret
	
Item_XPower: ;644B, not consumed??
	ld a, [wPowerBoost]
	inc a
	ld [wPowerBoost], a
	ret
	
Item_Finder: ;6453
	ld a, $01
	ld [$C2B4], a
	ret
	
Item_4Torp: ;6459
	ld a, $0C
	jr FireTorp
Item_3Torp:
	ld a, $0D
	jr FireTorp
Item_2Torp:
	ld a, $0E
	jr FireTorp
Item_1Torp:
	xor a
FireTorp:
	ld c, a
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ret z ;return if no lock
	ld a, [wWeaponEnergy]
	sub $40
	ret c
	ld [wWeaponEnergy], a
	ld a, c
	call SetSelectedInventoryItem
	dec hl
	call CallFireMissile
	ld a, $05
	ld [wQueueNoise], a
	ret
	
Item_Proxy2: ;6487, two of something
	ld a, [wWeaponEnergy]
	sub $80
	ret c
	ld [wWeaponEnergy], a
	ld a, $10
	call SetSelectedInventoryItem
	ld a, $01
	ld [$C2B3], a
	ret
Item_Proxy1: ;649B, one of something
	ld a, [wWeaponEnergy]
	sub $80
	ret c
	ld [wWeaponEnergy], a
	xor a
	call SetSelectedInventoryItem
	ld a, $01
	ld [$C2B3], a
	ret

SetSelectedInventoryItem: ;64AE
	ld c, a ;18, 19, or 0
	push hl
	ld a, [wCurInvSlot]
	add a, LOW(wInventory)
	ld l, a
	ld a, HIGH(wInventory)
	adc a, $00
	ld h, a ;current inventory slot
	ld [hl], c ;set
	pop hl
	ret
	
Item_Meson: ;64BE, MESON
	ld a, [wWeaponEnergy]
	sub $50
	ret c
	ld [wWeaponEnergy], a
	ld a, $0C
	ld [wQueueSFX], a
	call DrawMesonBeam
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ret z
	ld a, $08 ;8 damage! wow
	call CallDamageEntity
	ret
	
DrawMesonBeam: ;64DE
	xor a
	ld [$D058], a ;X
	ld a, $57
	ld [$D059], a ;Y
	ld b, $B2 ;yoff
	ld c, $08 ;xoff
	call DrawMesonSegment
	ld b, $44
	ld c, $08
	call DrawMesonSegment
	ld b, $B7
	ld c, $08
	call DrawMesonSegment
	ld b, $44
	ld c, $08
	call DrawMesonSegment
	ld b, $D5
	ld c, $08
	call DrawMesonSegment
	ld b, $26
	ld c, $08
	call DrawMesonSegment
	ld b, $EE
	ld c, $06
	call DrawMesonSegment
	ld b, $06
	ld c, $03
	call DrawMesonSegment
	ld a, $7F
	ld [$D058], a
	ld a, $57
	ld [$D059], a
	ld b, $B2
	ld c, $F8
	call DrawMesonSegment
	ld b, $44
	ld c, $F8
	call DrawMesonSegment
	ld b, $B7
	ld c, $F8
	call DrawMesonSegment
	ld b, $44
	ld c, $F8
	call DrawMesonSegment
	ld b, $D5
	ld c, $F8
	call DrawMesonSegment
	ld b, $26
	ld c, $F8
	call DrawMesonSegment
	ld b, $EE
	ld c, $FA
	call DrawMesonSegment
	ld b, $06
	ld c, $FD
	call DrawMesonSegment
	ret
DrawMesonSegment: ;6562
	ld hl, $D058
	ld a, [hl]
	ld e, a
	add a, c
	ld [hl+], a
	ld a, [hl]
	ld d, a
	add a, b
	ld [hl+], a
	call CallDrawLine
	ret
	
Item_Pulse: ;6571, PULSE
	ld a, [wWeaponEnergy]
	sub $28
	ret c
	ld [wWeaponEnergy], a
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	jr z, .draw
	ld a, $01
	call CallDamageEntity
	ld a, $0A
	ld [wQueueSFX], a
.draw ;A
	call NextRand
	and $01
	jr z, DrawLazerRight ;65BA
	
	
DrawLazerLeft: ;6595
	ld de, $5800 ;coord
	ld a, [$C2FB]
	sub $24
	ld b, a ;yoff
	ld a, [$C2FC]
	add a, $40
	ld c, a ;xoff
	push bc
	push de
	call CallDrawLine
	pop de
	pop bc
	push bc
	push de
	dec d
	inc b
	call CallDrawLine
	pop de
	pop bc
	inc e
	dec c
	call CallDrawLine
	ret
DrawLazerRight: ;65BA
	ld de, $587F ;coord
	ld a, [$C2FB]
	sub $24
	ld b, a ;yoff
	ld a, [$C2FC]
	sub $40
	ld c, a ;xoff
	push bc
	push de
	call CallDrawLine
	pop de
	pop bc
	push bc
	push de
	dec e
	inc c
	call CallDrawLine
	pop de
	pop bc
	dec d
	inc b
	call CallDrawLine
	ret


Item_Lazer: ;65DF
	ld a, [wWeaponEnergy]
	sub $00 ;change this to reenable lazer energy consumption
	ret c
	ld [wWeaponEnergy], a
	ld a, $0A ;zap
	ld [wQueueSFX], a
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	jr z, .nolock ;if no lock, jump
	dec hl
	ld a, [hl+]
	or a
	ret z ;if locked model is zero, return
	dec a
	add a, $28
	ld e, a
	ld a, $40
	adc a, $00
	ld d, a
	ld a, [de] ;else grab a value from table at 4028 (1 if lazer does damage)
	call CallDamageEntity
.nolock
	call DrawLazerLeft
	call DrawLazerRight
	ret
	
Item_QuadBeam: ;660F, Q BEAM
	ld a, [wWeaponEnergy]
	sub $50
	ret c
	ld [wWeaponEnergy], a
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	jr z, .draw ;if no target, skip
	ld a, $04
	call CallDamageEntity
.draw
	ld a, $0B
	ld [wQueueSFX], a
	call DrawLazerLeft
	call DrawLazerRight
	ld de, $4400 ;now draw the other two
	ld a, [$C2FB]
	sub $10
	ld b, a
	ld a, [$C2FC]
	add a, $40
	ld c, a
	call CallDrawLine
	ld de, $447F
	ld a, [$C2FB]
	sub $10
	ld b, a
	ld a, [$C2FC]
	sub $40
	ld c, a
	call CallDrawLine
	ret
	
Item_PlasmaBalls: ;6657, BALLS
	ld a, [wWeaponEnergy]
	sub $30
	ret c
	ld [wWeaponEnergy], a
	ldh a, [hZPosLow]
	ldh [$FFCF], a
	ldh a, [hZPosHi]
	ldh [$FFD0], a
	ld a, [wViewDir]
	sub $40
	cpl
	inc a
	ld d, a
	ld bc, $1E00
	call CallRotateCoordByAngle
	ld e, b
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	push de
	ldh a, [hYPosLow]
	add a, e
	ld e, a
	ldh a, [hYPosHi]
	adc a, d
	ld d, a
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a
	push bc ;BC is going to be our horizontal offset, used for either emitter
	ldh a, [hXPosLow]
	add a, c
	ld c, a
	ldh a, [hXPosHi]
	adc a, b
	ld b, a
	ld a, $20 ;age
	ld [wParticleAge], a
	ld a, [wViewDir]
	cpl
	inc a
	ld l, $78
	ld h, $00
	call GenerateParticle
	pop bc
	ldh a, [hXPosLow]
	sub a, c
	ld c, a
	ldh a, [hXPosHi]
	sbc a, b
	ld b, a
	pop de
	ldh a, [hYPosLow]
	sub a, e
	ld e, a
	ldh a, [hYPosHi]
	sbc a, d
	ld d, a
	ld a, [wViewDir]
	cpl
	inc a
	ld l, $78 ;speed, make sure we can outrun it!
	ld h, $00
	call GenerateParticle
	ld a, $0D
	ld [wQueueSFX], a
	ret
	
EntityShootDoubleShot: ;66CE
	push hl
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;Z orientation
	ld a, [de]
	ldh [$FFA4], a ;save z or
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	cpl
	add a, $01
	inc de
	ldh [$FFCF], a
	ld a, [de]
	cpl
	adc a, $00
	ldh [$FFD0], a ;save Y pos to CF/D0
	ld a, l
	add a, $00
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;extraneous addition!!
	ld a, [de]
	ldh [$FFDF], a
	inc de
	ld a, [de]
	ldh [$FFE0], a ;save X pos to DF/E0
	ld a, l
	add a, $02
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	ldh [$FFDB], a
	inc de
	ld a, [de]
	ldh [$FFDC], a ;save Z pos to DB/DC
	ldh a, [$FFA4]
	add a, $40 ;add by a quarter
	ld d, a
	ld bc, $1E00 ;vector of $1E
	call CallRotateCoordByAngle
	ld e, b
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	push de
	ldh a, [$FFDB]
	add a, e
	ld e, a
	ldh a, [$FFDC]
	adc a, d
	ld d, a
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a
	push bc
	ldh a, [$FFDF]
	add a, c
	ld c, a
	ldh a, [$FFE0]
	adc a, b
	ld b, a ;move X and Y for particle
	ld a, $20
	ld [wParticleAge], a
	ldh a, [$FFA4]
	cpl
	inc a
	ld l, $51
	ld h, $00
	call GenerateParticle ;shoot!
	pop bc
	ldh a, [$FFDF]
	sub a, c
	ld c, a
	ldh a, [$FFE0]
	sbc a, b
	ld b, a
	pop de
	ldh a, [$FFDB]
	sub a, e
	ld e, a
	ldh a, [$FFDC]
	sbc a, d
	ld d, a
	ldh a, [$FFA4]
	cpl
	inc a
	ld l, $51
	ld h, $00
	call GenerateParticle
	pop hl
	push hl
	push de
	push bc
	ld de, wQueueSFX
	ld a, $19
	call CallEntityPlayShootShound
	pop bc
	pop de
	pop hl
	ret

IF UNUSED == 1
LoadAlphanumerics: ;6778
	ld hl, AlphabetGFX1bpp
	ld de, $8800
	ld bc, $00D0
	call .copy
	ld hl, NumbersGFX1bpp
	ld bc, $0050
	call .copy
	ld hl, BlankTileGFX1bpp
	ld bc, $0008
	call .copy
	ret
	
.copy ;6797
	ld a, [hl+]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .copy
	ret
	
EclipseMainMenuTilemap: ;67A3, another tilemap baybee
	db $14, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $01, $02, $03, $00, $00, $00, $00, $04, $00, $05, $00, $00, $00, $00, $06, $07, $00 
	db $00, $08, $09, $0A, $00, $00, $0B, $0C, $0D, $0E, $0F, $10, $11, $00, $00, $12, $13, $00 
	db $00, $14, $15, $16, $00, $00, $17, $18, $19, $1A, $1B, $1C, $1D, $00, $00, $1E, $1F, $00 
	db $00, $20, $21, $22, $00, $00, $23, $24, $25, $26, $27, $28, $29, $00, $00, $2A, $2B, $00 
	db $00, $2C, $2D, $2E, $00, $00, $2F, $30, $31, $32, $33, $34, $35, $00, $00, $36, $37, $00 
	db $00, $38, $39, $3A, $00, $00, $3B, $3C, $3D, $3E, $3F, $40, $41, $00, $00, $42, $43, $00 
	db $00, $44, $45, $46, $00, $00, $47, $48, $49, $4A, $4B, $4C, $4D, $00, $00, $4E, $4F, $00 
	db $00, $50, $51, $52, $00, $00, $53, $54, $55, $56, $57, $58, $59, $00, $00, $5A, $5B, $00 
	db $00, $5C, $5D, $5E, $00, $00, $5F, $60, $61, $62, $63, $64, $65, $00, $00, $66, $67, $00 
	db $00, $68, $69, $0A, $00, $00, $6A, $6B, $6C, $6D, $6E, $6F, $70, $00, $00, $71, $72, $00 
	db $00, $73, $74, $75, $00, $00, $00, $00, $00, $76, $00, $77, $00, $00, $00, $78, $79, $00 
	db $00, $7A, $7B, $7C, $00, $00, $00, $00, $7D, $7E, $7F, $80, $81, $00, $00, $82, $83, $00 
	db $00, $84, $85, $86, $00, $00, $00, $00, $87, $88, $89, $8A, $8B, $00, $00, $8C, $8D, $00 
	db $00, $8E, $8F, $90, $00, $00, $00, $00, $00, $91, $92, $93, $94, $00, $00, $95, $96, $00 
	db $00, $97, $98, $99, $00, $00, $00, $00, $9A, $9B, $9C, $9D, $9E, $00, $00, $9F, $A0, $00 
	db $00, $A1, $A2, $A3, $00, $00, $00, $00, $A4, $A5, $A6, $A7, $A8, $00, $00, $A9, $AA, $00 
	db $00, $AB, $AC, $AD, $00, $00, $00, $00, $00, $AE, $AF, $00, $00, $00, $00, $B0, $B1, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;690D
	INCBIN "build/gfx/EclipseMenu.rle"
;708D
ENDC

SECTION "3:70BD", ROMX[$70BD], BANK[3]
;70BD
	db "LOCKED", 00
;70C4
	db "SELECT LOCK", 00
	
InitPlayerGear: ;70D0
	ld a, [wCurLevel]
	or a
	jr nz, .skiploads
	xor a
	ld [wCurLevel], a
	ld [wBigStars], a
	ld [wSmallStars], a
	ld a, WEAPON_NONE
	ld [wEquippedWeapon], a
.skiploads
	ld hl, wScore
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld hl, wInventory
	ld a, $1E ;lazer
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;wipe the rest of inventory
	ld [$C0AE], a ;objective progress?
	ld [wFuelAmountLo], a
	ld [wWeaponEnergy], a
	ld a, $08
	ld [wHealth], a
	ld [$CAA0], a
	ld a, $40
	ld [wFuelAmountHi], a
	xor a
	ld [$C283], a
	ld [$C284], a
	ld [$C273], a
	ld a, $44
	ld [wTutPosLo], a
	ld a, $72
	ld [wTutPosHi], a ;is this necessarily tutorial specific?
	xor a
	ld [$C278], a
	ret
;712A

SECTION "3:713C", ROMX[$713C], BANK[3]
IF UNUSED == 1
LoadSegmentNumbers: ;713C
	;copies $140 bytes from 4E5E to wherever DE is pointing to?
	ld hl, InterfaceSegmentNumsGFX
	ld bc, InterfaceSegmentNumsGFX.end - InterfaceSegmentNumsGFX
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret
ENDC

PositionLockCorner: ;714B
	;a is lock ticks, passed DE are offsets or values? Hl is something
	or a ;lock ticks
	jr nz, .nonzero
	ld c, e
	ld b, d ;else load BC with DE
	ret
.nonzero ;3, ticks is nonzero
	cp $04
	jr nc, .four ;jump if at tick four
	push hl
	ld l, a ;tick is L
	ld a, [wPitchAngle]
	sub $34
	add a, b
	ld b, a ;b += pitch
	push hl ;save tick
	ld a, c
	sub a, e ;c - e
	call MultAByLOverFour
	add a, e
	ld c, a ; c + e again
	ld a, b
	sub a, d ;b - d
	pop hl
	call MultAByLOverFour
	add a, d
	ld b, a ;b + d again
	pop hl
	ret
.four ;1B ;tick four
	ld a, [wPitchAngle]
	sub $34
	add a, b
	ld b, a
	ret

DrawLock: ;7178
	ld hl, $C328
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;bytes at C328 loaded into HL
	ld c, l
	ld b, h ;and also BC
	ld a, [wLockTicks]
	ld de, $CEC2
	call PositionLockCorner
	ld de, $0006
	call CallDrawLockLine
	ld de, $0600
	call CallDrawLockLine
	ld hl, $C32A
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld b, h
	ld a, [$C328]
	ld c, a
	ld a, [wLockTicks]
	ld de, $22C2
	call PositionLockCorner
	ld de, $0006
	call CallDrawLockLine
	ld de, $FA00
	call CallDrawLockLine
	ld c, l
	ld b, h
	ld a, [$CAD0]
	ld de, $223E
	call PositionLockCorner
	ld de, $00FA
	call CallDrawLockLine
	ld de, $FA00
	call CallDrawLockLine
	ld a, [$C329]
	ld b, a
	ld a, [$C32A]
	ld c, a
	ld a, [$CAD0]
	ld de, $CE3E
	call PositionLockCorner
	ld de, $00FA
	call CallDrawLockLine
	ld de, $0600
	call CallDrawLockLine
	ret
	
MultAByLOverFour: ;71EA
	sra a
	sra a ;a /= 4
	ld h, a ;save to H
	dec l
	ret z
	add a, h ;*2
	dec l
	ret z
	add a, h ;*3
	dec l
	ret z
	add a, h ;*4
	ret
	
EntityLogicArrow: ;71F9
	ret
;71FA

SECTION "3:720A", ROMX[$720A], BANK[3]
Load1BPPTiles: ;720A
	;HL is source, DE is target address, BC is number of bytes to read
	xor a
	ld a, [hl+]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, Load1BPPTiles
	ret
;7216 - 7222 number bytes?
	
SECTION "3:7223", ROMX[$7223], BANK[3]
TunnelLightGFX1: ;7223 UNUSED
	INCBIN "build/gfx/TunnelStartLight1.1bpp"
TunnelLightGFX2: ;7283 data
	INCBIN "build/gfx/TunnelStartLight2.1bpp"
TunnelLightGFX3: ;72E3 data
	INCBIN "build/gfx/TunnelStartLight3.1bpp"
TunnelLightGFX4: ;7343 data
	INCBIN "build/gfx/TunnelStartLight4.1bpp"
AreaNumbersGFX: ;73A3 data, 4bpp numbers
	INCBIN "build/gfx/AreaNums.2bpp"
	
;75A3-75DF: 3D screen text
	db "COUNTDOWN", 00
;75AD
	db "OBJECT LOCKED", 00
;75BB
	db "LOCK OFF", 00
;75C4
	db "  OUT OF RANGE  ", 00
;75D5
	db "STANDBY OK", 00
	
WriteTimeOverTexts: ;75E0
	call ClearAllScreenText
	ld a, [wCurLevel]
	and %11111100 ;level
	add a, $00
	ld l, a
	ld a, HIGH(TimeOverTextPointers)
	adc a, $00
	ld h, a ;HL is text pointer from top of bank
	push hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $32
	call CallTryWriteScreenText ;write first line
	pop hl
	inc hl
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $32
	call CallTryWriteScreenText ;write second line
	ret

CopyEnglishStringToWRAM: ;7605
	ld a, [hl+]
	or a
	ret z ;zero is end
	cp $0D
	jr nz, .notD
	inc b
	ld c, $00
	jr CopyEnglishStringToWRAM
.notD
	call CopyLetterToWRAM
	inc c
	jr CopyEnglishStringToWRAM

DrawMinimapPips: ;7617
	;c, b, and e set before calling
	ld d, e
	ld hl, $C028 ;eight groups of four bytes
	ld a, [$C2D0]
	bit 7, a
	ld e, d
	jr z, .dontblank1 ;if top bit not set, use [C2D0]
	ld e, $80 ;otherwise, use $80
.dontblank1
	call WriteOAMEntry ;writes B, C, E, and 0 to HL+ (7F, 6F, 35, 00)
	ld a, c
	add a, $08
	ld c, a
	ld a, b
	add a, $08
	ld b, a ;increment B and C by $8 each
	ld a, [$C2D2]
	bit 7, a
	ld e, d
	jr z, .dontblank2
	ld e, $80
.dontblank2
	call WriteOAMEntry ;write again (87, 77, 35, 00)
	ld a, c
	sub $08
	ld c, a ;c -= 8
	ld a, b
	add a, $08
	ld b, a  ;b += 8
	ld a, [$C2D4]
	bit 7, a
	ld e, d
	jr z, .dontblank3
	ld e, $80
.dontblank3
	call WriteOAMEntry ;write again (8F, 6F, 35, 00)
	ld a, c
	add a, $08
	ld c, a
	ld a, b
	add a, $08
	ld b, a ;b and c += 8
	ld a, [$C2D6]
	bit 7, a
	ld e, d
	jr z, .dontblank4
	ld e, $80
.dontblank4
	call WriteOAMEntry ;write again (97, 77, 35, 00)
	ld a, c
	add a, $08
	ld c, a ;c += 8
	ld a, b
	sub $18
	ld b, a ;b -= 18
	ld a, [$C2D1]
	bit 7, a
	ld e, d
	jr z, .dontblank5
	ld e, $80
.dontblank5
	call WriteOAMEntry ;write again (7F, 7F, 35, 00)
	ld a, c
	add a, $08
	ld c, a
	ld a, b
	add a, $08
	ld b, a ;b and c += 8
	ld a, [$C2D3]
	bit 7, a
	ld e, d
	jr z, .dontblank6
	ld e, $80
.dontblank6
	call WriteOAMEntry ;write again (87, 87, 35, 00)
	ld a, c
	sub $08
	ld c, a ;c -= 8
	ld a, b
	add a, $08
	ld b, a ;b += 8
	ld a, [$C2D5]
	bit 7, a
	ld e, d
	jr z, .dontblank7
	ld e, $80
.dontblank7
	call WriteOAMEntry ;write again (8F, 7F, 35, 00)
	ld a, c
	add a, $08
	ld c, a
	ld a, b
	add a, $08
	ld b, a ;b and c += 8
	ld a, [$C2D7]
	bit 7, a
	ld e, d
	jr z, .dontblank8
	ld e, $80
.dontblank8
	call WriteOAMEntry ;write again (97, 87, 35, 00)
	ret

LoadGameplayGUIgfx: ;76BC
	ld hl, InterfaceMainGFX
	ld de, $8810
	ld bc, $0140
.gfxcopyloop1
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .gfxcopyloop1
	ld hl, InterfaceGFX
	ld de, $8000
	ld bc, InterfaceUnusedGFX-InterfaceGFX
.gfxcopyloop2
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .gfxcopyloop2
	ld de, AlphabetGFX1bpp
	ld hl, $84A0
	ld b, $F0
.gfxcopyloop3
	xor a
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .gfxcopyloop3
	ld de, NumbersGFX1bpp
	ld b, $58
.gfxcopyloop4
	ld a, [de]
	ld [hl+], a
	ld [hl+], a
	inc de
	dec b
	jr nz, .gfxcopyloop4
	ld hl, $7723
	ld de, $87B0
	ld b, $40
.gfxcopyloop5
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .gfxcopyloop5
	ret
	
LoadMainGUIGFX: ;770A
	ld hl, InterfaceMainGFX
	ld de, $8810
	ld bc, $0140
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jp nz, .statloop
	ret
	
TutorialPointerGFX: ;7723
INCBIN "build/gfx/TutorialPointer.2bpp"
;7763