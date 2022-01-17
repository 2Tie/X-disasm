SECTION "Bank C top", ROMX[$4000], BANK[$C]
BriefingPointers: ;4000 these are in bank 5
	dw Briefing1Sequence ;briefing 1
	dw Briefing2Sequence ;briefing 2
	dw Briefing3Sequence ;briefing 3
	dw Briefing4Sequence ;briefing 4
	dw Briefing5Sequence ;briefing 5
	dw Briefing6Sequence ;briefing 6
	dw Briefing7Sequence ;briefing 7
	dw Briefing8Sequence ;briefing 8
	dw Briefing9Sequence ;briefing 9
	dw Briefing10Sequence ;briefing 10
	dw BriefingEndSequence ;ending brief
	dw UnusedBriefingSequence1 ;unused tutorial brief
	dw UnusedBriefingSequence2 ;unused tutorial ending brief
	
RadarLevelTextPointers: ;401A, jumped to in radar base based on level
	dw RadarTextLevel1 ;level 1
	dw RadarTextLevel2 ;level 2
	dw RadarTextLevel3 ;3
	dw RadarTextLevel4 ;4
	dw RadarTextLevel5 ;5
	dw RadarTextLevel6 ;6
	dw RadarTextLevel7 ;7
	dw RadarTextLevel8 ;8
	dw RadarTextLevel9 ;9
	dw RadarTextLevel10 ;10
	dw $0000 ;escape, has none
	dw RadarTextLevelTUT ;tutorial
	
;4032, model ID of entities dropped by entities. 7F is random. top bit clears the map ID
	db $22, $22, $00, $09, $7F, $00, $90, $7F, $00, $7F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $25, $34, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $7F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $25, $00, $00, $00, $3C, $3C, $22, $3C, $00, $3C, $00, $00, $40, $09, $3C, $00, $00, $00, $04, $00, $00, $00, $2C, $00, $25, $40, $3C, $00, $40, $7F, $00, $3C, $22, $25, $7F, $34, $3C, $3C, $7F, $00, $00, $00

EntityLogicChrysalis: ;4088
	ld a, [$CB0E]
	inc a
	ld [$CB0E], a ;increment count
	ld e, l
	ld d, h ;backup pointer
	ld a, e
	add a, $0C
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	bit 0, [hl] ;was it shot at?
	jr nz, .shot ;if yes, jump
	ld hl, wTimerFrames
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret nz ;if timer still counting, return
	push de
	ld hl, ChrysalisHatchText
	ld c, $32
	call CallTryWriteScreenText
	pop de
	jr .hatch 
.shot ;14, shot at
	push de
	ld hl, ChrysalisShotText
	ld c, $32
	call CallTryWriteScreenText
	pop de
.hatch ;A
	ld l, e
	ld h, d
	dec hl
	set 7, [hl] ;explode!
	inc hl
	ld a, $44 ;butterfly
	call CallEntityDropNewEntity
	ret c ;return if we couldn't spawn butterfly
	ld a, e
	add a, $18
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	xor a
	ld [hl], a ;zero out the next entity's model?
	ret

EntityLogicReactorRod: ;40D2, reactor rod logic
	ld a, [$CB01]
	inc a
	ld [$CB01], a
	call CallMoveBomb
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to HP value
	ld a, $FF
	ld [de], a ;set to max? -1?
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;map object ID
	xor a
	ld [de], a ;wipe it?
	ld a, l
	add a, $08
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;y orientation
	xor a
	ld [de], a ;wipe it
	ld a, [wCrosshairTargetEntityLo]
	cp l
	ret nz
	ld a, [wCrosshairTargetEntityHi]
	cp h
	ret nz ;return if crosshair not over this
	ld a, [$C2AD]
	or a
	ret z ;return if zero rods left
	ldh a, [$FFDC]
	cp $01
	ret nc ;not sure here
	call CallCleanUpPickupItem
	ld a, $12
	ld [wQueueSFX], a
	ld a, [$C2C2]
	inc a
	ld [$C2C2], a
	cp $04
	jr nz, .collectedNotFinal ;if not four, jump ahead
	ld hl, CollectedReactorRodsText
	ld c, $32
	call CallTryWriteScreenText
	ld hl, HeadToSiloText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, HeadToSiloText2
	ld c, $32
	call CallTryWriteScreenText
	ld a, $01
	ld [wGoalCellID], a
	ld a, $32
	ld [wGoalCellTimer], a
	jr .wipeCollision
.collectedNotFinal ;24
	ld hl, Level2BlankTXT
	ld c, $32
	call CallTryWriteScreenText
	ld a, [$C2C2]
	cpl
	inc a
	add a, $04
	call nz, CallPrintHowManyLeft
.wipeCollision ;12
	xor a
	ld [wCollisionType], a
	ret
	
EntityLogicSuperGlider: ;415D
	push hl ;save ent pointer
	ld a, [$C2AD] ;rods left?
	or a
	jr z, .rollSpeed
	call NextRand
	and $7F
	jr nz, .drawRod
	ld a, $04
	ld [wQueueWave], a
.drawRod ;5
	ldh a, [$FFDD]
	add a, $50
	ldh [$FFDD], a ;entity pos
	ldh a, [$FFDE]
	adc a, $00
	ldh [$FFDE], a ;entity pos
	xor a
	ldh [$FFA5], a ;entity rot
	ldh [$FFA3], a ;entity rot
	ld a, $10 ;model 10 - reactor rods?
	call CallDrawModel
.rollSpeed ;22
	pop hl ;ent pointer
	ld e, l
	ld d, h
	call NextRand
	and $1F
	jr nz, .firstangle ;1 in $20 chance to not jump
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl at speed byte
	call NextRand
	cp $10
	jr nc, .rollTurn ;1 in 16 chance to add range of +-8 to speed
	sub $08
	ld [hl], a
.rollTurn ;3
	inc hl
	call NextRand
	cp $10
	jr nc, .firstangle
	sub $08
	ld [hl], a ;1 in 16 chance to add range of +-8 to turn angle
.firstangle ;1D, 3
	ld l, e
	ld h, d ;restore ent pointer
	push de ;and back it up
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl += 6, to x orientation
	ld a, e
	add a, $0E
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;de += e, to turn angle
	ld a, [de]
	sub a, [hl]
	jr z, .clearangle1 ;if equal, skip ahead
	cp $80
	jr nc, .decangle1 ;jump if negative
	inc [hl]
	jr .skip1
.decangle1 ;3
	dec [hl]
.skip1 ;1
	jr .secondangle
.clearangle1 ;A
	xor a
	ld [de], a
.secondangle ;2
	ld a, [hl+]
	add a, [hl]
	ld [hl+], a ;z orientation += x orientation... tilty burd
	dec de
	ld a, [de] ;speed?
	sub a, [hl]
	jr z, .clearangle2
	cp $80
	jr nc, .decangle2
	inc [hl]
	jr .skip2
.decangle2
	dec [hl]
.skip2
	jr .move
.clearangle2
	xor a
	ld [de], a
	
.move
	pop hl ;restore ent pointer
	ld bc, $0000
	ld a, $50
	call CallMoveEntityBySpecifiedAmts
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl += 4, to ent ypos
	ld a, [hl+]
	add a, $32
	ld a, [hl-]
	adc a, $00
	cp $80
	jr nc, .bounds2 ;if overflowed after + $0032, jump
	ld a, $CE
	ld [hl+], a
	ld a, $FF
	ld [hl-], a ;else load $FFCE (-$32) to ypos
	push hl
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speed
	xor a
	ld [hl], a ;wipe speed
	pop hl
.bounds2 ;12
	ld a, [hl+]
	add a, $5E
	ld a, [hl-]
	adc a, $01
	cp $80
	jr c, .done ;if not overflowed after + $015E, jump
	ld a, $A2
	ld [hl+], a
	ld a, $FE
	ld [hl-], a ;else load $FEA2 (-$15E) to ypos
	push hl
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speed
	xor a
	ld [hl], a ;wipe it
	pop hl
.done ;12
	ret
	
MoveBomb: ;422E
	push bc
	push de
	push hl ;save all these
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance ent pointer to speed
	ld c, [hl] ;load speed to C
	push hl
	ld a, l
	sub $09
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;retreat to Ypos
	ld a, [hl+]
	ld e, a
	ld d, [hl] ;load it to DE
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extend speed into BC
	ld a, e
	add a, c
	ld e, a
	ld a, d
	adc a, b
	ld d, a ;Ypos += speed
	cp $80
	jr nc, .save ;if overflowed, jump
	xor a
	ld e, a
	ld d, a ;else wipe ypos
	ld a, c
	cp $80
	sbc a, $FF
	sra a
	cpl
	inc a
	ld c, a ;and negate speed and divide by two?
.save
	ld a, d
	ld [hl-], a
	ld [hl], e ;save updated ypos
	pop hl ;restore speed pointer
	ld a, c
	add a, $04
	add a, $20
	cp $40
	jr nc, .end ;if past threshold, skip
	sub $20
	ld [hl], a ;else save new speed
.end
	pop hl
	pop de
	pop bc
	ret
	
;4279

SECTION "C:42B9", ROMX[$42B9], BANK[$C]
FuncC42B9: ;42B9
	ld a, [$C348]
	rlca ;multiply by two
	and $3C ;mask with %00111100?
	add a, $79
	ld l, a
	ld a, $42
	adc a, $00
	ld h, a ;HL is now $4279 + resulting value
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;load first two bytes into BC
	ld a, [hl+]
	ld [$C2F6], a
	ld a, [hl+]
	ld [$C2F5], a ;second two bytes into F5/F6
	ld l, c
	ld h, b ;HL is now holding first pair
	ld a, [$C2F6]
	rrca
	ld e, a
	ld a, [$C2F5]
	rrca
	ld d, a ;DE now has second pair, divided by two?
	ldh a, [$FFC6]
	sub a, e
	ldh [$FFC6], a
	ldh a, [$FFC7]
	sbc a, $00
	ldh [$FFC7], a ;C6/C7 pair minus E
	ldh a, [$FFC4]
	sub a, d
	ldh [$FFC4], a
	ldh a, [$FFC5]
	sbc a, $00
	ldh [$FFC5], a ;C4/C5 pair minus D
	ldh a, [$FFC6]
	and $F8
	ldh [$FFC6], a ;mask off?
	sla e
	ldh a, [$FFC6]
	ld c, a ;backup into C?
	add a, e
	ldh [$FFC2], a 
	ldh a, [$FFC7]
	adc a, $00
	ldh [$FFC3], a ;C2/C3 = C6/C7 + E
	sla d
	ldh a, [$FFC4]
	ld b, a ;backup into B?
	add a, d
	ldh [$FFC0], a
	ldh a, [$FFC5]
	adc a, $00
	ldh [$FFC1], a ;C0/C1 = C4/C5 + D
	push bc ;save backups of C6/C4
	push hl ;save the first read pair
	call ComparePointersToC0C8Region ;todo, try understanding this again
	pop hl
	pop bc ;restore them
	ret c ;return possibly after the above call
	push bc
	ld bc, $42B9 ;this function?
	ld a, [$C2F7]
	inc a
	jr nz, .check1 ;if it wasn't -1, jump
	ld bc, $42B9 ;this function?
.check1
	dec a
	dec a
	jr nz, .donechecking ;if it wasn't 1, jump
	ld bc, $42B9 ;this function?
.donechecking
	add hl, bc ;BC will always be $42B9 here...
	pop bc ;restore backup of BC
	jp $4457
	
;4438
	ld a, c
	and $F8
	rrca
	rrca
	rrca
	add a, $D0
	ld d, a
	ld e, b
	ld c, b
	ld b, $07
	ld hl, $42B9
	ld bc, $1005
	jp $4457
;434E

SECTION "C:4457", ROMX[$4457], BANK[$C]
Func4457: ;4457
	ldh a, [$FFC4]
	sub a, b
	jr z, .doneupdatinghl
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL += value-B * 2
.doneupdatinghl
	ld a, c
	call EmptyDD7 ;????
	ldh a, [$FFC6]
	and $F8
	call EmptyDD7 ;????
	sub a, c
	jr z, .haveoffset
	rrca
	rrca
	rrca
	or a
	jr z, .haveoffset
	push af
	ld a, [$C2F5]
	rla
	ld e, a
	ld d, $00
	rl d
	pop af
.offsetloop
	add hl, de
	dec a
	jr nz, .offsetloop
.haveoffset ;15/F
	ldh a, [$FFC6]
	add a, $07
	and $F8
	ld c, a ;c is FFC6 minus the bottom three bits, except + 8 if any of those were set
	ldh a, [$FFC4]
	ld b, a
	ldh a, [$FFC6]
	and $F8 ;mask off bottom three bits
	rrca
	rrca
	rrca ;and shift it down?
	add a, $D0
	ld d, a ;d is that shifted C6 + $D0
	ld e, b ;e is C4
	ldh a, [$FFC0]
	sub a, b
	inc a
	ld b, a ;b is now C0 - C4 + 1
	ldh a, [$FFC2]
	and $F8
	sub a, c ;a is now masked C2 - masked C6
	jr c, .otherend ;to 44E0
	rrca
	rrca
	rrca
	ld c, a ;shift it down and save it to C
	ldh a, [$FFC6]
	and $07
	jr z, .skip ;jump if the bottom three bits are 0
	push bc
	push hl
	add a, $08 ;set the bit
	ld l, a ;save it to L
	ld a, $00
	adc a, $00 ;carry will never be set...?
	ld h, a
	ld c, [hl] ;from the depletion table?
	pop hl
	call $44E1
	pop bc
.skip ;10
	ld a, c
	or a
	jr z, .l5
	push bc
	call $4508
	pop bc
.l5 ;5
	ldh a, [$FFC2]
	and $07
	jr z, .end
	push hl
	add a, $10
	ld l, a
	ld a, $00
	adc a, $00
	ld h, a
	ld c, [hl]
	pop hl
	call DoSomeTopMasking ;save two bytes from [HL] to [DE], c being a mask, b is a counter
.end
	ret
.otherend ;44e0
	ret
	
DoSomeTopMasking: ;44E1
	;c is a byte from the top tables - not the flag, but the ones after
	;b is a loop count
	push hl
	push de
.toploop
	push bc
	ld a, c
	cpl
	ld c, a ;invert retrieved value
	ld a, [hl+] ;read a byte from the generated offset from earlier
	or c
	ld b, a ;b is now the OR'd result
	ld a, c
	cpl
	ld c, a ;uninvert the value
	ld a, [de]
	and b
	ld b, a ;b &= [de]
	ld a, [hl+] ;next byte
	and c
	or b
	ld [de], a ;save val &C | B to DE
	inc e ;next value
	pop bc ;restore passed b
	dec b
	jr nz, .toploop
	pop de
	inc d
	pop hl
	ld a, [$C2F5]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL += C2F5 * 2
	ret
	
FuncC4508: ;4508
	push de
	push hl
	push bc
.loop
	ld a, [hl+]
	ld c, a
	ld a, [de]
	and c
	or [hl]
	ld [de], a ;[de] & [HL] | [hl+1]
	inc e
	inc hl
	dec b
	jr nz, .loop
	pop bc
	pop hl
	ld a, [$C2F5]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl += C2F5 *2
	pop de
	inc d
	dec c
	jr nz, FuncC4508 ;to top of func
	ret


TitleLogoGFX: ;4529
INCBIN "build/gfx/TitleLogo.2bpp"
EkkusuGFX: ;47A9
INCBIN "build/gfx/ekkusu.2bpp"
CopyrightGFX: ;4809: mono "(C) 1992 Nintendo"
INCBIN "build/gfx/copyright.1bpp"
	db 00
DrawTitleText: ;4862
	ld a, $20
	ld [$CB1C], a
	ld c, $60
	ldh a, [$FF91] ; a byte from the save file
	or a
	ld hl, TitleTextPressAnyKey
	jr z, .skip
	ld hl, TitleTextPressAnyKeyAsterisks
.skip
	call CallHandleTitleText ;returns a value in C
	ld b, $68
	call CallDrawTitleLetters
	ret
	
DrawTitleCopyright: ;487D
	ld hl, $4809
	ld d, $D2
	ld b, $0B
.loop
	ld e, $08
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
	inc d
	dec b
	jp nz, .loop
	ret

TitleScreen: ;0x308A3, bank c $48A3
	ei
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, TitleScreenPlanetTilemap ;bank 7
	call LoadBank7TilesetOffset80 ;these are the planet bottom bg tiles
	call SetupTitleScreenBackground ;sets up BG, and loads "Ekkusu"
	call CallCopyWRAMToVRAM ;does nothing?
	call CallCopyWRAMToVRAM ;does nothing? the first time
	xor a
	ldh [$FF93], a
	ld [$C2ED], a
	ld [rSCY], a ;screen y = 0
	ld a, $08
	ld [rSCX], a ;screen x = 8
	ld a, $FF
	ld [rWX], a ;window x, disables it
	xor a
	ld [rIF], a
	ld a, (1 << VBLANK)
	ld [rIE], a
	loadpalette 2, 0, 1, 3
	ld [rBGP], a
	loadpalette 0, 0, 3, 0
	ld [rOBP0], a ;sets the planet to visible
	ld [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld a, $80 ;start setting a whole lot of unknown values
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFF0], a
	ldh [$FFEE], a
	xor a
	ld [$C2B7], a
	ldh [$FF9E], a
	ldh [$FF9F], a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $20
	ld [$C2BC], a
	ld [$C2BD], a
	ld a, $D0
	ldh [$FF9B], a
	ld a, $6A
	ldh [$FFDF], a
	ld a, $FF
	ldh [$FFE0], a
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ldh [$FFA1], a
	ldh [$FFA3], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ld a, $01
	ldh [$FFDC], a
	ld a, $46
	ldh [$FFDB], a
	xor a
	ld a, $2E
	ld [$C2BC], a
	ld [$C2BD], a
	call NextRand
	and $01
	jp nz, .sidesintro ;past end of function, always called first time (x comes in from sides)
	call NextRand
	and $01
	jp z, .slantintro ;past end of function, called after first demo (x legs slant in)
	
	ld a, $10
	ldh [$FFDC], a
	ld a, $E0
	ldh [$FFDF], a
	ld a, $01
	ldh [$FFE0], a
	ld a, $80
	ldh [$FFA3], a
	ld b, $31
.legsloop
	push bc
	ld a, $7F
	call CallDrawModel ;after third demo
	ldh a, [$FFDF]
	cpl
	add a, $01
	ldh [$FFDF], a
	ldh a, [$FFE0]
	cpl
	adc a, $00
	ldh [$FFE0], a
	ld a, $80
	call CallDrawModel
	ldh a, [$FFDF]
	cpl
	sub $09
	ldh [$FFDF], a
	ldh a, [$FFE0]
	cpl
	sbc a, $00
	ldh [$FFE0], a
	call CallCopyWRAMToVRAM ;this is what updates the onscreen graphics
	ldh a, [$FFDB]
	sub $50
	ldh [$FFDB], a
	ldh a, [$FFDC]
	sbc a, $00
	ldh [$FFDC], a
	ldh a, [$FFA3]
	add a, $10
	ldh [$FFA3], a
	call UpdateInputs
	pop bc
	ld a, [wCurrentInput]
	ld c, a
	ld a, [wChangedInputs]
	and c
	jp nz, HandleTitleInput
	dec b
	jp nz, .legsloop
	jp HandleTitleInput
	
.slantintro ;49A7
	ld a, $80
	ldh [$FFDF], a
	ld a, $FF
	ldh [$FFE0], a
	ld a, $80
	ldh [$FFDD], a
	ld a, $80
	ldh [$FFA3], a
	ld b, $08
.slantloop1
	push bc
	ldh a, [$FFDF]
	add a, $10
	ldh [$FFDF], a
	ldh a, [$FFE0]
	adc a, $00
	ldh [$FFE0], a
	ldh a, [$FFDD]
	sub $10
	ldh [$FFDD], a
	ld a, $7F
	call CallDrawModel
	call CallCopyWRAMToVRAM
	call UpdateInputs
	pop bc
	ld a, [$C29D]
	ld c, a
	ld a, [$C29E]
	and c
	jp nz, HandleTitleInput
	dec b
	jp nz, .slantloop1
	ld a, $C0
	ldh [$FFDF], a
	ld a, $FF
	ldh [$FFE0], a
	ld a, $80
	ldh [$FFDD], a
	ld a, $FF
	ldh [$FFDE], a
	ld b, $09
.slantloop2 ;49F9
	push bc
	ld a, $80
	call CallDrawModel
	ldh a, [$FFDD]
	ld c, a
	ldh a, [$FFDE]
	ld b, a
	push bc
	ldh a, [$FFDF]
	ld c, a
	ldh a, [$FFE0]
	ld b, a
	push bc
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ld a, $7F
	call CallDrawModel
	pop hl
	ld bc, $0008
	add hl, bc
	ld a, l
	ldh [$FFDF], a
	ld a, h
	ldh [$FFE0], a
	pop hl
	ld bc, $0010
	add hl, bc
	ld a, l
	ldh [$FFDD], a
	ld a, h
	ldh [$FFDE], a
	call CallCopyWRAMToVRAM
	call UpdateInputs
	pop bc
	ld a, [$C29D]
	ld c, a
	ld a, [$C29E]
	and c
	jp nz, HandleTitleInput
	dec b
	jp nz, .slantloop2
	jp HandleTitleInput
	
.sidesintro ;4A4A
	ld a, $C3
	ldh [$FFDF], a
	ld a, $00
	ldh [$FFE0], a
	ldh a, [$FFA1]
	add a, $80
	ldh [$FFA1], a
	ld a, $80
	ldh [$FFA3], a
	ld b, $27
.sidesloop
	push bc
	ld a, $7F
	call CallDrawModel
	ldh a, [$FFDF]
	cpl
	add a, $01
	ldh [$FFDF], a
	ldh a, [$FFE0]
	cpl
	adc a, $00
	ldh [$FFE0], a
	ld a, $80
	call CallDrawModel
	ldh a, [$FFDF]
	cpl
	sub $04
	ldh [$FFDF], a
	ldh a, [$FFE0]
	cpl
	sbc a, $00
	ldh [$FFE0], a
	call CallCopyWRAMToVRAM
	ldh a, [$FFA1]
	add a, $0A
	ldh [$FFA1], a
	call UpdateInputs
	pop bc
	ld a, [$C29D]
	ld c, a
	ld a, [$C29E]
	and c
	jr nz, HandleTitleInput
	dec b
	jp nz, .sidesloop

HandleTitleInput: ;4AA0, this is when the timers are up or buttons are pressed
	ld d, $06
	call WaitFrames
	call DrawTitleCopyright
	call LoadTitleLogo
	call CallCopyWRAMToVRAM
	ld a, $03
	ld [$C118], a
	ld c, $AE
.loop1
	call WaitForVBlank
	call SetEkkusuOAM
	ld a, c
	sub $08
	ld c, a
	cp $4E
	jr nz, .loop1
	
	ld a, $04
	ld [$C118], a
	ldh a, [rBGP]
	ldh [rOBP1], a
	call NextRand
	and $01
	jr nz, .skip
	ldh a, [rBGP]
	cpl
	ldh [rOBP1], a ;if that function returned 1, invert the object palette??
.skip
	ld b, $02 ;do this next loop twice, flash and shake
.loop2
	push bc
	ld c, $54
	call SetEkkusuOAM
	call WaitForVBlank
	ld a, $06
	ldh [rSCX], a
	ldh a, [rOBP1]
	ldh [rBGP], a
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	ld c, $56
	call SetEkkusuOAM
	call WaitForVBlank
	ld a, $08
	ldh [rSCX], a
	ld a, %10000111
	ldh [rBGP], a
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	pop bc
	dec b
	jr nz, .loop2
	
	ld b, $78 ;$78 frames we're waiting
.TitleWait ;4B13
	push bc
	call WaitForVBlank
	pop bc
	dec b
	jp nz, .TitleWait
	
	call LoadTitleLogo
	call CallReadSave
	call DrawTitleText
	call DrawTitleCopyright
	call CallCopyWRAMToVRAM
	ld a, LOW(DeleteSaveInputList)
	ld [wInputCodePtrLo], a
	ld a, HIGH(DeleteSaveInputList)
	ld [wInputCodePtrHi], a
	call CallRefreshBGTiles ;this func updates a quarter of the screen at a time
	ld hl, wUpdateCounter ;based on this var
	inc [hl] ;so we call the func and increment the var four times
	call CallRefreshBGTiles ;to update the whole screen.
	ld hl, wUpdateCounter
	inc [hl]
	call CallRefreshBGTiles
	ld hl, wUpdateCounter
	inc [hl]
	call CallRefreshBGTiles
	xor a
	ld [wUpdateCounter], a ;and finally reset the var
.titleidle
	call WaitForVBlank
	ld a, [wFrameCounterLo] ;vblank counter
	or a
	jr nz, .skip2 ;if not 0, skip
	ld a, [wUpdateCounter] ;otherwise
	inc a
	ld [wUpdateCounter], a ;increment update counter
	cp $04
	jr c, .skip2 ;if less than four, skip
	call CallPlayDemo ;else, play demo
	jp Reset
.skip2
	call UpdateInputs
	call CallCheckDeleteSaveInput
	jp nc, .dontwipe
	xor a
	ld [$C0AF], a
	ld [$CB4A], a
	ldh [$FF91], a
	ld [$C2C3], a
	ld [$C2C4], a
	ld [$C298], a ;wipe the progress in wram
	call CallWriteSave ;and wipe the save
	jp Reset
.dontwipe ;4B8C
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	or a
	jr z, .titleidle ;if nothing pressed, loop
	ld a, [$C0AF] ;level progress?
	and a
	jp z, .checksaveandreturn ;if savefile value is zero, skip ahead
	ld a, [$C2C3] ;big stars (levels clear?)
	and a
	jp z, .checksaveandreturn ;if savefile value is zero, skip ahead
	xor a
	ld [wSelectedContinueOption], a ;else write 0 to this
.continueprompt ;4BA9
	ld a, $0A
	call EmptyFunc30D46
	call LoadTitleLogo
	call DrawTitleCopyright
	ld a, $20
	ld [$CB1C], a
	ld c, $60
	ld a, [wSelectedContinueOption]
	ld hl, TitleTextContinueYes
	or a ;if zero (yes)
	jr z, .drawcontinuetext ;use 7E62
	ld hl, TitleTextContinueNo ;else use no
.drawcontinuetext
	call CallHandleTitleText
	ld b, $68
	call CallDrawTitleLetters
	call CallCopyWRAMToVRAM
.continueidle
	call WaitForVBlank
	call UpdateInputs
	ld a, [wChangedInputs]
	ld c, a
	ld a, [wCurrentInput]
	and c
	ld c, a
	and $09 ;mask for Start or A
	jr nz, .handleselection
	ld a, c
	and $F4 ;check other inputs except b
	jr z, .continueidle
	ld a, $05
	ld [$C100], a
	ld a, [wSelectedContinueOption]
	xor $01
	ld [wSelectedContinueOption], a
	jp .continueprompt
.handleselection
	ld a, $01
	ld [$CB4A], a
	ld a, [wSelectedContinueOption]
	or a
	ret z ;if yes selected, return
.checksaveandreturn ;4C04, prepare recap text? called after input at title
	xor a
	ld [$C0AF], a
	ld [$CB4A], a ;no continue
	ldh a, [$FF91] ;not sure what this save flag is for
	or a
	ret z ;if flag is zero, return
	ld a, $01
	ld [$C298], a ;training completed flag?
	ret
;4C15

SECTION "loadtitlelogo", ROMX[$4C71], BANK[$C]
LoadTitleLogo: ;4C71
	ld de, $8FF4 ;vram
	ld hl, $4529 ;x title logo
	ld b, $08
.copytilegroup ;4C79
	ld c, $28
.copytile ;4C7B
	ldh a, [rSTAT]
	and $02
	jr nz, .copytile
	ld a, [hl+]
	ld [de], a
	inc hl
	inc e
	inc de
	dec c
	jp nz, .copytile
	ld a, e
	add a, $60
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jp nz, .copytilegroup
	ld de, $D41A
	ld c, e
	ld hl, $452A
	ld b, $08
.copytilegrouptowram ;4C9F
	push bc
	ld c, $28
.copytiletowram ;4CA2
	ld a, [hl+]
	ld [de], a
	inc hl
	inc e
	dec c
	jp nz, .copytiletowram
	pop bc
	ld e, c
	inc d
	dec b
	jp nz, .copytilegrouptowram
	ret
;4CB2

SECTION "C:4D46", ROMX[$4D46], BANK[$C]
EmptyFunc30D46: ;4D46
	ret

SECTION "C:4D96", ROMX[$4D96], BANK[$C]
SetupTitleScreenBackground: ;0x4D96
	ld hl, $9823 ;this is in the background map
	ld bc, $0B80
	ld a, $D0
.biggerloop ;do this 0B times
	push bc
	ld b, $10
.firstloop ;do this 10 times
	ld [hl+], a
	add a, $0B
	dec b
	jr nz, .firstloop
	ld bc, $0010
	add hl, bc ;add 10 to the address
	pop bc
	inc c
	ld a, c
	add a, $50 ;a becomes c+51
	dec b
	jr nz, .biggerloop
	ld de, EkkusuGFX ;this is a tile offset to "Ekkusu"
	ld hl, VRAM_Begin 
	ld b, $60 ;number of tiles to copy
.lastloop
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .lastloop
	ret
	
EntityLogicHomingMissile: ;0x4DC2
	ld a, [$C356] ;collided?
	or a
	jr z, .nocollision
	dec hl ;step back to first byte (model ID)
	set 7, [hl] ;set top bit (forming/exploding)
	ld a, [wHealth]
	sub $02
	ld [wHealth], a
	ld a, [wScreenShakeCounter]
	add a, $32
	ld [wScreenShakeCounter], a
	ret
.nocollision
	call CallTurnEntTowardsPlayer
	ld b, $50
	ld c, $00
	call CallMoveEntityForward
	ld e, l
	ld d, h
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speed?
	ld a, [hl]
	add a, $04
	ld [hl], a ;increment by four
	ret nc
	ld l, e
	ld h, d
	ld a, $FF
	call CallDamageEntity ;destroy if rollover
	ret

ScrollNextMonoText: ;4DFD
	ld hl, wScreenTextLine1Val
	ld b, $06
	call ScrollMonoTextUpward
	ld hl, wScreenTextLine2Val
	ld b, $03
	call ScrollMonoTextUpward
	ret
	
ScrollMonoTextUpward: ;4E0E
	;b is amount to move, HL is pointer to vals
	ld a, [hl+]
	and $7F
	ret nz
	ld e, l
	ld d, h
	dec de
	dec de
	dec de
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	inc de
	inc de
	xor a
	ld [de], a
	ret

AddNewMonoTextLine: ;4E22
	call ScrollNextMonoText
	ld a, $20
	ld [wTextBubbleX], a
	ld hl, wScreenTextLine1Ptr
	ld bc, $0A03 ;C is iterator, B is offset into mono?
.loop ;4E30
	push bc ;save iterator
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;DE is screentext pointer
	ld a, [hl] ;screentext value
	bit 7, a
	jr z, .noflag ;if top bit of value not set, to 4E5D
	;negative value?
	sub $01
	cp $80
	jr c, .finishcycle ;if value was 80, jump to 4E7D
	ld [hl], a ;save decremented value
	push hl ;save read position
	ld l, e
	ld h, d ;load pointer into HL
	call ClearMonoTextRegion
	ld a, l
	or h
	jr z, .restoreposition ;if HL empty, jump to 4E7C
	push bc ;save iterator again
	ld a, b
	push af ;save mono offset
	ld c, $60
	call CallHandleSomeLetters ;returns modified C registered
	pop af
	add a, $20
	ld b, a ;increment offset by 20
	call CallPrintTutorialTextPage
	pop bc ;restore original offset + iterator
	jr .restoreposition ;to 4E7C
	
.noflag ;4E5D, positive value?
	sub $01
	jr c, .finishcycle ;if was zero, jump to 4E7D
	ld [hl], a ;save decremented value
	push hl ;save read position
	ld l, e
	ld h, d ;load hl with the pointer
	call ClearMonoTextRegion
	ld a, l
	or h
	jr z, .restoreposition ;if hl is zero, go to 4E7C
	push bc ;save offset and iterator
	ld a, b
	push af ;save offset
	ld c, $60 ;
	call CallHandleTitleText
	pop af ;restore offset
	add a, $20
	ld b, a ;increase offset?
	call CallDrawTitleLetters
	pop bc ;restore original offset and iterator
.restoreposition ;4E7C
	pop hl ;restore read position
.finishcycle ;4E7D
	inc hl ;go to the next entry
	pop bc ;restore iterator
	ld a, b
	add a, $0C ;the next offset
	ld b, a
	dec c
	jp nz, .loop
	ret
	
ClearMonoTextRegion: ;4E88
	push bc
	push hl
	ld l, b
	ld h, $D0
	ld b, $10
.loop
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
	ld [hl+], a ;12 bytes
	inc h
	ld a, l
	sub 12
	ld l, a ;next row
	dec b
	jp nz, .loop
	pop hl
	pop bc
	ret
	
DoSiloInteriorText: ;4EA8
	call CallLoadSiloInterior
	call Wait200Frames
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	ld hl, LocateCrystalText
	jr nz, .write
	ld hl, ThisIsSiloText
.write
	ld c, $19
	call CallTryWriteScreenText
	ret

TutFadeOut: ;4EC1
	ld a, -1
	ldh [hGameState], a
	loadpalette 0, 0, 2, 2
	ldh [hBGP], a
	loadpalette 1, 0, 2, 2
	ldh [hIntP], a
	call Wait13VBlanks
	loadpalette 0, 0, 1, 2
	ldh [hBGP], a
	loadpalette 1, 0, 1, 2
	ldh [hIntP], a
	call Wait13VBlanks
	loadpalette 0, 0, 1, 1
	ldh [hBGP], a
	loadpalette 0, 0, 1, 2
	ldh [hIntP], a
	call Wait13VBlanks
	loadpalette 0, 0, 0, 1
	ldh [hBGP], a
	loadpalette 0, 0, 0, 1
	ldh [hIntP], a
	call Wait13VBlanks
	loadpalette 0, 0, 0, 0
	ldh [hBGP], a
	ldh [hIntP], a
	call Wait13VBlanks
	call CallDisableLCD ;redundant, called in ClearAllVRAM
	call ClearAllVRAM
	ret

HandleGameOver: ;4F01
	ld a, [$CB4A] ;check for continue
	or a
	jp nz, .continue ;jump to continue handler
	call CallTutFadeOut
	ld a, [wCurLevel] ;check a state var
	cp LEVEL_TUTORIAL
	jr nz, .gameover ;if not $2C (tutorial), jump to 4F49
	;the following is possibly unused:
	ld hl, $7517 ;tilemap address, unused GAME OVER try again
	ld bc, $0080
	ld de, $0001
	call LoadTileMap
	xor a
	ldh [$FF93], a
	ld [$C2ED], a
	ldh [$FF42], a
	ld a, $08
	ldh [$FF43], a
	ld a, $FF
	ldh [$FF4B], a
	xor a
	ldh [$FF0F], a
	ld a, $01
	ldh [$FFFF], a
	ld a, $B4
	ldh [$FF47], a
	ld a, $00
	ldh [$FF48], a
	ldh [$FF49], a
	ld a, $A3
	call CallFlashScreen
	call WaitForStartPress
	xor a
	ret
	
.gameover ;4F49
	ld hl, GameOverTilemap
	call LoadBank7TilesetOffset80
	jr .drawgameoverlevel
.continue ;4F51
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, ContinueTextTilemap
	call LoadBank7TilesetOffset80
	jp .b2
.drawgameoverlevel
	ld hl, $994D ;gameover level placement
	ld a, [$C0AF]
	rrca
	rrca
	inc a
	ld c, a ;c (number to print) = (C0AF >> 2) + 1
	ld b, $00 ;font color
	call CallSetContinueNumberTile
.b2 ;4F6F
	ld hl, ContinueArrowGFX
	ld de, $8000
	ld b, $20
.copyloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copyloop
	call CallDrawContinueBottomBox
	ldh a, [$FF91]
	or a
	jp z, .smolskeep
	ld a, $24
	ld [$C0AF], a
.smolskeep
	call CallWriteSave
	ld a, [$CB4A]
	or a
	call z, WaitForStartPress
	ld a, [wBigStars]
	and a
	ret z ;if no stars, return
	ld a, [$C0AF]
	and a
	ret z
	xor a
	ld [wMenuSelection], a ;default selection to YES
	cpl
	ld [$CACC], a
	ld a, $02
	ld [$CAC9], a
	ld a, $50
	ld [$C2EC], a
	xor a
	ldh [$FFD1], a
	ld a, [$CB4A]
	or a
	jr nz, .skipask
.askcontinue
	ld hl, ContinueScreenContinueText ;this is in bank A
	ld de, $9904 ;?
	ld c, $00
	call CallContinueEnglishParser
	xor a
	ld [wMenuSelection], a
	cpl
	ld [$CACC], a
	ld a, $02
	ld [$CAC9], a
	ld a, $50
	ld [$C2EC], a
	xor a
	ldh [$FFD1], a
	call CallHandleContinueScreenInput
	ld a, $02
	ld [$C100], a
	ld a, [wMenuSelection]
	and a
	ret nz ;if no selected, return
.skipask
	ld a, [$C0AF]
	push af
	and $FC
	rrca
	rrca
	ld c, a
	ld a, [wBigStars]
	cp c
	jr nc, .innerloop
	rlca
	rlca
	ld [$C0AF], a
.innerloop
	ld a, [$C0AF]
	and $FC
	rrca
	rrca
	and $0F
	ld [$C330], a
	ld hl, ContinueScreenPlayText
	ld de, $98E3
	ld c, $00
	call CallContinueEnglishParser
	ld a, $60
	ld [$C2EC], a
	call CallHandleContinueScreenInput
	ld a, $02
	ld [$C100], a
	ld a, [wMenuSelection]
	or a
	jr z, .noloop
	ld a, [$C0AF]
	sub $04
	ld [$C0AF], a
	jr nz, .innerloop
	pop af
	ld [$C0AF], a
	ld hl, ContinueScreenSixEmptyLines
	ld de, $98E1
	ld c, $00
	call CallContinueEnglishParser
	jp .askcontinue
.noloop
	ld a, [$C0AF]
	and $FC
	rrca
	rrca
	ld b, a
.decstarsloop ;decrement the stars
	push bc
	ld a, $02
	ld [$C100], a
	ld a, [wBigStars]
	dec a
	ld [wBigStars], a
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
	ld a, [$C2C4]
	ld c, a
	ld b, $01
	call CallSetContinueNumberTile
	ld e, l
	ld d, h
	ld hl, ContinueScreenDoubleSpace
	ld c, $01
	call CallContinueEnglishParser
	call Wait13VBlanks
	pop bc
	dec b
	jp nz, .decstarsloop
	ld a, $08
	ld [$CA9F], a
	xor a
	ld [$CB4F], a
	ld [$CA81], a
	ld a, $40
	ld [$CA82], a
	call CallWriteSave
	pop af
	scf
	ret
	
ContinueArrowGFX: ;50A1, only one tile but mistakenly gets two bytes copied to VRAM. oops!
	INCBIN "build/gfx/ContinueArrow.2bpp"
	
CheckGameOverCondition: ;50B1
	ld hl, wTimerFrames
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret nz ;return if timer not zero
	ld a, [wGameOverTimer]
	or a
	ret nz ;return if we ran out of time during gameover (or gameovered to health)
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	push hl ;timer value (zero)
	call CallWriteTimeOverTexts
	pop hl
	ld a, $19
	ld [wGameOverTimer], a ;give the player some time to see it!
	ret

DrawTimer: ;50CE
	ld hl, wTimerFrames
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld b, $FF
	ld a, h ;hl is an address?, H in A
.lilloop
	inc b
	sub $0A
	jr nc, .lilloop
	add a, $0A
	ld [wTimerDigit2], a
	ld a, b
	ld [wTimerDigit1], a ;a (h) and b saved
	ld b, $FF
	ld a, l
.lilloop2
	inc b
	sub $0A
	jr nc, .lilloop2
	add a, $0A
	ld [wTimerDigit4], a
	ld a, b
	ld [wTimerDigit3], a ;a (l) and b saved
	ld bc, $103E
	ld hl, $C048
	ld a, $0B ;left border tiles
	call WriteTimerOAMPair
	ld a, [wTimerDigit1]
	call WriteTimerOAMPair
	ld a, [wTimerDigit2]
	call WriteTimerOAMPair
	ld a, c
	sub $03
	ld c, a
	ld a, $0A ;semicolon tiles
	call WriteTimerOAMPair
	ld a, c
	sub $02
	ld c, a
	ld a, [wTimerDigit3]
	call WriteTimerOAMPair
	ld a, [wTimerDigit4]
	call WriteTimerOAMPair
	ld a, $0C ;right border tiles
	call WriteTimerOAMPair
	ret
WriteTimerOAMPair: ;512C
	sla a ;multiply a by 2
	add a, $19
	ld e, a ;add 19, store to e
	ld a, b ;store passed b (y)
	ld [hl+], a
	add a, $08 ;b += 8
	ld b, a
	ld a, c
	ld [hl+], a ;store passed c (x)
	ld a, e
	ld [hl+], a ;store passed e (tile)
	ld a, [$C0AF]
	cp $2C
	jr z, .skipld1
	ld a, [wTimerEnableFlag]
	or a
.skipld1
	ld a, $10
	jr z, .skipxor1
	xor a
.skipxor1
	ld [hl+], a ;store attribs
	inc e ;increment tile
	ld a, b
	ld [hl+], a ;store y
	sub $08
	ld b, a ;set y back to top
	ld a, c
	ld [hl+], a ;store x
	ld a, e
	ld [hl+], a ;store tile
	ld a, [$C0AF]
	cp $2C
	jr z, .skipld2
	ld a, [wTimerEnableFlag]
	or a
.skipld2
	ld a, $10
	jr z, .skipxor2
	xor a
.skipxor2
	ld [hl+], a ;store attribs
	ld a, c
	add a, $08
	ld c, a ;increment x by 8
	ret
	
SetEntityIsForming: ;516B
	push hl
	dec hl
	set 7, [hl] ;set high bit (assemble/disassemble)
	ld a, l
	add a, $17
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	set 2, [hl] ;set forming flag
	pop hl
	ret


HandleEntityDrop: ;517B
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, [wLevelClearCountdown]
	or a
	ret nz ;don't do anything when ending the level
	dec hl
	ld a, [hl+] ;model ID
	dec a
	add a, $32
	ld e, a
	ld a, $40
	adc a, $00
	ld d, a ;DE is table at 4032
	ld a, [de]
	or a
	ret z ;if 0 entry, return
	cp $7F ;special flag
	jr nz, .gotDropID ;same as 1C
	ld a, [$C283]
	inc a
	ld [$C283], a
	cp $19
	jr c, .randomdrop
	xor a
	ld [$C283], a
	ld a, $40 ;use $40 (hexagon) instead of $7F
	jr .gotDropID 
.randomdrop ;8
	call NextRand
	and $03
	dec a
	jr z, .r1
	dec a
	jr z, .r2
	dec a
	jr z, .r3
	ld a, $3C ;use $3C instead of $40
	jr .gotDropID ;same as 1C
.r3
	ld a, $22
	jr .gotDropID
.r2
	ld a, $3C
	jr .gotDropID
.r1
	ld a, $25
.gotDropID ;2F, 1C, A, 6, 2
	ld c, a
	push bc ;C is table value
	and $7F
	call CallEntityDropNewEntity
	pop bc
	ret c ;if we failed to create dropped entity, return
	ld a, e
	add a, $08
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;new entity entry + 8?
	ld a, [hl]
	add a, $80
	ld [hl], a ;flip Y orientation?
	ld a, c
	and $7F
	cp $10 ;antenna?
	jr nz, .notAntenna
	ld a, e ;model was $10
	add a, $05
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;entity position + 5 (y position?)
	ld a, [hl]
	add a, $28
	ld [hl+], a ;ypos += 28
	ld a, [hl]
	adc a, $00
	ld [hl], a
.notAntenna ;10
	bit 7, c
	jr z, .form
	ld a, e ;if top bit was set (only for the glider?)
	add a, $18
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	xor a
	ld [hl], a ;zero out the final byte (not map object)
	ret
.form ;5201, b
	ld l, e
	ld h, d
	inc hl ;advance to position
	call CallSetEntityIsForming ;don't need to farcall?
	ret

DrawCompass: ;5208
	ldh a, [hGameState]
	dec a
	jr nz, .skipplanet ;if not planet, jump ahead
	ld a, [$C2A1]
	and $01
	ret nz
.skipplanet
	ld a, [wViewDir]
	srl a
	srl a
	ld c, a ;c is our modified view direction
	ld de, $8810 ;compass tiles
	call CopyCompassGFXTile
	ld a, $F0
	call CopyCompassGFXTileWithMask
	ld a, $0F
	call CopyCompassGFXTileWithMask
	call CopyCompassGFXTile
	ret
	
CopyCompassGFXTile: ;522F
	ld a, c
	and a
	xor $07
	ld h, $00
	rla
	rl h
	rla
	rl h
	rla
	rl h
	rla
	rl h
	add a, LOW(gfxCompass)
	ld l, a
	ld a, h
	adc a, HIGH(gfxCompass)
	ld h, a
	ld b, $08
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .statloop
	ld a, c
	add a, $08
	and $3F
	ld c, a
	ret
	
CopyCompassGFXTileWithMask: ;5261
	ld b, a
	ld a, c
	push bc
	ld c, b
	and a
	xor $07
	ld h, $00
	rla
	rl h
	rla
	rl h
	rla
	rl h
	rla
	rl h
	add a, LOW(gfxCompass)
	ld l, a
	ld a, h
	adc a, HIGH(gfxCompass)
	ld h, a
	ld b, $08
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl+]
	and c
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .statloop
	pop bc
	ld a, c
	add a, $08
	and $3F
	ld c, a
	ret

SECTION "5298 bank c", ROMX[$5298], BANK[$C]
SetCompassTiles: ;5298
	ld hl, $9989 ;position in vram
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, $81 ;the first of four compass tile IDs
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	ret
	
gfxCompass: ;52AB
INCBIN "build/gfx/compass.2bpp"

EntityLogicTruck: ;56AB
	ld a, [$CB0B]
	inc a
	ld [$CB0B], a ;increment truck count
	ld e, l
	ld d, h ;backup pointer
	ld a, l
	add a, $0C
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to shot byte
	bit 0, [hl]
	jr z, .notDamaged ;if it hasn't been shot, skip
	res 0, [hl]
	ld a, l
	add a, $02
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;speedup byte
	ld a, $01
	ld [hl], a ;set to 1
	ld hl, TruckDamagedText
	ld c, $19
	call CallTryWriteScreenText
	ret
.notDamaged ;16
	ld l, e
	ld h, d ;restore pointer
	ld a, l
	add a, $0E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speedup byte
	ld a, [hl]
	or a
	jr z, .noSpeedup ;if zero, skip ahead
	inc a
	ld [hl], a ;increment again
	cp $20 ;keep going until it's 20
	ret c
	xor a
	ld [hl], a ;when it's 20, reset it to zero.
	ret
.noSpeedup ;8
	ld l, e
	ld h, d ;restore pointer
	push hl ;backup pointer
	dec hl
	ld a, [hl]
	ld c, a ;model ID into C
	ld a, l
	add a, ENTITY_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to next entity
	ld a, c ;model ID
	call CallFindEntityWithModel
	jr c, .noneFound ;if there are none, jump! (aren't we one? will this never jump?)
	inc hl ;HL is now the first truck on the list
	pop de
	push hl
	push de ;and DE is our entity
	call CallGetDistanceBetweenEnts
	ld bc, $0032
	jr c, .getAngle ;jump if Y < X
	ld bc, $0028
	cp $0F
	jr nc, .getAngle;if above $F, jump
	ld bc, $001E
	cp $0A
	jr nc, .getAngle ;if between $F and A, jump
	ld bc, $000F
	cp $07
	jr nc, .getAngle ;if between A and 7, jump
	ld bc, $0007
	cp $05
	jr nc, .getAngle ;if between 7 and 5, jump
	ld a, [$CB0C]
	inc a
	ld [$CB0C], a
	ld bc, $0000
.getAngle ;26, 1F, 18, 11, A
	ld a, c
	pop de
	pop hl
	push bc ;save 
	call CallGetAngleBetweenEnts
.angleLoop ;5739
	sub $80 ;invert angle
	ld c, a ;load it into c
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to Z orientation
	ld a, c
	sub a, [hl] ;get angle difference
	add a, $04
	cp $08
	jr c, .doneTurning ;if behind, skip
	sub $04
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft
	ld a, [hl]
	sub $80
	ld [hl], a ;otherwise turn that much and save it
	jr .doneTurning
.turnRight ;A
	ld a, [hl]
	add a, $02
	ld [hl], a
	jr .doneTurning
.turnLeft ;C
	ld a, [hl]
	sub $02
	ld [hl], a
.doneTurning ;1A, A, 4
	jp .move
.noneFound ;6A
	pop hl
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed byte
	ld a, [de]
	sla a
	add a, $F4
	ld e, a
	ld a, $57
	adc a, $00
	ld d, a ;DE is an entry in the word table at 57F4
	push hl
	ld a, [de]
	cp $80
	jr nz, .notFinal ;if it's not 80, jump
	ld a, [wLevelClearCountdown]
	or a
	jp nz, .end ;if level's over, skip
	ld a, [$C2C8] ;bases/objectives left?
	dec a
	ld c, a
	ld a, [$CB0C] ;number of trucks at destination?
	cp c
	jr nz, .end ;not equal, skip
	call ClearAllScreenText
	ld hl, TruckArrivedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, TruckArrivedText2
	ld c, $32
	call CallTryWriteScreenText
	call CallTriggerMissionComplete
.end ;57AC, 16
	pop hl
	ret
	
.notFinal ;2A
	ld b, a
	ld c, $00
	inc de
	ld a, [de]
	ld d, a
	ld e, c ;BC is first byte, DE is second byte (in the upper bytes)
	ld a, [hl+]
	sub a, c
	ld c, a
	ld a, [hl+]
	sbc a, b
	ld b, a
	ld a, [hl+]
	sub a, e
	ld e, a
	ld a, [hl+]
	sbc a, d
	ld d, a ;subract our position from the target position
	inc a
	cp $03
	jr nc, .newAngle ;if farther than 3, jump
	ld a, b
	inc a
	cp $03
	jr nc, .newAngle ;if farther than 3, jump
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speed
	inc [hl] ;increment speed!
.newAngle ;f, 9
	call CallGetAngleToOffset
	pop hl
	ld e, a ;save new angle
	ld bc, $0000
	ld a, [$C2B8] ;check this value
	or a
	jr z, .cleanupAndLoop ;if zero, don't set this next value?
	ld bc, $001E
.cleanupAndLoop ;3
	push bc
	ld a, e
	jp .angleLoop
.move ;57EB
	pop hl
	pop bc
	ld b, c
	ld c, $00
	call CallMoveEntityForward
	ret
	
;57F4, table of byte pairs, target positions
	dw $1840, $4058, $7060, $60A0, $5DE0, $8080

SetupRadarItemGFX: ;5800
	ld hl, gfxShopEntries
	ld de, $8500
	ld b, $C0
.copytotiledata
	ld a, [hl+]
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
	dec b
	jp nz, .copytotiledata
	ld hl, $99A2
	ld de, $001A
	ld b, $04
	ld a, $50
.settilemapleft
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	add hl, de
	dec b
	jr nz, .settilemapleft
	ld hl, $99AE
	ld de, $001A
	ld b, $04
	ld a, $68
.settilemapright
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	ld [hl+], a
	inc a
	add hl, de
	dec b
	jr nz, .settilemapright
	ret

DrawRadarBaseItem: ;584D
	ld a, c
	rlca
	rlca
	rlca ;C*8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl ;C*32
	ld e, l
	ld d, h
	add hl, hl
	add hl, de ;C*96
	ld e, l
	ld d, h
	ld a, e
	add a, $00
	ld e, a
	ld a, d
	adc a, $85
	ld d, a ;DE += $8500 (item GFX offset)
	ld a, l
	add a, LOW(gfxShopEntries)
	ld l, a
	ld a, h
	adc a, HIGH(gfxShopEntries)
	ld h, a ;hl points to the gfx data to use?
	ld a, b
	or a ;2 if item collected, 1 if highlighted
	jr z, .drawcollected
	dec a
	jr z, .drawhighlighted
	ld b, $30
.neutralvblankloop ;5875, FA
	ldh a, [rSTAT]
	and $02
	jr nz, .neutralvblankloop
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .neutralvblankloop
	ret
.drawcollected
	ld b, $30
	ld c, %01010101
.cvbl
	ldh a, [rSTAT]
	and $02
	jr nz, .cvbl
	ld a, [hl+]
	and c
	ld [de], a
	inc e
	ld a, [hl+]
	and c
	ld [de], a
	inc de
	ld a, c
	cpl ;invert pattern for chequering
	ld c, a
	dec b
	jp nz, .cvbl
	ret
.drawhighlighted ;highlighted
	ld b, $30
.hvbl
	ldh a, [rSTAT]
	and $02
	jr nz, .hvbl
	ld a, [hl+]
	cpl ;invert
	ld [de], a
	inc e
	ld a, [hl+]
	cpl
	ld [de], a
	inc de
	dec b
	jp nz, .hvbl
	ret
	
EntityLogicNukeBomb: ;58B5
	ld a, [wEntityCollided]
	or a
	jr z, .applyArc
	xor a
	ld [wCollisionType], a ;wipe the collision type
.applyArc ;4
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to speed
	ld a, [de]
	add a, $02
	ld [de], a ;increment by 2
	sub $22
	ld c, a
	cp $80 ;are we over 22? carry if we are
	ld a, $00
	adc a, $FF
	ld b, a ;B is 0 if we are over 20, -1 if not
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to ypos
	ld a, [de]
	add a, c
	ld [de], a ;add our count
	inc de
	ld a, [de]
	adc a, b
	ld [de], a ;and our signed top
	cp $80
	jp c, .boom ;if we collided with the ground, jump ahead
	ld b, $5A
	ld c, $00
	call CallMoveEntityForward ;else move the bomb forward
	ret
.boom ;58F1
	call CallHighEXDamageEnts
	ld a, [wScreenShakeCounter]
	add a, $19
	ld [wScreenShakeCounter], a
	ld hl, HighEXText
	ld c, $32
	call CallTryWriteScreenText
	ld hl, DamagedEverythingText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $0A
	ld [wFlash3DWindow], a
	ld a, [wHealth]
	sub $08
	ld [wHealth], a ;ouch!
	ret nc
	ld a, $FF
	ld [wHealth], a
	ld hl, NoShieldText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $19
	ld [wGameOverTimer], a
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	ret

EntityLogicTank: ;5932
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	bit 0, a
	jr z, .dotanklogic
	res 0, a
	ld [de], a ;clear bottom bit
	push hl
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	cpl
	add a, $01
	ldh [$FFCF], a
	ld a, [hl+]
	cpl
	adc a, $00
	ldh [$FFD0], a
	call CallGenerateDebris
	pop hl
	ld e, l
	ld d, h
	call NextRand
	and $07
	sub $04
	ld c, a
	inc de
	ld a, [de]
	add a, c
	ld [de], a
	inc de
	inc de
	ld a, [de]
	add a, c
	ld [de], a
	call CallSetEntityIsForming
	ld a, $11
	ld [$C100], a
.dotanklogic ;37
	jp CallGenericEnemyLogic ;don't need farcall

gfxShopEntries: ;5979
INCBIN "build/gfx/shopentries.2bpp"

MonoBufferToRadarScreen: ;5C79
	ld de, wMonoBufferColumn1
	ld hl, $9001 ;target tiledata start?
	ld b, $10
.tileloop
	push bc
	ld a, [de]
	inc e
	ld c, a
	ld a, [de]
	ld b, a ;load two bytes from buffer into BC?
.vblankloop
	ldh a, [rSTAT]
	and $02
	jr nz, .vblankloop ;wait till we can write to vram
	ld a, c
	ld [hl+], a
	inc l
	ld a, b
	ld [hl+], a ;write our two read bytes, skipping a vram byte each
	inc hl
	xor a
	ld [de], a
	dec e
	ld [de], a
	ld a, e
	add a, $02
	ld e, a ;wipe out the source mono buffer
	pop bc
	cp $40
	jr c, .tileloop
	ld e, $00
	inc d
	dec b
	jr nz, .tileloop
	ret
	
RadarTextLevel1: ;5CA7, level 1 radar
	ld a, $24
	ld [wTextBubbleX], a
	ld a, [$C0AE] ;progress?
	or a
	jr nz, .crystalcollected ;if crystal collected, change
	ld hl, RadarTextL1E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL1E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
.crystalcollected
	ld hl, RadarTextL1E2L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL1E2L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck

RadarTextLevelTUT: ;5CEC, tutorial radar text
	ld a, $22
	ld [wTextBubbleX], a
	ld a, [wTutRadarTextPage]
	inc a
	and $07
	jr nz, .updatepage
	ld a, $01
	ld [wTutSawAllRadarText], a
	xor a
.updatepage
	ld [wTutRadarTextPage], a
	dec a
	and $07
	rlca
	add a, LOW(RadarTutorialTextPointers)
	ld l, a
	ld a, HIGH(RadarTutorialTextPointers)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallPrintTutorialTextPage
	ret
	
RadarTutorialTextPointers: ;5D1C, 8 pointers to the tutorial text pages, bank 9
	dw RadarTutText1, RadarTutText2, RadarTutText3, RadarTutText4, RadarTutText5, RadarTutText6, RadarTutText7, RadarTutText8
	
RadarTextLevel10: ;5D2C, level 10 radar text
	ld a, $22
	ld [wTextBubbleX], a
	ld hl, RadarTextL10E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL10E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
	
RadarTextLevel5: ;5D4E, level 5 radar text
	ld a, $22
	ld [wTextBubbleX], a
	ld hl, RadarTextL5E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL5E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL5E1L3
	ld a, $4F
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	push bc
	ld hl, wEntityTable
	ld a, $1F ;garage
	call CallFindEntityWithModel
	inc hl
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	ret
RadarTextLevel9: ;5D99, level 9 radar text
	ld a, $24
	ld [wTextBubbleX], a
	ld hl, RadarTextL9E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, wEntityTable
	ld a, $20 ;cruise missile
	call CallFindEntityWithModel
	inc hl
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	call CallGetEntityDirection
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL9E1L2
	call CallDrawTitleLetters
	pop hl
	push bc
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
RadarTextLevel8: ;5DEA, level 8 radar text
	ld a, $25
	ld [wTextBubbleX], a
	ld a, [wTimerEnableFlag]
	or a
	jr z, .butterfly
	ld hl, RadarTextL8E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL8E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	push bc
	ld hl, wEntityTable
	ld a, $38 ;flower stem
	call CallFindEntityWithModel
	inc hl
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
.butterfly ;3B
	ld hl, RadarTextL8E2L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL8E2L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	push bc
	ld hl, wEntityTable
	call CallFindEntityWithModel
	pop bc
	inc hl
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	call CallGetEntityDirection
	ld a, $4F
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL8E2L3
	call CallDrawTitleLetters
	pop hl
	push bc
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	ret
RadarTextLevel4: ;5E87, level 4 radar text
	ld a, $24
	ld [wTextBubbleX], a
	ld a, [$C0AE] ;progress?
	bit 1, a ;bit 2 set with the correct scientist collected
	jr z, .alienbases
	ld hl, RadarTextL4E2L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
.alienbases
	ld hl, RadarTextL4E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL4E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	push bc
	ld hl, wEntityTable
	ld a, $1A ;shack
	call CallFindEntityWithModel
	inc hl
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck

RadarTextNumTable: ;5EDE, level 5/8 radar text pointers
	dw RadarTextNum0, RadarTextNum1, RadarTextNum2, RadarTextNum3, RadarTextNum4, RadarTextNum5, RadarTextNum6, RadarTextNum7, RadarTextNum8, RadarTextNum9, RadarTextNum10, RadarTextNum11, RadarTextNum12, RadarTextNum13, RadarTextNum14, RadarTextNum15
	
HandleRadarLevelText: ;5EFE, jumps to level's radar text handler
	ld a, [wCurLevel]
	and $FC ;? accomplishes nothing?
	rrca ;turn into a word offset
	add a, LOW(RadarLevelTextPointers)
	ld l, a
	ld a, HIGH(RadarLevelTextPointers)
	adc a, $00
	ld h, a ;table at 401A
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl ;jump to position based on level
	
RadarTextLevel2: ;5F10, level 2 radar text
	ld a, $23
	ld [wTextBubbleX], a
	ld hl, RadarTextL2E1L1
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	push bc
	ld hl, wEntityTable
	ld a, $12 ;alien bomb
	call CallFindEntityWithModel
	inc hl
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	ld a, [$CB02] ;number of bombs left
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	ld hl, RadarTextL2E1L2
	call CallDrawTitleLetters
RadarTextTimeCheck: ;5F60
	ld hl, RadarTextTimeUrgent ;urgent
	ld a, [wTimerFramesHi]
	cp $0A
	jr c, .print
	ld hl, RadarTextTimeWarning ;normal
	cp $14
	jr c, .print
	ld hl, RadarTextTimeBlank ;blank
.print
	ld a, $4F
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ret
RadarTextLevel3: ;5F7F, level 3 radar text
	ld a, $24
	ld [wTextBubbleX], a
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	ld a, [$CB0A] ;number of bases left?
	cp $01
	jp nz, .morethan1left
	ld hl, RadarTextL3E3L1
	jr .printnumber
.morethan1left
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	ld hl, RadarTextL3E1L1
.printnumber ;13
	call CallDrawTitleLetters
	ld a, [$C2DA] ;area of the giant
	or a
	jr nz, .lastone
	ld hl, RadarTextL3E2L1
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextBaseCheck
.lastone ;10
	dec a
	push af
	ld hl, RadarTextL3E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	pop af
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
RadarTextBaseCheck:
	ld hl, RadarTextTimeUrgent
	ld a, [$CB0A] ;bases left?
	cp $03
	jr c, .print
	ld hl, RadarTextTimeWarning
	cp $05
	jr c, .print
	ld hl, RadarTextTimeBlank
.print
	ld a, $4F
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ret
	
RadarTextLevel6: ;6003, level 6 radar text
	ld a, $24
	ld [wTextBubbleX], a
	ld hl, RadarTextL6E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL6E1L2
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
RadarTextLevel7: ;6025, level 7 radar text
	ld a, $24
	ld [wTextBubbleX], a
	ld a, [$C2C2]
	cp $04
	jr c, .glidersremain
	ld hl, DirectionTextNorth
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
.glidersremain
	ld hl, RadarTextL7E1L1
	ld a, $33
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, wEntityTable
	ld a, $07 ;glider
	call CallFindEntityWithModel
	inc hl
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	call CallGetEntityDirection
	ld a, $41
	ld b, a
	ld a, [wTextBubbleX]
	ld c, a
	call CallDrawTitleLetters
	ld hl, RadarTextL7E1L2
	call CallDrawTitleLetters
	pop hl
	push bc
	call CallGetEntityArea
	pop bc
	sla a
	add a, LOW(RadarTextNumTable)
	ld l, a
	ld a, HIGH(RadarTextNumTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CallDrawTitleLetters
	jp RadarTextTimeCheck
	
GetEntityArea: ;608D, called above? HL is pointer to entity?
	push hl
	inc hl
	ld a, [hl+]
	sub $80
	rlca
	and %00000001
	ld c, a ;c is 1 if [hl+1] was positive? 
	inc hl
	ld a, [hl+] ;[hl+3]
	sub $80
	cpl
	inc a ;negate
	rlca
	rlca
	rlca
	and %00000110
	add a, c ;a is now three bits?
	pop hl
	ret
	
EntityLogicSprog3ScenerySix: ;60A4
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;Z orientation
	ld a, [de]
	add a, $07
	ld [de], a ;zpin!
EntityLogicSprogNoSpin:
	ld a, [wUpdateCounter]
	and $1F
	srl a
	add a, LOW(.moveTable)
	ld c, a
	ld a, HIGH(.moveTable)
	adc a, $00
	ld b, a ;BC is a pointer into table
	ld a, [bc]
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;BC is now that table value sign-extended
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;Y position
	ld a, [de]
	add a, c
	ld [de], a
	inc de
	ld a, [de]
	adc a, b
	ld [de], a ;move it move it
	ret
	
.moveTable ;60D8
	db -8, -4, -2, -1, 0, 1, 2, 4, 8, 4, 2, 1, 0, -1, -2, -4
	
EntityLogicTunnelEntrance: ;60E8
	ld a, [$CB11]
	inc a
	ld [$CB11], a
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;z orientation
	ld a, [de]
	add a, $06
	ld [de], a ;zpin!
	ld a, [wEntityCollided]
	or a
	jp z, .done ;if no collision, leave
	ld a, $02
	ld [wCollisionType], a
	ld a, [wLurchTarget]
	bit 7, a
	jp nz, .done ;if we bonked, leave
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;z orientation
	ld e, [hl]
	pop hl
	ld a, [wViewDir]
	ld d, a
	sub a, e
	add a, $18
	sub $80
	ld e, a
	cp $30
	jr c, .checkBriefing
	add a, $80
	cp $30
	call c, CallPlayerJump
	jp .done
.checkBriefing ;A
	push hl
	ld hl, $7CCF ;hmm
	call CallCheckTutScriptProgress
	pop hl
	jr c, .enter
	ld hl, $7D70 ;(briefing, bank 9)
	call CallDisplayTutorialLesson
	call CallRestoreGUIAndMusic
	ret
.enter ;A
	ld a, $09
	ld [wQueueNoise], a
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;speed
	ld a, [hl]
	sub $01
	adc a, $00
	sla a
	add a, LOW(TunnelEntranceTable)
	ld l, a
	ld a, HIGH(TunnelEntranceTable)
	adc a, $00
	ld h, a ;speed is used for an entry into tunnel table at 7F29
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;tunnel pointer loaded into HL
	call LoadTunnel
	xor a
	ld [wEntityCollided], a
	ldh [hXLoCopy], a
	ldh [hXHiCopy], a
	ldh [hYLoCopy], a
	ldh [hXPosLow], a
	ldh [hXPosHi], a
	ldh [hYPosLow], a
	ld a, $01
	ldh [hYHiCopy], a
	ldh [hYPosHi], a
	ld a, $80
	ldh [hViewAngle], a
	ld [wViewDir], a
	xor a
	ld [wFlightPitch], a
	ld a, $14
	ldh [hZPosLow], a
	xor a
	ldh [hZPosHi], a
	ld a, $01
	ld [wHideEntities], a ;hide so we can process them
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.entLoop
	ld a, [hl+]
	or a
	jr z, .nextEnt ;empty slot? skip it
	bit 7, a
	jr nz, .nextEnt ;exploding? skip it
	push bc
	call CallCheckDeloadEntity
	pop bc
.nextEnt
	ld a, l
	add a, ENTITY_SIZE-1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .entLoop
	call CallIterateOverMapObjects
	xor a
	ld [wHideEntities], a ;all done, show them!
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
	ldh [$FFEE], a ;clear + set all of these
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr nz, .junction
	ld a, [wHealth]
	or a
	jr z, .loadGUI ;if out of health, jump
.junction ;6
	ld a, [wGameOverTimer]
	or a
	call z, CallHandleJunctionState
.loadGUI ;7
	call CallRestoreGUIAndMusic
.done ;61E8
	ret
	
LoadBriefBubbleGFX: ;61E9
	ld hl, BriefBubbleGFX + 8 ;second tile in bubble border?
	ld de, $DFE0 ;buffer destination
	call .copy1bpptile
	ld l, e
	ld h, d
	ld a, [$CB1B]
	sub $10
	jr z, .skip1
.loop1
	set 0, [hl]
	inc l
	dec a
	jr nz, .loop1
.skip1
	ld e, l
	ld d, h
	ld hl, BriefBubbleGFX + $18 ;fourth tile
	call .copy1bpptile
	ld hl, $DBE0
	ld a, $03
	ld [hl], a
	inc h
	ld a, $FF
	ld [hl], a
	inc h
	ld [hl], a
	inc h
	ld [hl], a
	ld a, [$CB1C]
	sub $04
	and $F8
	rrca
	rrca
	rrca
	ld c, a
	ld a, $0D
	sub a, c
	ld b, a
	ld de, $DAE0
	ld a, $C0
	ld [de], a
	dec d
	ld a, $FF
.wipeloop1
	ld [de], a
	dec d
	dec b
	jr nz, .wipeloop1
	ld hl, BriefBubbleGFX ; first tile
	call .copy1bpptile
	ld a, [$CB1B]
	sub $10
	jr z, .skip2
	ld l, e
	ld h, d
.loop2
	set 7, [hl]
	inc l
	dec a
	jr nz, .loop2
	ld e, l
	ld d, h
.skip2
	ld hl, BriefBubbleGFX + $10 ;second tile
	call .copy1bpptile
	dec e
	inc d
	ld a, $12
	sub a, c
	ld b, a
	ld a, $FF
.wipeloop2
	ld [de], a
	inc d
	dec b
	jr nz, .wipeloop2
	ret
	
.copy1bpptile ;625F
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
	ret
	
BriefBorderGFX: ;0x6278
INCBIN "build/gfx/BriefBox.2bpp"
;62E8
INCBIN "build/gfx/BriefSpeechPoint.2bpp"
BriefBubbleGFX: ;6308
INCBIN "build/gfx/BriefBubble.1bpp"

DrawBriefSpeechPage: ;6328
	push bc
	push hl
	call CallLoadBriefBubbleGFX
	pop hl
	pop bc
	push hl
	call CallDrawTitleLetters
	call CallBriefDrawSpeech
	pop hl
	ld a, $50
	ldh [$FFF3], a
	ld a, $7F
	ldh [$FFF1], a
	xor a
	ldh [$FFEF], a
	ld a, $40
	ldh [$FFED], a
	ld a, $20
	ld [$C2BC], a
	ld [$C2BD], a
	ld a, $27
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
	ld a, $02
	ldh [$FFDC], a
	ld a, $1E
	ldh [$FFDB], a
.loop
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld d, a
	and $08 ;mask start
	cp $08
	ccf
	ret c ;return if start pressed
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
	ld a, $04
	call CallDrawModel
	call CallBriefDrawCommander
	pop hl
	call GetSimpleByteFromBank5
	inc hl
	ld a, c
	ld [$C2A1], a
	ld c, a
	bit 0, a
	jr z, .skipload2
	ld a, $07
	ld [$C110], a
.skipload2
	ld a, c
	or a
	jr nz, .loop
	xor a
	ret

UpdateBriefScreenModels: ;63B7
	ld a, $50
	ldh [$FFF3], a
	ld a, $7F
	ldh [$FFF1], a
	xor a
	ldh [$FFEF], a
	ld a, $40
	ldh [$FFED], a
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ldh [$FFA3], a
	ld a, $02
	ldh [$FFDC], a
	ld a, $1E
	ldh [$FFDB], a
	ld a, $20
	ld [$C2BC], a
	ld [$C2BD], a
	ld a, $27
	ldh [$FF9E], a
	cp $80
	ld a, $00
	adc a, $FF
	ldh [$FF9F], a
	xor a
	ldh [$FFA3], a
	ld a, [wUpdateCounter]
	push af ;save spot
	xor a
	ld [wUpdateCounter], a ;start at beginning of animations?
.loop
	ld a, [$CB1D]
	cp $70
	jr c, .done
	sub $04
	ld [$CB1D], a
	ldh [$FFA1], a
	xor a
	ld [$C33E], a
	ld a, $04
	call CallDrawModel
	call CallBriefDrawCommander
	jr .loop
.done
	pop af
	ld [wUpdateCounter], a ;restore spot
	ret

BriefCommanderIntro: ;641D
	ld a, $50
	ldh [$FFF3], a
	ld a, $7F
	ldh [$FFF1], a
	xor a
	ldh [$FFEF], a
	ld a, $40
	ldh [$FFED], a
	ld a, $20
	ld [$C2BC], a
	ld [$C2BD], a
	ld a, $27
	ldh [$FF9E], a
	cp $80
	ld a, $00
	adc a, $FF
	ldh [$FF9F], a
	ld a, $80
	ld [$CB1D], a
	xor a
	ldh [$FFDB], a
	ld a, $0F
	ldh [$FFDC], a
	ld a, $60
	ldh [$FFA3], a
.loop
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	and $08 ;start
	cp $08
	ccf
	ret c ;return if start pressed
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ldh a, [$FFA3]
	add a, $08
	ldh [$FFA3], a
	ld hl, $FFDB ;pointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $28
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;go back $28
	ld a, l
	sub $1E
	ld a, h
	sbc a, $02
	jr nc, .skeep
	ldh a, [$FFA3]
	cp $08
	ret z ;if done with intro
	jr .dontsave
.skeep
	ld a, l
	ldh [$FFDB], a
	ld a, h
	ldh [$FFDC], a
.dontsave
	ld a, $80
	ldh [$FFA1], a
	xor a
	ld [$C33E], a
	ld a, $04
	call CallDrawModel
	call CallBriefDrawCommander
	jr .loop
	xor a
	ret

BriefDrawScreen: ;64AB
	ld hl, $9260
	ld de, wMonoBufferColumn1
	ld b, $0A
	inc l
.outerloop
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
	cp $48
	jr c, .innerloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .outerloop
	ret

BriefDrawSpeech: ;64F2
	ld hl, $89D0 ;start of text bubble
	ld de, $CCE0
	ld b, $14
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
	jr nz, .innerloop
	ld e, $E0
	inc d
	pop bc
	dec b
	jr nz, .loop
	ret

BriefDrawCommander: ;6536
	ld hl, $8F60 ;top corner of commander during briefings
	ld de, $DA00 ;source
	ld b, $06
	inc l
.copyloop
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
	ld e, a ;load four bytes into CBED
.sl1
	ldh a, [rSTAT]
	and $02
	jr nz, .sl1
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
	inc l ;write the four bytes
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
	cp $40
	jr c, .innerloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .copyloop
	ret
	
SetUpBriefing: ;657D
	ld hl, $8000
	ld bc, $1800 ;all of tiledata
.wipetiledataloop
	xor a
	ld [hl+], a
	dec bc
	ld a, c
	or b
	jr nz, .wipetiledataloop
	ld hl, $9800
	ld bc, $0400 ;all of tilemap
.resettilesloop
	ld a, $80
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .resettilesloop
	ld hl, $9841
	ld a, $26
	ld c, $09 ;height
.setscreenrow
	ld b, $0A ;width
.setscreenloop
	ld [hl+], a
	add a, $09
	dec b
	jr nz, .setscreenloop
	sub $59
	ld e, a
	ld a, l
	add a, $16
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	dec c
	jr nz, .setscreenrow
	ld hl, $986D
	ld a, $F6
	ld c, $08
.setcommanderrow
	ld b, $06
.setcommanderloop
	ld [hl+], a
	add a, $08
	dec b
	jr nz, .setcommanderloop
	sub $2F
	ld e, a
	ld a, l
	add a, $1A
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	dec c
	jr nz, .setcommanderrow
	ld hl, $99A0
	ld a, $9D
	ld c, $04
.setspeechrow
	ld b, $14
.setspeechloop
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .setspeechloop
	sub $4F
	ld e, a
	ld a, l
	add a, $0C
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	dec c
	jr nz, .setspeechrow
	ld hl, BriefBorderGFX
	ld de, $8ED0 ;border gfx
	ld b, BriefBubbleGFX - BriefBorderGFX
.bordercopyloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .bordercopyloop
	ld hl, $9820
	ld a, $ED ;tl corner
	ld [hl+], a
	ld b, $0A
	inc a
.toplineloop
	ld [hl+], a
	dec b
	jr nz, .toplineloop
	inc a ;tr corner
	ld [hl+], a
	ld hl, $9840
	inc a
	ld c, a
	ld b, $09
.leftlineloop
	ld [hl], c
	ld a, l
	add a, $20
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jr nz, .leftlineloop
	inc c ;bl corner
	ld a, c
	ld [hl+], a
	inc a 
	ld b, $0A
.bottomlineloop
	ld [hl+], a
	dec b
	jr nz, .bottomlineloop
	inc a ;br corner
	ld [hl], a
	sub $03
	ld c, a
	ld b, $09
.rightlineloop
	ld a, l
	sub $20
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	ld [hl], c
	dec b
	jr nz, .rightlineloop
	ld hl, $9260
	ld b, $B4
	ld a, $FF
.wipescreenloop
	ld [hl+], a
	inc l
	ld [hl+], a
	inc l
	ld [hl+], a
	inc l
	ld [hl+], a
	inc hl
	dec b
	jr nz, .wipescreenloop
	ret
	
EntityLogicLittleMan: ;6652
	ld a, [$CB13]
	inc a
	ld [$CB13], a
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;HP
	ld a, $FF
	ld [de], a ;store
	ld a, [wCrosshairTargetEntityLo]
	cp l
	ret nz
	ld a, [wCrosshairTargetEntityHi]
	cp h
	ret nz ;return if crosshair not over me
	ld a, [$C2AD]
	or a
	ret z ;return if none left
	ldh a, [$FFDC]
	cp $01
	ret nc
	call CallCleanUpPickupItem
	xor a
	ld [wCollisionType], a ;no collisions here
	ld a, $FF
	ldh [hGameState], a ;state -1
	ld hl, wReticleOAMData
	ld b, $04
	xor a
.wipeReticle
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jp nz, .wipeReticle
	ld a, [wHasCargo]
	or a
	jp z, .noCargo ;if empty, jump!
	call GetFreeEntity
	jp c, .pickUp ;if no space, skip
	ld a, $11 ;little man (this ent)
	ld [hl+], a
	ld a, spdSTOP
	ldh [hSpeedTier], a
	ld bc, $6400 ;distance
	push hl
	call CallPlaceEntityAhead ;if full, place man far ahead
	pop hl
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	xor a
	ld [de], a ;wipe map ID
	ld a, [wHasCargo]
	bit 0, a ;check if imposter onboard
	jr z, .pickUp ;if not, jump
	ld a, l ;else, we eject the imposter
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;entity logic
	ld a, LOW(CallEntityLogicSpiderTransform)
	ld [hl+], a
	ld a, HIGH(CallEntityLogicSpiderTransform)
	ld [hl+], a 
.pickUp ;66CC, E
	ld a, [wHasCargo]
	xor $03
	ld [wHasCargo], a
	call LoadScientistBuffers
	ld hl, BriefImposterGFX
	ld a, [wHasCargo]
	bit 0, a
	jr nz, .loadBuffer
	ld hl, BriefScientistGFX
.loadBuffer ;3
	ld de, wMonoBufferColumn1 + 16
	call CallLoadBriefImageToBuffer
	ld de, ImposterScientistTextBufferGFX
	ld hl, wMonoBufferColumn1
	ld c, $10
.pageloop ;66F2
	ld b, $2C ;how many words to process per page
.copyloop ;66F4
	ld a, [de] ;take our data
	or [hl]
	ld [hl+], a ;overlay it onto the buffer
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a ;do it again
	inc de
	dec b
	jp nz, .copyloop
	inc h
	ld l, $00
	dec c
	jp nz, .pageloop
	call HandleScientistConversation
	ld hl, ScientistOnboardText1
	ld c, $19
	call CallTryWriteScreenText
	ld hl, ScientistOnboardText2
	ld c, $19
	call CallTryWriteScreenText
	jp .end
.noCargo ;671D, no cargo
	call NextRand
	and $01
	inc a ;1 or 2
	adc a, $00 ;2 or 3?
	ld [wHasCargo], a
	call LoadScientistBuffers
.end
	ld a, $01
	ldh [hGameState], a
	ld a, TRACK_LEVEL_STATE
	ld [wQueueMusic], a
	ret
	
LoadScientistBuffers: ;6735
	call CallCopyWRAMToVRAM
	ld a, [wHasCargo]
	ld hl, BriefImposterGFX
	cp CARGO_SCIENTIST
	jr nz, .imagebuffer
	ld hl, BriefScientistGFX
.imagebuffer
	ld de, wMonoBufferColumn1
	call CallLoadBriefImageToBuffer
	ld a, $60
	ld [wTextBubbleX], a
	ld c, a
	ld b, $58
	ld a, [wHasCargo]
	dec a
	ld hl, ImposterDialogueText
	jr z, .text
	ld hl, ScientistDialogueText1
.text
	call CallDrawTitleLetters
	ld a, [wHasCargo]
	cp CARGO_SCIENTIST
	jr nz, .invertWRAM
	ld a, $21
	ld [wTextBubbleX], a
	ld c, a
	ld a, $6B
	ld b, a
	ld hl, ScientistDialogueText2
	call CallDrawTitleLetters
.invertWRAM
	ld hl, wMonoBufferColumn1
	ld b, $10
.outerloop
	ld c, $58
.innerloop
	ld a, [hl]
	cpl
	ld [hl+], a ;invert?
	dec c
	jr nz, .innerloop
	xor a
	ld l, a
	inc h ;next page
	dec b
	jr nz, .outerloop
	call CallCopyWRAMToVRAM
	ld a, [wHasCargo]
	ld hl, BriefImposterGFX
	cp $02
	jr nz, .imagebuffer2
	ld hl, BriefScientistGFX
.imagebuffer2
	ld de, wMonoBufferColumn1
	call CallLoadBriefImageToBuffer
	ld a, $60
	ld [wTextBubbleX], a
	ld c, a
	ld b, $58
	ld a, [wHasCargo]
	dec a
	ld hl, ImposterDialogueText
	jr z, .text2
	ld hl, ScientistDialogueText1
.text2
	call CallDrawTitleLetters
	ld a, [wHasCargo]
	cp CARGO_SCIENTIST
	jr nz, .go 
	ld a, $21
	ld [wTextBubbleX], a
	ld c, a
	ld a, $6B
	ld b, a
	ld hl, ScientistDialogueText2
	call CallDrawTitleLetters
.go
	call HandleScientistConversation
	ret
	
HandleScientistConversation: ;67D2
	ld hl, wMonoBufferColumn1
	ld b, $10
.outercopyloop ;F2
	ld c, $58
.innercopyloop ;FA
	ld a, [hl]
	cpl
	ld [hl+], a
	dec c
	jr nz, .innercopyloop
	xor a
	ld l, a
	inc h
	dec b
	jr nz, .outercopyloop
	call CallCopyWRAMToVRAM
	ld a, [wHasCargo]
	bit 0, a
	jr nz, .imposterMusic
	ld a, $19
	ld [$C2E9], a
	ld a, $01
	ld [$C2EA], a
	ld a, TRACK_SCIENTIST
	ld [wQueueMusic], a
	jr .start 
.imposterMusic ;11, imposter
	ld a, TRACK_IMPOSTER
	ld [wQueueMusic], a
.start ;5
	loadpalette 0, 0, 2, 3
	ldh [hBGP], a
	ldh [rBGP], a
	call CallRefreshBGTiles
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	call CallRefreshBGTiles
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	call CallRefreshBGTiles
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	call CallRefreshBGTiles
	ldh a, [rLCDC]
	res rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	ld d, $78
	call WaitFrames
.inputwait
	call WaitForVBlank
	call UpdateInputs
	ld a, [wCurrentInput]
	ld c, a
	ld a, [wChangedInputs]
	and c
	and $0A
	jr z, .inputwait
	ldh a, [rLCDC]
	set rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	ret
	
EntityLogicNuclearSilo: ;6850
	ld a, [$CB0F]
	inc a
	ld [$CB0F], a
	ld a, [wGameOverTimer]
	or a
	jp z, .notDead
	ld a, [wCurLevel]
	rrca
	rrca
	cp $03
	jr z, .destroy ;level 3, do nothing
	cp $06
	jr z, .destroy ;level 6, do nothing
	cp $05
	jr z, .destroy ;level 5, do nothing
	jr .notDead
.destroy ;A, 6, 2
	ld a, $FF
	call CallDamageEntity
	ret
.notDead ;6877, 6
	ld a, [wCurLevel]
	and $FC ;mask to valid shifted level values?
	jr z, .main ;if level 1, skip
	ld c, a ;backup level to C
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;de points to z orientation
	ld a, c
	ld c, $08
	cp LEVEL_FIVE
	jr nz, .incementOrientaion ;if not level five, use amt 8
	ld c, $14 ;on level 5, use #14
.incementOrientaion ;2
	ld a, [de]
	add a, c
	ld [de], a
.main ;15
	push hl ;backup pointer
	ld e, l
	ld d, h
	ld a, e
	add a, $0B
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;HP value
	ld a, $FE
	ld [de], a ;set it really high!
	ld e, l
	ld d, h
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	or a
	jr z, .checkEntry ;if zero, skip ahead
	ld c, a
	inc a
	cp $40
	jr nc, .getOrientation
	ld [de], a ;otherwise increment until $40
.getOrientation ;1
	srl c
	srl c
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;y orienation
	ld a, [hl]
	add a, c
	ld [hl], a ;add shifted speed to y orientation
.checkEntry ;16
	ld a, [wEntityCollided]
	or a
	jr z, .return ;if no collision, we're done here
	ld a, $02
	ld [wCollisionType], a ;scenery collision
	ld a, [wLurchTarget]
	bit 7, a
	jr nz, .return ;if bouncing off, we're done here
	ld e, $00
	ld a, [wViewDir]
	ld d, a
	sub a, e
	add a, $20
	sub $40
	ld e, a
	cp $40
	jr nc, .return ;make sure we're looking in the right range
	ld a, $64
	ld [$C272], a
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .checkCrystal
	and $FC
	jp nz, .level6 ;in not level one, jump
.checkCrystal ;5
	ld a, [wHasCargo]
	dec a
	jr nz, .noCrystal ;didn't have crystal
	call CallSiloDepositCrystal
	pop hl
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;pointer to speed
	inc [hl] ;increment it!
	call ClearAllScreenText
	ld hl, NuclearSiloMovingText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, NuclearSiloMovingText2
	ld c, $32
	call CallTryWriteScreenText
	call CallRestoreGUIAndMusic
	call CallTriggerMissionComplete
	ret
.noCrystal ;27
	call CallDoSiloInteriorText
	call CallRestoreGUIAndMusic
.return ;60, 54, 44
	pop hl
	ret
	
.level6 ;692D
	rrca
	rrca
	cp $06
	jr nz, .level3
	call CallHandleSiloInterior
	call CallRestoreGUIAndMusic
	ld a, [$C2C2]
	cp $04
	jr c, .needRods
	ld hl, ReactorRodsReturnedText
	ld c, $32
	call CallTryWriteScreenText
	ld hl, SiloSavedText
	ld c, $32
	call CallTryWriteScreenText
	call CallTriggerMissionComplete
	pop hl
	ret
.needRods ;15
	ld hl, HaventCollectedRodText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, HaventCollectedRodText2
	ld c, $32
	call CallTryWriteScreenText
	pop hl
	ret
.level3 ;34
	cp $03
	jr nz, .otherLevels
	call CallHandleSiloInterior
	ld a, [wHasCargo]
	or a
	jr z, .emptyCargo
	cp $02
	jr c, .crystalCargo
	call CallSetupSiloGraphics
	ld hl, HelpScientistTest
	ld c, $32
	call CallTryWriteScreenText
	ld hl, NuclearSiloSafeText
	ld c, $32
	call CallTryWriteScreenText
	call CallRestoreGUIAndMusic
	call CallTriggerMissionComplete
	pop hl
	ret
.crystalCargo ;1B
	call CallSiloHasCrystalSetup
	call CallRestoreGUIAndMusic
	pop hl
	ret
.emptyCargo ;27
	ld hl, FindScientistText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, FindScientistText2
	ld c, $32
	call CallTryWriteScreenText
	call CallRestoreGUIAndMusic
	pop hl
	ret
.otherLevels ;45
	call CallHandleSiloInterior
	call CallRestoreGUIAndMusic
	pop hl
	ret

EntityLogicToughEnemy: ;69B8
	ld a, [wEntsEnemyCount]
	inc a
	ld [wEntsEnemyCount], a
	ld e, l
	ld d, h ;packup pointer to DE
	ld a, e
	add a, $04
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;z position
	ld a, [hl+]
	ld c, a
	ld b, [hl] ;load it into BC
	ld a, e
	add a, $14
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;final byte of status words
	ld a, [hl]
	sub $20
	cp $40
	jr c, .setbyte
	ldh a, [hZPosLow]
	add a, c
	ldh a, [hZPosHi]
	adc a, b ;add this to backup Z
	cp $80
	jp nc, .inc
	dec [hl]
	jp .setbyte
.inc ;69EA
	inc [hl]
.setbyte ;69EB
	;L was increased or decreased based on Z
	ld l, [hl]
	ld a, l
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;value extended to HL
	add hl, bc ;and added to Z
	ld c, l
	ld b, h ;save Z
	ld a, e
	add a, $11
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;HL is third status word
	ld a, [hl]
	ld l, a
	ld h, $00
	ld a, c
	add a, l
	ld a, b
	adc a, h ;check sign of Z + status byte
	cp $80
	jr nc, .turn
	xor a
	sub a, l
	ld c, a
	ld a, $00
	sbc a, h
	ld b, a ;do Z - status byte instead i guess
.turn ;7
	ld a, e
	add a, $04
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;Z pos
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a ;save new Z pos
	ld l, e
	ld h, d
	call CallTurnEntTowardsPlayer
	push hl
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;shot status byte in DE?
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;first status word in HL
	ld a, [de]
	bit 0, a
	jr z, .move
	res 0, a ;if shot,
	ld [de], a
	inc hl
	ld a, [hl-]
	add a, [hl]
	ld [hl], a ;speed us up!
.move ;7
	ld a, [hl]
	add a, $28 ;base speed
	ld b, a
	pop hl
	ld c, $00
	call CallMoveEntityForward
	ld a, [$C2B8] ;?
	or a
	ret z
	call NextRand
	and $0F
	ret nz
	ld e, l ;1 in 15 chance
	ld d, h ;backup pointer to DE
	ld a, e
	add a, $0F
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;second status word, first byte
	ld a, [de]
	or a
	ret nz ;if byte nonzero, skip
	ld a, [wCurLevel]
	cp LEVEL_FOUR
	ret c ;if level 1, 2, or 3, return
	jp CallEntityShootDoubleShot
	
IF UNUSED == 1
SeekNDestroyRadars: ;6A6B
	push hl
	ld a, [$C2C8] ;bases left/mothership?
	or a
	jp z, .notarget
	ld c, a ;base count into C
	ld a, l
	dec a ;minus one
	and $0F ;only bottom four bits
.subloop
	sub a, c
	jr nc, .subloop
	add a, c ;L % bases
	ld c, a
	inc c ;save result into C
	ld e, l
	ld d, h ;backup HL into DE
	ld hl, wEntityTable
.radarfindloop
	push bc
	push de
	ld a, $03 ;radar base
	call CallFindEntityWithModel
	pop de
	pop bc
	jr c, .notarget ;jump if no more found
	dec c
	jr nz, .radarfindloop
	inc hl
	push hl ;save pointer
	call CallGetAngleBetweenEnts
	sub $80
	ld c, a
	ld a, l
	add a, $07 ;z spin
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, c
	sub a, [hl] ;turn towards it
	add a, $08
	cp $10
	jr c, .doneturn
	sub $08
	cp $90
	jr c, .right
	cp $70
	jr nc, .left
	ld a, [hl]
	sub $80
	ld [hl], a
	jr .doneturn
.right ;A
	ld a, [hl]
	add a, $01
	ld [hl], a
	jr .doneturn
.left ;C
	ld a, [hl]
	sub $01
	ld [hl], a
.doneturn ;1A, A, 4
	pop de
	pop hl
	ld bc, $1E00
	call CallMoveEntityForward
	call CallTestEntityHasCollisions
	ret nc
	dec hl
	ld a, [hl+]
	cp $03 ;did we collide with radar base?
	jr nz, .done ;no, do nothing
	push de
	push hl
	ld c, $19
	call CallFlashEntityCell ;otherwise flash cell
	pop hl
	ld a, $FF
	call CallDamageEntity ;destroy this
	pop hl
	ld a, $FF
	call CallDamageEntity ;destroy base
.done
	ret
.notarget ;6AE9, 5B
	pop hl
	ld bc, $1E00 ;just keep movin'
	call CallMoveEntityForward
	ret
ENDC

EntityLogicWarehouse: ;6AF1
	ld a, [$CAFA]
	inc a
	ld [$CAFA], a
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;health
	ld a, $FF
	ld [de], a ;max it out
	push hl
	ld a, [$C2B8]
	or a
	jr z, .checkCargo
	ld a, [wUpdateCounter]
	add a, $04
	and $0F
	cp $08
	jr c, .checkCargo
	call NextRand
	or a
	jr nz, .checkCargo
	push hl
	ld a, $02 ;tank
	call GetMatchingEntitySlots
	pop hl
	cp $03
	jr nc, .checkCargo ;if less than 4
	ld a, $02
	call CallEntityDropNewEntity ;spawn a new tank
.checkCargo ;21, 16, 10, 5
	pop hl
	ld a, [wHasCargo]
	bit 7, a ;check top bit
	jr z, .checkTimerOut ;if not set, jump
	res 7, a ;else reset it
	ld c, a ;save to C
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;de is speed
	ld a, [de]
	cp c ;compare to cargo value
	jr nz, .checkTimerOut
	ld a, $FF
	push hl
	call CallDamageEntity
	pop hl
	call CallDamageEntity
	ld a, $02
	ld [wFlash3DWindow], a
	xor a
	ld [wHasCargo], a ;clear cargo
	ret
.checkTimerOut ;23, 14
	ld a, [wTimerEnableFlag]
	or a
	jr z, .checkCountdown
	ld a, [wTimerFramesLo]
	ld c, a
	ld a, [wTimerFramesHi]
	or c
	jr nz, .checkCountdown
	ld a, l ;if timer is zero,
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	ld c, a
	ld a, [wHasCargo]
	cp c
	jr nz, .checkCountdown ;if cargo doesn't match, skip
	ld a, $FF
	push hl
	call CallDamageEntity
	pop hl
	call CallDamageEntity
	ld a, $02
	ld [wFlash3DWindow], a
	xor a
	ld [wTimerEnableFlag], a
	ld a, [wHasCargo]
	set 7, a
	ld [wHasCargo], a
	xor a
	ld [wTunnelBombSet], a
	ret
.checkCountdown ;3A, 30, 20
	ld a, [wTimerEnableFlag]
	or a
	jp nz, .ret ;jump if timer still running
	ld a, [wEntityCollided]
	or a
	jp z, .ret ;if not collided, jump
	ld a, [wUpdateCounter]
	add a, $04
	and $0F
	cp $08
	jp c, .ret
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	ld [wHasCargo], a ;load cargo from entity?
	ld a, $02 ;scenery
	ld [wCollisionType], a
	ld a, [wLurchTarget]
	bit 7, a
	jp nz, .ret ;if recoiling, jump
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;y orientation
	ld a, [de]
	ld e, a
	ld a, [wViewDir]
	ld d, a
	sub a, e
	add a, $18
	sub $80
	ld e, a
	cp $30
	jp nc, .ret ;if not within range, jump
	ld a, $09 ;base enter
	ld [wQueueNoise], a
	push hl
	ld a, [wHasCargo]
	ld [$C2DB], a
	ld hl, $42BA ;in bank 9
	cp $01
	jr nz, .doTunnel
	ld hl, $475F ;in bank 9
.doTunnel
	call LoadTunnel
	xor a
	ld [$C2DB], a
	pop hl
	ld a, [hl+]
	ldh [hXLoCopy], a
	ldh [hXPosLow], a
	ld a, [hl+]
	add a, $80
	ldh [hXHiCopy], a
	ldh [hXPosHi], a
	ld a, [hl+]
	ldh [hYLoCopy], a
	ldh [hYPosLow], a
	ld a, [hl+]
	add a, $80
	ldh [hYHiCopy], a
	ldh [hYPosHi], a
	inc hl
	inc hl
	inc hl
	ld a, [hl+]
	ldh [hViewAngle], a
	ld [wViewDir], a
	xor a
	ld [wFlightPitch], a
	ld a, $14
	ldh [hZPosLow], a
	xor a
	ldh [hZPosHi], a
	ld a, $01
	ld [wHideEntities], a
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.despawnLoop ;6C36
	ld a, [hl+]
	or a
	jr z, .nextent
	bit 7, a
	jr nz, .nextent
	push bc
	call CallCheckDeloadEntity
	pop bc
.nextent ;9, 5
	ld a, l
	add a, ENTITY_SIZE-1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .despawnLoop
	call CallIterateOverMapObjects
	xor a
	ld [wHideEntities], a
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
	ld a, $78
	ld [wLurchCounter], a
	call CallBumpedRecoil
	ld a, $78
	ld [wLurchCounter], a
	call CallBumpedRecoil
	ld a, $78
	ld [wLurchCounter], a
	call CallRestoreGUIAndMusic
.ret ;6C85
	ret

DamageEntity: ;6C86
	push bc
	push af
	ld c, a
	ld b, $00 ;C is a table value, 1 or 0
	ld a, [$CAEA] ;? some sort of modifyer
	or a
	jr z, .dodamage 
	ld b, c ;b is also table value
	dec a ;a is now one less than b and c, make up for the add later
	jr nz, .nosrl
	srl c ;what does this do??
.nosrl ;2
	add a, b
	ld b, a ;b is double a now
.dodamage ;8
	pop af
	add a, b ;a is either passed a, or three times a, based on CAEA
	pop bc
	dec hl
	bit 7, [hl] ;if model is hidden, return
	ret nz
	ld e, a ;damage value now in E
	ld c, l
	ld b, h ;BC is the pointer to model?
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;increment pointer by D, to unknown byte
	set 0, [hl] ;set a bit?
	dec hl
	ld a, [hl]
	sub a, e ;damage entity!
	ld [hl], a ;last one here minus our table?
	jr nc, .hitsound ;to 6CFB
	;else, we killed it!
	ld l, c
	ld h, b ;else load model
	ld a, [hl+] ;into a
	cp $03 ;radar base?
	jr nz, .destroyentity ;if not 3, jump ahead
	push bc
	call CallGetEntityArea
	add a, LOW(wRadarBasesTable)
	ld c, a
	ld a, HIGH(wRadarBasesTable)
	adc a, $00
	ld b, a
	ld a, [bc]
	set 7, a
	ld [bc], a ;flag the base as destroyed
	pop bc
.destroyentity ;11
	push hl
	call CallHandleEntityDrop ;don't need farcall here?
	pop hl
	call CallDestroyEntityObject ;explodes, sets flag
	dec hl
	ld a, [hl]
	and $7F
	push hl ;save model position, model ID is in A
	call IncrementKills
	pop hl
	inc hl
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;BC is X
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;DE is Z
	ld a, [hl+]
	cpl
	add a, $01
	ldh [$FFCF], a
	ld a, [hl+]
	cpl
	adc a, $00
	ldh [$FFD0], a ;FFCF/FFD0 hold Y?
	call CallGenerateDebris
	ld a, $02
	ld [wQueueNoise], a
	scf
	ret
.hitsound ;6CFB
	ld a, e ;check our table value
	or a
	jr nz, .damaged
	ld a, $10 ;ting!
	ld [wQueueSFX], a
	and a
	ret
.damaged ;7
	ld a, $03 ;ow!
	ld [wQueueNoise], a
	and a
	ret
	
EntityLogicSpiderTransform: ;6D0D
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	inc a
	ld [de], a ;increase speed
	cp $07
	ret c ;if less than seven, jump
	ld a, l
	add a, $09
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to entity logic pointer
	ld a, LOW(CallGenericEnemyLogic)
	ld [de], a
	inc de
	ld a, HIGH(CallGenericEnemyLogic)
	ld [de], a
	dec hl ;model ID
	ld a, $3A ;turn it into a spider
	ld [hl], a
	ret
	

DrawBomb: ;6D2F
	ld a, [$C2DD]
	or a
	jr z, .ret
	dec a
	ld [$C2DD], a
	rlca
	rlca ;times four
	add a, $62
	ld l, a
	ld a, $6D
	adc a, $00
	ld h, a ;hl = 6D62 + value
	xor a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ldh [$FFA3], a
	ldh [$FFA1], a
	ld a, [hl+]
	ldh [$FFDD], a
	ld a, [hl+]
	ldh [$FFDE], a
	ld a, [hl+]
	ldh [$FFDB], a
	ld a, [hl+]
	ldh [$FFDC], a
	ld a, $09 ;diamond?
	call CallDrawModel
.ret
	ret
	
;6D62, table?
db $90, $01, $32, $00 
db $40, $01, $32, $00 
db $04, $01, $32, $00 
db $C8, $00, $28, $00 
db $A0, $00, $28, $00 
db $64, $00, $28, $00 
db $3C, $00, $28, $00 
db $1E, $00, $1E, $00 
db $0A, $00, $14, $00 
db $00, $00, $0A, $00

IF UNUSED == 1
ChackGameOver: ;6D8A
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, [wLevelClearCountdown]
	or a
	ret nz
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	ld a, $19
	ld [wGameOverTimer], a
	ret
ENDC

SetLevelTitle: ;6D9F
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr nz, .nottut
	ret ;return if in the tutorial
;6DA7, unused?
	ld hl, MissionTrainingText
	jr .loaded
.nottut
	cp LEVEL_ESCAPE
	ret nc ;return if in the escape
	rrca ;word offset
	add a, LOW(.MissionTitleTable)
	ld l, a
	ld a, HIGH(.MissionTitleTable)
	adc a, $00
	ld h, a ;table at $6DC3
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load pointer into HL
.loaded
	ld c, $19 ;and C to 19
	call CallTryWriteScreenText
	jp .ret
.MissionTitleTable ;6DC3
	dw MissionOneText
	dw MissionTwoText  
	dw MissionThreeText  
	dw MissionFourText  
	dw MissionFiveText 
	dw MissionSixText 
	dw MissionSevenText 
	dw MissionEightText 
	dw MissionNineText 
	dw MissionTenText
.ret
	ret
	
EntityPlayShootShound: ;6DD8
	ld c, a ;0D
	push bc ;save it
	push de ;explode sound pointer
	call CallGetDistanceFromPlayer
	pop de
	pop bc
	ret c ;return if y < x
	cp $20
	ret nc ;return if too far; distance is now 0 - $1F
	srl a
	srl a
	srl a ;now 0 - 4
	cpl
	and $03 ;invert those bits
	add a, c
	ld [de], a ;and play the sound
	ret

GenericEnemyLogic: ;6DF0
	ld a, [$CAFB] ;tank count
	inc a
	ld [$CAFB], a
	ld a, $00
	or a
	jr z, .tankturn
;all this is unused behaviour???
	push hl
	ld e, l
	ld d, h
	ld a, e
	add a, $0C
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;shot status bit
	ld a, [de]
	bit 0, a
	jr z, .notset
	call CallTurnEntTowardsPlayer ;if set, call this
	jr .zoom
.notset
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	call NextRand
	ld c, a
	and $1E
	jr nz, .zoom ;1 in 15 chance
	swap c
	ld a, c
	sub $10
	add a, [hl]
	ld [hl], a ;modify last status word??
.zoom
	pop hl
	ld bc, $5000 ;speed of 50
	call CallMoveEntityForward
	ret
	
.tankturn ;34, used code
	call CallTurnEntTowardsPlayer ;always call this
	push hl
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;shot status byte in DE
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;first status word in HL
	ld a, [de]
	bit 0, a
	jr z, .advance ;if not shot, skip
	res 0, a
	ld [de], a ;clear bit
	inc hl
	ld a, [hl-]
	add a, [hl]
	ld [hl], a ;first byte += second byte (this is the shot speedup???
.advance ;7
	ld a, [hl]
	add a, $1E
	ld b, a ;value + 1E into B (speed)
	pop hl
	ld c, $00
	call CallMoveEntityForward
	ld a, [$C2B8]
	or a
	ret z
	call NextRand
	and $0F
	ret nz ;1 in 16 chance
	ld e, l
	ld d, h
	ld a, e
	add a, $0F ;second status word
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	or a
	ret nz ;return if has value
	inc de ;second byte of second status word
	ld a, [de]
	add a, $51
	ld e, a
	ld d, $02
	push de ;save value + $251
	push hl 
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;X
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;Y
	pop hl
	push hl ;???
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	cpl
	add a, $01
	ldh [$FFCF], a
	ld a, [hl+]
	cpl
	adc a, $00
	ldh [$FFD0], a ;Z
	pop hl
	push hl ;save pos
	push de
	push bc ;save x and y
	ld de, wQueueNoise
	ld a, $0D ;drake sound
	call CallEntityPlayShootShound ;don't need the farcall?
	pop bc
	pop de
	pop hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, $20
	ld [wParticleAge], a
	ld a, [hl]
	cpl
	inc a
	pop hl
	jp GenerateParticle
	
EntityLogicReplenishAll: ;6EBC
	ld a, [wEntityCollided]
	or a
	jr z, .doneCollided
	xor a
	ld [wCollisionType], a
.doneCollided
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;map ID
	ld a, $FF
	ld [de], a ;set to FF
	call CallMoveBomb
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;y rotiation
	ld a, [de]
	add a, $09
	ld [de], a ;rotate it!
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, [wLevelClearCountdown]
	or a
	ret nz
	ld a, [wCrosshairTargetEntityLo]
	cp l
	ret nz
	ld a, [wCrosshairTargetEntityHi]
	cp h
	ret nz
	ld a, [$C2AD]
	or a
	ret z
	ldh a, [$FFDC]
	cp $01
	ret nc
	call CallCleanUpPickupItem
	ld a, $12
	ld [wQueueSFX], a
	ld a, MAX_HEALTH
	ld [wHealth], a
	ld a, $FF
	ld [wFuelAmountLo], a
	ld [wFuelAmountHi], a
	ld a, MISSILES_MAX
	ld [wMissileCount], a
	xor a
	ld [wCollisionType], a
	ret

DrawEntryArrow: ;6F1D
	ldh a, [hSpeedTier]
	cp $06
	jr z, .flying
	ld hl, EntryArrowGFX
	ld de, $D740 ;3dscreen coord
	ld b, $02
.outerloop
	ld c, $10
	push de
.innerloop
	ld a, [hl+]
	ld [de], a
	inc e
	dec c
	jp nz, .innerloop
	pop de
	inc d
	dec b
	jp nz, .outerloop
	ret
	
.flying ;6F3C, speed was 6
	ld hl, EntryArrowFlyingGFX
	ld de, $D610 ;3dscreen coord
	ld b, $04
.outerloop2
	ld c, $18
	push de
.innerloop2
	ld a, [hl+]
	ld [de], a
	inc e
	dec c
	jp nz, .innerloop2
	pop de
	inc d
	dec b
	jp nz, .outerloop2
	ret

EntryArrowFlyingGFX: ;6F55
INCBIN "build/gfx/EntryArrowFlying.1bpp"
;6FB5

SECTION "C:7255", ROMX[$7255], BANK[$C]
EntryArrowGFX: ;7255
INCBIN "build/gfx/EntryArrow.1bpp"

UpdateTimer: ;7275
	ld a, [wTimerEnableFlag]
	or a
	jr z, .ret
	ld hl, wTimerFrames
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is the timer framecount
	ld a, h
	or a
	jr nz, .zerobyte ;if high byte is nonzero, jump
	ld a, l
	or a
	jr z, .zerobyte ;if low byte is 0, jump
	cp 10
	jr c, .under10 ;if under 10, skip
.onesloop
	sub 10
	jr z, .under10 ;if ten, skip?
	jp nc, .onesloop
	jr .zerobyte
.under10
	ld a, [$C0AF] ;save file byte
	cp $2C ;training?
	jr z, .zerobyte
	ld a, $18 ;level start jingle?
	ld [$C100], a
.zerobyte
	ld hl, wTimerFrames
	ld a, [hl]
	sub 1
	ld [hl+], a
	jr nc, .nocarry
	dec hl
	ld a, 99
	ld [hl+], a
	scf
.nocarry
	ld a, [hl] ;high part
	sbc a, $00
	jr c, .outoftime
	ld [hl], a
	jr .ret
.outoftime
	xor a
	ld [hl-], a
	ld [hl], a
.ret
	ret
	
HandleFlightHeight: ;72BC
	xor a
	ld [wAJustPressed], a
	ld [wBJustPressed], a
	ld a, [wFlightPitch]
	add a, $80
	ld d, a ;D IS FLIGHT PITCH
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL IS Z POS
	ld a, [wFlyingFlag]
	or a
	jr z, .checkcounter
	ldh a, [hSpeedTier]
	cp spdTURBO
	jr z, .checkfuel
	xor a
	ld [wFlyingFlag], a
.checkfuel ;4
	ld a, [wCurrentInput]
	ld e, a ;E IS INPUT
	ld a, [wFuelAmountLo]
	ld c, a
	ld a, [wFuelAmountHi]
	or c
	jr z, .pitchdown ;if no fuel, stall
	bit INPUT_UP, e
	jr z, .setflying
	ld a, [wFlyingFlag]
	cp $80
	jr z, .pitchup
.pitchdown ;B
	ld a, d ;pitch
	cp $40
	jr c, .setflying
	sub $04
	ld d, a
	jr .pitchup
.setflying ;11, 5
	ld a, $01
	ld [wFlyingFlag], a
.pitchup ;F, 5
	bit INPUT_DOWN, e
	jr z, .checkpitch
	ld a, d
	cp $C0
	jr nc, .checkpitch
	add a, $04
	ld d, a
.checkpitch ;8, 3
	ld a, d ;load pitch
	sub $70
	cp $20
	jr nc, .pitchsign
	ld a, d ;load pitch
	cp $80
	jr z, .pitchsign
	jr nc, .minus1 ;if negative, jump?
	inc d
	inc d
.minus1 ;2
	dec d
.pitchsign ;A, 5
	ld a, d
	add a, $80
	cpl
	inc a
	bit 7, a ;sign
	jr nz, .getlurch
	sra a
	sra a
.getlurch ;4
	ld e, a
	ld a, [wLurchTarget]
	cp $70
	jr c, .setlurch
	cp $90
	jr c, .checkcounter
.setlurch ;4
	add a, e
	ld [wLurchTarget], a
.checkcounter ;6C, 4
	ld a, [wLurchCounter]
	sub $10
	cp $80
	jr nc, .lowcounter
	ld a, [wFlyingFlag]
	or a
	jr nz, .changeZ
.lowcounter ;6
	ld a, h
	or l
	jr z, .changeZ ;if Z pos is zero, jump
	ld a, d
	cp $40
	jr c, .changeZ
	sub $02 ;if at max height, pitch?
	ld d, a
.changeZ ;C, 8, 3
	ld a, d
	sub $80
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;pitch is now DE
	add hl, de ;add pitch to Z
	ld a, e
	sub $80
	ld d, a ;restore pitch to DE
	ld a, l
	cp $14
	ld a, h
	sbc a, $00
	cp $80
	jr c, .checkpos ;if not touched the ground, jump ahead
	xor a
	ld [wFlyingFlag], a ;else cancel flight
	ld hl, $0014 ;ground height
	ld a, d
	sub $80
	cpl
	inc a
	sra a
	add a, $80
	ld d, a ;invert pitch and divide by two
	dec a
	cp $80
	jr nz, .checksound
	ld d, a
.checksound ;1
	cp $80
	jr z, .checkpos
	ld a, $0B
	ld [wQueueSFX], a
.checkpos ;20, 5
	ld a, l
	cp $90
	ld a, h
	sbc a, $01
	jr c, .save
	ld hl, $0190 ;max Z height?
	ld a, d
	cp $40
	jr c, .save
	sub $02
	ld d, a
.save ;B, 3
	ld a, d ;pitch
	sub $80
	ld [wFlightPitch], a
	ld a, l
	ldh [hZPosLow], a
	ld a, h
	ldh [hZPosHi], a
	ret

PointToEntityEntry: ;73B6
	ld a, 0 - ENTITY_SIZE ;negative entity size?
	inc c ;force an increment to zero things out?
.loop
	add a, ENTITY_SIZE 
	dec c
	jp nz, .loop
	add a, LOW(wEntityTable)
	ld l, a
	ld a, HIGH(wEntityTable)
	adc a, $00
	ld h, a ;HL is CB53 + $19*c
	inc hl ;PLUS ONE
	ret
	
Briefing: ;73C9
	ld a, [$C0AF]
	cp $2C ;if training, return
	ret z
	call CallDisableLCD
	call CallBriefDrawCommander
	call CallBriefDrawSpeech
	call CallBriefDrawScreen
	call CallSetUpBriefing
	call ClearWRAM
	xor a ;clear carry flag, this loads the exit prompt graphics
	call CallHandleBriefExitPrompt
	xor a
	ldh [hGameState], a
	ld [wTargetSCY], a
	ldh [rSCY], a
	ldh [rSCX], a
	ld a, $FF
	ldh [rWX], a
	loadpalette 0, 3, 3, 0
	ldh [rBGP], a
	loadpalette 0, 0, 3, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ld a, $A3
	call CallFlashScreen
	ld a, [$C0AF]
	or a
	jr nz, .skip1
	ld a, $22
	ld [$C108], a ;if C0AF = 0, store $22
	jr .endb
.skip1
	cp $24
	jr nz, .skip2
	ld a, $1C
	ld [$C108], a ;if C0AF = 24, store $1C
	jr .endb
.skip2
	cp $28
	jr nz, .skip3
	ld a, $23
	ld [$C108], a ;if C0AF = 28, store $23
	jr .endb
.skip3
	ld a, $07
	ld [$C108], a ;else, store $07
.endb
	ld a, $80 ;7432
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFF0], a
	ldh [$FFEE], a
	ld [$CB1D], a
	ldh [$FFA1], a
	ld a, $D0
	ldh [$FF9B], a
	ld a, [$C0AF]
	or a
	call z, CallBriefCommanderIntro ;only happens in the first brief?
	ret c ;never happens?
	ld hl, $998E
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, $F4 ;speech bubble point tiles
	ld [hl+], a
	inc a
	ld [hl+], a
	ld a, [$C0AF] ;level?
	and %11111100 ;mask off bottom two bits
	rrca ;/divide by two
	add a, LOW(BriefingPointers)
	ld l, a ;store in L
	ld a, HIGH(BriefingPointers)
	adc a, $00
	ld h, a ;store $40 in H
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read pointer into HL
	call CallPlayBrief
	ret
	
EscapeSequence: ;746F
	ld a, $01
	ld [$C284], a
	ld a, LEVEL_ESCAPE
	ld [wCurLevel], a
	call CallBriefing
	call CallPrepareTunnelForLevel
	jp CallTriggerCredits
	
TriggerMissionComplete: ;7482
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, [wLevelClearCountdown]
	or a
	ret nz
	ld a, $FF
	ldh [hGameState], a
	call CallDrawHealthBar
	ld hl, MissionCompleteText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $3C
	ld [wLevelClearCountdown], a
	ld hl, wFrameCounter
	xor a
	ld [hl+], a
	ld [hl], a ;clear frames
	xor a
	ld [wTimerEnableFlag], a ;disable timer
	ld a, $08
	ldh [rSCX], a
	call CallDestroyAllHostiles
	ld a, $15 ;grats!
	ld [wQueueMusic], a
	ret

SetEkkusuOAM: ;74B7
	ld hl, $C000 ;base of wram
	ld a, $4D
	ld [hl+], a
	ld a, c
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a ;4D, c, 0, 0
	ld a, $4D
	ld [hl+], a
	ld a, c
	add a, $08
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	xor a
	ld [hl+], a ;4D, c+8, 1, 0
	ld a, $4D
	ld [hl+], a
	ld a, c
	add a, $10
	ld [hl+], a
	ld a, $02
	ld [hl+], a
	xor a
	ld [hl+], a ;4D, c+10, 2, 0
	ld a, $4D
	ld [hl+], a
	ld a, c
	add a, $18
	ld [hl+], a
	ld a, $03
	ld [hl+], a
	xor a
	ld [hl+], a ;4D, c+18, 3, 0
	ld a, $4D
	ld [hl+], a
	ld a, c
	add a, $20
	ld [hl+], a
	ld a, $04
	ld [hl+], a
	xor a
	ld [hl+], a ;4D, c+20, 4, 0
	ld a, c
	add a, $08
	ld b, a
	ld a, $04
.loop ;this happens four times
	push af
	ld a, $55
	ld [hl+], a
	ld a, b
	ld [hl+], a
	ld a, $05
	ld [hl+], a
	xor a
	ld [hl+], a ;55, b, 5, 0
	ld a, $45
	ld [hl+], a
	ld a, b
	ld [hl+], a
	ld a, $05
	ld [hl+], a
	ld a, $40
	ld [hl+], a ;45, b, 5, 40
	ld a, b
	add a, $08
	ld b, a
	pop af
	dec a
	jr nz, .loop
	ret

;7517 - 767E: unused training gameover tilemap
	db $14, $12 ;dimensions
	

SECTION "C:79A9", ROMX[$79A9], BANK[$C]
ImposterScientistTextBufferGFX:;79A9
	INCBIN "build/gfx/ScientistImposterTextBuffer.1bpp"

TunnelEntranceTable: ;7F29, tunnel table, pointers into bank 9?
	dw $49AF 
	dw $4AA6 
	dw $4B97 
	dw $4C84 
	dw $4D6D 
	dw $4E57 
	dw $4F41 
	dw $5074 
	dw $51A7
;7F3B
