SECTION "D:TOP", ROMX[$4000], BANK[$D]
EntityLogicButterfly: ;4000
	ld a, [$CB0D]
	inc a
	ld [$CB0D], a
	push hl
	ld a, [$C2C8] ;bases left?
	or a
	jp z, .moveForwardFast ;all destroyed!
	ld c, a
	ld a, [$CB0D]
	dec a
	and $0F ;how many butterflies
.assignBase ;subtract till we have a base number to assign
	sub a, c
	jr nc, .assignBase
	add a, c
	ld c, a
	inc c
	ld e, l
	ld d, h ;backup our entity pointer
	ld hl, wEntityTable
.getNextBase ;F2
	push bc
	push de
	ld a, $03 ;radar base
	call CallFindEntityWithModel
	pop de
	pop bc
	jr c, .moveForwardFast ;none left, jump to 4097
	dec c
	jr nz, .getNextBase ;if not our assigned one, get the next
	inc hl
	push hl
	call CallGetAngleBetweenEnts
	sub $80
	ld c, a
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to Z angle
	ld a, c
	sub a, [hl] ;get the angles' difference
	add a, $08
	cp $10
	jr c, .doneTurning ;skip if we overshot?
	sub $08
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft
	ld a, [hl]
	sub $80
	ld [hl], a
	jr .doneTurning 
.turnRight ;A
	ld a, [hl]
	add a, $01
	ld [hl], a
	jr .doneTurning
.turnLeft ;C
	ld a, [hl]
	sub $01
	ld [hl], a
.doneTurning ;1A, A, 4
	pop de
	pop hl
	push hl
	push hl
	push de
	call CallGetDistanceBetweenEnts
	pop de
	pop hl
	jp c, .moveForwardFast
	cp $08
	jp nc, .moveForwardFast
	call NextRand
	and $03 ;1 in 4 chance
	jr nz, .moveForwardSlow
	push de
	call CallButterflyShootLazer
	pop de
	ld l, e
	ld h, d
	ld a, $01
	call CallDamageEntity
.moveForwardSlow ;C
	pop hl
	ld bc, $3C00
	call CallMoveEntityForward
	push hl
	ld c, $19
	call CallFlashEntityCell
	pop hl
	jp .waveMotion
.moveForwardFast ;4097
	pop hl
	ld bc, $5000
	call CallMoveEntityForward
.waveMotion ;409E
	call CallMoveBomb
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	xor a
	ld [de], a ;wipe object ID?
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	add a, $C0
	inc de
	ld a, [de]
	adc a, $00 ;compare Y position to something
	cp $80
	jr c, .useTable1
	ld a, l
	add a, $0E
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de] ;speedup
	or a
	jr nz, .useTable2 ;if not zero, skip
	push hl
	push de
	push bc
	ld de, wQueueNoise
	ld a, $15
	call CallEntityPlayShootShound
	pop bc
	pop de
	pop hl
	ld a, $01
	ld [de], a ;set speedup to 1
.useTable2 ;11
	ld a, [wUpdateCounter]
	and $07
	rlca
	add a, LOW(ButterflyTable2)
	ld c, a
	ld a, HIGH(ButterflyTable2)
	adc a, $00
	ld b, a ;412B has 8 words?
	jr .applyTableValues
.useTable1 ;2D
	ld a, l
	add a, $0E
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speedup
	xor a
	ld [de], a ;clear it
	ld a, [wUpdateCounter]
	and $03
	rlca
	add a, LOW(ButterflyTable1)
	ld c, a
	ld a, HIGH(ButterflyTable1)
	adc a, $00
	ld b, a ;4123 has 4 words?
.applyTableValues ;18
	ld a, l
	add a, $08 ;y orientation?
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [bc]
	ld [de], a ;set orientation
	inc bc
	ld a, [bc]
	ld c, a ;load second byte into C
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	add a, c ;subtract
	add a, $20
	cp $40 ;if this would make it negative,
	ret nc ;leave
	sub $20
	ld [de], a ;else reduce its speed
	ret
	
ButterflyTable1: ;4123
	db $00, $F1 
	db $28, $F8 
	db $00, $FE 
	db $D8, $FA
ButterflyTable2: ;412B
	db $00, $FE 
	db $14, $FC 
	db $28, $FC 
	db $14, $00 
	db $00, $00 
	db $EC, $00 
	db $D8, $00 
	db $EC, $00
	
LoadBriefImageToBuffer: ;413B
	ld b, $0A
.loop
	ld c, $48
	ld a, e
	push af
.innerloop
	ld a, [hl+]
	cpl ;invert
	ld [de], a
	inc e
	dec c
	jr nz, .innerloop
	pop af
	ld e, a
	inc d
	dec b
	jr nz, .loop
	ret

CopyBriefImage: ;414F
	ldh a, [rSTAT]
	and $02
	jr nz, CopyBriefImage
	ld a, [hl+]
	cpl
	ld [de], a ;write inverted?
	inc e
	inc de
	dec bc
	ld a, b
	or c
	jp nz, CopyBriefImage
	ret
	
DrawStars: ;4161
	ld hl, .earthStars
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .draw
	call CallDrawSkyMoon
	ld hl, .tetamusStars
.draw ;6
	ld b, $10
	ld a, [wViewDir]
	ld c, a ;c is view direction
.loop ;C4
	push bc
	ld a, [hl+] ;read byte
	sub a, c ;subtract our angle
	and $3F ;mask off to a quarter (yes the stars are repeated four times)
	ld c, a ;save updated C
	ld a, [wPitchAngle]
	sub $34
	ld d, a ;d is pitch
	ld a, [hl+] ;second value
	sub $10
	add a, d ;add our pitch
	ld b, a ;save into B.
	ld a, c
	cp $20
	jp nc, .next
;our modified viewangle is in the lower half
	add a, a
	add a, a ;times four
	ld c, a ;save it
	call CallRollValByTilt
	ld a, b
	ld e, a
	cp $80
	jr nc, .next
	ld b, $00 ;top of rom
	ld a, c
	ld d, a
	and $07
	ld c, a
	ld a, d
	rrca
	rrca
	rrca ;divided by eight
	and $1F
	add a, HIGH(wMonoBufferColumn1)
	ld d, a
	ld a, [bc] ;grab from top
	ld c, a
	ld a, [de]
	or c ;mask
	ld [de], a
.next ;41AF, 15
	pop bc
	dec b
	jr nz, .loop 
	ret
	
.tetamusStars ;41B4, tetamus star coords
	db $C3, $05 
	db $14, $14 
	db $28, $30 
	db $64, $24 
	db $B0, $02 
	db $19, $14 
	db $2D, $0F 
	db $B4, $28 
	db $01, $09 
	db $19, $0D 
	db $E6, $23 
	db $C8, $2D 
	db $69, $05 
	db $32, $2B 
	db $28, $18 
	db $BE, $17
.earthStars ;41D4, earth star coords
	db $32, $05 
	db $0C, $26 
	db $17, $0C 
	db $1B, $20 
	db $10, $0F 
	db $05, $13 
	db $02, $14 
	db $28, $1E 
	db $20, $23 
	db $3C, $19 
	db $04, $2C 
	db $35, $2B 
	db $3B, $30 
	db $20, $07 
	db $0F, $31 
	db $23, $0D

TryWriteScreenText: ;41F4
	;passed text pointer resides in bank 5
	ld a, [$CB49] ;?
	or a
	ret nz
	ld a, [$C29A] ;?
	or a
	ret nz ;if either were nonzero, return
	ld de, wScreenTextLine1Val ;text row 1 val?
	call TryWriteTextRow
	ret c ;if matched or written to, return
	ld de, wScreenTextLine2Val ;text row 2 val?
	call TryWriteTextRow
	ret c
	ld de, wScreenTextLine3Val ;text row 3 val?
	call TryWriteTextRow
	ret c
	push hl ;if nonmatching AND no free space, save passed pointer
	ld hl, wScreenTextLine2Ptr ;row 2 ptr
	ld de, wScreenTextLine1Ptr ;row 1 ptr
	ld b, $06
.transferloop ;421C
	ld a, [hl+] ;copy from row 2 to row 1
	ld [de], a
	inc de
	dec b
	jp nz, .transferloop
	xor a
	ld [de], a ;wipe the old row 2 data
	inc de
	ld [de], a
	inc de
	ld [de], a
	pop hl ;restore passed pointer
	ld de, wScreenTextLine3Val ;text row 3???
	;fallthrough
	
TryWriteTextRow: ;422D
	ld a, [de]
	or a
	jr z, .zero
	dec de ;value not zero, check pointer before value
	ld a, [de]
	cp h
	jr nz, .ncf
	dec de
	ld a, [de]
	cp l
	jr nz, .ncf
	scf ;set carry flag if value matched
	ret
.ncf ;pointer didn't match passed one
	and a
	ret
.zero ;423F, value is 0
	ld a, c ;passed by caller, example $A3
	ld [de], a ;save value
	dec de
	ld a, h
	ld [de], a
	dec de
	ld a, l
	ld [de], a ;save passed pointer
	scf ;set carry flag
	ret

HandleBriefExitPrompt: ;4249
	jr c, .carryset ;if carry set, jump past ret
	ld hl, BriefExitPromptGFX
	ld de, $8000
	ld bc, $01E0
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jp nz, .loop
	ret
	
.carryset ;425E
	ld b, $38
	ld c, $10
	ld e, $00
	ld hl, $C000
	ld a, $0A
.oamloop
	push af
	ld a, $03
.setcolumn
	push af
	ld a, b
	ld [hl+], a ;y
	ld a, c
	ld [hl+], a ;x
	ld a, e
	ld [hl+], a ;tile
	inc e
	xor a
	ld [hl+], a ;attribs
	ld a, b
	add a, $08
	ld b, a
	pop af
	dec a
	jp nz, .setcolumn
	ld a, b
	sub $18
	ld b, a
	ld a, c
	add a, $08
	ld c, a
	pop af
	dec a
	jp nz, .oamloop
.inputloop
	call WaitForVBlank
	call UpdateInputs
	ld a, [$C29D]
	ld e, a
	ld a, [$C29E]
	and e
	bit 1, a ;b
	jr nz, .cancel
	bit 0, a ;a
	jr z, .inputloop
	call ClearWRAM
	scf
	ret
.cancel
	call ClearWRAM
	xor a
	ret
BriefPlanetGFX1: ;42AC
INCBIN "build/gfx/BriefingTetamus1.1bpp"
;457C
INCBIN "build/gfx/BriefingTetamus2.1bpp"
BriefEquipmentGFX: ;484C
INCBIN "build/gfx/EquipmentLesson.1bpp"
;4B1C
INCBIN "build/gfx/BigMinimap.1bpp"
;4DEC
INCBIN "build/gfx/AlienTech.1bpp"
;50BC
INCBIN "build/gfx/ConvoyRoute.1bpp"
;538C
INCBIN "build/gfx/ReactorAttack.1bpp"
BriefScientistGFX: ;565C
INCBIN "build/gfx/Scientist.1bpp"
BriefImposterGFX: ;592C
INCBIN "build/gfx/ScientistImposter.1bpp"
;5BFC
INCBIN "build/gfx/BombPlan1.1bpp"
;5ECC
INCBIN "build/gfx/BombPlan2.1bpp"
;619C
INCBIN "build/gfx/MissionLayout.1bpp"
;646C
INCBIN "build/gfx/PlanView.1bpp"
BriefExitPromptGFX: ;673C
INCBIN "build/gfx/BriefExitPrompt.2bpp"
;691C