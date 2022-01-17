;todo: loadbank macro, rSTAT loop macros

INCLUDE "src/hardware_constants.asm"
INCLUDE "src/charmap.asm"
SETCHARMAP main
INCLUDE "src/macros.asm"

SECTION "Top Constants", ROM0[$0]
BitPatterns:
	db %10000000, %01000000, %00100000, %00010000, %00001000, %00000100, %00000010, %00000001
	db %11111111, %01111111, %00111111, %00011111, %00001111, %00000111, %00000011, %00000001, %00000000
	db %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110
	db $0A
	db $00

SECTION "V-Blank Interrupt", ROM0[$0040]
	jp VBlankHandler
SECTION "LCD Stat Interrupt", ROM0[$0048]
	jp LYCInterruptFunc
	ret
SECTION "Timer Interrupt", ROM0[$0050]
	reti
SECTION "Serial Interrupt", ROM0[$0058]
	jp SerialInterruptFunc
SECTION "Joypad Interrupt", ROM0[$0060]
	ei
	ret
SECTION "Header Entry", ROM0[$0100]
	nop
	jp Init
	
SECTION "Entry Point", ROM0[$0150]
Init:
	ld a, 1
	ldh [hLoadedBank], a
	ld [$2100], a ;ensure bank 1 is loaded
	di
	ld sp, wStackTop
	call CopyDMARoutine
	call CallInitSound
	call CallResetSound
	ld a, TRACK_PRESENTS
	ld [wQueueMusic], a
	ld a, BANK(presentsGFX)
	ldh [hLoadedBank], a ;hram
	ld [$2106], a ;load bank 7
	ld hl, presentsGFX ;source tiles address, 1EA6D ("presents...")
	ld de, $8400 ;400 bytes into tile ram ($40 tiles in)
	ld bc, $0180 ;the number of byte pairs (tile lines) to copy ($30)
.waitvblank
	ld a, [rSTAT] ;load LCD status register into a
	and rSTAT_MODE_NOT_BLANKING ;mask for the blanking bit
	jr nz, .waitvblank
	ld a, [hl+]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .waitvblank 
	;once all have been copied, we fall out to here
	;set our initialization flags?
	ld a, 1<<VBLANK
	ld [rIE], a ;enable vblank interrupt 
	xor a
	ld [rSCY], a ;scroll x set to 0 
	ld [rSCX], a ;scroll y set to 0
	ld [wTargetSCY], a
	ldh [hGameState], a
	ld [rLYC], a ;reset ly compare register 
	ldh [$FF9C], a ;this is in hram 
	ld [wCurrentInput], a ;this is in wram 
	ld [rIF], a ;reset interrupt flags 
	ldh [$FF91], a ;hram 
	ei
	
	ld hl, $9944 ;vram background map 1 + $144
	ld e, $40 ;the tile to write
	ld c, $0C ;outer counter
.loop
	ld b, $04 ;inner counter
.waitforvblank
	ld a, [rSTAT] ;load lcd status into a 
	and rSTAT_MODE_NOT_BLANKING ;mask for blanking bit
	jr nz, .waitforvblank
	ld [hl], e ;write tile ID into vram bg
	inc e ;increment the tile
	ld a, l
	add a, $20 
	ld l, a ; add $20 to address
	ld a, h
	adc a, $00 ;handle carry from l
	ld h, a 
	dec b ; decrement the counter
	jr nz, .waitforvblank 
	;done with inner loop
	call WaitTwoVBlanks ;wait four frames?
	ld a, l
	sub $7F ;go back $7f tile bytes
	ld l, a
	ld a, h
	sbc a, $00 
	ld h, a
	dec c
	jr nz, .loop
	;done with outer loop (finished drawing "presents...")
	ld d, $7D 
	call WaitFrames 
	call ScatterBiosScreen
Reset: ;1d5
	di 
	xor a 
	ld [rBGP], a ;pal 0 
	ld [rOBP0], a ;pal 1 
	ld [rOBP1], a ;pal 2 
	ld [wCurrentInput], a ;wram 
	ld a, $FF 
	ld [wChangedInputs], a ;wram 
	ld sp, wStackTop
	;time to clear all of wram?
	ld hl, WRAM0_Begin 
	ld bc, WRAM1_End - WRAM0_Begin
	xor a 
.clearloop
	ld [hl+], a ;set wram value to 0 
	dec c
	jr nz, .clearloop ;inner loop
	dec b 
	jr nz, .clearloop ;outer loop
	ld a, $01 
	ldh [hLoadedBank], a ;hram
	ld [$2100], a ;bank 1 
	call CallResetSound 
	ld a, TRACK_TITLE 
	ld [wQueueMusic], a ;wram
	xor a
	ld [rIF], a ;reset interrupt flags 
	ld a, (1 << VBLANK) 
	ld [rIE], a ;enable vblank interrupt 
	ei
	ld a, $D0 
	ldh [$FF9B], a ;hram 
	call CallTitleScreen ;handles the title screen logic
	xor a
	ld [wTunnelDemoMode], a ;wram 
	ld [rIF], a ;reset interrupt flags 
	ld a, (1 << VBLANK) 
	ld [rIE], a ;enable vblank interrupt 
	call ScatterTitleScreen
	xor a 
	ld [wMapTankCellPos], a ;wram 
	ld [wScrollYFlag], a ;wram 
	ld [rSTAT], a ;hram 
	ld [rLYC], a ;hram 
	ld [wDidTetamusTunnel], a ;wram 
	xor a
	ld [rIF], a ;reset interrupt flags 
	ld a, [$CAA5] ;wram 
	or a ;what is this check for?
	ld a, (1 << VBLANK) 
	ld [rIE], a ; enable vblank interrupt 
	ld a, $01 
	ld [$CAA3], a ;wram 
	xor a 
	ld [wScrollYFlag], a ;wram 
	ei
	call CallInitPlayerGear
	ld a, [wCurLevel] ;wram, checked for continue
	or a
	jp z, .resetgameplay ;this jumps to the text screen
	ld a, BANK(ContinueFromTitle)
	ldh [hLoadedBank], a ;hram 
	ld [$210E], a ;load bank F 
	jp ContinueFromTitle
IF UNUSED == 1
;258	
	call ClearAllVRAM
	call LoadUnusedTextTiledata
	call WipeWholeScreenTiles
	loadpalette 3, 3, 3, 0
	ld [rBGP], a ;vram pal 0 
	ld a, $A1 
	call CallFlashScreen
	call UnusedFunc1514
	call ScatterTitleScreen
ENDC
.resetgameplay ;270
	ld a, $02 
	ld [$D058], a ;the value saved by the above unused func gets overwritten here
	ld a, $03 
	ld [$CB14], a ;wram 
	ld a, $34 
	ld [wPitchLurch], a ;wram
	xor a 
	ld [wTimerFramesLo], a  
	ld [wTimerFramesHi], a  
	xor a 
	ld [wMissileCount], a 
	jr .recapandstartlevel
.incrementlevel ;increments C0AF by 4 (one level)
	ld a, [wCurLevel]
	add a, $04 
	ld [wCurLevel], a 
.gameovercontinue
	call CallDisableLCD
	ld a, $02 
	ld [$D058], a ;loop overwrites this to 2
	xor a 
	ldh [hGameState], a 
.recapandstartlevel
	xor a
	ld [$C2AB], a 
	call ClearAllVRAM
	call LoadUnusedTextTiledata
	call WipeWholeScreenTiles
	call CallSetLevelPointers
	call CallRecapText ;handles all pages needed
	ld a, [wCurLevel] ;save flag 
	or a 
	jr nz, .startgame 
	ld a, [wTutComplete]
	or a
	jr z, .selecttraining 
	call CallPlanetSelect
	ld a, [wSelectedPlanet]
	or a 
	jp z, .startgame 
.selecttraining
	ld a, $01 
	ld [wSelectedPlanet], a ;wram 
	ld a, LEVEL_TUTORIAL
	ld [wCurLevel], a  
	call CallSetLevelPointers
.startgame
	call CallDisableLCD 
.nextlevel
	ld a, $00 
	or a 
	jr nz, .briefandpreplevel ;this will never happen?
	ld a, [wDidTetamusTunnel] ;wram 
	or a 
	jr nz, .briefandpreplevel 
	call PrepareTunnelForLevel ;this handles the first-time tunnel to Tetamus II
	jr c, .briefaftertunnel ;c flag set if C0AF not zero or $24
	ld a, TRACK_DEATH ;game over track
	ld [wQueueMusic], a ;wram 
	call CallHandleGameOver
	jp c, .gameovercontinue
	jp Reset
	
.briefaftertunnel
	call CallLoadMainGUIGFX
	ld a, $01 
	ld [wQueueWave], a ;wram 
	call CallCopyWRAMToVRAM
	call CallCopyWRAMToVRAM
.briefandpreplevel	
	call CallBriefing
	call CallDisableLCD 
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
	ld [wTargetSCY], a
	ld a, spdSTOP
	ldh [hSpeedTier], a ;stop!
	call CallSetupLevel
	call CallLoadFullGUI
	call UpdateInputs
	ld a, TRACK_LEVEL_INTRO ;play level intro
	ld [wQueueMusic], a
	xor a
	ldh [hPauseFlag], a
	ld a, $78
	ld [wLurchTarget], a
	ld [wLurchCounter], a
	ld a, BANK(InLevelLoop) ;bank F
	ldh [hLoadedBank], a
	ld [$210E], a
	jp InLevelLoop
	
HandleLowHealthAndLauncherText: ;339
	call CallAddNewMonoTextLine
	call CallDrawTimer
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .launchers ;skip if tutorial
	ld a, [wHealth]
	ld c, a
	call NextRand
	and $1F
	sub $1E
	jr c, .checkText ;1/16 chance?
	sub a, c ;1 health is a 1/32 chance
	jr c, .checkText
	ld a, [wScreenShakeCounter]
	add a, $02
	ld [wScreenShakeCounter], a
.checkText ;B, 8
	ld a, [wHealth]
	cp $02
	jr nc, .launchers
	ld hl, HighDamageText
	ld c, $01
	call CallTryWriteScreenText
.launchers ;27, 8
	ld a, [$CA8C]
	and $1F
	sub $01
	jr c, .ret
	ld [$CA8C], a ;decrement
	ld hl, LauncherSpottedText
	ld c, $32
	call CallTryWriteScreenText
	ld a, [wFrameCounterLo]
	and $3F
	cp $20
	jr c, .ret
	cp $32
	ld a, $05
	jr nc, .ret
	ld a, $04
.ret ;1C, 8, 2
	ret

HandleLevelInputs: ;393
	call CallUpdateTimer
	ld a, [wHideEntities]
	or a
	ret nz ;don't update inputs if we're still loading the ents
	ldh a, [hPauseFlag]
	or a
	jr z, .handleinventory
	;else pause flag was set. check if we can pause?
	ld a, [wLevelClearCountdown] ;can't pause once level's clear
	or a
	jp nz, .unpause
	ld a, [wGameOverTimer]
	or a
	jp nz, .unpause ;can't pause in game over
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .dopause
	ld a, [wLevelStartTimer] ;level start time?
	or a
	jr nz, .unpause ;can't pause when level just started?? not checked in tutorial though
.dopause
	call CallHandlePaused
.unpause
	xor a
	ldh [hPauseFlag], a
.handleinventory
	ld a, [wCurrentInput]
	bit INPUT_SELECT, a
	call nz, CallSetLevelTitle
	call CallCheckInventoryForItemTypeThree
	xor a
	ld [$CB52], a ;?
	ld a, [wCurInvSlot]
	add a, LOW(wInventory)
	ld e, a
	ld a, HIGH(wInventory)
	adc a, $00
	ld d, a
	ld a, [de]
	dec a
	ld [wEquippedItem], a ;current inventory selection assigned to A button
	add a, LOW(ItemTypes)
	ld l, a
	ld a, HIGH(ItemTypes)
	adc a, $00
	ld h, a ;HL is $5DE3 + our A item ID
	ldh a, [hLoadedBank]
	push af
	ld a, $03
	ldh [hLoadedBank], a
	ld [$2102], a
	ld a, [hl]
	ldh [hItemType], a ;retrieve value from bank 3 into FFAE. will be either 0, 3, or 5?
	pop af
	call LoadBankInA
	ldh a, [hItemType]
	and $03
	cp $02
	jr z, .useitem ;if value is 2 or 6, jump. Unused type?
	cp $03
	jr z, .finishedcheck ;if value is 3 or 7, jump.
	xor a
	ld [wUseItem], a ;else, reset this
	ldh a, [hItemType] ;look at the value again
	and $03
	cp $01
	jr nz, .checkHandledB ;if not 1 or 5, jump
	ld a, [wCurInvSlot] ;else, value was 1 or 5
	or a
	jr z, .checkA
	ld a, [wCurrentInput] ;slot is nonzero and val was five, check B
	bit INPUT_B, a
	jr nz, .buttonpressed
	jr .checkHandledB
.checkA ;9, slot is zero and val was five, check A
	ld a, [wCurrentInput]
	bit INPUT_A, a
	jr nz, .buttonpressed
.checkHandledB ;16, 07: val was zero, or was five and button wasn't pressed
	ld a, [wCurInvSlot]
	or a
	jr z, .checkHandledA
	ld a, [wBJustPressed] ;slot is nonzero, doublecheck B
	or a
	jp z, .finishedcheck
	jr .buttonpressed
.checkHandledA ;9, slot is zero, doublecheck A
	ld a, [wAJustPressed]
	or a
	jp z, .finishedcheck
.buttonpressed ;button was pressed
	ld a, $01
	ld [wUseItem], a ;unused use flag??
.useitem ;41, button pressed for 5 or 0, or value was 2 (it is never 2?)
	call CallUseItem
.finishedcheck ;445, value was 3, button wasn't pressed, OR fallthrough from button press. (aka all cases merge here)
	call CallHandleFlightHeight ;do this here because of jetpac
	ld a, [wWeaponEnergy]
	add a, $07
	jr nc, .charge
	ld a, $FF
.charge ;2
	ld [wWeaponEnergy], a ;+=7, caps at FF
	call CallUpdateGoalCompassAndAltimeter
	ld a, [wKnockbackCounter]
	or a
	ld a, $CE
	jr nz, .doRecoil ;if knockback, jump
	ld a, [wLurchCounter]
	or a
	jr z, .recoilDone ;if no knockback or lurch, skip to the end 
.doRecoil ;knockback or lurch
	ld c, a
	ld b, $00
	ldh a, [hViewAngle]
	ld d, a
	call CallRotateCoordByAngle
	ld hl, hYLoCopy
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is our Y position
	ld e, c
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	add hl, de ;add offset
	ld a, h
	ldh [hYHiCopy], a
	ld a, l
	ldh [hYLoCopy], a ;save new Y
	ld hl, hXLoCopy
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is our X position
	ld e, b
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	add hl, de ;add offset
	ld a, h
	ldh [hXHiCopy], a
	ld a, l
	ldh [hXLoCopy], a ;save new X
.recoilDone
	call CallUpdatePitchTilt
	ret

UpdateInputs: ;0x49E
	ld a, $20 ;checking for direction
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	cpl ;make 1 = pressed
	and $0F ;mask
	swap a ;directions now top nybble
	ld b, a ;store in b for now
	ld a, $10 ;checking for buttons
	ldh [rJOYP], a
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP]
	ldh a, [rJOYP] ;debounce lol
	cpl
	and $0F
	or b
	ld c, a ;current button state in c
	ld a, [wCurrentInput]
	xor c
	ld [wChangedInputs], a ;new presses are here
	ld a, c
	and $FF
	ld [wCurrentInput], a ;current press state is here
	ld a, $30
	ldh [rJOYP], a ;stop requesting joypad updates
	ret
	
ClearAllVRAM: ;0x4D7
	call CallDisableLCD
	call ClearWRAM
	ld bc, $0300
	inc c
	inc b
	ld hl, VRAM_Begin
	xor a
.loop1
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec c
	jr nz, .loop1
	dec b
	jr nz, .loop1
	ld hl, $9800
	ld b, $80
	xor a
.loop2
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .loop2
	ret

WaitForVBlank: ;506
	;this needs interrupts documented first
	ld a, [rLCDC] 
	bit rLCDC_ENABLE, a 
	ret z ;if lcd is disabled, return
	xor a
	ld [wVBlankHandled], a ;write zero to C29C
.waitloop
	halt ;any interrupts can resume this
	ld a, [wVBlankHandled] 
	or a
	jp z, .waitloop ;if LCD enabled, wait for vblank handled
	ret
	
VBlankHandler: ;0x518
	push af
	call hDMARoutine
	ei
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, [wCurrentInput]
	cpl
	and (1<<INPUT_A) | (1<<INPUT_B) | (1<<INPUT_SELECT) ;if all face buttons pressed
	jp z, Reset ;then reset
	push bc
	push de
	push hl
	ld a, [wScrollYFlag] ;wram, above frame counter
	cp $03
	ld a, [wTargetSCY]
	jr nz, .checkscy ;if CA9D not equal to 3, skip
	ldh [rSCY], a ;if CA9D is equal to 3, assign C2ED to SCY
	ld a, [$D15D]
	ld [$D15D], a
	ld [$D15C], a
	jr .checkstate
.checkscy 
	ld c, a
	ldh a, [rSCY]
	cp c ;compare C2ED with SCY
	jr z, .checkstate ;here to skip2 moves SCY towards C2ED
	jr c, .neg
	dec a
	jr .storescroll
.neg
	inc a
.storescroll
	ldh [rSCY], a
.checkstate
	ld a, $01
	ld [wVBlankHandled], a
	ldh a, [$FFFD]
	inc a
	ldh [$FFFD], a ;increment this
	ldh a, [hGameState]
	or a
	jr z, .checkifupdateframe
	ldh a, [rLCDC] ;if gamestate is nonzero, do this:
	res rLCDC_TILE_DATA, a
	ldh [rLCDC], a ;reset BG+Window tile data to 8800-97FF
	ldh a, [hBGP]
	ldh [rBGP], a ;load our stored BG palette
	
	
	;call cgbSetup ;testing
	;nop
	;nop
	;nop
	
.checkifupdateframe ;for all game states:
	ld hl, wFrameCounter
	ld a, [hl]
	add a, $01
	ld [hl+], a ;incremented every frame?
	ld a, [hl]
	adc a, $00
	ld [hl-], a
	bit 0, [hl]
	jp nz, .end ;only do the rest of these checks every other frame???
	ldh a, [hGameState]
	inc a
	jp z, .end ;if $FF or 0, skip the rest
	dec a
	jp z, .end
	ldh a, [$FFA6] ;viewing angle related
	push af
	ldh a, [$FFA0]
	push af ;push these two, they get restored later
	ld a, $08
	ldh [rSCX], a
	ld a, [wScreenShakeCounter]
	or a
	jr z, .doneshaking ;if C2BA is nonzero, do the following:
	ld c, a
	ld a, [wFrameCounterLo]
	and c
	and $08 ;check if bit 4 of both C2BA (???) and CA96 (framecounter) are set
	add a, $04
	ldh [rSCX], a
	ld a, c
	sub $03
	jr nc, .saveshake
	xor a
.saveshake
	ld [wScreenShakeCounter], a ;C2BA -= 3 until it hits 0
.doneshaking
	ldh a, [hGameState]
	cp $02 ;tunnel
	call nz, CallDrawFuel ;if not tunnel, set these
	call UpdateInputs
	ld a, [wCurrentInput]
	cpl
	and INPUT_RESET
	jp z, Reset
	ld a, [wCurrentInput]
	bit 3, a ;start down?
	jr z, .checkSelect
	ld a, [wChangedInputs]
	bit 3, a ;start pressed?
	jr z, .checkSelect
	ld a, $01
	ldh [hPauseFlag], a ;if so, pause the game
.checkSelect
	ld a, [wCurrentInput]
	cpl
	and INPUT_RESET
	jp z, Reset
	ld a, [wCurrentInput]
	bit 2, a ;select down?
	jr .checkinventoryscroll
	
	ld a, [wChangedInputs]
	bit 2, a ;select pressed?
	jr z, .checkinventoryscroll
	ld a, $01
	ld [wNextInvSlotFlag], a ;if so, load 1 into C342
.checkinventoryscroll
	ld a, [wNextInvSlotFlag]
	or a
	jr z, .handleinputs ;to 638 if flag wasn't set (always the case?)
	;here to l638 unused? inventory selection?
	ld a, $01
	ld [wLockCancel], a ;otherwise set CAD1 to 1
	ld a, [wCurInvSlot]
	add a, $E1
	ld l, a
	ld a, $CA
	adc a, $00
	ld h, a
	ld a, [wCurInvSlot] ;CAE1 holds six bytes, C341 is an offset, and it's incremented each check
	inc a
	cp $06
	jr c, .savescroll
	xor a
.savescroll
	ld [wCurInvSlot], a ;if less than five, increment. otherwise reset
	add a, LOW(wInventory)
	ld e, a
	ld a, HIGH(wInventory)
	adc a, $00
	ld d, a ;current value's in HL, next one's in DE
	xor a
	ld [$CB47], a
	ld [$CB1A], a
	ld [$CB46], a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	ld [wAimPitch], a ;clear out these three words: $CB46/47, $C2F9/FA, $CB1A and $C31B 
	ld a, [de]
	or a
	jr z, .handleinputs
	cp [hl]
	jr z, .handleinputs
	xor a
	ld [wNextInvSlotFlag], a ;if next value is empty, or equal to current value, increment again
.handleinputs ;638
	ld a, [wInventory1] ;second value in the list, this is equipped item?
	call CallPrintInterfaceString
	call CallSetCompassTiles
	ldh a, [hGameState]
	sub $02
	jr z, .tunnelinput ;if state 2 (tunnel?), do the call
	dec a
	jr z, .skipcall ;if state 3, skip past it
	call HandleMovementInputs ;else we do these calls instead
	call CallDrawCrosshair
	ld a, [wFrameCounterLo] ;check frame counter
	and $3F
	jr nz, .emptyjump ;do nothing with it
.emptyjump
	jr .skipcall
.tunnelinput
	call HandleTunnelInputs
.skipcall
	pop af
	ldh [$FFA0], a
	pop af
	ldh [$FFA6], a
.end ;662
	call CallUpdateSound
	pop hl
	pop de
	pop bc
	pop af
	call LoadBankInA
.waitforstat
	ldh a, [rSTAT]
	and rSTAT_MODE_NOT_BLANKING
	jr nz, .waitforstat
	pop af
	reti

LoadBankInA: ;0x674
	or a 
	ret z
	push hl
	push af 
	add a, $FF 
	ld l, a
	ld a, $20 
	adc a, 00 
	ld h, a 
	pop af
	ldh [hLoadedBank], a 
	ld [hl], a
	pop hl
	ret

CopyDMARoutine: ;0x686
	;copies DMAroutine into top of HRAM (FF80)
	ld c, $80 ;hram
	ld b, DMARoutineEnd - DMAroutine ;counter
	ld hl, DMAroutine 
.copy
	ld a, [hl+]
	ldh [c], a 
	inc c 
	dec b 
	jr nz, .copy
	ret
	
DMAroutine: ;0x694
	;needs to be ran from HRAM otherwise stuff breaks
	ld a, HIGH(wOAMStart) ;copy from C000 - C09F in wram to FE00 - FE9F
	ld [rDMA], a ;dma register 
	ld a, $28 
.wait
	dec a 
	jr nz, .wait
	ret
DMARoutineEnd:
	
LoadGuiSpecials: ;0x69E
	ld hl, $9800
	ld bc, $0501
	ld a, $80
.loop
	ld [hl+], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ld hl, $99E0
	ld b, $60
	ld a, $80
.loop2
	ld [hl+], a
	dec b
	jr nz, .loop2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(tilesetMainInterface)
	ldh [hLoadedBank], a
	ld [$2106], a
	ld hl, tilesetMainInterface
	ld bc, $009F
	ld de, $0001
	call LoadTileMap
	pop af
	call LoadBankInA
	call CallLoadGameplayGUIgfx
	call CallSetCompassTiles
Refresh3DWindow: ;6D8
	ld hl, $9823 ;start of 3D window
.customPos
	ld bc, $0B80
	ld a, $D0
.endloop ;refreshes this whole window?
	push bc
	ld b, $10
.loop3
	ld [hl+], a
	add a, $0B
	dec b
	jr nz, .loop3
	ld bc, $0010
	add hl, bc
	pop bc
	inc c
	ld a, c
	add a, $50
	dec b
	jr nz, .endloop
	ret
IF UNUSED == 1
;6F6, grabs values from 4300-4500 tables in bank 1 based on passed B and C
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, b
	add a, c
	ld l, a
	jp nc, .nocarry
	ld h, $43
	ld d, [hl]
	inc h
	ld e, [hl]
	ld h, $44
	ld a, b
	sub a, c
	jr nc, .nexttable
	cpl
	inc a
.nexttable
	ld l, a
	ld b, [hl]
	inc h
	ld c, [hl]
	push de
	ld e, l
	ld d, h
	pop hl
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	pop af
	call LoadBankInA
	ret
.nocarry ;726
	ld h, $44
	ld d, [hl]
	inc h
	ld e, [hl]
	ld a, b
	sub a, c
	jr nc, .nexttable2
	cpl
	inc a
.nexttable2
	dec h
	ld l, a
	ld b, [hl]
	inc h
	ld c, [hl]
	push de
	ld e, l
	ld d, h
	pop hl
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	pop af
	call LoadBankInA
	ret
ENDC

WackyMultUnsafe: ;745
	;b and c are bytes passed, differences in stuff
	;b length, c trig?
	;returns values into HL
	ld d, $00
	ld a, c ;a is trig
	cp $80
	jp c, .skipnegatec
	cpl
	inc a
	ld c, a ;otherwise invert c, and increment d to 1
	inc d
.skipnegatec ;751
	ld a, b
	cp $80
	jp c, .skipnegateb
	cpl
	inc a
	ld b, a ;otherwise invert b
	ld a, d
	xor $01
	ld d, a ;flip d bit - d signifies if the result should be negative
.skipnegateb ;75E
	ld a, b
	add a, c
	ld l, a ;L = B+C
	jp nc, .nooverflow  ;jump if it didn't overflow (it should always overflow, right???)
	;missing a push de here
	ld h, $43 ;ready up a linear table
	ld d, [hl] ;read a value into d from $43XX
	inc h
	ld e, [hl] ;read a value into e from $44XX
	ld a, b
	sub a, c ;store the difference between b and c into a
	jr nc, .noinverta
	cpl
	inc a
.noinverta
	ld h, $44 ;get ready to read another table
	ld l, a ;using our difference as the entry
	ld b, [hl] ;44XX
	inc h
	ld c, [hl] ;45XX read two bytes into BC
	push de
	ld e, l
	ld d, h
	pop hl ;swap DE and HL (???)
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a ;HL -= BE
	pop de ;??? restore D sign?
	ld a, d
	or a
	jp z, .quit ;if D signifies positive, leave now
	push de ;else,
	ld e, l
	ld d, h
	pop hl ;swap hl and de again
	ld hl, $0000
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a ;and negate HL
.quit ;792
	ret
	
.nooverflow ;793
	push de ;this is missing above lmao (store the negate flag)
	ld h, $44 ;reading the table at $44XX...
	ld d, [hl]
	inc h
	ld e, [hl] ;and the table at $45XX into DE
	ld a, b
	sub a, c ;find the difference
	jr nc, .noinverta_2
	cpl
	inc a ;negate if necessary
.noinverta_2
	dec h
	ld l, a
	ld b, [hl] ;use a as offset into table at $44XX
	inc h
	ld c, [hl] ;and as offset into table at $45XX
	push de
	ld e, l
	ld d, h
	pop hl ;swap HL and DE?
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	pop de ;our invert flag from the start
	ld a, d ;negate?
	or a
	jp z, .quit_2
	push de ;negate.
	ld e, l
	ld d, h
	pop hl
	ld hl, $0000
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a ;this is all basically above but with some changed order
.quit_2
	ret
	
ProjectPoint: ;7C2
	;X:Z saved to BC
	;Y:Z saved to HL
	ld a, e 
	add a, $AA
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;add $00AA to Z
;7CA
	ld a, h
	add a, $80
	ld h, a ;add $8000 to Y
	ld a, b
	add a, $80
	ld b, a ;add $8000 to X
	call CameraCoordsToScreenCoords ;loads HL based on operations. X:Z in H, Y:Z in L
	ld c, h
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extend h (X:Z result) into bc
	ld a, l
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;sign-extend l (Y:Z result) into hl
	call CallRollCoordsByTilt ;adds or subtracts a shifted BC to HL
	ret
	
PrepScaleXYByDistance: ;7EA
	ld a, e
	add a, $AA ;adds %10101010 to DE (distance to next segment)
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, d
	cp $3F ;???
	jp ScaleXYByDistance
	
;7F8 ?
	jp $07CA
	
CameraCoordsToScreenCoords: ;7FB
	;does an operation between passed Y and Z as well as X and Z. returns signed results in HL.
	push de
	push bc ;store input Z and X these for later
	ld c, l
	ld b, h
	ld l, c
	ld h, b ;???????
	ld bc, $0000
	bit 7, h
	jp nz, .topskip ;if the top bit of Y is set, jump ahead
	xor a
	sub a, l
	ld l, a
	ld a, $00 ;this coulda been xor a
	sbc a, h
	ld h, a ;else negate HL, and increment b
	inc b
.topskip ;811
	res 7, h ;clear top HL bit. Y is now abs(Y), with b set if it was negative.
	xor a
	sub a, e
	ld e, a
	ld a, $00
	sbc a, d
	ld d, a ;negate DE (Z)
	;this chunk below is repeated a bit
	sra d
	rr e ;and divide it by two
	add hl, de ;then add it to HL 
	jr c, .skiptobits1 ;but just to check if it overflows
	ld a, l ;if it didn't, reset HL
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a ;this is to clear carry
.skiptobits1
	rl c ;this shifts the bit over each time we do this?
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits2 ;does it overflow?
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits2
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits3 ;does it overflow?
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits3
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits4 ;does it overflow
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits4
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits5 ;does it overflow
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits5
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits6
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits6
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits7
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits7
	rl c
	sra d
	rr e ;divide DE by two again
	add hl, de
	jr c, .skiptobits8
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits8
	rl c
	bit 7, c
	jp z, .bit7notset ;if we set it the first time (Y >= Z/2) replace it. top bit will never be set.
	ld c, $7F ;+127
.bit7notset ;8A1
	;so, C is the results of this shifty-subtraction. not division.
	ld a, b 
	and a ;check if Y was negative
	ld a, c
	jp z, .skipcpl ;b is 1 if we didn't skip at start, else 0
	cpl 
	inc a ;if Y was negative, negate our C value (this value's sign matches Y's)
.skipcpl ;8A9
	pop bc ;restore passed X
	pop de ;restore passed Z
	ldh [$FFFE], a ;save our signed result for later
	ld l, c
	ld h, b ;load X into HL now
	ld bc, $0000 ;here we go again
	bit 7, h ;copied
	jp nz, .topskip2
	xor a
	sub a, l
	ld l, a
	ld a, $00
	sbc a, h
	ld h, a ;if top bit of H not set, negate HL
	inc b ;B is the sign of X now
.topskip2 ;8BF
	res 7, h
	xor a
	sub a, e
	ld e, a
	ld a, $00
	sbc a, d
	ld d, a ;negate Z (again)
	;here's where the loop happens again
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits1_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits1_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits2_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits2_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits3_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits3_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits4_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits4_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits5_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits5_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits6_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits6_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits7_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits7_2
	rl c
	sra d
	rr e ;divide Z by two
	add hl, de
	jr c, .skiptobits8_2
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	and a
.skiptobits8_2
	rl c
	bit 7, c
	jp z, .bit7notset_2
	ld c, $7F ;if passed X >= Z/2, set result to $7F
.bit7notset_2 ;94F
	ld a, b
	and a
	ld a, c
	jp z, .skipcpl_2 ;make result's sign match X's
	cpl
	inc a
.skipcpl_2
	ld h, a ;X:Z in H
	ldh a, [$FFFE]
	ld l, a ;Y:Z in L
	ret
	
ScaleXYByDistance: ;95C
	;calls $2445 with the passed DE HL values, then again with passed DE BC values
	;results of the function are saved in HL and BC
	;BC is X, HL is Z, DE is Y?
	ld a, e
	add a, $AA
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;add %10101010 to DE (again?)
	push bc
	push de ;these are passed in
	bit 7, h
	push af
	jr z, .scaleZ
	ld a, l ;if top bit of passed HL is set, negate passed HL (make sure its positive)
	cpl
	add a, $01
	ld l, a
	ld a, h
	cpl
	adc a, $00
	ld h, a ;HL is now abs(HL)
.scaleZ
	ld c, $E7 ;starting at $FFE7?
	ld a, e
	ld [c], a
	inc c
	ld a, d
	ld [c], a
	inc c
	xor a
	ld [c], a ;write e, d, then 0
	inc c
	ld a, l
	ld [c], a
	inc c
	ld a, h
	ld [c], a
	inc c
	xor a
	ld [c], a ;write l, h, then 0
	call CallScaleByDistance ;DE is the scalar, HL is the middle of four-byte value
	ldh a, [$FFE9]
	ld c, a
	ldh a, [$FFEA]
	ld b, a ;store function's results into BC
	pop af
	jr z, .prepX
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a ;if a (passed D after AA add) wasn't zero, negate BC
.prepX
	pop de ;passed DE
	pop hl ;passed BC
	push bc ;save results
	bit 7, h
	push af ;save passed D again
	jr z, .scaleX
	ld a, l
	cpl
	add a, $01
	ld l, a
	ld a, h
	cpl
	adc a, $00
	ld h, a ;negate HL if passed D nonzero
.scaleX
	ld c, $E7
	ld a, e
	ld [c], a ;write E into FFE7
	inc c
	ld a, d
	ld [c], a ;write D into FFE8 (passed BC)
	inc c
	xor a
	ld [c], a ;write 0 into FFE9
	inc c
	ld a, l
	ld [c], a ;write L into FFEA
	inc c
	ld a, h
	ld [c], a ;write H into FFEB (possibly negated HL)
	inc c
	xor a
	ld [c], a ;write 0 into FFEC
	call CallScaleByDistance
	ldh a, [$FFE9]
	ld c, a
	ldh a, [$FFEA]
	ld b, a ;load BC with func results
	pop af
	jr z, .done
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a ;negate BC if Dvar is nonzero (again)
.done
	pop hl ;hl has our first call's results, bc has our second
	ret
	

SubtractWords: ;9DB
	ld a, h
	cp $80 ;check sign
	push af ;save original
	jp c, .positive ;if positive, skip
	xor a
	sub a, l
	ld l, a
	ld a, $00
	sbc a, h
	ld h, a ;else negate HL
.positive ;9E9
	ld a, $10
	ld bc, $0000
	scf
	ccf ;clear carry flag
	jp .loop
	
.loop ;9F3
	ld [$C33B], a
	rl l
	rl h
	rl c
	rl b
	ld a, c
	sub a, e
	ld [$C33C], a
	ld a, b
	sbc a, d
	jp c, .carry
	ld b, a
	ld a, [$C33C]
	ld c, a
	ccf
	ld a, [$C33B]
	dec a
	jp nz, .loop
	rl l
	rl h
	ld c, l
	ld b, h
	pop af
	ret c
	xor a
	sub a, c
	ld c, a
	ld a, $00
	sbc a, b
	ld b, a
	ret
	
.carry ;A25
	ld a, [$C33B]
	dec a
	ccf
	jp nz, .loop
	rl l
	rl h
	ld c, l
	ld b, h
	pop af
	ret c
	xor a
	sub a, c
	ld c, a
	ld a, $00
	sbc a, b
	ld b, a
	ret
	
IF UNUSED == 1
DrawHexByte: ;A3D
	;draws a byte to the mono screen at height B, tile column C
	push hl
	swap a
	call DrawHexDigit
	inc c
	swap a
	call DrawHexDigit
	inc c
	pop hl
	ret
	
DrawHexDigit: ;A4C
	;draws the low nybble of A at height B, mono tile column C
	push af
	push bc
	and $0F
	add a, a
	add a, a
	add a, a
	add a, a ;16 bytes each?
	add a, LOW(HexValuesGFX)
	ld e, a
	ld a, HIGH(HexValuesGFX)
	adc a, $00
	ld d, a ;DE is 5A6E + our passed lower nybble * 16
	ld l, b
	ld a, HIGH(wMonoBufferColumn1)
	add a, c
	ld h, a ;$D000 (mono) plus bassed B, kinda
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HexValuesGFX)
	ldh [hLoadedBank], a
	ld [$2102], a
	ld b, $08
.loop ;A6D
	ld a, [de]
	ld [hl+], a
	inc de
	inc de
	dec b
	jp nz, .loop
	pop af
	call LoadBankInA
	pop bc
	pop af
	ret
	
StrobeLock: ;A7C
	dec c
	jp nz, StrobeLock
	dec b
	jp nz, StrobeLock
	ldh a, [rBGP]
	cpl
	ldh [rBGP], a
	jp StrobeLock
ENDC

LoadModelSides: ;0xA8C
	inc hl ;go forward two bytes, then load that pointer into hl, load its value into a
	inc hl ;we're now at the second pointer in the header
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;follow the pointer
	ld de, wNumEdges ;load this point in wram into de
	ld a, [hl+]
	ld [de], a ;load the first value into wram
	inc de ;increment wram pointer
	rlca ;multiply by two??
	ld b, a ;value*2 is our counter
.loop
	push bc
	ld a, [hl+] ;next value is an offset into vertex data
	push hl ;save our spot in this blob
	ld c, a
	ld b, $00
	ld hl, $C900
	add hl, bc
	ld a, [hl+] ;load four(?) values from vertex data into $C4XX
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	pop hl
	pop bc
	dec b
	jr nz, .loop
	ret
	
FuncAB5DecideBCReadAndFlip: ;AB5
	;reading the value after a 7F
	ld d, a
	ldh a, [$FFA1]
	ld e, a ;shove into DE with FFA1 as low bit?
	and $3E ;mask high bit
	ld c, a
	ld b, $00 ;shove into BC
	add hl, bc ;add FFA1's masked result to position
	ld a, e ;check original FFA1
	cp $E0
	cp $C0
	jr nc, .af6 ;if >= $C0, jump to AF6
	cp $A0
	cp $80
	jr nc, .afd ;if >= 80, jump to AFD
	cp $60
	cp $40
	jr nc, .b06 ;if >= $40, jump to B06
	cp $20
	ld a, [hl+]
	ld c, a
	ld b, [hl] ;else load the next bytepair into cb
	ret
;AD8
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	cpl
	inc a ;invert 2nd, cb
	ld b, a
	ret
;ADF
	ld a, [hl+]
	cpl
	inc a
	ld b, a
	ld a, [hl+]
	cpl
	inc a ;invert both, bc
	ld c, a
	ret
;AE8
	ld a, [hl+]
	cpl
	inc a
	ld c, a
	ld a, [hl+] ;invert 1st, cb
	ld b, a
	ret
;AEF ;identical to AE8
	ld a, [hl+]
	cpl
	inc a
	ld c, a
	ld a, [hl+] ;invert 1st, cb
	ld b, a
	ret
.af6 ;AF6
	ld a, [hl+]
	cpl
	inc a
	ld b, a
	ld a, [hl] ;invert 1st, bc
	ld c, a
	ret
.afd ;AFD
	ld a, [hl+]
	cpl
	inc a
	ld c, a
	ld a, [hl]
	cpl
	inc a
	ld b, a ;invert both, cb
	ret
.b06 ;B06
	ld a, [hl+]
	ld b, a
	ld a, [hl]
	cpl
	inc a
	ld c, a ;invert 2nd, bc
	ret
	
interpretA7F: ;B0D
	ld a, [hl+] ;next value is A
	push de
	push hl
	call FuncAB5DecideBCReadAndFlip ;reads next two values into BC, swapped and/or inverted as needed
	pop hl
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, d
	pop de
	push hl
	push de
	ld d, a
	jp LoadVertices.writetoVertBuffer
	
LoadVertices: ;0xB24
	;follow HL's pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL now holds the first pointer in the model header (vertex data?)
	ld de, $C900
.interpretA ;B2A
	ld a, [hl+] ;we just followed the vertex data pointer, first byte now in A
	or a
	ret z ;if value is 0, return (end? start of next?)
	dec a ;if value is 1, next byte is an offset to a redirect
	jr z, .aAnimationList
	dec a
	jr z, .aRedirect ;if value is 2, next word is a redirect
	add a, $02 ;restore the value
	ldh [$FFA2], a ;load it into A2
	ld a, [hl+] ;load next value (number of verts) into B
	ld b, a
	jr .loop ;enter the main loop
.aRedirect
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jr .interpretA ;restart
.aAnimationList
	ld a, [hl+] ;first vertex byte was one, load the number of entries
	dec a
	ld c, a ;load next value - 1 into c
	ld a, [$C2A1]
	and c ;load a with C2A1 & c
	rlca ;rotate left, copy to carry (multiply by two?)
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;jump ahead that many words
	ld a, [hl+] ;follow this pointer to new vertex lists
	ld h, [hl]
	ld l, a
	jr .interpretA ;restart
.loop ;B53
	push bc ;save the number of verts
	ld a, [hl+] ;read next
	cp $7F
	jr z, interpretA7F ;if $7f, jump to $B0D 
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+] ;load vertex XYZ into c, b, a
	push hl ;save our read position
	push de ;save $C900
	ld d, b ; b -> d temp (vert Y)
	ld b, a ; vert Z into b
	ldh a, [$FFA5]
	or a
	jr z, .doneRotX ;if FFA5 is 0, jump
	ldh a, [$FFA2] ;this is our vertex list type
	bit 0, a
	jr nz, .doneRotX ;if lowest bit in list type set, jump
	ld e, c ;C -> E (vert X)
	push de ;save Y and X
	ld c, b ;Z into c
	ld b, d ;Y into b
	ldh a, [$FFA5] ;x angle?
	ld d, a ;FFA5 into a/d
	call RotateCoordByAngle ;rotates passed coord BC by angle A
	pop de ;restore Y and X
	ld d, b ;overwrite Y with Y'
	ld b, c ;load b with Z'
	ld c, e ;load c with saved X
.doneRotX
	ldh a, [$FFA3] ;Z angle?
	or a
	jr z, .doneRotZ ;if angle is zero, skip
	ldh a, [$FFA2]
	bit 2, a
	jr nz, .doneRotZ ;if bit 2 in list type is set, skip
	ld e, b
	push de ;save Y'Z'
	ld b, d ;load b with Y'
	ldh a, [$FFA3]
	ld d, a ;load angle into a/d
	call RotateCoordByAngle ;using Z angle, Y', and X
	pop de ;restore Y'Z'
	ld d, b ;load d with new Y'
	ld b, e ;store Z' in b (BC now holds Z'X')
.doneRotZ
	ldh a, [$FFA2]
	bit 1, a
	jr z, .justFFA1 ;skip this step if 1st bit of vertex type NOT set
	push de ;save Y'Z'
	ldh a, [$FFA4]
	ld d, a
	ldh a, [$FFA1] ;Y angle?
	add a, d
	ld d, a ;load d with Y angle + FFA4
	call RotateCoordsAndSaveInvert ;final Z'X' in BC
	pop de ;restore Y'Z'
	jr .writetoVertBuffer ;to BAD
.justFFA1
	ldh a, [$FFA1]
	push de ;save Y'Z'
	ld d, a ;load d with Y angle
	call RotateCoordsAndSaveInvert ;final Z'X' in BC
	pop de ;restore Y'Z'
.writetoVertBuffer ;BAD
	ld e, b ;Z' into E
	ld l, d ;Y' into L
	ld a, l ;\_ store this in l and a
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;Y' is now a word wide (HL)
	ld a, e 
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;Z' is now a word wide (DE)
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;X' is now a word wide (BC)
	ld a, [wModelScale]
	dec a ;scale X'Y'Z' by the model's scale factor (up to 3X)
	jr z, .donescalingrotate
	sla c
	rl b
	sla e
	rl d
	sla l
	rl h
	dec a
	jr nz, .donescalingrotate
	sla c
	rl b
	sla e
	rl d
	sla l
	rl h
	dec a
	jr nz, .donescalingrotate
	sla c
	rl b
	sla e
	rl d
	sla l
	rl h
	dec a
	jr nz, .donescalingrotate
.donescalingrotate
	ldh a, [$FFDD]
	add a, l
	ld l, a ;add FFDD to L
	ldh a, [$FFDE]
	adc a, h
	ld h, a ;add FFDE to H
	ldh a, [$FFDF]
	add a, c
	ld c, a ;add FFDF to C
	ldh a, [$FFE0]
	adc a, b
	ld b, a ;add FFE0 to B
	ldh a, [$FFDB]
	add a, e
	ld e, a ;add FFDB to E
	ldh a, [$FFDC]
	adc a, d
	ld d, a ;add FFDC to D
	
	ldh a, [$FFA2] ;load our vertex table type again
	bit 3, a ;bit 3 is mirror?
	jr z, .noshifting ;if bit 3 not set, jump to C71
	;else, handle mirror
	push bc ;save these
	push de ;for later
	ld a, [$C31C] ;mirrored c1'
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;extend c1' into BC
	ld a, [$C31E] ;mirrored c2'
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend c2' into DE
	ld a, [wModelScale]
	dec a
	jr z, .donescalingmirror  ;shift BC DE left 0-3 based on scale
	sla c
	rl b
	sla e
	rl d
	dec a
	jr nz, .donescalingmirror
	sla c
	rl b
	sla e
	rl d
	dec a
	jr nz, .donescalingmirror 
	sla c
	rl b
	sla e
	rl d
	dec a
	jr nz, .donescalingmirror
.donescalingmirror ;C57
	ldh a, [$FFDF]
	add a, c
	ld [$C31C], a ;load C31C with FFDF + c, if mirrored?
	ldh a, [$FFE0]
	adc a, b
	ld [$C31D], a ;load C31D with FFE0 + b, if mirrored?
	ldh a, [$FFDB]
	add a, e
	ld [$C31E], a ;load C31E with FFDB + e, if mirrored?
	ldh a, [$FFDC]
	adc a, d
	ld [$C31F], a ;load C31F with FFDC + d, if mirrored?
	pop de
	pop bc ;restore these
.noshifting ;C71
	ld a, [wModelExploding]
	or a
	jr z, .zerovalue ;if zero, jump to CB0
	
	;C33E is nonzero in here, aka model is in pieces
	ld a, l
	ldh [$FFF5], a
	ld a, h
	ldh [$FFF6], a ;write our HL pair (Y') into FFF5/FFF6
	pop hl ;this is $C900
	ld h, HIGH(wExplodedVertBuffer) ;change to $C700
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a ;write X' into $C7XX as a word
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a ;write Z' into $C7XX as a word
	ldh a, [$FFF5]
	ld [hl+], a
	ldh a, [$FFF6]
	ld [hl+], a ;write Y' into $C7XX as a word
	ldh a, [$FFA2] ;check interpret byte again
	bit 3, a
	jr z, .nobitflag ;check bitflag for mirror, jump to CAA if clear
	ld a, [$C31C]
	ld [hl+], a
	ld a, [$C31D]
	ld [hl+], a ;write mirrored X' into $C7XX
	ld a, [$C31E]
	ld [hl+], a
	ld a, [$C31F]
	ld [hl+], a ;write mirrored Z' into $C7XX
	ldh a, [$FFF5]
	ld [hl+], a
	ldh a, [$FFF6] 
	ld [hl+], a ;write Y' into $C7XX again
.nobitflag ;CAA
	ld e, l ;save our position
	ld d, HIGH(wVertBuffer) ;change address back to $C9XX, in DE
	jp .poploop
	
.zerovalue ;CB0
	;model isn't in pieces
	ldh a, [$FFA2] ;vertex table type
	bit 3, a ;mirror bit
	jr nz, .bitflagset ;jump to CE0
	;this is non-mirrored handler
	call ProjectPoint ;BC and HL changed
	pop de ;$C9XX
	ldh a, [hRenderXOffLo]
	add a, c
	ld c, a ;c += FF9E
	ldh a, [hRenderXOffHi]
	adc a, b
	ld b, a ; b += FF9F
	ld a, c
	add a, $40 ;bc += 40, left edge of 3D view
	ld [de], a 
	inc e
	ld a, b
	adc a, $00
	ld [de], a ;store bc in $C9XX
	inc e
	ld a, [wPitchAngle]
	add a, l
	ld [de], a ;store HL + vert view offset into next address
	inc e
	ld a, h
	adc a, $00
	ld [de], a
	inc de
.poploop ;CD7
	pop hl
	pop bc
	dec b ;we just handled a vertex!
	jp nz, .loop
	jp .interpretA
	
.bitflagset ;CE0
	push bc ;bit 3 (mirror) of the byte was set
	push de ;push these real quick
	push hl
	ld a, [$C31C]
	ld c, a
	ld a, [$C31D]
	ld b, a ;load up the mirrored X'
	ld a, [$C31E]
	ld e, a
	ld a, [$C31F]
	ld d, a ;and mirrored Z'
	call ProjectPoint ;load up BCDE and call this
	ld a, c
	ldh [$FFF5], a
	ld a, b
	ldh [$FFF6], a
	ld a, l
	ldh [$FFF7], a
	ld a, h
	ldh [$FFF8], a ;store the results into F5-F8
	pop hl
	pop de
	pop bc
	call ProjectPoint ;now call this like normal above
	pop de ;$C9XX
	ldh a, [hRenderXOffLo]
	add a, c
	ld c, a
	ldh a, [hRenderXOffHi]
	adc a, b
	ld b, a
	ld a, c
	add a, $40
	ld [de], a ;start writing to $C9XX like above
	inc e
	ld a, b
	adc a, $00
	ld [de], a
	inc e
	ld a, [wPitchAngle]
	add a, l
	ld [de], a
	inc e 
	ld a, h
	adc a, $00
	ld [de], a
	inc de ;end of shared stuff from above
	ldh a, [$FFF5] ;now write our mirrored values
	ld c, a
	ldh a, [$FFF6]
	ld b, a
	ldh a, [$FFF7]
	ld l, a
	ldh a, [$FFF8]
	ld h, a
	ldh a, [$FF9E]
	add a, c
	ld c, a ; c = FFF5 + FF9E
	ldh a, [$FF9F]
	adc a, b
	ld b, a ; b = FFF6 + FF9F
	ld a, c
	add a, $40
	ld [de], a
	inc e
	ld a, b
	adc a, $00
	ld [de], a ;load bc + $0040 into C9 region?
	inc e
	ld a, [wPitchAngle]
	add a, l
	ld [de], a
	inc e
	ld a, h
	adc a, $00
	ld [de], a 
	inc de ;end with C2BD + HL like above...
	pop hl
	pop bc
	dec b ;we just handled a vertex
	jp nz, .loop
	jp .interpretA
	
RotateCoordsAndSaveInvert: ;D58
	;gets two pairs of reads into $48XX based on passed ABC
	;stores modified results of the pairs into C31C and C31E
	;returns the pair differences in BC
	push bc ;save the coords passed
	ld h, HIGH(SinTable)
	ldh [$FFA6], a ;save passed angle to FFA6
	ld l, a
	ld d, c ;c2 moved to d
	ld c, [hl] ;load c with sin(angle)
	call MultiplyValues ;multiply c1 with sin(angle)
	ld c, d ;restore old c2
	ld d, h ;load product into d
	ld h, HIGH(CosTable)
	ldh a, [$FFA6]
	ld l, a
	ld b, [hl] ;load b with cos(angle)
	call MultiplyValues ;multiply c2 with cos(angle)
	ld a, h ;load product into a
	sub a, d ;find c2*cos - c1*sin
	ldh [$FFA0], a ;save it
	xor a
	sub a, h 
	sub a, d ;0 - c2*cos - c1*sin
	add a, a ;double result
	ld [$C31C], a ;save it for later?
	pop bc
	push bc ;restore the passed coords
	ld h, HIGH(CosTable)
	ldh a, [$FFA6]
	ld l, a
	ld c, [hl]
	call MultiplyValues ;c1 * cos(angle)
	pop bc
	ld d, h
	ld h, HIGH(SinTable)
	ldh a, [$FFA6]
	ld l, a
	ld b, [hl]
	call MultiplyValues ;c2 * sin(angle)
	ld a, h
	add a, d ;c2*sin(angle) + c1*cos(angle)
	ld b, a ;save it to b
	xor a
	sub a, h
	add a, d
	add a, a
	ld [$C31E], a ;[C31E] = 2(-c2*sin + c1*cos)
	ldh a, [$FFA0]
	ld c, a ;BC are now c1'c2'
	sla b
	sla c ;mult both by 2
	ret
	
CopyLetterToWRAM: ;DA1
	;a is read from a table
	push hl
	push de
	push bc
	ld de, AlphabetGFX1bpp ;$41 or above
	ld h, $00
	sub $41
	jp nc, .mult
	add a, $11
	jr nc, .default
	ld de, NumbersGFX1bpp ;30-40?
	jr .mult
.default
	ld hl, BlankTileGFX1bpp ;29 or below, just use this address
	jr .skipmult
.mult ;DBC
	ld l, a
	add hl, hl ;x2
	add hl, hl ;x4
	add hl, hl ;x8
	add hl, de
.skipmult
	ld a, b
	rlca
	rlca
	rlca ;e = b*8
	ld e, a
	ld a, c
	add a, $D0
	ld d, a ;d = c + $D0
	ld b, $08
.copyloop
	ld a, [hl+]
	ld [de], a
	inc e
	dec b
	jp nz, .copyloop
	pop bc
	pop de
	pop hl
	ret
	
EmptyDD7: ;DD7
	ret
	
IF UNUSED == 1
UnusedDD8: ;DD8, lefdoff
	push bc
	push de
	push af
	ld a, [$C339]
	add a, $02
	and $0F
	ld [$C339], a
	ld c, a
	jr nz, .carry
	ld a, [$C33A]
	add a, $08
	ld [$C33A], a
.carry ;8
	ld a, [$C33A]
	ld b, a
	pop af
	push af
	call DrawHexByte
	pop af
	pop de
	pop bc
	ret
ENDC

ClearAllEntities: ;DFD
	ld hl, wEntityTable
	ld bc, ENTITY_SIZE*ENTITY_SLOTS
.entloop
	xor a
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .entloop
	ld hl, wParticleTable
	ld bc, PARTICLE_SIZE*PARTICLE_SLOTS
.partloop
	xor a
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .partloop
	ret
	
GetFreeEntity: ;E18
	ld hl, wEntityTable ;entities
	ld de, ENTITY_SIZE
	ld b, $28
	xor a
.findempty
	cp [hl]
	jr z, .slotfound ;jump if ID is 0 (slot empty)
	add hl, de
	dec b
	jr nz, .findempty
	ld hl, wEntityTable
	ld de, ENTITY_SIZE
	ld b, $28
.findhidden
	bit 7, [hl]
	jr nz, .slotfound ;jump if bit 7 set (hide entity)
	add hl, de
	dec b
	jr nz, .findhidden
	scf ;carry flag set if none found
	ret
	
.slotfound
	push hl
	xor a
	ld b, $18
.wipeloop
	ld [hl+], a ;clear out the entity data
	dec b
	jp nz, .wipeloop
	cpl
	ld [hl+], a ;write FF to the last byte
	pop hl ;return the entity address in HL
	xor a ;and clear the carry flag
	ret
	
CallLoadMainGUIGFX: ;E48
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadMainGUIGFX)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadMainGUIGFX
	pop af
	call LoadBankInA
	ret

CallLoadGameplayGUIgfx: ;E5A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadGameplayGUIgfx)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadGameplayGUIgfx
	pop af
	call LoadBankInA
	ret
	
SerialInterruptFunc: ;E6C, jumped to on serial interrupt
	reti
IF UNUSED == 1
UnusedE6C: ;E6D
	;copies bytes from bank 1. bc is a counter, de is target, hl is source
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
.loop
	xor a
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	pop af
	call LoadBankInA
	ret
ENDC
	
LoadUnusedTextTiledata: ;E87
	ldh a, [rLCDC]
	push af
	call CallDisableLCD
	ld hl, BlankTileGFX1bpp
	ld de, $8A00
	ld bc, AlphabetGFX1bpp - BlankTileGFX1bpp
	call CallLoad1BPPTiles
	ld hl, AlphabetGFX1bpp
	ld de, $8C10
	ld bc, NumbersGFX1bpp - AlphabetGFX1bpp
	call CallLoad1BPPTiles
	ld hl, NumbersGFX1bpp
	ld de, $8B00
	ld bc, DollarGFX1bpp - NumbersGFX1bpp
	call CallLoad1BPPTiles
	pop af
	ldh [rLCDC], a
	ret
	
WipeWholeScreenTiles: ;EB5
	call CallDisableLCD
	ld hl, $9800
	ld b, $00
	xor a
.loop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .loop
	ret
	
IF UNUSED == 1
UnusedEC6: ;EC6
	;copies BC bytes frin hl in bank 2 to de
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	pop af
	call LoadBankInA
	ret
ENDC

CallRotateCoordByAngle: ;EDD
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RotateCoordByAngle)
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, d
	call RotateCoordByAngle
	pop af
	call LoadBankInA
	ret

CallRestoreGUIAndMusic: ;EF0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RestoreGUIAndMusic)
	ldh [hLoadedBank], a
	ld [$2103], a
	call RestoreGUIAndMusic
	pop af
	call LoadBankInA
	ret
	
CallLoadFullGUI: ;F02
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadFullGUI)
	ldh [hLoadedBank], a
	ld [$2103], a
	call LoadFullGUI
	pop af
	call LoadBankInA
	ret
	
FuncF14: ;F14, scroll flag is 1 or 2?
	dec a
	jr nz, .flag2
	ld a, [$D15A]
	ldh [rBGP], a
	ld a, [$D159]
	dec a
	ld [$D159], a
	bit 4, a
	jr nz, .loadwith24
	ld a, $6C
	ld [$D15A], a
	jr .d15aloaded
.loadwith24
	ld a, $24
	ld [$D15A], a
.d15aloaded
	ld a, $02
	ld [wScrollYFlag], a ;swap to 2 next time
	ld a, [$D158]
	add a, $11
	ldh [rLYC], a
	pop af
	reti
.flag2 ;$2A jump
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	ld a, [$D15B]
	ld [$D158], a
	ldh [rLYC], a
	ld a, $01
	ld [wScrollYFlag], a ;swipe to 1 next time
	pop af
	reti
	
LYCInterruptFunc: ;F54, lcd stat interrupt jumps here
	push af
	ld a, [wScrollYFlag]
	cp $03
	jr z, .flag3 ;jumps to F8A
	cp $04
	jp z, .flag4
	or a
	jr nz, FuncF14 ;uhhhh, negative hex 50?
	;otherwise, scroll flag is zero
	ldh a, [rLCDC]
	set rLCDC_TILE_DATA, a ;use 8000-8FFF region
	ldh [rLCDC], a
	ld a, $60 ;scanline value to interrupt on
	ldh [rLYC], a
	ldh a, [hGameState]
	or a
	jr nz, .wait ;if not paused, jump
	ldh a, [rLCDC]
	res rLCDC_TILE_DATA, a ;scroll flag zero and we're paused, reset the tiledata offset
	ldh [rLCDC], a
.wait
	nop
	nop
	nop
	nop
	nop
	ldh a, [hIntP]
	ldh [rBGP], a
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop ;wait for a vblank or hblank
	pop af
	reti
.flag3 ;F8A scroll flag was 3
	pop af
	reti
.flag4 ;F8C scroll flag was 4
	push bc
	ld a, [wTargetSCY]
	ld c, a
	ld a, [wMapTankCellPos]
	sub $08
	sra a
	ldh [rSCX], a
	ld a, [wMapTankCellPos]
	inc a
	and $0F
	ld [wMapTankCellPos], a
	ldh a, [rLYC]
	inc a
	cp $90
	jr c, .saveLYC
	ld a, [wMapTankCellPos]
	inc a
	and $0F
	ld [wMapTankCellPos], a
	xor a ;if 90, reset the LYC
.saveLYC
	ldh [rLYC], a
	pop bc
	pop af
	reti

CallFlashScreen: ;0xFB9
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(FlashScreen)
	ldh [hLoadedBank], a
	ld [$2106], a
	ld a, d
	call FlashScreen
	pop af
	call LoadBankInA
	ret
	
CallLevelClearCheck: ;FCD, called when game over timer runs out in level
	xor a
	ld [$C2AB], a
	ldh a, [hLoadedBank]
	push af
	ld a, $06
	ldh [hLoadedBank], a
	ld [$2105], a
	ld hl, .return
	push hl ;set return point
	ld a, [$CAF5]
	ld l, a
	ld a, [$CAF6]
	ld h, a
	jp hl ;call F5/F6 pointer
.return ;FE8, return point
	jr nc, .done
	ld a, $01
	ld [$C2AB], a ;set on level 1 if crystal gotten, level 2 if all bombs destroyed
.done ;5
	pop af
	call LoadBankInA
	ret

ScatterTitleScreen: ;FF4
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	or $02
	ldh [rIE], a
	ld a, $04
	ld [$CA9D], a
	ld a, $40
	ldh [rSTAT], a
	ld a, $01
	ld [$C110], a
	loadpalette 2, 2, 2, 3
	ldh [rBGP], a
	ldh a, [rLCDC]
	res rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	ld b, $03 ;loop counter
.loop
	push bc
	call CallScreenScatter
	pop bc
	dec b
	jr nz, .loop
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	res LCD_STAT, a
	ldh [rIE], a
	xor a
	ld [$CA9D], a
	ldh [$FF43], a
	ret

ScatterBiosScreen: ;102F
	xor a
	ld [rIF], a ;clear interrupt flags
	ld a, [rIE] 
	or 02 
	ld [rIE], a ;enable LCD STAT interrupt
	ld a, 04 
	ld [$CA9D], a ;IDK
	ld a, $40 
	ld [rSTAT], a ;enable coincidence interrupt
	ld b, $0A ;loop ten times
.loop
	push bc
	call CallBGScatter 
	pop bc
	dec b
	jr nz, .loop
	xor a
	ld [rIF], a ;clear interrupt flags
	ld a, [rIE] 
	res 1, a
	ld [rIE], a ;clear coincidence interrupt
	ret
	
RetrieveWordFromBank2: ;1055
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, [bc]
	inc bc
	push af
	ld a, [bc]
	ld b, a
	pop af
	ld c, a
	pop af
	call LoadBankInA
	ret

GetSimpleByteFromBank5: ;106B
	ldh a, [hLoadedBank]
	push af
	ld a, $05
	ldh [hLoadedBank], a
	ld [$2104], a
	ld c, [hl]
	pop af
	call LoadBankInA
	ret

GetByteFromBank9: ;107B
	ldh a, [hLoadedBank]
	push af
	ld a, $09
	ldh [hLoadedBank], a
	ld [$2108], a
	ld c, [hl]
	pop af
	call LoadBankInA
	ret
	
GetByteFromBank5: ;108B
	push bc
	ldh a, [hLoadedBank]
	push af
	ld a, $05
	ldh [hLoadedBank], a
	ld [$2104], a
	ld a, [de]
	ld c, a
	pop af
	call LoadBankInA
	ld a, c
	pop bc
	ret
	
UpdateEntities: ;109F
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	xor a
	ld hl, $CAF8
	ld b, $1C
.wipeloop ;10AF
	ld [hl+], a
	dec b
	jp nz, .wipeloop
	cpl
	ld [$C2B1], a
	ld [$C2B2], a ;set these to FF
	ld hl, $C328
	ld a, $80
	ld [hl+], a
	ld [hl+], a ;$8080
	ld [hl+], a
	ld [hl+], a ;$8080
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop ;10C9
	ld a, [hl+]
	or a
	jp z, .nextent ;if model's zero, jump
	push bc ;save iterator
	push hl ;save position
	bit 7, a
	jr z, .visible ;if top bit NOT set, jump
	;so, this is a hidden model
	and $7F
	ld [$C33E], a ;hidden model
	ld [$C33B], a ;hidden model
	ld a, l
	add a, ENTITY_SIZE - 2 - 1 ;to penultimate byte.
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;put that position as DE
	ld a, [de]
	bit 2, a ;the forming flag.
	jr z, .exploding ;if not set, jump ahead
	
	;this is a forming model
	ld a, l
	add a, ENTITY_SIZE - 3 - 1 ;the byte before that
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;position to DE
	ld a, [de]
	sub $02 ;subtract 2
	cp $80
	jp c, .savformcount
	ld a, $10 ;if negative, set value to $10
.savformcount ;10FB
	ld [de], a ;save new value
	cp $04
	jr nz, .checkformed ;if not 4, jump
	ld a, $0B
	ld [wQueueNoise], a
	ld a, $04
.checkformed ;7
	rrca ;divide by two?
	ld [$C33F], a ;save value
	or a
	jp nz, .checkDeload ;jump if greater than $01
	;at 1 or 0, we've formed!
	ld a, l
	add a, ENTITY_SIZE - 2 - 1
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	res 2, a ;clear forming bit
	ld [de], a
	dec hl
	res 7, [hl] ;clear invis bit
	inc hl
	jp .checkDeload ;jump!
	
.exploding ;1122, 39, exploding model
	ld a, l
	add a, ENTITY_SIZE - 3 - 1
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	rrca ;divide by two
	ld [$C33F], a ;save value?
	rlca
	add a, $08
	ld [de], a ;increase by eight!
	jp nz, .checkDeload ;jump if not zero
	;otherwise, counter's at zero
	dec hl
	xor a
	ld [hl+], a ;wipe the model
	jr .checkDeload ;merge
	
.visible ;67, model is visible
	ld [$C33B], a ;model
	xor a
	ld [wModelExploding], a ;can't explode if visible!
	ld [$C356], a ;reset this
	call CallCheckEntityCollision
	;then fall into
	
.checkDeload ;1148, D.. forming, formed, exploding, or visible
	xor a
	ld [$C2AD], a ;? set zero
	call CallCheckDeloadEntity
	jp nc, .popfornext ;if it was deloaded, jump
	ldh a, [hXPosLow]
	ld c, a
	ldh a, [hXPosHi]
	ld b, a ;our X in BC
	ld a, [hl+]
	sub a, c
	ld c, a
	ld a, [hl+]
	sbc a, b
	ld b, a ;BC is ent X minus our X
	ldh a, [hYPosLow]
	ld e, a
	ldh a, [hYPosHi]
	ld d, a
	ld a, [hl+]
	sub a, e
	ld e, a
	ld a, [hl+]
	sbc a, d
	ld d, a ;DE is ent Y minus our Y
	ld a, b
	cp $80
	jr c, .posX ;jump if positive
	cp $F2
	jp c, .resetB8 ;jump if less than negative $D00
	jr .checkY
.posX ;7
	cp $0E
	jp nc, .resetB8 ;jump if greater than $D00
.checkY ;5, x offset is in the $D00/-$D00 range
	ld a, d
	cp $80
	jr c, .posY ;jump if positive
	cp $F2
	jp c, .resetB8 ;jump if less than negative $D00
	jr .inRange
.posY ;7
	cp $0E
	jp nc, .resetB8 ;jump if greater than $D00
.inRange ;5, y offset is in the $D00/-$D00 range
	push hl
	ld a, [wViewDir]
	call ProjectXYToCamera
	pop hl
	jp c, .resetB8 
	ld a, [wModelExploding]
	or a
	jr nz, .checkBounds ;skip if forming/unforming
	ld a, [$C33B]
	push de
	call CallCheckEntityLockable
	pop de
	cp $01
	jr nz, .unlockable
	ld a, [wFrameCounterLo]
	and $1F
	cp $10
.unlockable
	call c, CallDrawPositionOnRadar ;only if lockable and not sploded
.checkBounds
	ld a, d ;Y
	cp $80
	jp nc, .checkexploding
	cp $0E
	jp nc, .checkexploding
	ld a, b ;X
	cp $80
	jr c, .posXBounds
	cp $FE
	jp c, .checkexploding
	jr .loadEntPos
.posXBounds ;7
	cp $03
	jp nc, .checkexploding
.loadEntPos ;5
	ld a, e
	ldh [$FFDB], a
	ld a, d
	ldh [$FFDC], a
	ld a, c
	ldh [$FFDF], a
	ld a, b
	ldh [$FFE0], a ;write ent X and Y
	ldh a, [hZPosLow]
	add a, [hl]
	ldh [$FFDD], a
	inc hl
	ldh a, [hZPosHi]
	adc a, [hl]
	ldh [$FFDE], a ;write ent Z
	inc hl
	ld a, [hl+]
	ldh [$FFA5], a ;xrot
	ld a, [hl+]
	ldh [$FFA4], a ;yrot?
	ld e, a
	ld a, [hl+]
	ldh [$FFA3], a ;zrot
	ld a, [wViewDir]
	sub a, e
	ldh [$FFA1], a ;yrot
	ld a, [wModelExploding]
	or a
	jr nz, .testDamage ;jump if forming/exploding
	
	sla d ;divide Y by two?
	ld a, b ;X in A
	cp $80
	jr nc, .negX ;jump if X negative
	sub $01
	jr c, .fixshift ;fine if zero
	cp d
	jr nc, .checkexploding ;skipdraw if x < y/2
	jr nz, .fixshift ;fine if not matched
	ld a, c
	cp e
	jr nc, .checkexploding ;skipdraw if small x < small y
	jr .fixshift
.negX ;F
	cpl
	or a ;make X positive
	jr z, .fixshift ;fine if zero
	cp d
	jr nc, .checkexploding ;skipdraw if x < y/2
	jr nz, .fixshift ;fine if not matched
	ld a, c
	cp e
	jr nc, .checkexploding ;skipdraw if small x < small y
.fixshift ;18, 13, D, 9, 4
	sra d
.testDamage ;25
	pop hl
	push hl
	call CallCheckClosestTargetedEntity ;updates ents in reticle
	ld a, [$C2B3] ;proxy used?
	or a
	jr z, .testDraw
	pop hl
	push hl
	ld a, $10
	call CallDamageEntity
.testDraw
	ld a, [$C33B]
	cp $7F
	call nz, DrawModel
	ld a, $01
	ld [$C2AD], a ;set one here instead of zero
	pop hl
	push hl
	ld a, l
	add a, ENTITY_SIZE - 2 - 1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	set 0, [hl] ;clear forming flag?
.checkexploding ;124D, 42, 3C, 33, 2D, 
	pop hl
	push hl
	ld a, [wModelExploding]
	or a
	jr z, .logicNotExploding
	ld c, $F8
	call SpinEntY
	jp .popfornext
	jp .popfornext
.resetB8 ;1260, unused?
	pop hl
	push hl
	xor a
	ld [$C2B8], a ;zero
	ld a, [wModelExploding]
	or a
	jr nz, .popfornext
	jr .callLogic
.logicNotExploding
	ld a, $01
	ld [$C2B8], a ;set to one if not exploding
.callLogic
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld e, a
	ld a, [hl]
	ld d, a ;logic pointer in DE
	or e
	jr z, .doneUpdating ;if zero, jump
	ld a, $02
	ldh [hLoadedBank], a ;bank 2
	ld [$2101], a
	pop hl ;restore entity pointer
	push hl
	ld bc, .doneUpdating
	push bc ;return target
	push de ;entity pointer
	ret ;jump to entity pointer
.doneUpdating ;1291, F, return point from entity logic
	ld a, $01
	ldh [hLoadedBank], a ;bank 1
	ld [$2100], a
	ld a, [$CB06]
	inc a
	ld [$CB06], a
.popfornext ;129F
	pop hl ;list position
	pop bc ;iterator
.nextent ;12A1
	ld de, ENTITY_SIZE - 1
	add hl, de
	dec b
	jp nz, .loop
	;we've gone through them all!
	xor a
	ld [$C2B3], a
	ld a, [$CB07] ;check if ent was hostile
	or a
	jr z, .ret
	call CallHandleEntityCollision
.ret
	pop af
	call LoadBankInA
	ld a, [$CB06]
	call EmptyDD7
	ret
	
CallEntityLogicHomingMissile: ;12C1
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicHomingMissile)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicHomingMissile
	pop af
	call LoadBankInA
	ret

CallTurnEntTowardsPlayer: ;12D3
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TurnEntTowardsPlayer)
	ldh [hLoadedBank], a
	ld [$2101], a
	call TurnEntTowardsPlayer
	pop af
	call LoadBankInA
	ret
	
CallMoveEntityForward: ;12E5
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MoveEntityForward)
	ldh [hLoadedBank], a
	ld [$2109], a
	call MoveEntityForward
	pop af
	call LoadBankInA
	ret
	
CallMoveEntityBySpecifiedAmts: ;12F7
	ld e, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MoveEntityBySpecifiedAmts)
	ldh [hLoadedBank], a
	ld [$2109], a
	ld a, e
	call MoveEntityBySpecifiedAmts
	pop af
	call LoadBankInA
	ret
	
Draw3DNumber: ;130B
	;C has two digits
	;B has something, possibly always zero?
	ld e, $00
	ld hl, w3DTextBuffer
	ld a, b
	swap a ;test high nybble first
	and $0F
	cp e
	jr z, .digit2 ;skip leading zeroes
	add a, $5B ;add 91 if it's nonzero
	ld [hl+], a ;store to the buffer
	dec e
.digit2
	ld a, b
	and $0F ;now the low nybble
	cp e
	jr z, .digit3 ;skip leading zeroes
	add a, $5B
	ld [hl+], a ;else add 91 and store to the buffer
	dec e
.digit3
	ld a, c ;now load up C
	swap a ;top nybble
	and $0F
	cp $0F
	jr z, .digit4 ;skip leading zeroes
	add a, $5B
	ld [hl+], a ;load into buffer
	dec e
.digit4
	ld a, c ;low nybble, final digit
	and $0F
	add a, $5B
	ld [hl+], a ;always show it
	ld [hl], $00 ;end the buffer with EOS
	ld hl, w3DTextBuffer ;point back to the start of the buffer
	;with the buffer set up, fall into
Draw3DString: ;133E
	ld a, [hl+]
	or a
	ret z
	push hl
	cp $20
	jr z, .drewletter
	add a, $15 ;offset between text and the text models
	call CallDrawModel
.drewletter
	ldh a, [$FFDF]
	add a, $46
	ldh [$FFDF], a ;+$0046 per letter
	ldh a, [$FFE0]
	adc a, $00
	ldh [$FFE0], a
	pop hl
	jp Draw3DString

DrawModel: ;0x135B
	;bank to 1 before calling. passed a is model ID. This draws all visible edges to the screen.
	;example a's are 7F and 80
	sub $01
	ret c ;return if 0 is passed
	ld l, a ;shove it into l
	ld a, [$C2B7]
	or a
	ret nz ;return if C2B7 is nonzero
	ld h, HIGH(ModelHeadersTable)
	sla l ;multiply passed ID by two to get word offset
	ld a, [hl+] ;load pointer at $49XX into HL; this is the model table
	ld h, [hl]
	ld l, a
	ld a, [hl+] ;check if it points to a pointer (first value 1 instead of 0)
	or a
	jr z, .skip ;if not, jump ahead
	ld a, [hl+] ;if it does, load that new pointer into hl
	ld h, [hl]
	ld l, a
	ld a, $0B ;bank B. the pointers entries are offloaded into that bank?
	ldh [hLoadedBank], a
	ld [$210A], a
.skip
	ld a, [hl+];read the scale
	ld [wModelScale], a ;load it into C331
	push hl
	call LoadVertices ;loads up vertex buffer with vertex data
	pop hl
	ld a, [$C33E]
	or a
	jp nz, DrawExplodedModel ;if C33E has a value, jump
	push hl
	call LoadModelSides ;copies values from $C9XX into $C4XX using second pointer
	ld hl, wEdgeDrawFlags ;gonna wipe a chunk of wram now
	push bc ;actually pointless, since this is currently 00XX and gets trashed later
	ld b, $07
	xor a
.wipeloop ;0x1394
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jp nz, .wipeloop ;loop this seven times
	pop bc
	pop hl ;restore our header position
	call FlagEdgesForDraw ;writes FF to the $CAXX region to signal which edges to draw
	ld hl, wNumEdges ;$C400
	ld a, [hl+]
	ld b, a ;the loaded value becomes the counter
	ld de, wEdgeDrawFlags
.DrawEdgeLoop ;0x13AB
	ld a, [de]
	inc e ;for each value in CAXX area, load into FFF5-FFFC
	or a
	jp z, .blankentry ;if 00, don't draw
	push bc ;save counter
	push de ;save $CAXX position
	ld a, [hl+]
	ldh [$FFF5], a
	ld a, [hl+]
	ldh [$FFF6], a
	ld a, [hl+]
	ldh [$FFF7], a
	ld a, [hl+]
	ldh [$FFF8], a
	ld a, [hl+]
	ldh [$FFF9], a
	ld a, [hl+]
	ldh [$FFFA], a
	ld a, [hl+]
	ldh [$FFFB], a
	ld a, [hl+]
	ldh [$FFFC], a ;load edge-vertex values into the FFFX's
	push hl ;save our $C4XX position
	call CallProjectLine ;try to project to the screen
	jr c, .end ;leave the loop if ProjectLine failed
	ldh a, [$FFF5] ;otherwise load up the new screenspace values
	ld e, a
	ldh a, [$FFF7]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a ;DE = F7/F5 (coord), BC = FB/F9 - F7/F5 (deltas)
	call CallDrawLine ;uses bresenham to take BC DE and draw in WRAM1
.end
	pop hl
	pop de
	pop bc
	dec b
	jp nz, .DrawEdgeLoop
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a ;load bank 1
	ret
.blankentry ;13F1
	ld a, l
	add a, $08
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;add $8 to HL (skip an entry), dec b by one
	dec b
	jp nz, .DrawEdgeLoop
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a ;load bank 1
	ret
	
ProjectXYToCamera: ;1405
	;passed a is angle, bank 1 loaded
	;BC is X
	;DE is Y? both in $d00/-$d00 range
	push bc ;push x (gonna use this first)
	push de ;push y
	ld h, HIGH(CosTable)
	ldh [$FFA6], a ;save entry
	ld l, a
	ld a, [hl] ;Cos(A) into A
	call MultiplyWord
	pop bc ;restore y
	push bc ;save y (gonna use this next)
	push hl ;save result
	ld h, HIGH(SinTable)
	ldh a, [$FFA6]
	ld l, a
	ld a, [hl] ;Sin(A) into A
	call MultiplyWord
	pop de ;restore first result
	ld a, e
	sub a, l
	ld l, a
	ld a, d
	sbc a, h
	ld h, a ;CosX - SinY
	pop de ;y
	pop bc ;x
	push hl ;save difference of first result pair
	push de ;save y
	ld h, HIGH(SinTable)
	ldh a, [$FFA6]
	ld l, a
	ld a, [hl] ;Sin(A)
	call MultiplyWord
	pop bc ;restore y
	push hl ;save result
	ld h, HIGH(CosTable)
	ldh a, [$FFA6]
	ld l, a
	ld a, [hl] ;Cos(A)
	call MultiplyWord
	pop de ;restore result
	pop bc ;first results difference
	add hl, de ;SinX + CosY
	ld e, l
	ld d, h ;into DE
	sla e
	rl d
	sla c
	rl b ;multiply DE and BC (result pairs) by two
	xor a
	ret
	
IF UNUSED == 1
Unused144a: ;144A, oops
	push bc
	push af
	ld b, a
	call WackyMultSafe
	pop af
	pop bc
	ld c, a
	push hl ;save our val
	call WackyMultUnsafe
	pop de
	ld h, l
	ld l, $00
	add hl, de
	ret
ENDC
	
MultiplyWord: ;145D
	;passed A is value from trig table
	;BC is used
	;DE gets clobbered
	push bc ;save passed length
	push af ;save passed trig
	ld b, a ;load B with trig
	call WackyMultSafe
	pop af
	pop bc
	ld c, a ;load c with passed trig
	push hl ;save our val
	call WackyMultUnsafe
	pop de
	ld e, d
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	add hl, de
	ret
	
WackyMultSafe: ;1476
	;passed B is trig result (7F is 1, 81 is -1)
	;c is low byte of a length
	;60 cycles of math; small values could be sped up with a looped addition mult
	ld a, b
	cp $80
	push af ;save carry flag (sign)
	jp c, .nonegate1 ;if not negative, skip
	cpl
	inc a
	ld b, a
.nonegate1
	ld a, b ;b is positive angle now
	add a, c
	ld l, a ;first entry is B+C
	jp nc, .nooverflow
	;else we overflowed
	;this means..?
	;low byte plus trig (0 - 1) overflowed?
	ld h, $43 ;table at $4300
	ld d, [hl] ;D is $4300 val (high is med)
	inc h
	ld e, [hl] ;E is $4400 val (low is low)
	ld a, b
	sub a, c ;second entry is B-C (difference, always positive)
	jr nc, .nonegate2
	cpl
	inc a
.nonegate2
	ld h, $44 ;table at $4400
	ld l, a
	ld b, [hl] ;B is $4400 val (high is lowest)
	inc h
	ld c, [hl] ;C is $4500 val (low is highest)
	ld l, e
	ld h, d
	ld a, l
	sub a, c
	ld l, a ;L = E - C
	ld a, h
	sbc a, b
	ld h, a ;H = D - B
	pop af ;if passed trig was positive,
	ret c ;return
	ld e, l
	ld d, h
	ld hl, $0000
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a ;otherwise negate HL
	ret
	
.nooverflow ;14AD
	ld h, $44 ;table at $4400
	ld d, [hl]
	inc h
	ld e, [hl] ;vals from $4400 and $4500 into DE
	ld a, b
	sub a, c ;second entry is B-C
	jr nc, .nonegate3
	cpl
	inc a
.nonegate3
	dec h ;table at $4400
	ld l, a
	ld b, [hl] ;(high is lowest)
	inc h
	ld c, [hl] ;vals from $4400 and $4500 into BC (low is highest)
	ld l, e
	ld h, d
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a ;HL = DE - BC
	pop af
	ret c ;if carry set in initial comparison, return
	ld e, l
	ld d, h
	ld hl, $0000
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a ;else negate HL
	ret
	
IF UNUSED == 1
Unused14D3: ;14D3
	cp $10
	jr c, .under16
	cp $A0
	ret c
.under16 ;3
	dec hl
	ld [hl], $00
	inc hl
	ret
ENDC


WaitForNoNewInput: ;14DF
	halt
	call UpdateInputs
	ld a, [wChangedInputs]
	ld c, a
	ld a, [wCurrentInput]
	and c
	jp z, WaitForNoNewInput
	ret
	
WaitForStartPress: ;14EF
	halt
	call UpdateInputs
	ld a, [wChangedInputs]
	bit 3, a ;start button
	jr z, WaitForStartPress
	ld a, [wCurrentInput]
	bit 3, a ;start button
	jr z, WaitForStartPress
.WaitForStartRelease
	halt
	call UpdateInputs
	ld a, [wChangedInputs]
	bit 3, a ;start button
	jr nz, .WaitForStartRelease
	ld a, [wCurrentInput]
	bit 3, a ;start button
	jr nz, .WaitForStartRelease
	ret

UnusedFunc1514: ;1514
	;saves an input to $D058
	halt
	call UpdateInputs
	ld a, [wChangedInputs]
	and $0F ;mask to face buttons
	jp z, UnusedFunc1514 ;loop until something's pressed
	cp $01 ;a button
	jr z, .save
	cp $02 ;b button
	jr z, .save
	cp $08 ;start button
	jr z, .save
	jr UnusedFunc1514 ;loop if none of these three
.save
	ld [$D058], a ;save pressed button to $D058
.waitloop
	halt
	call UpdateInputs
	ld a, [wCurrentInput]
	and $0F
	jp nz, .waitloop ;wait until no buttons are down
	ret

CallSetAlertTiles: ;153E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetAlertTiles)
	ldh [hLoadedBank], a
	ld [$2101], a
	call SetAlertTiles
	pop af
	call LoadBankInA
	ret

ClearWRAM: ;0x1550
	ld hl, WRAM0_Begin
	ld b, $28
	xor a
.loop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .loop
	ret
;0x155E
	ret

IF UNUSED == 1
Unused155F: ;155F
	;loads wave properties (except the wave itself) and queues a position
	ld a, $80
	ldh [rNR30], a ;on
	ld a, $FF
	ldh [rNR31], a ;length max
	ld a, $60
	ldh [rNR32], a ;25% volume
	ld a, $FF
	ldh [rNR33], a
	ld a, $87
	ldh [rNR34], a ;87FF - restart, frequency 7FF
	ld hl, $4000 ;the top of some bank???
	jr Unused15A8 ;to 15A8
	
Unused1578: ;1578
	;copies [DE] values from HL to Channel 3 on/off, xor'd with previous
	ld b, $0A
.waitloop
	dec b
	jr nz, .waitloop
	ld a, [hl+]
	xor c
	ldh [rNR30], a
	ld c, a
	dec e
	jr nz, Unused1578
	dec d
	jr nz, Unused1578
	ret
	
Unused1589: ;1589
	;copies [DE]*4 values from HL to Channel 3 on/off, clears at end?
	ld a, [hl+]
	ld b, $09
.bloop ;F2
	dec b
	jr z, .next
	ldh [rNR30], a
	rlca
	ld c, $0A
.cloop ;FD
	dec c
	jr nz, .cloop
	dec b
	jr .bloop
.next ;B
	ld a, h
	and $7F
	ld h, a
	dec e
	jr nz, Unused1589 ;top
	dec d
	jr nz, Unused1589 ;top
	xor a
	ldh [rNR30], a
	ret
	
Unused15A8: ;15A8
	ld a, [hl+]
	add a, $80 ;que up a bit
	rrca ;rotate them in
	ldh [rNR32], a ;output level
	rlca
	sub $80
	ld b, a ;load
	xor c ;xor previous on/off
	ldh [rNR30], a ;on/off
	ld c, b ;save on/off
	ld c, $0A ;start wait
.cloop
	dec c
	jr nz, .cloop
	dec e
	jr nz, Unused15A8
	dec d
	jr nz, Unused15A8
	xor a
	ldh [rNR30], a ;off
	ret
	
AddScore: ;15C5
	;BC loaded with decimal nybbles to add to the score
	ld hl, wScoreOnes
	ld a, c
	and $0F
	ld e, a
	ld a, c
	and $F0
	rrca
	rrca
	rrca
	rrca
	ld d, a ;passed C's nybbles split into DE
	ld a, b
	and $0F
	ld c, a
	ld a, b
	and $F0
	rrca
	rrca
	rrca
	rrca
	ld b, a ;passed B's nybbles split into BC
	ld a, e
	add a, [hl] ;ca93
	cp 10
	jr c, .setones
	sub $0A
.setones ;2
	ccf
	ld [hl-], a
	ld a, d
	adc a, [hl]
	cp $0A
	jr c, .settens
	sub $0A
.settens ;2
	ccf
	ld [hl-], a
	ld a, c
	adc a, [hl]
	cp $0A
	jr c, .sethundreds
	sub $0A
.sethundreds ;2
	ccf
	ld [hl-], a
	ld a, b
	adc a, [hl]
	cp $0A
	jr c, .setthousands
	sub $0A
.setthousands ;2
	ccf
	ld [hl-], a
	ld a, [hl]
	adc a, $00
	cp $0A
	jr c, .settenthousands
	sub $0A
.settenthousands ;2
	ccf
	ld [hl-], a
	ld a, [hl]
	adc a, $00
	cp $0A
	jr c, .sethundredthousands
	sub $0A
.sethundredthousands ;2
	ld [hl-], a
	ret
	
SubtractScore: ;161E
	ld hl, wScoreOnes
	ld a, c
	and $0F
	ld e, a
	ld a, c
	and $F0
	rrca
	rrca
	rrca
	rrca
	ld d, a
	ld a, b
	and $0F
	ld c, a
	ld a, b
	and $F0
	rrca
	rrca
	rrca
	rrca
	ld b, a ;split passed score nybbles into BCDE
	ld a, [hl]
	sub a, e
	jr nc, .setones
	add a, $0A
	and $0F
	scf
.setones
	ld [hl-], a
	ld a, [hl]
	sbc a, d
	jr nc, .settens
	add a, $0A
	and $0F
	scf
.settens
	ld [hl-], a
	ld a, [hl]
	sbc a, c
	jr nc, .sethundreds
	add a, $0A
	and $0F
	scf
.sethundreds
	ld [hl-], a
	ld a, [hl]
	sbc a, b
	jr nc, .setthousands
	add a, $0A
	and $0F
	scf
.setthousands
	ld [hl-], a
	ld a, [hl]
	sbc a, $00
	jr nc, .settenthousands
	add a, $0A
	and $0F
	scf
.settenthousands
	ld [hl-], a
	ld a, [hl]
	sbc a, $00
	jr nc, .sethundredthousands
	add a, $0A
	and $0F
.sethundredthousands
	ld [hl-], a
	ret
ENDC

MagnitudeAndAngleToCoords: ;1677
	ld a, [unkMagnitude]
	ld c, a
	ld b, $00
	ld a, [unkAngle]
	inc a
	ld [unkAngle], a
	ld d, a
	call CallRotateCoordByAngle
	ld a, c
	ld [unkCoord1], a
	ld a, b
	add a, $10
	ld [unkCoord2], a
	ret

GetFreeParticleSlot: ;1693
	;returns with carry set if empty entry found
	ld hl, wParticleTable
	ld de, PARTICLE_SIZE
	ld b, PARTICLE_SLOTS
.searchloop ;F8
	ld a, [hl]
	or a
	jr z, .found
	add hl, de
	dec b
	jr nz, .searchloop
	xor a
	ret
.found ;6
	scf
	ret
	
GetMatchingEntitySlots: ;16A7
	;returns number of matching slots in C
	push hl
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
	ld c, $00
	ld de, ENTITY_SIZE
.loop
	cp [hl]
	jr nz, .next
	inc c
.next
	add hl, de
	dec b
	jr nz, .loop
	ld a, c
	pop hl
	ret

Wait200Frames: ;16BD
	ld d, $C8
WaitFrames: ;0x16BF
	call WaitForVBlank
	call UpdateInputs
	dec d 
	jr nz, WaitFrames ;start of function 
	xor a
	ret

WaitTwoVBlanks: ;0x16CA
	ld b, $02 
	jr Wait13VBlanks.loop 
Wait13VBlanks: ;0x16CE
	ld b, $0D 
.loop
	push bc
	call WaitForVBlank ;wait for lcd off / C29C to not be zero
	call UpdateInputs ;check input
	pop bc 
	dec b
	jr nz, .loop 
	ret
	
IncrementKills: ;0x16DC
	ld c, a
	ld b, $00
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, [wCurLevel]
	rrca
	rrca ;actual level number
	add a, LOW(LevelTargetModels)
	ld e, a
	ld a, HIGH(LevelTargetModels)
	adc a, $00
	ld d, a
	ld a, [de] ;grab a byte
	ld e, a
	cp c 
	jr z, .lvltarget ;if equal to passed model ID, jump
	ld hl, IgnoreModelForClosestTable
	add hl, bc
	ld a, [hl] ;grab from 2:5122 using passed model ID
	or a
	jr z, .return ;if value was 0, jump
	ld a, [$C2C7]
	inc a
	ld [$C2C7], a ;else increment mission objective and jump
	jr .return
.lvltarget ;11
	ld a, [$C32C]
	inc a
	ld [$C32C], a
.return ;10, 7
	pop af
	call LoadBankInA
	ret

IF UNUSED == 1
Unused1718: ;1718
	;passed C has bottom three bits as what bit to set, top five bits as which mono column to write to
	;passed L is height
	sla l ;l shifted left, word address?
	ld a, c
	rrca
	rrca
	rrca ;shift passed C right 3 bits
	and $1F ;bottom 5 bits
	add a, HIGH(wMonoBufferColumn1)
	ld h, a ;HL is now $D000 - EF00?
	ld a, c
	and $07 ;bottom 3 passed bits of C
	ld e, a
	ld d, HIGH(BitPatterns) ;from the top of rom!
	ld a, [de] ;take a byte
	ld c, a
	srl c
	or c
	srl c
	or c
	srl c ;shift right three
	or c ;clear carry bits?
	or [hl] ;add to the existing buffer
	ld [hl], a ;and save it
	jp UpdateParticles.checkIfPlasma
ENDC

CallRollValByTilt: ;1739
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RollValByTilt)
	ldh [hLoadedBank], a
	ld [$2106], a
	call RollValByTilt
	pop af
	call LoadBankInA
	ret
	
CallCruiseMissileLogic: ;174B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CruiseMissileLogic)
	ldh [hLoadedBank], a
	ld [$2106], a
	call CruiseMissileLogic
	pop af
	call LoadBankInA
	ret

CallUpdatePitchTilt: ;175D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UpdatePitchTilt)
	ldh [hLoadedBank], a
	ld [$2106], a
	call UpdatePitchTilt
	pop af
	call LoadBankInA
	ret

CallCheckEntityLockable: ;176F
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckEntityLockable)
	ldh [hLoadedBank], a
	ld [$2106], a
	ld a, d
	call CheckEntityLockable
	ld d, a
	pop af
	call LoadBankInA
	ld a, d
	ret
	
CallGenerateDebris: ;1785
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GenerateDebris)
	ldh [hLoadedBank], a
	ld [$2106], a
	call GenerateDebris
	pop af
	call LoadBankInA
	ret

CallLoad1BPPTiles: ;1797
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Load1BPPTiles)
	ldh [hLoadedBank], a
	ld [$2102], a
	call Load1BPPTiles
	pop af
	call LoadBankInA
	ret
	
CallPlayerJump: ;17A9
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlayerJump)
	ldh [hLoadedBank], a
	ld [$2107], a
	call PlayerJump
	pop af
	call LoadBankInA
	ret

CallCollapseTunnelEnts: ;17BB
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CollapseTunnelEnts)
	ldh [hLoadedBank], a
	ld [$2107], a
	call CollapseTunnelEnts
	pop af
	call LoadBankInA
	ret
	
CallMoveTunnelEntsCloser: ;17CD
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MoveTunnelEntsCloser)
	ldh [hLoadedBank], a
	ld [$2107], a
	call MoveTunnelEntsCloser
	pop af
	call LoadBankInA
	ret
	
CallBriefing: ;17DF
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Briefing)
	ldh [hLoadedBank], a
	ld [$210B], a
	call Briefing
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallRotateCoordsAndSaveInvert: ;17F1
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MODELBANK)
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, d
	call RotateCoordsAndSaveInvert
	pop af
	call LoadBankInA
	ret
ENDC

CallUpdateGoalCompassAndAltimeter: ;1805
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UpdateGoalCompassAndAltimeter)
	ldh [hLoadedBank], a
	ld [$2106], a
	call UpdateGoalCompassAndAltimeter
	pop af
	call LoadBankInA
	ret
	
CallRollCoordsByTilt: ;1817
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RollCoordsByTilt)
	ldh [hLoadedBank], a
	ld [$2106], a
	call RollCoordsByTilt ;1C3B4
	pop af
	call LoadBankInA
	ret
	
CallTitleScreen: ;1829
	ldh a, [hLoadedBank] 
	push af 
	ld a, BANK(TitleScreen)
	ldh [hLoadedBank], a 
	ld [$210B], a
	call TitleScreen
	pop af
	call LoadBankInA 
	ret
	
CallInitPlayerGear: ;183B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(InitPlayerGear)
	ldh [hLoadedBank], a
	ld [$2102], a
	call InitPlayerGear
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallLoadUnusedJunctionTiles: ;184D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadUnusedJunctionTiles)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadUnusedJunctionTiles
	pop af
	call LoadBankInA
	ret
ENDC

JumpIntoBank8: ;185F
	ldh a, [hLoadedBank]
	push af
	ld a, $08
	ldh [hLoadedBank], a
	ld [$2107], a
	ld de, ReturnFromBank8
	push de
	push bc
	ret ;jump to BC in bank 8, its return address is 186F
ReturnFromBank8: ;186F
	pop af
	call LoadBankInA
	ret
	
CallDrawCountdownDigit: ;1874
	ld c, a
	ldh a, [hLoadedBank]
	push af
	ld a, $08 ;bank 8
	ldh [hLoadedBank], a
	ld [$2107], a
	ld a, c
	call DrawCountdownDigit
	pop af
	call LoadBankInA
	ret

CallSetContinueNumberTile: ;1888
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetContinueNumberTile)
	ldh [hLoadedBank], a
	ld [$2109], a
	call SetContinueNumberTile
	pop af
	call LoadBankInA
	ret
	
CallContinueEnglishParser: ;189A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ContinueEnglishParser)
	ldh [hLoadedBank], a
	ld [$2109], a
	call ContinueEnglishParser
	pop af
	call LoadBankInA
	ret
	
CallAddNewMonoTextLine: ;18AC
	ldh a, [$FF9D]
	push af
	ld a, $0C
	ldh [$FF9D], a
	ld [$210B], a
	call AddNewMonoTextLine
	pop af
	call LoadBankInA
	ret

CallTryWriteScreenText: ;18BE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TryWriteScreenText)
	ldh [hLoadedBank], a
	ld [$210C], a
	call TryWriteScreenText
	pop af
	call LoadBankInA
	ret
	
CallWriteTimeOverTexts: ;18D0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(WriteTimeOverTexts)
	ldh [hLoadedBank], a
	ld [$2102], a
	call WriteTimeOverTexts
	pop af
	call LoadBankInA
	ret

ClearAllScreenText: ;18E2
	ld b, $09
	xor a
	ld hl, wScreenTextLine1Ptr
.clearloop
	ld [hl+], a
	dec b
	jr nz, .clearloop
	ret

CallCopyEnglishStringToWRAM: ;18ED
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CopyEnglishStringToWRAM)
	ldh [hLoadedBank], a
	ld [$2102], a
	call CopyEnglishStringToWRAM
	pop af
	call LoadBankInA
	ret
	
CallHandleGameOver: ;18FF
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleGameOver)
	ldh [hLoadedBank], a
	ld [$210B], a
	call HandleGameOver
	rl d
	pop af
	call LoadBankInA
	rr d
	ret
	
CallSiloDepositCrystal: ;1915
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SiloDepositCrystal)
	ldh [hLoadedBank], a
	ld [$2109], a
	call SiloDepositCrystal
	pop af
	call LoadBankInA
	ret
	
CallDoSiloInteriorText: ;1927
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DoSiloInteriorText)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DoSiloInteriorText
	pop af
	call LoadBankInA
	ret
	
CallLoadSiloInterior: ;1939
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadSiloInterior)
	ldh [hLoadedBank], a
	ld [$2109], a
	call LoadSiloInterior
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicMiniRadar: ;194B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicMiniRadar)
	ldh [hLoadedBank], a
	ld [$2107], a
	call EntityLogicMiniRadar
	pop af
	call LoadBankInA
	ret
	
CallDrawContinueBottomBox: ;195D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawContinueBottomBox)
	ldh [hLoadedBank], a
	ld [$2109], a
	call DrawContinueBottomBox
	pop af
	call LoadBankInA
	ret
	
CallSetLevelTimer: ;196F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetLevelTimer)
	ldh [hLoadedBank], a
	ld [$2105], a
	call SetLevelTimer
	pop af
	call LoadBankInA
	ret

CallDrawTitleLetters: ;1981
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawTitleLetters)
	ldh [hLoadedBank], a
	ld [$2104], a
	call DrawTitleLetters
	pop af
	call LoadBankInA
	ret

CallRecapText: ;1993
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RecapText)
	ldh [hLoadedBank], a
	ld [$2109], a
	call RecapText
	pop af
	call LoadBankInA
	ret
	
CallMissionResultsScreen: ;19A5
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MissionResultsScreen)
	ldh [hLoadedBank], a
	ld [$2109], a
	call MissionResultsScreen
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallGetAdvice: ;19B7
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetAdvice)
	ldh [hLoadedBank], a
	ld [$2109], a
	call GetAdvice
	pop af
	call LoadBankInA
	ret
ENDC

CallPrintHowManyLeft: ;19C9
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PrintHowManyLeft)
	ldh [hLoadedBank], a
	ld [$2105], a
	ld a, d
	call PrintHowManyLeft
	pop af
	call LoadBankInA
	ret

CallSetupLevel: ;19DD
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetupLevel)
	ldh [hLoadedBank], a
	ld [$2109], a
	call SetupLevel
	pop af
	call LoadBankInA
	ret
	
CallCleanUpPickupItem: ;19EF
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CleanUpPickupItem)
	ldh [hLoadedBank], a
	ld [$2107], a
	call CleanUpPickupItem
	pop af
	call LoadBankInA
	ret

CallLightTankManLogic: ;1A01
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LightTankManLogic)
	ldh [hLoadedBank], a
	ld [$2106], a
	call LightTankManLogic
	pop af
	call LoadBankInA
	ret
	
CallDrawMinimap: ;1A13
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawMinimap)
	ldh [hLoadedBank], a
	ld [$2107], a
	call DrawMinimap
	pop af
	call LoadBankInA
	ret
	
CallFlashEntityCell: ;1A25
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(FlashEntityCell)
	ldh [hLoadedBank], a
	ld [$2109], a
	call FlashEntityCell
	pop af
	call LoadBankInA
	ret

CallLoadGoalEntityID: ;1A37
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadGoalEntityID)
	ldh [hLoadedBank], a
	ld [$2106], a
	call LoadGoalEntityID
	pop af
	call LoadBankInA
	ret
	
CallHandleEntityDrop: ;1A49
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleEntityDrop)
	ldh [hLoadedBank], a
	ld [$210B], a
	call HandleEntityDrop
	pop af
	call LoadBankInA
	ret
	
CallDrawCompass: ;1A5B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawCompass)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawCompass
	pop af
	call LoadBankInA
	ret
	
CallDrawMesonBeam: ;1A6D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawMesonBeam)
	ldh [hLoadedBank], a
	ld [$2102], a
	call DrawMesonBeam
	pop af
	call LoadBankInA
	ret
	
CallDrakeEntityLogic: ;1A7F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrakeEntityLogic)
	ldh [hLoadedBank], a
	ld [$2107], a
	call DrakeEntityLogic
	pop af
	call LoadBankInA
	ret

CallSetCompassTiles: ;1A91
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetCompassTiles)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SetCompassTiles
	pop af
	call LoadBankInA
	ret
	
CallHandleTitleText: ;1AA3
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleTitleText)
	ldh [hLoadedBank], a
	ld [$2104], a
	call HandleTitleText
	pop af
	call LoadBankInA
	ret
	
CallDrawTimer: ;1AB5
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawTimer)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawTimer
	pop af
	call LoadBankInA
	ret

CallDrawMissileCount: ;1AC7
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawMissileCount)
	ldh [hLoadedBank], a
	ld [$2109], a
	call DrawMissileCount
	pop af
	call LoadBankInA
	ret
	
CallDrawSpeedDisplay: ;1AD9
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawSpeedDisplay)
	ldh [hLoadedBank], a
	ld [$2109], a
	call DrawSpeedDisplay
	pop af
	call LoadBankInA
	ret
	
LurchTargetTable: ;1AEB
	db $B0, $00, $10, $1E, $3C, $78 ;for each of the grounded speed tiers
	
CallClearAllTunnelEnts: ;1AF1
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ClearAllTunnelEnts)
	ldh [hLoadedBank], a
	ld [$2107], a
	call ClearAllTunnelEnts
	pop af
	call LoadBankInA
	ret
	
CallIterateOverMapObjects: ;1B03
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(IterateOverMapObjects)
	ldh [hLoadedBank], a
	ld [$2107], a
	call IterateOverMapObjects
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicArrow: ;1B15
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicArrow)
	ldh [hLoadedBank], a
	ld [$2102], a
	call EntityLogicArrow
	pop af
	call LoadBankInA
	ret

CallGetAngleToOffset: ;1B27
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	ld hl, .return
	push hl
	push hl ;push the ret twice?
	jp GetAngleToOffset
.return ;1B39
	ld d, a
	pop af
	call LoadBankInA
	ld a, d
	ret
	
CallEntityLogicTruck: ;1B40
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicTruck)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicTruck
	pop af
	call LoadBankInA
	ret

CallGetDistanceBetweenEnts: ;1B52
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	call GetDistanceBetweenEnts
	rl e
	ld d, a
	pop af
	call LoadBankInA
	rr e
	ld a, d
	ret

CallMoveBomb: ;1B6A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MoveBomb)
	ldh [hLoadedBank], a
	ld [$210B], a
	call MoveBomb
	pop af
	call LoadBankInA
	ret
	
CallHandleSiloInterior: ;1B7C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleSiloInterior)
	ldh [hLoadedBank], a
	ld [$2109], a
	call HandleSiloInterior
	pop af
	call LoadBankInA
	ret

CallSetupRadarItemGFX: ;1B8E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetupRadarItemGFX)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SetupRadarItemGFX
	pop af
	call LoadBankInA
	ret

CallDrawRadarBaseItem: ;1BA0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawRadarBaseItem)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawRadarBaseItem
	pop af
	call LoadBankInA
	ret
	
CallSetEquipmentItem: ;1BB2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetEquipmentItem)
	ldh [hLoadedBank], a
	ld [$2102], a
	call SetEquipmentItem
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicNukeBomb: ;1BC4
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicNukeBomb)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicNukeBomb
	pop af
	call LoadBankInA
	ret
	
CallHighEXDamageEnts: ;1BD6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HighEXDamageEnts)
	ldh [hLoadedBank], a
	ld [$2101], a
	call HighEXDamageEnts
	pop af
	call LoadBankInA
	ret

CallDestroyEntityObject: ;1BE8
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DestroyEntityObject)
	ldh [hLoadedBank], a
	ld [$2107], a
	call DestroyEntityObject
	pop af
	call LoadBankInA
	ret
	
CallCheckDeloadEntity: ;1BFA
	;sets carry if entity still loaded
	ldh a, [hLoadedBank]
	push af
	ld a, $08
	ldh [hLoadedBank], a
	ld [$2107], a
	call CheckDeloadEntity
	rl d
	pop af
	call LoadBankInA
	rr d
	ret

CallOverlayRadar: ;1C10
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(OverlayRadar)
	ldh [hLoadedBank], a
	ld [$2106], a
	call OverlayRadar
	pop af
	call LoadBankInA
	ret

CallDrawHealthBar: ;1C22
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawHealthBar)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DrawHealthBar
	pop af
	call LoadBankInA
	ret
	
CallCopyBriefImage: ;1C34
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CopyBriefImage)
	ldh [hLoadedBank], a
	ld [$210C], a
	call CopyBriefImage
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicReactorRod: ;1C46
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicReactorRod)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicReactorRod
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicSuperGun: ;1C58
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSuperGun)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicSuperGun
	pop af
	call LoadBankInA
	ret

CallHandleShopState: ;1C6A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleShopState)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleShopState
	pop af
	call LoadBankInA
	ret
CallHandleState4: ;1C7C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleState4)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleState4
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CollectReactorRod: ;1C8E
	ld a, [wMissionReactorRodCount]
	inc a
	ld [wMissionReactorRodCount], a
	ld a, [wEntityCollided]
	or a
	ret z
	ld a, COLLISION_SCENERY
	ld [wCollisionType], a
	ret
ENDC

CallEntityLogicSuperGlider: ;1CA0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSuperGlider)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicSuperGlider
	pop af
	call LoadBankInA
	ret
	
CallOrbitTarget: ;1CB2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(OrbitTarget)
	ldh [hLoadedBank], a
	ld [$2106], a
	call OrbitTarget
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallLoadAuxGUIOLD: ;1CC4
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadAuxGUIOLD)
	ldh [hLoadedBank], a
	ld [$2103], a
	call LoadAuxGUIOLD
	pop af
	call LoadBankInA
	ret
	
CallDrawHealthOLD: ;1CD6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawHealthOLD)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DrawHealthOLD
	pop af
	call LoadBankInA
	ret
	
CallLoadSegmentNumbers: ;1CE8
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadSegmentNumbers)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadSegmentNumbers
	pop af
	call LoadBankInA
	ret
ENDC

CallLoadShopkeepFrame: ;1CFA
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadShopkeepFrame)
	ldh [hLoadedBank], a
	ld [$2103], a
	ld a, d
	call LoadShopkeepFrame
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicBlackBox: ;1D0E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicBlackBox)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicBlackBox
	pop af
	call LoadBankInA
	ret
	
CallSetEntityLogicPointer: ;1D20
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetEntityLogicPointer)
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, d
	call SetEntityLogicPointer
	pop af
	call LoadBankInA
	ret
	
CallPlaceEntityInView: ;1D34
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlaceEntityInView)
	ldh [hLoadedBank], a
	ld [$2106], a
	call PlaceEntityInView
	pop af
	call LoadBankInA
	ret

CallProjectXYToCamera: ;1D46
	push hl
	ld h, a
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, h
	call ProjectXYToCamera
	pop af
	call LoadBankInA
	pop hl
	ret
	
IF UNUSED == 1
CallItem_Lazer: ;1D5C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Item_Lazer)
	ldh [hLoadedBank], a
	ld [$2102], a
	call Item_Lazer
	pop af
	call LoadBankInA
	ret
ENDC

CallGetDistanceFromPlayer: ;1D6E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetDistanceFromPlayer)
	ldh [hLoadedBank], a
	ld [$2101], a
	call GetDistanceFromPlayer
	rl e
	ld d, a
	pop af
	call LoadBankInA
	rr e
	ld a, d
	ret
	
CallDrawLockLine: ;1D86
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawLockLine)
	ldh [hLoadedBank], a
	ld [$2106], a
	call DrawLockLine
	pop af
	call LoadBankInA
	ret
	
CallSetEntityIsForming: ;1D98
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetEntityIsForming)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SetEntityIsForming
	pop af
	call LoadBankInA
	ret
	
CallCheckGameOverCondition: ;1DAA
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckGameOverCondition)
	ldh [hLoadedBank], a
	ld [$210B], a
	call CheckGameOverCondition
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicButterfly: ;1DBC
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicButterfly)
	ldh [hLoadedBank], a
	ld [$210C], a
	call EntityLogicButterfly
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicChrysalis: ;1DCE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicChrysalis)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicChrysalis
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicTank: ;1DE0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicTank)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicTank
	pop af
	call LoadBankInA
	ret
	
HandleMovementInputs: ;1DF2
	ld a, [wHideCrosshair]
	and %11111101
	ld [wHideCrosshair], a ;always clear bit 1 (temp flash)
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld e, a ;e is new inputs
	bit INPUT_A, e
	jr z, .checkB
	ld a, $01
	ld [wAJustPressed], a
.checkB
	bit INPUT_B, e
	jr z, .checkFFAE
	ld a, $01
	ld [wBJustPressed], a
.checkFFAE
	ldh a, [$FFAE]
	and %00000100 ;a certain flag? has to do with lockon process?
	jp nz, .FFAEsetBcheck ;if bit set, skip ahead
.checkLurch
	ld a, [wLurchTarget]
	or a
	jr .updateTurnSpeed ;typo? should be a conditional maybe?
	jp .doneUpdatingTurnSpeed
.FFAEsetBcheck
	bit INPUT_B, d ;current input
	jr z, .checkLurch
	bit INPUT_B, e ;new inputs
	jr z, .loadCB19
	xor a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	ld [wAimPitch], a
.loadCB19
	ld a, $01
	ld [$CB19], a
	
.updateTurnSpeed
	ld a, [wTurnSpeed]
	add a, $80 ;add/subtract 128.
	ld c, a
	ld a, c
	cp $80
	jr z, .checkrightforangle ;jump if originally 0
	jr nc, .checkright ;jump if originally positive (<80)
	bit INPUT_LEFT, d ;it was negative, so check left
	jr nz, .checkrightforangle ;if negative and left pressed, jump
	ld a, c
	add a, $08
	ld c, a ;otherwise add 8 to the angle
	cp $80
	jr nc, .correctangle
	jr .checkrightforangle
.checkright
	bit INPUT_RIGHT, d
	jr nz, .checkrightforangle ;if right pressed, jump
	ld a, c
	sub $08
	ld c, a ;otherwise subtract 8 to the angle
	cp $80
	jr nc, .checkrightforangle
.correctangle
	ld c, $80
	
.checkrightforangle
	bit INPUT_RIGHT, d
	jr z, .checkleftforangle ;if not pressed, jump
	res INPUT_RIGHT, d ;otherwise reset it
	ld a, c
	add a, $01 ;increment angle
	cp $B0
	jr nc, .loadCB43right ;if > B0, don't load C
	ld c, a
.loadCB43right
	sub $80
	ld [$CB43], a ;save our modified turnspeed
	jr c, .checkleftforangle
	jr .checkleftforangle
	
.checkleftforangle ;now check left inputs
	bit INPUT_LEFT, d
	jr z, .loadTurnSpeed
	res INPUT_LEFT, d
	ld a, c
	sub $01 ;subtract 1
	cp $50
	jr c, .loadCB43left ;if <$50, don't load C
	ld c, a
.loadCB43left
	sub $80
	ld [$CB43], a ;save our modified C2FD
	jr nc, .loadTurnSpeed
.loadTurnSpeed
	ld a, c
	sub $80
	ld [wTurnSpeed], a ;update C2FD
	
.doneUpdatingTurnSpeed ;1E97
	ld a, [$C2FE]
	add a, $80
	ld b, a ;load B with C2FE
	ld a, b
	sub $80
	ld [$C2FE], a ;no change here
	ld a, [$C2FE]
	or a
	jr z, .C2FEAdjusted ;if zero, skip
	bit 7, a
	jr nz, .increment
	dec a
	dec a
.increment
	inc a
	ld [$C2FE], a ;+1 or -1 towards 0
.C2FEAdjusted
	ld a, [$CB47]
	or a
	jr z, .donewithcrosshairflash
	ld a, [wFrameCounterLo] ;if CB47 set,
	and $07 ;get bottom four bits of timer
	cp $04
	jr nc, .donewithcrosshairflash ;every four frames, toggle flash
	ld a, [wHideCrosshair]
	or $02
	ld [wHideCrosshair], a ;toggle the reticle flash
.donewithcrosshairflash
	ldh a, [hViewAngle]
	ld e, a ;E is angle
	ld a, [$CB1A]
	or a
	jr z, .cl ;if 0, jump
	dec a
	jr z, .loadViewAngle  ;if 1, jump
	ld c, (1 << INPUT_LEFT)
	dec a
	jr z, .haveinputmask
	ld c, (1 << INPUT_RIGHT)
.haveinputmask
	ld a, d ;inputs
	and $CF ;mask off right and left
	or c ;unmask our selected input
	ld d, a ;update our inputs
	ld a, $01
	ld [$CB1A], a ;set to 1 so we don't do this again
.cl
	bit INPUT_LEFT, d
	jr z, .cr
	dec e
.cr
	bit INPUT_RIGHT, d
	jr z, .loadViewAngle 
	inc e
.loadViewAngle
	ld a, e
	ldh [hViewAngle], a ;update our viewangle
	
	ldh a, [hSpeedTier]
	bit INPUT_DOWN, d
	jr nz, .checkUpSpeed
	cp $01
	adc a, $00
.checkUpSpeed
	bit INPUT_UP, d
	jr nz, .checkknockback
	cp $05
	adc a, $FF
.checkknockback
	ld e, a ;E is our updated speed tier
	ld a, [wKnockbackCounter]
	or a
	jr z, .storetoC ;if CB48 empty, jump
	dec a
	ld [wKnockbackCounter], a ;else decrement
	cp $14
	ld a, $00
	jr c, .storetoC ;if less than 14, store 0
	ld a, $05 ;else store 5
.storetoC
	ld c, a ;store either 0 or 5 to C (tilt angle re: knockback
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL now has our Z position
	ld a, l
	sub $14
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;Z -= 14
	rr h
	rr l ;2
	rr h
	rr l ;4
	rr h
	rr l ;8
	rr h
	rr l ;16; moved down a nybble
	ld a, l
	add a, c
	ld c, a ;C += L
	ld a, [$CAA7] ;?
	sra a
	add a, c
	ld c, a ;C += CAA7 / 2
	ld a, [wAimPitch] ;?
	add a, c
	add a, $34
	ld [wPitchLurch], a ;?? value is now [wAimPitch] + 34 (normal pitch) + our C sum (knockback)
	ld c, d ;load inputs into C
	ld a, [wChangedInputs]
	and d
	ld d, a ;pressed inputs are now in D
	ld a, [wFlyingFlag]
	or a
	jr z, .checkUp ;if grounded, skip
	ld a, c
	and $3F
	ld c, a ;mask off up and down inputs if flying
.checkUp
	bit INPUT_UP, c
	jr z, .checkDown ;if up is not pressed, jump
	bit INPUT_UP, d
	jr z, .upHeld ;if it's been held, jump
	ld a, $0A ;up was just pressed this frame
	ld [$C2F1], a ;write $0A to value and skip ahead
	jr .checkTURBO
.upHeld
	ld a, [$C2F1]
	sub $01
	jr c, .loadwith1 ;if zero, save 1 instead
	ld [$C2F1], a ;else decrement and jump ahead
	jr .checkDown
.loadwith1
	ld a, $01
	ld [$C2F1], a
.checkTURBO ;we either just wrote $0A or are in 00/01 purgatory
	ld a, e ;grab our speed tier
	inc a ;what's the next one?
	cp spdTURBO
	jr nz, .checkTunnel ;if not turbo, jump ahead
	ld hl, $CA81 ;fuel
	ld a, [hl+]
	or a
	jr z, .maintainTurbo ;if no fuel, jump ahead
	ld a, [hl+]
	or a
	jr z, .maintainTurbo ;if no fuel, jump ahead
	ld a, $08
	ld [wQueueNoise], a ;play sound
.maintainTurbo
	ld a, spdTURBO
.checkTunnel
	cp spdTUNNEL
	jr nc, .checkDown ;if flying, jump
	ld e, a ;update our speed
	ld a, $03
	ld [wQueueSFX], a ;play sound
	jr .clearC0AD
.checkDown
	bit INPUT_DOWN, c
	jr z, .clearC0AD
	bit INPUT_DOWN, d
	jr z, .checkC2F1
	ld a, $0A
	ld [$C2F1], a ;just pressed, set to A
	jr .checkspeed
.checkC2F1
	ld a, [$C2F1] ;held, decrement value
	sub $01
	jr c, .loadwith1pt2
	ld [$C2F1], a
	jr .clearC0AD
.loadwith1pt2
	ld a, $01
	ld [$C2F1], a
.checkspeed 
	ld a, e ;grab our speed tier
	sub $01
	jr c, .clearC0AD
	ld e, a
	ld a, $03
	ld [wQueueSFX], a ;play sound
	jr .clearC0AD
.clearC0AD
	xor a
	ld [$C0AD], a ;unknown
	ld a, [wFlyingFlag]
	or a
	jr nz, .flying
	ld a, e
	cp $05
	jr nz, .notflying
.flying ;5
	ld hl, wFuelAmount
	ld a, [hl]
	sub $06
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	ld [hl], a ;subtract 6
	jr nc, .notflying
	xor a
	ld [hl-], a
	ld [hl], a
	ld e, spdHIGH ;cap fuel to 0, drop out of flight
	jr .loadedC0AD
.notflying
	ld a, $01
	ld [$C0AD], a
.loadedC0AD
	ld a, [wFlyingFlag]
	or a
	jr nz, .checklurch ;if flying, skip
	ld a, e 
	ldh [hSpeedTier], a ;save speed tier
	ld a, e
	add a, LOW(LurchTargetTable)
	ld l, a
	ld a, HIGH(LurchTargetTable)
	adc a, $00
	ld h, a
	ld a, [hl] ;grab value at 1AEB + tier?
	ld [wLurchTarget], a ;save to CA88
.checklurch ;10
	ld a, [wLurchTarget]
	add a, $80
	ld c, a
	ld a, [wLurchCounter]
	add a, $80
	ld e, a
	cp c
	jr z, .saveupdatedlurch ;if CA88 and counter equal, jump to $203F
	jr nc, .lurchback ; if counter > 88, jump
;lurch forward
	ld a, e
	add a, $04
	ld e, a ;else increase counter towards 88
	ld a, [wPitchLurch]
	sub $01
	ld [wPitchLurch], a ;decrement this tilt
	ld a, e
	cp c
	jr c, .saveupdatedlurch ;if counter still < 88, jump
	ld e, c ;else make them equal
	jr .saveupdatedlurch ;jump
.lurchback
	ld a, e
	sub $04
	ld e, a
	ld a, [wPitchLurch]
	add a, $01
	ld [wPitchLurch], a
	ld a, e
	cp c
	jr nc, .saveupdatedlurch
	ld e, c
.saveupdatedlurch
	ld a, c
	sub $80
	ld [wLurchTarget], a
	ld a, e
	sub $80
	ld [wLurchCounter], a ;save values
	ret
	
UpdateParticles: ;204C
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld hl, wParticleTable
	ld b, PARTICLE_SLOTS
.particleLoop ;205B
	ld a, [hl] ;life
	sub $01
	jp c, .nextParticle ;if life was at zero, jump ahead
	push bc ;counter
	push hl ;position
	ld [hl+], a ;save life
	ldh [$FFA0], a
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;x speed into BC
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld c, a
	ld a, [hl]
	adc a, b
	ld [hl+], a
	ld b, a ;increase xpos by xspeed, new xpos in BC
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;y speed into DE
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld e, a
	ld a, [hl]
	adc a, d
	ld [hl+], a
	ld d, a ;increase ypos by yspeed, new ypos in DE
	ld a, [hl+]
	ldh [$FFCF], a
	ld a, [hl+]
	ldh [$FFD0], a ;Zpos in CF/D0
	ld a, [hl+]
	ldh [$FFD1], a ;type into D1
	ld hl, hXPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;our xpos in HL
	ld a, c
	sub a, l
	ld c, a
	ld a, b
	sbc a, h
	ld b, a ;BC is particle xpos - our xpos
	ld hl, hYPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, e
	sub a, l
	ld e, a
	ld a, d
	sbc a, h
	ld d, a ;DE is particle ypos - our ypos
	ld a, b
	cp $80
	jr c, .xpos
	cp $EC
	jp c, .checkIfPlasma
	jr .xinrange
.xpos ;7
	cp $14
	jp nc, .checkIfPlasma
.xinrange ;5
	ld a, d
	cp $80
	jr c, .ypos
	cp $EC
	jp c, .checkIfPlasma
	jr .yinrange
.ypos ;7
	cp $14
	jp nc, .checkIfPlasma
.yinrange ;5
	ld a, [wViewDir]
	call ProjectXYToCamera
	ldh a, [$FFD1] ;type
	or a
	jr z, .checkInvinc ;zero does damage
	cp $02
	jp nz, .checkeddamage ;2 does damage; everything else skips
.checkInvinc ;5
	ld a, [wHitInvinc]
	sub $01
	jr c, .checkCollision
	ld [wHitInvinc], a ;decrement
	jp .checkeddamage
.checkCollision ;6
	ld a, c
	sub $41
	ld a, b
	sbc a, $00
	cp $80
	jr c, .checkeddamage ;if X > 40, jump
	ld a, c
	add a, $41
	ld a, b
	adc a, $00
	cp $80
	jr nc, .checkeddamage ;if X < -40, jump
	ld a, e
	sub $41
	ld a, d
	sbc a, $00
	cp $80
	jr c, .checkeddamage ;if Y > 40, jump
	ld a, e
	add a, $41
	ld a, d
	adc a, $00
	cp $80
	jr nc, .checkeddamage ;if Y < -40, jump
	ldh a, [hZPosLow]
	sub $14
	ld l, a
	ldh a, [hZPosHi]
	sbc a, $00
	ld h, a ;hl is our Z pos minus $14
	ldh a, [$FFCF] ;particle zpos lo
	add a, l
	ld l, a
	ldh a, [$FFD0] ;particle zpos hi
	adc a, h
	ld h, a ;HL += particle zpos
	ld a, l
	add a, $28
	ld a, h
	adc a, $00
	cp $80
	jr nc, .checkeddamage ;if negative, jump?
	ld a, $06 ;bunp
	ld [wQueueSFX], a
	pop hl ;restore particle table position
	ld [hl], $00 ;kill the particle
	ld a, [wHealth]
	dec a
	ld [wHealth], a ;owie
	ld a, [wScreenShakeCounter]
	add a, $0A
	ld [wScreenShakeCounter], a
	ld a, $0A
	ld [wHitInvinc], a
	push hl
.checkeddamage ;213F, 57 - 1D. done checking for/dealing damage.
	ld a, d
	cp $80
	jp nc, .checkIfPlasma ;if Y is negative, jump
	ld a, b
	cp $80
	jr c, .xpos2
	cp $FE
	jp c, .checkIfPlasma
	jr .xrange2
.xpos2 ;7
	cp $03
	jp nc, .checkIfPlasma
.xrange2 ;it's not right next to us, and visible
	ldh a, [$FFD1] ;type
	or a
	jr nz, .notzero
	ld a, $00 ;value is zero if type is zero
	jr .invertval
.notzero ;4, type is not zero
	dec a
	jr nz, .notone ;if one, jump
	ldh a, [$FFA0] ;particle life
	cpl
	and $1F ;low five bits, inverted
	add a, $40
	ld l, a
	ld h, $46 ;table? $4640 - 465F
	jr .grabfromtable
.notone ;C, type is not one
	ldh a, [$FFA0] ;particle life
	cpl
	and $3F ;low six bits, inverted
	ld l, a
	ld h, $46 ;table? $4600 - 463F
.grabfromtable ;8
	ld a, [hl] ;grab a byte from HL into A.
.invertval ;18
	cpl ;invert value
	ld l, a ;load value to L
	bit 7, l
	ld h, $00
	jr z, .project
	ld h, $FF ;extend L into HL
.project ;2
	ldh a, [hZPosLow]
	add a, l
	ld l, a
	ldh a, [hZPosHi]
	adc a, h
	ld h, a ;add our Z to HL
	ldh a, [$FFCF]
	add a, l
	ld l, a
	ldh a, [$FFD0]
	adc a, h
	ld h, a ;add particle Z to HL
	ld a, [$C2B7]
	or a
	jp nz, .checkIfPlasma ;if disabled, skip?
	push de
	call ProjectPoint
	pop de ;save distance
	push bc ;X:Z
	push hl ;Y:Z
	ld h, $10
	ld l, $00
	call SubtractWords ;BC -= HL
	pop hl ;Y:Z
	ld a, [wPitchAngle]
	add a, l
	ld l, a ;l is now adjusted screen Y 
	ld a, h
	ld h, c ;screen X to H?
	pop bc ;X:Z
	adc a, $00
	jr nz, .checkIfPlasma ;if Y overflowed the byte, jump
	ld a, l
	cp $58
	jr nc, .checkIfPlasma ;if Y is offscreen, jump
	ld a, c
	add a, $40
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;X:Z += $40
	jr nz, .checkIfPlasma ;if C overflowed, jump
	ld a, c
	cp $80
	jr nc, .checkIfPlasma ; if X is offscreen, jump
	ldh a, [$FFD1] ;type
	cp $01
	jr nz,.checkenemyshot ;if not 1 (debris), skip
	srl h
	srl h
	srl h ;shift H down three
	inc h ;and plus 1
.checkenemyshot ;7
	cp $02
	jr nz, .notenemyshot ;if not enemy shot, skip ahead
	;enemy shot
	ld a, h
	cp $40
	jr c, .jumptoenemyshot
	ld a, $40 ;cap A to $40
.jumptoenemyshot ;2
	jp .enemyshot ;only called if enemy shot
	
.notenemyshot
	ld a, h
	cp $01
	jr c, .checkIfPlasma ;if H is zero, jump?
	cp $10
	jr c, .cappedH
	ld h, $10 ;else cap it at $10
.cappedH ;2
	ld a, c ;X coord
	cp $78
	jr nc, .checkIfPlasma
	cp $08
	jr c, .checkIfPlasma
	call CallDrawBall ;only call if on screen
.checkIfPlasma ;21F9, 46 - 03
	ldh a, [$FFD1] ;type
	or a
	jp .nextPartPops ;??? all shots check this....
;21FF, this is a plasma ball
	pop hl ;particle table entry
	push hl
	call CallTestParticleEntsCollision
	jp nc, .nextPartPops
	ld a, $01
	call CallDamageEntity
	jr c, .killPart
	pop hl
	push hl
	xor a
	ld [hl+], a ;kill part life
	inc hl
	inc hl
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;load X to BE
	inc hl
	inc hl
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;load Y to DE
	ld a, [hl+]
	cpl
	add a, $01
	ldh [$FFCF], a
	ld a, [hl+]
	cpl
	adc a, $00
	ldh [$FFD0], a ;particle Z
	ld a, $02
	call GenerateDebris.loop ;plasma fizzles out. note that this is in a different bank, and crashes.
	pop hl
	jr .popbc
.killPart ;24
	pop hl
	ld [hl], $00
	jr .popbc
.nextPartPops ;2237
	pop hl
.popbc ;6, 1
	pop bc
.nextParticle ;2239
	ld de, PARTICLE_SIZE
	add hl, de
	dec b
	jp nz, .particleLoop
	pop af
	call LoadBankInA
	ret
	
.enemyshot ;2246, this is an enemy shot
	ld b, a ;range 0 - $40
	ld e, a
	srl e ;e/2
	ld a, l ;Y pos
	sub a, e
	jr nc, .nounderflow
	dec a
	add a, b ;if E underflowed, add B
	jp nc, .checkIfPlasma ;if that didn't fix, jump
	inc a
	ld b, a ;and save value to B
	ld l, $00 ;clear L
	jr .shiftX ;and jump
.nounderflow ;B, e didn't underflow
	ld l, a ;overwrite the Y pos with new value
	ld a, l
	add a, b ;add B
	sub $58 ;and subtract $58
	jr c, .shiftX ;if that underflowed, jump
	ld d, a ;else, subtract this value from B
	ld a, b
	sub a, d
	jp c, .checkIfPlasma ;and if that somehow underflowed, jump
	ld b, a ;else save this value to B
.shiftX ;E, 7
	ld a, b
	or a
	jp z, .checkIfPlasma ;if b is 0, leave
	push af ;save this value!
	ld a, c ;low X
	rrca
	rrca
	rrca ;x << 3
	and %0011111
	add a, HIGH(wMonoBufferColumn1)
	ld h, a
	ld a, c
	and %00000111
	ld e, a ;save offset
	ld b, $00
	sub $05
	jr c, .getbitmask
	inc a ;if 5, 6, or 7, increment and then loop
.shiftB ;fa
	scf
	rr b ;shift in bottom bit of B
	dec a
	jr nz, .shiftB
.getbitmask ;7
	ld d, $00
	ld a, [de] ;grab a bitmask from romtop
	ld c, a ;save it to C
	sra c
	or c ;two bits
	sra c
	or c ;three bits
	sra c
	or c ;four bits wide
	ld d, b ;shifted B
	ld c, a ;overwrite C with.... original bitmask?
	ldh a, [$FFD1] ;check type (we know this is 2)
	cp $02
	jr nz, .prepdraw ;jump if not 2....
	ld a, d
	and %10101010
	ld d, a
	ld a, c
	and %10101010
	ld c, a ;otherwise mask off our B and C pattern 
.prepdraw ;8
	pop af
	ld b, a ;restore Y to being in B
	push af ;and save it
.drawloopC ;fa
	ld a, c
	or [hl]
	ld [hl+], a
	dec b
	jr nz, .drawloopC
	pop af
	ld b, a ;restore our count again
	ld a, d
	or a
	jp z, .checkIfPlasma ;if D blank, don't need to draw
	ld a, l ;y pos?
	sub a, b ;minus count
	ld l, a ;save
	inc h
	ld a, h ;check our position
	cp $E0 ;if we breach the buffer,
	jp nc, .checkIfPlasma ;end here
.drawloopD;FA
	ld a, d
	or [hl]
	ld [hl+], a
	dec b
	jr nz, .drawloopD
	jp .checkIfPlasma
	
;22C7, generates a particle but with a Y of zero
	push af
	xor a
	ldh [$FFCF], a
	ldh [$FFD0], a
	pop af
	
GenerateParticle: ;22CE
	;A is something, DE is Z, BC is X, FFCF/FFD0 is Y, H is type, L is something (angle?)
	ldh [$FFD1], a ;store the passed A
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a ;BANK 1
	ldh a, [$FFD1] ;restore the passed A
	push af
	push hl
	push bc
	push de
	call GetFreeParticleSlot
	jr c, .found
	add sp, $08 ;undo the pushes
	pop af
	call LoadBankInA
	ret
.found ;7
	ld a, [$CA9E] ;first roll
	ld [hl], a ;save to HL (age)
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;increment HL by 9
	pop de ;Z
	pop bc ;X
	ldh a, [$FFCF]
	cpl
	add a, $01
	ld [hl+], a
	ldh a, [$FFD0]
	cpl
	adc a, $00
	ld [hl-], a ;Y to HL
	dec hl
	ld a, d
	ld [hl-], a
	ld a, e
	ld [hl-], a ;Z to HL (going backwards)
	dec hl
	dec hl ;-2
	ld a, b
	ld [hl-], a
	ld a, c
	ld [hl-], a ;X to HL
	pop de ;passed HL? H is 1, L is random
	pop af ;passed A
	push de ;passed HL
	push hl ;position
	ld d, $00
	ld b, d
	ld c, d ;zero out BC amd D, E is random, a is random
	call ProjectXYToCamera ;generate BC and DE based on passed L and A
	pop hl ;restore position
	ld a, b
	ld [hl-], a
	ld a, c
	ld [hl+], a ;write BC to HL
	inc hl
	inc hl
	inc hl ;HL += 4 (to the two we skipped)
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a ;write DE to that
	pop de ;passed HL
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], d ;hl+4 = passed H (type)
	pop af
	call LoadBankInA
	ret
	
CallDrawFloorDots: ;2337
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawFloorDots)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawFloorDots
	pop af
	call LoadBankInA
	ret
	
FlagEdgesForDraw: ;2349
	;handles face data?
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL += 4, advance to the third pointer in the header
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;follow the pointer into this new blob
	ld a, [hl+] ;first byte is a counter
	ld b, a
.mainloop ;2356
	push bc ;save counter
	inc hl
	inc hl
	inc hl ;skip forward three bytes (XYZ normals)
	ld d, $C9 ;vertex data page
	ld a, [hl+] ;load number of sides into a
	rlca ;rotate left, copy to carry
	jr nc, .calcnormal ;if top bit wasn't set (always draw flag), jump
	;if set, do below:
	srl a ;shift right, this clears the top bit
	cp $02
	jr z, .exactly2 ;if bit 1 is 0, jump
	ld [wFaceIncrement], a ;set this to num of sides
	ld [wFaceEdges], a ;set this to num of sides
	jp .forceloadfaceedge
.exactly2
	ld [wFaceEdges], a ;this is 2
	inc a
	ld [wFaceIncrement], a ;this is 3?
	jp .forceloadfaceedge
	
.calcnormal
	;this seems to calc the vert loop orientation from loaded+projected values in ram
	rrca ;if top bit wasn't set, we have more to do. restore the value
	ld [wFaceEdges], a ;true number of faces?
	sub $03
	jr nc, .skipxor ;if a is above 2, don't set a to 0
	xor a
.skipxor
	ld [wFaceIncrement], a ;save [C332]-3 or 0 into C333, whichever is more
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a ;read bytes into EBC - all three are offsets into $C9XX (vertex memory)
	push hl ;save our position
	ld a, [de] ;E offset
	cpl
	add a, $01 
	ld l, a
	inc e
	ld a, [de]
	cpl
	adc a, $00
	ld h, a ;negate word at [$C9XX], store in hl
	inc e
	ld a, [de]
	ldh [$FFCF], a ;next value goes into FFCF
	ld e, b
	push bc
	ld a, [de] ;B offset
	ld c, a
	inc e
	ld a, [de]
	ld b, a ;load this word into BC
	inc e
	ld a, [de]
	ld e, a
	ldh a, [$FFCF]
	ld d, a ;load next byte into E, and [FFCF] into D
	ld a, e
	ldh [$FFCF], a ;replace FFCF with the byte we just read
	sub a, d ;subtract old FFCF from new FFCF we just read
	ldh [$FFD0], a ;load it into FFD0
	add hl, bc ;add our read BC to our HL (negative 1st plus second)
	pop de ;pushed BC becomes DE - old c will be used as offset later
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a ;negate BC, like we did earlier for HL
	push hl ;save this for later
	ld d, $C9
	ld a, [de] ;C offset
	ld l, a
	inc e
	ld a, [de]
	ld h, a ;read a word into HL
	inc e
	ld a, [de]
	ldh [$FFD1], a ;read a third byte into FFD1
	add hl, bc ;add our negative BC to HL (negative second plus third)
	ldh a, [$FFCF]
	ld e, a
	ldh a, [$FFD1]
	sub a, e
	ldh [$FFD1], a ;store modified FFCF to FFD1
	ld c, l
	ldh a, [$FFD0]
	ld b, a ;load BC - both differences?
	call WackyMultUnsafe ; reads from $43XX and $44XX tables and stores to hl
	ld a, l
	cpl
	add a, $01
	ld l, a
	ld a, h
	cpl
	adc a, $00
	ld h, a ;negate resulting HL
	pop de ;our HL pushed from before the func
	push hl ;store out negative HL
	ld c, e
	ldh a, [$FFD1]
	ld b, a ;load bc
	call WackyMultUnsafe ;stores to HL
	pop de ;our hl right up there
	add hl, de ;subtract first results from second results
	ld a, h
	cp $80
	jr nc, .loadfaceedge ;if H >= 80, jump
	or l
	jr z, .loadfaceedge ;if H == L, jump
	pop hl ;restore our position in the blob
	ld a, [wFaceIncrement]
	ld c, a
	ld a, [wFaceEdges]
	add a, c
	ld c, a ;c = C332 + C333
	ld b, $00
	add hl, bc ;add this offest to our addres, and loop
	jr .end
	
.loadfaceedge
	pop hl ;restore our position in the blob
.forceloadfaceedge ;2403
	ld a, [wFaceIncrement]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to the edge offsets (add C333 to HL)
	ld a, [wFaceEdges] ;use C332 as a loop counter
	ld b, a
	ld d, HIGH(wEdgeDrawFlags)
	ld c, $FF
.loop
	ld a, [hl+] ;read a byte to use as offset into CAXX region
	ld e, a
	ld a, c
	ld [de], a ;write $FF to our CAXX region (flags it to be drawn??)
	dec b
	jr nz, .loop
.end
	pop bc
	dec b ;loop!
	jp nz, .mainloop
	ret
	
CallDisableLCD: ;0x2421
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DisableLCD)
	ldh [hLoadedBank], a
	ld [$2106], a
	call DisableLCD
	pop af
	call LoadBankInA
	ret
	
CallDrawBall: ;2433
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawBall)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawBall
	pop af
	call LoadBankInA
	ret

CallScaleByDistance: ;2445
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ScaleByDistance)
	ldh [hLoadedBank], a
	ld [$2103], a
	call ScaleByDistance
	pop af
	call LoadBankInA
	ret
	
CallCheckRadarStatic: ;2457
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckRadarStatic)
	ldh [hLoadedBank], a
	ld [$2103], a
	call CheckRadarStatic
	pop af
	call LoadBankInA
	ret
	
CallDrawRadarStatic: ;2469
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawRadarStatic)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DrawRadarStatic
	pop af
	call LoadBankInA
	ret
	
CallDrawPositionOnRadar: ;247B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawPositionOnRadar)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawPositionOnRadar
	pop af
	call LoadBankInA
	ret

CallDrawStars: ;248D
	ldh a, [hLoadedBank]
	push af
	ld a, Bank(DrawStars)
	ldh [hLoadedBank], a
	ld [$210C], a
	call DrawStars
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallOpenOptions: ;249F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(OpenOptions)
	ldh [hLoadedBank], a
	ld [$2102], a
	call OpenOptions
	pop af
	call LoadBankInA
	ret
ENDC

NextRand: ;0x24B1
	;might need a better name, seems to be a general masking function used for the scattering transitions
	push hl
	push bc
	ld hl, hRandLast ;this is a pointer, loaded into hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ldh a, [hRandSeedLo] ;loaded into c
	ld c, a
	ldh a, [hRandSeedHi] ; loaded into b
	ld b, a
	ld a, l
	rla
	rl h
	rla
	rl h
	rla
	rl h ;hl multiplied by 8?
	sub $07 ;then minus 7
	xor c ;xor'd with c?
	ld l, a
	ldh [hRandSeedLo], a ;low byte gets stored in C8
	ld a, h
	ldh [hRandSeedHi], a ;high byte stored in C9
	ld a, c
	ldh [hRandLastLo], a ;C8 and C9 shifted forward two bytes
	ld a, b
	ldh [hRandLastHi], a
	ld a, l ;the low byte of HL loaded back into A
	pop bc
	pop hl
	ret
	
CallScreenScatter: ;24DC
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ScreenScatter)
	ldh [hLoadedBank], a
	ld [$2101], a
	call ScreenScatter
	pop af
	call LoadBankInA
	ret

CallBGScatter: ;0x24EE
	ldh a, [hLoadedBank] 
	push af
	ld a, BANK(BGScatter) 
	ldh [hLoadedBank], a 
	ld [$2101], a 
	call BGScatter
	pop af
	call LoadBankInA 
	ret
CallProjectLine: ;0x2500
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	call ProjectLine ;2:400C?
	rl c
	pop af
	call LoadBankInA
	rr c
	ret
	
CallDrawLine: ;2516
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawLine)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawLine
	pop af
	call LoadBankInA
	ret
	
CallDrawCrosshair: ;2528
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawCrosshair)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawCrosshair
	pop af
	call LoadBankInA
	ret
	
DrawExplodedModel: ;253A:
	xor a
	ld [$C2CE], a ;clear these out
	xor a
	ld [$C2CF], a
	inc hl
	inc hl ;advance past vertex pointer
	ld a, [hl+]
	ld [$C335], a
	ld a, [hl+]
	ld [$C336], a ;save the edge pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [hl+] ;follow the face pointer
	or a
	ret z ;return if zero faces
	ld b, a ;otherwise save the face counter
.faceloop ;2553
	push bc
	ld a, [hl+] ;read the first normal byte??
	ld c, a ;save it into c
	push hl ;save read position
	ld a, [$C33F] ;unknown
	ld b, a
	call WackyMultUnsafe
	ld a, h
	ldh [$FFB7], a
	ld a, l
	ldh [$FFB6], a ;save the results from 745
	pop hl
	ld a, [hl+]
	ld c, a ;read next normal
	push hl
	ld a, [$C33F]
	ld b, a
	call WackyMultUnsafe
	sra h
	rr l ;divide result by two?
	ld a, l
	ldh [$FFB4], a
	ld a, h
	ldh [$FFB5], a ;save second results
	pop hl
	ld a, [hl+]
	ld c, a
	push hl
	ld a, [$C33F]
	ld b, a
	call WackyMultUnsafe
	ld a, h
	ldh [$FFB3], a
	ld a, l
	ldh [$FFB2], a ;save third normal results
	pop hl
	xor a
	ldh [$FFCE], a
	ld a, [hl+]
	and $7F ;read number of sides on the face, ignore the always-shown bit
	ld e, l
	ld d, h ;backup our read position into DE
	or a
	jr nz, .nonzerosides ;if nonzero sides, skip
.strobeloop ;2596
	ldh a, [rBGP] ;if zero sides, invert bg palette??
	cpl
	ldh [rBGP], a
	jr .strobeloop
	
.nonzerosides
	ld b, a ;use as loop counter
	ld [wFaceEdgesAlt], a
.edgesloop ;25A1
	push bc ;save counter
	ld a, [de] ;read vertex offset
	push de ;save position
	ld l, a
	push af ;save read offset
	rrca ;divide by two
	add a, l ;value * 1.5??? turns 4-based offset into 6-based offset
	ld e, a
	ld d, HIGH(wExplodedVertBuffer) ;$C7XX into DE now
	ldh a, [$FFB6]
	ld c, a
	ldh a, [$FFB7]
	ld b, a ;load first normal value into BC
	ld a, [de] ;read vertex data byte
	add a, c
	ld c, a
	inc e
	ld a, [de]
	adc a, b
	ld b, a ;BC is now normal word 1 + vertex data word 1
	inc e
	push bc ;save that sum
	ldh a, [$FFB2]
	ld c, a
	ldh a, [$FFB3]
	ld b, a
	ld a, [de]
	add a, c
	ld c, a
	inc e
	ld a, [de]
	adc a, b
	ld b, a
	inc e
	push bc ;save normal word 3 + vertex data word 2
	ldh a, [$FFB4]
	ld c, a
	ldh a, [$FFB5]
	ld b, a
	ld a, [de]
	add a, c
	ld c, a
	inc e
	ld a, [de]
	adc a, b
	ld b, a
	inc e ;bc is now normal word 2 + vertex data word 3, with previous two sums on the stack
	ld a, [$C2CE] ;set to zero at the top
	add a, c
	ld c, a
	ld a, [$C2CF] ;set to zero at the top
	adc a, b
	ld b, a
	push bc ;add CE/CF value to sum3, and push
	pop hl ;sum3
	pop de ;sum2
	pop bc ;sum1
	ld a, d
	cp $80
	jr c, .dontclearsum2
	jr z, .dontclearsum2 ;jump if de <= 8000 ?
	ld de, $0000
	ld a, $01
	ldh [$FFCE], a
.dontclearsum2
	ldh a, [$FFCE] ;0 or 1
	or a
	call z, ProjectPoint ;uses BC DE HL, returns value in HL?
	ld e, l
	ld d, h ;save result into DE
	pop af ;restore read offset value
	ld l, a
	ld h, HIGH(wVertBuffer)
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a ;write vertex data into proper $C9XX area
	pop de ;restore read position
	inc de ;advance
	pop bc ;restore counter
	dec b ;decrement it
	jp nz, .edgesloop ;loop if there's more to do
	ld l, e
	ld h, d ;hl is now our reading position
	ld a, [wFaceEdgesAlt]
	cp $02 ;if two faces, advance again to reach edge IDs
	jr nz, .atEdgeIDs
	inc hl
.atEdgeIDs
	ldh a, [$FFCE] ;0 or 1
	or a
	jr z, .zeroval
	ld a, [wFaceEdgesAlt]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;if 1, advance past the rest of the face
	jr .donehandlingface ;to 269A
.zeroval
	ld a, [wFaceEdgesAlt]
	or a
	jp z, .strobeloop
	ld b, a
.handlefaceedge ;2630
	push bc ;save counter
	ld a, [hl+] ;read
	ld e, a
	push hl ;save position
	ld hl, wModelEdgesPointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;follow the edges
	inc hl ;skip past quantity
	sla e ;multiply by two, for pair offset
	ld a, l
	add a, e
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance that far into the edge data table
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;load pair into DE
	ld h, HIGH(wVertBuffer)
	ld l, e ;load hl with first vert offset
	ldh a, [$FF9E]
	add a, $40
	ld c, a
	ldh a, [$FF9F]
	adc a, $00
	ld b, a ;BC is now the 9E/9F word + $0040
	ld a, [hl+]
	add a, c
	ldh [$FFF5], a
	ld a, [hl+]
	adc a, b
	ldh [$FFF6], a ;F5/F6 is two vert data bytes + BC
	ld a, [wPitchAngle]
	add a, [hl]
	inc hl
	ldh [$FFF7], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFF8], a ;F7/F8 is our angle + third vert byte
	ld l, d ;load hl with second vert offset
	ld a, [hl+]
	add a, c
	ldh [$FFF9], a
	ld a, [hl+]
	adc a, b
	ldh [$FFFA], a ;again, first two bytes + BC
	ld a, [wPitchAngle]
	add a, [hl]
	inc hl
	ldh [$FFFB], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFFC], a ;and again, third byte + pitch angle as word
	call CallProjectLine
	jr c, .donedrawingline
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF7]
	ld d, a ;DE is coord
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a ;BC is deltas
	call CallDrawLine
.donedrawingline ;the 11 jumps here
	pop hl
	pop bc
	dec b
	jp nz, .handlefaceedge
.donehandlingface ;269A
	pop bc
	dec b
	jp nz, .faceloop
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ret

LoadTileMap: ;0x26A7
	;de is an offset into $9800 (X offset into tilemap)
	;c is base tile, added to all map values
	ld a, e
	ld e, $00
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e ;these shifts and rotates divide DE by eight
	add a, e
	ld e, a
	ld a, d
	add a, $98 ;de/8+9800, gets an offset into the background map
	ld d, a
	push bc ;save bc
	ld a, [hl+]
	ld b, [hl]
	inc hl ;hl+1 is a counter
.loop2 ;do A times
	push af ;save value in [hl]
	push de ;save new offset
	push bc ;save [hl+]
.loop ; do B times
	ld a, [hl+]
	add a, c
	ld [de], a ;write hl+2 value into vram offset
	ld a, e
	add a, $20 ;add 20 to e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ; add $0020 to offset DE
	dec b
	jr nz, .loop
	pop bc ;restore the counter
	pop de ;restore the vram offset
	inc de ;increase by 1
	pop af ;restore value in counter
	dec a ;decrement counter
	jr nz, .loop2
	pop bc ;restore base tile
	ld a, b
	sla c
	rla
	sla c
	rla
	sla c
	rla
	sla c
	rla ;multiply BC by 16, add $8000 and store it into de - this is the base tile address still!
	add a, $80
	ld d, a
	ld e, c
	push de ;DE is now our cursor into tilegfx vram
	ld a, [hl+] ;load next two bytes into bc, multiply by eight
	ld b, a
	ld a, [hl+]
	ld c, a
	ld a, b
	sla c
	rla
	sla c
	rla
	sla c
	rla
	ld b, a
	push bc ;save BC, this is our iterator?
	call .checkcompressed ;call this with bc and de stored, then do it a second time
	pop bc
	pop de
	inc de ;on the second time de += 1 (the other bitplane)
.checkcompressed ;0x2701
	ld a, [hl+]
	bit 7, a
	jr nz, .decompress ;if value is negative, it's a run of compressed
	inc a ;else, positive value means a run of uncompressed
	push af ;save the value
	cpl
	inc a
	add a, c ;subtract next byte from bc (master counter)
	ld c, a
	ld a, b
	adc a, $FF
	ld b, a
	pop af ;restore byte
	push bc ;save result
	ld b, a ;using the byte as a counter,
.vramcopy ;0x2713
	ld a, [hl+] ;store byte into vram at [de]
	ld [de], a
	inc de
	inc de
	dec b
	jp nz, .vramcopy
.runend ;0x271B
	pop bc ;restore result
	ld a, b
	or c
	jp nz, .checkcompressed ;if it's not zero, subtract again
	ret
.decompress ;0x2722
	;this is jumped to when bit 7 fails the check above
	cpl
	inc a
	push af ;invert our byte and save it
	cpl
	inc a
	add a, c ;add our negative number our special way
	ld c, a
	ld a, b
	adc a, $FF
	ld b, a
	pop af ;grab our now-positive counter
	push bc ;save master counter
	ld b, a ;save counter to B
	ld a, [hl+] ;read a value
.vramdecompress
	ld [de], a ;save it to vram
	inc de
	inc de ;1bpp value
	dec b
	jp nz, .vramdecompress
	jp .runend
	
LoadBank7TilesetOffsetEA: ;273B
	ld bc, $00EA
	jr LoadBank7TilesetOffset80.skip
LoadBank7TilesetOffset80: ;2740
	ld bc, $0080
.skip
	ld de, $0001
LoadBank7Tileset: ;2746
	ldh a, [hLoadedBank]
	push af
	ld a, $07
	ldh [hLoadedBank], a
	ld [$2106], a
	call LoadTileMap
	pop af
	call LoadBankInA
	xor a
	ldh [hGameState], a
	xor a
	ld [rIF], a
	ld a, [rIE]
	res 1, a
	ld [rIE], a
	ret
	
IF UNUSED == 1
;0x2764, loads a tilemap
	ld bc, $0080
	ld de, $0001
	ldh a, [hLoadedBank]
	push af
	ld a, $05
	ldh [hLoadedBank], a
	ld [$2104], a
	call LoadTileMap
	pop af
	call LoadBankInA
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	res LCD_STAT, a
	ldh [rIE], a
	xor a
	ldh [hGameState], a
	ret
ENDC

CallCheckClosestTargetedEntity: ;2788
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckClosestTargetedEntity)
	ldh [hLoadedBank], a
	ld [$2106], a
	call CheckClosestTargetedEntity
	pop af
	call LoadBankInA
	ret

CallHandleJunctionState: ;279A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleJunctionState)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleJunctionState
	pop af
	call LoadBankInA
	ret
	
CallHandleState2: ;27AC
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleState2)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleState2
	pop af
	call LoadBankInA
	ret

CallDrawModel: ;27BE
	ld d, a ;passed A (model)
	ldh a, [hLoadedBank]
	push af
	ld a, $01 ;load the model bank (1)
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, d
	call DrawModel
	pop af
	call LoadBankInA
	ret
	
CallCopyWRAMToVRAM: ;27D2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CopyWRAMToVRAM)
	ldh [hLoadedBank], a
	ld [$2101], a
	call CopyWRAMToVRAM ;0x9A14
	pop af
	call LoadBankInA
	ret
	
CallDrawConvoScreen: ;27E4
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawConvoScreen)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawConvoScreen
	pop af
	call LoadBankInA
	ret

CallDrawHalf3D: ;27F6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawHalf3D)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawHalf3D
	pop af
	call LoadBankInA
	ret

IF UNUSED == 1
CallUnusedCopyMonoBufferToScreen: ;2808
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UnusedCopyMonoBufferToScreen)
	ldh [hLoadedBank], a
	ld [$2101], a
	call UnusedCopyMonoBufferToScreen
	pop af
	call LoadBankInA
	ret
ENDC

CallSetLevelPointers: ;281A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetLevelPointers)
	ldh [hLoadedBank], a
	ld [$2101], a
	call SetLevelPointers
	pop af
	call LoadBankInA
	ret
	
CallCheckTunnelEntitiesCollision: ;282C
	;carry flag set if we hit something
	ldh a, [hLoadedBank]
	push af
	ld a, $02
	ldh [hLoadedBank], a
	ld [$2101], a
	call CheckTunnelEntitiesCollision
	rl c
	pop af
	call LoadBankInA
	rr c
	ret

CallDrawTunnelEntities: ;2842
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawTunnelEntities)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawTunnelEntities
	pop af
	call LoadBankInA
	ret
	
CallHandleEntityCollision: ;2854
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleEntityCollision)
	ldh [hLoadedBank], a
	ld [$2101], a
	call HandleEntityCollision
	pop af
	call LoadBankInA
	ret
	
CallBumpedRecoil: ;2866
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BumpedRecoil)
	ldh [hLoadedBank], a
	ld [$2101], a
	call BumpedRecoil
	pop af
	call LoadBankInA
	ret

CallFireMissile: ;2878
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(FireMissile)
	ldh [hLoadedBank], a
	ld [$210E], a
	call FireMissile
	pop af
	call LoadBankInA
	ret
	
CallEntityDropNewEntity: ;288A
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityDropNewEntity)
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, d
	call EntityDropNewEntity
	rl c
	pop af
	call LoadBankInA
	rr c
	ret
	
CallSpawnNewCoin: ;28A2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SpawnNewCoin)
	ldh [hLoadedBank], a
	ld [$2101], a
	call SpawnNewCoin
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicCoin: ;28B4
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicCoin)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicCoin
	pop af
	call LoadBankInA
	ret

CallGetAngleToEntity: ;28C6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetAngleToEntity)
	ldh [hLoadedBank], a
	ld [$2101], a
	call GetAngleToEntity
	ld d, a
	pop af
	call LoadBankInA
	ld a, d
	ret
	
CallGetAngleBetweenEnts: ;28DA
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetAngleBetweenEnts)
	ldh [hLoadedBank], a
	ld [$2101], a
	call GetAngleBetweenEnts
	ld d, a
	pop af
	call LoadBankInA
	ld a, d
	ret

CallUseItem: ;28EE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UseItem)
	ldh [hLoadedBank], a
	ld [$2102], a
	call UseItem
	pop af
	call LoadBankInA
	ret
	
CallCheckInventoryForItemTypeThree: ;2900
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckInventoryForItemTypeThree)
	ldh [hLoadedBank], a
	ld [$2102], a
	call CheckInventoryForItemTypeThree
	pop af
	call LoadBankInA
	ret
	
CallEmpty1022D: ;2912
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Empty1022D)
	ldh [hLoadedBank], a
	ld [$2103], a
	call Empty1022D
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallDrawTunnelHeaderValues: ;2924
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawTunnelHeaderValues)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DrawTunnelHeaderValues
	pop af
	call LoadBankInA
	ret
ENDC

BlankFunc2936: 
	ret

CallCheckEntityCollision: ;2937
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckEntityCollision)
	ldh [hLoadedBank], a
	ld [$2103], a
	call CheckEntityCollision
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallMissionReport: ;2949
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MissionReport)
	ldh [hLoadedBank], a
	ld [$2103], a
	call MissionReport
	pop af
	call LoadBankInA
	ret
	
CallLoadModelName: ;295B
	ld c, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadModelName)
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, c
	call LoadModelName
	pop af
	call LoadBankInA
	ret
ENDC

CallTestEntityHasCollisions: ;296F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TestEntityHasCollisions)
	ldh [hLoadedBank], a
	ld [$2103], a
	call TestEntityHasCollisions
	rl c
	pop af
	call LoadBankInA
	rr c
	ret
	
CallTestParticleEntsCollision: ;2985
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TestParticleEntsCollision)
	ldh [hLoadedBank], a
	ld [$2103], a
	call TestParticleEntsCollision
	rl c
	pop af
	call LoadBankInA
	rr c
	ret

IF UNUSED == 1
;299B
	ldh a, [hLoadedBank]
	push af
	ld a, $0C
	ldh [hLoadedBank], a
	ld [$210B], a
	call $42B9
	pop af
	call LoadBankInA
	ret
	
CallHandleLevelInputs: ;29AD
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	call HandleLevelInputs
	pop af
	call LoadBankInA
	ret
	
CallHandleLowHealthAndLauncherText: ;29BF
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	call HandleLowHealthAndLauncherText
	pop af
	call LoadBankInA
	ret

CallCheckSerial: ;29D1
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckSerial)
	ldh [hLoadedBank], a
	ld [$2103], a
	call CheckSerial
	pop af
	call LoadBankInA
	ret
	
ENDC

CallUpdateSound: ;29E3
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(JumpToUpdateSound)
	ldh [hLoadedBank], a
	ld [$2105], a
	call JumpToUpdateSound
	pop af
	call LoadBankInA
	ret

CallInitSound: ;29F5
	;pushes registers, puts current bank into a, and then calls 
	ldh a, [hLoadedBank] 
	push af 
	ld a, BANK(JumpToInitSound) 
	ldh [hLoadedBank], a 
	ld [$2105], a 
	push hl
	push de
	push bc
	call JumpToInitSound
	pop bc 
	pop de
	pop hl
	pop af
	call LoadBankInA 
	ret
	
CallResetSound: ;0x2A0D
	ldh a, [hLoadedBank] 
	push af
	ld a, BANK(JumpToResetSound) 
	ldh [hLoadedBank], a 
	ld [$2105], a 
	call JumpToResetSound ;resets sound
	pop af 
	call LoadBankInA 
	ret
	
IF UNUSED == 1
CallPrintStringAtHL: ;0x2A1F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PrintStringAtHL)
	ldh [hLoadedBank], a
	ld [$2101], a
	call PrintStringAtHL
	pop af
	call LoadBankInA
	ret
ENDC

CallPrintInterfaceString: ;2A31
	ld e, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PrintInterfaceString)
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, e
	call PrintInterfaceString
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallPrintInterfaceStringAtBC: ;2A45
	ld e, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PrintInterfaceString)
	ldh [hLoadedBank], a
	ld [$2101], a
	ld a, e
	call PrintInterfaceString.atBC
	pop af
	call LoadBankInA
	ret
ENDC

CallDrawFuel: ;2A59
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawFuel)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DrawFuel ;4:41A6
	pop af
	call LoadBankInA
	ret

CallDrawMaxedHorizon: ;2A6B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawMaxedHorizon)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawMaxedHorizon
	pop af
	call LoadBankInA
	ret
	
CallClear3DBG: ;2A7D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Clear3DBG)
	ldh [hLoadedBank], a
	ld [$2101], a
	call Clear3DBG
	pop af
	call LoadBankInA
	ret

CallDrawSurfaceAndSky: ;2A8F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawSurfaceAndSky)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DrawSurfaceAndSky
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallUnused7482: ;2AA1
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(Unused7482)
	ldh [hLoadedBank], a
	ld [$2101], a
	call Unused7482
	pop af
	call LoadBankInA
	ret
CallLoadAlphanumerics: ;2AB3
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadAlphanumerics)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadAlphanumerics
	pop af
	call LoadBankInA
	ret
ENDC
CallCalcClosestDistance: ;2AC5
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CalcClosestDistance)
	ldh [hLoadedBank], a
	ld [$2101], a
	call CalcClosestDistance
	pop af
	call LoadBankInA
	ret
IF UNUSED == 1
CallEnterHiscoreName: ;2AD7
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EnterHiscoreName)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EnterHiscoreName
	pop af
	call LoadBankInA
	ret

CallDisplayHiscores: ;2AE9
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DisplayHiscores)
	ldh [hLoadedBank], a
	ld [$2103], a
	call DisplayHiscores
	pop af
	call LoadBankInA
	ret
	
CallSaveSRAM_OLD: ;2AFB
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SaveSRAM_OLD)
	ldh [hLoadedBank], a
	ld [$2101], a
	call SaveSRAM_OLD
	pop af
	call LoadBankInA
	ret
	
CallLoadSRAM_OLD: ;2B0D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadSRAM_OLD)
	ldh [hLoadedBank], a
	ld [$2101], a
	call LoadSRAM_OLD
	pop af
	call LoadBankInA
	ret
	
CallCheckForHiscore_OLD: ;2B1F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckForHiscore_OLD)
	ldh [hLoadedBank], a
	ld [$2101], a
	call CheckForHiscore_OLD
	pop af
	call LoadBankInA
	ret
ENDC

CallHandleRadarBase: ;2B31
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleRadarBase)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleRadarBase
	pop af
	call LoadBankInA
	ret

CallDrawRadarBG: ;2B43
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawRadarBG)
	ldh [hLoadedBank], a
	ld [$2106], a
	call DrawRadarBG
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicSprog1: ;2B55
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSprog1)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicSprog1
	pop af
	call LoadBankInA
	ret

CallEntityLogicBomb: ;2B67
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicBomb)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicBomb
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicMilitaryBase: ;2B79
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicMilitaryBase)
	ldh [hLoadedBank], a
	ld [$2103], a
	call EntityLogicMilitaryBase
	pop af
	call LoadBankInA
	ret
	
;2B8B
	ld c, $10
SpinEntY: ;2B8D
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	add a, c
	ld [hl], a
	ret
	
IF UNUSED == 1
CallShowMissionHelp: ;2B99
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ShowMissionHelp)
	ldh [hLoadedBank], a
	ld [$2103], a
	call ShowMissionHelp
	pop af
	call LoadBankInA
	ret
ENDC

CallButterflyShootLazer: ;2BAB
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ButterflyShootLazer)
	ldh [hLoadedBank], a
	ld [$2101], a
	call ButterflyShootLazer
	pop af
	call LoadBankInA
	ret
	
CallFindEntityWithModel: ;2BBD
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(FindEntityWithModel)
	ldh [hLoadedBank], a
	ld [$2101], a
	call FindEntityWithModel
	rr d
	pop af
	call LoadBankInA
	rl d
	ret
	
CallBarOutScreen: ;2BD4
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BarOutScreen)
	ldh [hLoadedBank], a
	ld [$2103], a
	call BarOutScreen
	pop af
	call LoadBankInA
	ret
	
CallMonoBufferToRadarScreen: ;2BE6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(MonoBufferToRadarScreen)
	ldh [hLoadedBank], a
	ld [$210B], a
	call MonoBufferToRadarScreen
	pop af
	call LoadBankInA
	ret

CallHandleRadarLevelText: ;2BF8
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleRadarLevelText)
	ldh [hLoadedBank], a
	ld [$210B], a
	call HandleRadarLevelText
	pop af
	call LoadBankInA
	ret
	
CallGetEntityArea: ;2C0A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetEntityArea)
	ldh [hLoadedBank], a
	ld [$210B], a
	call GetEntityArea
	ld d, a
	pop af
	call LoadBankInA
	ld a, d
	ret

CallTutFadeOut: ;2C1E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TutFadeOut)
	ldh [hLoadedBank], a
	ld [$210B], a
	call TutFadeOut
	pop af
	call LoadBankInA
	ret

CallHandleContinueScreenInput: ;2C30
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleContinueScreenInput)
	ldh [hLoadedBank], a
	ld [$2102], a
	call HandleContinueScreenInput
	ld e, a
	rl d
	pop af
	call LoadBankInA
	rr d
	ld a, e
	ret
	
CallEntityLogicSprog3ScenerySix: ;2C48
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSprog3ScenerySix)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicSprog3ScenerySix
	pop af
	call LoadBankInA
	ret

CallTriggerCredits: ;2C5A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TriggerCredits)
	ldh [hLoadedBank], a
	ld [$210D], a
	call TriggerCredits
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicTunnelEntrance: ;2C6C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicTunnelEntrance)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicTunnelEntrance
	pop af
	call LoadBankInA
	ret

CallHandleJunctionTunnelSel: ;2C7E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleJunctionTunnelSel)
	ldh [hLoadedBank], a
	ld [$210D], a
	call HandleJunctionTunnelSel
	rl d
	pop af
	call LoadBankInA
	rr d ;maintain carry flag
	ret

CallDrawMinimapPips: ;2C94
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawMinimapPips)
	ldh [hLoadedBank], a
	ld [$2102], a
	call DrawMinimapPips
	pop af
	call LoadBankInA
	ret
	
CallGetEntityDirection: ;2CA6
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GetEntityDirection)
	ldh [hLoadedBank], a
	ld [$2104], a
	ld a, d
	call GetEntityDirection
	pop af
	call LoadBankInA
	ret

CallLoadBriefBubbleGFX: ;2CBA
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadBriefBubbleGFX)
	ldh [hLoadedBank], a
	ld [$210B], a
	call LoadBriefBubbleGFX
	pop af
	call LoadBankInA
	ret
	
CallDrawBriefSpeechPage: ;2CCC
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawBriefSpeechPage)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawBriefSpeechPage
	pop af
	call LoadBankInA
	ret
	
CallUpdateBriefScreenModels: ;2CDE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UpdateBriefScreenModels)
	ldh [hLoadedBank], a
	ld [$210B], a
	call UpdateBriefScreenModels
	pop af
	call LoadBankInA
	ret
	
CallBriefCommanderIntro: ;2CF0
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BriefCommanderIntro)
	ldh [hLoadedBank], a
	ld [$210B], a
	call BriefCommanderIntro
	pop af
	call LoadBankInA
	ret

CallSetUpBriefing: ;2D02
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetUpBriefing)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SetUpBriefing
	pop af
	call LoadBankInA
	ret
	
CallBriefDrawCommander: ;2D14
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BriefDrawCommander)
	ldh [hLoadedBank], a
	ld [$210B], a
	call BriefDrawCommander
	pop af
	call LoadBankInA
	ret
	
CallBriefDrawSpeech: ;2D26
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BriefDrawSpeech)
	ldh [hLoadedBank], a
	ld [$210B], a
	call BriefDrawSpeech
	pop af
	call LoadBankInA
	ret
	
CallBriefDrawScreen: ;2D38
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BriefDrawScreen)
	ldh [hLoadedBank], a
	ld [$210B], a
	call BriefDrawScreen
	pop af
	call LoadBankInA
	ret

CallDrawTextIntoWram: ;2D4A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawTextIntoWram)
	ldh [hLoadedBank], a
	ld [$210E], a
	call DrawTextIntoWram
	pop af
	call LoadBankInA
	ret
	
CallTextDrawChar: ;2D5C
	ld e, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TextDrawChar)
	ldh [hLoadedBank], a
	ld [$2104], a
	ld a, e
	call TextDrawChar
	pop af
	call LoadBankInA
	ret
	
CallLoadBriefImageToBuffer: ;2D70
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadBriefImageToBuffer)
	ldh [hLoadedBank], a
	ld [$210C], a
	call LoadBriefImageToBuffer
	pop af
	call LoadBankInA
	ret

CallEntityLogicLittleMan: ;2D82
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicLittleMan)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicLittleMan
	pop af
	call LoadBankInA
	ret
	
CallSiloHasCrystalSetup: ;2D94
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SiloHasCrystalSetup)
	ldh [hLoadedBank], a
	ld [$210E], a
	call SiloHasCrystalSetup
	pop af
	call LoadBankInA
	ret

CallEntityLogicNuclearSilo: ;2DA6
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicNuclearSilo)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicNuclearSilo
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicToughEnemy: ;2DB8
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicToughEnemy)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicToughEnemy
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallSeekNDestroyRadars: ;2DCA
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SeekNDestroyRadars)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SeekNDestroyRadars
	pop af
	call LoadBankInA
	ret
ENDC
	
CallEntityLogicWarehouse: ;2DDC
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicWarehouse)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicWarehouse
	pop af
	call LoadBankInA
	ret
	
CallPlaceEntityAhead: ;2DEE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlaceEntityAhead)
	ldh [hLoadedBank], a
	ld [$2106], a
	call PlaceEntityAhead
	pop af
	call LoadBankInA
	ret
	
CallLoadTunnelHealthGFX: ;2E00
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadTunnelHealthGFX)
	ldh [hLoadedBank], a
	ld [$2102], a
	call LoadTunnelHealthGFX
	pop af
	call LoadBankInA
	ret
	
CallCheckDeleteSaveInput: ;2E12
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckDeleteSaveInput)
	ldh [hLoadedBank], a
	ld [$210D], a
	call CheckDeleteSaveInput
	rr d
	pop af
	call LoadBankInA
	rl d
	ret

CallDamageEntity: ;2E28
	ld d, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DamageEntity)
	ldh [hLoadedBank], a
	ld [$210B], a
	ld a, d
	call DamageEntity
	pop af
	call LoadBankInA
	ret
	
CallEntityShootDoubleShot: ;2E3C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityShootDoubleShot)
	ldh [hLoadedBank], a
	ld [$2102], a
	call EntityShootDoubleShot
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicSpiderTransform: ;2E4E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSpiderTransform)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicSpiderTransform
	pop af
	call LoadBankInA
	ret
	
CallHandlePaused: ;2E60
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandlePaused)
	ldh [hLoadedBank], a
	ld [$210E], a
	call HandlePaused
	pop af
	call LoadBankInA
	ret
	
CallDrawBomb: ;2E72
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawBomb)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawBomb
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallChackGameOver: ;2E84
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ChackGameOver)
	ldh [hLoadedBank], a
	ld [$210B], a
	call ChackGameOver
	pop af
	call LoadBankInA
	ret
ENDC

CallBombDamageEnts: ;2E96
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(BombDamageEnts)
	ldh [hLoadedBank], a
	ld [$2101], a
	call BombDamageEnts
	pop af
	call LoadBankInA
	ret

CallSetLevelTitle: ;2EA8
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetLevelTitle)
	ldh [hLoadedBank], a
	ld [$210B], a
	call SetLevelTitle
	pop af
	call LoadBankInA
	ret
	
CallEntityPlayShootShound: ;2EBA
	ld c, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityPlayShootShound)
	ldh [hLoadedBank], a
	ld [$210B], a
	ld a, c
	call EntityPlayShootShound
	pop af
	call LoadBankInA
	ret

CallGenericEnemyLogic: ;2ECE
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(GenericEnemyLogic)
	ldh [hLoadedBank], a
	ld [$210B], a
	call GenericEnemyLogic
	pop af
	call LoadBankInA
	ret
	
CallEntityLogicSceneryThree: ;2EE0
	ldh a, [$FF9D]
	push af
	ld a, BANK(EntityLogicReplenishAll)
	ldh [$FF9D], a
	ld [$210B], a
	call EntityLogicReplenishAll
	pop af
	call LoadBankInA
	ret

CallDrawEntryArrow: ;2EF2
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawEntryArrow)
	ldh [hLoadedBank], a
	ld [$210B], a
	call DrawEntryArrow
	pop af
	call LoadBankInA
	ret
	
CallSetupSiloGraphics: ;2F04
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(SetupSiloGraphics)
	ldh [hLoadedBank], a
	ld [$210D], a
	call SetupSiloGraphics
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
CallEntityLogicSprogNoSpin: ;2F16
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EntityLogicSprogNoSpin)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EntityLogicSprogNoSpin
	pop af
	call LoadBankInA
	ret
ENDC

CallRefreshBGTiles: ;2F28
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RefreshBGTiles)
	ldh [hLoadedBank], a
	ld [$210E], a
	call RefreshBGTiles
	pop af
	call LoadBankInA
	ret
	
CallUpdateTimer: ;2F3A
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(UpdateTimer)
	ldh [hLoadedBank], a
	ld [$210B], a
	call UpdateTimer
	pop af
	call LoadBankInA
	ret

CallPlanetSelect: ;2F4C
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlanetSelect)
	ldh [hLoadedBank], a
	ld [$210D], a
	call PlanetSelect
	pop af
	call LoadBankInA
	ret
	
CallHandleFlightHeight: ;2F5E
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleFlightHeight)
	ldh [hLoadedBank], a
	ld [$210B], a
	call HandleFlightHeight
	pop af
	call LoadBankInA
	ret

CallPointToEntityEntry: ;2F70
	ld c, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PointToEntityEntry)
	ldh [hLoadedBank], a
	ld [$210B], a
	call PointToEntityEntry
	pop af
	call LoadBankInA
	ret

CallPlayBrief: ;2F83
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlayBrief)
	ldh [hLoadedBank], a
	ld [$2104], a
	call PlayBrief
	pop af
	call LoadBankInA
	ret
	
CallEscapeSequence: ;2F95
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(EscapeSequence)
	ldh [hLoadedBank], a
	ld [$210B], a
	call EscapeSequence
	pop af
	call LoadBankInA
	ret

CallReadSave: ;2FA7
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(ReadSave)
	ldh [hLoadedBank], a
	ld [$210D], a
	call ReadSave
	pop af
	call LoadBankInA
	ret
	
CallWriteSave: ;2FB9
	ldh a, [hLoadedBank]
	push af
	ld a, $0E
	ldh [hLoadedBank], a
	ld [$210D], a
	call WriteSave
	pop af
	call LoadBankInA
	ret
	
CallTriggerMissionComplete: ;2FCB
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TriggerMissionComplete)
	ldh [hLoadedBank], a
	ld [$210B], a
	call TriggerMissionComplete
	pop af
	call LoadBankInA
	ret
	
CallDestroyAllHostiles: ;2FDD
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DestroyAllHostiles)
	ldh [hLoadedBank], a
	ld [$2101], a
	call DestroyAllHostiles
	pop af
	call LoadBankInA
	ret
	
CallDrawSkyMoon: ;2FEF
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DrawSkyMoon)
	ldh [hLoadedBank], a
	ld [$210E], a
	call DrawSkyMoon
	pop af
	call LoadBankInA
	ret

CallPrintTutorialTextPage: ;3001
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PrintTutorialTextPage)
	ldh [hLoadedBank], a
	ld [$2108], a
	call PrintTutorialTextPage
	pop af
	call LoadBankInA
	ret
	
CallLoadCharsetEnglish: ;3013
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadCharsetEnglish)
	ldh [hLoadedBank], a
	ld [$2104], a
	call LoadCharsetEnglish
	pop af
	call LoadBankInA
	ret
	
CallLoadCharset: ;3025
	push bc
	ld c, a
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(LoadCharset)
	ldh [hLoadedBank], a
	ld [$2104], a
	ld a, c
	call LoadCharset
	pop af
	call LoadBankInA
	pop bc
	ret
	
CallDisplayTutorialLesson: ;303B
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(DisplayTutorialLesson)
	ldh [hLoadedBank], a
	ld [$210E], a
	call DisplayTutorialLesson
	pop af
	call LoadBankInA
	ret
	
CallInterpretScriptTut: ;304D
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(InterpretScriptTut)
	ldh [hLoadedBank], a
	ld [$210E], a
	call InterpretScriptTut
	pop af
	call LoadBankInA
	ret
	
CallHandleSomeLetters: ;305F
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleSomeLetters)
	ldh [hLoadedBank], a
	ld [$2108], a
	call HandleSomeLetters
	pop af
	call LoadBankInA
	ret

CallTutorialEntityLogic: ;3071
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(TutorialEntityLogic)
	ldh [hLoadedBank], a
	ld [$210E], a
	call TutorialEntityLogic
	pop af
	call LoadBankInA
	ret
	
CallPlayDemo: ;3083
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(PlayDemo)
	ldh [hLoadedBank], a
	ld [$210E], a
	call PlayDemo
	pop af
	call LoadBankInA
	ret
	
CallHandleBriefExitPrompt: ;3095
	rl d ;save carry
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(HandleBriefExitPrompt)
	ldh [hLoadedBank], a
	ld [$210C], a
	rr d ;restore carry
	call HandleBriefExitPrompt
	rl d ;save carry
	pop af
	call LoadBankInA
	rr d ;restore carry
	ret
	
CallCheckTutScriptProgress: ;30AF
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(CheckTutScriptProgress)
	ldh [hLoadedBank], a
	ld [$210E], a
	call CheckTutScriptProgress
	rl c ;save carry
	pop af
	call LoadBankInA
	rr c ;restore carry
	ret
	
IF UNUSED == 1
CallLoadArrowC: ;30C5
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(InterpretScriptTut)
	ldh [hLoadedBank], a
	ld [$210E], a
	call InterpretScriptTut.loadArrowC
	pop af
	call LoadBankInA
	ret
	
CallWipeUnknownSprite: ;30D7
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(InterpretScriptTut)
	ldh [hLoadedBank], a
	ld [$210E], a
	call InterpretScriptTut.wipeUnknownSprite
	pop af
	call LoadBankInA
	ret
ENDC

CallRingEntityLogic: ;30E9
	ldh a, [hLoadedBank]
	push af
	ld a, BANK(RingEntityLogic)
	ldh [hLoadedBank], a
	ld [$210E], a
	call RingEntityLogic
	pop af
	call LoadBankInA
	ret
	
IF UNUSED == 1
TunnelThenReset: ;30FB
	call PrepareTunnelForLevel
	xor a
	ldh [rBGP], a
	jp Reset
ENDC

LoadTunnel: ;3104
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, TRACK_TUNNEL_DEMO
	ld [wQueueMusic], a
	ld a, [$C2DB]
	or a
	jr z, .skip
	ld a, TRACK_URGENT
	ld [wQueueMusic], a
.skip
	ld a, l
	ld [wTunnelPointerLo], a
	ld a, h
	ld [wTunnelPointerHi], a ;saved address from pointer table? tunnel pointers?
	ld a, $80
	ld [wTunnelIntroTimer], a ;this skips the intro
	ld a, $01
	call PrepareTunnelRaw
	pop af
	call LoadBankInA
	ret
	
HandleJunctionTunnel: ;3135
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld a, TRACK_TUNNEL_DEMO
	ld [wQueueMusic], a
	ld a, l
	ld [wTunnelPointerLo], a
	ld a, h
	ld [wTunnelPointerHi], a
	ld a, $80
	ld [wTunnelIntroTimer], a ;skip timer
	xor a
	call PrepareTunnelRaw
	pop af
	call LoadBankInA
	ret

CallPrepareTunnelForLevel: ;315A
	ldh a, [hLoadedBank]
	push af
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	call PrepareTunnelForLevel
	pop af
	call LoadBankInA
	ret

PrepareTunnelForLevel: ;316C
	ld a, [wCurLevel]
	or a
	jr z, .noreturn
	cp LEVEL_ESCAPE
	scf
	ret nz ;if not zero or $28, return with carry flag set
.noreturn
	ld a, $12 ;standard tunnel tune
	ld [wQueueMusic], a
	ld a, [wCurLevel]
	srl a ;divide by two into word offset
	and $FE ;mask bottom bit, just in case
	add a, LOW(TunnelPointerTable)
	ld l, a
	ld a, $00
	adc a, HIGH(TunnelPointerTable)
	ld h, a
	ld a, [hl+]
	ld [wTunnelPointerLo], a
	ld a, [hl+]
	ld [wTunnelPointerHi], a
	xor a
	ld [wTunnelIntroTimer], a ;reset the intro timer
	;falls into
PrepareTunnelRaw: ;3196
	ld d, a
	ld hl, hXPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	ld hl, hYPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl ;XZY stored
	ld a, d ;passed 1 if demo, 0 if level
	call SetupTunnelScene
	rl c ;save carry flag
	pop hl ;restore the coords
	ld a, l
	ldh [$FFAA], a
	ldh [hYPosLow], a
	ld a, h
	ldh [$FFAB], a
	ldh [hYPosHi], a
	pop hl
	ld a, l
	ldh [$FFA8], a
	ldh [hZPosLow], a
	ld a, h
	ldh [$FFA9], a
	ldh [hZPosHi], a
	pop hl
	ld a, l
	ldh [$FFAC], a
	ldh [hXPosLow], a
	ld a, h
	ldh [$FFAD], a
	ldh [hXPosHi], a
	rr c ;restore carry flag
	ccf ;and flip it
	ret
	
SetupTunnelScene: ;31D7
	;sets up tunnel scene? passed a is 1 if demo, 0 if level
	push af
	call CallDisableLCD
	pop af
	or a
	jp nz, .skiptilemapload ;skip these if demo
	ld a, $07
	ldh [hLoadedBank], a
	ld [$2106], a
	ld bc, $009F ;base tile
	ld de, $0001 ;offset
	ld hl, tilesetMainInterface
	call LoadTileMap
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	call Refresh3DWindow
.skiptilemapload ;31FD
	ld a, $02
	ldh [hGameState], a
	call CallClear3DBG
	call CallClearAllTunnelEnts
	call ClearWRAM
	call CallLoadGameplayGUIgfx
	ld a, spdTUNNEL
	ldh [hSpeedTier], a ;tunnel?
	call CallDrawCompass
	call CallSetAlertTiles
	call CallEmpty1022D
	call CallDrawRadarBG
	call CallDrawFuel
	call CallDrawMissileCount
	call CallSetCompassTiles
	call CallDrawTimer
	ld hl, $99CE ;vram
	call CallDrawMinimap
	ld a, [wInventory1]
	call CallPrintInterfaceString
	call CallLoadTunnelHealthGFX
	ld a, $08
	ldh [rSCX], a
	xor a
	ldh [rSCY], a
	ld [wTargetSCY], a
	ld [wScrollYFlag], a
	ld a, $60
	ldh [rLYC], a ;scanline $60
	ld a, (1 << rSTAT_LYC) ;enable coincidence interrupt
	ldh [rSTAT], a
	ld a, [wInventory]
	dec a
	ld [$CAE7], a ;just past the end of inventory
	ld a, [wInventory1]
	dec a
	ld [$CAE8], a
	ld a, [$CAE3]
	dec a
	ld [$CAE9], a
	call CallDrawHalf3D ;clears out tile data
	call CallDrawHalf3D ;can remove this safely
	xor a
	ldh [rIF], a
	ld a, (1 << VBLANK) | (1<<LCD_STAT) ;interrupt flags
	ldh [rIE], a
	loadpalette 2, 3, 1, 0
	ldh [rBGP], a
	loadpalette 1, 2, 3, 0
	ldh [rOBP0], a
	loadpalette 1, 2, 3, 0
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld a, [wTunnelIntroTimer]
	or a
	jr nz, .continuesetup ;skip if intro timer isn't 0; this can happen if rawtunnelsetup is called
	ld a, [wCurLevel]
	cp LEVEL_ESCAPE
	scf
	jr z, .continuesetup ;if level is 28, skip return check
	and a
	scf
	ret nz ;return if level isn't zero
.continuesetup
	xor a
	ldh [hYPosLow], a
	ldh [hYPosHi], a
	ldh [hXPosLow], a
	ldh [hXPosHi], a
	ldh [hZPosLow], a
	ldh [hZPosHi], a
	ldh [hYLoCopy], a
	ldh [hYHiCopy], a
	ldh [hXLoCopy], a
	ldh [hXHiCopy], a
	ldh [hZLoCopy], a
	ldh [hZHiCopy], a
	ld [$D397], a
	ld [$CAAE], a
	ld [$CAAF], a
	ld [$CAB4], a
	ld [$CAB6], a
	ldh [hViewAngle], a
	ld [$CA88], a
	ld a, $02
	ld [wFarTunnelHeight], a
	ld a, $03
	ld [wFarTunnelWidth], a
	ld b, $08 ;set loop counter
	ld hl, wTunnelDataPointer ;pointer to tunnel?
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $09
	ldh [hLoadedBank], a ;load bank 9?
	ld [$2108], a
	ld a, [hl+]
	ld [$CA85], a
	ld a, [hl+]
	ld [$CA86], a
	ld a, [hl+]
	ld [$CA87], a ;store three bytes from table in bank nine at [CA85]
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a ;back to bank 1
	xor a
	ld [$CAF0], a
	ld [$CAEF], a
	ld [$CAF1], a
.loop ;looped eight times
	push bc
	call ReadTunnelDataEntry ;hl is past the three bytes in the table
	pop bc
	dec b
	jr nz, .loop
	ld a, l
	ld [wTunnelPointerLo], a
	ld a, h
	ld [wTunnelPointerHi], a ;save our read position
	xor a
	ldh [hZPosHi], a
	ldh [hZPosLow], a
	ld [$CACF], a
	ld [$CB19], a
	ld [$CB1A], a
	ld [wCrosshairXOffset], a
	ld [wCrosshairYOffset], a
	ld [wAimPitch], a
	ld [$CB19], a
	ld [$CB47], a
	ld [$C29A], a
	call ClearAllScreenText
	ld a, $FF
	ld [wTunnelLightState], a
	ld a, [wTutProgress]
	cp $0B
	jr nz, .donetutcheck
	ld a, $0C
	ld [wTutProgress], a
.donetutcheck
	xor a
	ldh [hPauseFlag], a
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	ld a, [wTutProgress]
	cp $0C
	call z, CallInterpretScriptTut
	call CallRefreshBGTiles
	ld a, [wTunnelDemoMode]
	or a
	jr nz, .fillhealth
	ld a, [$C284]
	or a
	jr z, .branchmerge
.fillhealth
	ld a, $08
	ld [wHealth], a ;refill
.branchmerge
	ld a, [$C2DB]
	or a
	jp z, .donewithbombstuff
	ld a, [wTunnelBombSet]
	or a
	jp z, .bombnotset
	call CallDrawBomb
	call CallUpdateTimer
	call CallDrawTimer
	ld a, [wTimerFramesLo]
	ld c, a
	ld a, [wTimerFramesHi]
	or c
	jr nz, .bombnotset
	ld hl, intTextTunnelDestroyed ;ran out of time
	jp DrawEnglishTextToGame ;rip
.bombnotset
	ld a, [wCurLevel] ;level progress
	cp $10
	jr nz, .donewithbombstuff ;check level four?
	ld a, [$C2DB]
	or a
	jr z, .donewithbombstuff ;this check's redundant?
	ld a, [wInventory1]
	cp $1A ;check equipped item (BOMB?)
	jr nz, .donewithbombstuff
	ld hl, $D35B
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, h
	cp $1E
	jr c, .bombshaftbuttoncheck
	push hl
	call CallDrawEntryArrow
	ld a, [wUpdateCounter]
	and $0F
	jr nz, .dontplayentryarrowsound
	ld a, $02
	ld [wQueueSFX], a
.dontplayentryarrowsound
	pop hl
.bombshaftbuttoncheck
	ld a, [wCurrentInput]
	bit 1, a ;B button
	jr z, .donewithbombstuff
	ld a, WEAPON_NONE
	ld [wEquippedWeapon], a
	ld a, h
	cp $1E
	ld bc, $0300
	jr nc, .dropbomb
	ld hl, intTextNotDeep
	jp DrawEnglishTextToGame
.dropbomb
	ld a, c
	ld [wTimerFramesLo], a
	ld a, b
	ld [wTimerFramesHi], a ;set timer to 3:00
	xor a
	ld [wInventory1], a ;clear inventory?
	call CallPrintInterfaceString
	ld a, $01
	ld [wTunnelBombSet], a
	ld [wTimerEnableFlag], a
	ld a, $0A
	ld [$C2DD], a ;?
	ld a, $21
	ld [wQueueSFX], a
.donewithbombstuff
	call CallDrawHealthBar
	ld a, [wTunnelIntroTimer] ;take the intro timer...
	sub $20
	jr nc, .donelowering
	sla a
	sla a
	sla a ;a*8
	ldh [hZLoCopy], a
	ld a, $FF
	ldh [hZHiCopy], a ;and use it to lower VIXIV into place.
	xor a
	ld [$CAA7], a ;zero out the pitch
.donelowering
	ld a, [$CAA5] ;?
	or a
	jp z, .emptyjump
.emptyjump
	jr .setpositions ;to 3421
;3413
	db "TIMER EXPIRED", 00
.setpositions ;3421
	ldh a, [hXLoCopy]
	ldh [hXPosLow], a
	ldh a, [hXHiCopy]
	ldh [hXPosHi], a
	ldh a, [hYLoCopy]
	ldh [hYPosLow], a
	ldh a, [hYHiCopy]
	ldh [hYPosHi], a
	ldh a, [hZLoCopy]
	ldh [hZPosLow], a
	ldh a, [hZHiCopy]
	ldh [hZPosHi], a
	ldh a, [hViewAngle]
	ld [wViewDir], a
	ld a, [wPitchLurch]
	ld [wPitchAngle], a
.checknextsegment ;3444, looped to from below
	ldh a, [hYPosHi]
	add a, $01
	ld c, a ;yposhi into C
	ld hl, wTunnelDataPointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load pointer at CAC5 into HL
	ldh a, [hLoadedBank]
	push af
	ld a, $09
	ldh [hLoadedBank], a
	ld [$2108], a
	ld a, [hl] ;load byte from bank 9
	or a
	jp nz, UpdateTunnelPosition ;jump if retrieved byte not zero
	;otherwise, 00 means end of tunnel data?
	pop af
	call LoadBankInA
	xor a
	ld [$CAAE], a
	ld [$CAAF], a
	ld a, [$CAA5]
	or a
	jp nz, .ret
	jp .ret
.ret ;3473
	and a
	ret
	
;3475
	db "BONUS", 00
;347B
	db "10 X TIMER", 00
tunGetReadyText: ;3486
	db "GET READY", 00
tunGoGoGoText: ;3490
	db "GO GO GO", 00

UpdateTunnelPosition: ;3499, where i left off
	pop af
	call LoadBankInA ;restore the bank
	ld a, [wTunnelSeg1Distance]
	sub a, c ;next y - our y pos
	cp $80 ;if we're past it,
	jr c, .handlenextsegment ;jump to $E
	ld a, [wTunnelDemoMode]
	or a
	jr nz, .skipcollisions ;if demo enabled, jump ahead
	call CallCheckTunnelEntitiesCollision
	jr c, .handlenextsegment ;jump if we hit something
.skipcollisions
	call ReadTunnelDataEntry
	ld a, l
	ld [wTunnelPointerLo], a
	ld a, h
	ld [wTunnelPointerHi], a ;backup our read position
	jp SetupTunnelScene.checknextsegment ;go back to tunnel updating
	
.handlenextsegment
	ld a, [wTunnelSeg1WidthLo]
	sub $C8
	ld c, a
	ld a, [wTunnelSeg1WidthHi] ;59/5A is tunnel width
	sbc a, $00
	ld b, a ;bc is now that value (width - $00C8)
	sra b
	rr c ;divide it by two?
	ld a, [wTunnelSeg1RotLo]
	ld e, a
	add a, c
	ld l, a
	ld a, [wTunnelSeg1RotHi]
	ld d, a
	adc a, b
	ld h, a ;de is the word at 5D/5E (global rotation?), and HL is the rotation plus the width
	ld a, [wTunnelDemoMode]
	or a
	jr z, .doneautopilot ;if not in demo, skip past the autopilot
	;below this is the autopilot
	ld a, e
	ldh [hXLoCopy], a
	ld a, d
	ldh [hXHiCopy], a ;match our X to our rotated offset
	xor a
	ldh [hZLoCopy], a
	ldh [hZHiCopy], a ;reset Z position
	ldh [hZPosLow], a
	ldh [hZPosHi], a
	push hl
	push de
	push bc ;save those values retrieved from wram
	ld a, [wTunnelSeg1RotHi + TUNNEL_SEGMENT_SIZE * 2]
	sra a
	ld a, [wTunnelSeg1RotLo + TUNNEL_SEGMENT_SIZE * 2] ;is this the tunnel segment (local) direction?
	rra
	ld e, a
	and $FE ;mask off the low bit
	add a, $80 ;not sure what this accomplishes
	ld e, a ;save our result
	ldh a, [hViewAngle]
	add a, $80
	cp e
	jr z, .skipVASave ;if they are equal, jump ahead 8
	jr nc, .noturnright
	add a, $04 ;turn right
.noturnright
	sub $82 ;turn left
	ldh [hViewAngle], a
.skipVASave
	pop bc
	pop de
	pop hl
	ld a, [wCurrentInput]
	or a
	ret nz ;return if there was input (skip demo mode)
.doneautopilot
	ldh a, [hXPosLow]
	sub a, l
	ld [$C33B], a
	ldh a, [hXPosHi]
	sbc a, h
	ld [$C33C], a ;update these, xpos - hl (tunnel side edge?)
	cp $80
	jr nc, .checkotherwall ;if negative, jump ahead
	ld a, l
	sub $14
	ldh [hXLoCopy], a
	ld a, h
	sbc a, $00
	ldh [hXHiCopy], a ;bump away from the side
	ld a, [$C33C]
	or a
	jr nz, .damageright ;if hi difference is nonzero, go ahead
	ld a, [$C33B]
	cp $32
	jr c, .correctleft ;if low difference is less than $32, go ahead?
.damageright
	;oops, right side doesn't damage you!
.correctleft
	ldh a, [hViewAngle]
	sub $0C
	ldh [hViewAngle], a ;turn left?
	ld a, [wLurchTarget]
	sra a ;divide by 2
	ld [wLurchTarget], a
.checkotherwall
	ld a, e
	sub a, c
	ld l, a
	ld a, d
	sbc a, b
	ld h, a ;hl is now de - bc (other wall side)
	ldh a, [hXPosLow]
	sub a, l
	ld [$C33B], a
	ldh a, [hXPosHi]
	sbc a, h
	ld [$C33C], a ;difference into 3B/3C again
	cp $80
	jr c, .donecheckingsides ;if positive, jump ahead
	ld a, l
	add a, $14
	ldh [hXLoCopy], a
	ld a, h
	adc a, $00
	ldh [hXHiCopy], a ;bump away from the wall
	ld a, [$C33C]
	inc a
	jr nz, .damageleft ;if difference greater than zero, jump ahead
	ld a, [$C33B]
	cp $CE
	jr nc, .correctright ;if low difference less than $32, jump ahead
.damageleft
	ld a, [wHealth]
	dec a
	ld [wHealth], a
	ld a, $06
	ld [wQueueSFX], a ;ouch!
.correctright
	ldh a, [hViewAngle]
	add a, $0C
	ldh [hViewAngle], a ;turn right
	ld a, [wLurchTarget]
	sra a ;divide by 2
	ld [wLurchTarget], a
.donecheckingsides
	call RenderTunnelEdges
	call DrawTunnelRects
	call CallDrawTunnelEntities
	call CallDrawSpeedDisplay
	ld a, [wTunnelLightState]
	ld c, a
	ld a, [wTunnelIntroTimer]
	cp $78
	jp nc, .donecheckingcountdown ;if timer's at $80 or longer, skip the intro stuff
	add a, $02
	ld [wTunnelIntroTimer], a
	cp $40
	jr c, .doneprintingtext ;if below $40 frames, skip
	push af
	ld hl, tunGetReadyText ;if below $70 frames, print this
	cp $70
	jr c, .printtext
	ld hl, tunGoGoGoText ;else print this'n
.printtext
	push bc
	ld bc, $0304 ;position
	call CallCopyEnglishStringToWRAM
	pop bc
	pop af
.doneprintingtext
	sub $40
	jp nc, .docountdown ;if timer is >= $40, jump
	xor a
	ldh [hYLoCopy], a
	ldh [hYHiCopy], a ;zero these out
	ld [wLurchTarget], a ;zero this out
	jp .donecheckingcountdown
	
.docountdown ;35D9
	rrca ;range going into this is $00 - $40
	rrca
	rrca ;shift left three, range is now $00 - $08
	and $06 ;mask to keep the middle two bits
	ld [wTunnelLightState], a ;save it, new address
	cp c ;compare to old CB17
	jp z, .donebeeping ;if light progress is the same, skip
	push af
	ld a, $02
	ld [wQueueSFX], a ;play sound 2. is this the beep?
	pop af
.donebeeping ;35EC
	push af ;save timer
	cp $06
	jr z, .copylightgraphic ;if middle two bits both on, jump
	push af
	xor a
	ldh [hYLoCopy], a
	ldh [hYHiCopy], a ;zero out y pos
	ld [wLurchTarget], a ;wipe the timer??
	pop af
.copylightgraphic
	add a, LOW(TunnelLightsTable)
	ld l, a
	ld a, $00
	adc a, HIGH(TunnelLightsTable)
	ld h, a ;modified timer is now an offset into the table
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is now a pointer from that table
	ld de, wMonoBufferColumn6 + 8
	ld a, BANK(TunnelLightGFX1) ;bank 3!
	ldh [hLoadedBank], a
	ld [$2102], a
	ld b, $06
.outerloop
	ld c, $08
.innerloop
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	dec c
	jr nz, .innerloop ;moved two bytes over, total of eight bytepairs per outerloop
	ld a, e
	sub $10
	ld e, a
	inc d
	dec b
	jr nz, .outerloop
	ld a, $01
	ldh [hLoadedBank], a ;restore our old bank
	ld [$2100], a
	pop af ;our masked timer
	rrca ;move the two bits to the bottom
	cpl
	inc a ;negate
	add a, $03 ;okay what
	call CallDrawCountdownDigit
.donecheckingcountdown ;3635
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ld a, [wHealth]
	jr nz, .normalhealthcheck ;if not tutorial, skip
	or a
	ret z ;return if zero health in tutorial?
	rla
	jr nc, TunnelVerticalMovement ;if not negative, jump
	xor a
	ld [wHealth], a ;else reset to empty. you cannot die in the tutorial.
.normalhealthcheck
	rla
	jr nc, TunnelVerticalMovement ;if not negative, jump
	ld hl, intTextShieldDestroyed
	;falls into
DrawEnglishTextToGame: ;364E
	ld bc, $0500
	call CallCopyEnglishStringToWRAM
	ld a, $05
	ld [wQueueMusic], a
	call CallDrawHalf3D
	ld d, $00
	call WaitFrames
	ld a, $01
	ld [wGameOverTimer], a
	scf
	ret
	
intTextShieldDestroyed: ;3668
db "SHIELD DESTROYED", 00
intTextNotDeep: ;3679
db "NOT DEEP ENOUGH", 00
intTextTunnelDestroyed: ;3689
db "TUNNEL DESTROYED", 00

TunnelVerticalMovement: ;369A
	;a continuation of the tunnel check code
	ld a, [wTunnelIntroTimer]
	cp $6F
	jp c, .handleangle
	ld a, [wCurrentInput]
	ld d, a ;backup inputs to D
	cpl
	and INPUT_RESET
	jp z, Reset
	ld a, [wFlightPitch]
	add a, $80
	ld e, a
	
	bit INPUT_DOWN, d ;dunno why INPUT_DOWN doesn't work here
	jr z, .checkup
	ld a, e
	cp $10
	jr c, .checkup
	sub $10
	ld e, a ;if e > 10, e -= 10
.checkup
	bit 6, d ;INPUT_UP
	jr z, .savenewangle
	ld a, e
	cp $F0
	jr nc, .savenewangle
	add a, $10
	ld e, a ;if e < F0, e += 10
.savenewangle
	ld a, e
	sub $80
	ld [wFlightPitch], a
.handleangle ;36D0
	ld a, [wFlightPitch]
	cpl
	inc a ;negate it
	sra a
	cp $80
	sbc a, $FF
	sra a
	cp $80
	sbc a, $FF
	sra a
	cp $80
	sbc a, $FF
	add a, $34
	ld [wPitchAngle], a
	ld [wPitchLurch], a
	ld [wPitchAngleR], a
	ld hl, wTunnelSeg1Height
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load the height
	sra h
	rr l
	ld a, l
	sub $40
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;hl is height / 2 - $40
	ld a, [wFlightPitch]
	ld e, a ;E is now our vert angle
	ld a, [wTunnelIntroTimer]
	cp $78
	jp c, .checktopbump ;if still in the countdown, jump ahead
	ldh a, [hZLoCopy]
	ld c, a
	ldh a, [hZHiCopy]
	ld b, a
	ld a, c
	sub a, l
	ld c, a
	ld a, b
	sbc a, h
	ld b, a ;subtract the tunnel height from our Z, can this be optimized?
	rlca
	jr c, .testtop ;if negative, jump ahead
	bit 7, e
	jr nz, .donegravity ;if vert angle negative, skip
	ld a, e
	cpl
	add a, $02 ;else negate it and add 1
	sra a
	sra a ;divide by four
	ld e, a ;and update it
.donegravity
	ld a, l
	ldh [hZLoCopy], a
	ld a, h
	ldh [hZHiCopy], a ;update our position??
	ld a, b
	or a
	jr nz, .damagebottom
	ld a, c
	cp $32
	jr c, .skiptopbump
.damagebottom
	ld a, [wHealth]
	dec a
	ld [wHealth], a
	ld a, $06 ;ouch!
	ld [wQueueSFX], a
.skiptopbump
	jr .checktopbump ;to 3758
	
.testtop
	or c
	jr z, .checktopbump ;if Z position is 0000, jump to 3758
	ld a, e
	cp $80
	jr nc, .pitchdown ;if angle negative, jump
	cp $7C
	jr nc, .checktopbump ;if angle steeper than 7C, jump to 3758
.pitchdown
	add a, $04
	ld e, a
.checktopbump ;3758
	ld a, e
	ld [wFlightPitch], a ;save our pitch
	cp $80
	ld a, $FF
	adc a, $00
	ld d, a
	ldh a, [hZLoCopy]
	add a, e
	ldh [hZLoCopy], a
	ldh a, [hZHiCopy]
	adc a, d
	ldh [hZHiCopy], a ;Z += DE
	ld a, [wTunnelSeg1HeightLo]
	sub $40
	ld l, a
	ld a, [wTunnelSeg1HeightHi]
	sbc a, $00
	ld h, a ;load 5B/5C - 0040 into HL
	sra h
	rr l ;divide hl by two
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl ;negate hl
	ldh a, [hZLoCopy]
	sub a, l
	ld c, a
	ldh a, [hZHiCopy]
	sbc a, h
	ld b, a ;Z -= HL
	cp $80
	jr c, .doneallwalls
	ld a, l
	ldh [hZLoCopy], a
	ld a, h
	ldh [hZHiCopy], a ;if Z positive, then Z = HL?
	xor a
	ld [wFlightPitch], a ;and reset pitch?
	ld a, c
	add a, $32
	ld a, b
	adc a, $00 ;if above -32, skip
	jr c, .doneallwalls
	ld hl, wHealth
	dec [hl]
	ld a, $06 ;ouch!
	ld [wQueueSFX], a
.doneallwalls
	xor a
	ld [$C339], a
	ld [$C33A], a
	xor a
	ldh [$FFFD], a
	call CallAddNewMonoTextLine
	ld a, BANK(DrawDemoModeText)
	ldh [hLoadedBank], a
	ld [$210E], a
	ld a, [wTunnelDemoMode]
	or a
	jr z, .donedemo
	call DrawDemoModeText
.donedemo
	ld a, $01
	ldh [hLoadedBank], a
	ld [$2100], a
	ld bc, $0000
	ld d, $57 ;height
	ld e, $7F ;width
	call DrawRect ;thick window border, hides line problems?
	call CallDrawHalf3D
	loadpalette 2, 3, 1, 0
	ldh [hBGP], a
	loadpalette 1, 0, 2, 3
	ldh [hIntP], a
	jp SetupTunnelScene.donetutcheck


DrawTunnelRects: ;37E7
	ld hl, wTunnelFrames
	ld a, $08
.loop
	push af
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	sub a, c
	ld e, a
	ld a, [hl+]
	sub a, b
	ld d, a
	ld a, d
	or a
	jr z, .skipcall
	ld a, e
	or a
	jr z, .skipcall
	call DrawRect
.skipcall
	pop af
	dec a
	jr nz, .loop
	ret


RenderTunnelEdges: ;3807
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a ;reset unknown values
	ld a, $7F
	ldh [$FFF1], a ;3D screen width
	ld a, $57
	ldh [$FFED], a ;3D screen height
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFF0], a
	ldh [$FFEE], a ;set the high bytes of these words all to $80?
	xor a
	ld [$CAAA], a ;unknown pair
	ld [$CAAB], a
	ld hl, wTunnelSegmentData ;scratch area
	ld de, wTunnelFrames ;unknown
	ld a, $08 ;8 loops
.mainloop ;382D, a loop?
	push af ;save counter
	push de ;save tunnel frames pointer
	ld a, [hl+] ;read from scratch
	ld [$C33B], a ;distance?
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;BC is width
	ld a, [hl+]
	ld e, a
	ld a, [hl+] ;read five values to a, e, b, c, wram
	push hl ;save read position
	ld l, e
	ld h, a ;HL is height
	ld a, [$C33B]
	ld d, a ;first read value's now in d
	ldh a, [hYPosLow]
	cpl
	add a, $01
	ld e, a ;e is now our negative Y
	ldh a, [hYPosHi]
	cpl
	adc a, $00
	add a, d
	ld d, a ;DE is now negative Ypos, plus distance to next segment?
	bit 7, d ;check the topmost bit
	jr z, .skipclear
	ld de, $0000 ;if bit set, wipe DE
.skipclear
	push de ;save depth
	call PrepScaleXYByDistance
	pop de ;restore so we can use it again
	sra b
	rr c
	push bc ;save bc, shifted right 1 (width)
	sra h
	rr l
	push hl ;save hl, shifted right 1 (height)
	ldh a, [hXPosLow]
	cpl
	ld c, a
	ldh a, [hXPosHi]
	cpl
	ld b, a
	inc bc ;negate xpos, save into bc
	ldh a, [hZPosLow]
	cpl
	ld l, a
	ldh a, [hZPosHi]
	cpl
	ld h, a
	inc hl ;negate zpos, save into hl
	call PrepScaleXYByDistance
	ld a, c
	ldh [$FFF5], a
	ld a, b
	ldh [$FFF6], a
	ld a, l
	ldh [$FFF7], a
	ld a, h
	ldh [$FFF8], a ;backup the results of our transformed XZ
	pop de ;z
	pop bc ;x
	pop hl ;position
	push hl
	push bc
	push de ;restore values and save them again
	ldh a, [$FFF5]
	add a, c
	ld c, a
	ldh a, [$FFF6]
	adc a, b
	ld b, a ;bc = our X + frame X
	ldh a, [$FFF7]
	add a, e
	ld e, a
	ldh a, [$FFF8]
	adc a, d
	ld d, a ;de = our Z + frame Z
	ld a, [hl+]
	add a, c
	ldh [$FFF9], a
	ld a, [hl+]
	adc a, b
	ldh [$FFFA], a ;F9/FA = read word + new X
	ld a, [hl+]
	add a, e
	ldh [$FFFB], a
	ld a, [hl+]
	adc a, d
	ldh [$FFFC], a ;FB/FC = read word + new Z
	pop de
	pop bc ;restore frame X and Z again
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a ;negate bc (frame X)
	ld a, e
	cpl
	add a, $01
	ld e, a
	ld a, d
	cpl
	adc a, $00
	ld d, a ;negate de (frame Y)
	ldh a, [$FFF5]
	add a, c
	ld c, a
	ldh a, [$FFF6]
	adc a, b
	ld b, a ;bc = our X + negated frame X
	ldh a, [$FFF7]
	add a, e
	ld e, a
	ldh a, [$FFF8]
	adc a, d
	ld d, a ;de = our Z + negated frame Z
	pop hl ;restore position
	ld a, [hl+]
	add a, c
	ldh [$FFF5], a
	ld a, [hl+]
	adc a, b
	ldh [$FFF6], a ;f5/f6 = read word + X val
	ld a, [hl+]
	add a, e
	ldh [$FFF7], a
	ld a, [hl+]
	adc a, d
	ldh [$FFF8], a ;F7/F8 = read word + Z val
	push hl ;save new position
	ld a, [wViewDir]
	cpl
	inc a ;negate
	cp $80
	ld b, $00
	jr c, .skipff
	ld b, $FF ;b is either 0 or -1
.skipff
	sla a
	rl b
	add a, $40
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;bc is now angle times 2 + 40
	ldh a, [$FFF5]
	add a, c
	ldh [$FFC6], a
	ldh a, [$FFF6]
	adc a, b
	ldh [$FFC7], a ;frame top left x + angle
	ldh a, [$FFF9]
	add a, c
	ldh [$FFC2], a
	ldh a, [$FFFA]
	adc a, b
	ldh [$FFC3], a ;frame bottom right x + angle
	ld a, [wPitchAngle]
	ld c, a
	ld b, $00
	ldh a, [$FFF7]
	add a, c
	ldh [$FFC4], a
	ldh a, [$FFF8]
	adc a, b
	ldh [$FFC5], a ;frame top left Z + angle
	ldh a, [$FFFB]
	add a, c
	ldh [$FFC0], a
	ldh a, [$FFFC]
	adc a, b
	ldh [$FFC1], a ;frame bottom right Z + angle
	
	ld a, [$CAAA] ;set to zero at the top, i dunno
	or a
	jp nz, .wipeframe ;if we've already stopped drawing frames, keep skiping them
	ld a, [$CAAB]
	or a
	ld a, $FF
	ld [$CAAB], a
	jp z, .donelines
	ldh a, [$FFC6]
	ldh [$FFF5], a
	ldh a, [$FFC7]
	ldh [$FFF6], a ;frame top left X
	ldh a, [$FFBE]
	ldh [$FFF9], a
	ldh a, [$FFBF]
	ldh [$FFFA], a ;previous frame's top left X
	ldh a, [$FFC4]
	ldh [$FFF7], a
	ldh a, [$FFC5]
	ldh [$FFF8], a ;frame top left Z
	ldh a, [$FFBC]
	ldh [$FFFB], a
	ldh a, [$FFBD]
	ldh [$FFFC], a ;previous frame's top left Z
	call CallProjectLine
	jr c, .line2
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF7]
	ld d, a ;save screen coord to DE
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a ;save screen deltas to BC
	call CallDrawLine ;and draw the line!
.line2
	ldh a, [$FFC2]
	ldh [$FFF5], a
	ldh a, [$FFC3]
	ldh [$FFF6], a ;new new X
	ldh a, [$FFBA]
	ldh [$FFF9], a
	ldh a, [$FFBB]
	ldh [$FFFA], a ;new old X
	ldh a, [$FFC4]
	ldh [$FFF7], a
	ldh a, [$FFC5]
	ldh [$FFF8], a ;old new Z
	ldh a, [$FFBC]
	ldh [$FFFB], a
	ldh a, [$FFBD]
	ldh [$FFFC], a ;new old Z
	call CallProjectLine
	jr c, .line3
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF7]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a ;load BCDE with results
	call CallDrawLine
.line3
	ldh a, [$FFC6]
	ldh [$FFF5], a
	ldh a, [$FFC7]
	ldh [$FFF6], a ;old new X
	ldh a, [$FFBE]
	ldh [$FFF9], a
	ldh a, [$FFBF]
	ldh [$FFFA], a ;new old X
	ldh a, [$FFC0]
	ldh [$FFF7], a
	ldh a, [$FFC1]
	ldh [$FFF8], a
	ldh a, [$FFB8]
	ldh [$FFFB], a
	ldh a, [$FFB9]
	ldh [$FFFC], a
	call CallProjectLine
	jr c, .line4
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF7]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a
	call CallDrawLine
.line4
	ldh a, [$FFC2]
	ldh [$FFF5], a
	ldh a, [$FFC3]
	ldh [$FFF6], a
	ldh a, [$FFBA]
	ldh [$FFF9], a
	ldh a, [$FFBB]
	ldh [$FFFA], a
	ldh a, [$FFC0]
	ldh [$FFF7], a
	ldh a, [$FFC1]
	ldh [$FFF8], a
	ldh a, [$FFB8]
	ldh [$FFFB], a
	ldh a, [$FFB9]
	ldh [$FFFC], a
	call CallProjectLine
	jr c, .donelines
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF7]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFB]
	sub a, d
	ld b, a
	call CallDrawLine
.donelines ;3A14
	ldh a, [$FFC6]
	ldh [$FFBE], a
	ldh a, [$FFC7]
	ldh [$FFBF], a ;top left X to backup
	ldh a, [$FFC4]
	ldh [$FFBC], a
	ldh a, [$FFC5]
	ldh [$FFBD], a
	ldh a, [$FFC2]
	ldh [$FFBA], a
	ldh a, [$FFC3]
	ldh [$FFBB], a
	ldh a, [$FFC0]
	ldh [$FFB8], a
	ldh a, [$FFC1]
	ldh [$FFB9], a
	call ComparePointersToC0C8Region ;clipping
	jr nc, .saveframe
.wipeframe ;3A39
	xor a
	ldh [$FFC6], a
	ldh [$FFC4], a
	xor a
	ldh [$FFC2], a
	ldh [$FFC0], a
	ld a, $FF
	ld [$CAAA], a
.saveframe
	pop hl
	pop de ;restore frames position
	ldh a, [$FFC6]
	ld [de], a
	inc de
	ldh [$FFF3], a
	ldh a, [$FFC4]
	ld [de], a
	inc de
	ldh [$FFEF], a
	ldh a, [$FFC2]
	ld [de], a
	inc de
	ldh [$FFF1], a
	ldh a, [$FFC0]
	ld [de], a
	inc de ;frames now written to
	ldh [$FFED], a
	pop af
	dec a
	jp nz, .mainloop
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $7F
	ldh [$FFF1], a
	ld a, $57
	ldh [$FFED], a
	ret


LoadNextTunnelSegment: ;3A75, called by tunnel data reader
	ld hl, wTunnelSeg1Distance + TUNNEL_SEGMENT_SIZE
	ld de, wTunnelSeg1Distance
	ld bc, $003F
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop ;transfer from HL to DE
	call CallMoveTunnelEntsCloser
	ld hl, wTunnelSeg1Distance + TUNNEL_SEGMENT_SIZE * 7 ;start of the farthest segment data
	ld a, [wTunnelSeg1Distance + TUNNEL_SEGMENT_SIZE * 6] ;penultimate segment distance
	ld c, a
	ld a, [$CAC2] ;load a read value?
	add a, c
	ld [hl+], a
	ldh a, [$FFF5]
	ld [hl+], a
	ldh a, [$FFF6]
	ld [hl+], a
	ldh a, [$FFF7]
	ld [hl+], a
	ldh a, [$FFF8]
	ld [hl+], a
	ldh a, [$FFF9]
	ld [hl+], a
	ldh a, [$FFFA]
	ld [hl+], a
	ldh a, [$FFFB]
	ld [hl+], a
	ldh a, [$FFFC]
	ld [hl+], a ;write a whole lot to D397
	ret


DrawVerticalLine: ;3AAE
	;BC is position, E is length
	push bc
	push de
	push hl ;save everything passed
	ld a, c
	and $F8 ;mask to the top five bits
	rrca
	rrca
	rrca
	add a, $D0
	ld h, a ;passed c (modified) is higher here
	ld l, b ;b is lower here
	ld b, e ;passed e is our counter
	ld d, $00
	ld a, c 
	and $07
	ld e, a
	ld a, [de] ;grab from $000X where X is passed c & 7
	ld e, a
.loop
	ld a, e
	or [hl]
	ld [hl+], a ;mask the byte at [hl] with our grabbed byte
	dec b
	jr nz, .loop
	pop hl
	pop de
	pop bc
	ret
	
DrawHorizontalLine: ;3ACE
	;BC is position, E is length
	push bc
	push de
	push hl ;save these
	ld a, c
	and $F8
	rrca
	rrca
	rrca
	add a, $D0
	ld h, a ;modified passed c is the high address of HL
	ld l, b ;passed b is L
	ld a, c
	and $F8
	rrca
	rrca
	rrca
	inc a
	ld d, a ;modified passed c is loaded into d
	ld a, e
	add a, c
	ld b, a ;b is now passed e + passed c
	and $F8
	rrca
	rrca
	rrca
	sub a, d
	ld d, a ;d is now modified passed c - d
	ld e, h ;modified pased c (1st) is now e
	jr z, .skip ;if d is currently zero, skip
	cp $80
	jr nc, .skip2 ;if d is currently negative, skip
	ld a, $FF
.writeloop
	inc h
	ld [hl], a ;else write FF into [HL], using d as a counter
	dec d
	jr nz, .writeloop
.skip
	inc h
.skip2
	ld d, c ;passed c is now in d
	ld a, b ;a is now passed e + passed c
	and $07
	add a, LOW(FillFromLeftTable)
	ld c, a ;c is now between B8 and BF
	ld a, HIGH(FillFromLeftTable)
	adc a, $00
	ld b, a ;bc is now 3BB8 - 3BBF
	ld a, [bc] ;load read value into a
	ld c, d
	ld d, a ;save it to d
	ld a, c ;load passed c
	and $07
	add a, LOW(EmptyFromLeftTable)
	ld c, a 
	ld a, HIGH(EmptyFromLeftTable)
	adc a, $00
	ld b, a
	ld a, [bc] ;load value from $3BAF - $3BB6
	ld c, a ;save it to c
	ld a, h
	cp e
	jr nz, .notequal ;if h != e, jump
	ld a, d
	and c ;& our two saved values together
	or [hl]
	ld [hl], a ;and mask [hl] with it
	jr .quit
.notequal
	ld a, d
	or [hl]
	ld [hl], a ;mask our first value with d
	ld h, e
	ld a, c
	or [hl]
	ld [hl], a ;mask out [EL] value with c
.quit
	pop hl
	pop de
	pop bc
	ret
	
IF UNUSED == 1
DrawHorizontalHalftone: ;3B2D
	;passed C top five bits is the mono column
	;passed B is mono row
	push bc
	push de
	push hl
	ld a, c
	and $F8
	rrca
	rrca
	rrca
	add a, HIGH(wMonoBufferColumn1)
	ld h, a ;CB becomes HL, address into mono buffer?
	ld l, b
	ld a, c
	and $F8
	rrca
	rrca
	rrca
	inc a
	ld d, a ;sh(C)+1 -> D
	ld a, e
	add a, c
	ld b, a ;E+C -> B
	and $F8
	rrca
	rrca
	rrca
	sub a, d 
	ld d, a ;sh(E)-1 -> D
	ld e, h ;SH(C) + $DO -> E
	jr z, DrawHorizontalLine.skip ;if sh(E)-1 == 0, loop
	cp $80
	jr nc, DrawHorizontalLine.skip2
	ld a, $AA ;else write $AA to [HL], using D as the counter?
.loop
	inc h
	ld [hl], a
	dec d
	jr nz, .loop
	inc h
	ld d, c
	ld a, b
	and $07
	add a, LOW(FillFromLeftTable)
	ld c, a
	ld a, HIGH(FillFromLeftTable)
	adc a, $00
	ld b, a
	ld a, [bc]
	ld c, d
	ld d, a
	ld a, $AA
	and d
	ld d, a
	ld a, c
	and $07
	add a, LOW(EmptyFromLeftTable)
	ld c, a
	ld a, HIGH(EmptyFromLeftTable)
	adc a, $00
	ld b, a
	ld a, [bc]
	ld c, a
	ld a, $AA
	and c
	ld c, a
	ld a, h
	cp e
	jr nz, .notequal
	ld a, d
	and c
	or [hl]
	ld [hl], a
	jr .end
.notequal ;6
	ld a, d
	or [hl]
	ld [hl], a
	ld h, e
	ld a, c
	or [hl]
	ld [hl], a
.end ;7
	pop hl
	pop de
	pop bc
	ret
ENDC

DrawRect: ;3B94
	call DrawHorizontalLine
	ld a, e
	ld e, d
	ld d, a
	call DrawVerticalLine
	ld a, c
	add a, d
	ld c, a
	call DrawVerticalLine
	ld a, c
	sub a, d
	ld c, a
	ld a, b
	add a, e
	ld b, a
	ld e, d
	inc e
	call DrawHorizontalLine
	ret

EmptyFromLeftTable: ;3BAF - 3BB7 is a mask table
	db %11111111, %01111111, %00111111, %00011111, %00001111, %00000111, %00000011, %00000001, %00000000
FillFromLeftTable: ;3BB8 - 3BC0 is a mask table
	db %00000000, %10000000, %11000000, %11100000, %11110000, %11111000, %11111100, %11111110, %11111111

ComparePointersToC0C8Region: ;3BC1
	;clear flag is set when the subtractions fail?
	ld hl, $FFF3
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is value at FFF3/FFF4
	ldh a, [$FFC6]
	sub a, l
	ldh a, [$FFC7]
	sbc a, h ;check if C6/C7 is more[??] than pointed value?
	cp $80
	jr nc, .skipsave1
	ld a, l
	ldh [$FFC6], a
	ld a, h
	sub $80
	ldh [$FFC7], a ;if not, save pointer - $8000 to C6/C7
.skipsave1
	ldh a, [$FFC2]
	ld e, a
	sub a, l
	ldh a, [$FFC3]
	ld d, a ;DE is now C2/C3
	sbc a, h
	cp $80
	jp c, .carryret ;if C2/C3 is less[??] than pointed value, return with carry flag set
	ld hl, $FFF1
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load new pointed word into HL
	ld a, e
	sub a, l
	ld a, d
	sbc a, h
	cp $80
	jr c, .skipsave2 ;do the same check with C2/C3
	ld a, l
	ldh [$FFC2], a
	ld a, h
	sub $80
	ldh [$FFC3], a
.skipsave2
	ldh a, [$FFC6]
	sub a, l
	ldh a, [$FFC7]
	sbc a, h
	cp $80
	jp nc, .carryret
	ld hl, $FFEF
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;new pointed word into HL
	ldh a, [$FFC4]
	sub a, l
	ldh a, [$FFC5]
	sbc a, h
	cp $80
	jr nc, .skipsave3
	ld a, l
	ldh [$FFC4], a
	ld a, h
	sub $80
	ldh [$FFC5], a
.skipsave3
	ldh a, [$FFC0]
	ld e, a
	sub a, l
	ldh a, [$FFC1]
	ld d, a ;DE is now C0/C1
	sbc a, h
	cp $80
	jp c, .carryret
	ld hl, $FFED
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;new pointed word into HL
	ld a, e
	sub a, l
	ld a, d
	sbc a, h
	cp $80
	jr c, .skipsave4
	ld a, l
	ldh [$FFC0], a
	ld a, h
	sub $80
	ldh [$FFC1], a
.skipsave4
	ldh a, [$FFC4]
	sub a, l
	ldh a, [$FFC5]
	sbc a, h
	cp $80
	jp nc, .carryret
	xor a
	ret
.carryret ;3C4F
	scf
	ret

HandleTunnelInputs: ;3C51
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wTunnelTurnSpeed] ;left-right
	ld e, a
	ld a, [wTunnelDemoMode]
	or a
	jr z, .horizangle ;if not demo, skip
	ld d, $00 ;blank out inputs
	ld a, $20
	ld [wLurchTarget], a ;set angle
.horizangle
	ld a, [wTunnelIntroTimer]
	cp $78 ;are we still in the intro?
	jp c, .vertangle ;if yes, jump ahead
	bit INPUT_LEFT, d
	jr z, .checkRight ;if not pressed, skip
	ld a, e
	cp $08 ;right bound
	jr c, .turnLeft
	cp $F8 ;left bound
	jr c, .checkRight ;check caps
.turnLeft
	sub $02
	ld e, a
.checkRight ;done with left input
	bit INPUT_RIGHT, d
	jr z, .slowTurn
	ld a, e
	cp $F8 ;left bound
	jr nc, .turnRight
	cp $08 ;right bound
	jr nc, .slowTurn
.turnRight
	add a, $02
	ld e, a
.slowTurn ;done with right input, now we move the turn speed towards zero
	ld a, e
	or a
	jr z, .saveNewTurnSpeed
	rla
	jr c, .pos
	dec e
	jr .saveNewTurnSpeed
.pos
	inc e
.saveNewTurnSpeed
	ld a, e
	ld [wTunnelTurnSpeed], a
	ld a, e
	cp $80
	ccf
	adc a, $00
	sra a
	cp $80
	ccf
	adc a, $00
	sra a
	ld e, a ;some math i'm too lazy to figure out atm
	ldh a, [hViewAngle]
	add a, e
	ldh [hViewAngle], a
	
.vertangle ;3CB2
	ld a, spdTUNNEL
	ldh [hSpeedTier], a
	ld a, [wLurchTarget]
	ld e, a
	add a, $80
	cp $A0 ;$20 before the addition
	jr nc, .checkDown ;if less, skip
	add a, $02
	jr c, .checkDown ;if was 7E or 7F, skip?
	sub $80
	ld e, a ;else save a new angle
.checkDown
	bit 7, e ;check sign
	jr nz, .checkUp
	bit INPUT_DOWN, d ;current input still in D
	jr z, .checkUp ;if not pressed, skip
	ld a, e
	add a, $80
	cp $9B ;cap
	jr c, .checkUp
	sub $04 ;amount
	jr c, .checkUp
	sub $80
	ld e, a ;save
.checkUp
	bit INPUT_UP, d
	jr z, .dampenpitch
	ld a, e
	add a, $80
	cp $A5 ;cap
	jr nc, .dampenpitch
	add a, $02 ;amount
	sub $80
	ld e, a ;save
.dampenpitch ;move it towards zero, but gravity will always pull neutral down
	ld a, e
	or a
	jr z, .saveNewPitch
	cp $80
	jr c, .neg
	inc e
	jr .saveNewPitch
.neg
	dec e
.saveNewPitch
	ld a, e
	ld [wLurchTarget], a
	ld a, [$D366] ;x of next tunnel segment?
	sra a
	ld c, a ;divide by two, save to C
	ldh a, [hViewAngle]
	sub a, c
	ld d, a ;d is x - angle? 
	cpl
	or a
	jr z, .clearD ;if difference is FF, jump
	sra d ;divide by two again?
	ld a, d
	cpl
	or a
	jr z, .clearD ;if result is FF now, jump
	sra d ;otherwise, divide by two again and use this value
	jr .updatePos
.clearD
	xor a
	ld d, a
.updatePos
	ld a, d ;modified horiz angle to A (Z angle)
	ld c, e ;vert angle to C (Y)
	ld b, $00 ;0 to B (X)
	call CallRotateCoordByAngle
	ld e, b
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend result b coord into DE
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;extend result c coord into BC
	sla c
	rl b
	sla c
	rl b ;multiply BC by four
	sla e
	rl d
	sla e
	rl d ;multiply DE by four
	ldh a, [hYLoCopy]
	add a, c
	ldh [hYLoCopy], a
	ldh a, [hYHiCopy]
	adc a, b
	ldh [hYHiCopy], a
	ldh a, [hXLoCopy]
	add a, e
	ldh [hXLoCopy], a
	ldh a, [hXHiCopy]
	adc a, d
	ldh [hXHiCopy], a ;add DE to X, BC to Y
	ret

DrawInD100Region: ;3D55
	;uses the results from ComparePointersToC0C8Region
	push bc
	push de
	call MaskD100RegionEmpty
	pop de
	pop bc
	push bc
	push de
	call MaskD100RegionFill
	pop de
	pop bc
	push bc
	push de
	call WriteToD100Region
	pop de ;swap the orders?
	pop bc
	call DrawRect
	ret
	
WriteToD100Region: ;3D6E
	;uses DE as a counter after modifying E
	ld a, c
	add a, $08
	and $F8
	ld l, a
	ld a, c
	add a, e
	and $F8
	sub a, l
	ret c
	ret z ;return if C+8 >= E
	rrca
	rrca
	rrca ;else shift the difference right 3
	ld e, a ;and save it to E
	ld a, c
	rrca
	rrca
	rrca
	and $1F ;and shift original C right 3 as well
	add a, $D1 ;move to the bottom of WRAM area, $D100 onward
	ld h, a ;save it to H for now
	ld l, b ;passed b into L
	bit 0, l
	ld a, [$C2AE] ;?
	jr z, .skipcpl1
	cpl
.skipcpl1
	ld b, a ;load [C2AE] into b, optionally complemented
	ld c, l ;load passed b into c
.outerloop
	push de ;save our DE value??
.innerloop
	ld [hl+], a ;write our accum into our constructed $D100+ region
	cpl ;invert accum for next write
	dec d
	jr nz, .innerloop
	pop de ;restore our de value
	bit 0, d
	jr z, .skipcpl2
	cpl
.skipcpl2
	inc h
	ld l, c
	dec e
	jr nz, .outerloop
	ret
	
MaskD100RegionFill: ;3DA5, where i left off above
	;d used as a counter, uses passed E and C for mask maths?
	ld a, c
	and $F8
	push af ;mask off bottom three bits and save modified C
	ld a, c
	add a, e
	ld c, a ;C += E
	and $F8
	ld e, a ;mask off bottom bits again
	pop af ;restore modified C
	cp e
	ret z ;basically, if C+E&$F8 == C&$F8, return.
	ld a, c
	and $07
	ret z ;if C+E&$7 == 7, return?
	add a, LOW(FillFromLeftTable)
	ld l, a
	ld a, $00
	adc a, HIGH(FillFromLeftTable)
	ld h, a ;HL now is $3BB8 + our 0-6 range
	ld e, [hl] ;load a byte from that table
	ld a, c
	rrca
	rrca
	rrca ;the C+E shifted right three,
	and $1F ;then masked to the remaining original bits (low 5 now)
	add a, HIGH(wMonoBufferColumn1)
	ld h, a ;now use this as an offset into $D000?
	ld l, b ;and passed B as the low part?
	bit 0, l
	ld a, [$C2AE] ;unknown value
	jr z, .nocpl
	cpl
.nocpl
	ld c, a ;load wram value into C
	and e
	ld b, a ;AND it with E, load into B
	ld a, c
	cpl
	and e
	ld c, a ;complement C and AND with E
	ld a, e
	cpl
	ld e, a ;finally, complement E
.loop
	ld a, [hl]
	and e
	or b
	ld [hl+], a ;load value from hl, AND E, OR B and save it back
	ld a, c
	ld c, b
	ld b, a ;swap B and C
	dec d ;and finally decrement
	jp nz, .loop
	ret

MaskD100RegionEmpty: ;3DE7
	push de
	ld a, e
	add a, c
	and $F8
	ld e, a
	ld a, c
	and $F8
	cp e
	pop de
	jr nz, .bigskip
	ld a, c
	and $07
	add a, LOW(EmptyFromLeftTable)
	ld l, a
	ld a, $00
	adc a, HIGH(EmptyFromLeftTable)
	ld h, a
	ld a, [hl]
	push af
	ld a, c
	add a, e
	and $07
	add a, $B8
	ld l, a
	ld a, $00
	adc a, $3B
	ld h, a
	ld e, [hl]
	pop af
	and e
	ld e, a
	jr .smallskip
	
.bigskip ;the 1f jump
	ld a, c
	and $07
	add a, LOW(EmptyFromLeftTable)
	ld l, a
	ld a, $00
	adc a, HIGH(EmptyFromLeftTable)
	ld h, a
	ld e, [hl]
.smallskip ;the 0c jump
	ld a, c
	rrca
	rrca
	rrca
	and $1F
	add a, $D0
	ld h, a
	ld l, b
	bit 0, l
	ld a, [$C2AE]
	jr z, .skipcpl
	cpl
.skipcpl
	ld c, a
	and e
	ld b, a
	ld a, c
	cpl
	and e
	ld c, a
	ld a, e
	cpl
	ld e, a
.loop ;3E3B
	ld a, [hl]
	and e
	or b
	ld [hl+], a
	ld a, c
	ld c, b
	ld b, a
	dec d
	jp nz, .loop
	ret

ReadTunnelDataEntry: ;3E47
	ldh a, [hLoadedBank]
	push af
	ld a, $09
	ldh [hLoadedBank], a
	ld [$2108], a
	call InterpretTunnelEntry ;read bank 9 table entries
	ld a, [$CAF1]
	inc a
	ld [$CAF1], a ;increment CAF1
	push hl ;save our position
	ld a, [$CAAE]
	ldh [$FFF9], a
	ld a, [$CAAF]
	ldh [$FFFA], a ;turn direction
	xor a
	ldh [$FFFB], a
	ldh [$FFFC], a
	ld a, [wFarTunnelWidth]
	ldh [$FFF6], a
	ld a, [wFarTunnelHeight]
	ldh [$FFF8], a
	xor a
	ldh [$FFF5], a
	ldh [$FFF7], a ;F5-FC are written to
	call LoadNextTunnelSegment
	pop hl ;restore our position
	pop af ;restore bank
	call LoadBankInA
	ret
	
InterpretTunnelEntry: ;3E83
	;hl is an offset into a table in bank 9
	ld de, TunnelEntryTable ;pointer table
	ld a, [hl+] ;read a byte to use as word offset, can be 0 - D
	rlca ;mult by 2 
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;DE = pointer to script opcode
	ld bc, InterpretTunnelEntry
	push bc ;save this function on the stack
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a ;load the pointer from the table into bc
	push bc ;put it on the stack
	ret ;jump to bc, with this on the stack
	
tDatTurnLeft: ;3E99
	ld a, [hl+] ;read next byte
	ld e, a
	sra a
	add a, e ;multiply by 1.5
	ld e, a
	ld a, [$CAAE]
	sub a, e
	ld [$CAAE], a
	ld a, [$CAAF]
	sbc a, $00
	ld [$CAAF], a ;AF/AE -= val
	ret
tDatTurnRight: ;3EAF
	ld a, [hl+]
	ld e, a
	sra a
	add a, e ;multiply by 1.5
	ld e, a
	ld a, [$CAAE]
	add a, e
	ld [$CAAE], a
	ld a, [$CAAF]
	adc a, $00
	ld [$CAAF], a ;AF/AE += val
	ret
	
tDatSetLength: ;3EC5
	ld a, [hl+]
	ld [$CAC2], a ;value into CAC2
	pop bc
	ret ;quit the lookup loop
	
tDatStub1: ;3ECB
	ld a, [hl+] ;dummy byte?
	ret
tDatStub2: ;3ECD
	ld a, [hl+]
	ret
tDatStub3: ;3ECF
	ld a, [hl+]
	ret
tDatStub4: ;3ED1
	ld a, [hl+]
	ret
	
tDatEnd: ;3ED3
	dec hl ;byte read was end of list?
	pop bc
	ret ;quit the lookup loop
	
tDatSetWidth: ;3ED6
	ld a, [wFarTunnelWidth]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld [wFarTunnelWidth], a ;next byte into CAB5
	xor a
	ld [$CAC2], a ;0 into CAC2
	pop bc
	ret ;quit the lookup loop
	
tDatSetHeight: ;3EE5
	ld a, [hl+]
	ld [wFarTunnelHeight], a ;next byte into CAB7
	xor a
	ld [$CAC2], a ;0 into CAC2
	pop bc
	ret ;quit the lookup loop
	
tDatSetDimensions: ;3EEF
	ld a, [hl+]
	ld [wFarTunnelWidth], a ;byte into B5
	ld a, [hl+]
	ld [wFarTunnelHeight], a ;byte into B7
	xor a
	ld [$CAC2], a ;0 into C2
	pop bc
	ret ;quit the lookup loop
	
tDatLoadEnt: ;3EFD
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+] ;load bytes into CBEDA
	push hl ;save our position
	push af ;save last byte
	ld a, [hl+]
	push af ;save next byte
	push bc ;save first two
	push de ;save second two
	call GetFinalTunnelEnt ;hl is now D4C4 (distance of final ent)
	pop de
	pop bc
	ld a, $07
	ld [hl+], a ;set distance to seven
	ld a, [$CAAE]
	ld [hl+], a ;low x from this
	ld a, [$CAAF]
	add a, c
	ld [hl+], a ;CAAF + first read byte into high x
	ld a, [$CAB2]
	ld [hl+], a ;low Z from this
	ld a, [$CAB3]
	add a, b
	ld [hl+], a ;CAB3 + second read byte into high z
	ld a, [wTunnelSegmentData + TUNNEL_SEGMENT_SIZE * (TUNNEL_SEGMENT_COUNT - 1)]
	ld [hl+], a ;unknown here?
	xor a
	ld [hl+], a ;wipe this (lo width)
	ld a, e
	ld [hl+], a ;third read value here (high width)
	xor a
	ld [hl+], a ;wipe this (lo height)
	ld a, d
	ld [hl+], a ;fourth read value here (hi height)
	pop af
	ld c, a
	pop af
	ld [hl+], a ;fifth read value here (type)
	ld [hl], c ;sixth/final read byte here (fill pattern)
	pop hl ;restore position
	inc hl ;next!
	ret
	
tDatSpecialJump: ;3F3A
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	ld c, a
	ld a, [$CAA5]
	or a
	ret z ;return if CAA5 is zero
	ld a, [$CAEF]
	inc a
	cp c ;third byte
	jr nc, .storezero ;if CAEF > third byte, reset CAEF
	ld [$CAEF], a ;else, increment it
	ld l, e
	ld h, d ;jump to the first word read
	ld a, $02
	ld [wFarTunnelHeight], a
	ld a, $03
	ld [wFarTunnelWidth], a
	xor a
	ld [$CAAE], a
	ld [$CAAF], a
	ld [$CAF1], a
	ret
.storezero ;3F66
	xor a
	ld [$CAEF], a
	ret
	
tDatConditionalJump: ;3F6B
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	ld c, a
	ld a, [$CAF0]
	inc a
	cp c
	jr nc, .writezero
	ld [$CAF0], a
	ld l, e
	ld h, d
	ret
.writezero ;3F7E
	xor a
	ld [$CAF0], a
	ret
	
TunnelEntryTable: ;3F83
	dw tDatEnd ;0
	dw tDatTurnLeft ;1, turn left by byte
	dw tDatTurnRight ;2, turn right by byte
	dw tDatSetLength ;3, set length to byte and ret
	dw tDatStub1 ;4, stub byte
	dw tDatStub2 ;5, stub byte
	dw tDatStub3 ;6, stub byte
	dw tDatStub4 ;7, stub byte
	dw tDatLoadEnt ;8, loads entity, six bytes
	dw tDatSetWidth ;9, next byte into wFarTunnelWidth, wipe length, ret
	dw tDatSetHeight ;A, next byte into wFarTunnelHeight, wipe length, ret
	dw tDatSetDimensions ;B, load wFarTunnelWidth and then wFarTunnelHeight with the next two bytes, ret
	dw tDatSpecialJump ;C, jump to word if CAEF > third byte and CAA5 != 0. sets other values.
	dw tDatConditionalJump ;D, jump to word if incremented CAF0 > third byte.
	
GetFinalTunnelEnt: ;3F9F
	call CallCollapseTunnelEnts
	ld hl, wTunnelEntities + TUNNEL_ENTITIES_SIZE * (TUNNEL_ENTITIES_COUNT - 1) ;distance of final ent?
	ret
	
TunnelLightsTable: ;3FA6
	dw TunnelLightGFX2 ;bug, change this to 1
	dw TunnelLightGFX2
	dw TunnelLightGFX3
	dw TunnelLightGFX4
TunnelPointerTable: ;3FAE pointer table for tunnel data?
	dw $4069 ;level 1
	dw $4000 
	dw $4000
	dw $4000
	dw $4000
	dw $4000
	dw $4000
	dw $4000
	dw $4000
	dw $4000 ;level 10
	dw $4000 ;escape
	dw $4000 ;tutorial
;bank ends at 3FC6
SECTION "gbctest", ROM0[$3FC6]
;cgbSetup:
;	ld a, $80
;	ldh [rBGPI], a
;	
;	ld a, $DE
;	ldh [rBGPD], a
;	ld a, $7B
;	ldh [rBGPD], a
;	
;	ld a, $CE
;	ldh [rBGPD], a
;	ld a, $39
;	ldh [rBGPD], a
;	
;	ld a, $C6
;	ldh [rBGPD], a
;	ld a, $18
;	ldh [rBGPD], a
;	
;	ld a, $42
;	ldh [rBGPD], a
;	ld a, $08
;	ldh [rBGPD], a
;	
;	ld a, [rKEY1]
;	bit 7, a
;	jr nz, .done 
;	ld a, $01
;	ldh [rKEY1], a
;	stop
;.done
;	ret

INCLUDE "src/bank1.asm"
INCLUDE "src/bank2.asm"
INCLUDE "src/bank3.asm"
INCLUDE "src/bank4.asm"
INCLUDE "src/bank5.asm"
INCLUDE "src/bank6.asm"
INCLUDE "src/bank7.asm"
INCLUDE "src/bank8.asm"
INCLUDE "src/bank9.asm"
INCLUDE "src/banka.asm"
INCLUDE "src/bankb.asm"
INCLUDE "src/bankc.asm"
INCLUDE "src/bankd.asm"
INCLUDE "src/banke.asm"
INCLUDE "src/bankf.asm"

INCLUDE "src/WRAM.asm"
INCLUDE "src/HRAM.asm"