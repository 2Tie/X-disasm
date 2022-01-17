SECTION "E:TOP", ROMX[$4000], BANK[$E]
TriggerCredits: ;4000
	ld a, $1E
	ld [wQueueMusic], a
	ld a, $01
	ldh [$FF91], a
	call CallWriteSave
	jp Credits
;400F

;0x3815A - 0x383D9: fat brighttext
SECTION "E:43DA", ROMX[$43DA], BANK[$E]
HandleJunctionTunnelSel: ;43DA, Junction tunnel selection screen
	call CallDisableLCD
	call ClearAllVRAM
	call LoadUnusedTextTiledata
	call WipeWholeScreenTiles
	ld hl, PlanetSelectGFX
	ld de, $8000 ;top of vram
	ld b, $20
.selectorcopy ;FA
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .selectorcopy
	ld hl, JunctionTunnelSelectTileset
	ld bc, $0080
	ld de, $0001
	call LoadTileMap
	xor a
	ldh [rIF], a
	ldh [hGameState], a
	ldh a, [rIE]
	res LCD_STAT, a
	ldh [rIE], a
	loadpalette 3, 2, 1, 0
	ldh [rBGP], a
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld c, $28
	ld b, $38
	xor a
	ld [$C33B], a ;current tunnel exit?
.selectionloop ;4421
	call WaitForVBlank
	call UpdateInputs
	ld a, [wChangedInputs]
	ld d, a
	ld a, [wCurrentInput]
	and d ;new presses in D
	ld d, a
	and a
	bit INPUT_START, d
	ret nz
	and a
	bit INPUT_B, d
	ret nz ;B or Start backs out
	bit INPUT_A, d
	jp nz, .selected
	ld a, [$C33B] ;0 at start
	ld e, a
	or a
	jr z, .tlcheckr
	dec a
	jr z, .trcheckl
	dec a
	jr z, .brcheckl
	;else we are bottom left
	bit INPUT_UP, d
	jr z, .blcheckr
	inc e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.blcheckr
	bit INPUT_RIGHT, d
	jr z, .blnone
	dec e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.blnone
	jr .saveposition
.brcheckl ;currently 3 (bottom right)
	bit INPUT_LEFT, d
	jr z, .brchecku
	inc e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.brchecku
	bit INPUT_UP, d
	jr z, .brnone
	dec e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.brnone
	jr .saveposition
.trcheckl ;currently 1 (top right)
	bit INPUT_LEFT, d
	jr z, .trcheckd
	dec e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.trcheckd 
	bit INPUT_DOWN, d
	jr z, .trnone
	inc e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.trnone 
	jr .saveposition
.tlcheckr ;currently 0 (top left)
	bit INPUT_RIGHT, d
	jr z, .tlcheckd
	inc e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.tlcheckd
	bit INPUT_DOWN, d
	jr z, .saveposition
	dec e
	ld a, $01 ;beep
	ld [wQueueSFX], a
.saveposition
	ld a, e
	and $03 ;mask to our four positions
	ld [$C33B], a ;and save it
	ld a, [wFrameCounterLo]
	and $0F
	cp $08
	loadpalette 3, 3, 3, 3
	jr nc, .savepal
	cpl
.savepal
	ldh [rOBP0], a
	ld a, [$C33B] ;position
	sla a
	add a, LOW(TunSelCursorPositions)
	ld l, a
	ld a, HIGH(TunSelCursorPositions)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld c, a
	ld b, [hl] ;B and C hold top right XY coord for cursor sprites
	call SetTunSelCursorOAM
	jp .selectionloop ;loop
.selected ;44CA
	ld a, $02 ;beep
	ld [wQueueSFX], a
	ld b, $0A
.selectedwaitloop ;44D1
	push bc
	ldh a, [rOBP0]
	cpl ;invert
	ldh [rOBP0], a
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	pop bc
	dec b
	jp nz, .selectedwaitloop
	call ClearAllVRAM
	ld a, [$C33B] ;selected tunnel
	push af
	sla a
	add a, LOW(JunctionTunnelPointers)
	ld l, a
	ld a, HIGH(JunctionTunnelPointers)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;hl is now a pointer to the tunnel to use
	call HandleJunctionTunnel
	pop af
	sla a
	sla a ;four byte table
	add a, LOW(TunnelExitPositions)
	ld l, a
	ld a, HIGH(TunnelExitPositions)
	adc a, $00
	ld h, a
	ld a, [hl+] ;first is X
	ldh [hXHiCopy], a
	ldh [hXPosHi], a
	ld a, [hl+] ;second is Y
	ldh [hYHiCopy], a
	ldh [hYPosHi], a
	ld a, [hl+] ;third is angle
	ldh [hViewAngle], a
	ld [wViewDir], a
	xor a
	ld [$C356], a ;?
	ldh [hXLoCopy], a
	ldh [hYLoCopy], a
	ldh [hXPosLow], a
	ldh [hYPosLow], a
	xor a
	ld [$CAA7], a ;?
	ld a, $14
	ldh [hZPosLow], a ;set us on the ground
	xor a
	ldh [hZPosHi], a
	ld a, $01
	ld [$C2B7], a ;set this
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.entityloop ;453A
	ld a, [hl+]
	or a
	jr z, .nextentity
	bit 7, a
	jr nz, .nextentity
	push bc
	call CallCheckDeloadEntity
	pop bc
.nextentity
	ld a, l
	add a, ENTITY_SIZE-1 ;since we already progressed one
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .entityloop
	call CallIterateOverMapObjects ;refill any absent slots with relevant entities now
	xor a
	ld [$C2B7], a ;clear this
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
	xor a
	ld [wTurnSpeed], a
	ld [$CB07], a
	ld [$C356], a
	ld a, spdMED
	ldh [hSpeedTier], a
	scf
	ret
	
TunSelCursorPositions: ;4581, cursor XY offsets
	db $26, $38
	db $6C, $38 
	db $6C, $70 
	db $26, $70
TunnelExitPositions: ;4589
	db $BF, $41, $E0, $00 ;x, y, angle
	db $41, $41, $20, $00 
	db $41, $BF, $60, $00 
	db $BF, $BF, $A0, $00

SetTunSelCursorOAM: ;4599
	ld hl, wOAMStart
	ld a, b
	ld [hl+], a ;y from table
	ld a, c
	ld [hl+], a ;x from table
	xor a
	ld [hl+], a ;tile 0
	ld [hl+], a ;no attrib
	ld a, b
	ld [hl+], a ;y
	ld a, c
	add a, $18
	ld [hl+], a ;x+18
	xor a
	ld [hl+], a ;tile 0
	ld a, X_FLIP
	ld [hl+], a ;mirror horiz 
	ld a, b
	add a, $10
	ld [hl+], a ;y+10
	ld a, c
	ld [hl+], a ;x
	xor a
	ld [hl+], a ;tile 0
	ld a, Y_FLIP
	ld [hl+], a ;mirror vert
	ld a, b
	add a, $10
	ld [hl+], a ;y+10
	ld a, c
	add a, $18
	ld [hl+], a ;x+18
	xor a
	ld [hl+], a ;tile 0
	ld a, X_FLIP | Y_FLIP
	ld [hl+], a ;mirror vert | mirror horiz
	ret
	
	
PlanetSelectGFX: ;45C7: planet select tile(s)
INCBIN "build/gfx/planetselectcursor.2bpp"

JunctionTunnelSelectTileset: ;45D7
	db $14, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $01, $02, $03, $04, $05, $06, $04, $07, $04, $08, $09, $04, $0A, $0B, $04, $0C, $00 
	db $00, $0D, $0E, $0F, $10, $11, $12, $10, $13, $10, $14, $15, $10, $16, $17, $10, $18, $00 
	db $00, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $1F, $21, $22, $1C, $23, $24, $1F, $25, $00 
	db $00, $26, $27, $0F, $10, $11, $28, $10, $13, $10, $14, $15, $10, $29, $17, $10, $18, $00 
	db $00, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $2D, $32, $33, $34, $35, $36, $2D, $37, $00 
	db $00, $38, $39, $0F, $10, $3A, $3B, $3C, $3D, $10, $14, $3E, $3F, $40, $41, $10, $18, $00 
	db $00, $42, $43, $44, $45, $46, $47, $48, $49, $48, $4A, $4B, $45, $4C, $4D, $48, $4E, $00 
	db $00, $4F, $39, $0F, $10, $3A, $12, $10, $3D, $50, $51, $3E, $10, $16, $52, $10, $18, $00 
	db $00, $53, $39, $0F, $10, $3A, $12, $10, $54, $55, $56, $57, $10, $16, $52, $10, $18, $00 
	db $00, $58, $59, $5A, $5B, $5C, $5D, $5B, $5E, $5F, $60, $61, $5B, $62, $63, $5B, $64, $00 
	db $00, $65, $43, $0F, $10, $11, $12, $10, $13, $66, $67, $15, $10, $16, $17, $10, $18, $00 
	db $00, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $6E, $70, $71, $6B, $72, $73, $6E, $74, $00 
	db $00, $75, $76, $0F, $10, $11, $77, $78, $13, $10, $14, $15, $79, $7A, $17, $10, $18, $00 
	db $00, $7B, $39, $7C, $7D, $7E, $7F, $80, $81, $7D, $82, $83, $84, $85, $86, $7D, $87, $00 
	db $00, $88, $39, $0F, $10, $3A, $89, $8A, $3D, $10, $14, $3E, $10, $8B, $52, $10, $18, $00 
	db $00, $8C, $39, $8D, $8E, $8F, $90, $91, $92, $91, $93, $94, $8E, $95, $96, $91, $97, $00 
	db $00, $98, $99, $0F, $10, $3A, $12, $10, $3D, $10, $14, $3E, $10, $16, $52, $10, $18, $00 
	db $00, $9A, $9B, $9C, $9D, $9E, $9F, $9D, $A0, $9D, $A1, $A2, $9D, $A3, $A4, $9D, $A5, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;4741
	INCBIN "build/gfx/JunctionTunnelSelect.rle"

;4E47
	call ScatterTitleScreen
Credits: ;4E4A
	call CallDisableLCD
	call ClearAllVRAM
	ld hl, $9800
	ld a, $80
	ld b, $00
.floodloop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jp nz, .floodloop
	call CreditsSetUpStars
	call Refresh3DWindow
	call CallCopyWRAMToVRAM
	call CallCopyWRAMToVRAM
	ld a, $FF
	ldh [rWX], a
	ld a, $2C
	ld [$C2BC], a ;?
	ld [$C2BD], a ;?
	ld a, $D0
	ldh [$FF9B], a
	ld a, $F0
	ldh [rSCY], a
	ld [wTargetSCY], a
	xor a
	ld [$C2B7], a ;?
	ldh [$FF9E], a
	ldh [$FF9F], a
	ldh [hGameState], a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFEE], a
	ldh [$FFF0], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ld a, $08
	ldh [rSCX], a
	ld a, $53
	ldh [rBGP], a
	ld a, $67
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ld hl, CreditsText
.parseloop ;4EBF
	ld a, [hl]
	or a
	jp z, .endoftext
	cp $0C
	jr nz, .notC ;to 4ED9
	inc hl ;else read the two vals (word??)
	ld a, [hl+]
	ldh [$FFDD], a ;?
	ld a, [hl+]
	ldh [$FFDE], a ;?
	push hl ;save our read position
	call CreditsWipeBG
	call CreditsWipeBG
	jp .restorepos
	
.notC ;4ED9
	cp $0D
	jr nz, .handlestring
	inc hl
	ld a, [hl+]
	ldh [$FFDD], a
	ld a, [hl+]
	ldh [$FFDE], a ;these get loaded every screen?
	push hl
	call CallCopyWRAMToVRAM
	ld d, 150 ;150 vblanks = 2.5 seconds, roughly
.delayloop
	push de
	call WaitForVBlank
	call CreditsTwinkle
	pop de
	dec d
	jp nz, .delayloop
	call NextRand
	and $10
	sub $08 ;-8 through 7
	ld e, a
	call NextRand
	and $0F
	sub $08 ;-8 through 6?
	ld d, a
	ld a, $04
	ld [wQueueNoise], a
	ld b, $10
.scrollloop
	push bc
	push de
	call WaitForVBlank
	call CreditsTwinkle
	pop de
	pop bc
	ldh a, [rSCX]
	add a, e
	ldh [rSCX], a
	ldh a, [rSCY]
	add a, d
	ldh [rSCY], a
	ld [wTargetSCY], a
	dec b
	jr nz, .scrollloop
	call CreditsWipeBG
	call CreditsWipeBG
	ld a, $F0
	ldh [rSCY], a
	ld [wTargetSCY], a ;reset scroll position
	;fallthrough to
.restorepos ;4F34
	pop hl ;restore read
.handlestring ;4F35
	push hl
	call CreditsDrawText
	ld a, $03
	ld [wQueueNoise], a
	pop hl
.advancepaststring
	ld a, [hl+]
	or a
	jp nz, .advancepaststring
	ldh a, [$FFDD] ;add some value to Z?
	add a, $64
	ldh [$FFDD], a
	ldh a, [$FFDE]
	adc a, $00
	ldh [$FFDE], a
	jp .parseloop
	;dummy
	ret
	
.endoftext ;4F54
	call CallCopyWRAMToVRAM
	ld a, $08
	ld [wUpdateCounter], a
.loadnextconstellation ;4F5C
	ld a, [wUpdateCounter]
	ld c, $38
	ld b, $58 ;address?
	call CreditsProcessConstellation
	call CreditsSetStarPaths
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld b, $3C
.bloop
	push bc
	call WaitForVBlank
	call CreditsUpdateStarPositions
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	bit 3, a ;check start
	jp nz, Reset
	pop bc
	dec b
	jr nz, .bloop
	call CreditsAnimateStars
	ld d, 100
	call WaitFrames
	xor a
	ld [wViewDir], a
.speen ;4F97
	call CreditsSpinStars
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	bit 3, a
	jp nz, Reset
	ld a, [wUpdateCounter]
	bit 0, a ;odd or even update?
	ld a, [wViewDir]
	jr nz, .sub
	add a, $04
	jr .didmath
.sub
	sub $04
.didmath
	ld [wViewDir], a
	jp nz, .speen
	ld b, $00
.inputloop
	push bc
	call WaitForVBlank
	call CreditsUpdateStarPositions
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	bit 3, a
	jp nz, Reset
	pop bc
	dec b
	jr nz, .inputloop
	ld a, [wUpdateCounter]
	inc a
	and $07
	ld [wUpdateCounter], a
	jp .loadnextconstellation
	
Unused_CreditsTransition: ;4FE9
	ld a, $05
	call CreditsSetAllStars
	ld d, $0A
	call WaitFrames
	ld a, $06
	call CreditsSetAllStars
	ld d, $0A
	call WaitFrames
	ld a, $07
	call CreditsSetAllStars
	ld d, $0A
	call WaitFrames
	call WaitForStartPress
	jp Reset
	
CreditsAnimateStars: ;500D
	ld hl, $D358
	ld de, $C000
	ld b, $28
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	inc de
	inc de
	dec b
	jp nz, .loop
	ret
	
CreditsSpinStars: ;5022
	ld hl, $C000 ;OAM base
	ld de, wCreditStarPositions
	ld a, CREDIT_STARS
.loop
	push af
	ld a, [de]
	inc de
	sub $50
	ld b, a
	ld a, [de]
	inc de
	sub $58
	ld c, a
	push hl
	push de
	ld a, [wViewDir]
	ld d, a
	call CallRotateCoordByAngle
	pop de
	pop hl
	ld a, b
	add a, $50
	ld [hl+], a
	ld a, c
	add a, $58
	ld [hl+], a
	inc hl
	inc hl
	pop af
	dec a
	jp nz, .loop
	ret
	
CreditsSetAllStars: ;5050
	ld hl, $C000
	ld b, $28
.loop
	inc hl
	inc hl
	ld [hl+], a
	inc hl
	dec b
	jp nz, .loop
	ret

CreditsDrawText: ;505E
	xor a
	ldh [$FFDB], a
	ldh [$FFDC], a
.loop
	xor a
	ldh [$FFA1], a
	ldh [$FFA5], a
	ldh [$FFA4], a
	ldh [$FFA3], a
	ldh a, [$FFDB] ;this causes the zoom?
	add a, $50
	ldh [$FFDB], a
	ldh a, [$FFDC]
	adc a, $00
	ldh [$FFDC], a
	push hl
	call CreditsGetStringXOffset
	call Draw3DString
	ldh a, [$FFDC]
	cp $06
	jr c, .zoom
	call CreditsCopyWRAM
	call CreditsCopyWRAM
	call CallCopyWRAMToVRAM
	call CallRefreshBGTiles
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	pop hl
	ret
.zoom
	call CallCopyWRAMToVRAM
	call CreditsTwinkle
	pop hl
	ld a, $08
	ldh [rSCX], a
	jp .loop
;50A8
	ret

CreditsWipeBG: ;50A9
	ld hl, $8D00
	ld bc, $0580
.loop
	ldh a, [rSTAT]
	and $02
	jr nz, .loop ;waitforblank
	xor a
	ld [hl+], a
	inc hl
	dec bc
	ld a, b
	or c
	jp nz, .loop
	ret
	
CreditsCopyWRAM: ;50BF
	ld hl, $8D00
	ld de, wMonoBufferColumn1
	ld b, $10
.loop
	ld a, [de]
	ld c, a
.vbl1
	ldh a, [rSTAT]
	and $02
	jr nz, .vbl1
	ld a, [hl]
	cp $FF
	jr nz, .skeep
.vbl2
	ldh a, [rSTAT]
	and $02
	jr nz, .vbl2
	ld a, [hl]
.skeep
	or c
	ld c, a
.vbl3
	ldh a, [rSTAT]
	and $02
	jr nz, .vbl3
	ld [hl], c
	inc l
	inc hl
	inc e
	ld a, e
	cp $58
	jp c, .loop
	ld e, $00
	inc d
	dec b
	jp nz, .loop
	ret

CreditsGetStringXOffset: ;50F5
	push hl
	ld bc, $0046
.loop
	ld a, c
	sub $23
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a
	ld a, [hl+]
	or a
	jr nz, .loop
	ld a, c
	ldh [$FFDF], a
	ld a, b
	ldh [$FFE0], a
	pop hl
	ret

CreditsSetUpStars: ;510D
	ld hl, $C000 ;OAM
	ld b, $28
.loop ;5112
	call NextRand
	cp $90
	jr c, .skipx
	sub $90
.skipx
	sub $08
	cp $58
	add a, $10
	ld [hl+], a ;X
	call NextRand
	cp $A0
	jr c, .skipy
	sub $A0
.skipy
	sub $10
	cp $80
	add a, $18
	ld [hl+], a ;Y
	call NextRand
	and $03
	ld [hl+], a ;Tile
	ld a, $10 ;obj pal 1
	ld [hl+], a ;Attribs
	dec b
	jp nz, .loop
	ld hl, CreditsStarsGFX
	ld de, $8000
	ld b, $80
.endloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jp nz, .endloop
	ret

CreditsTwinkle: ;514F
	call NextRand
	and $3F ;six bits
	cp $28
	jr c, .bounded
	sub $28
.bounded
	rlca ;multiply by four; use this to choose random OAM slot
	rlca
	add a, $02 ;plus two
	add a, $00 ;OAM
	ld l, a
	ld a, $C0 ;OAM
	adc a, $00
	ld h, a
	call NextRand
	and $03
	ld [hl+], a ;random tile
	ret
	
CreditsStarsGFX: ;516D
INCBIN "build/gfx/CreditsStars.2bpp"

CreditsText: ;51ED - 5497ish: credits text
	db $0C, $CE, $FF
	db "X", 00
	db $0D, $38, $FF 
	db "DIRECTED", 00, "BY", 00, "YOSHIO", 00, "SAKAMOTO", 00 
	db $0D, $38, $FF
	db "PROGRAM AND", 00, "DESIGN BY", 00, "DYLAN", 00, "CUTHBERT", 00, "OF ARGONAUT", 00 
	db $0D, $38, $FF 
	db "GRAPHIC", 00, "DESIGN", 00, "KENICHI", 00, "SUGINO", 00
	db $0D, $60, $FF 
	db "^D SHAPES", 00, "BY", 00, "DANNY EMMETT", 00
	db $0D, $38, $FF ;this should be 3D not ^D
	db "MUSIC" ,00, "BY", 00, "H TANAKA", 00, "AND", 00, "K TOTAKA", 00
	db $0D, $38, $FF 
	db "TECHNICAL", 00, "SUPPORT", 00, "TAKEHIRO", 00, "IZUSHI", 00
	db $0D, $38, $FF 
	db "ASSISTANT", 00, "SUPPORT", 00, "NOBUHIRO", 00, "OZAKI", 00
	db $0D, $38, $FF 
	db "ADDITIONAL", 00, "HELP AND", 00, "DESIGN FROM", 00, "DAN OWSEN", 00, "F NOMURA", 00
	db $0D, $FC, $FE 
	db "ENGLISH", 00, "SUPPORT", 00, "D DRABWELL", 00, "I CROWTHER", 00, "S LITTLEWOOD", 00, "G GODDARD", 00
	db $0D, $FC, $FE 
	db "JAPANESE", 00, "SUPPORT", 00, "M KANOH", 00, "T OHSAWA", 00, "T IMOTO", 00, "Y OGAWA", 00
	db $0D, $38, $FF 
	db "SPECIAL", 00, "THANKS TO", 00, "S INOKE", 00, "K YAMANO", 00, "JB YAMADA", 00
	db $0D, $38, $FF 
	db "THANKS TO", 00, "TONY HARMAN", 00, "YUKA NAKATA", 00, "TONY STANCZYK", 00, "STEVEN DUNN", 00
	db $0D, $38, $FF 
	db "PRODUCED", 00, "BY", 00, "GUNPEI", 00, "YOKOI", 00
	db $0D, $38, $FF 
	db "EXECUTIVE", 00, "PRODUCER", 00, "HIROSHI", 00, "YAMAUCHI", 00
	db $0D, $9C, $FF 
	db "NINTENDO", 00, "\\dd]", 00, 00 ;should say 1992 instead of \dd]
	;unused?
	db "LUNAR CHASE\r\r\r\rWAS\rBROUGHT TO\rYOU BY", $5B, $5B, "\r\r\r\r\rNINTENDO\r", $5C, " 1991", 00
	
CheckDeleteSaveInput: ;5498
	;clear flag set if 
	ld hl, wInputCodePtr
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret z ;if pointer in C270/71 is blank, ret
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	and a ;why
	ret z ;if inputs blank, ret
	cp [hl] ;if value in pointer doesn't match new inputs
	jr nz, .failed ;clear pointer
	inc hl
	ld a, [hl] ;else advance pointer
	or a
	jr nz, .nextinput ;if it's not zero, store it
	scf
	ret
.nextinput: ;54B4
	ld a, l
	ld [wInputCodePtrLo], a
	ld a, h
	ld [wInputCodePtrHi], a ;load pointer into C270/71
	call UpdateInputs
	xor a
	ret
.failed: ;54C1
	xor a
	ld [wInputCodePtrLo], a ;clear C270/71
	ld [wInputCodePtrHi], a
	ret
	
DeleteSaveInputList: ;54C9
	db (1<<INPUT_B), (1<<INPUT_RIGHT), (1<<INPUT_B), (1<<INPUT_A), (1<<INPUT_DOWN), 00
CreditsInputList: ;54CF
	db (1<<INPUT_B), (1<<INPUT_A), (1<<INPUT_DOWN), (1<<INPUT_START), (1<<INPUT_A), (1<<INPUT_RIGHT), (1<<INPUT_B), (1<<INPUT_UP), (1<<INPUT_RIGHT), (1<<INPUT_START), 00
	
SetupSiloGraphics: ;54DA
	call ClearAllVRAM
	call ClearWRAM
	ld hl, SiloImposterTilemap
	ld de, $0001
	ld bc, $0080
	call LoadTileMap
	xor a
	ldh [rIF], a
	ldh [hGameState], a
	ld a, LCD_STAT
	ldh [rIE], a
	loadpalette 2, 1, 0, 3
	ldh [rBGP], a
	ldh [hBGP], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	call WaitForNoNewInput
	ret
	
PlanetSelect: ;550A
	call ClearAllVRAM
	call ClearWRAM
	ld hl, PlanetSelectTilemap ;address
	ld de, $0001 
	ld bc, $0080
	call LoadTileMap
	xor a
	ldh [rIF], a
	ldh [hGameState], a
	ld a, $01
	ldh [rIE], a
	xor a
	ld [$C2ED], a
	ldh [rSCY], a
	ld hl, PlanetSelectGFX ;graphics
	ld de, $8000 ;target
	ld b, $20 ;length (two tiles)
.loadloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loadloop
	ld a, $93
	ldh [rBGP], a
	ldh [hBGP], a
	ld a, $03
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	xor a
	ld [$CA95], a
.mainloop
	call WaitForVBlank
	ld a, [$CA96] ;frame
	and $1F
	cp $10 ;every ten frames
	ld a, $03 ;load one pal
	jr nc, .skip
	ld a, $AB ;or the other
.skip
	ldh [rOBP0], a
	ldh [rOBP1], a ;to make selection frame blink
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	ld d, a
	and $F4 ;directions or select
	jr z, .skip2
	ld a, [wSelectedPlanet] ;invert selection
	xor $01
	ld [wSelectedPlanet], a
	ld a, $01
	ld [$C100], a
.skip2
	ld a, d
	and $0B ;check start, b, or a
	jp nz, .selected
	ld a, [wSelectedPlanet]
	swap a ;selects which OAM data to copy
	add a, LOW(PlanetSelectOAMTetamus)
	ld l, a
	ld a, HIGH(PlanetSelectOAMTetamus) ;55BC into HL
	adc a, $00
	ld h, a
	ld de, $C000
	ld b, $10
.copyOAMloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copyOAMloop
	jp .mainloop
	
.selected
	ld a, $02
	ld [$C100], a
	ld b, $0A
.flashloop
	push bc
	ldh a, [rOBP0]
	cpl
	ldh [rOBP0], a
	call WaitForVBlank
	call WaitForVBlank
	call WaitForVBlank
	pop bc
	dec b
	jp nz, .flashloop
	ret
	
PlanetSelectOAMTetamus: ;55BC
	db $5A, $5E, $00, $00 
	db $8C, $8E, $00, $60 
	db $8C, $5E, $00, $40 
	db $5A, $8E, $00, $20
PlanetSelectOAMEarth: ;55CC
	db $26, $15, $00, $00 
	db $35, $24, $00, $60 
	db $26, $24, $00, $20 
	db $35, $15, $00, $40
	
ReadSave: ;55DC
	ld a, SRAM_ENABLE
	ld [$0018], a
	ld c, $FF
	ld hl, $A000
	call ReadRamNybbleWithMask
	cp $0B ;$B is the save header?
	jr nz, .wrongchecksum
	call ReadRamNybbleWithMask
	rlca
	rlca
	ld [$C0AF], a ;first nybble << 2 into here
	call ReadRamByteWithMask
	ld [wBigStars], a ;next two nybbles are C2C3
	call ReadRamByteWithMask
	ld [wSmallStars], a ;next two nybbles are C2C4
	call ReadRamNybbleWithMask
	ld [$C2D8], a ;next nybble to C2D8
	call ReadRamNybbleWithMask
	ldh [$FF91], a ;next nybble to FF91
	call ReadRamNybbleWithMask
	ld [$C298], a ;next nybble to C298
	call ReadRamNybbleWithMask
	ld a, c ;final nybble is ??
	and $0F
	ld c, a ;snag the final mask
	ld a, [hl+]
	and $0F
	cp c ;final nybble is the checksum
	jr nz, .wrongchecksum
	xor a ;it matched
	ld [$0019], a ;disable sram
	ret ;return
.wrongchecksum
	xor a
	ld [$0019], a ;disable sram
	xor a
	ld [$C0AF], a ;clear all the loaded "save data"
	ld [$CB4A], a
	ldh [$FF91], a
	ld [wBigStars], a
	ld [wSmallStars], a
	ld [$C298], a
	ret
	
WriteSave: ;563B
	ld a, SRAM_ENABLE
	ld [$0018], a
	ld c, $FF
	ld hl, $A000
	ld a, $0B ;magic
	call WriteRamNybble
	ld a, [$C0AF]
	rrca
	rrca
	call WriteRamNybble
	ld a, [wBigStars]
	call WriteRamByte
	ld a, [wSmallStars]
	call WriteRamByte
	ld a, [$C2D8]
	call WriteRamNybble
	ldh a, [$FF91]
	call WriteRamNybble
	ld a, [$C298]
	call WriteRamNybble ;write the six values
	ld a, $05
	call WriteRamNybble ;write 5 (version?)
	ld a, c
	call WriteRamNybble ;write checksum
	xor a
	ld [$0019], a ;disable sram
	ret
	
WriteRamNybble: ;567D
	and $0F
	ld [hl+], a
	xor c
	ld c, a
	ret

ReadRamNybbleWithMask: ;5683
	ld a, [hl+]
	and $0F
	ld b, a
	xor c
	ld c, a ;masked values into c
	ld a, b ;raw nybble into a
	ret
ReadRamByteWithMask: ;568B
	ld a, [hl+]
	and $0F
	ld b, a
	xor c
	ld c, a ;masked value into c
	ld a, [hl+]
	and $0F
	swap a
	or b
	ld b, a ;raw byte into b
	swap a
	and $0F
	xor c
	ld c, a ;mask nybble into c
	ld a, b ;raw byte into a
	ret
	
WriteRamByte: ;56A0
	ld b, a
	and $0F
	ld [hl+], a ;write one nybble
	xor c
	ld c, a
	ld a, b
	swap a
	and $0F
	ld [hl+], a ;write the other nybble
	xor c
	ld c, a
	ret
	
CreditsProcessConstellation: ;56AF
	rlca ;x2, word offset
	add a, LOW(CreditStarPicTable)
	ld l, a
	ld a, HIGH(CreditStarPicTable)
	adc a, $00
	ld h, a ;into table at 576E
	ld a, [hl+]
	ld e, a
	ld d, [hl] ;load pointer into DE
	ld hl, wCreditStarPositions
	xor a
	REPT $50
	ld [hl+], a
	ENDR ;wipe the table clean
	ld hl, wCreditStarPositions
	ld a, $10
.constellationloop
	push af
	push bc
	ld a, [de]
	inc de
	push de
	call CreditsProcessConstellationByte
	pop de
	push de
	ld a, e
	add a, $0F
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance to the next row?
	ld a, [de]
	call CreditsProcessConstellationByte
	pop de
	pop bc
	ld a, b
	add a, $04
	ld b, a
	pop af
	dec a
	jp nz, .constellationloop
	ld a, $A8
	sub a, l
	ld c, a
	ld a, $D3
	sbc a, h
	cp $80
	jr nc, .ret ;return for overshoot?
	or c
	jr z, .ret ;if at the end of the table, return
	srl c ;divide undershoot by two to get number of stars to duplicate
	ld de, wCreditStarPositions
.dupeloop ;copy stars from the start until the table's full
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	dec c
	jp nz, .dupeloop
.ret
	ret
	
CreditsProcessConstellationByte: ;5753
	;a is read byte from constellation
	ld d, $08
.loop
	rla ;shift left
	ld e, a ;new pos in E
	jr nc, .pixelhandled
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a ;write position
.pixelhandled
	ld a, c
	add a, $04
	ld c, a
	ld a, e ;restore new pos
	dec d
	jr nz, .loop
	ret
	
JunctionTunnelPointers: ;5766
	dw $4AA6
	dw $5074
	dw $4E57
	dw $4C84
	
CreditStarPicTable: ;576E
	dw $5780
	dw $57A0
	dw $57C0
	dw $57E0
	dw $5800
	dw $5820
	dw $5840
	dw $5860
	dw $5880
	
;5780-589F: 1bpp credits star shapes
INCBIN "build/gfx/EndFireworks.1bpp"

SECTION "E:58F0", ROMX[$58F0], BANK[$E]
CreditsUpdateStarPositions: ;58F0
	ld hl, wEntityTable
	ld de, $C000 ;OAM base
	ld a, CREDIT_STARS
.loop
	push af
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;load saved CB
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;increment saved position with it
	ld [de], a ;update OAM X position
	inc de
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a
	ld [de], a ;do the same with OAM Y position
	ld a, e
	add a, $03
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance to the next OAM entry
	pop af
	dec a
	jp nz, .loop
	ret

CreditsSetStarPaths: ;591E
	ld hl, $C000 ;OAM base
	ld de, wEntityTable
	ld bc, wCreditStarPositions
	ld a, CREDIT_STARS
.loop
	push af
	push bc
	push hl
	push de
	ld a, [hl+] ;load sprite location, X
	srl a ;divide by two
	ld h, a ;save in H
	ld a, [bc] ;load destination, X
	srl a ;divide by two
	sub a, h ;destination pos - current pos
	ld h, a ;save result in H
	ld l, $00
	ld de, $003C
	call SubtractWords
	pop de ;entity table pos?
	sla c
	rl b
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a ;save CB
	inc de
	pop hl ;restore OAM position
	xor a
	ld [de], a ;save 0
	inc de
	ld a, [hl+]
	ld [de], a ;save original OAM X
	inc de
	pop bc
	push bc
	push hl
	push de
	ld a, [hl+] ;now load OAM Y
	srl a
	ld h, a
	inc bc
	ld a, [bc] ;and destination Y
	srl a
	sub a, h
	ld h, a ;save the difference
	ld l, $00
	ld de, $003C
	call SubtractWords
	pop de ;entity table pos
	sla c
	rl b
	ld a, c
	ld [de], a
	inc de
	ld a, b
	ld [de], a ;save CB
	inc de
	pop hl
	xor a
	ld [de], a ;save 0
	inc de
	ld a, [hl+]
	ld [de], a ;save OAM Y
	inc de
	ld a, $04
	ld [hl+], a ;write 4 to OAM tile
	inc hl ;proceed to next sprite
	pop bc
	inc bc
	inc bc ;advance the destination map
	pop af
	dec a
	jp nz, .loop
	ret
	
SiloImposterTilemap: ;5985: silo interior tilemap, $80 long? 14 12 first values?
	db $14, $12
	db $00, $01, $02, $03, $03, $03, $03, $04, $05, $00, $00, $06, $07, $08, $00, $00, $00, $09 
	db $00, $0A, $00, $00, $00, $00, $00, $00, $0B, $00, $0C, $0D, $0E, $0F, $10, $00, $00, $11 
	db $00, $0A, $00, $00, $00, $00, $00, $00, $0B, $00, $12, $13, $14, $15, $16, $00, $17, $18 
	db $00, $0A, $00, $19, $1A, $1B, $1C, $1D, $0B, $1E, $00, $1F, $20, $21, $22, $23, $24, $25 
	db $00, $0A, $26, $27, $28, $29, $2A, $2B, $0B, $2C, $00, $2D, $2E, $2F, $30, $31, $32, $33 
	db $00, $0A, $34, $35, $36, $37, $38, $39, $0B, $3A, $00, $3B, $3C, $3D, $3E, $3F, $40, $41 
	db $00, $0A, $42, $43, $44, $45, $46, $47, $0B, $48, $00, $49, $4A, $4B, $4C, $4D, $4E, $4F 
	db $00, $0A, $00, $50, $51, $52, $53, $54, $0B, $55, $56, $57, $58, $59, $5A, $00, $5B, $5C 
	db $00, $0A, $00, $5D, $5E, $5F, $60, $61, $0B, $62, $63, $64, $65, $66, $67, $00, $00, $68 
	db $00, $0A, $00, $69, $6A, $6B, $6C, $6D, $6E, $6F, $00, $70, $71, $72, $73, $00, $00, $74 
	db $00, $0A, $75, $76, $77, $78, $00, $79, $7A, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $00, $7B, $00, $7C, $00, $7D, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $7E, $7F, $00, $00, $00, $80, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $81, $82, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $00, $83, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $84, $85, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $00, $00, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $0A, $00, $00, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $86, $00, $00, $00, $00, $00, $00, $87, $00, $00, $00, $00, $00, $00, $00, $00, $25 
	db $00, $34, $88, $03, $03, $03, $03, $89, $8A, $00, $00, $00, $00, $00, $00, $00, $00, $8B
;5AEF
	INCBIN "build/gfx/SiloImposter.rle"
	
PlanetSelectTilemap: ;5E5A -5FC1: planet select tilemap, $168 long
	db $14, $12
	db $00, $01, $00, $00, $00, $00, $02, $00, $00, $03, $04, $00, $00, $05, $00, $00, $00, $02 
	db $00, $00, $00, $06, $07, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $09, $00, $0A, $0B, $0C, $00, $00, $00, $00, $00, $00, $0D, $0E, $00, $00, $00, $00 
	db $0F, $00, $00, $10, $11, $12, $00, $00, $00, $00, $00, $00, $13, $14, $00, $15, $00, $00 
	db $00, $00, $16, $17, $18, $19, $1A, $00, $00, $00, $1B, $00, $1C, $1D, $00, $00, $00, $00 
	db $1E, $00, $00, $1F, $20, $21, $22, $1A, $00, $23, $00, $00, $24, $25, $00, $00, $00, $00 
	db $00, $00, $00, $26, $27, $28, $29, $22, $2A, $2B, $00, $00, $2C, $2D, $00, $00, $00, $00 
	db $00, $00, $00, $2E, $2F, $00, $21, $30, $30, $31, $00, $00, $32, $33, $00, $00, $00, $00 
	db $00, $00, $00, $34, $35, $00, $36, $30, $30, $31, $37, $00, $38, $39, $00, $3A, $00, $08 
	db $00, $00, $3B, $3C, $3D, $09, $3E, $3F, $40, $31, $00, $00, $41, $42, $00, $43, $00, $00 
	db $00, $00, $00, $44, $45, $00, $00, $00, $00, $46, $00, $47, $48, $49, $4A, $00, $00, $00 
	db $00, $00, $00, $4B, $4C, $00, $00, $4D, $00, $00, $4E, $4F, $50, $51, $52, $53, $00, $00 
	db $00, $00, $00, $54, $55, $00, $00, $00, $00, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $00 
	db $00, $5E, $00, $5F, $60, $00, $00, $00, $00, $61, $62, $63, $64, $65, $66, $67, $68, $00 
	db $00, $00, $00, $69, $6A, $00, $00, $6B, $00, $6C, $6D, $6E, $6F, $6F, $70, $71, $72, $00 
	db $00, $00, $00, $73, $74, $00, $00, $00, $00, $75, $76, $77, $78, $79, $7A, $7B, $00, $00 
	db $00, $00, $00, $7C, $7D, $00, $00, $00, $00, $7E, $7F, $80, $81, $82, $83, $84, $00, $00 
	db $85, $00, $00, $00, $00, $00, $86, $00, $00, $00, $87, $88, $89, $8A, $00, $00, $00, $00 
	db $8B, $00, $00, $8C, $00, $00, $00, $00, $8D, $00, $00, $00, $00, $00, $00, $00, $00, $8E 
	db $00, $8F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;5FC4
	INCBIN "build/gfx/PlanetSelect.rle"
;6347