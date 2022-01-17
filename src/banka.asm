SECTION "A:TOP", ROMX[$4000], BANK[$A]
LevelStartingCoords: ;4000
	db $E0, $94 
	db $A0, $54 
	db $A0, $54 
	db $A0, $54 
	db $A0, $54 
	db $20, $D8 
	db $A0, $54 
	db $A0, $54 
	db $E0, $10 
	db $A0, $54 
	db $A0, $54 
	db $A0, $54

;4018
	dw Recap1Page1Text  ;these all point into bank 5
	dw Recap2Text 
	dw Recap3Text
	dw Recap4Text 
	dw Recap5Text 
	dw Recap6Text
	dw Recap7Text 
	dw Recap8Text
	dw Recap9Text
	dw Recap10Text 
	dw Recap1Page1Text 
	dw RecapTrainingPageText
	dw Recap1Page1Text
	
FlashEntityCell: ;4032, passed C will be timer duration
	inc hl ;ent pointer
	ld a, [hl+] ;high x
	add a, $80 ;set carry if top bit set
	rlca
	rlca ;rotate carry and top bit to the bottom
	and $03 ;mask them
	ld b, a ;save to B
	inc hl
	ld a, [hl+] ;high y
	cpl
	add a, $81 ;negate and set carry if top bit set
	swap a ;swap nybbles
	and $0C ;mask
	add a, b ;combine the XY bits into one nybble
	ld [wGoalCellID], a
	ld a, c
	ld [wGoalCellTimer], a
	ret

SetupLevel: ;404D
	call ClearAllEntities
	xor a
	ld [$C287], a
	ld [$CA8C], a
	ld [$CB4A], a
	ld [wTutEndTimer], a
	ldh [$FFA5], a
	ldh [$FFA3], a
	ldh [$FFA4], a
	ld [$C2C8], a
	ld [$C2C9], a
	ld [$C2CA], a
	ld [$C2CB], a
	ld [$C2DC], a
	ldh [$FFF6], a
	ldh [$FFF8], a
	ldh [$FFFA], a
	ldh [$FFFC], a
	ldh [hXPosLow], a
	ldh [hYPosLow], a
	ld [$C32C], a
	ld [$C319], a
	ld [$C2C2], a
	ld [$CA88], a
	ld [$C2C7], a
	ld [wScreenShakeCounter], a
	ld [$C2DA], a
	ld [$C0AE], a
	ld [wRadarBaseCount], a
	ld hl, wEntityDestroyedFlags
	ld b, $20
.clearobjflags
	ld [hl+], a
	dec b
	jr nz, .clearobjflags
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ld a, $00
	jr nz, .nottut
	ld a, $80
.nottut
	ld hl, wRadarBasesTable
	ld b, $08
.mappiploop
	ld [hl+], a
	dec b
	jp nz, .mappiploop
	call CallSetLevelTimer
	ld a, $14
	ldh [hZLoCopy], a
	ldh [hZPosLow], a
	ld a, $00
	ldh [hZHiCopy], a
	ldh [hZPosHi], a
	ld a, $32
	ld [unkMagnitude], a
	ld a, $80 ;180 degrees
	ld [unkAngle], a
	call MagnitudeAndAngleToCoords
	xor a
	ld [$C29B], a
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF0], a
	ldh [$FFF2], a
	ldh [$FFEE], a
	loadpalette 3, 3, 1, 0
	ldh [rBGP], a
	xor a
	ld [wScrollYFlag], a
	ld a, $60
	ldh [rLYC], a
	ld a, (1 << rSTAT_LYC)
	ldh [rSTAT], a
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	or (1 << LCD_STAT)
	ldh [rIE], a
	xor a
	ld [$C2D9], a
	ld [$CB49], a
	ld [$C29A], a
	ld [$C359], a
	ld [$C35A], a
	ldh [hYLoCopy], a
	ldh [hXLoCopy], a
	ldh [hViewAngle], a
	ld [wFlyTilt], a
	ld [$CB42], a
	ld [wSubscreen], a
	ld [wAnimDisable], a
	ld [$C2BF], a
	ld [$C2C0], a
	ld [$C29A], a ;duplicate from above?
	ld [$CB15], a
	ld [$CB47], a
	ld [$C2FD], a
	ld [$C2E9], a
	ld [$C2EA], a
	ld [$C330], a
	ld [wInventory1], a
	call ClearAllScreenText
	ld a, $D0
	ld [$C2FE], a
	ld a, $78
	ld [$CB44], a
	ld [$CA88], a
	xor a
	ld [$CAA7], a
	ld a, spdSTOP
	ldh [hSpeedTier], a ;stop!
	ld a, $34
	ld [wPitchAngle], a
	ld [wPitchLurch], a
	call CallDrawMaxedHorizon
	call CallDrawRadarBG
	ld a, $01
	ldh [hGameState], a
	ld [$CA9C], a
	ld a, [wDidTetamusTunnel]
	or a
	jr z, .jumpD
	ld a, $01
	ld [wScoreHundredThousands], a
	ld a, $3F
	ld [wMaxHealth], a
	ld [wHealth], a ;???
.jumpD
	ld a, $08
	ld [wHealth], a
	ld a, [wCurLevel]
	rrca
	and $FE ;level as word offset
	add a, LOW(LevelStartingCoords)
	ld l, a
	ld a, HIGH(LevelStartingCoords)
	adc a, $00
	ld h, a ;table at the top of the bank
	ld a, [hl+]
	ldh [hXPosHi], a
	ldh [hXHiCopy], a
	ld a, [hl+]
	ldh [hYPosHi], a
	ldh [hYHiCopy], a
	call CallIterateOverMapObjects
	call CallLoadGoalEntityID
	call CallSetLevelTitle
	ret
	
IF UNUSED == 1
GetAdvice: ;41AE
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, StaffRollTilemap
	call LoadBank7TilesetOffset80
	ld hl, res_Advice
	ld de, $9822
	ld c, $01
	call CallContinueEnglishParser
	call LoadContinueFont
	call WaitForNoNewInput
	ret
ENDC

MissionResultsScreen: ;41CC
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, MissionResultsBorderTilemap
	call LoadBank7TilesetOffset80
	ld hl, res_Mission
	ld de, $9826
	ld c, $01
	call CallContinueEnglishParser
	xor a
	ld [$C2C5], a
	ld [$C2C6], a
	ld a, $04
	ld [wQueueMusic], a
	call CallDrawContinueBottomBox
	ld hl, res_Master
	ld de, $9881
	ld c, $00
	call CallContinueEnglishParser
	ld a, [$C2C6]
	or a
	jp z, .noSmall
.addSmallLoop ;4204
	push af
	ld a, [wSmallStars]
	inc a
	ld [wSmallStars], a
	sub 10
	jr c, .notten
	ld [wSmallStars], a
	ld a, [wBigStars]
	inc a
	ld [wBigStars], a
	ld a, $02
	ld [wQueueSFX], a
	jr .staradded
.notten
	ld a, $01
	ld [wQueueSFX], a
.staradded
	ld hl, $9A07 ;big stars in Total
	ld a, [wBigStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	ld hl, ContinueScreenDoubleSpace
	ld c, $01
	call CallContinueEnglishParser
	ld hl, $9A0F ;small stars in Total
	ld a, [wSmallStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	ld hl, ContinueScreenDoubleSpace
	ld c, $01
	call CallContinueEnglishParser
	call Wait13VBlanks
	pop af
	dec a
	jp nz, .addSmallLoop
.noSmall ;425A
	ld a, [$C2C5]
	or a
	jp z, .noBig
.addBigLoop ;4261
	push af
	ld a, [wBigStars]
	inc a
	ld [wBigStars], a
	ld a, $09
	ld [$C100], a
	ld hl, $9A07
	ld a, [wBigStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	ld hl, ContinueScreenDoubleSpace
	ld c, $01
	call CallContinueEnglishParser
	ld hl, $9A0F
	ld a, [wSmallStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	ld hl, ContinueScreenDoubleSpace
	ld c, $01
	call CallContinueEnglishParser
	ld b, $19
	call Wait13VBlanks.loop
	pop af
	dec a
	jp nz, .addBigLoop
.noBig ;42A4
	ld a, [wCurLevel]
	add a, $04
	ld [wCurLevel], a
	call CallWriteSave
	ld a, [wCurLevel]
	sub $04
	ld [wCurLevel], a
	ld d, $1E
	call WaitFrames
	call WaitForNoNewInput
	ret

RecapText: ;42C0
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, $9800
	ld b, $00
	ld a, $80
.setloop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .setloop
	di
	ld hl, $9823 ;start position of the recap text
	ld bc, $0F80 ;counter and tile
	ld a, $90 ;first tile ID
.outerloop
	push bc ;save counter
	ld b, $10
.innerloop
	ld [hl+], a
	add a, $0F
	dec b
	jr nz, .innerloop
	ld bc, $0010
	add hl, bc
	pop bc
	inc c
	ld a, c
	add a, $10
	dec b
	jr nz, .outerloop
	call .copytextgfx ;the tiles are set up by this point
	xor a
	ldh [hGameState], a
	ld a, [$C0AF] ;load level progress?
	rrca ;multiply by two, for word offsets
	and $FE ;mask
	add a, $18
	ld l, a
	ld a, $40
	adc a, $00
	ld h, a ;pointer table at 4018
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;pointer loaded
	ld a, $20
	ld [$CB1C], a
	ld a, [$C0AF] ;based on C0AF,
	or a
	jr z, .b1 ;load C108 with a value
	cp $24
	jr z, .b2
	jr .b3
.b1
	ld a, $14 ;if C0AF is 0,
	ld [$C108], a ;load with $14
	jr .bend
.b2
	ld a, $1C ;if C0AF is $24,
	ld [$C108], a ;load with $1C
	jr .bend
.b3
	ld a, $14 ;else,
	ld [$C108], a ;load with $14
.bend
	ld bc, $2020
	call CallDrawTitleLetters
	push hl
	call .copytextgfx
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a
	jr nz, .skeep
	ld a, $F8
	ld [wTargetSCY], a
	ldh [rSCY], a
	ld a, $08
	ldh [rSCX], a
	ld a, $FF
	ldh [rWX], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ei
	ld a, $B4
	ldh [rBGP], a
	ld a, $A3
	call CallFlashScreen
.skeep
	ld d, $1E
	call WaitFrames
	call WaitForNoNewInput
	pop hl
	call GetSimpleByteFromBank5
	ld a, c
	or a
	jp nz, .bend
	ret
	
.copytextgfx ;436F
	ld hl, $8900
	ld de, wMonoBufferColumn1
	ld b, $10
	inc l
.cpyouterloop
	push bc ;save counter
.cpyinnerloop
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	inc e
	ld a, [de]
	inc e
	inc e ;read three bytes into CBA
	push de ;save read position
	push af ;save third read byte
	dec e
	ld a, [de]
	ld d, a ;save fourth byte into D
	pop af ;CBAD
	ld e, a ;make that CBED
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
	ld [hl+], a ;write those four bytes into tiledata
	inc l
	pop de ;restore read position
	ld a, e
	sub $04 ;go back four
	ld e, a
	xor a
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e ;clear out the four bytes just read
	ld a, e
	cp $78
	jr c, .cpyinnerloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .cpyouterloop
	ret
	
MoveEntityBySpecifiedAmts: ;43B6
	push hl
	push hl ;save ent pointer twice
	push bc ;loaded before calling, save it
	ld c, a ;the passed a (for example, $50)
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;ent pointer + 6, X orientation
	ld a, [hl+]
	or a
	jr z, .doneX
	ld d, a
	push hl
	call CallRotateCoordByAngle
	pop hl
.doneX
	pop de ;the passed word
	ld d, c
	ld c, e
	inc hl ;to y orientation
	ld a, [hl-]
	or a
	jr z, .doneY
	push de
	push hl
	ld d, a
	call CallRotateCoordByAngle
	pop hl
	pop de
.doneY
	ld a, b
	ldh [$FFD1], a ;save to scratch area
	ld b, d
	ld d, [hl] ;z orientation
	xor a
	sub a, d ;negate it
	jr z, .doneZ
	ld d, a
	call CallRotateCoordByAngle
.doneZ
	pop hl ;restore ent pointer - B and C hold two new orientations, and another's in ram
	ld e, b
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;bc is sign-extended resulting C
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;de is sign-extended resulting B
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;ent x += bc
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl+], a ;ent z += de
	ldh a, [$FFD1]
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;sign-extend scratch value into de
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl+], a ;ent y += de
	pop hl ;restore ent pointer
	ret
	
MoveEntityForward: ;4419
	;the coord in BC is the XY vector to move (in local model space)
	push hl
	push hl ;save ent pointer twice
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld d, [hl] ;z orientation
	xor a
	sub a, d
	ld d, a ;negated
	call CallRotateCoordByAngle
	pop hl ;restore pointer
	ld e, b
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;extend c into BC
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend b into DE
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl+], a
	pop hl
	ret
	
SpeedLevelGraphics: ;0x444A-0x464A: speed graphics
	INCBIN "build/gfx/SpeedLevels.2bpp"

DrawMissileCount: ;464A
	;this could be greatly simplified, yuck
	ldh a, [hGameState]
	dec a
	jr nz, .stateskip
	ld a, [$C2A1]
	cpl
	and $03
	ret nz
.stateskip
	ld hl, $99D3 ;missile graphic spot
	ld a, [wMissileCount]
	ld b, a
	or a
	jp z, .nm8l ;zero missiles
.mloop1
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop1
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm7l ;one missile
.mloop2
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop2
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm6 ;two missiles
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;go to the next row
.mloop3
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop3
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm5l ;three missiles
.mloop4
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop4
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm4 ;four missiles
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
.mloop5
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop5
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm3l ;five missiles
.mloop6
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop6
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm2 ;six missiles
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
.mloop7
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop7
	ld a, $85
	ld [hl+], a
	dec b
	jp z, .nm1l ;seven missiles
.mloop8
	ldh a, [rSTAT]
	and $02
	jr nz, .mloop8
	ld a, $85
	ld [hl+], a ;eight misiles
	ret
	
.nm8l ;46DE
	ldh a, [rSTAT]
	and $02
	jr nz, .nm8l
	ld a, $86
	ld [hl+], a
.nm7l ;46E7
	ldh a, [rSTAT]
	and $02
	jr nz, .nm7l
	ld a, $86
	ld [hl+], a ;identical to above
.nm6 ;46F0
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
.nm6l
	ldh a, [rSTAT]
	and $02
	jr nz, .nm6l
	ld a, $86
	ld [hl+], a
.nm5l ;4701
	ldh a, [rSTAT]
	and $02
	jr nz, .nm5l
	ld a, $86
	ld [hl+], a
.nm4 ;470A
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
.nm4l
	ldh a, [rSTAT]
	and $02
	jr nz, .nm4l
	ld a, $86
	ld [hl+], a
.nm3l ;471B
	ldh a, [rSTAT]
	and $02
	jr nz, .nm3l
	ld a, $86
	ld [hl+], a
.nm2 ;4724
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
.nm2l
	ldh a, [rSTAT]
	and $02
	jr nz, .nm2l
	ld a, $86
	ld [hl+], a
.nm1l;4735
	ldh a, [rSTAT]
	and $02
	jr nz, .nm1l
	ld a, $86
	ld [hl+], a
	ret

DrawSpeedDisplay: ;473F
	ldh a, [hGameState]
	dec a
	jr nz, .skip
	ld a, [$C2A1] ;standard gamestate check, todo: should this be macro'd?
	cpl
	and $03
	ret nz
.skip
	ld hl, $9A29 ;speed indicator tile
.statloop1
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop1
	ld a, $73
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a ;set tiles, always 73-76
	ld a, [$C2CD]
	or a
	jr z, .ld
	ld a, $07
	jr .nold
.ld
	ldh a, [hSpeedTier]
.nold
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ;value * 16 * 4 (four tiles each graphic)
	ld bc, SpeedLevelGraphics ;speed graphics
	add hl, bc
	ld de, $8730
	ld b, $40 ;number of bytes to copy
.gfxcopyloop
	ldh a, [rSTAT]
	and $02
	jr nz, .gfxcopyloop
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .gfxcopyloop
	ret
	
ContinueEnglishParser: ;478C
	;passed hl is string, de is vram address, c is ?
	;code 1 draws a number from passed address
	;code 2 draws the next number
	;code 3 compares pointed byte to byte, jumps if equal
	;code 4 compares pointed byte to byte, jumps if unequal
	;code 5 is code 3 except divide the pointed byte by 4
	;code 6 is code 4 except divide the pointed byte by 4
	;code 7 follows pointer if pointed byte >= value
	;code 8 follows pointer if pointed byte <= value
	;codes 9 and A are dummied out
	;code B prints the level number (uses pointer)
	;code C prints a read number minus a pointed number
	;code D prints a newline?
	;code E prints a big star
	;code F prints a small star
	;code 10 skips specified number of tiles in vram
	;code 11 jumps to specified address
	;code 12 increments $C2C5 by the pointed value
	;code 13 decrements $C2C5 by the pointed value
	;code 14 increments $C2C6 by the pointed value
	;code 15 decrements $C2C6 by the poitned value
	;codes 16-1F dummied out
	ld a, e
	and $1F
	add a, $20
	ld b, a ;b = passed e + $20
	ld a, c
	ld [$D058], a ;write passed c to D058 (temp)
	or a
	jp z, .useD6 ;if c = 0, set it to D6, otherwise add 03
	add a, $2D
.useD6 ;479C
	add a, $D6
	ld c, a ;c is D6 or c + 03 based on pass
.mainloop ;479F
	ld a, [hl+] ;read from passed HL
	or a
	ret z ;return if read value is zero
	cp $20
	jp z, .handlespace ;if read byte was $20, jump (space)
	jp nc, .handleletter ;if read byte was >$20, jump (letters)
	;otherwise, handle a control code
	dec a
	jr nz, .not1 ;if not 1, branch
	push bc ;otherwise handle 1
	push hl ;save BC and HL
	ld a, [hl+] ;next word is a pointer
	ld h, [hl]
	ld l, a ;load pointer
	ld c, [hl] ;read byte from pointer into c
	ld a, [$D058] 
	ld b, a ;load our saved c into b
	ld l, e
	ld h, d ;HL is our passed DE
	call CallSetContinueNumberTile ;draw a number
	ld e, l
	ld d, h ;restore the DE?
	pop hl
	pop bc
	inc hl
	inc hl ;advance past pointer
	jp .mainloop
	
.not1
	dec a
	jr nz, .not2
	push bc ;handle a 2
	push hl ;save these
	ld c, [hl] ;next byte is c
	ld a, [$D058] ;saved val into b
	ld b, a
	ld l, e
	ld h, d ;de into hl
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	pop hl
	pop bc
	inc hl ;advance past byte
	jp .mainloop
	
.not2
	dec a
	jr nz, .not3
	push de ;save XY target
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;next two bytes a pointer
	ld a, [de] ;load that into a
	pop de ;restore target
	cp [hl] ;compare next byte with the byte the word before pointed to
	jr nz, .notequal
	inc hl ;if they match, load the next pointer and loop
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.notequal
	inc hl ;advance past the pointer
	inc hl
	inc hl
	jp .mainloop
	
.not3
	dec a
	jr nz, .not4
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	pop de
	cp [hl]
	jr z, .equal
	inc hl ;same as above, but !=
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.equal
	inc hl
	inc hl
	inc hl
	jp .mainloop
	
.not4
	dec a
	jr nz, .not5
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de] ;load pointer
	srl a
	srl a ;divide by four?
	pop de
	cp [hl]
	jr nz, .div4nonequal
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.div4nonequal
	inc hl
	inc hl
	inc hl
	jp .mainloop
	
.not5
	dec a
	jr nz, .not6
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	srl a
	srl a
	pop de
	cp [hl]
	jr z, .div4equal
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.div4equal
	inc hl
	inc hl
	inc hl
	jp .mainloop

.not6
	dec a
	jr nz, .not7
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	pop de
	cp [hl]
	jr c, .lessthan
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.lessthan
	inc hl
	inc hl
	inc hl
	jp .mainloop

.not7
	dec a
	jr nz, .not8
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	pop de
	cp [hl]
	jr nc, .notlessthan
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp .mainloop
.notlessthan
	inc hl
	inc hl
	inc hl
	jp .mainloop
	
.not8
	dec a
	jr nz, .not9
.not9
	dec a
	jr nz, .notA ;9 and A do nothing
.notA
	dec a
	jr nz, .notB
	push bc ;B draws a number to screen based on pointer
	push hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read pointer into hl
	ld c, [hl] ;pointed byte into C
	srl c
	srl c
	inc c ;make it a 1-indexed level number
	ld a, [$D058]
	ld b, a
	ld l, e
	ld h, d
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	pop hl
	pop bc
	inc hl
	inc hl
	jp .mainloop

.notB
	dec a
	jr nz, .notC
	push bc
	push hl
	ld a, [hl+]
	ld c, a ;byte into C
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read a pointer
	ld a, c
	sub a, [hl] ;subtract pointed byte from read byte
	ld c, a
	ld a, [$D058]
	ld b, a
	ld l, e
	ld h, d
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	pop hl
	pop bc
	inc hl
	inc hl
	inc hl
	jp .mainloop

.notC
	dec a
	jr nz, .notD
	ld a, e
	and $E0
	add a, b
	ld e, a ;DE += E0 + b (newline?)
	ld a, d
	adc a, $00
	ld d, a
	jp .mainloop

.notD
	dec a
	jr nz, .notE
.sl1
	ldh a, [rSTAT]
	and $02
	jr nz, .sl1
	ld a, $61 ;(four tiles, big star??)
	add a, c
	ld [de], a
	inc de
.sl2
	ldh a, [rSTAT]
	and $02
	jr nz, .sl2
	ld a, $62
	add a, c
	ld [de], a ;write C+61 and then C+62,
	ld a, e
	add a, $1F
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance $1F
.sl3
	ldh a, [rSTAT]
	and $02
	jr nz, .sl3
	ld a, $63
	add a, c
	ld [de], a
	inc de
.sl4
	ldh a, [rSTAT]
	and $02
	jr nz, .sl4
	ld a, $64
	add a, c
	ld [de], a ;then C+63 and C+64
	ld a, e
	sub $1F
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a ;go back $1F tiles
	jp .mainloop
	
.notE
	dec a
	jr nz, .notF
.sl5
	ldh a, [rSTAT]
	and $02
	jr nz, .sl5
	ld a, $5F
	add a, c
	ld [de], a
	inc de
.sl6
	ldh a, [rSTAT]
	and $02
	jr nz, .sl6
	ld a, $60 ;C+5F and C+60, a two-tile graphic (small star?)
	add a, c
	ld [de], a
	inc de
	jp .mainloop
	
.notF
	dec a
	jr nz, .not10
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance that many bytes on screen
	jp .mainloop

.not10
	dec a
	jr nz, .not11
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load this pointer into read position
	jp .mainloop
	
.not11
	dec a
	jr nz, .not12
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [$C2C5]
	add a, e
	ld [$C2C5], a ;increment C2C5 by the value at the pointer given
	pop de
	jp .mainloop

.not12
	dec a
	jr nz, .not13
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [$C2C5]
	sub a, e
	ld [$C2C5], a ;decrement C2C5 by value at pointer
	pop de
	jp .mainloop
	
.not13
	dec a
	jr nz, .not14
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [$C2C6]
	add a, e
	ld [$C2C6], a ;increment C2C6 by value at pointer
	pop de
	jp .mainloop
	
.not14
	dec a
	jr nz, .not15
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [$C2C6]
	sub a, e
	ld [$C2C6], a ;decrement C2C6 by value at pointer
	pop de
	jp .mainloop

.not15
	dec a
	jr nz, .not16
	jp .mainloop ;nop
	
.not16
	jp .mainloop ;nops
	
.handlespace ;49A4
	ld a, $5D
.handleletter ;49A6
	add a, c
	ldh [$FFFE], a
.sl7
	ldh a, [rSTAT]
	and $02
	jr nz, .sl7
	ldh a, [$FFFE]
	ld [de], a
	inc de
	jp .mainloop

SetContinueNumberTile: ;49B6
	ld a, b
	or a
	jp z, .darkfont
	ld a, $2E
.darkfont ;49BD
	add a, $0D
	ld b, a ;load 0D or 3B into B, this is font offset
	ld a, c
	sub 100
	ld d, $00 ;d = 0
	jr c, .no3rddigit ;jump if c < 100
.divloop100s
	inc d ;d += 1
	ld c, a ;otherwise C -= 100
	sub 100
	jr nc, .divloop100s
.statloop100s
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop100s
	ld a, d ;d is c/100 (number to print)
	add a, b ;add font offset
	ld [hl+], a
	ld a, c ;c is remainder of c/100
	sub 10
	ld d, $00
	jr c, .statloop10s
.divloop10s
	inc d
	ld c, a
	sub 10
	jr nc, .divloop10s
.statloop10s
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop10s
	ld a, d
	add a, b
	ld [hl+], a
	jr .statloop1s
.no3rddigit
	ld a, c
	sub 10
	ld d, $00
	jr c, .statloop1s
.no3rdloop
	inc d
	ld c, a
	sub 10
	jr nc, .no3rdloop
.no3rdstatloop
	ldh a, [rSTAT]
	and $02
	jr nz, .no3rdstatloop
	ld a, d
	add a, b
	ld [hl+], a
.statloop1s
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop1s
	ld a, c
	add a, b
	ld [hl+], a
	ret
	
DrawContinueBottomBox: ;4A0E
	ld hl, ContinueBottomTilemap ;address
	ld bc, $0169 ;base address
	ld de, $0D01 ;placement offset
	call LoadBank7Tileset
.convertstarsloop
	ld a, [wSmallStars]
	sub 10
	jr c, .lessthanten
	ld [wSmallStars], a
	ld a, [wBigStars]
	inc a
	ld [wBigStars], a
	jr .convertstarsloop
.lessthanten
	ld hl, $9A07 ;big star num placement
	ld a, [wBigStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld hl, $9A0F ;small star num placement
	ld a, [wSmallStars]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
LoadContinueFont: ;4A45
	ld hl, ResultsFontDark ;dark font
	ld de, $90D0 ;destination
	ld bc, $05C0 ;both fonts
.fontgfxcopyloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jp nz, .fontgfxcopyloop
	xor a
	ldh [hGameState], a
	ld [$C2ED], a
	ldh [rSCY], a
	ld a, $08
	ldh [rSCX], a
	ld a, $FF
	ldh [rWX], a
	xor a
	ldh [rIF], a
	ld a, (1 << VBLANK)
	ldh [rIE], a
	loadpalette 2, 3, 1, 0
	ldh [rBGP], a
	loadpalette 0, 0, 0, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ret
	
LoadSiloInterior: ;4A7E
	ld a, TRACK_SILO_INTERIOR
	ld [wQueueMusic], a
	ld hl, wMonoBufferColumn1
	xor a
	ld c, MONO_BUFFER_COLUMNS
.wipeColumn ;4A89
	ld b, MONO_BUFFER_ROWS * 2
.wipeHalfTile ;4A8B
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jp nz, .wipeHalfTile
	dec c
	jp nz, .wipeColumn
	call CallCopyWRAMToVRAM
	ldh a, [rLCDC]
	res rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	loadpalette 1, 0, 2, 3
	ldh [hBGP], a
	loadpalette 1, 0, 2, 3 ;unneeded?
	ldh [hIntP], a
	ld a, -1
	ldh [hGameState], a
	ld hl, SiloInteriorGFX ;address of the interior graphics
	ld de, $8D00 ;start of 3D window tiles
	ld bc, $0580 ;how many lines, works out to the entirety of the window
.statLoop
	ldh a, [rSTAT]
	and $02
	jr nz, .statLoop
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jp nz, .statLoop
	ret
	
SiloDepositCrystal: ;4AC8
	call LoadSiloInterior
	ld hl, wMonoBufferColumn1
	xor a
	ld c, $10
.outerloop
	ld b, $16
.innerloop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jp nz, .innerloop
	dec c
	jp nz, .outerloop
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a ;positioning
	ld a, $A8
	ldh [$FFDD], a
	ld a, $FF
	ldh [$FFDE], a
	ld a, $02
	ldh [$FFDC], a
	ld a, $32
	ldh [$FFDB], a ;positioning
	xor a
	ld [$D158], a
	ld a, $60
	ld [$D159], a
.loop
	ldh a, [$FFA1]
	inc a
	ldh [$FFA1], a ;spin
	ldh a, [$FFDD]
	cp $28
	jr nz, .addZ
	ldh a, [$FFDE]
	or a
	jr z, .decrement
	ldh a, [$FFDD]
.addZ ;7
	add a, $02
	ldh [$FFDD], a
	ldh a, [$FFDE]
	adc a, $00
	ldh [$FFDE], a
.decrement ;C
	ld a, [$D158]
	sub $01
	ld [$D158], a
	jr nc, .drawModel
	ld a, [$D159]
	sub $01
	adc a, $00
	ret c
	ld [$D159], a
	sub $20
	jr nc, .update
	xor a
.update ;1
	srl a
	srl a
	srl a
	ld [$D158], a
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	ldh a, [$FFA1]
	inc a
	ldh [$FFA1], a
.drawModel ;25
	ld a, $0C ;power crystal
	call CallDrawModel
	call DrawSiloPowerCrystal
	jp .loop

HandleSiloInterior: ;4B53
	call LoadSiloInterior
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDE], a ;blank out 3D position
	ld a, $28
	ldh [$FFDD], a
	ld a, $02
	ldh [$FFDC], a
	ld a, $32
	ldh [$FFDB], a ;set certain position
	ld [wUpdateCounter], a
.loop ;4B6C
	ldh a, [$FFA1]
	add a, $04
	ldh [$FFA1], a ;rotate the entity by 4
	call CallRefreshBGTiles
	ld a, [wCurLevel]
	and $FC ;mask to whole levels
	rrca
	rrca
	cp $03
	jr nz, .notLevel3 ;if level's not 3, jump
	ld a, [wHasCargo]
	cp CARGO_SCIENTIST
	jr nz, .flashedDamaged ;if not scientist, jump
	jr .drawCrystal ;level 3 + scientist, jump
.notLevel3 ;9
	cp $05
	jr z, .flashedDamaged ;if level 5, jump
	cp $06
	jr nz, .drawCrystal ;if not level 6, jump
	ld a, [$C2C2]
	cp $04
	jr z, .drawCrystal ;we got four !!!!
.flashedDamaged ;11, B
	ld a, [wUpdateCounter]
	and $01
	rlca
	rlca
	rlca
	rlca ;rotate alternation into high nybble
	add a, $28
	ldh [$FFDD], a ;alternate between $28 and $38
	call NextRand
	and $07 
	loadpalette 0, 0, 2, 3
	jr nz, .loadPal
	cpl ;1 in 8 chance to use 3, 3, 1, 0 instead
.loadPal
	ldh [hBGP], a
.drawCrystal ;28, 20, 19
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	cp $80
	ret z
	call UpdateInputs
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	bit INPUT_START, a
	ret nz ;if start pressed, return
	ld a, $0C ;power crystal
	call CallDrawModel
	call DrawSiloPowerCrystal
	jp .loop
	
DrawSiloPowerCrystal: ;4BD4
	ld hl, $90A0 ;3D window data: column 5 row 3
	ld de, wMonoBufferColumn6 + MONO_TILE_HEIGHT*3 ;monochrome buffer: column 5 row 3
	ld b, $06 ;6 columns wide
	inc l
.copyColumn ;BB
	push bc
.copyHalfTile ;CB
	ld a, [de] ;grab value from buffer
	ld c, a
	inc e
	ld a, [de]
	ld b, a ;BC is value pair from buffer
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
	ld e, a ;DC is next value pair from buffer
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
	inc l ;write four values to vram
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
	inc e ;wipe the mono buffer
	ld a, e
	cp $50
	jr c, .copyHalfTile
	ld e, $18
	inc d
	ld a, l
	add a, $40
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop bc
	dec b
	jr nz, .copyColumn
	ret
;4C23

SECTION "A:4C7A", ROMX[$4C7A], BANK[$A]
IF UNUSED == 1
res_Advice: ;4C7A
	conAdvanceVRAM $c
	conLevelNumber wCurLevel
	conNewline
	conJumpDiv4Equal wCurLevel, $0, .lev1
	conJumpDiv4Equal wCurLevel, $1, .lev2
	conJumpDiv4Equal wCurLevel, $2, .lev3
	conEnd
	
.lev1 ;4C93
	db "\r FIND THE CRYSTAL"
	db "\r AND TAKE TO SILO"
	db "\r BEFORE THE ALIEN"
	db "\r DESTROYS THE SILO"
	db "\r\r\r\r\r\r\r"
	conJumpEqual wHasCargo, CARGO_CRYSTAL, .l1part2
	db "THE CRYSTAL IS IN\r\r"
	db "    SECTOR "
	conLiteralNumber 14 ;???
	conEnd
.l1part2 ;4D0A
	db "YOU HAVE A CRYSTAL\r"
	db "NOW GO TO THE SILO\r"
	db "   IN SECTOR "
	conLiteralNumber 1
	conEnd
	
.lev2 ;4D40
	db "\r ENEMY HAS PLANTED"
	db "\r FIVE TIME BOMBS"
	db "\r DESTROY THEM ALL"
	db "\r BEFORE THEY BLOW"
	db "\r\r\r\r\r\r\r"
	db " TIME BOMBS LEFT\r"
	conAdvanceVRAM $8
	db "\\"
	conPointedNumber wMissionBombCount
	conNewline
	conNewline
	conJumpGreaterEqual wTimerFramesHi, $5, .l2part2
	db "     HURRY UP"
	conEnd
.l2part2 ;4DBC
	conJumpGreaterEqual wTimerFramesHi, $f, .l2part1
	db " QUICKER QUICKER"
	conEnd
.l2part1 ;4DD3
	db "  PLENTY OF TIME"
	conEnd
	
.lev3 ;4DE4
	db "\r HEAVY TANK IS ON"
	db "\r COURSE TO DESTROY"
	db "\r  ALL OUR RADARS"
	db "\r DESTROY THE TANK"
	db "\r\r\r\r\r\r\r"
	db " RADARS REMAINING\r"
	conAdvanceVRAM $8
	db "\\"
	conPointedNumber wMissionBasesLeft
	conNewline
	conNewline
	conJumpEqual wMissionBasesLeft, 8, .l3part1
	conJumpGreaterEqual wMissionBasesLeft, 4, .l3part2
	db " SITUATION DRASTIC"
	conEnd
.l3part2 ;4E6C
	db " HURRY UP PLEASE"
	conEnd
.l3part1 ;4E7D
	db "  SITUATION SAFE"
	conEnd
ENDC

res_Mission: ;4E8E
	db "MISSION "
	conLevelNumber wCurLevel
	conEnd
res_Master: ;4E9A, the big script?
	conIncVal2 $c2c7
	conJumpEqual wCurLevel, LEVEL_ONE, res_LevelOne
	conJumpLessEqual wCurLevel, $0A, res_EarlyLevels
	conJumpEqual wCurLevel, LEVEL_FOUR, res_LevelFour
	conJumpEqual wCurLevel, LEVEL_FIVE, res_LevelFive
	conJumpEqual wCurLevel, LEVEL_SIX, res_LevelSix
	conJumpEqual wCurLevel, LEVEL_SEVEN, res_LevelSeven
	conJumpEqual wCurLevel, LEVEL_EIGHT, res_LevelEight
	conJumpEqual wCurLevel, LEVEL_NINE, res_LevelNine
	conEnd
res_LevelOne: ;4ECE
	db " ^YOU DESTROYED\r\r "
	conSmallStar
	db " ALIENS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r\r ^YOU COLLECTED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " CRYSTAL[[[[[\\"
	conLiteralNumber $1
	conIncVal1 .value
	conJump .end
.value ;4F20 ;if this was moved after conEnd, no need for a jump??
	db $1
.end ;4F21
	conEnd
	
res_LevelFive: ;4F22, continue from here
	db " ^YOU DESTROYED\r\r "
	conBigStar
	conNewline
	conAdvanceVRAM $4
	db "TUNNEL[[[[[[\\"
	conLiteralNumber $2
	conIncVal1 .value
	conJump .line2
.value ;4F4D
	db $2
.line2 ;4F4E
	db "\r\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	conEnd
	
res_LevelNine: ;4F65
	db " ^YOU DESTROYED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $4
	db "MISSILES[[[[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
	db "\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r ^YOU SAVED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " SILO[[[[[[[[\\"
	conLiteralNumber $1
	conIncVal1 .value
	conJump .end
.value
	db $1
.end
	conEnd

res_LevelEight: ;4FCD
	db " ^YOU DESTROYED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $4
	db "BUTTERFLIES[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
	db "\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r ^YOU SAVED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " RADARS[[[[[[\\"
	conPointedNumber $cb0a
	conIncVal1 $cb0a
	conEnd
	
res_LevelFour: ;5032
	db " ^YOU DESTROYED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $4
	db "ALIEN BASES[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
	db "\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r ^YOU RESCUED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " SCIENTIST[[[\\"
	conLiteralNumber $1
	conIncVal1 .value
	conJump .end
.value
	db $1
.end
	conEnd
	
res_LevelSeven: ;509C
	db " ^YOU DESTROYED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $4
	db "GLIDERS[[[[[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
	db "\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r ^YOU RETURNED\r\r "
	conSmallStar
	db " RODS[[[[[[[[\\"
	conLiteralNumber $4
	conIncVal2 .value
	conJump .end
.value ;5103
	db $04
.end
	conEnd
	
res_LevelSix: ;5105
	db " ^YOU DESTROYED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " INSECTS[[[[[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
	db "\r\r "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	db "\r\r ^YOU DELIVERED\r\r "
	conSmallStar
	db " RODS[[[[[[[[\\"
	conLiteralNumber $4
	conIncVal2 .value
	conJump .end
.value
	db $04
.end
	conEnd

res_EarlyLevels: ;5170
	db " ^YOU DESTROYED\r"
	conJumpDiv4Equal wCurLevel, $2, .skip
	db "\r"
.skip ;5187
	db " "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	conJumpDiv4Equal wCurLevel, $0, .level_one
	conJumpDiv4Equal wCurLevel, $1, .level_two
	conJumpDiv4Equal wCurLevel, $2, .level_three
	conEnd
.level_three ;519F
	db " HEAVY TANKS[\\"
	conReadMinusPointed $2, $cb03
	conIncVal1 .value1
	conJump .j1
.value1
	db $02
.j1
	conDecVal1 $cb03
	conJump .merge
.level_two ;51BE
	db " TIME BOMBS[[\\"
	conReadMinusPointed $5, $cb02
	conIncVal1 .value2
	conJump .j2
.value2
	db $5
.j2
	conDecVal1 $cb02
	conJump .merge
.level_one ;51dd
	db " CRABS[[[[[[[\\"
	conPointedNumber $c32c
	conIncVal1 $c32c
.merge ;51F1
	conNewline
	conNewline
	conJumpDiv4Equal wCurLevel, $2, .skip2
	conNewline
.skip2 ;51FA
	db " "
	conSmallStar
	db " OTHERS[[[[[[\\"
	conPointedNumber $c2c7
	conJumpDiv4Equal wCurLevel, $2, .radars
	conEnd
.radars ;5214
	db "\r\r ^YOU SAVED\r "
	conBigStar
	conNewline
	conAdvanceVRAM $3
	db " RADARS[[[[[[\\"
	conPointedNumber $cb0a
	conIncVal1 $cb0a
	conEnd

ContinueScreenContinueText: ;523C:
	db "CONTINUE[[[YES", "\r\r", "           ", "NO", 00
	
ContinueScreenPlayText: ;525A
	db "           " 
	conBigStar
	db "\r", "MISSION " 
	conLevelNumber wCurLevel
	db " " 
	conJumpDiv4Equal wCurLevel, $9, .lvlTen
	db " "
.lvlTen ;527A
	conAdvanceVRAM $2
	db "\\"
	conPointedNumber $c330
	db "\r\r", "     ", "PLAY", "[[[", "YES", "\r\r", "            ", "NO", 00
	
ContinueScreenSixEmptyLines: ;52A2
	db "                    \r"
	db "                    \r"
	db "                    \r"
	db "                    \r"
	db "                    \r"
	db "                    \r", 00
	
ContinueScreenDoubleSpace: ;5321
	db "  ", 00

SiloInteriorGFX:;5324
	INCBIN "build/gfx/SiloInterior.2bpp"
ResultsFontDark: ;0x5E24: dark end of level text + stars
	INCBIN "build/gfx/ResultsHiContrast.2bpp"
ResultsFontLight: ;0x6104-0x63E3: light end of level text + stars
	INCBIN "build/gfx/ResultsLoContrast.2bpp"