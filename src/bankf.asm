SECTION "F:4000", ROMX[$4000], BANK[$F]
tutRingsOffsets: ;4000
db -10, -1
db   5,  0 
db -30, -1 
db -40, -1 
db  40,  0 
db  20,  0 
db -60, -1
db  60,  0 
db -20, -1 
db -30, -1 
db  30,  0 
db -25, -1 
db  60,  0 
db -30, -1 
db  20,  0 
db -40, -1
db  20,  0

SiloTilemap: ;4022, tilemap
	db $14, $12 ;dimensions
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $03, $00, $00, $00, $04 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $05, $06, $07, $08, $09, $00, $00, $0A 
	db $00, $0B, $0C, $0D, $0E, $0F, $10, $00, $00, $00, $11, $12, $13, $14, $15, $00, $00, $16 
	db $00, $17, $18, $19, $1A, $1B, $1C, $00, $00, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25 
	db $00, $26, $27, $28, $29, $2A, $2B, $00, $00, $2C, $00, $00, $2D, $2E, $2F, $30, $31, $32 
	db $00, $33, $34, $35, $36, $37, $38, $00, $00, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41 
	db $00, $42, $43, $44, $45, $46, $47, $00, $00, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50 
	db $00, $51, $52, $53, $54, $55, $56, $00, $00, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F 
	db $00, $60, $61, $62, $63, $64, $65, $00, $00, $00, $66, $67, $68, $69, $6A, $00, $00, $6B 
	db $00, $6C, $6D, $6E, $6F, $70, $71, $00, $00, $72, $73, $74, $75, $76, $77, $00, $00, $78 
	db $00, $79, $7A, $7B, $7C, $7D, $7E, $7F, $80, $81, $00, $00, $82, $00, $00, $00, $00, $00 
	db $00, $83, $84, $85, $86, $87, $88, $89, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $8A, $8B, $8C, $8D, $8E, $8F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $90, $91, $00, $00, $92, $93, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $94, $00, $00, $00, $95, $96, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $97, $98, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;418C
	INCBIN "build/gfx/SiloScientist.rle"
	
RingEntityLogic: ;4562
	ld a, [wEntityCollided]
	or a
	jr z, .notHit
	xor a
	ld [wCollisionType], a
	dec hl
	xor a
	ld [hl+], a
	xor a
	ld [wTimerFramesLo], a
	ld a, $01
	ld [wTimerFramesHi], a
	ld a, $09
	ld [wQueueSFX], a
	jp TutSetupRings
.notHit ;18
	ld a, [wTutProgress]
	or a
	jr nz, .setOrientation
	dec hl
	xor a
	ld [hl], a ;kill this ring
	ret
.setOrientation ;4
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [wViewDir]
	ld [de], a
	ret
	
TutSetupRings: ;4597
	call GetFreeEntity
	ret c
	ld a, $2A ;flight ring model
	ld [hl+], a
	ld a, [wTutProgress]
	inc a
	ld [wTutProgress], a
	ld c, $00
	cp $03
	jr c, .donerandom
	cp $08
	jr c, .ringsunder8
	call NextRand  
	and $07 
	sub $04 ;-4 to 3
	ld c, a
	jr .donerandom
.ringsunder8
	call NextRand 
	and $03 
	sub $02 ;-2 to 1
	ld c, a
.donerandom
	ldh a, [hViewAngle]
	cpl 
	inc a ;negate it
	add a, c ;add our random range
	ld bc, $0000
	ld de, $0E00
	call CallProjectXYToCamera
	ldh a, [hXLoCopy]
	add a, c
	ld [hl+], a
	ldh a, [hXHiCopy]
	add a, b
	ld [hl+], a
	ldh a, [hYLoCopy]
	add a, e
	ld [hl+], a
	ldh a, [hYHiCopy]
	add a, d
	ld [hl+], a
	ld a, [wTutProgress]
	dec a
	sla a
	add a, LOW(tutRingsOffsets)
	ld e, a
	ld a, HIGH(tutRingsOffsets)
	adc a, $00
	ld d, a ;DE is now entry A into word table at $4000
	ld a, [wTutProgress]
	cp $01
	jr z, .firstring
	ld a, [wTutLastRingZLo]
	ld c, a
	ld a, [wTutLastRingZHi]
	ld b, a
	jr .gotZ
.firstring
	ldh a, [hZPosLow]
	cpl
	ld c, a
	ldh a, [hZPosHi]
	cpl
	ld b, a
	inc bc ;BC is our Z position
.gotZ
	ld a, [de]
	add a, c
	ld c, a
	inc de
	ld a, [de]
	adc a, b
	ld b, a ;BC += value pair from the $4000 table
	bit 7, b
	jr nz, .nonegate
	ld a, c
	cpl
	add a, $01
	ld c, a
	ld a, b
	cpl
	adc a, $00
	ld b, a
.nonegate
	ld a, c
	ld [hl+], a
	ld [wTutLastRingZLo], a
	ld a, b
	ld [hl+], a
	ld [wTutLastRingZHi], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $E9
	ld [hl+], a
	ld a, $30
	ld [hl+], a
	ld a, $C8
	ld [hl+], a
	ld a, [wTutProgress]
	cp $09
	jr nz, .end
	call ClearAllScreenText
	ld c, $A3
	ld hl, $7F92 ;hey good job
	call CallTryWriteScreenText
	ld c, $A3
	ld hl, $7FA1 ;what bank are these in?
	call CallTryWriteScreenText
.end
	ret
	
CheckTutScriptProgress: ;464E
	;return with clear flag set UNLESS we're not past the reference point yet
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	scf
	ret nz ;return with carry if not tutorial
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;else load word into DE
	ld hl, wTutPos ;script position
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;position in HL
	cp e
	ld a, h
	sbc a, d ;subtract reference from our actual position
	ccf ;clear flag now set if we're past reference point
	ret
	
CheckCreditsCheat: ;4664
	ld a, LOW(CreditsInputList)
	ld [wInputCodePtrLo], a
	ld a, HIGH(CreditsInputList)
	ld [wInputCodePtrHi], a
	ld a, $FF
	ldh [hGameState], a
.inploop
	call WaitForVBlank
	call UpdateInputs
	call CallCheckDeleteSaveInput
	jp c, CallTriggerCredits
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	bit 3, a
	jr z, .inploop
	ld a, $01
	ldh [hGameState], a
	ret


HandlePaused: ;468F
	ld a, [TutRefPoint3]
	ld e, a
	ld a, [TutRefPoint3+1]
	ld d, a
	ld hl, wTutPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	cp e
	ld a, h
	sbc a, d
	jr nc, .nottut
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jp z, CheckCreditsCheat
.nottut ;8
	ld a, $08
	ldh [rSCX], a
	xor a
	ldh [hGameState], a ;pause
	ldh [rIF], a ;clear interrupt flags
	ld a, (1<<VBLANK)
	ldh [rIE], a
	call CallDisableLCD
	call ClearAllVRAM
	call WipeWholeScreenTiles
	call ClearWRAM
	ld hl, PaperMapTilemap
	ld bc, $0080
	ld de, $0001
	call LoadTileMap
	ld hl, PaperMapMarkerGFX
	ld de, $8000
	ld b, $10
.loadmarker
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loadmarker
	loadpalette 3, 2, 1, 0
	ldh [rBGP], a
	ldh [hBGP], a
	loadpalette 3, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld a, LOW(CreditsInputList)
	ld [wInputCodePtrLo], a
	ld a, HIGH(CreditsInputList)
	ld [wInputCodePtrHi], a
	ldh a, [hXHiCopy]
	ld l, a
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;extend Hi X into HL
	add hl, hl
	add hl, hl
	add hl, hl ;then multiply by eight
	ld e, l
	ld d, h ;save this,
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ;128
	add hl, de ;total multiply = by 136 
	ld c, h ;high byte, effectively divide by 256... simplifies to 17/32 (horizontal tile count)
	ldh a, [hYHiCopy]
	cpl
	inc a
	ld l, a ;invert Y - bottom of map is world coord 0?
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;extend our inverted Y to HL
	ld a, c
	add hl, hl
	add hl, hl
	add hl, hl ;mult by eight
	ld c, l
	ld b, h ;8
	add hl, hl
	add hl, hl
	ld e, l
	ld d, h ;32
	add hl, hl ;64
	add hl, bc ;72
	add hl, de ;104
	ld b, h ;high byte, so fraction is 104/256, or.. 13/32 (vertical tile count); y in B
	ld c, a ;x in C
	ld hl, wOAMStart
	ld a, b
	add a, $5D ;Y start of map
	ld [hl+], a ;Y
	ld a, c
	add a, $54 ;x start of map
	ld [hl+], a ;X
	xor a
	ld [hl+], a ;tile
	ld [hl+], a ;attrib
.waitloop
	ld hl, wOAMStart + 2 ;(tile offset)
	ld a, [wFrameCounterLo]
	and $3F
	cp $20
	ld a, $01
	jr nc, .savetile
	ld a, $00
.savetile
	ld [hl+], a
	call WaitForVBlank
	call UpdateInputs
	call CallCheckDeleteSaveInput
	jp c, CallTriggerCredits
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	bit 3, a
	jr z, .waitloop
	call CallLoadFullGUI
	call CallSetLevelTitle
	ret

PaperMapMarkerGFX: ;4766
	INCBIN "build/gfx/PaperMapMarker.2bpp"
	
SiloHasCrystalSetup: ;4776
	xor a
	ldh [hGameState], a
	ldh [rIF], a
	ld a, $01 ;VBLANK
	ldh [rIE], a
	call CallDisableLCD
	call ClearAllVRAM
	call WipeWholeScreenTiles
	call ClearWRAM
	ld hl, SiloTilemap
	ld bc, $0080
	ld de, $0001
	call LoadTileMap
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	ldh [hBGP], a
	loadpalette 0, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A1
	call CallFlashScreen
	call WaitForNoNewInput
	ret

InLevelLoop: ;47AC, jumped to at the end of the home main sequence
	ld a, [$C299]
	sub $01
	adc a, $00
	ld [$C299], a ;count down C299
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .tut
	loadpalette 0, 0, 2, 0
	ldh [rOBP0], a
	loadpalette 3, 0, 2, 0
	ldh [rOBP1], a
	jr .objpalsset
.tut
	loadpalette 0, 3, 2, 0
	cpl ;makes it 3, 0, 1, 3
	ldh [rOBP0], a
	loadpalette 2, 3, 1, 0
	ldh [rOBP1], a
	call CallInterpretScriptTut
.objpalsset
	xor a
	ld [$C2B7], a
	ldh [hRenderXOffLo], a
	ldh [hRenderXOffHi], a ;word
	ld [$C339], a
	add a, $06
	ld [$C33A], a
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	call CheckSpecialArrowCases
	ld a, [wTutEndTimer]
	or a
	jr z, .notfadeout
	dec a
	ld [wTutEndTimer], a ;decrement counter
	jr nz, .notfadeout
	call CallTutFadeOut ;this only happens on the tick it hits 0
	call CallDisableLCD ;redundant
	ld a, $01
	ld [wTutComplete], a
	xor a
	ld [wCurLevel], a
	call CallSetLevelPointers
	ld a, $08
	ld [wHealth], a
	call CallWriteSave
	jp Reset.nextlevel
.notfadeout
	call UpdateBasesTotal
	ld a, [wSubscreen]
	or a
	jr z, .levelendcheck ;zero, to 4868
	dec a
	jr z, .junctionstate ;one, to 4851
	dec a
	jr z, .twoval ;two
	dec a
	jr z, .shopstate ;three
	dec a
	jr z, .fourval ;four
	ld a, $06 ;else, state five (base)
	ld [wQueueMusic], a
	call CallHandleRadarBase
	call CallRestoreGUIAndMusic ;reload the gui
	ld a, spdSTOP
	ldh [hSpeedTier], a ;stop
	jp .subdone
.fourval
	call CallHandleState4 ;ends up calling an empty function, like the shop
	jr .subdone
.shopstate
	call CallHandleShopState
	jr .subdone
.twoval
	call CallHandleState2 ;ends up calling an empty function, like the shop
.subdone ;484A
	xor a
	ld [wSubscreen], a
	jp .levelendcheck
.junctionstate ;4851
	call CallHandleJunctionState ;junction
	xor a
	ld [wSubscreen], a
	ldh a, [$FFD1]
	or a
	jr z, .levelendcheck ;to 4868
	xor a
	ld [wHasCargo], a ;no longer have crystal
	xor a
	ld [wMapTankCellPos], a
	jp Reset.incrementlevel
.levelendcheck ;4868
	ld a, [wLevelClearCountdown]
	or a
	jr z, .checkGameOver ;to 48B5
	dec a
	ld [wLevelClearCountdown], a ;level should end soon, decrement
	jp nz, .levelending 
	ld a, [wCurLevel] ;if just hit 0,
	cp LEVEL_TEN ;mission ten?
	jr nz, .missionresults
.endsequence
	call CallEscapeSequence
	jp Reset
.missionresults
	call CallMissionResultsScreen
	jp Reset.incrementlevel
	
.levelending ;4888, we're in the level end countdown
	ld a, [wCurLevel]
	cp LEVEL_TEN
	jr nz, .endstopmoving
	ld hl, wFrameCounter ;if we ARE in level ten, check the frame counter
	ld a, [hl+]
	cp $70
	ld a, [hl]
	sbc a, $02
	cp $80
	jp c, .endsequence ;if the time is low enough, force the escape sequence?
	ld a, $0A
	ld [wLevelClearCountdown], a ;else reset the timer?
.endstopmoving ;level is ending.
	xor a
	ld [wTurnSpeed], a ;stop turning
	ld a, spdSTOP
	ldh [hSpeedTier], a
	xor a
	ld [wLurchTarget], a
	ld [wLurchCounter], a
	ld a, $FF
	ldh [hGameState], a
.checkGameOver ;48B5, jumped to when level is not ending, fell into when level is ending.
	ld a, [wGameOverTimer]
	or a
	jr z, .checkhealth ;jump if not game over
	dec a
	jr z, .triggerGameOver ;jump if timer done
	ld [wGameOverTimer], a
	xor a
	ld [wTurnSpeed], a
	ld a, spdSTOP
	ldh [hSpeedTier], a
	xor a
	ld [wLurchTarget], a
	ld [wLurchCounter], a
	ld a, $FF
	ldh [hGameState], a ;freeze in place
.checkhealth
	ld a, [wHealth]
	rlca
	jp nc, $4926 ;if not negative, jump
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr nz, .kill
	xor a
	ld [wHealth], a ;prevent game over in the tutorial
	jp $4926
.kill
	ld a, $FF
	ld [wHealth], a
	ld a, [wLevelClearCountdown]
	or a
	jp nz, $4926 ;if we have already cleared the level, prevent death
	ld a, [wGameOverTimer]
	or a
	jp nz, $4926 ;if we're already dying, don't trigger this again
	ld a, $FF
	ldh [hGameState], a
	call CallDrawHealthBar
	ld hl, NoShieldText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $19
	ld [wGameOverTimer], a
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	jp $4926
.triggerGameOver ;4918
	ld a, TRACK_DEATH
	ld [wQueueMusic], a
	;falls into
ContinueFromTitle: ;491D
	call CallHandleGameOver
	jp c, Reset.gameovercontinue
	jp Reset
	
;4926, we didn't game over and we didn't win this frame. so do other stuff i guess.
	ldh a, [hXPosHi]
	and $F0
	ld c, a
	ld b, $00
	ldh a, [hXLoCopy]
	ldh [hXPosLow], a
	ldh a, [hXHiCopy]
	ldh [hXPosHi], a
	and $F0
	cp c
	jp z, $493D
	ld b, $01 ;b set if we moved over a grid space
;493D
	ldh a, [hYPosHi]
	and $F0
	ld c, a
	ldh a, [hYLoCopy]
	ldh [hYPosLow], a
	ldh a, [hYHiCopy]
	ldh [hYPosHi], a
	and $F0
	cp c
	jp z, $4952
	ld b, $01 ;b set if we moved over a grid space
;4952
	ldh a, [hViewAngle]
	ld [wViewDir], a
	ld a, [wCrosshairXOffset]
	ld [$C2FC], a
	ld a, [wCrosshairYOffset]
	ld [$C2FB], a
	ld a, [$CB08]
	ld [wCrosshairTargetLo], a
	ld a, [$CB09]
	ld [wCrosshairTargetHi], a
	ld a, [wPitchLurch]
	ld [wPitchAngle], a
	ld a, [wFlyTiltRaw]
	ld [wFlyTilt], a
	ld a, b
	or a
	call nz, CallIterateOverMapObjects ;if we moved into a grid space, update the entities
	call CallDrawStars
	call CallCheckRadarStatic
	call UpdateEntities
	call UpdateParticles
	call CallDrawRadarStatic
	call CallEmpty1022D
	call CallDrawCompass
	call CallSetAlertTiles
	call CallDrawFloorDots
	call HandleLowHealthAndLauncherText
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a
	jr nz, .skipflash ;check if screen's on
	ld a, $A3
	call CallFlashScreen
.skipflash
	call HandleLevelInputs
	call CallDrawHealthBar
	call CallDrawSpeedDisplay
	call CallDrawMissileCount
	call CallSetEquipmentItem ;this clears/overrides inventory1
	ld c, $6F
	ld b, $7F
	ld e, $35
	call CallDrawMinimapPips
	call CallRefreshBGTiles
	ld hl, $99CE
	call CallDrawMinimap
	ld a, [wInventory1]
	call CallPrintInterfaceString
	xor a
	ldh [$FFFD], a ;clear the vblank counter?
	ld a, [$CB4D] ;unknown currently
	or a
	jr z, .drawsky ;if zero, skip
	sub $04
	ld [$CB4D], a ;decrement by four
	jr z, .drawsky ;if zero now, skip
	ld d, a ;backup to d
	ld a, $55
	ld [$C2AE], a ;unknown
	ld e, $80
	ld bc, $0000
	call DrawInD100Region
	jp .finishsetup
.drawsky ;18 jump
	ld a, [wGameOverTimer]
	cp $01
	jp z, InLevelLoop
	ld a, $01
	ld [$CB20], a
	call CallDrawSurfaceAndSky
.finishsetup ;4A01
	call CallCopyWRAMToVRAM
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	loadpalette 0, 0, 2, 3 ;3D palette
	jr nz, .nocpl
	cpl
.nocpl
	ld c, a
	ld a, [wFlash3DWindow]
	sub $01
	adc a, $00 ;ALWAYS count down, restore to 0 if underflows
	ld [wFlash3DWindow], a
	bit 0, a
	ld a, c
	jr z, .nocpl2
	cpl
.nocpl2
	ldh [hBGP], a
	loadpalette 1, 0, 2, 3
	ldh [hIntP], a
	ld a, [wGameOverTimer]
	or a
	call z, CallLevelClearCheck
	ld a, [$C273]
	sub $01
	jr c, .target
	ld [$C273], a
	jr z, .target
	ld c, $0B
	jr .target
.target
	ld a, [wLevelIntroTimer]
	or a
	jp z, InLevelLoop
	ld a, $FF
	ldh [hGameState], a
.tickloop ;4A47
	call WaitForVBlank
	call WaitForVBlank
	ld a, [wLevelIntroTimer]
	dec a
	ld [wLevelIntroTimer], a
	jp nz, .tickloop
	ld a, $01
	ldh [hGameState], a ;set state to on planet
	jp InLevelLoop

DrawTextIntoWram: ;4A5E
	ld a, $0C
.mainloop
	ldh [$FF98], a
	ld a, c
	or a
	ld a, [de] ;start of rom table
	jr z, .skiploop ;if passed c is zero, skip ahead
	ld b, c
.loop1
	rrca
	dec b ;rotate a right by the three-bit c passed
	jr nz, .loop1
.skiploop
	ld b, a
	ldh a, [$FF9A]
	and b ;a is now masked with invert stored at FF9A?
.loop2
	or [hl]
	ld [hl], a ;mask off WRAM with our art
	inc h
	ldh a, [$FF99]
	and b
	or [hl]
	ld [hl+], a
	dec h
	inc de
	ldh a, [$FF98]
	dec a
	jr nz, .mainloop ;loops $C times
	ret
	
UpdateBasesTotal: ;4A80
	ld hl, wRadarBasesTable
	ld c, $00
	ld b, BASES_TOTAL
.loop
	ld a, [hl+]
	bit 7, a ;check top bit
	jp nz, .notset
	inc c
.notset
	dec b
	jp nz, .loop ;c has number of entries with top bit set
	ld a, [wRadarBaseCount]
	or a
	jr z, .savecount
	cp c
	jr z, .savecount
	push bc ;if count mismatches saved, and saved isn't zero:
	ld hl, RadarBaseDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, RadarBaseDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	pop bc
.savecount
	ld a, c
	ld [wRadarBaseCount], a
	ret

CharsetGFXEnglish: ;0x4AB2 - 0x4E5Dish?: 1bpp latin+hiragana+katakana+kanji
	INCBIN "build/gfx/CharsetEnglish.1bpp"
CharsetGFXHiragana: ;50A6
	INCBIN "build/gfx/CharsetHiragana.1bpp"
CharsetGFXKanji: ;578A
	INCBIN "build/gfx/CharsetKanji.1bpp"

PaperMapTilemap: ;5E62
	db $14, $12 ;dimensions
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $03, $04, $04, $05, $04, $04, $06, $07, $04, $04, $08, $04, $04, $09, $00, $00, $00, $00, $0A 
	db $0B, $0C, $0D, $0E, $0F, $0C, $10, $11, $0C, $12, $13, $0C, $14, $00, $00, $00, $00, $0A, $15, $0C 
	db $0D, $16, $17, $0C, $18, $19, $0C, $1A, $1B, $0C, $14, $00, $00, $00, $00, $0A, $1C, $0C, $1D, $1E 
	db $1F, $0C, $20, $21, $0C, $22, $23, $24, $25, $00, $26, $27, $00, $0A, $28, $0C, $29, $2A, $2B, $2C 
	db $2D, $2E, $2F, $30, $31, $32, $33, $00, $34, $35, $00, $0A, $0C, $36, $37, $38, $0C, $39, $3A, $0C 
	db $3B, $3C, $0C, $3D, $3E, $00, $3F, $40, $00, $0A, $41, $42, $0D, $43, $44, $0C, $45, $46, $47, $1A 
	db $0C, $48, $49, $00, $4A, $4B, $00, $0A, $4C, $4D, $0D, $4E, $4F, $50, $51, $52, $0C, $1A, $53, $54 
	db $55, $00, $56, $57, $58, $59, $0C, $5A, $5B, $5C, $5D, $5E, $5F, $0C, $60, $61, $62, $63, $64, $65 
	db $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $70, $6A, $71, $72, $6A, $73, $74, $75, $76, $77 
	db $00, $0A, $0C, $78, $79, $7A, $7B, $7C, $7D, $7E, $0C, $1A, $0C, $7F, $80, $00, $81, $82, $00, $0A 
	db $0C, $83, $79, $84, $85, $0C, $45, $86, $87, $1A, $0C, $88, $89, $00, $3F, $40, $00, $0A, $0C, $8A 
	db $8B, $8C, $0C, $8D, $8E, $0C, $8F, $90, $91, $92, $93, $00, $94, $95, $00, $0A, $96, $97, $98, $99 
	db $9A, $9B, $9C, $9D, $2F, $9E, $9F, $A0, $A1, $00, $A2, $A3, $00, $0A, $A4, $A5, $A6, $A7, $A8, $0C 
	db $A9, $AA, $0C, $AB, $AC, $AD, $AE, $00, $00, $00, $00, $0A, $AF, $B0, $79, $B1, $B2, $0C, $B3, $B4 
	db $0C, $1A, $B5, $B6, $B7, $00, $00, $00, $00, $0A, $B8, $B9, $79, $BA, $BB, $0C, $BC, $BD, $0C, $BE 
	db $BF, $C0, $C1, $00, $00, $00, $00, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $C7, $CD 
	db $CE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $CF, $D0, $00, $00, $00, $00, $00, $00, $00
;5FCC
	INCBIN "build/gfx/PaperMapTilemap.rle"

RefreshBGTiles: ;67A0
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a
	ret z ;if screen disabled, return
	ldh a, [hGameState]
	cp $01
	jp nz, Update3DBGTilesSection ;if not planet, jump
	ld a, [$C2A1] ;animation frame??
	and $03
	dec a
	jp z, DrawHud1 ;if one, jump
	dec a
	jp z, DrawHud2 ;if two, jump
	dec a
	jp z, DrawHud3 ;if three, jump
	;otherwise it's zero, draw first portion
;DrawHud0:
	ld hl, $9801 ;bg tile 1
.statloop1
	ldh a, [rSTAT]
	and $02
	jr z, .statloop1
.statloop2
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop2 ;alternates jr z and jr nz each time
	
	ld a, $9F
	ld [hl+], a
	ld a, $AA
	ld [hl+], a ;write two tiles
	ld b, $02
.statloop3
	ldh a, [rSTAT]
	and $02
	jr z, .statloop3
.statloop4
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop4
	ld a, $B3
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;write tile B3 into bg
	dec b
	jp nz, .statloop3
.statloop5
	ldh a, [rSTAT]
	and $02
	jr z, .statloop5
.statloop6
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop6
	
	ld a, $C2
	ld [hl+], a
	ld a, $C8
	ld [hl+], a
	ld hl, $9821 ;new tile position
.statloop7
	ldh a, [rSTAT]
	and $02
	jr z, .statloop7
.statloop8
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop8
	
	ld a, $A0
	ld [hl+], a
	ld a, $AB
	ld [hl+], a
	ld hl, $9841 ;new tile position
.statloop9
	ldh a, [rSTAT]
	and $02
	jr z, .statloop9
.statloopA
	ldh a, [rSTAT]
	and $02
	jr nz, .statloopA
	
	ld a, $A1
	ld [hl+], a
	ld a, $AC
	ld [hl+], a
	ld hl, $9833 ;new tile address
.statloopB
	ldh a, [rSTAT]
	and $02
	jr z, .statloopB
.statloopC
	ldh a, [rSTAT]
	and $02
	jr nz, .statloopC
	
	ld a, $C3
	ld [hl+], a
	ld a, $A0
	ld [hl+], a
	ld hl, $9853
.statloopD
	ldh a, [rSTAT]
	and $02
	jr z, .statloopD
.statloopE
	ldh a, [rSTAT]
	and $02
	jr nz, .statloopE
	ld a, $C4
	ld [hl+], a
	ld a, $C9
	ld [hl+], a
	jp Update3DBGTilesSection ;top three rows of the frame drawn
	
DrawHud3: ;6857
	ld hl, $9861
	ld de, $001E
	ld b, $08
.statz1
	ldh a, [rSTAT]
	and $02
	jr z, .statz1
.statnz1
	ldh a, [rSTAT]
	and $02
	jr nz, .statnz1
	
	ld a, $A2
	ld [hl+], a
	ld a, $AD
	ld [hl+], a
	add hl, de
	dec b
	jp nz, .statz1 ;loop draws the altometer
	
.statz2
	ldh a, [rSTAT]
	and $02
	jr z, .statz2
.statnz2
	ldh a, [rSTAT]
	and $02
	jr nz, .statnz2
	ld a, $A3
	ld [hl+], a
	ld a, $AE
	ld [hl+], a
	add hl, de
.statz3
	ldh a, [rSTAT]
	and $02
	jr z, .statz3
.statnz3
	ldh a, [rSTAT]
	and $02
	jr nz, .statnz3
	ld a, $A4
	ld [hl+], a
	ld a, $AF
	ld [hl+], a
	ld hl, $9973
.statz4
	ldh a, [rSTAT]
	and $02
	jr z, .statz4
.statnz4
	ldh a, [rSTAT]
	and $02
	jr nz, .statnz4
	ld a, $C5
	ld [hl+], a
	ld a, $CA
	ld [hl+], a
	add hl, de
.statz5
	ldh a, [rSTAT]
	and $02
	jr z, .statz5
.statnz5
	ldh a, [rSTAT]
	and $02
	jr nz, .statnz5
	ld a, $C6
	ld [hl+], a
	ld a, $CB
	ld [hl+], a
	jp Update3DBGTilesSection ;altometer + bottom frame corners drawn
	
DrawHud2: ;68C6
	ld hl, $99A1
.sz1
	ldh a, [rSTAT]
	and $02
	jr z, .sz1
.snz1
	ldh a, [rSTAT]
	and $02
	jr nz, .snz1
	ld a, $A5
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.sz2
	ldh a, [rSTAT]
	and $02
	jr z, .sz2
.snz2
	ldh a, [rSTAT]
	and $02
	jr nz, .snz2
	ld a, $B5
	ld [hl+], a
	ld a, $3A
	ld [hl+], a
	ld a, $3E
	ld [hl+], a
	ld a, $42
	ld [hl+], a
.sz3
	ldh a, [rSTAT]
	and $02
	jr z, .sz3
.snz3
	ldh a, [rSTAT]
	and $02
	jr nz, .snz3
	ld a, $46
	ld [hl+], a
	ld a, $BB
	ld [hl+], a
	ld a, $BF
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.sz4
	ldh a, [rSTAT]
	and $02
	jr z, .sz4
.snz4
	ldh a, [rSTAT]
	and $02
	jr nz, .snz4
	ld a, $C0
	ld [hl+], a
	ld a, $C7
	ld [hl+], a
	ld [hl+], a
	ld hl, $99C8
.sz5
	ldh a, [rSTAT]
	and $02
	jr z, .sz5
.snz5
	ldh a, [rSTAT]
	and $02
	jr nz, .snz5
	ld a, $B6
	ld [hl+], a
	ld a, $3B
	ld [hl+], a
	ld a, $3F
	ld [hl+], a
.sz6
	ldh a, [rSTAT]
	and $02
	jr z, .sz6
.snz6
	ldh a, [rSTAT]
	and $02
	jr nz, .snz6
	ld a, $43
	ld [hl+], a
	ld a, $47
	ld [hl+], a
	ld a, $BC
	ld [hl+], a
	ld hl, $99D2
	ld de, $001F
.sz7
	ldh a, [rSTAT]
	and $02
	jr z, .sz7
.snz7
	ldh a, [rSTAT]
	and $02
	jr nz, .snz7
	ld a, $C1
	ld [hl+], a
	add hl, de
	ld [hl+], a
	add hl, de
.sz8
	ldh a, [rSTAT]
	and $02
	jr z, .sz8
.snz8
	ldh a, [rSTAT]
	and $02
	jr nz, .snz8
	ld a, $C1
	ld [hl+], a
	add hl, de
	ld [hl+], a
	jp Update3DBGTilesSection ;top half of the console + radar drawn, right side of the map border drawn

DrawHud1: ;697A
	ld hl, $99E1
.sz1
	ldh a, [rSTAT]
	and $02
	jr z, .sz1
.snz1
	ldh a, [rSTAT]
	and $02
	jr nz, .snz1
	ld a, $A7
	ld [hl+], a
	ld a, $B0
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.sz2
	ldh a, [rSTAT]
	and $02
	jr z, .sz2
.snz2
	ldh a, [rSTAT]
	and $02
	jr nz, .snz2
	ld a, $B7
	ld [hl+], a
	ld a, $3C
	ld [hl+], a
	ld a, $40
	ld [hl+], a
.sz3
	ldh a, [rSTAT]
	and $02
	jr z, .sz3
.snz3
	ldh a, [rSTAT]
	and $02
	jr nz, .snz3
	ld a, $44
	ld [hl+], a
	ld a, $48
	ld [hl+], a
	ld a, $BD
	ld [hl+], a
	ld hl, $9A01
.sz4
	ldh a, [rSTAT]
	and $02
	jr z, .sz4
.snz4
	ldh a, [rSTAT]
	and $02
	jr nz, .snz4
	ld a, $A8
	ld [hl+], a
	ld a, $B1
	ld [hl+], a
	ld a, $B4
	ld [hl+], a
	ld hl, $9A08
.sz5
	ldh a, [rSTAT]
	and $02
	jr z, .sz5
.snz5
	ldh a, [rSTAT]
	and $02
	jr nz, .snz5
	ld a, $B8
	ld [hl+], a
	ld a, $3D
	ld [hl+], a
	ld a, $41
	ld [hl+], a
.sz6
	ldh a, [rSTAT]
	and $02
	jr z, .sz6
.snz6
	ldh a, [rSTAT]
	and $02
	jr nz, .snz6
	ld a, $45
	ld [hl+], a
	ld a, $49
	ld [hl+], a
	ld a, $BE
	ld [hl+], a
	ld hl, $9A21
.sz7
	ldh a, [rSTAT]
	and $02
	jr z, .sz7
.snz7
	ldh a, [rSTAT]
	and $02
	jr nz, .snz7
	ld a, $A9
	ld [hl+], a
	ld a, $B2
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.sz8
	ldh a, [rSTAT]
	and $02
	jr z, .sz8
.snz8
	ldh a, [rSTAT]
	and $02
	jr nz, .snz8
	ld a, $B9
	ld [hl+], a
	ld a, l
	add a, $04
	ld l, a
.sz9
	ldh a, [rSTAT]
	and $02
	jr z, .sz9
.snz9
	ldh a, [rSTAT]
	and $02
	jr nz, .snz9
	ld a, $BE
	ld [hl+], a
;lower half of the console and radar drawn, fall into
Update3DBGTilesSection: ;6A3F
	;updates a four-block-wide section of the 3D screen
	ld a, [$C2A1] ;animation frame again
	and $03
	dec a
	jr z, .branch1 ;if one
	dec a
	jr z, .branch2 ;if two
	dec a
	jr z, .branch3 ;if three
	ld hl, $9823 ;if zero
	ld e, $D0
	jr .donebranch
.branch1
	ld hl, $9827
	ld e, $FC
	jr .donebranch
.branch2
	ld hl, $982B
	ld e, $28
	jr .donebranch
.branch3
	ld hl, $982F
	ld e, $54
.donebranch
	ld d, $0B
	ld b, $0B
.snzloop
	ldh a, [rSTAT]
	and $02
	jr nz, .snzloop
	ld a, e
	ld [hl+], a
	add a, d
	ld [hl+], a
	add a, d
	ld [hl+], a
	add a, d
	ld [hl+], a
	ld a, l
	add a, $1C
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc e
	dec b
	jp nz, .snzloop
	ret
	
FireMissile: ;6A87
	push hl
	call GetFreeEntity
	pop de
	ret c
	ld a, $0F ;missile
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
	ld [hl-], a
	ld a, [hl]
	sub $0A
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	ld [hl+], a ;offset Z pos
	xor a
	ld [hl+], a
	ld a, [wViewDir]
	ld [hl+], a
	xor a
	ld [hl+], a ;orientation
	ld a, $27
	ld [hl+], a
	ld a, $73
	ld [hl+], a ;two bytes
	ld a, $04
	ld [hl+], a ;4 HP?
	xor a
	ld [hl+], a
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl+], a ;passed HL (targeted entity pointer??)
	xor a
	ld [hl+], a ;not map object
	ret
	
DrawSkyMoon: ;6ACB
	ld a, [wViewDir]
	cpl
	inc a ;negate
	add a, $1E
	cp $30
	ret nc ;return if not in a certain range
	add a, a
	add a, a ;times four
	ld c, a ;save to C
	ld a, [wPitchAngle]
	sub $34
	add a, $14
	ld b, a
	call CallRollValByTilt
	ld a, b ;rolled value
	ld e, a
	cp $80
	ret nc
	ld a, c
	rrca
	rrca
	rrca
	and $1F
	add a, $CF
	ld d, a
	ld a, c
	and $07
	rlca
	rlca
	rlca
	rlca
	add a, LOW(SkyMoonGFX)
	ld l, a
	ld a, HIGH(SkyMoonGFX)
	adc a, $00
	ld h, a ;HL is the moon gfx pointer
	ld a, d
	cp $D0
	jr c, .half2
	cp $E0
	ret nc
	push de
	push hl
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	pop hl
	pop de
.half2 ;2F
	inc d
	ld a, d
	cp $D0
	ret c
	cp $E0
	ret nc
	ld a, l
	add a, $08
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ld a, [de]
	or [hl]
	ld [de], a
	inc hl
	inc e
	ret
	

SkyMoonGFX: ;6B6D - 6BEE: mono moon
	INCBIN "build/gfx/moon.1bpp"

DisplayTutorialLesson: ;6BED
	push hl
	call CallDisableLCD
	call LoadTutorialBG
	call CopyTutInstructorFromBuf
	call CopyTutInstructorFromBuf ;twice?
	call CopyTutTextFromBuf
	call CopyTutTextFromBuf ;twice? draws top and bottom of speech bubble
	xor a
	ldh [hGameState], a
	ld [wTargetSCY], a
	ldh [rSCY], a
	ldh [rSCX], a
	ld a, $FF
	ldh [rWX], a
	loadpalette 0, 3, 3, 0
	ldh [rBGP], a
	loadpalette 0, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ld a, $A3
	call CallFlashScreen
	xor a
	ld [$C2FD], a
	ld a, spdSTOP
	ldh [hSpeedTier], a
	xor a
	ldh [$FFA8], a
	ldh [$FFA9], a
	ld [$CAA7], a
	ld [$C2CD], a
	pop hl ;restore address passed (pointer to tut text?)
.outerloop
	ld bc, $0000 ;clear bc
	push hl
	call DisplayTutorialTextPage
	jr z, .skipscf
	scf
.skipscf
	call nc, WaitForNoNewInput
	pop hl
.innerloop
	inc hl
	call GetByteFromBank9
	ld a, c
	or a
	jp nz, .innerloop
	inc hl
	call GetByteFromBank9
	ld a, c
	cp $FF ;done writing text when 00FF is read
	jp nz, .outerloop
	ret
	
DisplayTutorialTextPage: ;6C5A
	ld a, TRACK_TRAINING_PAGE
	ld [wQueueMusic], a
	ld a, c
	add a, $40
	ld c, a
	push bc ;save our bc
	call GetByteFromBank9
	ld a, c
	pop bc
	add a, b ;add our saved b to our read byte
	add a, $22 ;+22
	ld b, a ;save our new value to b
	inc hl ;next byte
	ld a, $40
	ld [wTextBubbleX], a
	push hl ;save position
	push bc ;save bc
	call CopyTutTextFromBuf ;prints clear buffer
	pop bc ;restore bc
	pop hl ;restore read position
	push hl ;save read position again
	call CallPrintTutorialTextPage ;this puts the text into the buffer
	call CopyTutTextFromBuf ;prints the text
	pop hl ;restore read position
	xor a
	ldh [$FFF3], a
	ld a, $7F
	ldh [$FFF1], a
	xor a
	ldh [$FFEF], a
	ld a, $40
	ldh [$FFED], a
	ld a, $18
	ld [$C2BC], a
	ld [$C2BD], a
	ld a, $D4
	ldh [$FF9E], a
	cp $80
	ld a, $00
	adc a, $FF
	ldh [$FF9F], a
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ldh [$FFA3], a
	ld [$CB41], a
	ld a, $02
	ldh [$FFDC], a
	ld a, $5A
	ldh [$FFDB], a
	ld a, $80
	ld [$CB1D], a
	ld a, $19
	ld [wTutTextWait], a
.bigloop ;moved this up a lil
	ld a, [wTutTextWait]
	sub $01
	ld [wTutTextWait], a
	jr nc, .cantadvance
	xor a
	ld [wTutTextWait], a
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld d, a
	and $08
	cp $08
	ccf
	ret c
	ld a, d
	and $01
	ret nz
.cantadvance
	push hl
	ld a, [$CB1D]
	cp $80
	jr nc, .skipload
	add a, $04
	ld [$CB1D], a
.skipload
	ldh [$FFA1], a
	xor a
	ld [$C33E], a
	ld a, $04 ;instructor model
	call CallDrawModel
	call CopyTutInstructorFromBuf
	pop hl
	call GetByteFromBank9
	inc hl
	ld a, c
	ld [$C2A1], a
	ld c, a
	bit 0, a
	jr z, .skipload2
	ld a, $07
	ld [wQueueWave], a
.skipload2
	ld a, c
	or a
	jr nz, .bigloop
	xor a
	ret
	
LoadTutorialBG: ;6D20
	ld hl, $8000
	ld bc, $1800
.clearloop
	xor a
	ld [hl+], a
	dec bc
	ld a, c
	or b
	jr nz, .clearloop
	ld hl, $9800
	ld bc, $0400
.bgpaintloop ;sets all tiles in bg plane 0 to $80
	ld a, $80
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .bgpaintloop
	ld hl, $9840
	ld a, $62 ;tutorial face tile
	ld c, $06 ;height
.facerow
	ld b, $05 ;width
.facetile
	ld [hl+], a
	add a, $06
	dec b
	jr nz, .facetile
	sub $1D
	ld e, a
	ld a, l
	add a, $1B
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	dec c
	jr nz, .facerow
	
	ld hl, $9807
	ld a, $8A ;starting text tile
	ld c, $12 ;height
.textrow
	ld b, $0C ;width
.textchar
	ld [hl+], a
	add a, $12
	dec b
	jr nz, .textchar
	sub $D7
	ld e, a
	ld a, l
	add a, $14
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	dec c
	jr nz, .textrow
	ld hl, $8810
	ld de, TutSpeechBubbleGFX ;speech bubble tiles
	ld b, $30
;6D7F?
	ld a, [de]
	inc de
	ld [hl+], a
	xor a
	ld [hl+], a
	dec b
	jp nz, $6D7F
	ld hl, $9813 ;top right bubble corner
	ld de, $0020
	ld a, $81
	ld [hl], a
	add hl, de
	ld b, $10
	ld a, $85
;6D96
	ld [hl], a
	add hl, de
	dec b
	jp nz, $6D96 ;loop for right side
	ld a, $84
	ld [hl], a
	ld hl, $9806 ;top left corner
	ld a, $82
	ld [hl], a
	add hl, de
	ld a, $85
	ld b, $10
;6DAA
	ld [hl], a
	add hl, de
	dec b
	jp nz, $6DAA
	ld a, $83 ;bottom left corner
	ld [hl], a
	ld hl, $9906
	ld a, $86
	ld [hl], a
	ret
	
TutSpeechBubbleGFX: ;6DBA
	INCBIN "build/gfx/tutspeechbubble.1bpp"
CopyTutTextFromBuf: ;6DEA
	ld hl, $D400
	ld de, $D48F
	ld b, $0C
	ld a, $FF
.startloop
	ld [hl], a
	ld [de], a
	inc d
	inc h
	dec b
	jp nz, .startloop
	ld hl, $88A0 ;start of text tiles
	ld de, $D400
	ld b, $0C
	inc l
.loop
	push bc
.innerloop
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	inc e
	ld a, [de]
	inc e
	inc e
	push de
	push af
	dec e
	ld a, [de]
	ld d, a
	pop af
	ld e, a
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, c
	ld [hl+], a
	inc l
	ld a, b
	ld [hl+], a
	inc l
	ld a, e
	ld [hl+], a
	inc l
	ld a, d
	ld [hl+], a
	inc l
	pop de
	ld a, e
	sub $04
	ld e, a
	xor a
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld a, e
	cp $90
	jp c, .innerloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .loop
	ret
	
CopyTutInstructorFromBuf: ;6E44
	ld hl, $9620 ;start of the instructor face tiles
	ld de, wMonoBufferColumn1
	ld b, $05
	inc l
.bcloop
	push bc
.loop
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	inc e
	ld a, [de]
	inc e
	inc e
	push de
	push af
	dec e
	ld a, [de]
	ld d, a
	pop af
	ld e, a
.statwait
	ldh a, [rSTAT]
	and $02
	jr nz, .statwait
	ld a, c
	ld [hl+], a
	inc l
	ld a, b
	ld [hl+], a
	inc l
	ld a, e
	ld [hl+], a
	inc l
	ld a, d
	ld [hl+], a ;write to tiledata
	inc l
	pop de
	ld a, e
	sub $04
	ld e, a
	xor a
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a ;wipe gfx buffer
	inc e
	ld a, e
	cp $30
	jr c, .loop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .bcloop
	ret
	
TutorialEntityLogic: ;6E8B
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	xor a
	ld [de], a ;wipe mapobj ID
	ld a, [wTutProgress]
	cp $03
	jr nc, .overtwoprog
	or a
	jr z, .zeroprog
.loop ;?
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de] ;health
	cp $0B
	ret nc ;if undamaged, return
	ld a, $14
	call CallDamageEntity ;kaplowie!
	ld a, $02
	ld [wTutProgress], a
	ret
.zeroprog ;17
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;health
	ld a, $0D
	ld [de], a ;replenish health
	ret
.overtwoprog ;26
	cp $08
	jr nc, .oversevenprog
	push hl
	inc hl
	inc hl
	ld a, [hl]
	add a, $14
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl+], a
	pop hl
	ld a, [$C2B8] ;logic enable
	or a
	jp nz, .loop
	ld a, $04
	ld [wTutProgress], a
	dec hl
	xor a
	ld [hl+], a
	ret
.oversevenprog ;1C
	cp $09
	jr nc, .overeight
	ld a, $09
	ld [wTutProgress], a
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, $28
	ld [de], a ;health
	ret
.overeight ;11
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	cp $23
	jr nc, .dam
	ld a, $0A
	ld [wTutProgress], a
	ld a, $32
	call CallDamageEntity
	ret
.dam ;0B
	ld a, $28
	ld [de], a
	inc hl
	inc hl
	ld a, [hl]
	add a, $0A
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl+], a
	ret


InterpretScriptTut: ;6F1D
	ld hl, $C289 ;word, points to where we start interpreting from
	ld a, [hl+]
	ld h, [hl]
	ld l, a
.loop ;6F23
	push hl ;save pointed word
	ld a, [wTimerEnableFlag]
	or a
	jr z, .skip
	ld hl, wTimerFrames ;if timer enabled and 0, use fallback pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr nz, .skip
	xor a
	ld [wTimerEnableFlag], a
	pop hl ;restore pointed word
	ld a, [wTutFallbackPointerLo]
	ld l, a
	ld a, [wTutFallbackPointerHi]
	ld h, a
	jr .nopop
.skip
	pop hl
.nopop
	ld a, [hl+] ;byte at address is our offset for table
	ld c, l
	ld b, h ;backup new read offset to BC
	rlca ;multiply by two to get offset in words
	add a, LOW(.TutScriptOpTable)
	ld l, a
	ld a, HIGH(.TutScriptOpTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl ;jump to table value
	
.TutScriptOpTable ;6F53
	dw $6F87 ;0 dummy
	dw $6F8C ;1 dummy
	dw $6F91 ;2 dummy
	dw $6F96 ;3 word "calls" a normal function
	dw $6FA7 ;4 word tutorial lesson
	dw $6FC7 ;5 word prints text on screen
	dw $6FD8 ;6 none exits loop
	dw $6FE3 ;7 word jump
	dw $6FEB ;8 byte+word jump z
	dw $6FF9 ;9 byte writes to an address (wait?)
	dw $700A ;A none 
	dw $7020 ;B word loads byte at pointer into C288?
	dw $702D ;C byte draws arrow
	dw $708D ;D none wipes arrow
	dw $7095 ;E byte+word jump nz
	dw $70A4 ;F byte+word writes byte to word
	dw $70B1 ;10 word jumps interpreter to new position
	dw $70C5 ;11 none returns from command 10 jump
	dw $70D0 ;12 byte into C290
	dw $70E1 ;13 none decrement 2nd wait counter
	dw $70F7 ;14 byte+word jump c
	dw $7106 ;15 byte+word jump nc 
	dw $7115 ;16 none clears an area of wram
	dw $711F ;17 word+word enables timer, jumps to second word if timer hits 0
	dw $7139 ;18 none disables timer
	dw $714D ;19 none bars out the screen
;6F87
	ld l, c
	ld h, b ;restore read offset
	jp .loop ;nothing else
;6F8C
	ld l, c
	ld h, b ;restore read offset
	jp .loop ;nothing else
;6F91
	ld l, c
	ld h, b ;restore read offset
	jp .loop ;nothing else
;6F96, address call
	ld l, c
	ld h, b ;restore read offset
	push hl ;save it
	ld bc, .return
	push bc ;save .return as our ret target
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read a word
	jp hl ;and jump to it
.return
	pop hl ;restore our read position
	inc hl
	inc hl ;and advance past what was just read
	jp .loop
	
;6FA7, tutorial lesson
	ld l, c
	ld h, b ;restore read offset, these are at lesson text pointer table??
	ld a, [$C2BD]
	push af
	push hl ;save these
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read a pointer into HL, this is lesson text pointer
	ld bc, $0000
	call CallDisplayTutorialLesson ;farcall for something in this bank, lol
	call CallRestoreGUIAndMusic
	pop hl
	pop af
	ld [$C2BC], a
	ld [$C2BD], a
	inc hl
	inc hl
	jp .loop
	
;6FC7, print text
	ld l, c
	ld h, b ;restore read offset
	push hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is text address
	ld c, $A3
	call CallTryWriteScreenText
	pop hl
	inc hl
	inc hl
	jp .loop
	
;6FD8 
	ld l, c
	ld h, b ;restore read offset
	ld a, l
	ld [wTutPosLo], a
	ld a, h
	ld [wTutPosHi], a
	ret ;the only exit for the loop
	
;6FE3 
	ld l, c
	ld h, b ;restore read offset
.backjump
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .loop
	
;6FEB 
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutRegister]
	cp [hl]
	inc hl
	jr z, .backjump
	inc hl
	inc hl
	jp .loop
	
;6FF9 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+]
	ld [wTutLoopTimer], a ;reads one byte
	ld a, l
	ld [wTutLoopPosLo], a
	ld a, h
	ld [wTutLoopPosHi], a ;backs up position
	jp .loop
	
;700A 
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutLoopTimer]
	dec a
	ld [wTutLoopTimer], a
	jr z, .end
	ld a, [wTutLoopPosLo]
	ld l, a
	ld a, [wTutLoopPosHi]
	ld h, a
.end
	jp .loop
	
;7020 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld [wTutRegister], a ;load byte at pointer into C288
	jp .loop
	
;702D 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+] ;read a byte, this is entry in table
	call $7037
	jp .loop
.loadArrowC ;garbo byte
	ld a, c
;7037
	push hl ;push position
	rlca ;multiply by two, word offset
	add a, LOW(TutArrowPointers)
	ld l, a
	ld a, HIGH(TutArrowPointers)
	adc a, $00
	ld h, a ;$7172 + word
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load pointer
	xor a
	ldh [$FFF5], a ;clear out these two
	ldh [$FFF7], a
	ld a, [hl+]
	sub $18
	ld d, a
	ld a, [hl+]
	sub $18
	ld e, a ;next two bytes - $18 into DE
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a ;next two bytes into BC
	push hl ;push data position
	call CallDrawLine
	pop hl ;restore data position
	ld de, $C080 ;OAM for arrows
.spriteloop;705D?
	ld a, [hl+] ;read 4
	cp $80 ;end of data
	jr z, .ret
	ld c, a
	ldh a, [$FFF7]
	add a, c
	ldh [$FFF7], a
	ld [de], a ;byte + FFF7 for Y
	inc de
	ldh a, [$FFF5]
	add a, [hl]
	ldh [$FFF5], a
	ld [de], a ;byte + FFF5 for X
	inc de
	inc hl
	ld a, [hl+]
	add a, $7B ;arrow stem tiles offset
	ld [de], a ;byte + $7B for tile
	inc de
	xor a
	ld [de], a ;0 for attr
	inc de
	jp .spriteloop ;loop
.ret
	pop hl
	ret
	
.wipeUnknownSprite ;707F not in table
	ld hl, $C080 ;OAM arrow position?
	ld d, $08
	xor a
.lupe
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec d
	jr nz, .lupe
	ret
;708D 
	call $707F
	ld l, c
	ld h, b ;restore read offset
	jp .loop
	
;7095 
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutRegister]
	cp [hl]
	inc hl
	jp nz, $6FE5
	inc hl
	inc hl
	jp .loop
	
;70A4 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, c
	ld [de], a ;write first byte to word
	jp .loop
	
;70B1 
	ld l, c
	ld h, b ;restore read offset
	ld a, l
	add a, $02
	ld [wTutSubStackLo], a
	ld a, h
	adc a, $00
	ld [wTutSubStackHi], a ;sets a continue point - a call?
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .loop
	
;70C5 
	ld a, [wTutSubStackLo]
	ld l, a
	ld a, [wTutSubStackHi]
	ld h, a ;returns from the call?
	jp .loop
	
;70D0 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+]
	ld [wTutSubTimer], a ;byte into C290
	ld a, l
	ld [wTutSubLoopPosLo], a
	ld a, h
	ld [wTutSubLoopPosHi], a ;backup position
	jp .loop
	
;70E1
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutSubTimer]
	dec a
	ld [wTutSubTimer], a
	jr z, .skiphl
	ld a, [wTutSubLoopPosLo]
	ld l, a
	ld a, [wTutSubLoopPosHi]
	ld h, a
.skiphl
	jp .loop
	
;70F7 
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutRegister]
	cp [hl]
	inc hl
	jp c, $6FE5
	inc hl
	inc hl
	jp .loop
	
;7106 
	ld l, c
	ld h, b ;restore read offset
	ld a, [wTutRegister]
	cp [hl]
	inc hl
	jp nc, $6FE5 ;follows next pointer
	inc hl
	inc hl ;jp nc
	jp .loop
	
;7115 
	ld l, c
	ld h, b ;restore read offset
	push hl
	call ClearAllScreenText
	pop hl
	jp .loop
	
;711F 
	ld l, c
	ld h, b ;restore read offset
	ld a, [hl+]
	ld [wTimerFrames], a
	ld a, [hl+]
	ld [$C313], a
	ld a, [hl+]
	ld [wTutFallbackPointerLo], a
	ld a, [hl+]
	ld [wTutFallbackPointerHi], a
	ld a, $01
	ld [wTimerEnableFlag], a ;enable fallback
	jp .loop
	
;7139 
	ld l, c
	ld h, b ;restore read offset
	xor a
	ld [wTimerEnableFlag], a ;disable fallback
	ld [wTimerFrames], a
	ld [wTimerFrames+1], a
	push hl
	call CallDrawTimer
	pop hl
	jp .loop
	
;714D 
	ld l, c
	ld h, b ;restore read offset
	push hl
	call CallBarOutScreen
	call CallCopyWRAMToVRAM
	ldh a, [$FF40]
	bit 7, a
	jr z, .skipcalls
	call CallBarOutScreen
	call CallCopyWRAMToVRAM
	call CallBarOutScreen
	call CallCopyWRAMToVRAM
	call CallBarOutScreen
	call CallCopyWRAMToVRAM
.skipcalls
	pop hl
	jp .loop
	
TutArrowPointers: ;7172
	dw .TutArrowOAM1 
	dw .TutArrowOAM2
	dw .TutArrowOAM3
	dw .TutArrowOAM4
	dw .TutArrowOAM5
	dw .TutArrowOAM6 
	dw .TutArrowOAM7
	dw .TutArrowOAM8
	dw .TutArrowOAM9 
	dw .TutArrowOAM10
	dw .TutArrowOAM11
	dw .TutArrowOAM12
	
.TutArrowOAM1 ;718A, arrow 1
	db $3C, $92 
	db $30, $00 
	db $6C, $8A, 00 
	db $08, $F8, 00 
	db $08, $F8, 00 
	db $08, $F8, 00 
	db $08, $F8, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM2 ;71A1
	db $3C, $40 
	db $28, $00 
	db $64, $40, 01 
	db $08, $08, 03 
	db $80
.TutArrowOAM3 ;71AC
	db $3C, $88 
	db $00, $00 
	db $3C, $88, 01 
	db $08, $08, 01 
	db $08, $08, 03 
	db $80
.TutArrowOAM4 ;71BA
	db $32, $78 
	db $32, $00 
	db $64, $70, 00 
	db $08, $F8, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM5 ;71C8
	db $34, $50 
	db $1E, $00 
	db $52, $50, 01 
	db $08, $08, 01 
	db $08, $08, 01 
	db $08, $08, 03 
	db $80
.TutArrowOAM6 ;71D9
	db $34, $5E 
	db $00, $00 
	db $34, $5E, 01 
	db $08, $08, 01 
	db $08, $08, 03 
	db $80
.TutArrowOAM7 ;71E7
	db $34, $7C 
	db $3E, $00 
	db $72, $7C, 01 
	db $08, $08, 01 
	db $08, $08, 01 
	db $08, $08, 03 
	db $80
.TutArrowOAM8 ;71F8
	db $28, $28 
	db $0A, $00 
	db $32, $20, 00 
	db $08, $F8, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM9 ;7206
	db $32, $4E 
	db $40, $00 
	db $72, $46, 00 
	db $08, $F8, 00 
	db $08, $F8, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM10 ;7217
	db $38, $6C 
	db $00, $00 
	db $38, $64, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM11 ;7222
	db $38, $62 
	db $2E, $00 
	db $66, $5A, 00 
	db $08, $F8, 00 
	db $08, $F8, 00 
	db $08, $F8, 02 
	db $80
.TutArrowOAM12 ;7233
	db $38, $62 
	db $2E, $00 
	db $66, $62, 01 
	db $08, $08, 01 
	db $08, $08, 01 
	db $08, $08, 03 
	db $80

tutStart: ;7244, pointed at by $C289 when tutorial is ran
	tutShowBriefing $55EA
	tutJump tutMain
	
tutTunnelHealthZero: ;724A, when health is zero in the tunnel
	tutReturnControl
	tutWriteValue $0, wHealth
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, tutTunnelHealthZero
	tutWriteValue $8, wHealth
	tutClearText
	tutScreenText $7d04 ;you hit the wall too much! try again!
	tutScreenText $7d32
	tutScreenText $7d49
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutJump tutMain.resettunnel

tutMissileCheck: ;726B
	tutRawCall tutGetMissileDistance
	tutJumpNZ $ff, .found
	tutLoadFromAddress wMissileCount
	tutJumpIfEqual $0, .nomissiles
	tutRet
.found ;727A
	tutJumpC $23, .ret
.nomissiles ;727E
	tutRawCall tutRefreshMissile
	tutClearText
	tutScreenText $7bdc ;follow the cursor!
	tutScreenText $7bf4
	tutSetSubLoopCounter $a
	tutReturnControl
	tutSubLoop
.ret ;728C
	tutRet

tutTargetEnemy1: ;728D
	tutRawCall tutGetTankDistance
	tutJumpIfEqual $FF, .subreturn
	tutJumpC $23, .subreturn
	tutRawCall tutRefreshEnemy1
	tutLoadFromAddress wTutProgress
	tutJumpNZ 9, .capped
	tutWriteValue 8, wTutProgress ;if it's 9, reset it to 8?
.capped ;72A6
	tutClearText
	tutScreenText $7BA1 ;get back to the enemy!
	tutScreenText $7BB2
	tutSetSubLoopCounter 10
	tutReturnControl
	tutSubLoop
.subreturn ;72B1
	tutRet
	
;72B2
	tutClearText
	tutSetSubLoopCounter $a
	tutReturnControl
	tutSubLoop
	tutShowBriefing $6af7 ;???
	tutSetSubLoopCounter $a
	tutReturnControl
	tutSubLoop
	tutWriteValue $8, wTutProgress
	tutJump $76b0 ;back to after getting lock-on
	
tutCheckEnemyCollision: ;72C5
	tutLoadFromAddress wHealth 
	tutJumpIfEqual 8, tutCheckHealth1.subreturn 
	tutClearText
	tutScreenText $5EC7 ;it's too close! 
	tutSetSubLoopCounter $19
	tutReturnControl
	tutSubLoop 
	tutWriteValue 8, wHealth
	tutRet

tutCheckHealth2: ;72D9
	tutLoadFromAddress wHealth
	tutJumpNC 6, tutCheckHealth1.subreturn
	tutJump tutCheckHealth1.submain
	
tutCheckHealth1: ;72E3, called
	tutLoadFromAddress wHealth
	tutJumpIfEqual 08, .subreturn ;if health full, return
.submain
	tutClearArrow
	tutShowBriefing $59A1 ;else, got a briefing here for you
	tutClearText
	tutScreenText $5A31
	tutScreenText $5A45
	tutSetSubLoopCounter $19
	tutReturnControl
	tutDrawArrow 2
	tutSubLoop
	tutClearArrow
	tutSetSubLoopCounter $A
	tutReturnControl
	tutSubLoop
	tutWriteValue $08, wHealth
.subreturn ;7304
	tutRet
	
tutMain: ;7305, just past the starting brief of the tutorial
	tutSetLoopCounter $14 
	tutReturnControl 
	tutLoop
	tutScreenText $58C9 ;screentext
	tutScreenText $58DA
	tutSetLoopCounter $23 ;write val
	tutDrawArrow 0 ;draw arrow
	tutReturnControl 
	tutLoop
	tutScreenText $58F8
	tutScreenText $5913
	tutSetLoopCounter $23 
	tutDrawArrow 0 
	tutReturnControl
	tutLoop
	tutClearArrow
	tutSetLoopCounter $46 
	tutReturnControl
	tutCallPos tutCheckHealth1
	tutLoop
	tutScreenText $5932
	tutScreenText $594E
	tutSetLoopCounter $23 
	tutDrawArrow 1 
	tutReturnControl
	tutLoop
	tutScreenText $5974
	tutScreenText $598F
	tutSetLoopCounter $23 
	tutDrawArrow 1 
	tutReturnControl
	tutLoop
	tutClearArrow
	tutSetLoopCounter $46 
	tutReturnControl
	tutCallPos tutCheckHealth1
	tutLoop
	tutShowBriefing $5A61
	
	tutWriteValue 0, hXLoCopy
	tutWriteValue $A0, hXHiCopy
	tutWriteValue 0, hYLoCopy
	tutWriteValue $54, hYHiCopy
	tutWriteValue 0, hViewAngle
	tutBarScreen
	tutScreenText $5C26
	tutSetLoopCounter $22
	tutDrawArrow 3
	tutReturnControl
	tutLoop
	tutClearText
	tutScreenText $5C26
	tutSetLoopCounter $23
	tutDrawArrow 3
	tutReturnControl
	tutLoop
	tutScreenText $5C43
	tutScreenText $5C60
	tutSetLoopCounter $20
	tutDrawArrow 3
	tutReturnControl
	tutLoop
	tutClearArrow
	tutSetLoopCounter $4B
	tutCallPos tutCheckHealth2
	tutReturnControl
	tutLoop
	tutScreenText $7EBB
	tutScreenText $7EDA
	tutSetLoopCounter $23
	tutDrawArrow $B
	tutReturnControl
	tutLoop
	tutScreenText $7EF1
	tutScreenText $7F0D
	tutSetLoopCounter $23
	tutDrawArrow $B
	tutReturnControl
	tutLoop
	tutClearArrow
	tutShowBriefing $5C89
	
	tutWriteValue 0, hXLoCopy
	tutWriteValue $40, hXHiCopy
	tutWriteValue 0, hYLoCopy
	tutWriteValue $58, hYHiCopy
	tutWriteValue 0, hViewAngle
	tutBarScreen
	tutSetLoopCounter $14
	tutReturnControl
	tutLoop
	tutRawCall TutLoadEnemy1
	tutWriteValue spdSTOP, hSpeedTier ;set to stop
	tutSetLoopCounter $A
	tutReturnControl
	tutLoop
	tutScreenText $5DB8
	tutScreenText $5DD6
	tutSetLoopCounter $19
	tutDrawArrow 4
	tutReturnControl
	tutLoop
	tutClearArrow
	tutClearText
.targetloop ;73D6
	tutWriteValue spdSTOP, hSpeedTier ;stop
	tutWriteValue 8, wHealth ;full
	tutScreenText $5DF0
	tutScreenText $5E04
	tutSetLoopCounter $14
	tutDrawArrow 3
	tutReturnControl
	tutLoop
	tutClearArrow
	tutClearText
.aimplz ;73EC
	tutScreenText $5E23 ;directs you to aim at enemy
	tutScreenText $5E32
	tutSetLoopCounter $14
	tutDrawArrow 9
	tutReturnControl
	tutLoop
	tutClearArrow
;73F9
	tutSetLoopCounter $64
	tutCallPos tutTargetEnemy1
	tutRawCall tutLoadPointerTarget
	tutJumpIfEqual 2, $740A
	tutReturnControl
	tutLoop
	tutJump .targetloop
;740A
	tutSetLoopCounter $05
	tutRawCall tutLoadPointerTarget ;make sure we stay aimed at the tank
	tutJumpNZ 2, $73F9
	tutReturnControl
	tutLoop
	tutClearText
	tutRawCall tutCheckPointerTargetDistance
	tutJumpC $C, .shootbrief ;close enough! jump to briefing
	tutClearText
	tutScreenText $5E3C ;get closer!
	tutScreenText $5E44
.spdloop ;7424
	tutSetLoopCounter $23
	tutReturnControl
	tutCallPos tutCheckEnemyCollision
	tutLoop
	tutCallPos tutTargetEnemy1
	tutRawCall tutCheckPointerTargetDistance
	tutJumpC $0C, .frwrd ;close
	tutRawCall tutLoadPointerTarget
	tutJumpNZ 2, .aimplz ;not targeted anymore
	tutLoadFromAddress hSpeedTier
	tutJumpNC 2, .frwrd ;not stopped or reversed
	tutClearText
	tutScreenText $5e63 ;go forward!!
	tutScreenText $5e8a
	tutJump .spdloop
	
.frwrd ;744D
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual 1, .stopped ;stopped?
	tutClearText
	tutScreenText $5e9f ;stop when you get closer
	tutScreenText $5ebc
.stopped ;745B
	tutSetLoopCounter $f
	tutReturnControl
	tutCallPos tutCheckEnemyCollision
	tutLoop
	tutRawCall tutCheckPointerTargetDistance
	tutJumpC $0C, .close ;close?
	tutSetLoopCounter $32
	tutReturnControl
	tutCallPos tutCheckEnemyCollision
	tutLoop
.close ;7470
	tutRawCall tutLoadPointerTarget
	tutJumpNZ 2, .aimplz ;stopped targeting
.shootbrief ;7477
	tutShowBriefing $5EE8
	tutWriteValue spdSTOP, hSpeedTier ;stop!
	tutWriteValue $1, wTutProgress
	tutClearText
	tutScreenText $5f8b
.shootloop ;7486
	tutSetLoopCounter $64
	tutCallPos tutTargetEnemy1
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .destroyedtank
	tutReturnControl
	tutLoop
	tutScreenText $5fa1 ;use A button!
	tutScreenText $5fc5
	tutJump .shootloop
	
.destroyedtank ;749D
	tutSetLoopCounter $6
	tutReturnControl
	tutLoop
	tutShowBriefing $5fd3
	
	tutClearText
	tutScreenText $611f
	tutScreenText $6130
	tutSetLoopCounter $32
	tutReturnControl
	tutLoop
	tutShowBriefing $6143
;74B2
	tutWriteValue $0, hXLoCopy
	tutWriteValue $40, hXHiCopy
	tutWriteValue $0, hYLoCopy
	tutWriteValue $58, hYHiCopy
	tutWriteValue $0, hViewAngle
	tutBarScreen
	tutRawCall TutLoadEnemy1
	tutWriteValue $3, wTutProgress
	tutRawCall tutLoadPointerTarget
	tutJumpIfEqual $2, .alreadytargeted
.aimloop2 ;74D5
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .tankdestroyed2
	tutJumpIfEqual $4, .tanklost
	tutScreenText $6228 ;first, aim at the enemy
	tutScreenText $623b
.brokeaim ;74E6
	tutSetLoopCounter $64
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .tankdestroyed2
	tutJumpIfEqual $4, .tanklost
	tutReturnControl
	tutRawCall tutLoadPointerTarget
	tutJumpIfEqual $2, .killtank2loop ;aimed at tank
	tutLoop
	tutJump .aimloop2
	
.killtank2loop ;74FF
	tutSetLoopCounter $5
	tutReturnControl
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $2, .brokeaim ;make sure we keep reticle on the target
	tutLoop
.alreadytargeted ;750A
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .tankdestroyed2
	tutJumpIfEqual $4, .tanklost
	tutClearText
	tutScreenText $6248 ;approach with LOW speed!
	tutScreenText $6263
	tutSetLoopCounter $32
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .tankdestroyed2
	tutJumpIfEqual $4, .tanklost
	tutLoop
	
	tutRawCall tutCheckPointerTargetDistance
	tutJumpNC $12, .tank2loopend ;close enough
	tutScreenText $628a
	tutSetLoopCounter $1e
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $2, .tankdestroyed2
	tutReturnControl
	tutLoop
.tank2loopend ;7540
	tutJump .killtank2loop

.tankdestroyed2 ;7543
	tutClearText
	tutScreenText $6271 ;good job!
	tutSetLoopCounter $1e
	tutReturnControl
	tutLoop
	tutJump $7554

.tanklost ;754E
	tutShowBriefing $62a2 ;(lost it)
	tutJump $74b2
	
;7554
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
;7558
	tutShowBriefing $635d
	tutWriteValue $8, wHealth ;top off on health
	tutJump .baseapproachloop
	
.timerfail ;7562
	tutClearText
	tutShowBriefing $7df1
.baseapproachloop ;7566
	tutSetTimer $0300, .timerfail
	tutWriteValue $0, hXLoCopy
	tutWriteValue $ff, hXHiCopy
	tutWriteValue $0, hYLoCopy
	tutWriteValue $12, hYHiCopy
	tutWriteValue $0, hZLoCopy
	tutWriteValue $0, hZHiCopy
	tutWriteValue $73, hViewAngle
	tutWriteValue $6, wTutProgress
	tutWriteValue $0, $c2cd ;?
	tutWriteValue spdSTOP, hSpeedTier ;stopped
	tutWriteValue $0, $cb44 ;?
	tutWriteValue $0, $caa7 ;?
	tutWriteValue $8, wHealth ;top off on health again
	tutBarScreen
	tutClearText
	tutScreenText $65ef ;orient here
	tutSetLoopCounter $f
	tutWriteValue spdSTOP, hSpeedTier ;stopped
	tutWriteValue $0, $cb44 ;?
	tutReturnControl
	tutLoadFromAddress hViewAngle
	tutJumpNZ $73, .turned 
	tutDrawArrow $5
	tutLoop
	tutSetLoopCounter $a
	tutLoadFromAddress hViewAngle
	tutJumpNZ $73, .turned 
	tutDrawArrow $5
	tutReturnControl
	tutLoop
.turned ;75C6
	tutClearArrow
	tutClearText
	tutLoadFromAddress hSpeedTier
	tutJumpNZ $2, .notlo ;should be Z?
	tutScreenText $65fd ;low speed plz
	tutWriteValue spdLOW, hSpeedTier
.notlo ;75D6
	tutSetLoopCounter $a
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $7, $76b0 ;todo
	tutLoop
.lospeednag ;75E1
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $2, .goinglospeed
	tutClearText
	tutScreenText $65fd ;low speed plz
	tutSetLoopCounter $1e
	tutJump .checkbasedistance
.goinglospeed ;75F1
	tutClearText
	tutScreenText $661c
	tutScreenText $6632
	tutSetLoopCounter $64
	tutLoadFromAddress hSpeedTier
	tutJumpC $2, .lospeednag
	;else fallthrough to
.checkbasedistance ;7601
	tutRawCall tutGetModel3Distance
	tutJumpC $23, .baseclose
	tutScreenText $7bbe ;what a whiny baby
	tutScreenText $7bc7
	tutSetLoopCounter $14
	tutReturnControl
	tutLoop
	tutJump .baseapproachloop
	
.baseclose ;7615
	tutLoadFromAddress hYHiCopy
	tutJumpNC $f, .notrightspot
	tutJumpC $6, .notrightspot ;jump if out of sweetspot
	tutLoadFromAddress hXHiCopy
	tutJumpIfEqual $0, .insweetspot
	tutJumpIfEqual $ff, .insweetspot ;jump if in sweetspot
.notrightspot ;762B
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $7, $76b0
	tutLoop
	tutJump .lospeednag
	
.insweetspot ;7637
	tutSetLoopCounter $5
	tutReturnControl
	tutLoop
.sweetloop ;763B
	tutLoadFromAddress hYHiCopy
	tutJumpNC $f, .goinglospeed
	tutJumpC $6, .goinglospeed ;jump out if leaving sweetspot
	tutLoadFromAddress hXHiCopy
	tutJumpIfEqual $0, .checkrighthalf ;the right cell!
	tutJumpNZ $ff, .goinglospeed
	tutLoadFromAddress hXLoCopy
	tutJumpC $80, .goinglospeed ;otherwise we still need to go there
	tutJump .rightspot
	
.checkrighthalf ;765B
	tutJumpNC $80, .goinglospeed ;make sure we're in the right half
.rightspot ;765F
	tutLoadFromAddress hSpeedTier
	tutJumpNZ $1, .lospeednag
	tutClearText
	tutScreenText $6646
	tutScreenText $6653
	tutSetLoopCounter $32
	tutRawCall tutLoadPointerTarget
	tutJumpIfEqual $3, .basetargeted
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $7, $76b0
	tutLoop
	tutJump .sweetloop
	
.basetargeted ;7682
	tutSetLoopCounter $5
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $3, .sweetloop ;keep reticle on it
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $7, $76b0
	tutLoop
.basetargetloop
	tutClearText
	tutScreenText $666e ;enter base!
	tutScreenText $6682
	tutSetLoopCounter $23
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $7, $76b0
	tutLoop
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $3, .sweetloop
	tutJump .basetargetloop
	
;76B0
	tutClearTimer
	tutWriteValue $1, $c278 ;?
	tutClearText
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
	tutShowBriefing $66b5
;76BD
	tutLoadFromAddress wEquippedWeapon
	tutJumpIfEqual $0, .gotlockon
	tutJumpIfEqual $4, .gotnothing
.plzgetrightwep ;76C8
	tutRawCall EraseTankEntity
	tutClearText
	tutScreenText $7c11
	tutScreenText $7c27
	tutScreenText $7c41
	tutSetLoopCounter $14
	tutReturnControl
	tutLoop
.gotnothing ;76D9
	tutClearText
	tutScreenText $6683
	tutScreenText $669a
	tutScreenText $66b4
	tutSetLoopCounter $23
	tutReturnControl
	tutLoadFromAddress wEquippedWeapon
	tutJumpIfEqual $0, .gotlockon
	tutLoop
	tutRawCall tutGetModel3Distance
	tutJumpC $23, .stillinrange ;if not too far
	tutClearText
	tutScreenText $7c42
	tutScreenText $7c5c
	tutSetLoopCounter $14
	tutReturnControl
	tutLoop
	tutJump .baseapproachloop ;else restart
.stillinrange ;7703
	tutJump $76bd
	
.gotlockon ;7706
	tutClearText
	tutScreenText $7cd4
	tutScreenText $7ceb
	tutSetLoopCounter $23
	tutDrawArrow $a
	tutReturnControl
	tutLoop
	tutClearArrow
	tutClearText
	tutScreenText $6825 ;have some missiles lol
	tutScreenText $682f
	tutWriteValue $8, wMissileCount
	tutWriteValue $8, wHealth
	tutSetLoopCounter $23
	tutDrawArrow $6
	tutReturnControl
	tutLoop
	tutClearArrow
;772A
	tutClearText
	tutScreenText $7d4a ;look for the enemy!
	tutScreenText $7d5d
	tutSetLoopCounter $64
	tutReturnControl
	tutRawCall tutGetModel3Distance
	tutJumpNC $28, $773f ;if close enough, escape loop
	tutLoop
	tutJump $772a
;773F
	tutLoadFromAddress wEquippedWeapon
	tutJumpNZ $0, .stillinrange ;changed weapon??
	tutRawCall TutLoadEnemy1
	tutWriteValue $8, wTutProgress
	tutSetLoopCounter $a
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, $72b2 ;what triggers this?? "Y U NO follow directions"
	tutLoop
.lockonaimloop ;7758
	tutLoadFromAddress wEquippedWeapon
	tutJumpNZ $0, .plzgetrightwep ;changed weapon??
	tutClearText
	tutScreenText $684C ;aim at the enemy!
	tutScreenText $6861
	tutSetLoopCounter $a
	tutCallPos tutTargetEnemy1
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, $72b2 ;???
	tutLoop
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $2, .lockonaimloop ;not tank, loop
	tutClearText
	tutRawCall tutLoadClosestEntityModel
	tutJumpIfEqual $2, .lockonclosetotank ;tank still happening
	tutShowBriefing $6872 ;found a different model, so tank destroyed??
.lockonapproackloop ;7786
	tutClearText
	tutScreenText $6a2b ;aim at the tank and slowly approach!
	tutScreenText $6a3b 
	tutSetLoopCounter $32
	tutRawCall tutCheckPointerTargetDistance
	tutJumpC $c, .lockonmissilecheck ;close enough
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, $72b2 ;???
	tutCallPos tutTargetEnemy1
	tutLoop
	tutJump .lockonapproackloop
	
.lockonmissilecheck ;77A5
	tutLoadFromAddress wMissileCount
	tutJumpNZ $0, .stillhasmissiles
	tutClearText
	tutScreenText $7b8d ;used the missiles!
	tutScreenText $7ba0
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutWriteValue $8, wMissileCount ;restock
.stillhasmissiles ;77BB
	tutLoadFromAddress wEquippedWeapon
	tutJumpNZ $0, .plzgetrightwep
	tutClearText
	tutScreenText $6a54 ;lock on with B button!
.lookattankplz ;77C6
	tutSetLoopCounter $23
	tutRawCall tutLoadClosestEntityModel
	tutJumpIfEqual $2, .lockonclosetotank
	tutCallPos tutTargetEnemy1
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, $72b2 ;mystery scolding
	tutLoop
	
.lockonclosetotank ;77DB
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $2, .lookattankplz ;not pointed at tank, jump
	tutRawCall tutLoadClosestEntityModel
	tutJumpNZ $2, .lockonmissilecheck ;pointed at, but closest isn't tank?
	tutScreenText $6aa6 ;good! now follow in low gear
	tutScreenText $6ac8
	tutScreenText $6ad0
	tutSetLoopCounter $23
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, $72b2 ;mystery
	tutReturnControl
	tutLoop
	tutRawCall tutLoadClosestEntityModel
	tutJumpIfEqual $2, $7833 ;closest is tank, jump
.missedtank ;7804
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $2, .lockonaimloop ;not pointed at tank?
	tutClearText
	tutSetLoopCounter $32
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, .lockondone
	tutLoop
	tutRawCall tutLoadPointerTarget
	tutJumpNZ $2, .lockonaimloop ;not pointed at tank
	tutRawCall tutLoadClosestEntityModel
	tutJumpIfEqual $2, .plzfiremissile ;tank is closest
	tutLoadFromAddress wEquippedWeapon
	tutJumpNZ $0, .plzgetrightwep
	tutClearText
	tutScreenText $6a54 ;use the B button!
	tutJump .plzfiremissile
	
.lockedonloop ;7833
	tutClearText
	tutScreenText $6a74 ;alright, press the B button again!
	tutScreenText $6a81
.plzfiremissile ;783A
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $a, .lockondone
	tutRawCall tutLoadClosestEntityModel
	tutJumpNZ $2, .missedtank
	tutJump .lockedonloop
	
.lockondone ;784F
	tutClearText
	tutScreenText $6271
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutShowBriefing $6bb3
	
;785A
	tutWriteValue $0, hXLoCopy
	tutWriteValue $40, hXHiCopy
	tutWriteValue $0, hYLoCopy
	tutWriteValue $58, hYHiCopy
	tutWriteValue $8, wHealth
	tutBarScreen
	tutWriteValue $0, wMissileCount ;don't need these anymore
	tutWriteValue $3c, $c2eb ;?
	tutWriteValue spdSTOP, hSpeedTier ;stop!
	tutRawCall tutLoadEnemy2
	tutScreenText $6ee6 ;please wait until the cursor appears!
	tutScreenText $6eff
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
.followCompass ;7888
	tutScreenText $6f19 ;center the cursor and follow it slowly!
	tutScreenText $6f2d
	tutScreenText $6f3f
.compassLoop
	tutSetLoopCounter $32
	tutCallPos tutMissileCheck
	tutReturnControl
	tutLoadFromAddress wMissileCount
	tutJumpNZ $0, .gotmissile ;progress
	tutLoadFromAddress hSpeedTier
	tutJumpNZ $2, .speednag
	tutLoop
	tutJump .followCompass
	
.speednag ;78A9
	tutClearText
	tutScreenText $65fd ;use LOW gear!!!
	tutJump .compassLoop
	
.gotmissile ;78B0
	tutClearText
	tutScreenText $6f4f ;good job
	tutScreenText $6f57
	tutSetLoopCounter $23
	tutDrawArrow $6
	tutReturnControl
	tutLoop
	tutClearArrow
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
;78C2
	tutShowBriefing $6f77
	
.resettunnel ;78C5
	tutWriteValue $0, hXLoCopy
	tutWriteValue $42, hXHiCopy
	tutWriteValue $0, hYLoCopy
	tutWriteValue $42, hYHiCopy
	tutWriteValue $0, hZLoCopy
	tutWriteValue $0, hZHiCopy
	tutWriteValue $8, wHealth
	tutWriteValue $0, hZPosLow
	tutWriteValue $0, hZPosHi
	tutBarScreen
	tutWriteValue $a0, hViewAngle
	tutWriteValue $b, wTutProgress
	tutWriteValue $0, $c2cd ;?
	tutWriteValue spdSTOP, hSpeedTier ;stop!
	tutClearText
	tutScreenText $73e9 ;enter the tunnel entrance!
	tutScreenText $7405
	tutSetLoopCounter $1e
	tutLoadFromAddress wTutProgress
	tutJumpIfEqual $c, $7946 ;progress
	tutReturnControl
	tutLoop
	tutClearText
	tutScreenText $741d ;tunnel leads to a junction
	tutScreenText $7436
	tutSetLoopCounter $32
	tutLoadFromAddress $c295
	tutJumpIfEqual $c, $7946 ;progress
	tutReturnControl
	tutLoop
.tunnelloop ;791E
	tutScreenText $7448 ;carefully time the approach!
	tutScreenText $7459
	tutScreenText $7470
	tutSetLoopCounter $32
	tutLoadFromAddress $c295
	tutJumpIfEqual $c, $7946 ;progress
	tutReturnControl
	tutLoop
	tutRawCall tutGetTunnelDistance
	tutJumpC $19, .tunnelloop ;still close
	tutScreenText $7c76 ;enter the tunnel!!!
	tutScreenText $7c8f
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutJump .resettunnel
	
;7946
	tutClearText
	tutScreenText $7471
	tutScreenText $7483
	tutSetLoopCounter $19
	tutReturnControl
	tutWriteValue $0, $ca88 ;?
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, .skiptunhealthchk ;if flying??
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
.skiptunhealthchk
	tutLoop
	tutClearText
	tutScreenText $748b ;can't control your speed now!
	tutScreenText $74a5
	tutSetLoopCounter $19
	tutReturnControl
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, .skiptunhealthchk2
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
.skiptunhealthchk2
	tutLoop
	tutClearText
	tutScreenText $74af ;up and down controls height!
	tutScreenText $74ca
	tutSetLoopCounter $19
	tutReturnControl
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, .skiptunhealthchk3
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
.skiptunhealthchk3
	tutLoop
	tutClearText
	tutScreenText $74e4 ;hitting a wall causes damage!
	tutScreenText $74fe
	tutSetLoopCounter $19
	tutReturnControl
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, .skiptunhealthchk4
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
.skiptunhealthchk4
	tutLoop
	tutSetLoopCounter $64
	tutReturnControl
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $5, .skiptunhealthchk5 ;this one checks for tunnel?
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
.skiptunhealthchk5
	tutLoop
.tunnelrunloop ;79C0
	tutReturnControl
	tutLoadFromAddress hSpeedTier
	tutJumpNZ $6, .donetunnel ;if not 6, progress?
	tutJump .tunnelrunloop
	
.donetunnel ;79CB
	tutLoadFromAddress hSpeedTier
	tutJumpIfEqual $6, .donetunnel ;we back in the tunnel? then wait
	tutLoadFromAddress wHealth
	tutJumpIfEqual $0, tutTunnelHealthZero
	tutRawCall tutLoadRamp
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
	tutClearText
	tutShowBriefing $751a
	
;79E4
	tutWriteValue $1, hPauseFlag ;force pause to loop at the map
	tutReturnControl
	tutShowBriefing $7641
	
;79EC
	tutWriteValue $0, $c296 ;?
.pyramidresetpos ;79F0
	tutWriteValue $0, hXLoCopy
	tutWriteValue $a5, hXHiCopy
	tutWriteValue $0, hYLoCopy
	tutWriteValue $45, hYHiCopy
	tutWriteValue $0, hZLoCopy
	tutWriteValue $0, hZHiCopy
	tutWriteValue $0, hZPosLow
	tutWriteValue $0, hZPosHi
	tutWriteValue $ff, wFuelAmountLo
	tutWriteValue $f0, wFuelAmountHi
	tutWriteValue $0, wFlyingFlag
	tutWriteValue $6, wGoalEntityID
	tutBarScreen
	tutWriteValue spdSTOP, hSpeedTier ;stop!
	tutWriteValue $80, hViewAngle
	tutWriteValue $0, wTutProgress ;??
	tutClearTimer
.pyramidapproachloop ;7A2E
	tutClearText
	tutScreenText $7a00 ;approach the pyramid!
	tutScreenText $7a1b
	tutSetLoopCounter $64
	tutReturnControl
	tutRawCall tutGetPyramidDistance
	tutJumpC $32, .pyramidclose
	;far from pyramid
	tutLoadFromAddress wFlyingFlag
	tutJumpNZ $0, .pyramidclose ;if not zero like we set it, progress
	tutClearText ;else
	tutScreenText $7c5d ;approach it, you know you want to
	tutScreenText $7c75
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutJump .pyramidresetpos

.grounded ;7A54
	tutLoadFromAddress $c296 ;?
	tutJumpNZ $0, .pyramidclose ;progress
	tutClearText
	tutScreenText $7c90 ;Hold altitude with + and keep flying
	tutScreenText $7ca4
	tutScreenText $7cb8
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutJump .pyramidresetpos
	
.pyramidclose ;7A6C, close enough
	tutLoadFromAddress wFlyingFlag
	tutJumpNZ $0, .flying ;next progress
	tutReturnControl
	tutLoop
	tutJump .pyramidapproachloop

.flying ;7A78
	tutWriteValue $7f, wGoalEntityID
	tutWriteValue $0, wGoalEntityPointerLo
	tutWriteValue $0, wGoalEntityPointerHi
	tutClearText
	tutScreenText $7a33 ;we have lifdoff!
	tutScreenText $7a3b
	tutSetLoopCounter $23
	tutReturnControl
	tutLoadFromAddress wFlyingFlag
	tutJumpIfEqual $0, .grounded
	tutLoop
	tutLoadFromAddress $c296
	tutJumpNZ $0, $7acc
	tutScreenText $74af ;reused from tunnel brief
	tutScreenText $74ca
	tutSetLoopCounter $23
	tutReturnControl
	tutLoadFromAddress wFlyingFlag
	tutJumpIfEqual $0, .grounded
	tutLoop
	tutScreenText $7a4d ;this is the altimeter!
	tutScreenText $7a6a
	tutSetLoopCounter $23
	tutDrawArrow $7
	tutReturnControl
	tutLoop
	tutClearArrow
	tutSetLoopCounter $a
	tutReturnControl
	tutLoop
	tutScreenText $7a6b ;turbo costs fuel!
	tutScreenText $7a83
	tutSetLoopCounter $23
	tutDrawArrow $8
	tutReturnControl
	tutLoop
	tutClearArrow
;7ACC
	tutLoadFromAddress wFlyingFlag
	tutJumpIfEqual $0, .grounded
	tutLoadFromAddress hZPosHi
	tutJumpIfEqual $0, $7aff
	tutReturnControl
	tutClearText
	tutScreenText $7f73 ;you're a little too high.
	tutJump $7acc
	
.failedRingTimer ;7AE2
	tutClearText
	tutScreenText $7f2c ;you have to fly through the frames! try again.
	tutScreenText $7f48
	tutScreenText $7f62
	tutWriteValue $0, wTutProgress
	tutWriteValue $0, wFlyingFlag
	tutSetLoopCounter $23
	tutReturnControl
	tutLoop
	tutWriteValue $1, $c296
	tutJump .pyramidresetpos
	
;7AFF
	tutClearText
	tutScreenText $7e8d ;fly through the square frames.
	tutScreenText $7ea3
	tutSetTimer $0064, .failedRingTimer
	tutRawCall tutFinalMission
.ringloop ;7B0E
	tutReturnControl
	tutLoadFromAddress wTutProgress
	tutJumpNZ $f, .ringloop
	tutWriteValue $0, wTutProgress
	tutShowBriefing $7aa3
	tutWriteValue $a, wTutEndTimer
.endloop
	tutReturnControl
	tutJump .endloop
	;this is the end of the tutorial sequence
	
tutFinalMission: ;7B25
	call TutSetupRings
	ret

EraseTankEntity: ;7B29
	ld hl, wEntityTable
	ld a, $02
	call CallFindEntityWithModel
	ret c
	xor a
	ld [hl+], a
	ret
	
tutGetTunnelDistance: ;7B35
	ld hl, wEntityTable
	ld a, $30
	call CallFindEntityWithModel
.loop
	ld a, $FF
	jr c, tutGetModel3Distance.skeep
	inc hl
	call CallGetDistanceFromPlayer
	jr c, .loop
	jr tutGetModel3Distance.skeep
	
tutGetPyramidDistance: ;7B49
	ld hl, $C302
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ld a, $FF
	jr z, tutGetModel3Distance.skeep
	call CallGetDistanceFromPlayer
	jr nc, tutGetModel3Distance.skeep
	ld a, $FF
	jr tutGetModel3Distance.skeep

tutGetMissileDistance: ;7B5D
	ld hl, wEntityTable
	ld a, $3C
	call CallFindEntityWithModel
.loop
	ld a, $FF
	jr c, tutGetModel3Distance.skeep
	inc hl
	call CallGetDistanceFromPlayer
	jr c, .loop
	jr tutGetModel3Distance.skeep

tutGetModel3Distance: ;7B71
	ld hl, wEntityTable
	ld a, $03
	call CallFindEntityWithModel
.loop
	ld a, $FF
	jr c, .skeep
	inc hl
	call CallGetDistanceFromPlayer
	jr c, .loop
.skeep
	ld [wTutRegister], a
	ret

tutGetTankDistance: ;7B87
	ld hl, wEntityTable
	ld a, $02
	call CallFindEntityWithModel ;HL is now positioned at the entity data
.loop
	ld a, $FF
	jr c, .notfound ;if none found, skip
	inc hl
	call CallGetDistanceFromPlayer ;a is distance, carry is Y>X
	jr c, .loop ;loop if y is the farther axis (need to get closer)
.notfound
	ld [wTutRegister], a ;FF here when Y closer than X
	ret
	
tutRefreshEnemy1: ;7B9D
	ld hl, wEntityTable
	ld a, $02
	call CallFindEntityWithModel
	ret c ;if none, return
	ld a, $02
	ld [hl+], a ;otherwise set model back to 2
	ldh a, [$FFAC]
	ld [hl+], a
	call NextRand
	and $03
	sub $06
	ld c, a
	ldh a, [$FFAD] ;randomize x again?
	sub a, c
	ld [hl+], a
	ldh a, [$FFAA]
	ld [hl+], a
	ldh a, [$FFAB] ;our Y - 0900
	sub $09
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a ;z of zero
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;orientation of zero
	ld a, $71
	ld [hl+], a ;x speed $71?
	ld a, $30
	ld [hl+], a ;y speed $30?
	ld a, $0D
	ld [hl+], a ;Z speed $0D?
	ret

TutLoadEnemy1: ;7BD1
	call GetFreeEntity
	ret c ;return if none found
	ld a, $02
	ld [hl+], a ;write model ID 2
	ldh a, [hXLoCopy]
	ld [hl+], a
	call NextRand
	and $03
	sub $06
	ld c, a ;this is a modifyer?
	ldh a, [hXHiCopy]
	sub a, c ;variance in X position
	ld [hl+], a
	ldh a, [hYLoCopy]
	ld [hl+], a
	ldh a, [hYHiCopy]
	sub $09 ;minus 9 for Y. always behind?
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a ;0 for z position
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;0 for xyz orientation
	ld a, LOW(CallTutorialEntityLogic)
	ld [hl+], a
	ld a, HIGH(CallTutorialEntityLogic)
	ld [hl+], a ;$3071 for logic pointer
	ld a, $0D
	ld [hl+], a ;$0D for HP
	xor a
	ld [wTutProgress], a ;0 into C295
	ret
	
tutLoadRamp: ;7C04
	ld hl, wEntityTable
	ld a, $0B
	call CallFindEntityWithModel
	ret nc ;if exists, return
	call GetFreeEntity
	ret c ;if no free slots, return
	ld e, l
	ld d, h
	ld a, $0B
	ld [hl+], a ;model B (ramp?)
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;0 out its position
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;0 out its orientation
	ld [hl+], a
	ld [hl+], a
	ld a, $C8
	ld [hl+], a ;z speed? down?
	ld a, e
	add a, $18
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld [hl], $00 ;set the z speed of the next entity to 0???
	ret

tutLoadEnemy2: ;7C31
	call GetFreeEntity
	ret c ;no free slots :(
	ld a, $3C
	ld [hl+], a
	ldh a, [hXLoCopy]
	ld [hl+], a
	call NextRand
	and $03
	sub $04
	ld c, a
	ldh a, [hXHiCopy]
	sub a, c
	ld [hl+], a
	ldh a, [hYLoCopy]
	ld [hl+], a
	ldh a, [hYHiCopy]
	sub $0A
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $45
	ld [hl+], a
	ld a, $7E
	ld [hl+], a
	ld a, $C8
	ld [hl+], a
	ret
	
tutRefreshMissile: ;7C60
	ld hl, wEntityTable
	ld a, $3C
	call CallFindEntityWithModel
	jp c, tutLoadEnemy2 ;if none, jump
	ld a, $3C
	ld [hl+], a ;refresh the model
	ldh a, [hXLoCopy]
	ld [hl+], a
	call NextRand
	and $03
	sub $04
	ld c, a
	ldh a, [hXHiCopy]
	sub a, c
	ld [hl+], a
	ldh a, [hYLoCopy]
	ld [hl+], a
	ldh a, [hYHiCopy]
	sub $0A
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $45
	ld [hl+], a
	ld a, $7E
	ld [hl+], a
	ld a, $C8
	ld [hl+], a
	ret

tutLoadClosestEntityModel: ;7C96
	ld a, [$CACF] ;?
	cp $03
	ld a, $00
	jr nz, tutLoadPointerTarget.empty
	ld hl, wNearestEntityPtr
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr z, tutLoadPointerTarget.empty
	dec hl
	ld a, [hl+]
	ld [wTutRegister], a
	ret

tutLoadPointerTarget: ;7CAE
	ld hl, $CB08 ;pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr z, .empty
	dec hl
	ld a, [hl+]
.empty
	ld [wTutRegister], a
	ret
	
tutCheckPointerTargetDistance: ;7CBD
	ld hl, $CB08 ;pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ld a, $FF
	jr z, tutLoadPointerTarget.empty
	call CallGetDistanceFromPlayer
	ld [wTutRegister], a
	ret
	
TutRefPoint1: ;7CCF
	dw $78C2 ;finished missile lockon tut
TutRefPoint2: ;7CD1
	dw $7558 ;before radar base brief
TutRefPoint3: ;7CD3	
	dw $79E4 ;looks at the map, before pyramid brief

PlayDemo: ;7CD5
	call CallRestoreGUIAndMusic
	call NextRand
	and %00011110 ;multiples of two
	add a, LOW(DemoTunnelPointers)
	ld l, a
	ld a, HIGH(DemoTunnelPointers)
	adc a, $00
	ld h, a ;HL is in table 7CF5
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;pointer from table is now in HL
	ld a, $01
	ld [$C304], a
	call LoadTunnel
	xor a
	ld [$C304], a
	ret
	
DemoTunnelPointers: ;7CF5, these are pointers into bank 9
	dw $4069 
	dw $41DA 
	dw $42BA 
	dw $4585 
	dw $46A8 
	dw $475F 
	dw $475F 
	dw $475F 
	dw $49AF 
	dw $4AA6 
	dw $4B97 
	dw $4C84 
	dw $4D6D 
	dw $4E57 
	dw $4F41 
	dw $5074 
	
CheckSpecialArrowCases: ;7D15
	ld a, [$C272]
	sub $01 ;decrement C272
	jr c, .zero
	ld [$C272], a
	ret
.zero
	ld hl, $CB08
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret z ;if pointer blank, ret
	dec hl
	ld a, [hl+] ;load value before
	cp $03
	jr z, .case3
	cp $30
	jr z, .generalcase
	cp $0B
	jr z, .generalcase
	cp $18
	jr z, .case18
	ret
.case18
	ldh a, [hViewAngle]
	sub $30
	cp $20
	ret nc ;return if angle's not $30-$49
	jr .generalcase
.case3
	ldh a, [hViewAngle]
	add a, $10
	cp $20
	ret nc ;return if angle's not $F0-$09
.generalcase
	ld a, [wUpdateCounter]
	and $03 ;three out of every four updates, 
	call nz, CallDrawEntryArrow ;call this
	ret
	
DrawDemoModeText: ;7D54, prints demo mode
	ld hl, DemoModeGFX
	ld de, $D408 ;target, in the 1bpp buffer
	ld b, $08
.loop
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld e, $08
	inc d
	dec b
	jr nz, .loop
	ret
DemoModeGFX: ;7D84 - 7DDB
	INCBIN "build/gfx/DemoMode.1bpp"
;7DDC 

SECTION  "F:7E45", ROMX[$7E45], BANK[$F]
;7E45
	