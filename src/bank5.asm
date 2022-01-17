SECTION "bank 5 base", ROMX[$4000], BANK[5]
DrawTitleLetters: ;4000
	;called after c set below, b is also set before calling
	call LoadCharsetEnglish
.readchar ;4003
	ld a, [hl+]
	cp $24
	jp nz, .handlechar
	ld a, [hl+] ;if char was 24,
	or a
	jr z, .handlechar ;jump to 4015 if next was zero
	sub $31
	call LoadCharset ;else convert next 1-index ascii to 0-index table number
	jp .readchar
.handlechar ;4015
	call TitleTextHandleSpace ;otherwise, if it's a letter
	or a
	ret z ;if handled char was $00, return
	push hl
	push bc
	push af
	call TextDrawChar
	pop af
	pop bc
	pop hl
	sub $20
	ld e, a
	ld a, [$C27B]
	add a, e
	ld e, a
	ld a, [$C27C]
	adc a, $00
	ld d, a
	ld a, [de]
	add a, c
	ld c, a
	jp .readchar
	
HandleTitleText: ;4037
	;called with $7E44 or 7E52 in HL
	call LoadCharsetEnglish
	push hl
	push de
	ld b, $00
.readchar ;403E
	ld a, [hl+]
	cp $24 ;character $24 is a special case?
	jp nz, .handlechar
	ld a, [hl+]
	or a
	jr z, .handlechar ;to 4050
	sub $31 ;convert next 1-index ascii to 0-index table number
	call LoadCharset
	jp .readchar
.handlechar ;4050
	sub $20
	jr c, .skip ;less than 20, jump
	ld e, a
	ld a, [$C27B]
	add a, e
	ld e, a
	ld a, [$C27C]
	adc a, $00 ;add the read number - 20 to the second pointer (ascii to tile offset?)
	ld d, a
	ld a, [de] ;get a byte from the character width table
	add a, b
	ld b, a ;increment B with it
	jr .readchar ;403E
.skip
	srl b ;divide unsigned b by two
	ld a, c
	sub a, b ;difference between B and C
	ld c, a ;stored in C?
	pop de
	pop hl
	ret
	
TitleTextHandleSpace: ;406D
	cp $20
	ret nz ;handles spaces only
	push af
	push hl ;remember our spot
	push bc
	ld a, [$C27F]
	push af
	ld a, [$43E6] ;a middle pointer in the tables below
	ld e, a
.loop
	ld a, c
	add a, e
	ld c, a ;c += $43E6 value
.readchar1 ;407E
	ld a, [hl+] ;readchar
	cp $24
	jp nz, .handlechar1
	ld a, [hl+]
	or a
	jr z, .handlechar1
	sub $31
	call LoadCharset ;the usual here
	jp .readchar1
.handlechar1 ;4090
	or a ;next char wasn't a command
	jr z, .end ;if end of text (00), exit
	cp $20
	jr z, .loop ;if next char a space, go back
	ld a, c
	cp $9A
	jr nc, .largeC ;to 40E1 if c >= 9A
	pop af
	ld a, [$C27F] ;refresh this
	push af
	push hl
.readchar2
	ld a, [hl+]
	cp $24
	jp nz, .handlechar2
	ld a, [hl+]
	or a
	jr z, .handlechar2
	sub $31
	call LoadCharset
	jp .readchar2
.handlechar2
	or a
	jr z, .popend
	cp $20
	jr z, .popend ;if zero or $20, exit
	sub $20
	ld e, a
	ld a, [$C27B]
	add a, e
	ld e, a
	ld a, [$C27C]
	adc a, $00
	ld d, a
	ld a, [de]
	add a, c
	ld c, a
	cp $9A
	jr c, .readchar2
	pop hl
	pop af
	call LoadCharset
	dec hl
	jr .spexit ;to 40E3
.popend
	pop hl
.end
	pop af
	call LoadCharset
	pop bc
	pop hl
	pop af
	ret
.largeC ;40E1
	dec hl
	pop af
.spexit ;40E3
	ld a, b
	add a, $0D
	ld b, a
	ld a, [$CB1C]
	ld c, a
	add sp, $06 ;pop!
.readchar3
	ld a, [hl+]
	cp $24
	jp nz, .leave
	ld a, [hl+]
	or a
	jr z, .leave
	sub $31
	call LoadCharset
	jp .readchar3
.leave
	ret
	
LoadCharsetEnglish: ;4100
	xor a
LoadCharset: ;4101
	;passed a is what charset to use
	push hl
	ld [wLoadedCharset], a
	rlca
	ld l, a
	rlca
	add a, l
	add a, LOW(CharsetPointerTable)
	ld l, a
	ld a, HIGH(CharsetPointerTable)
	adc a, $00 ;HL = 418E + a*6
	ld h, a
	ld a, [hl+]
	ld [$C279], a
	ld a, [hl+]
	ld [$C27A], a ;gfx pointer
	ld a, [hl+]
	ld [$C27B], a
	ld a, [hl+]
	ld [$C27C], a ;second pointer
	ld a, [hl+]
	ld [$C27D], a
	ld a, [hl+]
	ld [$C27E], a ;third pointer
	pop hl
	ret
	
TextDrawChar: ;412B
	sub $20
	ret z ;get tile offset? make sure it's not space
	cp $03
	ret z ;make sure it's not special char
	ld l, a
	ld a, [$C27D]
	add a, l
	ld l, a
	ld a, [$C27E] ;third pointer
	adc a, $00
	ld h, a ;char + pointer = hl
	ld a, [hl] ;grab from table
	ld h, $00
	rla
	rl h
	rla
	rl h ;a*4
	ld e, a
	ld d, h
	rla
	rl h
	ld l, a ;a*8
	add hl, de ;a*12?
	ld a, [$C279]
	add a, l
	ld l, a
	ld a, [$C27A]
	adc a, h
	ld h, a ;add a*12 to first pointer
	ld a, c
	and $07
	add a, $08 ;mask lower three bits of c, set 4th
	ld e, a
	ld a, $00
	adc a, $00
	ld d, a
	ld a, [de] ;grab value from table at the start of rom (vertical lines?)
	ldh [$FF9A], a ;store it to FF9A
	cpl
	ldh [$FF99], a ;and store the invert to FF99
	ld e, l
	ld d, h ;store a*12 to DE
	ld a, c
	and $F8 ;the rest of the bits in the passed c
	rrca
	rrca
	rrca ;right-align the bits
	add a, $CC
	ld h, a
	ld a, b
	add a, $E0
	ld l, a ;address $CCE0 + high passed bits of C and passed B
	ld a, h
	cp $DF ;if high passed c bits < $13, skip
	jr c, .skip
	cp $E0
	ld a, $00
	ldh [$FF99], a
	jr c, .skip
	ldh [$FF9A], a ;clear these based on math
.skip
	ld a, c
	and $07
	ld c, a ;mask the low 3 bits of C
	call CallDrawTextIntoWram
	ret
	
CharsetPointerTable: ;418e - charset pointers. first is offset to 1bpp graphic in bank F, second is offset to $C0 size table of letter widths in this bank, third is offset to $C2 sized character->tile map, also in this bank.
	dw CharsetGFXEnglish, .EnglishWidths, .EnglishTiles
;4194
	dw CharsetGFXHiragana, .HiraganaWidths, .HiraganaTiles
;419A
	dw CharsetGFXKanji, .KanjiWidths, .KanjiTiles

.EnglishTiles ;41A0 $C2 sized byte table, maps the letter to the graphics tile. (p3)
	db $00, $40, $00, $00, $00, $00, $00, $42, $00, $00, $44, $00, $3F, $41, $3E, $43 
	db $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $00, $00, $00, $00, $00, $00 
	db $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E 
	db $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $00, $00, $00, $00, $00 
	db $00, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28 
	db $29, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32, $33, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E 
	db $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E 
	db $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E 
	db $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E 
	db $6D, $6D
	
.HiraganaTiles ;4262 $C2 sized byte table, maps the letter to the graphics tile. (p3)
	db $00, $00, $00, $00, $00, $7F, $80, $81, $82, $83, $84, $85, $78, $00, $00, $90 
	db $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $86, $87, $78, $78, $00, $00 
	db $8F, $3D, $3E, $3F, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B 
	db $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $88, $89, $8A, $8B, $00 
	db $00, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $3A, $3B 
	db $3C, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $8C, $8D, $8E, $78, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09 
	db $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19 
	db $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29 
	db $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39 
	db $28, $28

.KanjiTiles ;4324 $C2 sized byte table, maps the letter to the graphics tile. (p3)
	db $00, $00, $00, $00, $00, $6D, $6E, $6F, $70, $71, $72, $73, $4F, $00, $00, $7D 
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $74, $75, $4F, $4F, $00, $00 
	db $90, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18 
	db $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $76, $77, $78, $79, $77 
	db $00, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32 
	db $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $7A, $7B, $7C, $77, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $3E, $3F, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C 
	db $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C 
	db $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C 
	db $4F, $4F

.EnglishWidths ;43E6 $C0 sized byte table, character widths. (p2)
	db $03, $04, $00, $FF, $00, $00, $00, $03, $00, $00, $09, $00, $03, $07, $03, $08 
	db $06, $04, $06, $06, $05, $06, $06, $06, $06, $06, $00, $00, $00, $00, $00, $00 
	db $00, $08, $08, $08, $09, $08, $07, $08, $08, $04, $04, $08, $06, $08, $09, $09 
	db $07, $09, $08, $07, $07, $07, $08, $08, $08, $08, $08, $00, $00, $00, $00, $00 
	db $00, $05, $06, $04, $05, $05, $04, $05, $06, $03, $04, $07, $03, $09, $06, $05 
	db $06, $05, $05, $05, $04, $06, $06, $08, $05, $06, $05, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $07, $06, $06, $06, $06, $06, $06, $06, $05, $06 
	db $07, $08, $07, $08, $08, $08, $08, $08, $07, $08, $07, $08, $07, $08, $08, $07 
	db $08, $08, $07, $08, $06, $08, $08, $08, $08, $07, $06, $08, $08, $08, $08, $08 
	db $07, $08, $07, $08, $08, $08, $07, $07, $06, $08, $06, $07, $08, $08, $04, $04

.HiraganaWidths ;44A6 $C0 sized byte table, character widths. (p2)
	db $03, $00, $00, $FF, $00, $08, $08, $08, $08, $08, $08, $07, $00, $00, $00, $08 
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $00, $00, $00, $00 
	db $08, $08, $08, $08, $08, $08, $09, $09, $06, $09, $08, $09, $08, $08, $09, $08 
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $08, $08, $07, $08, $00 
	db $00, $09, $09, $09, $08, $09, $09, $09, $09, $08, $09, $09, $04, $04, $05, $04 
	db $04, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $08, $08, $08, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $07, $07, $07, $07, $07, $08, $07, $07, $06, $06 
	db $07, $08, $08, $07, $07, $08, $08, $07, $05, $08, $07, $07, $06, $08, $08, $08 
	db $08, $07, $08, $08, $07, $08, $07, $08, $08, $08, $08, $08, $08, $08, $08, $07 
	db $08, $08, $08, $07, $08, $08, $08, $07, $06, $08, $08, $08, $08, $08, $04, $04

.KanjiWidths ;4566 $C0 sized byte table, character widths. (p2)
	db $03, $00, $00, $FF, $00, $08, $08, $08, $07, $07, $07, $08, $00, $00, $00, $05 
	db $09, $09, $09, $08, $09, $09, $09, $09, $09, $08, $08, $09, $00, $00, $00, $00 
	db $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09 
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $08, $08, $08, $08, $00 
	db $00, $08, $09, $07, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $04, $09 
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $08, $08, $08, $09, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $09, $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $08, $09, $09, $09 
	db $08, $09, $08, $08, $08, $08, $08, $08, $08, $08, $06, $08, $08, $08, $08, $08 
	db $04, $08, $04, $08, $08, $07, $07, $07, $08, $07, $08, $08, $08, $07, $08, $07

;4626, another table?

SECTION "5:46E6", ROMX[$46E6], BANK[$5]
BriefingPagePointers: ;46E6 table of pointers for Briefing, 1C entries
	dw BriefingCommand0 ;won't be called, just backs the read up one spot (to this again)
	dw BriefingCommand1 ;copies $A values and then wipes $F values from specified entity
	dw BriefingCommand2 ;writes a word into the entity data specified (points into bank 8)
	dw BriefingCommand3 ;byte is how many updates to loop/wait
	dw BriefingCommand4 ;load entity pointer into DE, advance it two places
	dw BriefingCommand5 ;writes a dialogue page to the screen
	dw BLANK_POINTER ;6 unused
	dw BLANK_POINTER ;7 unused
	dw BriefingCommand8 ;load the next two bytes (modified) into CB1B/CB1C
	dw BLANK_POINTER ;9 unused
	dw BLANK_POINTER ;A unused
	dw BLANK_POINTER ;B unused
	dw BriefingCommandC ;animates the briefing screen
	dw BriefingCommandD ;writes eight bytes to the entity table
	dw BriefingCommandE ;sets byte before specified entity to 0
	dw BriefingCommandF ;draw "static" to the screen
	dw BLANK_POINTER ;10 unused
	dw BriefingCommand11 ;play sound effect
	dw BriefingCommand12 ;play wave
	dw BriefingCommand13 ;play noise
	dw BriefingCommand14 ;loads image from bank D using the pointer following
	dw BriefingCommand15 ;sets top bit in byte before specified entity?
	dw BriefingCommand16 ;wipes the top half of the display?
	dw BriefingCommand17 ;overwrites first specified entity with second entity data?
	dw BriefingCommand18 ;clear C338
	dw BriefingCommand19 ;set C338
	dw BriefingCommand1A ;same as command D, but with two bytes
	dw BriefingCommand1B ;same as command D, but with four bytes
	dw BriefingCommand1C ;plays the next byte track
	
BriefingCommand1C: ;4720
	ld a, [hl+]
	ld [wQueueMusic], a ;load next byte into C108
	scf
	ret

BriefingCommand18: ;4726
	xor a
	ld [$C338], a ;load 0 into C338
	scf
	ret

BriefingCommand19: ;472C
	ld a, $01
	ld [$C338], a ;load 1 into C338
	scf
	ret

BriefingCommand17: ;4733
	;overwrites six bytes in first object ID with second ID's data
	ld a, [hl+]
	push hl ;grab next byte, save position
	call CallPointToEntityEntry
	ld e, l
	ld d, h ;save pointer to DE
	pop hl
	ld a, [hl+]
	push hl ;read next byte
	call CallPointToEntityEntry
	REPT 6 ;is this a bug? seems like intent here is to copy position, but doesn't this start with model ID?
	ld a, [hl+] ;read byte from 2nd entity
	ld [de], a ;write it to 1st entity
	inc de
	ENDR
	pop hl
	scf ;set clear
	ret

BriefingCommand16: ;4755
	push hl
	ld hl, $9260 ;start of presentation screen
	ld bc, $0168
	ld e, $FF
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, e
	ld [hl+], a ;write FF
	inc l
	ld [hl+], a
	inc hl
	dec bc
	ld a, b
	or c
	jp nz, .statloop
	pop hl
	scf
	ret

BriefingCommand15: ;4772
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	dec hl
	set 7, [hl] ;set the top bit in byte $19 in the entity before specified
	pop hl
	scf
	ret

BriefingCommand14: ;477D
	push hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load pointer
	ld de, $9260 ;position
	ld bc, $02D0
	call CallCopyBriefImage ;loads image
	pop hl
	inc hl
	inc hl
	scf
	ret

BriefingCommand11: ;478F
	ld a, [hl+]
	ld [$C100], a ;load next byte into C100
	scf
	ret
	
BriefingCommand12: ;4795
	ld a, [hl+]
	ld [$C110], a ;load next byte into C110
	scf
	ret
	
BriefingCommand13: ;479B
	ld a, [hl+]
	ld [$C118], a ;load next byte into C118
	scf
	ret

BriefingCommandF: ;47A1
	push hl
	ld a, %11001100 ;static pattern
	ld h, $D0
	ld b, $0A
.loop
	ld c, $48
	ld l, $00 ;D000
.innerloop
	ld [hl+], a
	rrca ;shift right one
	cpl ;invert
	dec c
	jr nz, .innerloop
	inc h
	dec b
	jr nz, .loop
	pop hl
	xor a ;carry not set!
	ret

BriefingCommandE: ;47B9
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	dec hl
	xor a
	ld [hl+], a ;write 0 to byte $19 of the entity preceding the specified one
	pop hl
	scf
	ret

BriefingCommand2: ;47C4
	ld a, [hl+] ;read a byte
	ld e, l
	ld d, h ;save place in DE
	call CallPointToEntityEntry
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance forward 9 bytes in entity data
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a ;write the next word into the entity data (values $9 and $A?)
	inc de
	ld l, e
	ld h, d ;restore and advance
	scf ;carry set
	ret

BriefingCommandD: ;47DC
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	ld e, l
	ld d, h
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;get entity pointer in DE and advance it by $0D
	pop hl
	ld b, $08
.loop
	ld a, [hl+] ;write the next eight bytes to entity table
	ld [de], a
	inc de
	dec b
	jp nz, .loop
	scf
	ret
	
BriefingCommand1B: ;47F7
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	ld e, l
	ld d, h
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;get pointer into DE, advance $0D
	pop hl
	ld b, $04
.loop
	ld a, [hl+]
	ld [de], a ;write four bytes
	inc de
	dec b
	jp nz, .loop
	scf
	ret

BriefingCommand1A: ;4812
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	ld e, l
	ld d, h
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;DE = pointer + $0D
	pop hl
	ld b, $02
.loop
	ld a, [hl+]
	ld [de], a ;write two bytes
	inc de
	dec b
	jp nz, .loop
	scf
	ret

BriefingCommand1: ;482D
	call CopyTenValuesToCB53 ;next byte is entry
	scf
	ret
	
BriefingCommandC: ;4832
	push hl
	call CallUpdateBriefScreenModels ;explanatory
	pop hl
	scf
	ret

BriefingCommand0: ;4839, page command 0
	dec hl ;loop, oops
	ret
	
BriefingCommand4: ;483B
	ld a, [hl+]
	push hl
	call CallPointToEntityEntry
	ld e, l
	ld d, h
	inc de
	inc de ;load pointer into DE, advance it two places
	pop hl
	xor a
	ret

BriefingCommand3: ;4847
	ld a, [$CB1E]
	ld e, a
	ld a, [$CB1F]
	ld d, a ;load word into DE
	or e
	jr z, .zero ;if zero, to 4862
	ld a, d
	inc a
	jr z, .negative ;to 486C
	dec de ;otherwise decrement the counter
	ld a, e
	ld [$CB1E], a
	ld a, d
	ld [$CB1F], a
	dec hl ;go back a position AKA loop until zero
	xor a ;no clear flag
	ret
.zero ;4862
	cpl
	ld [$CB1E], a ;load FF into the values
	ld [$CB1F], a
	inc hl ;advance
	scf ;clear flag
	ret
.negative ;486C
	ld a, [hl-]
	ld [$CB1E], a ;load byte into the counter
	xor a
	ld [$CB1F], a
	scf ;clear flag
	ret
	
BriefingCommand5: ;4876
	push hl
	ld a, [wUpdateCounter] ;save
	push af
	ld a, [wTextBubbleX]
	ld c, a
	ld b, $04
	call CallDrawBriefSpeechPage
	jr nc, .skip
	ld a, $01
	ld [$CB4E], a
.skip
	pop af
	ld [wUpdateCounter], a ;restore
	pop hl
.findzero
	ld a, [hl+]
	or a
	jr nz, .findzero
	scf
	ret
	
BriefingCommand8: ;4896
	ld a, [hl+]
	rlca
	rlca
	rlca
	add a, $04
	ld [wTextBubbleX], a ;load first byte into CB1C
	ld a, [hl+]
	rlca
	rlca
	rlca
	ld [wTextBubbleHeight], a ;load second byte into CB1B
	scf
	ret

PlayBrief: ;48A8
	push hl ;save pointer from top of bank C
	call ClearAllEntities
	pop hl ;restore pointer
	ld a, $FF
	ld [$CB1E], a
	ld [$CB1F], a
	xor a
	ld [$C338], a
	ld [$CB4E], a
.returnpoint
	jp c, .noskip
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	bit 3, a ;start
	jr z, .nostart
	push hl ;save pointer
	scf ;set clear flag, bring up exit prompt
	call CallHandleBriefExitPrompt
	pop hl ;restore pointer
	ret c ;if selected exit, then return
.nostart
	push hl ;save pointer
	call AnimateBriefScreen
	call CallBriefDrawScreen
	pop hl ;restore pointer
.noskip ;48DD
	ld a, [$CB4E]
	or a
	ret nz
	ld a, [hl+] ;load a byte from the brief sequence
	or a
	ret z ;if sequence byte is zero, exit
	sla a ;multiply by two to get word offset
	add a, LOW(BriefingPagePointers)
	ld e, a
	ld a, HIGH(BriefingPagePointers)
	adc a, $00
	ld d, a ;table at 46E6
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a ;read pointer into BC
	ld de, .returnpoint
	push de ;push return point
	push bc ;push new address
	ret ;jump to it
	
CopyTenValuesToCB53: ;48FA called by a brief command? hl is read position
	ld a, [hl+] ;next value is entity index
	or a
	ld de, $CB53
	jr z, .zero ;if value was zero, skip
	ld b, a
.advanceloop ;advance $CB53 by $19 times read value
	ld a, e
	add a, ENTITY_SIZE
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, .advanceloop
.zero
	ld b, $0A
.writeloop
	ld a, [hl+] ;write the next $A values into entity array
	ld [de], a
	inc de
	dec b
	jr nz, .writeloop
	ld b, $0F
	xor a
.wipeloop
	ld [de], a ;clear out the next $F values
	inc de
	dec b
	jr nz, .wipeloop
	ret

AnimateBriefScreen: ;491E
	ld a, [wAnimDisable]
	or a
	jr nz, .skipinc
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
.skipinc
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $4F
	ldh [$FFF1], a
	ld a, $50
	ldh [$FFED], a
	ld a, $00
	ld [wPitchLurch], a
	ld [wPitchAngle], a
	ld a, $E8
	ldh [hRenderXOffLo], a
	cp $80
	ld a, $00
	adc a, $FF
	ldh [hRenderXOffHi], a
	ld hl, wEntityTable
	ld b, $04 ;only check four entities?
.loop
	ld a, [hl+] ;model
	or a
	jr z, .endskip
	push bc ;save counter
	push hl ;save pos
	ld c, a
	xor a ;reset exploding value if we're gonna jump
	bit 7, c ;if top bit of model id not set, skip
	jr z, .shortskip
	res 7, c
	push hl
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;DE is z orientation?
	ld a, [de]
	add a, $05
	ld [de], a ;increment by 5?
	ld a, l
	add a, $15
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;forming byte?
	ld a, [hl]
	ld b, a
	srl a
	ld [$C33F], a ;forming/exploding progress?
	ld a, b
	add a, $04
	ld [hl], a ;more
	pop hl
	jr nz, .skipstore
	dec hl
	xor a
	ld [hl+], a ;zero the model if it's sploded
.skipstore
	ld a, c ;clear top bit for model ID
.shortskip
	ld [wModelExploding], a
	ld a, [hl+]
	ldh [$FFDF], a ;entity x
	ld a, [hl+]
	ldh [$FFE0], a ;entity y
	ld a, [hl+]
	ldh [$FFDB], a ;entity z
	ld a, [hl+]
	bit 7, a
	jp nz, .skipcall ;if top bit of rotation set, don't draw the model
	ldh [$FFDC], a ;entity xrot
	ld a, [hl+]
	ldh [$FFDD], a ;entity yrot
	ld a, [hl+]
	ldh [$FFDE], a ;entity zrot
	ld a, [hl+]
	ldh [$FFA5], a ;x speed?
	xor a
	ldh [$FFA4], a ;0
	ld a, [hl+]
	cpl
	inc a
	ldh [$FFA1], a ;y speed, negated?
	ld a, [hl+]
	ldh [$FFA3], a ;z speed?
	ld a, c ;restore model ID
	call CallDrawModel
.skipcall
	pop hl
	push hl
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [$C33E]
	or a
	jr nz, .skiptopops
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	or c
	jr z, .skiptopops
	pop hl
	push hl
	call JumpIntoBank8 ;BC is the target address
.skiptopops
	pop hl
	pop bc
.endskip
	ld a, l
	add a, $18
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .loop
	ret
	
GetEntityDirection: ;49DD
	add a, $10
	swap a
	and $0E
	add a, LOW(RadarTextDirectionTable)
	ld l, a
	ld a, HIGH(RadarTextDirectionTable) ;table at 7BEB
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret


Briefing1Sequence: ;49EF
	bcomSetBubbleSize 2, 4
	bcomText "$H私か<LP><LP>$Kﾞ$Hこのわくせいの司会官た<LP><LP>$Kﾞ<NL>", \
	         "$H今から、し<LP><LP><LP>$Kﾞ$Hょうきょうをせつめいしよう。"
	bcomSetBubbleSize 1, 4
	bcomText "$Kハﾟワークリスタル$Hをはこふ<LP><LP><LP>$Kﾞ$Hゆそう船か<LP><LP>$Kﾞ<NL>", \
	         "$Hなにものかによってはかいされた。"
	bcomLookAtScreen
	bcomStatic 5
	bcomLoadImage BriefPlanetGFX1
	bcomLoadImage BriefPlanetGFX1
	bcomLoadModel 0, $3D, $FFE7, $1B58, $0078, $00, $80, $00
	bcomWait 1 ;wait
	bcomSetBubbleSize 2, 4
	bcomText "$Hこれは、ていさつえいせいか<LP><LP>$Kﾞ$Hとらえた<NL>", \
	         "ゆそう船さいこ<LP><LP>$Kﾞ$Hの$P映像$Hた<LP><LP>$Kﾞ$H・・・"
	bcomLookAtScreen
	bcomPlayMusic $26
	bcomSetEntityMovementXY 0, $00, $CE
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomWait $7D ;wait
	bcomExplodeEntity 0
	bcomPlayExplosionSound $02
	bcomWait $32 ;wait
	bcomWipeScreen ;wipe
	bcomWipeScreen
	bcomStatic 6
	bcomSetBubbleSize 4, 4
	bcomText "$Hゆそう船は<NL>",\
	         "$Kエリア$H７上$P空$Hて<LP><LP>$Kﾞ$Hはかいされ・・・・・"
	bcomSetBubbleSize 4, 4
	bcomText "$Hつんて<LP><LP>$Kﾞ$Hいた$Kハﾟワークリスタル$Hは<NL>", \
	         "地上におちてしまった。"
	bcomLoadModel 0, $0C, $0000, $0140, $0064, $00, $00, $00
	bcomWait 1 ;wait
	bcomPlayMusic $27
	bcomSetBubbleSize 5, 4
	bcomText "$H見たまえ<NL>", \
	         "これか<LP><LP>$Kﾞハﾟワークリスタル$Hた<LP><LP>$Kﾞ$P！"
	bcomSetEntityMovementXY 0, $03, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $1E ;wait
	bcomSetBubbleSize 0, 4
	bcomText "$H地上て<LP><LP>$Kﾞ$Hは$Kエネルキ<LP><LP>ﾞー$Hをしょうもうし<NL>", \
	         "とけてなくなってしまう$Kハﾟワークリスタル$H。"
	bcomLookAtScreen
	bcomWait $32 ;wait
	bcomSetBubbleSize 1, 4
	bcomText "$Kクリスタル$Hか<LP><LP>$Kﾞ$Hとけるまえに発見し<NL>",\
	         "この$Kニュークリアサイロ$Hへはこふ<LP><LP>$Kﾞ$Hのた<LP><LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomStatic 3
	bcomLoadModel 0, $18, $0000, $03E8, $007D, $00, $C0, $00
	bcomSetEntityMovementXYZ0 0, $00, $EC, $FE, $00
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomWait $3C ;wait
	bcomNullModel 0
	bcomStatic 3
	bcomSetBubbleSize 1, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hは任務にうつるまえに<NL>",\
	         "$Kレータ<LP><LP>ﾞー$P基$H地についてせつめいしよう。"
	bcomStatic 1 ;static
	bcomSetBubbleSize 2, 4
	bcomText "$P各$Kエリア$Hに１<LP><LP><LP>つつ<LP><LP><LP>$Kﾞ$Hつあり<NL>",\
	         "いろいろな$P情報$Hを与えてくれる$P場所$H、"
	bcomLoadModel 0, $03, $0000, $0384, $008C, $00, $00, $00
	bcomLoadModel 1, $54, $FF9C, $02BC, $008C, $00, $C0, $00
	bcomLoadModel 2, $54, $0064, $02BC, $008C, $00, $40, $00
	bcomWait 1 ;wait
	bcomSetBubbleSize 7, 3
	bcomText "<NL>",\
	         "$Hこれか<LP><LP>$Kﾞレータ<LP><LP>ﾞー$P基$H地た<LP><LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomWait $19 ;wait
	bcomSetEntityMovementXYZ0 0, $00, $D8, $FB, $00
	bcomSetEntityMovementXYZ0 1, $00, $D8, $FB, $00
	bcomSetEntityMovementXYZ0 2, $00, $D8, $FB, $00
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomWait $28 ;wait
	bcomNullModel 0 
	bcomNullModel 1 
	bcomNullModel 2
	bcomSetBubbleSize 2, 4
	bcomText "$P情報$Hのほかにもねんりょうや<NL>",\
	         "$Kミサイル$Hの$P補給$H、$Kリヘ<LP><LP><LP>ﾟアー$Hか出来る。"
	bcomLoadImage BriefEquipmentGFX
	bcomLoadImage BriefEquipmentGFX
	bcomSetBubbleSize 5, 4
	bcomText "$Hまた、これらの$P兵器$Hをえらひ<LP><LP>$Kﾞ<NL>",\
	         "$Hそうひ<LP><LP>$Kﾞ$Hするのもこの$P場所$Hた<LP><LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomWait $C8 ;wait
	bcomSetBubbleSize 1, 4
	bcomText "$Hこのわくせいには、なにものかか<LP><LP>$Kﾞ<NL>",\
	         "$Hひそんて<LP><LP>$Kﾞ$Hいるようた<LP><LP>$Kﾞ$H、きをつけたまえ$P！"
	bcomWait $32
	bcomEnd
	
Briefing2Sequence: ;4DC9
	bcomSetBubbleSize 4, 4
	bcomText "$Hついに$Kエイリアン$Hか<LP><LP>$Kﾞ<NL>", \
		"$H我々にこうけ<LP><LP>$Kﾞ$Hきをしかけてきた。"
	bcomStatic 4
	bcomLoadImage $457C
	bcomLoadImage $457C
	bcomLoadModel 0, $3D, $FF6A, $0320, $00FA, $00, $80, $00
	bcomWait 1
	bcomSetBubbleSize 5, 3
	bcomText1Line "$H見たまえ、これか<LP>ﾞその$P映像$Hた<LP><LP>ﾞ$P！"
	bcomLookAtScreen
	bcomSetEntityMovementXY 0, $00, $1E
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomWait $3E
	
	bcomLoadModel 1, $09, $0000, $0000, $0000, $00, $00, $00
	bcomCopyPosition 1, 0
	bcomSetEntityMovementXYZ0 1, $00, $00, $28, $00
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomSetEntityMovementXYZ0 0, $05, $1E, $01, $00
	bcomPlayInterfaceSound $14
	bcomWait $11
	
	bcomLoadModel 2, $09, $0000, $0000, $0000, $00, $00, $00
	bcomCopyPosition 2, 0
	bcomSetEntityMovementXYZ0 2, $00, $00, $28, $00
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomSetEntityMovementXYZ0 0, $0A, $19, $01, $00
	bcomPlayInterfaceSound $14
	bcomWait $0C
	
	bcomLoadModel 3, $09, $0000, $0000, $0000, $00, $00, $00
	bcomCopyPosition 3, 0
	bcomSetEntityMovementXYZ0 3, $00, $00, $28, $00
	bcomSetEntLogic 3, BriefingEntMoveOffsets
	bcomSetEntityMovementXYZ0 0, $14, $19, $01, $00
	bcomPlayInterfaceSound $14
	bcomWait $07
	
	bcomLoadModel 1, $09, $0000, $0000, $0000, $00, $00, $00
	bcomCopyPosition 1, 0
	bcomSetEntityMovementXYZ0 1, $00, $00, $28, $00
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomSetEntityMovementXYZ0 0, $19, $19, $01, $00
	bcomPlayInterfaceSound $14
	bcomWait $07
	
	bcomLoadModel 2, $09, $0000, $0000, $0000, $00, $00, $00
	bcomCopyPosition 2, 0
	bcomSetEntityMovementXYZ0 2, $00, $00, $28, $00
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomSetEntityMovementXYZ0 0, $1E, $14, $0A, $00
	bcomPlayInterfaceSound $14
	bcomWait $20
	
	bcomWipeScreen
	bcomWipeScreen
	bcomNullModel 0 
	bcomNullModel 1 
	bcomNullModel 2 
	bcomNullModel 3
	bcomStatic 5
	bcomSetBubbleSize 2, 4
	bcomText "$Kエイリアン$Hは５つの時$P限$Kハﾞクタ<LP>ﾞン$Hを<NL>", \
	"$Kテタムス$H２に$Kセット$Hしたらしい。"
	bcomLoadModel 0, $12, $0000, $02BC, $0078, $00, $00, $00
	bcomWait $01
	
	bcomSetBubbleSize 4, 3
	bcomText1Line "$Hこれか<LP><LP>$Kﾞ$H、その時$P限$Kハﾞクタ<LP>ﾞン$Hた<LP><LP>ﾞ。"
	bcomLookAtScreen
	bcomSetEntityMovementXY 0, $05, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $66
	
	bcomSetBubbleSize 2, 4
	bcomText "$H今回の任務は、時$P限$Kハﾞクタ<LP><LP>ﾞン$Hを<NL>", \
	"$P全$Hてはかいすることにある、しかし・・・"
	bcomSetBubbleSize 6, 4
	bcomText "$Hこれは$Kミサイル$Hて<LP><LP>ﾞなけれは<LP><LP>ﾞ<NL>", \
	"はかいて<LP><LP>ﾞきない。"
	bcomLoadModel 1, $0F, $0000, $0000, $0050, $00, $00, $00
	bcomSetEntityMovementXYZ0 1, $00, $28, $28, $00
	bcomSetEntLogic 1, BriefingEntRotate
	bcomPlayExplosionSound 5
	bcomWait $0C
	
	bcomExplodeEntity 0
	bcomNullModel 1
	bcomPlayExplosionSound 2
	bcomWait $20
	
	bcomNullModel 0
	bcomSetBubbleSize 7, 4
	bcomText "$Kミサイル$Hを発$P射$Hするには<NL>", \
	"$Kロックオン$Hか<LP><LP>$Kﾞ$Hひつようた<LP><LP>$Kﾞ$H。"
	bcomLookAtScreen
	bcomStatic 4
	bcomLoadModel 0, $03, $0000, $01F4, $0078, $00, $00, $00
	bcomWait $01
	bcomSetBubbleSize 5, 3
	bcomText1Line "$Kレータﾞー$P基$H地て<LP><LP>$Kﾞ$H、そうひ<LP><LP>$Kﾞ$Hせよ$P！"
	bcomNullModel 0
	bcomWait $01
	
	bcomLoadImage $484C 
	bcomLoadImage $484C
	bcomLookAtScreen
	bcomWait $C8
	
	bcomWipeScreen
	bcomWipeScreen
	bcomStatic 4
	bcomSetBubbleSize 7, 3
	bcomText "$Hもう時間はない、<NL>", \
	"いそけ<LP><LP>$Kﾞ$P！"
	bcomWait $32
	bcomEnd

Briefing3Sequence: ;50A0
	bcomStatic 5
	bcomSetBubbleSize 3, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hは、$Kエイリアン$Hたちの<NL>", \
	"新$P型兵器$Hについてせつめいしよう。"
	bcomWait $01
	bcomLoadImage $4DEC
	bcomLoadImage $4DEC
	bcomDisableAnimations
	bcomLoadModel 0, $2E, $003C, $0258, $0050, $00, $40, $00
	bcomLoadModel 1, $2E, $FFBF, $0258, $0050, $00, $80, $00
	bcomLoadModel 2, $2E, $FFBF, $0258, $00A0, $C0, $00, $00
	bcomWait $01
	bcomSetBubbleSize 7, 4
	bcomText "$Hこれか<LP><LP>$Kﾞ$Hその新$P型兵器<NL>", \
	"$Kヒューマノイト<LP><LP>ﾞタンク$Hた<LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomWait $16
	bcomWipeScreen 
	bcomWipeScreen
	bcomNullModel 0
	bcomNullModel 2
	bcomSetEntityMovementXYZ0 1, $05, $EC, $01, $00
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomWait $0E
	bcomSetEntityMovementXY 1, $4, $0
	bcomSetEntLogic 1, EntityLogicMiniRadar
	bcomWait $2A
	bcomSetBubbleSize 5, 4
	bcomText "$Kエイリアン$Hたちはこの$Kタンク$Hを<NL>", \
	"２たい$P送$Hりこんて<LP><LP>$Kﾞ$Hきたようた<LP><LP>$Kﾞ$H。"
	bcomLookAtScreen
	bcomEnableAnimations
	bcomWait $3C
	bcomDisableAnimations
	bcomSetEntityMovementXY 1, $FB, $EC
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomWait $08
	bcomSetEntLogic 1, $0000
	bcomWait $01
	bcomLoadModel 0, $01, $0050, $03E8, $0096, $00, $00, $00
	bcomLoadModel 2, $0D, $FFC4, $0578, $00A0, $00, $00, $00
	bcomWait $01
	bcomSetBubbleSize 3, 4
	bcomText "$Hそのそうこうはかたく<NL>", \
	"我々の$Kレーサ<LP><LP>ﾞー$Hをも、うけつけない。"
	bcomEnableAnimations
	bcomSetEntityMovementXYZ0 1, $FD, $05, $0F, 00
	bcomSetEntLogic 1, BriefingEntRotate
	bcomWait $18
	bcomExplodeEntity 0
	bcomPlayExplosionSound $02
	bcomWait $17
	bcomExplodeEntity 2
	bcomPlayExplosionSound $02
	bcomWait $07
	bcomSetEntityMovementXYZ0 1, $09, $C4, $FF, $00
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomDisableAnimations
	bcomNullModel 0
	bcomWait $0C
	bcomNullModel 2
	bcomSetEntityMovementXY 1, $0A, $00
	bcomSetEntLogic 1, EntityLogicMiniRadar
	bcomWait $01
	bcomSetBubbleSize 2, 4
	bcomText "$Hしかし、$Kミサイル$Hを４発$Kヒット$Hさせれは<LP><LP>$Kﾞ<NL>", \
	"$Hはかい出来る。"
	bcomLookAtScreen
	bcomLoadModel 0, $0F, $0000, $FFFB, $0050, $00, $00, $00
	bcomSetEntityMovementXY 0, $00, $28
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomPlayExplosionSound $05
	bcomWait $07
	bcomLoadModel 2, $0F, $0000, $FFFB, $0050, $00, $00, $00
	bcomSetEntityMovementXY 2, $00, $28
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomPlayExplosionSound $05
	bcomWait $07
	bcomExplodeEntity 0
	bcomPlayExplosionSound $03
	bcomWait $07
	bcomExplodeEntity 2
	bcomPlayExplosionSound $03
	bcomWait $0C
	bcomLoadModel 0, $0F, $0000, $FFFB, $0050, $00, $00, $00
	bcomSetEntityMovementXY 0, $00, $28
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomPlayExplosionSound $05
	bcomWait $05
	bcomLoadModel 2, $0F, $0000, $FFFB, $0050, $00, $00, $00
	bcomSetEntityMovementXY 2, $00, $28
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomPlayExplosionSound $05
	bcomWait $09
	bcomExplodeEntity 00
	bcomPlayExplosionSound $03
	bcomWait $05
	bcomExplodeEntity 1
	bcomExplodeEntity 2
	bcomPlayExplosionSound $03
	bcomWait $20
	bcomNullModel 0
	bcomNullModel 1
	bcomNullModel 2
	bcomWait $01
	bcomSetBubbleSize 7, 4
	bcomText "$Kエイリアン$Hたちのねらいは<NL>", \
	"$Kレータ<LP><LP>ﾞー$P基$H地た<LP><LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomStatic 5
	bcomWait $01
	bcomLoadImage $4B1C 
	bcomLoadImage $4B1C
	bcomSetBubbleSize 5, 4
	bcomText "$Kタンク$Hのこうけ<LP><LP>$Kﾞ$Hきから<NL>", \
	"これらの$Kレータ<LP><LP>ﾞー$P基$H地を$P守$Hれ。"
	bcomSetBubbleSize $B, 3
	bcomText  "<NL>", \
	"$H成功を祈る・・・・"
	bcomWait $32
	bcomEnd

Briefing6Sequence: ;535A
	bcomStatic 1
	bcomLoadModel 0, $27, $0000, $0190, $0064, $00, $30, $00
	bcomWait $1
	bcomSetBubbleSize 1, 4
	bcomText "$Hこれか<LP><LP>$Kﾞ$H４$P本$Hの$Kリアクターロット<LP><LP>ﾞ$Hをはこふ<LP><LP><LP>$Kﾞ<NL>", \
	"$H我々の$Kトラック$Hた<LP><LP>$Kﾞ$H。"
	bcomSetEntityMovementXY 0, $05, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $25
	bcomSetEntityMovementXYZ0 0, $0f, $14, $0f, $00
	bcomSetEntLogic 0, BriefingEntRotate
	bcomWait $73
	bcomNullModel 0
	bcomStatic 6
	bcomSetBubbleSize 1, 4
	bcomText "$H今回の任務は、この４た<LP><LP>$Kﾞ$Hいの$Kトラック$Hを<NL>", \
	"$Kサイロ$Hまて<LP><LP>$Kﾞ$P守$Hることにある$P！"
	bcomWait $01
	bcomLoadImage $50bc
	bcomLoadImage $50bc
	bcomSetBubbleSize 2, 4
	bcomText "$Hこれは$Kコース$P図$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$Kトラック$Hはし<LP><LP><LP>$Kﾞ$Hと<LP><LP>$Kﾞ$Hうそうし<LP><LP><LP>$Kﾞ$Hゅうた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H・・・・<NL>"
	bcomSetBubbleSize 3, 4
	bcomText "$P安全$Hのため、君か<LP><LP>$Kﾞ$P近$Hくにいないと<NL>", \
	"すすまないように$Kセット$Hしてある。"
	bcomLookAtScreen
	bcomWait $3c
	bcomWipeScreen
	bcomWipeScreen
	bcomStatic 4
	bcomSetBubbleSize 1, 4
	bcomText "$Hところて<LP><LP>$Kﾞ$H、$Kサイロ$Hからもれた放$P射能$Hは<NL>", \
	"わくせいの$P虫$Hを、$P巨$H大$P化$Hさせてしまった。"
	bcomLoadModel 0, $1d, $006e, $14b4, $0064, $0, $88, $0
	db $d, 0, $ff, $ce, 0, 0, 0, 0, 0, $e8 ;first two bytes are for movement?
	bcomSetEntLogic 0, BreifingEntBounce
	bcomWait $6c
	bcomSetEntLogic 0, $0
	bcomWait $1e
	bcomSetBubbleSize 2, 4
	bcomText "$Hその$P中$Hて<LP><LP>$Kﾞ$Hも、この$Kインセクト$Hは<NL>", \
	"$Kトラック$Hをおそうきけんなこん$P虫$Hた<LP><LP>$Kﾞ$P！"
	bcomLookAtScreen
	bcomSetEntityMovementXY 0, $f6, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $32
	db $d, 0, 0, 0, 0, 0, 0, 0, 0, $e8 ;the e8 sets it at base of its jump instead of falling
	bcomSetEntLogic 0, BreifingEntBounce
	bcomWait $3d
	bcomSetEntityMovementXY 0, $f6, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetBubbleSize 4, 4
	bcomText "$Hこの$Kインセクト$Hをたおすには<NL>", \
	"$Kレーサ<LP><LP>ﾞー$Hによってうこ<LP><LP>$Kﾞ$Hきをとめ、"
	bcomSetBubbleSize 2, 4
	bcomText "$P完全$Hにとまった時に<NL>", \
	"$Kミサイル$Hによってはかいするしかない。"
	bcomSetBubbleSize 2, 4
	bcomText "$Hしかし、くれく$Kﾞ$Hれも$Kトラック$Hをうつことの<NL>", \
	"ないよう、きをつけたまえ。"
	db $d, 0, $f6, $f1, 0, 0, 0, 0, 0, $e8 
	bcomSetEntLogic 0, BreifingEntBounce
	bcomWait $32
	bcomEnd
	
Briefing7Sequence: ;5624
	bcomStatic 1
	bcomLoadModel 0, $07, $0000, $01f4, $005a, $00, $00, $00
	bcomWait $01
	bcomSetBubbleSize 4, 4
	bcomText "$H見たまえ、これか<LP><LP>$Kﾞ$P敵$Hの新$P型兵器<NL>", \
	"$Kスーハﾟーク<LP><LP>ﾞライタ<LP><LP>ﾞー$Hた<LP><LP>$Kﾞ$H。"
	bcomSetEntityMovementXY 0, $03, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $14
	bcomPlayGeneralSound $04
	bcomWait $28
	bcomPlayGeneralSound $04
	bcomSetBubbleSize 1, 4
	bcomText "$Kエイリアン$Hたちは、４きの$Kク<LP><LP>ﾞライタ<LP><LP>ﾞー$Hを<NL>", \
	"$P送$Hりこんて<LP><LP>$Kﾞ$Hきた。"
	bcomLookAtScreen
	bcomNullModel 0
	bcomStatic 3
	bcomWait $01
	bcomLoadImage $538c
	bcomLoadImage $538c
	bcomSetBubbleSize 7, 3
	bcomText1Line "$Hこれはその時の$P映像$Hた<LP><LP>$Kﾞ$H。"
	bcomSetBubbleSize 0, 4
	bcomText "$Hはやく$Kリアクターロット<LP><LP>ﾞ$Hをとりかえさないと<NL>", \
	"$Kサイロ$Hはは<LP><LP>$Kﾞ$Hくはつしてしまう$P！"
	bcomWipeScreen
	bcomWipeScreen
	bcomStatic 3
	bcomLoadModel 0, $07, $ff9c, $012c, $005a, $00, $0a, $00
	bcomLoadModel 1, $10, $ff9c, $012c, $0096, $00, $0a, $00
	bcomSetBubbleSize 2, 4
	bcomText "$Hこれをたおすには、我々も$P空$Hをとひ<LP><LP>$Kﾞ<NL>", \
	"レーサ<LP><LP>ﾞー$Hなと<LP><LP>$Kﾞ$Hて<LP><LP>$Kﾞ$Hはかいするしかない。"
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 0, $02, $28
	bcomSetEntityMovementXY 1, $02, $28
	bcomWait $0a
	bcomPlayGeneralSound $04
	bcomWait $05
	bcomSetEntityMovementXY 0, $05, $0a
	bcomSetEntityMovementXY 1, $05, $0a
	bcomSetEntLogic 0, MoveBriefingEntForward
	bcomSetEntLogic 1, MoveBriefingEntForward
	bcomWait $1e
	bcomPlayGeneralSound $04
	bcomWait $0a
	bcomPlayGeneralSound $04
	bcomWait $28
	bcomPlayGeneralSound $04
	bcomWait $1e
	bcomPlayGeneralSound $04
	bcomWait $0d
	bcomLoadModel 2, $0f, $0000, $fffb, $0050, $00, $00, $00
	bcomSetEntityMovementXY 2, $00, $32
	bcomSetEntLogic 2, BriefingEntMoveOffsets
	bcomPlayExplosionSound $05
	bcomWait $0f
	bcomSetEntLogic 1, $00
	bcomExplodeEntity 0
	bcomNullModel 2
	bcomPlayExplosionSound $03
	bcomWait $1e
	bcomNullModel 0
	bcomSetEntityMovementXYZ0 1, $ff, $ec, $fe, $00
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomWait $19
	bcomSetEntityMovementXY 1, $0a, $00
	bcomSetEntLogic 1, EntityLogicMiniRadar
	bcomSetBubbleSize 0, 4
	bcomText "$Kク<LP><LP>ﾞライタ<LP><LP>ﾞー$Hをたおし、<NL>", \
	"$P全$Hての$Kリアクターロット<LP><LP>ﾞ$Hを$Kサイロ$Hにもと<LP><LP>$Kﾞ$Hせ$P！"
	bcomWait $32
	bcomSetBubbleSize 1, 4
	bcomText "$P空$Hをとふ<LP><LP>$Kﾞ$Hには、$Kシ<LP><LP>ﾞェットハﾟック$Hか<LP><LP>$Kﾞ$Hあれは<LP><LP>$Kﾞ<NL>", \
	"$Hかんたんた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H・・・・<NL>"
	bcomNullModel 1
	bcomStatic 1
	bcomLoadModel 0, $06, $0000, $01f4, $0064, $00, $18, $00
	bcomWait $01
	bcomSetBubbleSize 0, 4
	bcomText "$Kターホ<LP><LP>ﾞ$H時に、$Kヒ<LP><LP>ﾟラミット<LP><LP>ﾞ$Hのけいしゃを使い<NL>", \
	"とひ<LP><LP>$Kﾞ$Hたつ方$P法$Hもある。"
	bcomWait $19
	bcomSetBubbleSize 5, 4
	bcomText "$Hたた<LP><LP>$Kﾞ$Hし、と<LP><LP>$Kﾞ$Hちらの$P場$H合も<NL>", \
	"ねんりょうか<LP><LP>$Kﾞ$Hひつようとなる$P！"
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetEntityMovementXY 0, $03, $00
	bcomWait $32
	bcomNullModel 0
	bcomStatic 1
	bcomWait $01
	bcomStatic 1
	bcomSetBubbleSize 10, 3
	bcomText "$P補給$Hをおこたるな$P！<NL>", \
	"<NL>"
	bcomWait $32
	bcomEnd
	
Briefing4Sequence: ;5948
	bcomStatic 3
	bcomLoadImage $565c
	bcomLoadImage $565c
	bcomWait $01
	bcomSetBubbleSize 5, 4
	bcomText "$Hこれか<LP><LP>$Kﾞ$H、つれさられた$P科学者<NL>", \
	"$Kト<LP><LP>ﾞクター$Hやまののしゃしんた<LP>$Kﾞ$H。"
	bcomLookAtScreen
	bcomWait $64
	bcomWipeScreen
	bcomWipeScreen
	bcomStatic 3
	bcomLoadModel 0, $1a, $0000, $0190, $008c, $00, $00, $00
	bcomWait $01
	bcomSetBubbleSize 1, 4
	bcomText "$Hと<LP><LP>$Kﾞ$Hうやら、この$Kエイリアンヘ<LP><LP><LP>ﾞース$Hのなかに<NL>", \
	"とらえられているらしい。"
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 0, $00, $32
	bcomWait $0c
	bcomSetEntLogic 0, $0000
	bcomLoadModel 1, $1a, $ff9c, $02bc, $008c, $00, $00, $00
	bcomLoadModel 2, $1a, $0064, $02bc, $008c, $00, $00, $00
	bcomWait $01
	bcomSetBubbleSize 1, 4
	bcomText "$Hた<LP><LP>$Kﾞ$Hか、$Kエイリアンヘ<LP><LP><LP>ﾞース$Hは１<LP><LP><LP><LP>つて<LP><LP>$Kﾞ$Hはない。<NL>", \
	"わくせいのあらゆる$P所$Hにあり・・・・・"
	bcomSetEntityMovementXY 0, $0a, $00
	bcomSetEntityMovementXY 1, $f6, $00
	bcomSetEntityMovementXY 2, $f6, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetEntLogic 1, EntityLogicMiniRadar
	bcomSetEntLogic 2, EntityLogicMiniRadar
	bcomWait $3c
	bcomSetBubbleSize 3, 4
	bcomText "$Hと<LP><LP>$Kﾞ$Hの$Kエイリアンヘ<LP><LP><LP>ﾞース$Hに<NL>", \
	"とらえられているのかわからない。"
	bcomLoadModel 3, $0f, $0000, $fffb, $0050, $00, $f6, $00
	bcomSetEntLogic 3, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 3, $fc, $28
	bcomPlayExplosionSound $05
	bcomWait $0f
	bcomExplodeEntity 1
	bcomNullModel 3
	bcomPlayExplosionSound $03
	bcomWait $1e
	bcomNullModel 1
	bcomLoadModel 3, $0f, $0000, $fffb, $0050, $00, $0a, $00
	bcomSetEntLogic 3, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 3, $04, $28
	bcomPlayExplosionSound $05
	bcomWait $0f
	bcomExplodeEntity 2
	bcomNullModel 3
	bcomPlayExplosionSound $03
	bcomWait $1e
	bcomNullModel 2
	bcomLoadModel 3, $0f, $0000, $fffb, $0050, $00, $00, $00
	bcomSetEntLogic 3, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 3, $00, $28
	bcomPlayExplosionSound $05
	bcomWait $14
	bcomLoadModel 1, $11, $0000, $03e8, $00a0, $00, $00, $00
	bcomExplodeEntity 0
	bcomNullModel 3
	bcomPlayExplosionSound $03
	bcomWait $1e
	bcomNullModel 0
	bcomWait $1e
	bcomSetBubbleSize 2, 4
	bcomText "$H今回の任務は、$P科学者$Hをたすけ<NL>", \
	"$Kニュークリアサイロ$Hへ$P送$Hることた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H、"
	bcomSetBubbleSize 6, 4
	bcomText "$Hはやくつれもと<LP><LP>$Kﾞ$Hさなけれは<LP><LP>$Kﾞ<NL>", \
	"サイロ$Hはは<LP><LP>$Kﾞ$Hくはつしてしまう$P！"
	bcomWait $19
	bcomSetBubbleSize 4, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hは、$P敵$Hか<LP><LP>$Kﾞ$P開$H発した新$P兵器<NL>", \
	"$Kマイン$Hについてせつめいしよう。"
	bcomSetBubbleSize 6, 4
	bcomText "$Hこれは、$P近$Hつ<LP><LP>$Kﾞ$Hく$P敵$Hに$P反応$Hし<NL>", \
	"は<LP>$Kﾞ$Hくはつする$Kハﾞクタ<LP><LP>ﾞン$Hた<LP><LP>$Kﾞ$P！"
	bcomWipeScreen
	bcomWipeScreen
	bcomNullModel 1
	bcomLoadModel 0, $17, $0000, $012c, $0064, $00, $00, $00
	bcomWait $3c
	bcomSetBubbleSize 1, 4
	bcomText "$Hこれをかんちした時はすく$Kﾞ$Hにていしして<NL>", \
	"さか<LP><LP>$Kﾞ$Hし出せ$P！"
	bcomSetBubbleSize 3, 4
	bcomText "$Hそして、はなれた$P場所$Hから$P攻$Hけ<LP><LP>$Kﾞ$Hきし<NL>", \
	"はかいするのた<LP><LP>$Kﾞ$P！"
	bcomExplodeEntity 0
	bcomPlayExplosionSound $3
	bcomWait $1e
	bcomSetBubbleSize 6, 4
	bcomText "$Hさあ、もうあまり時間はない<NL>", \
	"いそいて<LP><LP>$Kﾞ$Hくれ$P！"
	bcomWait $32
	bcomEnd
	
Briefing8Sequence: ;5CB0
	bcomSetBubbleSize 6, 4
	bcomText "$H見たまえ、今回発見された<NL>", \
	"この$P巨$H大$Kサナキ<LP><LP>ﾞ$Hは・・・・・"
	bcomLookAtScreen
	bcomLoadModel 0, $38, $0000, $01f4, $0082, $00, $40, $00
	bcomWait $14
	bcomSetBubbleSize 3, 4
	bcomText "$Hわくせいをおおっている<NL>", \
	"$P巨$H大$P幼虫$Hか<LP><LP>$Kﾞ$Hせいちょうしたものた<LP><LP>$Kﾞ$H。"
	bcomLoadModel 1, $2d, $012c, $07d0, $0096, $00, $80, $00
	bcomSetEntityMovementXYZ0 1, $f6, $00, $0f, $00
	bcomSetEntLogic 1, BriefingEntRotate
	bcomLoadModel 2, $2d, $012c, $05dc, $0096, $00, $80, $00
	bcomSetEntityMovementXYZ0 2, $f6, $0, $0f, $0
	bcomSetEntLogic 2, BriefingEntRotate
	bcomLoadModel 3, $2d, $012c, $03e8, $0096, $00, $80, $00
	bcomSetEntityMovementXYZ0 3, $f6, $00, $0f, $00
	bcomSetEntLogic 3, BriefingEntRotate
	bcomWait $50
	bcomSetBubbleSize 0, 4
	bcomText "$Hもうすく$Kﾞサナキ<LP><LP>ﾞ$Hはふかし<NL>", \
	"きけんな$Kハ<LP><LP>ﾞタフライ$Hになってしまうらしい。"
	bcomSetBubbleSize 4, 4
	bcomText "$Hふかするまえに<NL>", \
	"$Kミサイル$Hて<LP><LP>$Kﾞ$Hたおしてしまうのた<LP><LP>$Kﾞ$P！"
	bcomSetBubbleSize 5, 4
	bcomText "$Hもし、ふかさせてしまったら<NL>", \
	"かならす<LP><LP>$Kﾞ$Hおいかけて、たおせ$P！"
	bcomExplodeEntity 0
	bcomSetBubbleSize 3, 4
	bcomText "$Hさもなけれは<LP><LP>$Kﾞハﾞタフライ$Hに<NL>", \
	"$Kレータ<LP><LP>ﾞー$P基$H地をはかいされてしまう$P！"
	bcomWait $32
	bcomEnd
	
Briefing9Sequence: ;5E37
	bcomSetBubbleSize 5, 4
	bcomText "$Hこれか<LP><LP>$Kﾞ$P敵$Hの発$P射$Hした<NL>", \
	"$Kクルース<LP>ﾞミサイル$Hの$P映像$Hた<LP><LP>$Kﾞ$P！"
	bcomLoadModel 0, $20, $0000, $012c, $0064, $00, $00, $00
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetEntityMovementXY 0, $0a, $00
	bcomWait $4d
	bcomLoadModel 1, $18, $0032, $0bb8, $0064, $00, $00, $00
	bcomSetEntLogic 0, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 0, $00, $32
	bcomWait $14
	bcomSetEntityMovementXY 0, $00, $ec
	bcomSetEntLogic 1, BriefingEntMoveOffsets
	bcomSetEntityMovementXY 1, $00, $ec
	bcomWait $3c
	bcomSetEntLogic 0, $0
	bcomSetEntityMovementXY 1, $fe, $d8
	bcomWait $19
	bcomSetEntityMovementXYZ0 1, $ff, $c4, $fe, $00
	bcomWait $06
	bcomSetEntityMovementXYZ0 1, $ff, $c4, $fc, $00
	bcomWait $06
	bcomExplodeEntity 1
	bcomWait $02
	bcomExplodeEntity 0
	bcomWait $32
	bcomNullModel 0
	bcomNullModel 1
	bcomWait $01
	bcomSetBubbleSize 0, 4
	bcomText "$H今回の任務は、３きの$Kクルース<LP><LP>ﾞミサイル$Hを<NL>", \
	"はかいすることた<LP><LP>$Kﾞ$H、しかし・・・・<NL>"
	bcomSetBubbleSize 5, 4
	bcomText "$Hこれは$Kミサイル$Hて<LP><LP>$Kﾞ$Hなけれは<LP><LP>$Kﾞ<NL>", \
	"$Hはかいて<LP><LP>$Kﾞ$Hきない$P！<NL>"
	bcomWait $32
	bcomEnd
	
Briefing5Sequence: ;5F4A
	bcomStatic 4
	bcomLoadModel 0, $1f, $0000, $012c, $0050, $00, $80, $00
	bcomWait $1
	bcomSetBubbleSize 2, 4
	bcomText "$Hこれは$Kエイリアントンネル$Hの出$P入$Hり$Kロ<NL>", \
	"トンネルエントランス$Hた<LP><LP>$Kﾞ$H。<NL>"
	bcomWait $32
	bcomSetBubbleSize 1, 4
	bcomText "$Kエイリアン$Hたちはここから<NL>", \
	"新$P型$Kタンク$Hをしゅつけ<LP><LP>$Kﾞ$Hきさせるらしい。<NL>"
	bcomNullModel 0
	bcomWait $1
	bcomLoadImage $619c
	bcomLoadImage $619c
	bcomSetBubbleSize 2, 4
	bcomText "$Hこれは、その$Kトンネル$Hと$Kエントランス$Hの<NL>", \
	"$P場所$Hをあらわした地$P図$Hた<LP><LP>$Kﾞ$H。"
	bcomSetBubbleSize 0, 4
	bcomText "$Kトンネル$Hは２つ、$Kエントランス$Hは４つある。<NL>", \
	"おほ<LP><LP>$Kﾞ$Hえておきたまえ。"
	bcomLookAtScreen
	bcomWait $3c
	bcomSetBubbleSize 0, 4
	bcomText "$H今回の任務は、この$Kトンネル$Hのはかいた<LP><LP>$Kﾞ$H。<NL>", \
	"しかし、これをはかいするには・・・・"
	bcomSetBubbleSize 3, 4
	bcomText "$Kトンネル$P内$Hにせんにゅうし、$Kホ<LP><LP>ﾞム$Hて<LP><LP>$Kﾞ<NL>", \
	"$P中$Hからはかいするしかない$P！"
	bcomLoadImage $5bfc
	bcomLoadImage $5bfc
	bcomSetBubbleSize 0, 4
	bcomText "$Hその$Kホ<LP><LP>ﾞム$Hをおとす$P場所$Hた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H・・・・<NL>", \
	"$Kトンネル$Hをよこからみたこの$P図$Hを見たまえ。"
	bcomSetBubbleSize 2, 4
	bcomText "$Hかならす<LP><LP>$Kﾞ$H、この１<LP><LP>は<LP>$Kﾞ$Hんふかい$P場所$Hて<LP><LP>$Kﾞ<NL>", \
	"$Hおとすように。"
	bcomSetBubbleSize 0, 4
	bcomText "$Hここて<LP><LP>$Kﾞ$Hなけれは<LP><LP>$Kﾞ$H、は<LP><LP>$Kﾞ$Hくはつに<NL>", \
	"まきこまれ、君まて<LP><LP>$Kﾞ$Hやられてしまうた<LP><LP>$Kﾞ$Hろう。"
	bcomLoadImage $5ecc
	bcomLoadImage $5ecc
	bcomLookAtScreen
	bcomWait $ff
	bcomSetBubbleSize 4, 4
	bcomText "$Hくれく$Kﾞ$Hれも、$Kホ<LP><LP>ﾞム$Hのそうひ<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$Hけは<NL>", \
	"わすれるな$P！"
	bcomWait $32
	bcomEnd
	
Briefing10Sequence: ;61DA
	bcomStatic 4
	bcomSetBubbleSize 2, 4
	bcomText "$P敵$Hの$Kマサ<LP><LP>ﾞーシッフ<LP><LP>ﾟ$Hにかんする$P情報$Hを<NL>", \
	"与えておく。"
	bcomSetBubbleSize 3, 4
	bcomText "$Hこれは見えない$Kハﾞリアー$Hにおおわれ<NL>", \
	"$P近$Hつ<LP><LP>$Kﾞ$Hくことは出来ない。"
	bcomLookAtScreen
	bcomLoadImage $646c
	bcomLoadImage $646c
	bcomWait $1
	bcomSetBubbleSize 0, 4
	bcomText "$Hこれは、そのようすをあらわした$P図$Hた<LP><LP>$Kﾞ$H・・・・<NL>", \
	"$Kマサ<LP><LP>ﾞーシッフ<LP>ﾟ$Hをはかいするためには、"
	bcomSetBubbleSize 1, 4
	bcomText "$Kハイエックスミサイル$Hしかない、しかし<NL>", \
	"これは君も$Kタ<LP><LP>ﾞメーシ<LP><LP>ﾞ$Hをうける$P兵器$Hた<LP><LP>$Kﾞ$P！"
	bcomSetBubbleSize 0, 4
	bcomText "$Kシールト<LP><LP>ﾞ$Hか<LP><LP>$Kﾞフル$Hの時て<LP><LP>$Kﾞ$Hなけれは<LP><LP>$Kﾞ<NL>", \
	"ハイエックスミサイル$Hは使ってはならない$P！<NL>"
	bcomLookAtScreen
	bcomWait $32
	bcomSetBubbleSize 1, 4
	bcomText "$Hまた、$Kミサイル$Hか<LP><LP>$Kﾞフル$Hて<LP><LP>$Kﾞ$Hなけれは<LP><LP>$Kﾞ<NL>", \
	"ハイエックス$Hは発$P射$H出来ない$P！<NL>"
	bcomWait $32
	bcomEnd
	
BriefingEndSequence: ;635E
	bcomSetBubbleSize 5, 4
	bcomText "$Hよくやった$P！<NL>", \
	"$Kマサ<LP><LP>ﾞーシッフ<LP>ﾟ$Hははかいされた$P！"
	bcomSetBubbleSize 8, 4
	bcomText "$H我々は$Kエイリアン$Hたちに<NL>", \
	"しょうりしたのた<LP><LP>$Kﾞ$H。"
	bcomSetBubbleSize 1, 4
	bcomText "$P全$Hて君のおかけ<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$H・・・・君のことは<NL>", \
	"人々の間にかたりつか<LP><LP>$Kﾞ$Hれることた<LP><LP>$Kﾞ$Hろう。"
	bcomSetBubbleSize 5, 4
	bcomText "$Hありか<LP><LP>$Kﾞ$Hとう$P！<NL>", \
	"$Hきをつけてかえってくれたまえ。"
	bcomWait $32
	bcomEnd
	
UnusedBriefingSequence1: ;6422
	bcomSetBubbleSize 5, 4
	bcomText "$H今から$Kテタムス$H２に行くまえの<NL>", \
	"$Kトレーニンク<LP><LP>ﾞ$Hを行なう$P！"
	bcomSetBubbleSize 2, 4
	bcomText "$Hこの$Kトレーニンク<LP><LP>ﾞ$Hは<NL>", \
	"$Kタンク$Hなと<LP><LP><LP>$Kﾞ$Hを、１<LP><LP><LP><LP>０たおすことにある$P！"
	bcomSetBubbleSize 4, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hはここて<LP><LP>$Kﾞ$H、やくにたつ<NL>", \
	"$Kオフ<LP><LP>ﾞシ<LP><LP><LP>ﾞェクト$Hをしょうかいしよう$P！"
	bcomLoadModel 0, $1, $0, $c8, $55, $0, $0, $0
	bcomSetEntityMovementXY 0, $a, $0
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $32
	bcomSetBubbleSize 7, 3
	bcomText1Line "$Hます<LP><LP>$Kﾞ$H、$Kハﾟワーキューフ<LP><LP>ﾞ$Hた<LP><LP>$Kﾞ$P！"
	bcomSetBubbleSize 6, 4
	bcomText "$Hこれをうては<LP><LP>$Kﾞ$H、$Kシールト<LP><LP><LP>ﾞ$Hか<LP><LP>$Kﾞ<NL>", \
	"リヘ<LP><LP><LP>ﾟアー$Hされていく・・・・・"
	bcomLoadModel 0, $8, $0, $c8, $50, $0, $0, $0
	bcomSetEntityMovementXY 0, $a, $0
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomWait $32
	bcomSetBubbleSize 5, 4
	bcomText "$Hつき<LP><LP>$Kﾞ$Hに、これは$Kヒ<LP><LP><LP>ﾞーコン$Hという<NL>", \
	"とくしゅな$Kオフ<LP><LP>ﾞシ<LP><LP><LP>ﾞェクト$Hた<LP><LP>$Kﾞ$P！"
	bcomSetBubbleSize 3, 4
	bcomText "$Hはかいすることによりさまさ<LP><LP>$Kﾞ$Hまな<NL>", \
	"$Kホ<LP><LP>ﾞーナスオフ<LP><LP>ﾞシ<LP><LP>ﾞェ$Hにへんかする。"
	bcomExplodeEntity 0
	bcomPlayExplosionSound $3
	bcomWait $a
	bcomLoadModel 0, $f, $ffa6, $28a, $82, $0, $0, $0
	bcomLoadModel 1, $22, $0, $28a, $82, $0, $0, $0
	bcomLoadModel 2, $25, $5a, $28a, $82, $0, $0, $0
	bcomSetEntityMovementXY 0, $c, $0
	bcomSetEntityMovementXY 1, $f4, $0
	bcomSetEntityMovementXY 2, $c, $0
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetEntLogic 1, EntityLogicMiniRadar
	bcomSetEntLogic 2, EntityLogicMiniRadar
	bcomWait $32
	bcomSetBubbleSize 3, 4
	bcomText "$H今、出ているこれらか<LP><LP>$Kﾞ<NL>", \
	"$Hその$Kホ<LP><LP>ﾞーナスオフ<LP><LP>ﾞシ<LP><LP><LP>ﾞェクト$Hたちた<LP><LP>$Kﾞ$H。"
	bcomSetBubbleSize 0, 4
	bcomText "$P右$Hから、ねんりょう$Kタンク<NL>", \
	"シールト<LP><LP><LP>ﾞマッシュルーム$H、そして$Kミサイル$Hた<LP><LP>$Kﾞ$H。"
	bcomLookAtScreen
	bcomWait $19
	bcomNullModel 0
	bcomNullModel 1
	bcomNullModel 2
	bcomLoadModel 0, $3, $0, $190, $78, $0, $0, $0
	bcomSetEntLogic 0, EntityLogicMiniRadar
	bcomSetEntityMovementXY 0, $7, $0
	bcomWait $28
	bcomSetBubbleSize 6, 4
	bcomText "$Hつき<LP><LP>$Kﾞ$Hに、これは我々の<NL>", \
	"$Kレータ<LP><LP><LP>ﾞー$P基$H地の$P映像$Hた<LP><LP>$Kﾞ$H・・・・"
	bcomSetBubbleSize 4, 4
	bcomText "$Hここて<LP><LP>$Kﾞ$Hも$Kシールト<LP><LP>ﾞ$Hの$Kリヘ<LP><LP><LP>ﾟアー$Hや<NL>", \
	"$Kミサイル$Hなと<LP><LP>$Kﾞ$Hの$P補給$Hか<LP><LP>$Kﾞ$H出来る$H。"
	bcomSetBubbleSize 3, 4
	bcomText "$Hまた、４つの$P兵器$Hから１<LP><LP><LP>つをえらひ<LP><LP>$Kﾞ<NL>", \
	"$Hそうひ<LP><LP>$Kﾞ$H出来るのもこの$P場所$Hた<LP><LP>$Kﾞ$H。"
	bcomLookAtScreen
	bcomNullModel 0
	bcomStatic 4
	bcomLoadImage $484c
	bcomLoadImage $484c
	bcomWait $1
	bcomSetBubbleSize 0, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hは、その４つの$P兵器$Hをせつめいする<NL>", \
	"ます<LP><LP>$Kﾞミサイル$Hを発$P射$Hする・・・・・$Kロックオン"
	bcomSetBubbleSize 4, 4
	bcomText "$H８$P本$Hの$Kミサイル$Hをひつようとする<NL>", \
	"$P超強力兵器$Hの・・・・$Kハイエックス"
	bcomSetBubbleSize 0, 4
	bcomText "$Hた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H、これはきけんな$P兵器$Hた<LP><LP>$Kﾞ$P！<NL>", \
	"$H使えは<LP><LP>$Kﾞ$Hし<LP><LP><LP>$Kﾞ$Hふ<LP><LP>$Kﾞ$Hんも大きな$Kタ<LP><LP>ﾞメーシ<LP><LP><LP>ﾞ$Hをうける。"
	bcomSetBubbleSize 1, 4
	bcomText "$Hそして$Kターホ<LP><LP>ﾞ$H時て<LP><LP>$Kﾞ$Hあれは<LP><LP>$Kﾞ$H、と<LP><LP><LP>$Kﾞ$Hこからて<LP><LP>$Kﾞ$Hも<NL>", \
	"とひ<LP><LP>$Kﾞ$Hたてる・・・・・・$Kシ<LP><LP><LP>ﾞェットハﾟック"
	bcomSetBubbleSize 0, 4
	bcomText "$Hさらに、$Kハイエックス$Hほと<LP><LP>$Kﾞ$Hいりょくはないか<LP><LP>$Kﾞ<NL>", \
	"$Hかならす<LP><LP>$Kﾞ$H使う時か<LP><LP>$Kﾞ$H来るて<LP><LP>$Kﾞ$Hあろう・・・$Kホ<LP><LP>ﾞム"
	bcomSetBubbleSize 0, 4
	bcomText "$Hこれら４つの$P兵器$Hを<NL>", \
	"し<LP><LP><LP><LP>$Kﾞ$Hょうきょうに$P応$Hし<LP><LP><LP><LP>$Kﾞ$H、使いわけるように・・・・"
	bcomLookAtScreen
	bcomWait $32
	bcomSetBubbleSize 7, 4
	bcomText "$Hて<LP><LP>$Kﾞ$Hは、これより<NL>", \
	"$Kトレーニンク<LP><LP>ﾞ$Hを$P開始$Hする$P！"
	bcomWait $32
	bcomEnd
	
UnusedBriefingSequence2: ;69AA
	bcomSetBubbleSize 0, 3
	bcomText1Line "$Hよくやった、これて<LP><LP>$Kﾞトレーニンク<LP><LP>ﾞ$Hは$P完了$Hた<LP><LP>$Kﾞ$P！"
	bcomSetBubbleSize 3, 4
	bcomText "$Hさあ、$Kワーフ<LP>ﾟトンネル$Hを使い<NL>", \
	"わくせい$Kテタムス$H２に行きたまえ$P！"
	bcomWait $64
	bcomEnd
	
	
SETCHARMAP CHARS
LocateCrystalText: ;6A0E
	db "$Kクリスタル$Hを発見せよ$P！", 00
	
AlienTunnelDestroyedText1: ;6A20
	db "$Kエイリアントンネル$Hはかい$P！", 00
AlienTunnelDestroyedText2: ;6A34
	db " ", 00
MothershipDestroyedText1: ;6A36
	db "$Kマサ<LP><LP>ﾞーシッフ<LP>ﾟ$Hはかい$P！", 00
MothershipDestroyedText2: ;6A4C
	db " ", 00
CruiseMissileDestroyedText1: ;6A4E
	db "$Kクルース<LP><LP>ﾞミサイル$Hはかい$P！", 00
CruiseMissileDestroyedText2: ;6A64
	db " ", 00
	
ChrysalisHatchText: ;6A66
	db "$Kサナキ<LP><LP>ﾞ$Hか<LP><LP>$Kﾞ$Hふかした$P！", 00 ;chrysalis has hatched!
ChrysalisShotText: ;6A80
	db "$Kサナキ<LP><LP>ﾞ$Hか<LP><LP>$Kﾞ$Hふかした$P！", 00 ;chrysalis has hatched! (duplicate?)
	
MineDiscoveredText: ;6A9A
	db "$P近$Hくに$Kマイン$H発見$P！$Hちゅういせよ$P！", 00 ;mine discovered nearby! be careful!

	
SETCHARMAP main
JunctionTextThisBase: ;6AB9
	db "$1This Base Has Run", 00
JunctionTextNoStock: ;6ACD
	db "$1Out Of Supplies.", 00
JunctionTextNoMissiles: ;6AE0
	db "$1Out Of Missiles.", 00
JunctionTextNoFuel: ;6AF3
	db "$1Out Of Fuel Supplies.", 00
JunctionTextNoShield: ;6B0B
	db "$1Out Of Materials", 00
SETCHARMAP CHARS
JunctionTextGotGas: ;6B1E, bought gas at junction
	db  "$Hねんりょう$P補給完了！", 00
JunctionTextGotMissiles: ;6B2D, bought missiles at junction
	db  "$Kミサイル$P補給完了！", 00
JunctionTextGotShield: ;6B3B, bought shield at junction
	db  "$Kリヘ<LP><LP>ﾟアー$P完了！", 00
HighEXText: ;6B4A
	db "$Kハイエックス$Hか<LP><LP>$Kﾞ$Hさくれつ$P！！", 00 ;HIGH-EX exploded!
DamagedEverythingText: ;6B65
	db "$P全$Hてに$Kタ<LP><LP>ﾞメーシ<LP><LP><LP>ﾞ$Hを与えた$P！", 00 ;damaged everything!
;6B83

SECTION "5:6BBD", ROMX[$6BBD], BANK[5]
HelpScientistTest: ;6BBD
	db "$Kト<LP><LP>ﾞクター$Hやまのをたすけた<LP><LP>$Kﾞ$Hし", 00
NuclearSiloSafeText: ;6BD9
	db "$Kニュークリアサイロ$Hは$P守$Hられた$P！", 00
FindScientistText1: ;6BF3
	db "$Kト<LP><LP>ﾞクター$Hやまのを発見せよ$P！", 00
FindScientistText2: ;6C0A
	db 00


ImposterDialogueText: ;6C0B
	db "$Hありか<LP><LP>$Kﾞ$Hとう・・・", 00
ScientistDialogueText1: ;6C1D
	db "$Hありか<LP><LP>$Kﾞ$Hとう$P！", 00
ScientistDialogueText2: ;6C2F
	db "$Hさあ私を$Kサイロ$Hにつれていってくれ$P！", 00
;6C49

SECTION "5:6C5C", ROMX[$6C5C], BANK[5]
ReactorRodsReturnedText: ;6C5C
	db "$Kリアクターロット<LP><LP>ﾞ$Hか<LP><LP>$Kﾞ$Hもと<LP><LP>$Kﾞ$Hり", 00
SiloSavedText: ;6C7E
	db "$Kサイロ$Hはたすかった$P！", 00
	
CollectedReactorRodsText: ;6C8F 
	db "$P全$Hての$Kリアクターロットﾞ$Hを回収した$P！", 00 ;$Collected All Reactor Rods!
HeadToSiloText1: ;6CAC
	db "$H今すく<LP><LP>$Kﾞサイロ$Hへ向かえ$P！<NL>", 00 ;Head to the silo immediately!
HeadToSiloText2: ;6CC4
	db "<NL>", 00
	
HaventCollectedRodText1: ;6CC6
	db "$Hまた<LP><LP>$Kﾞロット<LP><LP>$Hを回収しおえてない$P！", 00 ;typo??? should be a diactric after the second pair of left movements
HaventCollectedRodText2:
	db "<NL>", 00
	
TruckArrivedText1: ;6CE5
	db "$Kトラック$Hとうちゃく$P！", 00
TruckArrivedText2:
	db "<NL>", 00
TruckDamagedText: ;6CF8
	db "$Kトラックタ<LP><LP>ﾞメーシ<LP><LP>ﾞ$P！", 00
	
Level6TruckDestroyedText: ;6D0C
	db "$Kトラック$Hはかい$P！", 00
	
Level2NoBombsText1: ;6D1B
	db "$P全$H時$P限$Kハﾞクタ<LP><LP>ﾞン$Hはかい$P！", 00 ;all time bombs destroyed?
Level2NoBombsText2: ;6D37
	db " ", 00
RadarBaseDestroyedText1: ;6D39
db  "$Kレータ<LP><LP>ﾞー$P基$H地か<LP><LP>$Kﾞ$Hはかいされた$P！", 00
RadarBaseDestroyedText2: ;6D5A
db  "<NL>", 00
Level2BlankTXT: ;6D5C
db "<NL>", 00
Left7Text: ;6D5E
db  "$H残り、$H７", 00
Left6Text: ;6D67
db  "$H残り、$H６", 00
Left5Text: ;6D70
db  "$H残り、$H５", 00
Left4Text: ;6D79
db  "$H残り、$H４", 00
Left3Text: ;6D82
db  "$H残り、$H３", 00
Left2Text: ;6D8B
db  "$H残り、$H２", 00
Left1Text: ;6D94
db  "$H残り、$H１", 00

SETCHARMAP main
NoShieldText: ;6D9D
	db "$1NO SHIELD LEFT!", 00
SETCHARMAP CHARS
TimerOverText1_1: ;6DAF
	db "$Kクリスタル$Hか<LP><LP>ﾞとけた$P！", 00 ;crystal melted!
TimerOverText1_2: ;6DC3
	db " ", 00
	
TimerOverText2_1: ;6DC5
	db  "$H時$P限$Kハﾞクタ<LP><LP>ﾞン$Hは<LP><LP>$Kﾞ$Hくはつ$P！", 00 ;bomb exploded!
TimerOverText2_2: ;6DE6
	db " ", 00
	
TimerOverText3_1: ;6DE8
	db  "$Kレータ<LP><LP>ﾞー$P基$H地は", 00
TimerOverText3_2: ;6DF9
	db  "$P全$Hてはかいされた$P！", 00 ;radar bases all destroyed!
	
TimerOverText6_1: ;6E09
	db  "$Kニュークリアサイロ$Hは<LP><LP>$Kﾞ$Hくはつ$P！", 00 ;nuclear silo exploded!
TimerOverText6_2: ;6E25
	db " ", 00
Level6BlankText: ;6E27
	db " ", 00

TimerOverText7_1: ;6E29
	db  "$Kニュークリアサイロ$Hは<LP><LP>$Kﾞ$Hくはつ$P！", 00 ;nuclear silo exploded!
TimerOverText7_2: ;6E45
	db " ", 00
	
TimerOverText4_1: ;6E47
	db "$Kニュークリアサイロ$Hは<LP><LP>$Kﾞ$Hくはつ$P！<NL>", 00
TimerOverText4_2: ;6E64
	db " ", 00
	
TimerOverText9_1: ;6E66
	db " ", 00
TimerOverText9_2: ;6E68
	db  "$H我々の$Kサイロ$Hか<LP><LP>$Kﾞ$Hはかいされた$P！", 00 ;our silo destroyed!
	
TimerOverText10_1: ;6E86
	db "$H我々は、こうふくした$P！", 00 ;we surrendered!
TimerOverText10_2: ;6E96
	db " ", 00
	
HumanoidTankDestroyedText1: ;6E98, humanoid tank destroyed!
	db "$Kヒューマノイト<LP><LP>ﾞタンク$Hはかい$P！", 00
HumanoidTankDestroyedText2: ;6EB0
	db " ", 00

PowerCrystalRetrieveText1: ;6EB2
	db "$Kハﾟワークリスタル$H発見$P！", 00 ;power crystal discovered!
PowerCrystalRetrieveText2: ;6EC5
	db "$Kニュークリアサイロ$Hへ$P<向alt>$Hかえ$P！", 00 ;head to the nuclear silo!
PowerCrystalRetrieveText3: ;6EDE
	db "<NL>", 00
	
NuclearSiloMovingText1: ;6EE0
	db "$Kニュークリアサイロ$Hか<LP><LP>$Kﾞ$Hうこ<LP><LP>$Kﾞ$Hきた<LP><LP>$Kﾞ$Hした$P！", 00
NuclearSiloMovingText2: ;6F0D
	db "<NL>", 00
	
AllButterfliesDestroyedText1: ;6F0F
	db "$P全$Hての$Kハ<LP><LP>ﾞタフライ$Hをたおした$P！", 00
AllButterfliesDestroyedText2:;6F2B
	db " ", 00
	
MissionCompleteText: ;6F2D
	db "$Kミッション$P完了！", 00 ;mission complete!
SETCHARMAP main
;6F3A
	db "POINT REACHED", 00
SETCHARMAP CHARS
NoMissilesText: ;6F48
	db  "$Kミサイル$Hか<LP><LP>$Kﾞ$Hない$P！", 00
NotEnoughMissilesText: ;6F5E, not enough missiles!
	db  "$Kミサイル$Hか<LP><LP>$Kﾞ$Hたりない$P！", 00
	
;6F76, unused?
	db "<NL>", 00
	db "<NL>", 00
	db "<NL>", 00

MineDetonatedText: ;67FC
	db "$Kマイン<NL>", \
	"$Hは<LP><LP>$Kﾞ$Hくはつ$P！", 00 ;mine detonated!

SETCHARMAP main
SiloDestroyedText: ;6F93
	db "SILO DESTROYED", 00
IF UNUSED == 1
;unused? 6FA2
	db "VIDEO PIC TAKEN", 00
RodInsertedText: ;unused? 6FB2
	db "ROD INSERTED", 00
SiloSafeText: ;unused? 6FBF
	db "SILO NOW SAFE", 00
ENDC
	
HighDamageText: ;6FCD
	db "$1DAMAGE HIGH", 00
SETCHARMAP CHARS
LauncherSpottedText: ;6FDB
	db  "$P近$Hくに$Kランチャー$H発見$P！$Hちゅういせよ$P！", 00
SETCHARMAP main
;unused? 6FFC
	db "FUEL LOW", 00
;7005
	db "PAU ##SED", 00
SETCHARMAP CHARS
OneAlienTunnelLeftText1: ;700F
	db "$Kエイリアントンネル$Hはかい$P！", 00 ;alien tunnel destroyed!
OneAlienTunnelLeftText2: ;7023
	db "$H残りあと１<LP><LP>$P！", 00 ;1 left!
OneAlienTunnelLeftText3: ;7030
	db " ", 00
	
PenHumanTankDestroyedText1: ;7032
	db "$Kヒューマノイト<LP><LP>ﾞタンク$Hはかい$P！", 00 ;human tank destroyed
PenHumanTankDestroyedText2: ;704A
	db "$H", 102, "りあと１<LP><LP>$P！", 00 ;1 left!
PenHumanTankDestroyedText3: ;7057
	db " ", 00
	
ThisIsSiloText: ;7059
	db "$Hこれは、$Kニュークリアサイロ$Hた<LP><LP>$Kﾞ$P！", 00
	
TunnelEntranceDestroyedText1: ;7076
	db "$Kトンネルエントランス$Hか<LP><LP>$Kﾞ", 00
TunnelEntranceDestroyedText2: ;708B
	db "    $Hはかいされた$P！ ", 00
JunctionDestroyedText1: ;709C
	db "$Kシ<LP><LP><LP>ﾞャンクション$Hか<LP><LP>$Kﾞ", 00
JunctionDestroyedText2: ;70B2
	db "    $Hはかいされた$P！ ", 00
	
ScientistOnboardText1: ;70C3
	db "$Hさきにのっていた", 00 ;on the previous page...
ScientistOnboardText2: ;70CE
	db "$P科学者$Hをおい出した$P！", 00 ;i brought that scientist out

RecapTrainingPageText: ;70DF - 70FE: training recap page?
db  "$Hこれは、$Kトレーニンク<LP><LP>ﾞミッション$Hた<LP><LP>$Kﾞ", 00
db  00

Recap10Text: ;70FF - 71E1: recap 10
db  "$Kエイリアン$Hの$Kマサ<LP><LP>ﾞーシッフ<LP><LP>ﾟ$Hか<LP><LP>$Kﾞ<NL>", \
	"$Hついにそのすか<LP><LP>$Kﾞ$Hたをあらわした。<NL>", \
	"$Kエイリアン$Hたちは我々に<NL>", \
	"$Hさいこ<LP><LP>$Kﾞ$Hのたたかいをいと<LP><LP>$Kﾞ$Hみ、<NL>", \
	"$Hおひ<LP><LP>$Kﾞ$Hたた<LP><LP>$Kﾞ$Hしいかす<LP><LP>$Kﾞ$Hの$P兵器$Hを<NL>", \
	"$P送$Hりこんて<LP><LP>$Kﾞ$Hきたのた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hこうふくか、それともしょうりか、<NL>", \
	"$P全$Hてをかけ、たたかいか<LP><LP>$Kﾞ$H今$P始$Hまる・・・", 00
db  00

Recap4Text: ;71E2 - 72A4: recap 4
db  "$Kニュークリアサイロ$Hのうこ<LP><LP>$Kﾞ$Hきか<LP><LP>$Kﾞ<NL>", \
	"$P突如$H、おかしくなった。<NL>", \
	"$Kエイリアン$Hたちによって、<NL>", \
	"$Kニュークリアサイロ$Hの$P科学者$Hか<LP><LP>$Kﾞ<NL>", \
	"$Hつれさられていたのた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hこのままて<LP><LP>$Kﾞ$Hはいす<LP><LP>$Kﾞ$Hれ、<NL>", \
	"$Kニュークリアサイロ$Hは大は<LP>$Kﾞ$Hくはつを<NL>", \
	"$P起$Hこしてしまうた<LP><LP>$Kﾞ$Hろう・・・・<NL>", 00
db  00

Recap9Text: ;72A5 - 734F: recap 9
db  "$H放$P射能$Hのえいきょうも$P少$Hなくなり、<NL>", \
	"$H我々のわくせい$P開$H発も<NL>", \
	"$Hきと<LP><LP>$Kﾞ$Hうにのり$P始$Hめた、その時・・・・<NL>", \
	"$Hまたも$Kエイリアン$Hたちは<NL>", \
	"$H新たなこうけ<LP><LP>$Kﾞ$Hきをしかけてきた。<NL>", \
	"$Kニュークリアサイロ$Hに$P対$Hし<NL>", \
	"$Kミサイル$Hを発$P射$Hしてきたのた<LP><LP>$Kﾞ$H。<NL>", 00
db  00

Recap8Text: ;7350 extra newline gets ignored
db  "$Kリアクターロット<LP><LP>ﾞ$Hはもとにもと<LP><LP>$Kﾞ$Hった。<NL>", \
	"$Hた<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$H、$Kサイロ$Hからもれた放$P射能$Hは<NL>", \
	"$H我々か<LP><LP>$Kﾞ$P思$Hっていたよりも<NL>", \
	"$H大きなえいきょうを与え、<NL>", \
	"<NL>", \
	"$Hこのわくせい$Kテタムス$H２を<NL>", \
	"$P巨$H大な$P虫$Hたちにおおわれた、<NL>", \
	"$Hおそろしいほしにかえてしまった。<NL>", 00
db  00

Recap6Text: ;73FD - 74DB: recap 6
db  "$Kト<LP><LP>ﾞクター$Hやまのから<NL>", \
	"$Kサイロ$Hの放$P射能$Hもれか<LP><LP>$Kﾞ$P報告$Hされた。<NL>", \
	"$Hこのままて<LP><LP>$Kﾞ$Hは大は<LP>$Kﾞ$Hくはつを$P起$Hこし<NL>", \
	"$Hわくせいは、ほうかいしてしまう。<NL>", \
	"$Hきゅうきょ我々は、<NL>", \
	"$H放$P射能$Hをせいき<LP><LP>$Kﾞ$Hょするための<NL>", \
	"$Kリアクターロット<LP><LP>ﾞ$Hを$P開$H発し、<NL>", \
	"$H４た<LP><LP>$Kﾞ$Hいの$Kトラック$Hにのせ<NL>", \
	"$Kサイロ$Hへはこふ<LP><LP><LP>$Kﾞ$Hことになった。<NL>", 00
db  00

Recap7Text: ;74DC - 758B: recap 7
db "$Kリアクターロット<LP><LP>ﾞ$Hによって<NL>", \
	"$H放$P射能$Hもれはおさまり、<NL>", \
	"$Kサイロ$Hは$P正$Hし<LP><LP><LP>$Kﾞ$Hょうにもと<LP><LP>$Kﾞ$Hった。<NL>", \
	"$Hしかし、このことを$P知$Hった<NL>", \
	"$Kエイリアン$Hたちは、新$P型兵器$Hを使い<NL>", \
	"$H４$P本$Hの$Kリアクターロット<LP><LP>ﾞ$P全$Hてを<NL>", \
	"$Kサイロ$Hからうは<LP>$Kﾞ$Hっていった。<NL>", 00
db  00

Recap5Text: ;758C - 765C: recap 5
db  "$P突如$H、$Kエイリアン$Hたちか<LP><LP>$Kﾞ<NL>", \
	"$H我々のまえからすか<LP><LP>$Kﾞ$Hたをけした。<NL>", \
	"$Hわくせいにも$P平和$Hか<LP><LP>$Kﾞ$Hおとす<LP><LP>$Kﾞ$Hれたかに<NL>", \
	"$P思$Hわれた、しかし・・・・<NL>", \
	"$Kエイリアン$Hはあきらめてはなかった。<NL>", \
	"$Hちかに$Kエイリアントンネル$Hをつくり、<NL>", \
	"$H新たなこうけ<LP><LP>$Kﾞ$Hきのし<LP><LP><LP>$Kﾞ$Hゅんひ<LP><LP>$Kﾞ$Hを<NL>", \
	"$Hすすめていたのた<LP><LP>$Kﾞ$H。<NL>", 00
db  00

Recap3Text: ;765D - 7703: recap 3
db  "$H時$P限$Kハﾞクタ<LP>ﾞン$Hははかいされ<NL>", \
	"$Kエイリアン$Hたちのこうけ<LP><LP>$Kﾞ$Hきは<NL>", \
	"$Hしっは<LP>$Kﾟ$Hいにおわった。<NL>", \
	"$Hしかし・・・・・<NL>", \
	"$Kエイリアン$Hたちは我々に$P対$Hし<NL>", \
	"$H新たなこうけ<LP><LP>$Kﾞ$Hきをしかけるへ<LP><LP><LP><LP>$Kﾞ$Hく<NL>", \
	"$H新$P型兵器$Hを$P送$Hりこんて<LP><LP>$Kﾞ$Hきた。<NL>", 00
db  00

Recap2Text: ;7704
db  "$Kニュークリアサイロ$Hはうこ<LP><LP>$Kﾞ$Hき$P始$Hめ<NL>", \
	"$H我々は$Kエネルキ<LP><LP>ﾞー$Hを$P手$Hにいれた。<NL>", \
	"$Hそのころ、ちょうさた<LP><LP>$Kﾞ$Hんにより<NL>", \
	"$Hゆそう船をはかいしたのは、<NL>", \
	"$H宇宙せいふくをたくらむ<NL>", \
	"$Kエイリアン$Hたちて<LP><LP>$Kﾞ$Hあることか<LP><LP>$Kﾞ<NL>", \
	"$Hはんめいした。$P彼$Hらはこのわくせいを<NL>", \
	"$Hわか<LP><LP>$Kﾞ$Hものにしようとしていたのた<LP><LP>$Kﾞ$P！<NL>", 00
db  00
	
Recap1Page1Text: ;77CF
db  "$H宇宙世紀XXXX年・・・・<NL>", \
	"$H人$Kロ$Hのそ<LP><LP>$Kﾞ$Hうかにより、ちきゅうは<NL>", \
	"$Hすむへ<LP><LP><LP>$Kﾞ$Hき$P場所$Hか<LP><LP>$Kﾞ$Hなくなっていた。<NL>", \
	"$H人々は、ふえすき<LP><LP>ﾞた人間の<NL>", \
	"$Hいし<LP><LP><LP>$Kﾞ$Hゅうさきを宇宙にもとめ、<NL>", \
	"$Hついに、未来の$Kエネルキ<LP><LP>ﾞー$Hしけ<LP><LP>$Kﾞ$Hん<NL>", \
	"$Kハﾟワークリスタル$Hか<LP><LP>$Kﾞ$Hねむるという<NL>", \
	"$Hわくせい$Kテタムス$H２を発見し、<NL>", 00
Recap1Page2Text: ;789E
db  "$Kエネルキ<LP><LP>ﾞー$Hのきょうきゅうしせつ<NL>", \
	"$Kニュークリアサイロ$Hをけんせつした。<NL>", \
	"$Hそんな時、$Kテタムス$H２の$P基$H地から<NL>", \
	"$Hきんきゅうし<LP><LP>$Kﾞ$Hたい発$P生$Hのしらせか<LP><LP>$Kﾞ<NL>", \
	"$Hちきゅうにとと<LP><LP>$Kﾞ$Hけられた。<NL>", \
	"$Kテタムス$H２になにか<LP><LP>$Kﾞ$Hおこったのか・・・<NL>", \
	"$H君をのせた$Kスヘ<LP><LP><LP>ﾟースタンク<NL>", \
	"$Kウ<LP><LP>ﾞィクシフ<LP><LP>ﾞ$Hか<LP><LP>$Kﾞ$H、今たひ<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$Hつ・・・<NL>", 00
db  00 ;end of pages

SETCHARMAP main
RadioLinkText: ;7981
	db "$1RADIO LINK", 00
SETCHARMAP CHARS

;radar text lines. designation is Level X, Entry X, Line X
RadarTextL10E1L1: ;798E
	db  "<NL>$Kシールト<LP><LP>ﾞ$Hか<LP><LP>$Kﾞフル$Hの時にしか<NL>", 00
RadarTextL10E1L2: ;79AB
	db  "$Kハイエックスミサイル$Hは使うな$P！", 00
RadarTextL5E1L1: ;79C1
	db  "$Kエイリアントンネル$P入$Hりく$Kﾞ$Hち発見$P！"
RadarTextL5E1L2: ;79DE
	db "<NL>", 00
RadarTextL5E1L3: ;79E0
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$P場所$Hは$Kエリア<NL>", \
	"", 00
RadarTextL9E1L1: ;79F9
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kクルース<LP><LP>ﾞミサイル$Hは・・・", 00
RadarTextL9E1L2: ;7A15
	db  "$H・・・・・・・<NL>", \
	"$Kエリア<NL>", 00
RadarTextL8E1L1: ;7A26
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kサナキ<LP><LP>ﾞ$H発見$P！", 00
RadarTextL8E1L2: ;7A41
	db  "$H発見$P場所$H・・・・・・・・・・・・$Kエリア<NL>", 00
RadarTextL8E2L1: ;7A5E
	db  "$P敵$Hに$P近$Hい、$P基$H地からの$P情報$H・・・・", 00
RadarTextL8E2L2: ;7A7F
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kハﾞタフライ$Hは・・・・", 00
RadarTextL8E2L3: ;7A9A
	db  "<NL>$H・・・$Kエリア<NL>", 00
RadarTextL4E1L1: ;7AA7
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kエイリアンヘ<LP><LP><LP><LP>ﾞース$H発見$P！<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"", 00
RadarTextL4E1L2: ;7AC9
	db  "$H発見$P場所$H・・・・・・・・・・・・$Kエリア<NL>", 00
RadarTextL4E2L1: ;7AE6
	db  "<NL>", \
	"$Kト<LP><LP>ﾞクター$Hやまのをたすけた<LP><LP>$Kﾞ$Hした$P！<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$H今すく<LP><LP>$Kﾞサイロ$Hへ向かえ$P！", 00
RadarTextL7E1L1: ;7B27
	db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kク<LP><LP>ﾞライタ<LP><LP>ﾞー$Hは・・・・", 00
RadarTextL7E1L2: ;7B47
	db  "<NL>$H・・$P情報$Kエリア<NL>", 00
DirectionTextNorth: ;7B57
	db  "$P北$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextNorthEast: ;7B69, typo??? should this be north-east???
	db  "$P北西$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextEast: ;7B7C
	db  "$P東$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextSouthEast: ;7B8E
	db  "$P南東$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextSouth: ;7BA1
	db  "$P南$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextSouthWest: ;7BB3
	db  "$P南西$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextWest: ;7BC6
	db  "$P西$Hの方向た<LP><LP>$Kﾞ$P！", 00
DirectionTextNorthWest: ;7BD8
	db  "$P北西$Hの方向た<LP><LP>$Kﾞ$P！", 00
RadarTextDirectionTable: ;7BEB, table of the above message variants.
	dw DirectionTextNorth 
	dw DirectionTextNorthEast
	dw DirectionTextEast
	dw DirectionTextSouthEast
	dw DirectionTextSouth
	dw DirectionTextSouthWest 
	dw DirectionTextWest 
	dw DirectionTextNorthWest
RadarTextL6E1L1: ;7BFB
	db  "$Kインセクト$Hから、$Kトラック$Hを$P守$Hれ$P！", 00
RadarTextL6E1L2: ;7C1A
	db  "<NL>", 00
RadarTextL3E1L1: ;7C1C, needs 66 in set H
	db  "$Hつ$Kレータ<LP><LP>ﾞー$P基$H地か<LP><LP>$Kﾞ$H", 102, "っている<NL>", 00
RadarTextL3E1L2: ;7C3D
	db  "$H今、やられた$Kレータ<LP><LP>ﾞー$Hは$Kエリア", 00
RadarTextL3E2L1: ;7C57
	db  "$Hはかいされた$Kレータ<LP><LP>ﾞー$P基$H地はない", 00
RadarTextL3E3L1: ;7C72
	db  "$Hさいこ<LP><LP>$Kﾞ$Hの$Kレータ<LP><LP>ﾞー$P基$H地た<LP><LP>$Kﾞ$P！", 00
RadarTextL2E1L2: ;7C98, needs 66 in set H
	db  "$Hつの$Kハﾞクタ<LP>ﾞン$Hか<LP><LP>$Kﾞ$H", 102, "っている$P！", 00
RadarTextTimeBlank: ;7CB8, blank used in ender?
	db  "<NL>", 00
RadarTextTimeWarning: ;7CBA, used in ender, needs 66 in set H
	db  "$H", 102, "り時間、あとわす<LP><LP>$Kﾞ$Hか・・・・", 00
RadarTextTimeUrgent: ;7CD2, used in ender, needs 66 in set H
	db  "$H", 102, "り時間、あとわす<LP><LP>$Kﾞ$Hか$P！！", 00
RadarTextL2E1L1: ;7CEA
	db  "$H時$P限$Kハﾞクタ<LP>ﾞン$H発見$P！$H・・・$Kエリア", 00
RadarTextL1E1L1: ;7D0B
db  "<NL><NL><NL><NL><NL>", \
	"$Kハﾟワークリスタル$H発見$P！", 00
RadarTextL1E1L2:;7D23
db  "<NL><NL><NL><NL><NL><NL><NL><NL><NL><NL><NL><NL><NL><NL><NL>", \
	"$Kエリア<NL>", \
	"$H７", 00
RadarTextL1E2L1: ;7D3C
db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kニュークリアサイロ$Hの$P場所", 00
RadarTextL1E2L2: ;7D54
db  "<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"<NL>", \
	"$Kエリア$H０", 00
	
RadarTextNum0: ;7D6B, start of multi-level table?
	db  "$H０", 00
RadarTextNum1: ;7D6F
	db  "$H１", 00
RadarTextNum2: ;7D73
	db  "$H２", 00
RadarTextNum3: ;7D77
	db  "$H３", 00
RadarTextNum4: ;7D7B
	db  "$H４", 00
RadarTextNum5: ;7D7F
	db  "$H５", 00
RadarTextNum6: ;7D83
	db  "$H６", 00
RadarTextNum7: ;7D87
	db  "$H７", 00
RadarTextNum8: ;7D8B
	db  "$H８", 00
RadarTextNum9: ;7D8F
	db  "$H９", 00
RadarTextNum10: ;7D93
	db  "$H１０", 00
RadarTextNum11: ;7D98
	db  "$H１１", 00
RadarTextNum12: ;7D9D
	db  "$H１２", 00
RadarTextNum13: ;7DA2
	db  "$H１３", 00
RadarTextNum14: ;7DA7
	db  "$H１４", 00
RadarTextNum15: ;7DAC
	db  "$H１５", 00
;7DB1
	db 00

SETCHARMAP main
MissionOneText: ;7DB2
	db "Mission One", 00
MissionTwoText: ;7DBE
	db "Mission Two", 00
MissionThreeText: ;7DCA
	db "Mission Three", 00
MissionFourText: ;7DD8
	db "Mission Four", 00
MissionFiveText: ;7DE5
	db "Mission Five", 00
MissionSixText: ;7DF2
	db "Mission Six", 00
MissionSevenText: ;7DFE
	db "Mission Seven", 00
MissionEightText: ;7E0C
	db "Mission Eight", 00
MissionNineText: ;7E1A
	db "Mission Nine", 00
MissionTenText: ;7E27
	db "Mission Ten", 00
MissionTrainingText: ;7E33: unused?
	db "Training Mission", 00
	
TitleTextPressAnyKey: ;7E44
	db "Press Any Key", 00
TitleTextPressAnyKeyAsterisks: ;7E52
	db "*Press Any Key*", 00
TitleTextContinueYes: ;7E62
	db "Continue...", $2F, "YES", "    ",  $23,  "NO", 00
TitleTextContinueNo: ;7E79
	db "Continue...", "   ", $23, "YES", " ",  $2F,  "NO", 00
;7E90
