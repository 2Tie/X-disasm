SECTION "Bank 2 Top", ROMX[$4000], BANK[2]
LevelTargetModels: ;4000, each corresponds to a model ID, one per level. increments C32C when killed.
	db $36, $12, $2E, $1A, $1F, $1D, $07, $44, $20, $4B, $00, $00

ProjectLine: ;0x800C
	;FFF5 and FFF7 end up with a screen coordinate
	;FFF9 and FFFB end up with deltas
	;sets carry on failure
	ldh a, [$FFF3]
	sub $01
	ldh [$FFF3], a
	ldh a, [$FFF4]
	sbc a, $00
	ldh [$FFF4], a ;subtract 1 from the word at F3/F4
	ldh a, [$FFEF]
	sub $01
	ldh [$FFEF], a
	ldh a, [$FFF0]
	sbc a, $00
	ldh [$FFF0], a ;subtract 1 from the word at EF/F0
	;compare the words with each other, determine which way to subtract them?
	ld bc, $0000 ;clear out BC
	ldh a, [$FFF5]
	ld l, a
	ldh a, [$FFF6]
	add a, $80
	ld h, a ;load F5/F6 + $8000 into HL; this is a tile address?
	ldh a, [$FFF1]
	sub a, l
	ldh a, [$FFF2]
	sbc a, h ;compare F1/F2 to the tile address
	rl b ;this puts carry value into 0th bit of b (set if F1/F2 < F5/F6)
	ldh a, [$FFF3]
	sub a, l
	ldh a, [$FFF4]
	sbc a, h ;compare F3/F4 to the tile address
	ccf
	rl b ;shift inversed carry bit into b (set if F3/F4 >= F5/F6)
	ldh a, [$FFF7]
	ld l, a
	ldh a, [$FFF8]
	add a, $80
	ld h, a ;load F7/F8 + $8000 into HL. tile address 2?
	ldh a, [$FFEF]
	sub a, l
	ldh a, [$FFF0]
	sbc a, h ;compare EF/F0 to tile address
	ccf 
	rl b ;shift inversed carry bit into b (set if EF/F0 >= F7/F8)
	ldh a, [$FFED]
	sub a, l
	ldh a, [$FFEE]
	sbc a, h ;compare ED/EE to tile address
	rl b ;shift carry bit into b (four bits now) (set if ED/EE < F7/F8) 
	ldh a, [$FFF9]
	ld l, a
	ldh a, [$FFFA]
	add a, $80
	ld h, a ;load F9/FA + $8000 into HL, tile address
	ldh a, [$FFF1]
	sub a, l
	ldh a, [$FFF2]
	sbc a, h ;compare F1/F2 to tile address
	rl c ;shift carry bit into c (set if F1/F2 < F9/FA)
	ldh a, [$FFF3]
	sub a, l
	ldh a, [$FFF4]
	sbc a, h ;compare F3/F4 to tile address
	ccf
	rl c ;shift inversed carry bit into c (set if F3/F4 >= F9/FA)
	ldh a, [$FFFB]
	ld l, a
	ldh a, [$FFFC]
	add a, $80
	ld h, a ;load FB/FC + $8000 into HL, tile address
	ldh a, [$FFEF]
	sub a, l
	ldh a, [$FFF0]
	sbc a, h ;compare EF/F0 to tile address
	ccf
	rl c ;shift inverted carry bit into c (set if EF/F0 >= FB/FC)
	ldh a, [$FFED]
	sub a, l
	ldh a, [$FFEE]
	sbc a, h ;compare ED/EE to tile address
	rl c ;shift carry bit into c (four bits now) (set if ED/EE < FB/FC)
	
	ldh a, [$FFF3]
	add a, $01
	ldh [$FFF3], a
	ldh a, [$FFF4]
	adc a, $00
	ldh [$FFF4], a ;increment F3/F4
	ldh a, [$FFEF]
	add a, $01
	ldh [$FFEF], a
	ldh a, [$FFF0]
	adc a, $00
	ldh [$FFF0], a ;increment EF/F0
	ld a, b
	or c ;OR the comparison results together
	jp z, .saveresults ;if none set, we're done
	ld a, b
	and c ;AND the comparisons together
	jp nz, .matched ;if some match, set carry flag and ret
	ld a, b
	or a
	jp z, .BFlagsNotSet ;if none set in b (but some set in c), jump
	bit 1, b
	jp z, .BBit1NotSet
	push bc ;save our flags
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF6]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld l, a
	ldh a, [$FFFA]
	sbc a, d
	ld h, a ;load F9/FA minus F5/F6 into HL
	ldh a, [$FFF7]
	ld e, a
	ldh a, [$FFF8]
	ld d, a ;F7/F8 into DE
	ldh a, [$FFFB]
	sub a, e
	ld c, a
	ldh a, [$FFFC]
	sbc a, d
	ld b, a ;load FB/FC minus F7/F8 into BC
	cp $80
	jp nc, .PopBCAndLoop ;if BC >= $8000, jump
	ldh a, [$FFEF]
	ldh [$FFF7], a ;move EF to F7
	sub a, e
	ld e, a ;subtract old F7 from EF, store E
	ldh a, [$FFF0]
	ldh [$FFF8], a
	sbc a, d
	sub $80
	ld d, a ;subtract old F8 + $80 from F0, store D
	ldh a, [$FFF8]
	sub $80
	ldh [$FFF8], a ;remove the $80 offset from F8
.BCHLLoop ;40ED
	srl b
	rr c ;low bit of B shifted into C
	bit 7, h
	jr z, .noinc ;if the high bit of H set, increment HL
	inc hl
.noinc
	sra h
	rr l ;divide HL by 2
	ld a, h
	or l
	jr z, .PopBCAndLoop ;if HL is 0
	ld a, b
	or c
	jp z, .PopBCAndLoop ;if BC is 0
	ld a, c
	cp e ;c minus e
	ld a, b
	sbc a, d ;b minus d
	jr nc, .BCHLLoop ;if bc >= de, loop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a ;de -= bc
	ldh a, [$FFF5]
	add a, l
	ldh [$FFF5], a
	ldh a, [$FFF6]
	adc a, h
	ldh [$FFF6], a ;F5/F6 += HL
	jp .BCHLLoop
	
.PopBCAndLoop;411C
	pop bc
	jp ProjectLine ;top of the function
	
.BBit1NotSet ;4120
	bit 0, b
	jp z, .Bit0NotSet
	push bc
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF6]
	ld d, a ;DE = F5/F6
	ldh a, [$FFF9]
	sub a, e
	ld l, a
	ldh a, [$FFFA]
	sbc a, d
	ld h, a ; HL = F9/FA - F5/F6
	ldh a, [$FFFB]
	ld e, a
	ldh a, [$FFFC]
	ld d, a
	ldh a, [$FFF7]
	sub a, e
	ld c, a
	ldh a, [$FFF8]
	sbc a, d
	ld b, a ; BC = F7/F8 - FB/FC
	cp $80
	jr nc, .bit1popbcloop ; if BC >= $8000, jump
	
	ldh a, [$FFED]
	ld e, a
	ldh a, [$FFEE]
	sub $80
	ld d, a ;load ED/EE - $8000 into DE
	ldh a, [$FFF7]
	sub a, e
	ld e, a
	ldh a, [$FFF8]
	sbc a, d
	ld d, a ;DE -= F7/F8
	ldh a, [$FFED]
	ldh [$FFF7], a
	ldh a, [$FFEE]
	sub $80
	ldh [$FFF8], a ;F7/F8 = ED/EE - $8000
.bit1bcloop
	srl b
	rr c
	bit 7, h
	jr z, .bit1skipinc
	inc hl
.bit1skipinc ;4160
	sra h
	rr l ;divide HL by 2
	ld a, h
	or l
	jr z, .bit1popbcloop ; if hl is 0, jump
	ld a, b
	or c
	jp z, .bit1popbcloop ;if BC is 0, loop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .bit1bcloop ;if bc >= de, jump
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a ; de -= bc
	ldh a, [$FFF5]
	add a, l
	ldh [$FFF5], a
	ldh a, [$FFF6]
	adc a, h
	ldh [$FFF6], a ;F5/F6 += HL
	jp .bit1bcloop
.bit1popbcloop ;418F
	pop bc
	jp ProjectLine ;top of func
	
.Bit0NotSet ;4193
	bit 2, b
	jp z, .Bit2NotSet
	push bc
	ldh a, [$FFF7]
	ld e, a
	ldh a, [$FFF8]
	ld d, a
	ldh a, [$FFFB]
	sub a, e
	ld l, a
	ldh a, [$FFFC]
	sbc a, d
	ld h, a ; HL = FB/FC - F7/F8
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF6]
	ld d, a ; DE = F5/F6
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFA]
	sbc a, d
	ld b, a ; BC = F9/FA - F5/F6
	cp $80
	jr nc, .b0popbcloop ;if BC >= $8000, loop
	ldh a, [$FFF3]
	ldh [$FFF5], a ; F5 = F3
	sub a, e
	ld e, a
	ldh a, [$FFF4]
	sbc a, d
	sub $80
	ld d, a ; DE = F3/F4 - F5/F6 - $8000
	jr c, .b0popbcloop ;loop if DE underflowed
	ldh a, [$FFF4]
	sub $80
	ldh [$FFF6], a ; F6 = F4-80
.b0bcloop
	srl b
	rr c ;shift BC right one
	bit 7, h
	jr z, .b0skipinc
	inc hl
.b0skipinc
	sra h
	rr l ;divide HL by 2
	ld a, h
	or l
	jr z, .b0popbcloop ;if HL is zero, loop
	ld a, b
	or c
	jp z, .b0popbcloop ;if BC is zero, loop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .b0bcloop ; if BC >= DE, jump
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a ; DE -= BC
	ldh a, [$FFF7]
	add a, l
	ldh [$FFF7], a
	ldh a, [$FFF8]
	adc a, h
	ldh [$FFF8], a ;F7/F8 += HL
	jp .b0bcloop
.b0popbcloop ;41FC
	pop bc
	jp ProjectLine ;top of func
	
.Bit2NotSet ;4200
	bit 3, b
	jp z, .BFlagsNotSet
	push bc ;these flags are from the comparisons, and determine which words
	ldh a, [$FFF7] ;to subtract from each other.
	ld e, a
	ldh a, [$FFF8]
	ld d, a
	ldh a, [$FFFB]
	sub a, e
	ld l, a
	ldh a, [$FFFC]
	sbc a, d
	ld h, a ; HL = FB/FC - F7/F8
	ldh a, [$FFF9]
	ld e, a
	ldh a, [$FFFA]
	ld d, a
	ldh a, [$FFF5]
	sub a, e
	ld c, a
	ldh a, [$FFF6]
	sbc a, d
	ld b, a ; BC = F5/F6 - F9/FA
	cp $80
	jr nc, .b2poploop ; if BC >= $8000, loop
	ldh a, [$FFF1]
	ld e, a
	ldh a, [$FFF2]
	ld d, a
	ldh a, [$FFF5]
	sub a, e
	ld e, a
	ldh a, [$FFF6]
	sbc a, d
	sub $80
	ld d, a ; DE = F5/F6 - F1/F2 - $8000
	jr c, .b2poploop
	ldh a, [$FFF1]
	ldh [$FFF5], a
	ldh a, [$FFF2]
	sub $80
	ldh [$FFF6], a ; F5/F6 = F1/F2 - $8000
.b2bcloop
	srl b
	rr c
	bit 7, h
	jr z, .b2skipinc
	inc hl
.b2skipinc
	sra h
	rr l ; divide HL by 2
	ld a, h
	or l
	jr z, .b2poploop ;if HL is 0, loop
	ld a, b
	or c
	jp z, .b2poploop ; if BC is 0, loop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .b2bcloop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a
	ldh a, [$FFF7]
	add a, l
	ldh [$FFF7], a
	ldh a, [$FFF8]
	adc a, h
	ldh [$FFF8], a
	jp .b2bcloop
.b2poploop ;4271
	pop bc
	jp ProjectLine ;top of func
	
.BFlagsNotSet ;4275
	ld a, c
	or a
	jp z, .saveresults ;c flags not set either, save results?
	bit 1, c
	jp z, .c1notset
	push bc
	ldh a, [$FFF9]
	ld e, a
	ldh a, [$FFFA]
	ld d, a
	ldh a, [$FFF5]
	sub a, e
	ld l, a
	ldh a, [$FFF6]
	sbc a, d
	ld h, a ; HL = F5/F6 - F9/FA
	ldh a, [$FFFB]
	ld e, a
	ldh a, [$FFFC]
	ld d, a
	ldh a, [$FFF7]
	sub a, e
	ld c, a
	ldh a, [$FFF8]
	sbc a, d
	ld b, a ; BC = F7/F8 - FB/FC
	cp $80
	jr nc, .c1poploop
	
	ldh a, [$FFEF]
	ldh [$FFFB], a
	sub a, e
	ld e, a
	ldh a, [$FFF0]
	ldh [$FFFC], a
	sbc a, d
	sub $80
	ld d, a
	ldh a, [$FFFC]
	sub $80
	ldh [$FFFC], a
.c1bcloop
	srl b
	rr c
	bit 7, h
	jr z, .c1skipinc
	inc hl
.c1skipinc
	sra h
	rr l
	ld a, h
	or l
	jr z, .c1poploop
	ld a, b
	or c
	jp z, .c1poploop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .c1bcloop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a
	ldh a, [$FFF9]
	add a, l
	ldh [$FFF9], a
	ldh a, [$FFFA]
	adc a, h
	ldh [$FFFA], a
	jp .c1bcloop
.c1poploop
	pop bc
	jp ProjectLine ; top of func

.c1notset ;42E7
	bit 0, c
	jp z, .c0notset
	push bc
	ldh a, [$FFF9]
	ld e, a
	ldh a, [$FFFA]
	ld d, a
	ldh a, [$FFF5]
	sub a, e
	ld l, a
	ldh a, [$FFF6]
	sbc a, d
	ld h, a ; HL = F5/F6 - FA/F9
	ldh a, [$FFF7]
	ld e, a
	ldh a, [$FFF8]
	ld d, a
	ldh a, [$FFFB]
	sub a, e
	ld c, a
	ldh a, [$FFFC]
	sbc a, d
	ld b, a ; BC = FB/FC - F7/F8
	cp $80
	jr nc, .c0poploop
	ldh a, [$FFED]
	ld e, a
	ldh a, [$FFEE]
	sub $80
	ld d, a
	ldh a, [$FFFB]
	sub a, e
	ld e, a
	ldh a, [$FFFC]
	sbc a, d
	ld d, a
	ldh a, [$FFED]
	ldh [$FFFB], a
	ldh a, [$FFEE]
	sub $80
	ldh [$FFFC], a
.c0bcloop
	srl b
	rr c
	bit 7, h
	jr z, .c0skipinc
	inc hl
.c0skipinc
	sra h
	rr l
	ld a, h
	or l
	jr z, .c0poploop
	ld a, b
	or c
	jp z, .c0poploop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .c0bcloop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a
	ldh a, [$FFF9]
	add a, l
	ldh [$FFF9], a
	ldh a, [$FFFA]
	adc a, h
	ldh [$FFFA], a
	jp .c0bcloop
.c0poploop
	pop bc
	jp ProjectLine ; top of func
	
.c0notset ;435A
	bit 2, c
	jp z, .c2notset
	push bc
	ldh a, [$FFFB]
	ld e, a
	ldh a, [$FFFC]
	ld d, a
	ldh a, [$FFF7]
	sub a, e
	ld l, a
	ldh a, [$FFF8]
	sbc a, d
	ld h, a ; HL = F7/F8 - FB/FC
	ldh a, [$FFF9]
	ld e, a
	ldh a, [$FFFA]
	ld d, a
	ldh a, [$FFF5]
	sub a, e
	ld c, a
	ldh a, [$FFF6]
	sbc a, d
	ld b, a ; BC = F5/F6 - F9/FA
	cp $80
	jr nc, .c2poploop
	ldh a, [$FFF3]
	sub a, e
	ld e, a
	ldh a, [$FFF4]
	sbc a, d
	sub $80
	ld d, a
	jr c, .c2poploop
	ldh a, [$FFF3]
	ldh [$FFF9], a
	ldh a, [$FFF4]
	sub $80
	ldh [$FFFA], a
.c2bcloop
	srl b
	rr c
	bit 7, h
	jr z, .c2skipinc
	inc hl
.c2skipinc
	sra h
	rr l
	ld a, h
	or l
	jr z, .c2poploop
	ld a, b
	or c
	jp z, .c2poploop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .c2bcloop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a
	ldh a, [$FFFB]
	add a, l
	ldh [$FFFB], a
	ldh a, [$FFFC]
	adc a, h
	ldh [$FFFC], a
	jp .c2bcloop
.c2poploop
	pop bc
	jp ProjectLine

.c2notset ;43C9
	bit 3, c
	jp z, .saveresults ;we're done here?
	push bc
	ldh a, [$FFFB] 
	ld e, a
	ldh a, [$FFFC]
	ld d, a
	ldh a, [$FFF7]
	sub a, e
	ld l, a
	ldh a, [$FFF8]
	sbc a, d
	ld h, a
	ldh a, [$FFF5]
	ld e, a
	ldh a, [$FFF6]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld c, a
	ldh a, [$FFFA]
	sbc a, d
	ld b, a
	cp $80
	jr nc, .c3poploop
	ldh a, [$FFF1]
	ld e, a
	ldh a, [$FFF2]
	ld d, a
	ldh a, [$FFF9]
	sub a, e
	ld e, a
	ldh a, [$FFFA]
	sbc a, d
	sub $80
	ld d, a
	jr c, .c3poploop
	ldh a, [$FFF1]
	ldh [$FFF9], a
	ldh a, [$FFF2]
	sub $80
	ldh [$FFFA], a
.c3bcloop
	srl b
	rr c
	bit 7, h
	jr z, .c3skipinc
	inc hl
.c3skipinc
	sra h
	rr l
	ld a, h
	or l
	jr z, .c3poploop
	ld a, b
	or c
	jp z, .c3poploop
	ld a, c
	cp e
	ld a, b
	sbc a, d
	jr nc, .c3bcloop
	ld a, e
	sub a, c
	ld e, a
	ld a, d
	sbc a, b
	ld d, a
	ldh a, [$FFFB]
	add a, l
	ldh [$FFFB], a
	ldh a, [$FFFC]
	adc a, h
	ldh [$FFFC], a
	jp .c3bcloop
.c3poploop
	pop bc
	jp ProjectLine
	
.saveresults ;443E
	ldh a, [$FFF5] ;x coord
	cp $C0 ;window width * 1.5?
	jr c, .skipclearF5
	xor a ;if greater than $C0, set it to zero
	ldh [$FFF5], a
.skipclearF5
	cp $80 ;window width
	jr c, .skiploadF5
	ld a, $7F
	ldh [$FFF5], a ;if greater than window width, set it to $7F
.skiploadF5
	ldh a, [$FFF9] ;x delta
	cp $C0
	jr c, .skipclearF9
	xor a
	ldh [$FFF9], a
.skipclearF9
	cp $80
	jr c, .skiploadF9
	ld a, $7F
	ldh [$FFF9], a
.skiploadF9
	ldh a, [$FFF7] ;y coord
	cp $AC ;window height * 1.5?
	jr c, .skipclearF7
	xor a
	ldh [$FFF7], a ;if greater than, set to zero
.skipclearF7
	cp $58 ;window height
	jr c, .skiploadF7
	ld a, $57
	ldh [$FFF7], a ;if greater than window height, set it to $57
.skiploadF7
	ldh a, [$FFFB] ;y delta
	cp $AC
	jr c, .skipclearFB
	xor a
	ldh [$FFFB], a
.skipclearFB
	cp $58
	jr c, .skiploadFB
	ld a, $57
	ldh [$FFFB], a
.skiploadFB
	xor a ;clears carry flag
	ret
.matched ;0x4484
	scf
	ret
	
CallDrawVerticalLine: ;4486
	ld a, b
	or a
	ret z ;return if B is also zero
	bit 7, b
	jr nz, .invertb ;if top bit set, jump
	ld a, e
	ld e, b ;passed B becomes E
	ld c, a
	ld b, d ;passed DE becomes BC
	jp DrawVerticalLine
.invertb
	ld a, b
	cpl
	inc a
	ld c, e
	ld b, d
	ld e, a ;e = negative passed b
	ld a, b
	sub a, e
	ld b, a ;bc = passed de minus passed b
	jp DrawVerticalLine 
	
CallDrawHorizontalLine: ;44A0
	ld a, c
	or a
	ret z ;return if C also zero
	bit 7, c
	jr nz, .invertc ;if top bit set, jump
	ld a, e
	ld e, c ;passed c becomes e (length)
	ld c, a
	ld b, d ;bc = passed de (position)
	jp DrawHorizontalLine
.invertc
	ld a, c
	cpl
	inc a
	ld c, e
	ld b, d
	ld e, a ;e = negative passed c
	ld a, c
	sub a, e
	ld c, a ; bc = passed de - passed c
	jp DrawHorizontalLine
	
DrawLine: ;44BA
	;uses passed BC (deltaY and deltaX) and DE (coordinate)
	;to draw a line in WRAM1
	ld a, c
	or a
	jr z, CallDrawVerticalLine ;if passed c is 0, jump
	ld a, b
	or a
	jr z, CallDrawHorizontalLine ;if passed b is 0, jump
	ld a, e
	and $07
	ld h, $00
	ld l, a ;HL is offset into start of rom, usng low 3 bits of passed e
	ld a, e
	and $F8 ;high 5 bits of passed e
	rrca
	rrca
	rrca
	ld e, a ;shift the other bits down, store it back
	ldh a, [$FF9B] ;intro sets this to $D0
	add a, e ;add FF9B to saved bits
	ld e, [hl] ;grab our mask from start of rom
	ld h, a ;saved bits 
	ld l, d ;passed d
	ld a, e
	or [hl] ;apply the mask to our $DXXX value
	ld [hl], a
	bit 7, c
	jp nz, .DrawLineNegativeDeltaX ;if top bit of passed c is set, jump (negative C)
	bit 7, b
	jp nz, DrawLineNegativeDeltaY ;if top bit of passed b is set, jump (negative B)
	ld a, b
	cp c
	jr c, .DrawLineOct2 ; if c > b, jump to 4540
	or a
	ret z ;if b == c, return
	;otherwise, this is octant 1
	ld a, c
	ld d, b
	srl d
	ld c, b
	ldh [$FFFE], a ;save our passed c to FFFE
	inc l
.loop ;44F0
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skeep
	sub a, c
	rrc e
	jr c, .topbiteset
.skeep
	ld d, a
	ld a, e
	or [hl]
	ld [hl+], a ;adding bits to values
	dec b ;passed b is our loop counter
	jp nz, .loop
	ret
.topbiteset
	ld d, a
	inc h
	ld a, e ;go up a page
	or [hl]
	ld [hl+], a ;|| our bits to the [hl] value
	dec b ;passed b is loop counter
	jp nz, .loop
	ret
	
.DrawLineNegativeDeltaX ;450E (C was negative)
	ld a, c
	cpl
	inc a
	ld c, a
	bit 7, b
	jp nz, DrawLineBothDeltasNegative ;(B and C were negative)
	cp b
	jp nc, DrawLineOct7 ;(-C >= B)
	ld a, b
	or a
	ret z
	;else we're drawing octant 8
	ld a, c
	ld d, b
	srl d
	ld c, b
	ldh [$FFFE], a
	inc l
.lowloop ;4526
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skip1
	sub a, c
	rlc e
	jr c, .part2 ;453A
.skip1
	ld d, a
	ld a, e
	or [hl] ;mask!
	ld [hl+], a
	dec b
	jp nz, .lowloop
	ret
.part2 ;453A
	ld d, a
	dec h
	ld a, e
	or [hl] ;more of this masking
	ld [hl+], a
	dec b
	jp nz, .lowloop
	ret
	
.DrawLineOct2 ;4544 (C > B and both are positive)
	ld d, c
	srl d
	ld a, c
	or a
	ret z
	ld a, b
	ld b, c
	ldh [$FFFE], a
.lowerloop ;454E
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipinc
	sub a, c
	inc l
.skipinc
	ld d, a
	rrc e
	jr c, .l4563
	ld a, e
	or [hl] ;more mask shenanigans
	ld [hl], a
	dec b
	jp nz, .lowerloop
	ret
.l4563 ;4563
	inc h
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .lowerloop
	ret
	
DrawLineOct7: ;456C (-C >= B)
	ld d, c
	srl d
	ld a, c
	or a
	ret z
	ld a, b
	ld b, c
	ldh [$FFFE], a
.loop ;4576
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipinc
	sub a, c
	inc l
.skipinc
	ld d, a
	rlc e
	jr c, .l458B
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
.l458B ;458B
	dec h
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
	
DrawLineOct4: ;4594 (-B < C)
	ld a, c
	or a
	ret z
	ld a, b
	ld d, c
	srl d
	ld b, c
	ldh [$FFFE], a
.loop ;459E
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipdec
	sub a, c
	dec l
.skipdec
	ld d, a
	rrc e
	jr c, .l45B3
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
.l45B3 ;45B3
	inc h
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
	
DrawLineOct6: ;45BC ;(-C >= -B)
	ld a, c
	or a
	ret z
	ld a, b
	ld d, c
	srl d
	ld b, c
	ldh [$FFFE], a
.loop ;45C6
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipdec
	sub a, c
	dec l
.skipdec
	ld d, a
	rlc e
	jr c, .l45DB
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
.l45DB ;45DB
	dec h
	ld a, e
	or [hl]
	ld [hl], a
	dec b
	jp nz, .loop
	ret
	
DrawLineBothDeltasNegative: ;45E4 ;b and c were both negative
	ld a, b
	cpl
	inc a
	ret z ;0 negates back to zero, this is yet another zero check
	ld b, a
	ld a, c
	cp b
	jp nc, DrawLineOct6 ; (-C >= -B)
	;else we're drawing octant 5
	ld d, b
	srl d
	ld c, b
	ldh [$FFFE], a
	dec l
.loop ;45F5
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipjrc
	sub a, c
	rlc e
	jr c, .l4609
.skipjrc
	ld d, a
	ld a, e
	or [hl]
	ld [hl-], a
	dec b
	jp nz, .loop
	ret
.l4609 ;4609
	ld d, a
	dec h
	ld a, e
	or [hl]
	ld [hl-], a
	dec b
	jp nz, .loop
	ret
	
DrawLineNegativeDeltaY: ;4613 (b was negative)
	ld a, b
	cpl
	inc a
	ret z
	ld b, a
	cp c
	jp c, DrawLineOct4 ;(if -B < C)
	;else we're drawing octant 3
	ld a, c
	ld d, b
	srl d
	ld c, b
	ldh [$FFFE], a
	dec l
.loop ;4624
	ldh a, [$FFFE]
	add a, d
	cp c
	jr c, .skipjrc
	sub a, c
	rrc e
	jr c, .l4638
.skipjrc
	ld d, a
	ld a, e
	or [hl]
	ld [hl-], a
	dec b
	jp nz, .loop
	ret
.l4638 ;4638
	ld d, a
	inc h
	ld a, e
	or [hl]
	ld [hl-], a
	dec b
	jp nz, .loop
	ret

BallFrameTable: ;4642-4741 is a table of offsets for all the sprites below
	dw .Ball_16_1_GFX, .Ball_16_2_GFX, .Ball_16_3_GFX, .Ball_16_4_GFX, .Ball_16_5_GFX, .Ball_16_6_GFX, .Ball_16_7_GFX, .Ball_16_8_GFX 
	dw .Ball_15_1_GFX, .Ball_15_2_GFX, .Ball_15_3_GFX, .Ball_15_4_GFX, .Ball_15_5_GFX, .Ball_15_6_GFX, .Ball_15_7_GFX, .Ball_15_8_GFX 
	dw .Ball_14_1_GFX, .Ball_14_2_GFX, .Ball_14_3_GFX, .Ball_14_4_GFX, .Ball_14_5_GFX, .Ball_14_6_GFX, .Ball_14_7_GFX, .Ball_14_8_GFX 
	dw .Ball_13_1_GFX, .Ball_13_2_GFX, .Ball_13_3_GFX, .Ball_13_4_GFX, .Ball_13_5_GFX, .Ball_13_6_GFX, .Ball_13_7_GFX, .Ball_13_8_GFX 
	dw .Ball_12_1_GFX, .Ball_12_2_GFX, .Ball_12_3_GFX, .Ball_12_4_GFX, .Ball_12_5_GFX, .Ball_12_6_GFX, .Ball_12_7_GFX, .Ball_12_8_GFX 
	dw .Ball_11_1_GFX, .Ball_11_2_GFX, .Ball_11_3_GFX, .Ball_11_4_GFX, .Ball_11_5_GFX, .Ball_11_6_GFX, .Ball_11_7_GFX, .Ball_11_8_GFX 
	dw .Ball_10_1_GFX, .Ball_10_2_GFX, .Ball_10_3_GFX, .Ball_10_4_GFX, .Ball_10_5_GFX, .Ball_10_6_GFX, .Ball_10_7_GFX, .Ball_10_8_GFX 
	dw .Ball_9_1_GFX, .Ball_9_2_GFX, .Ball_9_3_GFX, .Ball_9_4_GFX, .Ball_9_5_GFX, .Ball_9_6_GFX, .Ball_9_7_GFX, .Ball_9_8_GFX 
	dw .Ball_8_1_GFX, .Ball_8_2_GFX, .Ball_8_3_GFX, .Ball_8_4_GFX, .Ball_8_5_GFX, .Ball_8_6_GFX, .Ball_8_7_GFX, .Ball_8_8_GFX 
	dw .Ball_7_1_GFX, .Ball_7_2_GFX, .Ball_7_3_GFX, .Ball_7_4_GFX, .Ball_7_5_GFX, .Ball_7_6_GFX, .Ball_7_7_GFX, .Ball_7_8_GFX 
	dw .Ball_6_1_GFX, .Ball_6_2_GFX, .Ball_6_3_GFX, .Ball_6_4_GFX, .Ball_6_5_GFX, .Ball_6_6_GFX, .Ball_6_7_GFX, .Ball_6_8_GFX 
	dw .Ball_5_1_GFX, .Ball_5_2_GFX, .Ball_5_3_GFX, .Ball_5_4_GFX, .Ball_5_5_GFX, .Ball_5_6_GFX, .Ball_5_7_GFX, .Ball_5_8_GFX 
	dw .Ball_4_1_GFX, .Ball_4_2_GFX, .Ball_4_3_GFX, .Ball_4_4_GFX, .Ball_4_5_GFX, .Ball_4_6_GFX, .Ball_4_7_GFX, .Ball_4_8_GFX 
	dw .Ball_3_1_GFX, .Ball_3_2_GFX, .Ball_3_3_GFX, .Ball_3_4_GFX, .Ball_3_5_GFX, .Ball_3_6_GFX, .Ball_3_7_GFX, .Ball_3_8_GFX 
	dw .Ball_2_1_GFX, .Ball_2_2_GFX, .Ball_2_3_GFX, .Ball_2_4_GFX, .Ball_2_5_GFX, .Ball_2_6_GFX, .Ball_2_7_GFX, .Ball_2_8_GFX 
	dw .Ball_1_1_GFX, .Ball_1_2_GFX, .Ball_1_3_GFX, .Ball_1_4_GFX, .Ball_1_5_GFX, .Ball_1_6_GFX, .Ball_1_7_GFX, .Ball_1_8_GFX 
	
;4742: 16-width oval
.Ball_16_1_GFX
.Ball_16_2_GFX
	INCBIN "build/gfx/Ball_16_1.1bpp"
.Ball_16_3_GFX
.Ball_16_4_GFX
	INCBIN "build/gfx/Ball_16_3.1bpp"
.Ball_16_5_GFX
.Ball_16_6_GFX
	INCBIN "build/gfx/Ball_16_5.1bpp"
.Ball_16_7_GFX
.Ball_16_8_GFX
	INCBIN "build/gfx/Ball_16_7.1bpp"
;4802: 15-width oval
.Ball_15_1_GFX
.Ball_15_2_GFX
	INCBIN "build/gfx/Ball_15_1.1bpp"
.Ball_15_3_GFX
.Ball_15_4_GFX
	INCBIN "build/gfx/Ball_15_3.1bpp"
.Ball_15_5_GFX
.Ball_15_6_GFX
	INCBIN "build/gfx/Ball_15_5.1bpp"
.Ball_15_7_GFX
.Ball_15_8_GFX
	INCBIN "build/gfx/Ball_15_7.1bpp"
;48C2: 14-width oval
.Ball_14_1_GFX
.Ball_14_2_GFX
	INCBIN "build/gfx/Ball_14_1.1bpp"
.Ball_14_3_GFX
.Ball_14_4_GFX
	INCBIN "build/gfx/Ball_14_3.1bpp"
.Ball_14_5_GFX
.Ball_14_6_GFX
	INCBIN "build/gfx/Ball_14_5.1bpp"
.Ball_14_7_GFX
.Ball_14_8_GFX
	INCBIN "build/gfx/Ball_14_7.1bpp"
;4982: 13-width oval
.Ball_13_1_GFX
.Ball_13_2_GFX
	INCBIN "build/gfx/Ball_13_1.1bpp"
.Ball_13_3_GFX
.Ball_13_4_GFX
	INCBIN "build/gfx/Ball_13_3.1bpp"
.Ball_13_5_GFX
.Ball_13_6_GFX
	INCBIN "build/gfx/Ball_13_5.1bpp"
.Ball_13_7_GFX
.Ball_13_8_GFX
	INCBIN "build/gfx/Ball_13_7.1bpp"
;4A42: 12-width oval
.Ball_12_1_GFX
.Ball_12_2_GFX
	INCBIN "build/gfx/Ball_12_1.1bpp"
.Ball_12_3_GFX
.Ball_12_4_GFX
	INCBIN "build/gfx/Ball_12_3.1bpp"
.Ball_12_5_GFX
.Ball_12_6_GFX
	INCBIN "build/gfx/Ball_12_5.1bpp"
.Ball_12_7_GFX
.Ball_12_8_GFX
	INCBIN "build/gfx/Ball_12_7.1bpp"
;4B02: 11-width oval
.Ball_11_1_GFX
.Ball_11_2_GFX
	INCBIN "build/gfx/Ball_11_1.1bpp"
.Ball_11_3_GFX
.Ball_11_4_GFX
	INCBIN "build/gfx/Ball_11_3.1bpp"
.Ball_11_5_GFX
.Ball_11_6_GFX
	INCBIN "build/gfx/Ball_11_5.1bpp"
.Ball_11_7_GFX
.Ball_11_8_GFX
	INCBIN "build/gfx/Ball_11_7.1bpp"
;4BC2: 10-width oval
.Ball_10_1_GFX
.Ball_10_2_GFX
	INCBIN "build/gfx/Ball_10_1.1bpp"
.Ball_10_3_GFX
.Ball_10_4_GFX
	INCBIN "build/gfx/Ball_10_3.1bpp"
.Ball_10_5_GFX
.Ball_10_6_GFX
	INCBIN "build/gfx/Ball_10_5.1bpp"
.Ball_10_7_GFX
.Ball_10_8_GFX
	INCBIN "build/gfx/Ball_10_7.1bpp"
;4C82: 9-width oval
.Ball_9_1_GFX
.Ball_9_2_GFX
	INCBIN "build/gfx/Ball_9_1.1bpp"
.Ball_9_3_GFX
.Ball_9_4_GFX
	INCBIN "build/gfx/Ball_9_3.1bpp"
.Ball_9_5_GFX
.Ball_9_6_GFX
	INCBIN "build/gfx/Ball_9_5.1bpp"
.Ball_9_7_GFX
.Ball_9_8_GFX
	INCBIN "build/gfx/Ball_9_7.1bpp"
;4D42: 8-width oval
.Ball_8_1_GFX
.Ball_8_2_GFX
	INCBIN "build/gfx/Ball_8_1.1bpp"
	INCBIN "build/gfx/Ball_8_2.1bpp" ;widths 8 - 5 all have 4 unused precisions???
.Ball_8_3_GFX
.Ball_8_4_GFX
	INCBIN "build/gfx/Ball_8_3.1bpp"
	INCBIN "build/gfx/Ball_8_4.1bpp"
.Ball_8_5_GFX
.Ball_8_6_GFX
	INCBIN "build/gfx/Ball_8_5.1bpp"
	INCBIN "build/gfx/Ball_8_6.1bpp"
.Ball_8_7_GFX
.Ball_8_8_GFX
	INCBIN "build/gfx/Ball_8_7.1bpp"
	INCBIN "build/gfx/Ball_8_8.1bpp"
;4DC2: 7-width oval
.Ball_7_1_GFX
.Ball_7_2_GFX
	INCBIN "build/gfx/Ball_7_1.1bpp"
	INCBIN "build/gfx/Ball_7_2.1bpp"
.Ball_7_3_GFX
.Ball_7_4_GFX
	INCBIN "build/gfx/Ball_7_3.1bpp"
	INCBIN "build/gfx/Ball_7_4.1bpp"
.Ball_7_5_GFX
.Ball_7_6_GFX
	INCBIN "build/gfx/Ball_7_5.1bpp"
	INCBIN "build/gfx/Ball_7_6.1bpp"
.Ball_7_7_GFX
.Ball_7_8_GFX
	INCBIN "build/gfx/Ball_7_7.1bpp"
	INCBIN "build/gfx/Ball_7_8.1bpp"
;4E42: 6-width oval
.Ball_6_1_GFX
.Ball_6_2_GFX
	INCBIN "build/gfx/Ball_6_1.1bpp"
	INCBIN "build/gfx/Ball_6_2.1bpp"
.Ball_6_3_GFX
.Ball_6_4_GFX
	INCBIN "build/gfx/Ball_6_3.1bpp"
	INCBIN "build/gfx/Ball_6_4.1bpp"
.Ball_6_5_GFX
.Ball_6_6_GFX
	INCBIN "build/gfx/Ball_6_5.1bpp"
	INCBIN "build/gfx/Ball_6_6.1bpp"
.Ball_6_7_GFX
.Ball_6_8_GFX
	INCBIN "build/gfx/Ball_6_7.1bpp"
	INCBIN "build/gfx/Ball_6_8.1bpp"
;4EC2: 5-width oval
.Ball_5_1_GFX
.Ball_5_2_GFX
	INCBIN "build/gfx/Ball_5_1.1bpp"
	INCBIN "build/gfx/Ball_5_2.1bpp"
.Ball_5_3_GFX
.Ball_5_4_GFX
	INCBIN "build/gfx/Ball_5_3.1bpp"
	INCBIN "build/gfx/Ball_5_4.1bpp"
.Ball_5_5_GFX
.Ball_5_6_GFX
	INCBIN "build/gfx/Ball_5_5.1bpp"
	INCBIN "build/gfx/Ball_5_6.1bpp"
.Ball_5_7_GFX
.Ball_5_8_GFX
	INCBIN "build/gfx/Ball_5_7.1bpp"
	INCBIN "build/gfx/Ball_5_8.1bpp"
;4F42: 4-width oval
.Ball_4_1_GFX
	INCBIN "build/gfx/Ball_4_1.1bpp"
.Ball_4_2_GFX
	INCBIN "build/gfx/Ball_4_2.1bpp"
.Ball_4_3_GFX
	INCBIN "build/gfx/Ball_4_3.1bpp"
.Ball_4_4_GFX
	INCBIN "build/gfx/Ball_4_4.1bpp"
.Ball_4_5_GFX
	INCBIN "build/gfx/Ball_4_5.1bpp"
.Ball_4_6_GFX
	INCBIN "build/gfx/Ball_4_6.1bpp"
.Ball_4_7_GFX
	INCBIN "build/gfx/Ball_4_7.1bpp"
.Ball_4_8_GFX
	INCBIN "build/gfx/Ball_4_8.1bpp"
;4FC2: 3-width oval
.Ball_3_1_GFX
	INCBIN "build/gfx/Ball_3_1.1bpp"
.Ball_3_2_GFX
	INCBIN "build/gfx/Ball_3_2.1bpp"
.Ball_3_3_GFX
	INCBIN "build/gfx/Ball_3_3.1bpp"
.Ball_3_4_GFX
	INCBIN "build/gfx/Ball_3_4.1bpp"
.Ball_3_5_GFX
	INCBIN "build/gfx/Ball_3_5.1bpp"
.Ball_3_6_GFX
	INCBIN "build/gfx/Ball_3_6.1bpp"
.Ball_3_7_GFX
	INCBIN "build/gfx/Ball_3_7.1bpp"
.Ball_3_8_GFX
	INCBIN "build/gfx/Ball_3_8.1bpp"
;4FF2: 2-width oval
.Ball_2_1_GFX
	INCBIN "build/gfx/Ball_2_1.1bpp"
.Ball_2_2_GFX
	INCBIN "build/gfx/Ball_2_2.1bpp"
.Ball_2_3_GFX
	INCBIN "build/gfx/Ball_2_3.1bpp"
.Ball_2_4_GFX
	INCBIN "build/gfx/Ball_2_4.1bpp"
.Ball_2_5_GFX
	INCBIN "build/gfx/Ball_2_5.1bpp"
.Ball_2_6_GFX
	INCBIN "build/gfx/Ball_2_6.1bpp"
.Ball_2_7_GFX
	INCBIN "build/gfx/Ball_2_7.1bpp"
.Ball_2_8_GFX
	INCBIN "build/gfx/Ball_2_8.1bpp"
;5012 - 5021: 1-width oval
.Ball_1_1_GFX
	INCBIN "build/gfx/Ball_1_1.1bpp"
.Ball_1_2_GFX
	INCBIN "build/gfx/Ball_1_2.1bpp"
.Ball_1_3_GFX
	INCBIN "build/gfx/Ball_1_3.1bpp"
.Ball_1_4_GFX
	INCBIN "build/gfx/Ball_1_4.1bpp"
.Ball_1_5_GFX
	INCBIN "build/gfx/Ball_1_5.1bpp"
.Ball_1_6_GFX
	INCBIN "build/gfx/Ball_1_6.1bpp"
.Ball_1_7_GFX
	INCBIN "build/gfx/Ball_1_7.1bpp"
.Ball_1_8_GFX
	INCBIN "build/gfx/Ball_1_8.1bpp"
	
EntityLogicPointers: ;5022 - 50CB: two-byte table. Pointers for entity logic.
	dw EntityLogicCoinbox, CallEntityLogicTank, EntityLogicBase, CallEntityLogicToughEnemy ;1
	dw EntityLogicGun, EntityLogicRamp, EntityLogicGlider, BLANK_POINTER ;5
	dw CallEntityLogicBomb, EntityLogicSpewer, CallEntityLogicMilitaryBase, EntityLogicPowerCrystal ;9
	dw BLANK_POINTER, CallEntityLogicHomingMissile, EntityLogicTrackingMissile, CallEntityLogicReactorRod ;D
	dw CallEntityLogicLittleMan, EntityLogicTimeBomb, CallEntityLogicBlackBox, EntityLogicSpinMissile ;11
	dw BLANK_POINTER, CallEntityLogicSprog1, EntityLogicMine, CallEntityLogicNuclearSilo ;15
	dw BLANK_POINTER, EntityLogicAlienBase1, EntityLogicCivilianBase, BLANK_POINTER ;19
	dw EntityLogicInsectThing, CallEntityLogicCoin, CallEntityLogicWarehouse, CallCruiseMissileLogic ;1D
	dw CallEntityLogicSprog3ScenerySix, EntityLogicMushroom, CallEntityLogicSuperGun, CallEntityLogicNukeBomb ;21
	dw EntityLogicGasCan, EntityLogicGasStation, CallEntityLogicTruck, CallEntityLogicTruck ;25
	dw CallEntityLogicArrow, BLANK_POINTER, BLANK_POINTER, CallEntityLogicToughEnemy ;29 ;arrow can safely be changed to blank
	dw CallGenericEnemyLogic, CallLightTankManLogic, BLANK_POINTER, CallEntityLogicTunnelEntrance ;2D
	dw CallLightTankManLogic, CallGenericEnemyLogic, CallGenericEnemyLogic, CallEntityLogicToughEnemy ;31
	dw BLANK_POINTER, CallGenericEnemyLogic, BLANK_POINTER, CallEntityLogicChrysalis ;35
	dw CallEntityLogicToughEnemy, CallGenericEnemyLogic, CallGenericEnemyLogic, EntityLogicMissilePickup ;39
	dw BLANK_POINTER, BLANK_POINTER, BLANK_POINTER, CallEntityLogicSceneryThree ;3D
	dw BLANK_POINTER, BLANK_POINTER, CallEntityLogicMiniRadar, CallEntityLogicButterfly ;41
	dw CallEntityLogicSprog3ScenerySix, BLANK_POINTER, CallEntityLogicToughEnemy, CallEntityLogicToughEnemy ;45
	dw CallEntityLogicToughEnemy, CallGenericEnemyLogic, EntityLogicAlienBase2, CallDrakeEntityLogic ;49
	dw CallEntityLogicTank, CallGenericEnemyLogic, CallGenericEnemyLogic, CallDrakeEntityLogic ;4D
	dw CallGenericEnemyLogic, CallEntityLogicToughEnemy, CallEntityLogicToughEnemy, EntityLogicSceneryEight ;51
	dw BLANK_POINTER ;55
	
EntityHealthValues: ;50CC - 5121: one-byte table. default entity health values.
	db $00, $04, $02, $1E, $04, $23, $14, $0A, $02, $01, $0E, $C8, $32, $32, $04, $FF, $C8, $04, $12, $05, $01, $09, $00, $03, $FF, $03, $32, $14, $18, $0F, $01, $FF, $0F, $0F, $02, $0F, $19, $0F, $2D, $05, $0F, $FF, $FF, $0A, $19, $0A, $46, $FF, $FF, $0F, $0A, $02, $01, $1E, $02, $14, $0A, $0A, $13, $01, $0A, $00, $14, $1E, $14, $14, $14, $00, $08, $02, $00, $01, $0F, $19, $0A, $1E, $0A, $09, $02, $14, $13, $14, $04, $14, $0A, $0A
IgnoreModelForClosestTable: ;5122 - 5177 is a table(s) of 1 or 0
	db 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
	
ObjectNamePointerTable:;5178-5227: pointers to text block (these are NOT just in order lol)
	dw objname_Cube
	dw objname_Tank
	dw objname_Radar
	dw objname_Gameboy 
	dw objname_Gun 
	dw objname_Pyramid
	dw objname_Sfx_Glider
	dw objname_Homing_Beacon ;8
	dw objname_Bomb
	dw objname_Bird_Silo
	dw objname_Military_Base
	dw objname_Power_Crystal 
	dw objname_Petrified_Tree 
	dw objname_Homing_Missile 
	dw objname_Homing_Missile 
	dw objname_Reactor_Rod ;10
	dw objname_Little_Man 
	dw objname_Time_Bomb 
	dw objname_Black_Box 
	dw objname_Homing_Missile
	dw objname_Pendulum 
	dw objname_Sprog1
	dw objname_Mine
	dw objname_Nuclear_Silo ;18
	dw objname_Mutating_Plant 
	dw objname_Alien_Base1
	dw objname_Civilian_Base
	dw objname_Sprog2
	dw objname_Insect_Thing
	dw objname_Coin
	dw objname_Warehouse 
	dw objname_Cruise_Missile ;20
	dw objname_Sprog3 
	dw objname_Mushroom 
	dw objname_Super_Gun 
	dw objname_Nuke_Bomb 
	dw objname_Gas_Can
	dw objname_Gas_Station 
	dw objname_Truck 
	dw objname_Another_Truck ;28
	dw objname_Arrow
	dw objname_Wall 
	dw objname_Grasshopper 
	dw objname_Flower1 
	dw objname_Larva 
	dw objname_Man 
	dw objname_Scorpion
	dw objname_Tunnel_Entrance ;30
	dw objname_Light_Tank 
	dw objname_Heavy_Tank
	dw objname_Small_Tank 
	dw objname_Skimmer 
	dw objname_Cone 
	dw objname_Crab
	dw objname_Rocket_Launcher
	dw objname_Chrysalis ;38
	dw objname_Flower2
	dw objname_Spider 
	dw objname_Mouse
	dw objname_Collect_Missile 
	dw objname_Transporter 
	dw objname_Scenery_One
	dw objname_Scenery_Two
	dw objname_Scenery_Three ;40
	dw objname_Scenery_Four
	dw objname_Scenery_Five
	dw objname_Mini_Radar 
	dw objname_Butterfly
	dw objname_Scenery_Six 
	dw objname_Scenery_Seven
	dw objname_Plane_One 
	dw objname_Plane_Three ;48
	dw objname_Plane_Four 
	dw objname_Sugino_Tank_Four
	dw objname_Alien_Base2 
	dw objname_Drake
	dw objname_Sledge 
	dw objname_Sugi_Tank_One 
	dw objname_Sugi_Tank_Two 
	dw objname_Sugi_Tank_Three ;50
	dw objname_Sugi_Tank_Five 
	dw objname_Drake_Two
	dw objname_Sea_Plane 
	dw objname_Scenery_Eight 
	dw objname_Scenery_Nine
	dw objname_Cube
	dw objname_Cube
	dw objname_Cube ;58
;5228-557E: text block
objname_Cube:	db "CUBE", 00
objname_Tank:	db "TANK", 00
objname_Radar:	db "RADAR", 00
objname_Gameboy:	db "GAMEBOY", 00
objname_Gun:	db "GUN", 00
objname_Pyramid:	db "PYRAMID", 00
objname_Sfx_Glider:	db "SFX GLIDER", 00
objname_Homing_Beacon:	db "HOMING BEACON", 00
objname_Bomb:	db "BOMB", 00
objname_Bird_Silo:	db "BIRD SILO", 00
objname_Military_Base:	db "MILITARY BASE", 00
objname_Power_Crystal:	db "POWER CRYSTAL", 00
objname_Petrified_Tree:	db "PETRIFIED TREE", 00
objname_Homing_Missile:	db "HOMING MISSILE", 00
objname_Pendulum:	db "PENDULUM", 00
objname_Sprog1:	db "SPROG", 00
objname_Mine:	db "MINE", 00
objname_Nuclear_Silo:	db "NUCLEAR SILO", 00
objname_Mutating_Plant:	db "MUTATING PLANT", 00
objname_Alien_Base1:	db "ALIEN BASE", 00
objname_Civilian_Base:	db "CIVILIAN BASE", 00
objname_Sprog2:	db "SPROG", 00
objname_Insect_Thing:	db "INSECT THING", 00
objname_Coin:	db "COIN", 00
objname_Warehouse:	db "WAREHOUSE", 00
objname_Cruise_Missile:	db "CRUISE MISSILE", 00
objname_Sprog3:	db "SPROG", 00
objname_Mushroom:	db "MUSHROOM", 00
objname_Super_Gun:	db "SUPER GUN", 00
objname_Nuke_Bomb:	db "NUKE BOMB", 00
objname_Gas_Can:	db "GAS CAN", 00
objname_Gas_Station:	db "GAS STATION", 00
objname_Truck:	db "TRUCK", 00
objname_Another_Truck:	db "ANOTHER TRUCK", 00
objname_Black_Box:	db "BLACK BOX", 00
objname_Time_Bomb:	db "TIME BOMB", 00
objname_Little_Man:	db "LITTLE MAN", 00
objname_Reactor_Rod:	db "REACTOR ROD", 00
objname_Arrow:	db "ARROW", 00
objname_Wall:	db "WALL", 00
objname_Grasshopper:	db "GRASSHOPPER", 00
objname_Flower1: db "FLOWER", 00
objname_Larva:	db "LARVA", 00
objname_Man:	db "MAN", 00
objname_Scorpion:	db "SCORPION", 00
objname_Tunnel_Entrance:	db "TUNNEL ENTRANCE", 00
objname_Light_Tank:	db "LIGHT TANK", 00
objname_Heavy_Tank:	db "HEAVY TANK", 00
objname_Small_Tank:	db "SMALL TANK", 00
objname_Skimmer:	db "SKIMMER", 00
objname_Cone:	db "CONE", 00
objname_Crab:	db "CRAB", 00
objname_Rocket_Launcher:	db "ROCKET LAUNCHER", 00
objname_Chrysalis:	db "CHRYSALIS", 00
objname_Flower2:	db "FLOWER", 00
objname_Spider:	db "SPIDER", 00
objname_Mouse:	db "MOUSE", 00
objname_Collect_Missile:	db "COLLECT MISSILE", 00
objname_Transporter:	db "TRANSPORTER", 00
objname_Scenery_One:	db "SCENERY ONE", 00
objname_Scenery_Two:	db "SCENERY TWO", 00
objname_Scenery_Three:	db "SCENERY THREE", 00
objname_Scenery_Four:	db "SCENERY FOUR", 00
objname_Scenery_Five:	db "SCENERY FIVE", 00
objname_Mini_Radar:	db "MINI RADAR", 00
objname_Butterfly:	db "BUTTERFLY", 00
objname_Scenery_Six:	db "SCENERY SIX", 00
objname_Scenery_Seven:	db "SCENERY SEVEN", 00
objname_Plane_One:	db "PLANE ONE", 00
objname_Plane_Three:	db "PLANE THREE", 00
objname_Plane_Four:	db "PLANE FOUR", 00
objname_Sugino_Tank_Four:	db "SUGINO TANK FOUR", 00
objname_Alien_Base2:	db "ALIEN BASE", 00
objname_Drake:	db "DRAKE", 00
objname_Sledge:	db "SLEDGE", 00
objname_Sugi_Tank_One:	db "SUGI TANK ONE", 00
objname_Sugi_Tank_Two:	db "SUGI TANK TWO", 00
objname_Sugi_Tank_Three:	db "SUGI TANK THREE", 00
objname_Sugi_Tank_Five:	db "SUGI TANK FIVE", 00
objname_Drake_Two:	db "DRAKE TWO", 00
objname_Sea_Plane:	db "SEA PLANE", 00
objname_Scenery_Eight:	db "SCENERY EIGHT", 00
objname_Scenery_Nine:	db "SCENERY NINE", 00
	
ScreenScatter: ;557F
	ld hl, $8800
	ld bc, $0400
.loop
	call NextRand
	ld d, a
	cpl
	ld e, a
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl]
	and e
	ld [hl+], a
	ld a, [hl]
	and d
	ld [hl+], a
	ld a, [hl]
	and e
	ld [hl+], a
	ld a, [hl]
	and d
	ld [hl+], a
	dec c
	jr nz, .loop
	dec b
	jr nz, .loop
	ret

SECTION "BGScatter", ROMX[$55A4], BANK[2]
BGScatter: ;55A4
	ld hl, $8000 ;start of video ram
	ld bc, $0200 ;loop counter
.loop
	call NextRand
	ld d, a
	cpl
	ld e, a
.inloop
	ld a, [rSTAT] 
	and 02 
	jr nz, .inloop ;wait until we're searching oam/ram
	ld a, [hl] ;start masking off 4*0x200 bytes
	and e
	ld [hl+], a
	ld a, [hl] 
	and d
	ld [hl+], a
	ld a, [hl] 
	and e
	ld [hl+], a
	ld a, [hl] 
	and d
	ld [hl+], a
	dec c
	jr nz, .loop 
	dec b
	jr nz, .loop
	ret
;55C9

SECTION "2:5729", ROMX[$5729], BANK[2]
DrawFloorDots: ;5729
	ld bc, $0100
	ld de, $0000
	ld a, [wViewDir]
	call CallProjectXYToCamera ;some sort of projection i think
	ld a, b
	ldh [$FFD8], a
	ldh [$FFD6], a
	ld a, c
	ldh [$FFD7], a
	ldh [$FFD5], a
	ld a, e
	ldh [$FFD9], a
	cpl
	add a, $01
	ldh [$FFD3], a
	ld a, d
	ldh [$FFDA], a
	cpl
	adc a, $00
	ldh [$FFD4], a
	ldh a, [$FFD7]
	cpl
	add a, $01
	ld c, a
	ldh a, [$FFD8]
	cpl
	adc a, $00
	ld b, a
	ldh a, [$FFD3]
	cpl
	add a, $01
	ld e, a
	ldh a, [$FFD4]
	cpl
	adc a, $00
	ld d, a
	ld a, c
	add a, e
	ld c, a
	ld a, b
	adc a, d
	ld b, a
	sla c
	rl b
	sla c
	rl b
	ldh a, [$FFD9]
	cpl
	add a, $01
	ld l, a
	ldh a, [$FFDA]
	cpl
	adc a, $00
	ld h, a
	ldh a, [$FFD5]
	cpl
	add a, $01
	ld e, a
	ldh a, [$FFD6]
	cpl
	adc a, $00
	ld d, a
	add hl, de
	sla l
	rl h
	sla l
	rl h
	push bc
	push hl
	ld a, [wViewDir]
	ld l, a
	ldh a, [hXPosLow]
	ld c, a
	ld b, $00 ;xpos in BC
	ldh a, [hYPosLow]
	ld e, a
	ld d, $00 ;ypos in DE
	ld a, l ;view direction
	call CallProjectXYToCamera ;project again
	pop hl
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	ld e, c
	ld d, b
	pop bc
	ld a, c
	sub a, e
	ld c, a
	ld a, b
	sbc a, d
	ld b, a
	ld e, l
	ld d, h
	push bc
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is Z
	add hl, hl
	add hl, hl ;Z times four
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc ;Z times 12
	dec h ;minus 256
	add hl, de
	pop bc
	ld a, $09
.outerloop ;57CE
	push af ;counter
	push hl
	push bc
	ld a, $09
.innerloop ;57D3
	push af ;counter
	push hl
	push bc
	bit 7, h
	jr nz, .nextdot ;jump if HL negative
	ld a, h
	cp $04
	jr nc, .projectdot ;jump if H > 3
	ld a, b
	or a
	jr z, .projectdot ;jump if B zero
	inc a
	jr nz, .nextdot ;jump if B wasn't $FF
.projectdot ;7, 3, H was > 3 or B was FF
	ld e, l
	ld d, h
	push de
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;HL is Z
	call ProjectPoint
	ld a, [wPitchAngle]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;add pitch to HL (screen Y)
	ld a, c
	add a, $40
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;add $40 to BC (screen X)
	pop de
	ld a, h
	or a
	jr nz, .nextdot
	ld a, b
	or a
	jr nz, .nextdot
	call DrawFloorDot
.nextdot ;35, 29, 7, 3
	pop bc
	pop hl
	ldh a, [$FFD7]
	add a, c
	ld c, a
	ldh a, [$FFD8]
	adc a, b
	ld b, a
	ldh a, [$FFD9]
	add a, l
	ld l, a
	ldh a, [$FFDA]
	adc a, h
	ld h, a
	pop af
	dec a
	jp nz, .innerloop
	pop bc
	pop hl
	ldh a, [$FFD3]
	add a, c
	ld c, a
	ldh a, [$FFD4]
	adc a, b
	ld b, a
	ldh a, [$FFD5]
	add a, l
	ld l, a
	ldh a, [$FFD6]
	adc a, h
	ld h, a
	pop af
	dec a
	jp nz, .outerloop
	ret
	
DrawFloorDot: ;583E
	ld a, l
	cp $58 ;check Y bounds
	ret nc
	ld a, c
	cp $80 ;check X bounds
	ret nc
	rrca
	rrca
	rrca ;x / 8? 
	and $1F
	add a, HIGH(wMonoBufferColumn1)
	ld h, a ;offset into $D000
	ld a, d ;check distance
	cp $02
	jp c, .zero
;one by one
	ld a, c
	and $07 ;mask to only the bit
	ld d, $00 ;top constants
	ld e, a
	ld a, [de] ;grab the bit
	or [hl] ;overlay it
	ld [hl+], a ;and save
	ret
.one ;585E, two tall
	ld a, c
	and $07
	ld d, $00
	ld e, a
	ld a, [de] ;grab bit
	or [hl]
	ld [hl+], a ;mask
	ld a, [de]
	or [hl]
	ld [hl+], a ;mask the next one too
	ret
.zero ;586B, two by two
	or a
	jp nz, .one
	ld a, c
	and $07
	ld d, $00
	ld e, a
	ld a, [de]
	ld e, a ;load bit
	sra a ;move it over
	or e
	ld e, a ;it's now two wide!
	or [hl]
	ld [hl+], a
	ld a, e
	or [hl]
	ld [hl+], a
	ret

HideCrosshair: ;5881
	;writes four OAM entries
	ld b, $04
.loop
	ld a, $F8
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .loop
	ret
DrawCrosshairReal: ;588E
	ld hl, wCrosshairTarget
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load word at $C2AF
	or h
	ld e, $08 ;the minimal crosshair
	jr z, .set8
	ld e, $04 ;the full crosshair
.set8
	ld hl, wReticleOAMData
	ld a, [wHideCrosshair] ;no idea what this location's for
	and $03 ;mask to bottom three bits
	jr nz, HideCrosshair ;if some were set, jump
	ld a, $44 ;Y
	ld c, a
	ld a, [wCrosshairYOffset]
	add a, c
	ld b, a ;b = [C2F9]+$44
	ld a, [wCrosshairXOffset]
	add a, $50 ;X
	ld c, a ;c = [C2FA]+$50
	call .writetoOAM
	ld a, b
	add a, $08
	ld b, a ;b += 8
	call .writetoOAM
	ld a, c
	add a, $08
	ld c, a ;c += 8
	ld a, b
	sub $08
	ld b, a ;b -= 8
	call .writetoOAM
	ld a, b
	add a, $08
	ld b, a ;b += 8
	call .writetoOAM
	ret
.writetoOAM ;58D0
	;write B, C, E+1, $00 into HL
	ld a, b
	ld [hl+], a ;Y
	ld a, c
	ld [hl+], a ;X
	ld a, e
	inc e
	ld [hl+], a ;ID
	xor a
	ld [hl+], a ;Attribute
	ret
	
DrawCrosshair: ;58DA
	jr DrawCrosshairReal ;to 588E
	;below this is unused??
	;draws tiles $04 - $10 based on view angle, using the last 13 sprites
	ld hl, $C06C ;the bottom-center-right of the timer OAM
	ldh a, [hViewAngle]
	cpl
	inc a
	ld d, a ;d is negative view angle
	ld e, $04 ;tile = 4
	call .writeFourOAM ;write four entries
	ld a, d
	add a, $32
	ld d, a ;increase view angle
	call .writeFourOAM ;write four entries
	ld a, d
	add a, $3C
	ld d, a ;increase view angle
	call .writeFourOAM ;write four entries
	call .writeOAM ;write a final entry
	ret
	
.writeFourOAM ;58FB
	;increments angle by 32 overall, and tile by four
	call .writeOAM
	call .writeOAM
	call .writeOAM
	jp .writeOAM
	
.writeOAM ;5907, writes a full OAM entry
	ld a, d ;view angle
	sub $10
	cp $88
	ld a, $00
	jr nc, .skip
	ld a, [wPitchAngle]
	add a, $10
.skip
	ld [hl+], a ;write pitch or 00 to yloc? based on angle
	ld a, d
	ld [hl+], a ;write angle to xloc?
	add a, $08
	ld d, a ;increment angle by 8
	ld a, e
	ld [hl+], a ;write tile
	inc e ;increment tile
	ld a, (1 << OAM_PRIORITY) | (1 << OAM_OBP_NUM)
	ld [hl+], a ;write 90 to attribute
	ret
	
EntityLogicGlider: ;5922, alien glider logic
	ld a, [$CAFC]
	inc a
	ld [$CAFC], a ;counter
	ld a, [wCurLevel]
	and $FC
	rrca
	rrca
	cp $06
	jp z, CallEntityLogicSuperGlider ;if level six, jump
	call NextRand
	and $7F ;1 in 128 chance not to jump
	jr nz, .moveforward 
	push hl ;save ent pointer
	call BlankFunc2936 ;hmmmmmmm
	pop hl ;restore ent pointer
.moveforward
	ld bc, $0000 ;XZ
	ld a, $50 ;Y
	call CallMoveEntityBySpecifiedAmts
	ld e, l
	ld d, h
	ld c, l
	ld b, h 
	push hl ;backup ent pointer into DE, BC, and the stack
	ld a, e
	add a, $07
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;DE += 07 (pointer to Z orientation)
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL += 0D (pointer to speed)
	ld a, c
	add a, $0C
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;BC += 0C (pointer to if hit)
	call NextRand
	and $3F
	jr z, .clearhit ;1 in 64 chance to jump
	ld a, [bc]
	or a
	jr z, .checkunk ;if not hit, jump
.clearhit
	xor a
	ld [bc], a ;clear hit flag
	inc hl
	inc hl ;advance HL by 2, to ?
	ld [hl], $01 ;set that byte to 1
	jp .decXOrient ;and jump
.checkunk
	inc hl
	inc hl
	ld a, [hl-] ;advance HL by 2, to ?
	or a
	jp nz, .decXOrient ;if set, jump
	;else!
	dec hl ;speed
	ld c, [hl]
	ld a, [wUpdateCounter]
	rrca ;every other update, increment speed
	jr c, .dotilts
	inc c
	ld [hl], c
.dotilts
	pop hl ;restore ent pointer
	push hl ;save ent pointer
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl += 4 (y position)
	ld a, [de] ;load Z orientation
	push de
	add a, $40
	and $FC ;mask
	sub a, [hl] ;ypos low minus angle
	ld e, a ;save to E
	inc hl ;ypos hi
	ld a, $FF
	sbc a, [hl] ;signcheck hi
	cp $80
	dec hl
	jr nc, .sub4
	or e
	jr z, .calctilt
	
	ld a, [hl]
	and $FC
	add a, $04
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl], a ;add 4
	jr .calctilt
.sub4
	or e
	jr z, .calctilt
	ld a, [hl]
	and $FC
	sub $04
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	ld [hl], a ;subtract 4
.calctilt ;ypos updated
	ld a, c ;speed?
	pop de ;z orientation
	pop bc ;ent pointer
	push af ;save speed
	ld l, e
	ld h, d ;z orientation to HL
	inc hl ;HL now Y orientation
	ld a, c
	add a, $0E
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;BC += 0E, now turn direction
	ld a, [bc]
	sub a, [hl] ;speedup minus y orientation?
	jr z, .dotilt
	cp $80
	ld a, [hl]
	jr nc, .neg
	add a, $10
.neg
	sub $08
	ld [hl], a ;add or subtract $8 based on sign
.dotilt
	xor a
	ld [bc], a ;wipe turn direction
	pop af ;restore speed to A
	rlca
	jr c, .negtilt
	ld a, [de] ;z orientation
	add a, $08 ;add 8
	cp $88 ;check cap
	ret nc
	ld [de], a
	ld a, $40
	ld [bc], a ;save turn direction
	ret
.negtilt
	ld a, [de] ;z orientation
	sub $08 ;sub 8
	ret c ;check cap
	ld [de], a
	ld a, $C0
	ld [bc], a ;save turn direction
	ret
.decXOrient ;59F9
	pop hl ;restore ent pointer
	ld c, l
	ld b, h
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance hl by six to x orientation
	ld a, [hl]
	sub $08
	ld [hl], a ;x orient -= 8
	ret nz
	ld a, c
	add a, $0F
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;advance bc by F to 1st mapobj byte if xorient is zero
	xor a
	ld [bc], a ;wipe it
	ret

CopyWRAMToVRAM: ;5A14
	ld hl, $8D00 ;tileset data
	ld de, WRAM1_Begin ;this is in wram
	ld b, $10 ;how many times to increment through D
	inc l
.bigloop
	push bc
.resetloop
	jp .firstloop
.loop ;0x5A21
	ld a, [de] ;load from wram
	cpl
	ld c, a
	inc e
	ld a, [de]
	cpl
	ld b, a
	inc e
	ld a, [de]
	cpl
	inc e
	inc e
	push de
	push af
	dec e
	ld a, [de]
	cpl
	ld d, a
	pop af
	ld e, a ;four bytes from [de] now copied to CBED
	jp .loopbody
.firstloop ;5A38
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	inc e
	ld a, [de]
	inc e
	inc e
	push de ;shove our position onto the stack
	push af 
	dec e
	ld a, [de]
	ld d, a
	pop af
	ld e, a ;four bytes from [de] are now in CBED
	di
.loopbody ;0x5A49
	ldh a, [rSTAT]
	and $02 ;mask to searching OAM/RAM
	jr nz, .loopbody
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
	ld [hl+], a ;copy those four bytes to [hl+] with an extra increment before each time
	ei
	inc l
	pop de ;restore our position in WRAM
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
	inc e ;erase the four bytes we just copied from
	ld a, e
	cp $58
	jr c, .resetloop ;if DE is less than 58, perform the smaller loop
	ld e, $00
	inc d ;if e == 58, jump to the next D
	pop bc
	dec b ;decrement the counter
	jr nz, .bigloop
	ret
	
DrawConvoScreen: ;0x5A77
	ld hl, $8D00 ;the start of the text screen
	ld de, $D000
	ld b, $10
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
	ld e, a ;read four bytes into EDBC, read position DE in pushed
.statloop
	ldh a, [$FF41]
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
	inc l ;write the four bytes
	pop de
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l ;and then copy the next four bytes
	inc e
	ld a, e
	cp $58
	jr c, .innerloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .outerloop
	ei
	ret
	
IF UNUSED == 1
UnusedCopyMonoBufferToScreen: ;5AC2
	ld hl, $8D00
	ld de, wMonoBufferColumn1
	ld b, MONO_BUFFER_COLUMNS
	inc l
.copycolumn
	push bc
.copyloop
	ld a, [de]
	ld c, a
	inc e
	ld a, [de]
	ld b, a
	inc e ;read word into BC
	ld a, [de] ;third byte into a
	inc e
	inc e ;advance past fourth
	push de ;save position
	push af ;save third byte
	dec e
	ld a, [de]
	ld d, a
	pop af
	ld e, a ;third and fourth bytes into DE
.statloop
	ldh a, [rSTAT]
	and rSTAT_MODE_NOT_BLANKING
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
	inc l ;write our four read rows
	pop de
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l
	inc e
	ld a, [de]
	ld [hl+], a
	inc l ;read and write four more rows
	ld a, e
	sub $07
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
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e
	ld [de], a
	inc e ;wipe the read values
	ld a, e
	cp MONO_BUFFER_HEIGHT
	jr c, .copyloop
	ld e, $00
	inc d
	pop bc
	dec b
	jr nz, .copycolumn
	ei
	ret
ENDC

DrawHalf3D: ;5B21
	ld hl, $8D00 ;start of 3D tiles
	ld de, wMonoBufferColumn1
	ld b, $10
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [de]
	inc l
	ld [hl+], a
	inc e
	ld a, [de]
	inc l
	ld [hl+], a ;copy two bytes from $D000 to $8D00
	xor a
	ld [de], a
	dec e
	ld [de], a ;then wipe the copied bytes
	inc e
	inc e
	ld a, e
	cp $58
	jr c, .statloop ;write $58 bytes? 5 and a half tiles
	ld e, $00
	inc d
	dec b
	jr nz, .statloop
	ret
	
LevelPointers: ;5B48
	;first pointer is level name/objective in bank 4?
	;second pointer is in bank 6, is routine to check for level clear/end/progress
	dw MissionOneReportText, Level1ProgressFunc 
	dw MissionTwoReportText, Level2ProgressFunc
	dw MissionThreeReportText, Level3ProgressFunc 
	dw MissionFourReportText, Level4ProgressFunc 
	dw MissionFiveReportText, Level5ProgressFunc
	dw MissionSixReportText, Level6ProgressFunc 
	dw MissionSevenReportText, Level7ProgressFunc 
	dw MissionEightReportText, Level8ProgressFunc
	dw MissionNineReportText, Level9ProgressFunc 
	dw MissionTenReportText, Level10ProgressFunc
	dw MissionElevenReportText, LevelEscapeProgressFunc ;escape
	dw MissionTwelveReportText, LevelTutorialProgressFunc ;tutorial
	
FindEntityWithModel: ;5B78
	ld a, h
	cp $CF
	jr nz, .notend
	ld a, l
	cp $3B
	jr z, .notfound
.notend
	ld a, [hl]
	cp d
	jr z, .found
	ld a, l
	add a, ENTITY_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	jr FindEntityWithModel
.notfound
	scf
	ret
.found
	xor a
	ret
	
ButterflyShootLazer: ;5B94
	ld a, [$C2AD] ;number of something left
	or a
	ret z ;return if none
	push de
	call GetFreeEntity
	pop de
	ret c ;return if none
	ld a, $7F
	ld [hl+], a ;set model to $7F ????
	ld b, $09
.copyloop
	ld a, [de]
	ld [hl+], a
	inc de ;copy this ent's position and rotation into the next one
	dec b
	jr nz, .copyloop
	ld a, LOW(ButterflyDrawLazer)
	ld [hl+], a
	ld a, HIGH(ButterflyDrawLazer)
	ld [hl+], a ;copy to logic pointer
	inc hl
	inc hl
	ld a, [$C320] ;speed
	ld [hl+], a
	ld a, [$C321] ;speedup
	ld [hl+], a
	ld a, [$C322]
	ld [hl+], a
	ld a, [$C323]
	ld [hl+], a ;mapiterator word 1
	xor a
	ld [hl+], a
	ld [hl+], a ;word 2
	ld [hl+], a
	ld [hl+], a ;word 3
	ld [hl+], a
	ld [hl+], a ;forming/targets bytes
	ld [hl+], a ;map ID byte
	ret
	
ButterflyDrawLazer: ;5BCB
	dec hl
	xor a
	ld [hl+], a ;wipe model
	ld a, [$C2AD] ;number left
	or a
	ret z
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;speed
	ld a, [wPitchAngle]
	ld c, a
	call NextRand
	and $07
	add a, $40
	ld e, a
	call NextRand
	and $07
	add a, c
	ld d, a ;D is pitch angle + rand(7), E is $40 + rand(7)
	ld a, [hl+]
	add a, e
	ldh [$FFF5], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFF6], a ;F5/F6 is speed and speedup plus E
	ld a, [hl+]
	add a, d
	ldh [$FFF7], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFF8], a ;F7/F8 is map word plus D
	ld hl, $C320
	ld a, [hl+]
	add a, e
	ldh [$FFF9], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFFA], a ;F9/FA is copied word 1 plus E
	ld a, [hl+]
	add a, d
	ldh [$FFFB], a
	ld a, [hl+]
	adc a, $00
	ldh [$FFFC], a ;FB/FC is copied word 2 plus D
	call CallProjectLine
	ret c
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
	ret
	
SetLevelPointers: ;5C2B
	ld hl, $C2A2
	xor a
	ld b, $04
.wipeloop
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .wipeloop ;wipe the pointers
	ld a, [wCurLevel]
	and $FC ;mask it to multiples of four
	add a, LOW(LevelPointers)
	ld l, a
	ld a, HIGH(LevelPointers) ;uses 5B48
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld [wReportPointerLo], a
	ld a, [hl+]
	ld [wReportPointerHi], a
	ld a, [hl+]
	ld [wLevelProgressFuncPointerLo], a
	ld a, [hl+]
	ld [wLevelProgressFuncPointerHi], a ;load two pointers into wram
	ret
	
CopyStringToDE: ;5C54
	.loop
	ld a, [hl+]
	ld [de], a
	or a
	ret z
	inc de
	jr .loop ;to 5C94
	
CheckTunnelEntitiesCollision: ;5C5B
	;loops through ten entries at D458, sets carry if successful
	push hl
	ld hl, wTunnelEntities
	ld a, TUNNEL_ENTITIES_COUNT
.loop
	push af
	ld a, [hl+]
	or a
	jp nz, .nextentry ;loop until we find an empty one
	push hl ;save our spot?
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;an x position?
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;a z position?
	inc hl ;skip one
	ldh a, [hXPosLow]
	cp c
	ldh a, [hXPosHi]
	sbc a, b ;our X minus it's.
	rla ;shift top bit into carry
	jr c, .clearedobstacle ;if negative, to 5CBD
	ldh a, [hZPosLow]
	cp e
	ldh a, [hZPosHi]
	sbc a, d ;our Z minus it's.
	rla
	jr c, .clearedobstacle ;if negative, to 5CBD
	ld a, [hl+]
	add a, c
	ld c, a
	ld a, [hl+]
	adc a, b
	ld b, a ;add next X to its position
	ldh a, [hXPosLow]
	cp c
	ldh a, [hXPosHi]
	sbc a, b
	rla
	jr nc, .clearedobstacle ;check again, if positive go to 5CBD
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, [hl+]
	adc a, d
	ld d, a
	ldh a, [hZPosLow]
	cp e
	ldh a, [hZPosHi]
	sbc a, d
	rla
	jr nc, .clearedobstacle ;same again, final check. if positive jump to 5CBD
	ld a, $C4
	ld [$CA88], a
	ld a, [$D45D]
	dec a
	ldh [hYHiCopy], a
	xor a
	ldh [hYLoCopy], a
	ld hl, wHealth
	dec [hl] ;ouch!
	ld a, $06
	ld [wQueueSFX], a
	add sp, $04 ;discard the table position and counter
	pop hl ;restore hl from the start
	scf ;and set carry flag, we hit something
	ret
.clearedobstacle ;5CBD
	pop hl
.nextentry ;5CBE
	ld a, l
	add a, TUNNEL_ENTITIES_SIZE - 1 ;since we already read it?
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop af
	dec a
	jp nz, .loop
	pop hl
	and a
	ret

DrawTunnelEntities: ;5CCE
	ld a, [$C2F4]
	inc a
	jr z, .neg
	ld a, [$CAA5] ;if wasn't -1, use this instead (always zero??)
	or a
	ld a, $00 ;save 0 ONLY WHEN CAA5 is nonzero and C2F4 is not -1
	jr nz, .zero
.neg
	ld a, $01
.zero
	ld [$C2F3], a ;no idea
	ld hl, $D4C4 ;in entity list?
	ld a, $0A ;do this ten times
.mainloop
	push af
	push hl
	ld a, [hl+]
	cp $FF
	jp z, .finishedcommand ;if byte is -1, next loop
	ld [$D058], a ;map tank cell? might be something else for tunnel scene
	ld c, a
	ld a, [$C2F4]
	sub $01
	jr c, .nocall ;if 0, skip
	cp c
	call nc, $705B ;if > c, call
.nocall
	ld a, c
	rlca
	rlca ;c * 4
	add a, LOW(wTunnelFrames)
	ld e, a
	ld a, $00
	adc a, HIGH(wTunnelFrames)
	ld d, a
	ld a, [de] ;de is now an offset into tunnel frame coords
	ldh [$FFF3], a ;first byte into F3
	inc de
	ld a, [de]
	ldh [$FFEF], a ;second byte into EF
	inc de
	ld a, [de]
	ldh [$FFF1], a ;third byte into F1
	inc de
	ld a, [de]
	ldh [$FFED], a ;fourth byte into ED
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFF0], a
	ldh [$FFEE], a ;low bytes of each set to $80
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;next word loaded into BC
	ld a, [hl+]
	ldh [$FFF7], a
	ld a, [hl+]
	ldh [$FFF8], a ;next word loaded into  F7/F8
	ld a, [hl+] ;one last byte into a
	push hl ;save position
	ld d, a
	ld e, $00 ;last byte now in DE
	ldh a, [hYPosLow]
	ld l, a
	ld a, e
	sub a, l
	ldh [$FFDB], a
	ld e, a
	ldh a, [hYPosHi]
	ld l, a
	ld a, d
	sbc a, l
	ldh [$FFDC], a
	ld d, a ;subtract Ypos from DE, save them to DB/DC
	ldh a, [hXPosLow]
	ld l, a
	ld a, c
	sub a, l
	ldh [$FFDF], a
	ld c, a
	ldh a, [hXPosHi]
	ld l, a
	ld a, b
	sbc a, l
	ldh [$FFE0], a
	ld b, a ;subtract Xpos from BC, save them to DF/E0
	ldh a, [$FFE3]
	ld h, a
	ldh a, [$FFF7]
	sub a, h
	ldh [$FFDD], a
	ld l, a
	ldh a, [$FFE4]
	ld h, a
	ldh a, [$FFF8]
	sbc a, h
	ldh [$FFDE], a
	ld h, a ;subtrack unknown from HL, save them to DD/DE
	bit 7, d
	jr z, .dontblankd
	ld de, $0000 ;if negative, clear
.dontblankd
	push de
	call PrepScaleXYByDistance ;process BC DE HL
	ld a, [$D058] ;tank cell again
	ld e, a
	rlca
	rlca
	rlca
	add a, e ;multiply by nine
	add a, $5D
	ld e, a
	ld a, $D3
	adc a, $00
	ld d, a ;DE is our value + $D35D
	ld a, [de]
	push af
	inc de 
	ld a, [de]
	ld d, a
	pop af
	ld e, a ;read word at [DE], load it into DE
	ld a, c
	add a, e
	ldh [$FFC6], a
	ld a, b
	adc a, d
	ldh [$FFC7], a ;C6/C7 = BC+DE (BC is one result from processing)
	ld a, l
	ldh [$FFC4], a
	ld a, h
	ldh [$FFC5], a ;C4/C5 = HL (other result from processing)
	pop de ;restore our word value
	pop hl ;restore monobuffer position?
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;read four bytes into BC and HL
	call PrepScaleXYByDistance ;process BC DE HL
	ldh a, [$FFC6]
	add a, c
	ldh [$FFC2], a 
	ldh a, [$FFC7]
	adc a, b
	ldh [$FFC3], a ;store old result 1 + new result 1 to C2/C3
	ldh a, [$FFC4]
	add a, l
	ldh [$FFC0], a
	ldh a, [$FFC5]
	adc a, h
	ldh [$FFC1], a ;store old result 2 + new result 2 to C0/C1
	ld a, [wViewDir]
	cpl
	inc a ;negate
	cp $80
	ld b, $00
	jr c, .notneg
	ld b, $FF
.notneg
	sla a
	rl b
	add a, $40
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;bc is now negative view direction * 2 + $0040
	ldh a, [$FFC6]
	add a, c
	ldh [$FFC6], a
	ldh a, [$FFC7]
	adc a, b
	ldh [$FFC7], a ;increment old result 1 by our view direction??
	ldh a, [$FFC2]
	add a, c
	ldh [$FFC2], a
	ldh a, [$FFC3]
	adc a, b
	ldh [$FFC3], a ;increment result 1 totals by view direction??
	ld a, [wPitchAngle]
	ld c, a
	ld b, $00 ;BC is now our view pitch
	ldh a, [$FFC4]
	add a, c
	ldh [$FFC4], a
	ldh a, [$FFC5]
	adc a, b
	ldh [$FFC5], a ;increment old result 2 by our view pitch
	ldh a, [$FFC0]
	add a, c
	ldh [$FFC0], a
	ldh a, [$FFC1]
	adc a, b
	ldh [$FFC1], a ;increment result 2 totals by view pitch
	call ComparePointersToC0C8Region ;carry flag set on fail, this modifies the C0C8 region
	jr c, .skipcall
	ldh a, [$FFC6] ;if they were changed, load up BC DE
	ld c, a
	ldh a, [$FFC4]
	ld b, a ;BC is now C4/C6
	ldh a, [$FFC2]
	sub a, c 
	jr c, .skipcall
	jr z, .skipcall ;if negative or zero, jump ahead
	ld e, a ;else save to e
	ldh a, [$FFC0]
	sub a, b
	jr c, .skipcall
	jr z, .skipcall ;if negative or zero, jump ahead
	ld d, a ;else save to d; DE is now loaded
	pop hl
	push hl ;grab out monobuffer position?
	ld a, l
	add a, $0B
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;go forward $B bytes
	ld a, [hl]
	ld [$C2AE], a ;load value into $C2AE
	call DrawInD100Region ;uses BC and DE and some masks for monochrome drawing?
.skipcall ;all those jumps above go to here
	pop hl ;restore read position
	ld a, l
	add a, $0A
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de] ;grab value at [hl+$A]
	or a
	jr z, .nocommand ;if 0, jump to 5E49
	push hl ;save read position again
	dec a
	sla a ;its an entry into a table? 1-indexed tho
	add a, LOW(TunnelEntityLogicTable)
	ld e, a
	ld a, HIGH(TunnelEntityLogicTable)
	adc a, $00
	ld d, a ;DA is $5FEB + our index
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a ;read a pointer into BC
	ld de, .finishedcommand ;return point
	push de
	push bc ;jump to the read pointer
	ret
	
.finishedcommand ;5E48
	pop hl ;restore read position
.nocommand ;5E49
	ld a, l
	sub $0C
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;go back $C?
	pop af
	dec a
	jp nz, .mainloop
	call $705B ;TODO
	ret
	
ShutterCloseLeftLogic: ;5E5A
	push hl
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	call EntSub30
	pop hl
ShutterCloseRightLogic: ;5E67
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	jr EntAdd30
ShutterCloseUpwardLogic: ;5E71
	push hl
	ld a, l
	add a, $03
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	call EntSub30
	pop hl
ShutterCloseDownwardLogic: ;5E7E
	ld a, l
	add a, $08
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
EntAdd30: ;15
	ld a, [hl]
	add a, $1E
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl+], a
	ret
	
EntSub30: ;5E8F
	ld a, [hl]
	sub $1E
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	ld [hl+], a
	ret
	
DoorLeftLogic: ;5E98
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [wFrameCounterLo]
	bit 7, a
	jr z, .write
	and $7F
	cpl
.write ;3
	sla a
	ld [hl+], a
	ret
	
ShutterLeftLogic: ;5EAE
	ld a, [wTunnelIntroTimer]
	cp $08
	ret c
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	sub $03
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	ld [hl+], a
	ret

ShutterRightLogic: ;5EC5
	ld a, [wTunnelIntroTimer]
	cp $08
	ret c
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	add a, $03
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl+], a
	ret
	
DoorRightLogic: ;5EDC
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [wFrameCounterLo]
	add a, $80
	bit 7, a
	jr z, .write
	and $7F
	cpl
.write
	sla a
	ld [hl+], a
	ret
	
ShimmerBarrierLogic: ;5EF4
	ld a, l
	add a, $0B
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl] ;grab fillpattern
	swap a ;swap nybbles
	inc a ;??
	xor $3C ;invert middle four bits?
	ld [hl+], a ;save it
	ret
	
TunnelExitLogic: ;5F04
	call GetTunEntRotation
	ldh a, [$FFDF]
	add a, $A0
	ldh [$FFDF], a ;x
	ldh a, [$FFE0]
	adc a, $3F
	ldh [$FFE0], a ;z
	ld hl, TunnelExitTXT
	call Draw3DString
	ret
	
EarthExitLogic: ;5F1A
	call GetTunEntRotation
	ldh a, [$FFDF]
	add a, $A0
	ldh [$FFDF], a
	ldh a, [$FFE0]
	adc a, $3F
	ldh [$FFE0], a
	ld hl, TunnelEarthTXT
	call Draw3DString
	ret
	
LeftSignLogic: ;5F30
	ld de, TunnelLeftTXT
	jr RightSignLogic.getRot
RightSignLogic: ;5F35
	ld de, TunnelRightTXT
.getRot ;3
	push de
	call GetTunEntRotation
	ldh a, [$FFDD]
	sub $50
	ldh [$FFDD], a
	ldh a, [$FFDE]
	sbc a, $00
	ldh [$FFDE], a ;y?
	ldh a, [$FFDF]
	add a, $32
	ldh [$FFDF], a
	ldh a, [$FFE0]
	adc a, $00
	ldh [$FFE0], a ;x?
	pop hl
	call Draw3DString
	ret
	
TunnelLabelLogic: ;5F59
	call GetTunEntRotation
	ld hl, TunnelTunnelTXT
	ld de, w3DTextBuffer
	call CopyStringToDE
	ld a, [wCurLevel]
	srl a
	srl a
	inc a
	cp $0A ;tenth level?
	jr c, .end ;if less, jump ahead
	ld a, "1" ;otherwise put ones in the tens place
	ld [de], a
	inc de ;next place
	xor a ;and zero out
.end ;5
	add a, "[" ;why this character? shouldn't this be '0'?
	ld [de], a
	inc de
	xor a
	ld [de], a ;buffer end
	ldh a, [$FFE0]
	add a, $3F
	ldh [$FFE0], a ;X, far far to the right?
	ldh a, [$FFDD]
	add a, $64
	ldh [$FFDD], a
	ldh a, [$FFDE]
	adc a, $00
	ldh [$FFDE], a ;Y? below the position
	ld hl, w3DTextBuffer
	call Draw3DString
	ret

TunnelTunnelTXT: ;5F95
	db "TUNNEL ", 00
	
GetTunEntRotation: ;5F9D
	ld a, [wViewDir]
	cpl
	inc a ;negate
	cp $80
	ld b, $00
	jr c, .gotsign
	ld b, $FF
.gotsign ;2
	sla a
	rl b
	ld c, a ;BC is our rotation direction
	ld a, [hl]
	ld e, a
	rlca
	rlca
	rlca
	add a, e
	add a, LOW(wTunnelSeg1RotLo)
	ld e, a
	ld a, HIGH(wTunnelSeg1RotLo)
	adc a, $00
	ld d, a ;DE now the tunnel seg rotation
	ld a, [de]
	add a, c
	ld c, a
	inc de
	ld a, [de]
	adc a, b
	ld b, a ;BC += tun seg rot
	ld a, c
	ldh [$FF9E], a
	ld a, b
	ldh [$FF9F], a ;save the rotation
	xor a ;zero it out
	ld [wModelExploding], a
	ldh [$FFA1], a
	ldh [$FFA5], a
	ldh [$FFA3], a
	ret
	
TunnelExitTXT: ;5FD5
	db "EXIT", 00
TunnelRightTXT: ;5FDA
	db "RIGHT", 00
TunnelLeftTXT: ;5FE0
	db "LEFT", 00
TunnelEarthTXT: ;5FE5
	db "EARTH", 00
	

TunnelEntityLogicTable: ;5FEB, entity pointer table
	dw ShutterCloseDownwardLogic
	dw ShutterCloseUpwardLogic
	dw ShutterCloseLeftLogic
	dw ShutterCloseRightLogic ;4
	dw DoorLeftLogic 
	dw DoorRightLogic
	dw ShimmerBarrierLogic
	dw TunnelExitLogic ;8
	dw TunnelLabelLogic
	dw LeftSignLogic
	dw RightSignLogic
	dw ShutterLeftLogic ;C
	dw ShutterRightLogic 
	dw EarthExitLogic
	
IF UNUSED == 1
EclipseTilemap: ;6007, RLE tileset, unused
	db $14, $12 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $03, $04, $05, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $07, $08, $09, $0A, $0B, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $0C, $0D, $0E, $0F, $10, $11, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $12, $13, $14, $15, $16, $17, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $00, $00, $00, $00, $00, $00, $21, $22, $23, $24 
	db $25, $26, $27, $28, $29, $2A, $2B, $2C, $00, $00, $00, $00, $00, $2D, $2E, $2F, $30, $31, $32, $33 
	db $34, $35, $36, $37, $38, $39, $00, $00, $00, $00, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $43 
	db $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57 
	db $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B 
	db $00, $00, $6C, $6D, $6E, $6F, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $00, $00 
	db $7C, $7D, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $00, $00, $8C, $8D 
	db $8E, $8F, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $00, $00, $00, $9C, $9D, $9E 
	db $9F, $A0, $A1, $00, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $00, $00, $00, $00, $00, $00, $AA, $AB 
	db $00, $00, $AC, $AD, $AE, $AF, $B0, $B1, $B2, $B3, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $B4, $B5, $B6, $B7, $B8, $B9, $00, $BA, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $BB, $BC 
	db $BD, $BE, $BF, $C0, $C1, $C2, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C3, $C4, $C5, $C6 
	db $C7, $C8, $C9, $CA, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $CB, $CC, $CD, $CE, $CF, $D0 
	db $D1, $D2, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $D3, $D4, $D5, $D6, $D7, $D2, $D2, $D2
	INCBIN "build/gfx/Eclipse.rle"
ENDC

HandleEntityCollision: ;6DA1
	push hl
	call BumpedRecoil
	pop hl
	ld a, [$CB07]
	cp $02 ;nonhostile?
	jr nz, .harm
	ld a, $0B
	ld [wQueueSFX], a
	ret
.harm ;6
	dec a
	ret nz
	ld a, $06 ;bunp
	ld [wQueueSFX], a
	ld a, [wHealth]
	dec a
	ld [wHealth], a
	ld a, $1E
	ld [wScreenShakeCounter], a
	ld a, [$C357]
	ld l, a
	ld a, [$C358]
	ld h, a ;hl is x of entity
	ld a, $01
	call CallDamageEntity
	ret
	
BumpedRecoil: ;6DD4
	ld a, spdSTOP
	ldh [hSpeedTier], a
	ld a, [wLurchCounter]
	rla
	jr nc, .over80 
	ld a, $78
	ld [wLurchCounter], a
	ld c, $64
	jr .dorecoil
.over80 ;9
	ld a, $C1
	ld [wLurchCounter], a
	ld c, $9C
.dorecoil ;7
	ld b, $00
	ldh a, [hXPosLow]
	ldh [hXLoCopy], a
	ldh a, [hXPosHi]
	ldh [hXHiCopy], a
	ldh a, [hYPosLow]
	ldh [hYLoCopy], a
	ldh a, [hYPosHi]
	ldh [hYHiCopy], a
	ld a, [wViewDir]
	ld d, a
	call CallRotateCoordByAngle
	ld e, b
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;extend X into BC
	ldh a, [hYLoCopy]
	add a, c
	ldh [hYLoCopy], a
	ldh a, [hYHiCopy]
	adc a, b
	ldh [hYHiCopy], a
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend Y into DE
	ldh a, [hXLoCopy]
	add a, e
	ldh [hXLoCopy], a
	ldh a, [hXHiCopy]
	adc a, d
	ldh [hXHiCopy], a
	ret


EntityDropNewEntity: ;6E2D
	ld c, a
	push bc
	push hl
	call GetFreeEntity
	ld e, l
	ld d, h
	pop hl
	pop bc
	ret c ;if no free entities, return
	push hl ;passed entity?
	push de
	push de ;free entity
	ld e, l
	ld d, h
	pop hl ;free is now in HL, passed is in DE
	ld a, c
	ld [hl+], a ;passed value into free (model?)
	ld b, $09
.copyloop
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copyloop ;copy position and orientation
	ld a, c
	dec a
	sla a
	add a, LOW(EntityLogicPointers)
	ld e, a
	ld a, b
	adc a, HIGH(EntityLogicPointers) ;table at 5022, two bytes?
	ld d, a
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a ;copy them to entity
	ld a, c
	add a, LOW(EntityHealthValues)
	ld e, a
	ld a, b
	adc a, HIGH(EntityHealthValues)
	ld d, a ;table at 50CC, health?
	ld a, [de]
	ld [hl+], a
	xor a
	ld [hl+], a ;clear next byte. last byte blank because not a map object.
	pop de
	pop hl
	and a
	ret
	
SpawnNewCoin: ;6E68
	push hl
	ld a, $1E ;coin
	call GetMatchingEntitySlots
	cp $02
	pop hl
	ret nc ;if two or more already present, don't spawn any more
	ld a, $1E ;coin
	call EntityDropNewEntity
	ret c
	ld a, e
	add a, $05
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;y
	ld a, [de]
	sub $32
	ld [de], a
	inc de
	ld a, [de]
	sbc a, $00
	ld [de], a ;y -= 32
	ld a, e
	add a, $08
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;first status byte
	xor a
	ld [de], a ;clear it
	ret

GetAngleBetweenEnts: ;6E94
	push de
	ld a, [de]
	sub a, [hl]
	ld c, a
	inc hl
	inc de
	ld a, [de]
	sbc a, [hl]
	ld b, a
	inc hl
	inc de
	push bc
	ld a, [de]
	sub a, [hl]
	ld c, a
	inc de
	inc hl
	ld a, [de]
	sbc a, [hl]
	ld d, a
	ld e, c
	pop bc
	jr GetAngleToOffset

GetAngleToEntity: ;6EAC
	push hl ;entity pointer
	ld a, [hl+]
	cpl
	ld c, a
	ld a, [hl+]
	cpl
	ld b, a
	ld a, [hl+]
	cpl
	ld e, a
	ld a, [hl+]
	cpl
	ld d, a
	inc bc ;negative X
	inc de ;negative Z
	ldh a, [hXPosLow]
	add a, c
	ld c, a
	ldh a, [hXPosHi]
	adc a, b
	ld b, a ;BC is our X minus entity X
	ldh a, [hYPosLow]
	add a, e
	ld e, a
	ldh a, [hYPosHi]
	adc a, d
	ld d, a ;DE is our Y minus entity Y
GetAngleToOffset:
	bit 7, d
	jr nz, .negativeY 
	bit 7, b
	jr nz, .negativeX
;both offsets are positive
	ld a, c
	cp e
	ld a, b
	sbc a, d ;x minus y
	cp $80
	jr nc, .yg1 ;jump if negative, aka y > x
	ld a, $30
	jr .done
.yg1
	ld a, $10
	jr .done
.negativeX
	ld a, c
	add a, e
	ld a, b
	adc a, d
	cp $80
	jr c, .yg2
	ld a, $D0
	jr .done
.yg2
	ld a, $F0
	jr .done
.negativeY
	bit 7, b
	jr nz, .negativeBoth
	ld a, c
	add a, e
	ld a, b
	adc a, d
	cp $80
	jr nc, .yg3
	ld a, $50
	jr .done
.yg3
	ld a, $70
	jr .done
.negativeBoth
	ld a, c
	cp e
	ld a, b
	sbc a, d
	cp $80
	jr nc, .yg4
	ld a, $90
	jr .done
.yg4
	ld a, $B0
	jr .done
.done
	pop hl
	ret
;6F19

SECTION "2:7049", ROMX[$7049], BANK[2]
IF UNUSED == 1
LoadModelName: ;7049
	dec a
	sla a
	add a, LOW(ObjectNamePointerTable)
	ld l, a
	ld a, $00
	adc a, HIGH(ObjectNamePointerTable)
	ld h, a ;5178
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CopyStringToDE
	ret
ENDC

Func705B: ;705B, todo
	ld a, [$C2F3]
	or a
	ret nz ;if nonzero, return (the overwhelming case)
	ld a, $01
	ld [$C2F3], a ;flag it with one
	push bc
	push de
	push hl ;save these
	ld a, [$C2F4]
	or a
	jr nz, .lf
	xor a ;if F4 was zero,
	ldh [$FFF3], a
	ldh [$FFEF], a ;zero these out
	ld a, $7F
	ldh [$FFF1], a
	ld a, $57
	ldh [$FFED], a ;and write values here
	jr .l1a
.lf;F
	dec a
	rlca
	rlca ;otherwise, minus one times four?
	add a, LOW(wTunnelFrames)
	ld e, a
	ld a, $00
	adc a, HIGH(wTunnelFrames)
	ld d, a ;make an address out of it, + D258
	ld a, [de]
	ldh [$FFF3], a
	inc de
	ld a, [de]
	ldh [$FFEF], a
	inc de
	ld a, [de]
	ldh [$FFF1], a
	inc de
	ld a, [de]
	ldh [$FFED], a ;otherwise load up a frame from the list?
.l1a;1A
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF2], a
	ldh [$FFF0], a
	ldh [$FFEE], a ;high bytes all $80
	ld a, [$C349]
	ld c, a
	ld a, [$C34A]
	ld b, a ;load bc with ?
	ld a, [$C34B]
	ldh [$FFC4], a
	ld a, [$C34C]
	ldh [$FFC5], a ;load these
	ld a, [$C34D]
	ld e, a
	ld a, [$C34E]
	ld d, a ;load de with ?
	ldh a, [hYPosLow]
	ld l, a
	ld a, e
	sub a, l
	ldh [$FFDB], a
	ld e, a
	ldh a, [hYPosHi]
	ld l, a
	ld a, d
	sbc a, l
	ldh [$FFDC], a ;DE -= y position? 
	ld d, a
	ldh a, [hXPosLow]
	ld l, a
	ld a, c
	sub a, l
	ldh [$FFDF], a
	ld c, a
	ldh a, [hXPosHi]
	ld l, a
	ld a, b
	sbc a, l
	ldh [$FFE0], a ;BC -= x position
	ld b, a
	ldh a, [hZPosLow]
	ld h, a
	ldh a, [$FFC4]
	sub a, h
	ldh [$FFDD], a
	ld l, a
	ldh a, [hZPosHi]
	ld h, a
	ldh a, [$FFC5] 
	sbc a, h
	ldh [$FFDE], a ;hl -= z and C4/C5
	ld h, a
	bit 7, d
	jr nz, .end ;if negative, jump to 7147?
	ld a, e
	ld [$C347], a
	ld a, d
	ld [$C348], a
	call PrepScaleXYByDistance ;project
	ld a, [wViewDir]
	cpl
	inc a
	cp $80
	ld d, $00
	jr c, .skipneg
	ld d, $FF
.skipneg
	sla a
	rl d
	add a, $40
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;DE = angle * 2 + 0040
	ld a, c
	add a, e
	ld c, a
	ld a, b
	adc a, d
	ld b, a ;BC += DE
	ld a, [$C2F4]
	ld e, a
	rlca
	rlca
	rlca
	add a, e ;C2F4 * 9
	add a, $5D
	ld e, a
	ld a, $D3
	adc a, $00
	ld d, a ;D35D + that math
	ld a, [de] ;read an entry
	push af ;save read value
	inc de
	ld a, [de] ;read next bit of data
	ld d, a
	pop af
	ld e, a ;load the two bytes read into DE
	ld a, c
	add a, e
	ldh [$FFC6], a
	ld a, b
	adc a, d
	ldh [$FFC7], a ;C6/C7 = BC + DE
	ld a, [wPitchAngle]
	add a, l
	ldh [$FFC4], a
	ld a, h
	adc a, $00
	ldh [$FFC5], a ;C4/C5 = pitch + HL
	call $299B ;TODO
.end ;7147
	pop hl
	pop de
	pop bc ;restore registers to how they were before this func
	ret
	
EntityLogicInsectThing: ;714B
	ld a, [$CAFD]
	inc a
	ld [$CAFD], a ;count
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed (here its age)
	ld a, [de]
	cp $E8
	jr nz, .growing
	push hl
	push de
	push bc
	ld de, wQueueSFX
	ld a, $1D
	call CallEntityPlayShootShound
	pop bc
	pop de
	pop hl
.growing ;E
	ld e, l
	ld d, h
	ld c, l
	ld b, h
	ld a, e
	add a, $0E
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;speedup
	ld a, [de]
	bit 0, a
	jp z, .checkHit
	ld e, l
	ld d, h
	ld a, c
	add a, $0D
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;speed
	ld a, [bc]
	add a, $04
	ld [bc], a ;increase
	cp $80
	jr nc, .mature
	cp $18
	jp nc, .adolescent
.mature;5
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ; y position
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a
	ld l, e
	ld h, d
	ld bc, $1E00
	call CallMoveEntityForward
	call CallTestEntityHasCollisions
	jr nc, .notCollision
	dec hl
	ld a, [hl+]
	cp $27 ;truck?
	jr nz, .damage
	dec de
	ld a, [de]
	set 7, a
	ld [de], a ;blam
.damage ;5
	ld a, $01
	call CallDamageEntity
	ret
	
.notCollision ;71CA, 11
	ld l, e
	ld h, d
	ld a, [$CB0B] ;trucks left
	or a
	jp z, .targetPlayer ;if none, target player instead
	ld c, a
	ld a, l
	and $0F
.subloop
	sub a, c
	jr nc, .subloop
	add a, c
	ld c, a
	inc c
	ld e, l
	ld d, h
	ld hl, wEntityTable
.entLoop
	push bc
	push de
	ld a, $27 ;truck
	call CallFindEntityWithModel
	pop de
	pop bc
	jr c, .targetPlayer ;to 233
	dec c
	jr nz, .entLoop
	inc hl
	push hl
	push de
	call CallGetDistanceBetweenEnts
	pop de
	pop hl
	jp c, .targetPlayer ;if none found, jump
	cp $3C
	jp nc, .targetPlayer ;if too far, jump
	call CallGetAngleBetweenEnts
	sub $80
	ld c, a
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;y orientation
	ld a, c ;angle
	sub a, [hl]
	add a, $08
	cp $10
	jr c, .doneTurning
	sub $08
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft 
	ld a, [hl]
	sub $80
	ld [hl], a
	jr .doneTurning
.turnRight
	ld a, [hl]
	add a, $02
	ld [hl], a
	jr .doneTurning
.turnLeft
	ld a, [hl]
	sub $02
	ld [hl], a
.doneTurning
	pop hl
	ret
	
.targetPlayer ;7233
	ld l, e
	ld h, d
	call CallTurnEntTowardsPlayer
	ret
	
.adolescent ;7239
	ld a, e
	add a, $0E
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;speedup
	ld a, [de]
	res 0, a
	ld [de], a ;reset the bit?
.checkHit ;7245
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de] ;shot at flag
	bit 0, a
	jr z, .cap ;if not, jump ahead
	ld a, l
	add a, $0F
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;mapiterator byte?
	call NextRand
	and $0F
	add a, $14
	ld c, a
	ld a, [de]
	inc a
	ld [de], a ;increment the value
	cp c
	ret c ;chance to do nothing
	xor a
	ld [de], a ;otherwise reset it
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	res 0, a
	ld [de], a ;otherwise reset shot at flag
.cap ;23
	ld e, l
	ld d, h
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;speed (age)
	ld [hl], $E8 ;cap it
	ld a, e
	add a, $0E
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, $01
	ld [de], a ;set speedup to 1
	ret
	
EntityLogicAlienBase1: ;728D
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;hp
	ld a, [de]
	cp $28
	ret nc ;if $28 or more, we're done
	push hl
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;"speed", here the ent ID to spawn?
	ld a, [de]
	cp $11
	jr nz, .spawnEnt ;if speed != 11, jump
	ld a, [$C287]
	inc a
	ld [$C287], a ;increment?
	cp $03
	ld a, $11
	jr c, .spawnEnt
	ld a, $3A
.spawnEnt
	or a
	jr z, .damage
	call CallEntityDropNewEntity
	jr c, .damage ;if it failed, skip ahead
	ld a, e
	add a, $08
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld a, [wViewDir]
	add a, $80
	ld [hl], a ;set its direction to be opposite/same? as ours
	ld a, e
	add a, ENTITY_SIZE-1
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	xor a
	ld [hl], a ;clear its mapID (redundant?)
.damage ;1D, 18
	pop hl
	ld a, $FF
	call CallDamageEntity
	ret
	
EntityLogicCivilianBase: ;72DD
	ret
	
EntityLogicGasStation: ;72DE
	ld a, [wEntityCollided]
	or a
	ret z
	ld a, $02 ;scenery
	ld [wCollisionType], a
	ld a, $04
	ld [wSubscreen], a
	ret

EntityLogicCoinbox: ;72EE
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to Z orientation
	ld a, [de]
	add a, $0F
	ld [de], a ;increase it by $0F (just under 1/16)
	ld a, l
	add a, $0C
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;advance to a status byte
	ld a, [de]
	bit 0, a
	ret z
	res 0, a
	ld [de], a
	call CallSpawnNewCoin ;call if bit 0 was set? farcall not needed here
	ld a, $08
	ld [wQueueSFX], a
	ret
;7312
	
SECTION "2:7327", ROMX[$7327], BANK[2]
EntityLogicTrackingMissile: ;7327
	ld e, l
	ld d, h ;backup ent pointer
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to "speed"
	ld a, [hl]
	inc a
	ld [hl+], a ;increment value
	cp $1E
	jr nc, .destroy ;if over $1E, jump
	cp $04
	jr nc, .checkTarget ;if over 4, jump
	ld a, [wEntityCollided]
	or a
	jr z, .checkTarget ;if we didn't collide, jump ahead
	xor a
	ld [wCollisionType], a ;clear the collision type
.checkTarget ;A, 4
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h ;"speedup" and another byte, these are coords for target? or an ent pointer?
	jr nz, .checkBit ;if either are nonzero, jump
	ld l, e
	ld h, d ;otherwise restore pointer and jump
	jr .checkHit
.checkBit ;4
	bit 7, [hl]
	jr z, .seek ;if top bit not set, jump
.destroy
	ld l, e
	ld h, d ;restore pointer
	ld a, $FF
	call CallDamageEntity ;kill?
	ret
.seek ;735C, 8
	inc hl
	call CallGetAngleBetweenEnts
	sub $80
	ld c, a
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, c
	sub a, [hl]
	add a, $08
	cp $10
	jr c, .doneTurning
	sub $08
	cp $90
	jr c, .turnright
	cp $70
	jr nc, .turnleft
	ld a, [hl]
	sub $80
	ld [hl], a
	jr .doneTurning
.turnright
	ld a, [hl]
	add a, $02
	ld [hl], a
	jr .doneTurning
.turnleft
	ld a, [hl]
	sub $02
	ld [hl], a
.doneTurning ;1A, A 4
	pop hl
.checkHit ;3F
	ld b, $78
	ld c, $00
	call CallMoveEntityForward
	call CallTestEntityHasCollisions
	ret nc
	push de
	ld a, $14
	call CallDamageEntity ;14 damage to target
	pop hl
	ld a, $FF ;kill this
	call CallDamageEntity
	ret
	
EntityLogicSpinMissile: ;73A7
	push hl
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;x rotation
	ld a, [hl]
	add a, $1D
	ld [hl+], a
	pop hl
	jp CallEntityLogicHomingMissile
	
DrawPositionOnRadar: ;73B8
	ld a, [wFlyingFlag]
	or a
	jr z, .statecheck
	;if flying, 
	push hl
	ld a, [hl+]
	ld l, [hl] ;check ent Z
	or l
	pop hl
	ret z ;if Z is 0, return
.statecheck ;6
	ldh a, [hGameState]
	dec a
	jr nz, .poscheck ;if not 1 (planet), skip
	ld a, [wUpdateCounter]
	and $01
	ret z ;only check every other update?
.poscheck ;6
	push bc ;X
	push de ;Y
	push hl ;Z
	ld c, b
	ld b, d
	sra c
	sra b
	ld a, c
	add a, $08
	cp $10
	jr nc, .ret ;jump if X / 2 > 08
	ld c, a ;save increased X
	and %11111100 ;mask off bottom two bits
	sla a
	sla a
	sla a
	ld l, a ;shift up three?
	ld a, b
	cpl
	add a, $09 ;negative Y + 8
	cp $10
	jr nc, .ret ;jump if no carry
	ld b, a
	rlca ;rotate left again (back to normal?)
	add a, l
	ld l, a ;L is mod X + mod Y
	ld h, $00
	ld d, $00
	ld a, c ;increased X
	sla a
	and $07
	ld e, a ;bottom bits in E
	ld bc, wRadarBuffer
	add hl, bc ;go to our position
	ld a, [de] ;grab bit mask
	ld e, a ;save it
	or [hl]
	ld [hl], a ;mask!
	srl e
	ld a, e
	or [hl]
	ld [hl+], a ;mask to the right! and advance down
	sla e
	ld a, e
	or [hl]
	ld [hl], a ;mask to the left!
	srl e
	ld a, e
	or [hl]
	ld [hl+], a ;mask to the right! and advance
.ret ;37, 25
	pop hl
	pop de
	pop bc
	ret

PrintStringAtHL: ;741A
	;prints the string HL points to at the screen coord in BC
	ld a, b
	swap a ;swaps the nybbles, huh
	rrca
	and $F8 ;some masking
	ld d, $00
	rla
	rl d
	rla
	rl d
	add a, c
	add a, $00
	ld e, a
	ld a, d
	adc a, $98
	ld d, a ;DE is now a $98XX address
.outerloop
	ld a, [hl+]
	or a
	ret z ;print until a $00 is found
	cp $20
	jr nz, .skip
	ld a, $77 ;use tile 77 for spaces
.skip
	add a, $09 ;i guess the ascii tiles are offset by 9
	ld c, a
.statwait
	ldh a, [rSTAT]
	and $02
	jr nz, .statwait
	ld a, c
	ld [de], a
	inc e
	jr .outerloop ;continue until all the letters are printed
	
PrintInterfaceString: ;7447
	;passed a is the index of the string to write
	ld bc, $0E01 ;these bytes are YX tile offsets
.atBC
	ld hl, InterfaceStringBlank ;a bunch of 20's and then 00
	or a
	jr z, .skip
	dec a
	ld hl, InterfaceStringTable ;this is a pointer table
	rlca ;turn a into a word offset
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;navigate the table
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load the pointer into HL
.skip
	call PrintStringAtHL
	ret
	
DrawMaxedHorizon: ;7462
	ld hl, wHorizonTable
	ld b, $10
	ld a, $58
.loop
	ld [hl+], a
	dec b
	jr nz, .loop
	call CallDrawSurfaceAndSky
	ret
	
Clear3DBG: ;7471
	ld hl, $8D00 ;start of 3D window
	ld c, $10 ;columns
.columnloop
	ld b, $58 ;pixel rows or something
	xor a
.rowloop
	ld [hl+], a
	inc hl
	dec b
	jr nz, .rowloop
	dec c
	jr nz, .columnloop
	ret

IF UNUSED == 1
Unused7482: ;7482
	;loads the last nine of ten bytes wherever $C352 is pointed.
	ld hl, $C352
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	inc hl
	ld a, [$C349]
	ld [hl+], a
	ld a, [$C34A]
	ld [hl+], a
	ld a, [$C34D]
	ld [hl+], a
	ld a, [$C34E]
	ld [hl+], a
	ld a, [$C34B]
	cpl
	add a, $01
	ld [hl+], a
	ld a, [$C34C]
	cpl
	adc a, $00
	ld [hl+], a
	ld a, [$C34F]
	ld [hl+], a
	ld a, [$C350]
	ld [hl+], a
	ld a, [$C351]
	ld [hl+], a
	ret
ENDC

CapHorizonValues: ;74B4
	;cap the 10 bytes at CB21 to $58 max
	ld hl, wHorizonTable
	ld b, $10
.loop
	ld a, [hl+]
	cp $58
	jr c, .skip
	ld a, $58
	dec hl
	ld [hl+], a
.skip
	dec b
	jr nz, .loop
	ret
	
CalculateHorizon: ;74C6
	ld hl, wHorizonTable ;writes 10 bytes at CB21, based on C2BD
	ld b, $10 ;if CB41 is positive, inc values written, if negative, dec
	ld a, [wFlyTilt] ;if this is 1 or -1, load 5 words instead
	or a
	jr z, .zero ;if zero, to 74F2
	bit 7, a
	jr nz, .negative ;if negative, to 74FA
	cp $02
	jr nc, .greaterthanone ;if > 1, to 74E7
	srl b ;otherwise, it was 1. divide b by two so we read five words instead of ten
	ld a, [wPitchAngle]
	sub $04
.wordloop
	ld [hl+], a
	ld [hl+], a
	inc a
	dec b
	jr nz, .wordloop
	ret
	
.greaterthanone ;74E7
	ld a, [wPitchAngle]
	sub $08
.byteloop
	ld [hl+], a
	inc a
	dec b
	jr nz, .byteloop
	ret
	
.zero ;74F2
	ld a, [wPitchAngle]
.noincloop
	ld [hl+], a
	dec b
	jr nz, .noincloop
	ret
	
.negative ;74FA
	cp $FF
	jr c, .lessthannegativeone ;to 750C
	srl b
	ld a, [wPitchAngle]
	add a, $04
.decwordloop
	ld [hl+], a
	ld [hl+], a
	dec a
	dec b
	jr nz, .decwordloop
	ret
	
.lessthannegativeone ;750C
	ld a, [wPitchAngle]
	add a, $08
.decbyteloop
	ld [hl+], a
	dec a
	dec b
	jr nz, .decbyteloop
	ret

DrawSurfaceAndSky: ;7517
	ld hl, wHorizonTable
	ld de, wBackupHorizonTable
	ld b, $10
.copyloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copyloop ;backup current CB21 table to CB31
	call CalculateHorizon
	call CapHorizonValues
	call SetHorizonGFX
	call SetHorizonGFX ;nop this for performance boost?
	ld a, [wPitchAngle]
	ld [wPitchAngleR], a
	ret
	
SetHorizonGFX: ;7538
	ld hl, wHorizonTable
	ld de, wBackupHorizonTable
	ld bc, $8D00 ;this is the start of the 3D window tiles!!
	ld a, $10
.mainloop
	push af
	ld a, [de]
	cp [hl] ;compare old table with new table?
	jr z, .bigskip ;if they're equal, skip over this
	push bc
	push de
	push hl ;else save all these
	ld e, c
	ld d, b ;tiledata address into DE
	jr c, .newbigger ;if new value is bigger, jump
	ld b, a ;old into b
	ld c, [hl] ;new into c
	ld l, e
	ld e, $FF
	jr .endbranch
.newbigger
	ld c, a ;old into c
	ld b, [hl] ;new into b
	ld l, e
	ld e, $00
.endbranch ;bc is loaded with DE and HL values (bigger in B), l is low tiledata address byte, e is OLD-NEW's sign
	ld a, c
	add a, a
	add a, l
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;hl now has tileaddress + 2*c
	ld a, b
	sub a, c
	ld b, a ;b is now the difference between oldval and newval
.writeloop
	ldh a, [rLCDC]
	rla
	jr nc, .skipwaits ;if lcd disabled, skip the loops
.waitblankend
	ldh a, [rSTAT]
	and $02
	jr z, .waitblankend
.waitblankstart
	ldh a, [rSTAT]
	and $02
	jr nz, .waitblankstart
.skipwaits
	ld a, e
	ld [hl+], a ;write the sign to tiledata (half a row)
	inc hl
	dec b
	jr nz, .writeloop
	pop hl
	pop de
	pop bc
.bigskip
	inc hl
	inc de
	ld a, c
	add a, $B0
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;next vertical column
	pop af
	dec a
	jr nz, .mainloop
	ret
	
EntityLogicPowerCrystal: ;758F
	ld a, l
	add a, $0B
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, $FF
	ld [de], a ;write FF to HP
	ld a, [wCrosshairTargetEntityLo]
	cp l
	jp nz, .idleSpin
	ld a, [wCrosshairTargetEntityHi]
	cp h
	jp nz, .idleSpin
	ld a, [$C2AD]
	or a
	jp z, .idleSpin
	ldh a, [$FFDC]
	cp $05
	jr nc, .idleSpin
	ld a, [wHasCargo]
	or a
	jr nz, .idleSpin ;to end of block
	ld a, CARGO_CRYSTAL
	ld [wHasCargo], a
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, LOW(CollectCrystal)
	ld [hl+], a
	ld a, HIGH(CollectCrystal)
	ld [hl+], a ;write $7604 to entity logic pointer
	ld a, TRACK_ITEM_REVEAL
	ld [wQueueMusic], a
	call ClearAllScreenText
	ld hl, PowerCrystalRetrieveText1
	ld c, $01
	call CallTryWriteScreenText
	ld hl, PowerCrystalRetrieveText2
	ld c, $01
	call CallTryWriteScreenText
	ld hl, PowerCrystalRetrieveText3
	ld c, $01
	call CallTryWriteScreenText
	ld a, $96
	ld [wLevelIntroTimer], a
	ld [$C273], a
	ret
.idleSpin ;75F7
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	sub $04
	ld [hl+], a ;subtract 4 from Z orientation (make it spin like a top)
	ret
	
CollectCrystal: ;7604
	push hl
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl] ;check speed?
	inc a
	ld [hl], a ;increment speed?
	cp $02
	pop hl
	ret c ;do nothing for two frames?
	call CallDestroyEntityObject
	call CallCleanUpPickupItem
	ld a, $C8 ;$C8 ticks
	ld [wGoalCellTimer], a
	ld a, $01
	ld [wGoalCellID], a
	ld a, $18 ;Nuclear Silo
	ld [wGoalEntityID], a
	ret

SECTION "bank 2 tabledata", ROMX[$762A], BANK[2]
InterfaceStringBlank: ;762A
	db "       ", 00
InterfaceStringTable: ;7632, todo
	dw $7672 
	dw $767A 
	dw $7682 
	dw $768A 
	dw $7692 
	dw $769A 
	dw $76A2 
	dw $76AA 
	dw $76B2 
	dw $76BA 
	dw $76C2 
	dw $76CA 
	dw $76D2 
	dw $76DA 
	dw $76E2 
	dw $76EA 
	dw $76F2 
	dw $76FA 
	dw $7702 
	dw $770A 
	dw $7712 
	dw $771A 
	dw $7722 
	dw $772A 
	dw $7732 
	dw $773A 
	dw $7742 
	dw $774A 
	dw $7752 
	dw $775A 
	dw $7762 
	dw $776A 
;7672, text
	db "BALLS  ", 00
	db "PULSE  ", 00
	db "D PULSE", 00
	db "D BEAM ", 00
	db "Q BEAM ", 00
	db "MESON  ", 00
	db "FUEL   ", 00
	db "HP     ", 00
	db "X POWER", 00
	db "FINDER ", 00
	db "[[[[   ", 00 ;torpedoes
	db "[[[    ", 00
	db "[[     ", 00
	db "[      ", 00
	db "\\\\     ", 00 ;smart bombs (mind the backslashes)
	db "\\      ", 00
	db "CRYSTAL", 00
	db "XPUTER ", 00
	db "CUBIFY ", 00
	db "GO BEAC", 00
	db "GO BASE", 00
	db "GO LOCK", 00
	db "] ] ]  ", 00 ;mines
	db "] ]    ", 00
	db "]      ", 00
	db "BOMB   ", 00
	db "X FUEL ", 00
	db "X HP   ", 00
	db "JETPAC ", 00
	db "LASER  ", 00
	db "LOCK ON", 00
	db "HIGH EX", 00
;7772, shop text
	db "BUY", 00
	db "SELL", 00
	db "CANNOT SELL HERE", 00
	db "                ", 00
	db " INVENTORY FULL ", 00
;77AE, VIXIV speeds
	db "REVERSE", 00
	db "STOPPED", 00
	db "LOW    ", 00
	db "MEDIUM ", 00
	db "HIGH   ", 00
	db "FULL   ", 00
	
CalcClosestDistance: ;77DE
	xor a ;whole bunch of ram values i don't know
	ld [wNearestEntityLo], a
	ld [wNearestEntityHi], a ;address for closest entity
	cpl
	ld [wClosestDist], a ;set this to max ($FF)
	ld a, [$CACB]
	cp $02
	jr nz, .skeep ;this leads to the loop
	ld a, [$C2BF]
	ld l, a
	ld [wNearestEntityLo], a
	ld a, [$C2C0]
	ld h, a
	ld [wNearestEntityHi], a
	or l
	jr z, .skeep2 ;if HL is blank, jump
	dec hl
	bit 7, [hl]
	jr z, .skeep3
	xor a
	ld [$C2BF], a
	ld [$C2C0], a
	jr .skeep2
.skeep3
	inc hl
	call CheckClosestDistance
	jr .skeep2
.skeep
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop ;once we're in this loop, nothing breaks out of it until all $28 loops are done
	ld a, [hl+]
	or a
	jr z, .skeep4 ;empty slot
	bit 7, a
	jr nz, .skeep4 ;hidden slot
	ld c, a
	add a, LOW(IgnoreModelForClosestTable) ;low flag byte
	ld e, a
	ld a, HIGH(IgnoreModelForClosestTable) ;high flag byte
	adc a, $00
	ld d, a
	ld a, [de]
	bit 0, a
	jr z, .skeep4 ;if table returns 0, ignore model
	push hl
	call CheckClosestDistance
	pop hl
	jr c, .skeep4 ;c means no new closest, so skip
	ld a, l
	ld [wNearestEntityLo], a
	ld a, h
	ld [wNearestEntityHi], a ;otherwise store current address to C2B5/6
.skeep4
	ld a, l
	add a, $18
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;increment HL
	dec b
	jp nz, .loop
.skeep2
	ld a, [wClosestDist]
	ld c, a
	ld a, $02
	add a, $02
	dec a
	jr z, .cb2
	dec a
	jr z, .cb3
	dec a
	jr z, .cb4
	dec a
	jr z, .cb5
.cb1
	srl c
	jr .endcb
.cb2
	srl c
	srl c
	jr .endcb
.cb3
	srl c
	srl c
	srl c
	jr .endcb
.cb4
	srl c
	srl c
	srl c
	srl c
	jr .endcb
.cb5
	srl c
	srl c
	srl c
	srl c
	srl c
.endcb
	ld a, c
	cp $08
	jr c, .skiplda
	ld a, $07
.skiplda
	cpl
	add a, $08
	sub $01
	adc a, $00
	ld [wClosestDist], a
	ld a, [$C0AF]
	cp $2C
	ret z
	ld a, [$CA9F]
	cp $01
	ret nc
	ld a, [wFrameCounterLo]
	and $07
	sub $01
	adc a, $00
	ld [wClosestDist], a
	ret
	
EntityLogicMine: ;78AF
	push hl
	call CallEntityLogicSprog3ScenerySix
	pop hl
	ld a, [$CAFF]
	inc a
	ld [$CAFF], a ;increment count
	ld a, [$C2B8] ;enabled?
	or a
	ret z
	push hl
	ld hl, MineDiscoveredText
	ld c, $19
	call CallTryWriteScreenText
	pop hl
	push hl
	call GetDistanceFromPlayer
	pop hl
	ret c
	cp $0A
	ret nc ;if far enough, we're done here
	dec hl
	set 7, [hl] ;set top bit (hides entity)
	ld a, $02
	ld [wQueueNoise], a
	ld a, [wHealth]
	sub $03
	ld [wHealth], a
	ld a, [wScreenShakeCounter]
	add a, $32
	ld [wScreenShakeCounter], a
	ld hl, MineDetonatedText
	ld c, $32
	call CallTryWriteScreenText
	ret

GetDistanceBetweenEnts: ;78F4
	inc de ;entity x
	ld a, [de]
	ld c, a ;store to C
	inc de
	inc de ;entity y
	ld a, [de]
	ld e, c
	ld d, a ;YX in DE
	call GetDistance
	ret

GetDistanceFromPlayer: ;7900
	ldh a, [hXPosHi]
	ld e, a
	ldh a, [hYPosHi]
	ld d, a
GetDistance: ;7906
	inc hl
	ld a, [hl+]
	sub a, e
	ld e, a
	inc hl
	ld a, [hl]
	sub a, d
	ld d, a ;XY pos bytes - pos bytes at HL
	bit 7, e
	jr z, .noabs1
	ld a, e
	cpl
	inc a
	ld e, a
.noabs1
	bit 7, d
	jr z, .noabs2
	ld a, d
	cpl
	inc a
	ld d, a
.noabs2 ;if either resulting position bytes were negative, negate them.
	ld a, d ;DE are now Y and X distances between two points
	add a, e
	ld l, a ;l = D+E
	ld a, d
	cp e
	jr nc, .end ;carry set if d < e
	ld a, e ;if d < e, add e instead
.end
	add a, l ;A = X+Y offsets, plus the bigger of X or Y again
	ret c ;c set if Y < X
	ret
	
CheckClosestDistance: ;7929
	call GetDistanceFromPlayer
	ret c ;if X distance was greater than Y distance, return
	ld l, a ;else, load l with the distance?
	ld a, [wClosestDist]
	cp l ;saved - new
	ret c ;if new larger, return
	ld a, l
	ld [wClosestDist], a ;otherwise save our new distance
	and a ;and return with it in a
	ret
	
IF UNUSED == 1
LoadSRAM_OLD: ;7939, lefdoff
	ld a, SRAM_ENABLE
	ld [$0018], a ;enable
	ld hl, SRAM_Begin
	ld de, $CF3B
	ld b, $00
.sramloop
	ld a, [hl+]
	and $0F
	ld c, a
	ld a, [hl+]
	and $0F
	swap a
	or c
	ld [de], a ;load two nybbles from sram
	inc de
	dec b
	jr nz, .sramloop
	ld hl, $CF3B
	ld a, $FF
	ld b, a
.verifyloop
	xor [hl]
	inc hl
	dec b
	jr nz, .verifyloop
	cp [hl]
	jr z, .done ;if they match, jump
	ld b, $00
.invertloop
	ldh a, [rBGP]
	cpl
	ldh [rBGP], a
	dec b
	jr nz, .invertloop
	ld hl, DefaultHiscoreTable
	ld de, $CF3B
	ld b, $FF
.setdefaultloop
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .setdefaultloop
	call CallSaveSRAM_OLD
.done
	xor a
	ld [$0019], a ;done with sram
	ret
	
SaveSRAM_OLD: ;7983
	ld hl, $CF3B
	ld a, $FF
	ld b, a
.calcloop
	xor [hl]
	inc hl
	dec b
	jr nz, .calcloop
	ld [hl+], a ;save checksum
	ld a, SRAM_ENABLE
	ld [$0018], a
	ld hl, $CF3B
	ld de, SRAM_Begin
	ld b, $00
.saveloop
	ld a, [hl]
	ld [de], a
	inc de
	ld a, [hl+]
	swap a
	and $0F
	ld [de], a
	inc de
	dec b
	jr nz, .saveloop
	xor a
	ld [$0019], a
	ret
	
CheckForHiscore_OLD: ;79AE
	call CallLoadSRAM_OLD
	ld hl, $CF45 ;top score first digit
	ld b, $05 ;number of scores
.scoreloop
	push bc
	push hl
	ld de, wScoreHundredThousands
	ld a, [de]
	cp [hl]
	jr nz, .different ;if they don't match, jump
	inc hl
	inc de ;next digit
	ld a, [de]
	cp [hl]
	jr nz, .different ;no match = jump
	inc hl
	inc de ;thousands
	ld a, [de]
	cp [hl]
	jr nz, .different ;no match = jump
	inc hl
	inc de ;hundreds
	ld a, [de]
	cp [hl]
	jr nz, .different ;no match = jump
	inc hl
	inc de ;tens
	ld a, [de]
	cp [hl]
	jr nz, .different ;no match = jump
	inc hl
	inc de ;ones
	ld a, [de]
	cp [hl]
	jr nz, .different ;no match = jump
	inc hl
	inc de ;end digit?
.different ;20, 1A, 14, E, 8, 2, no match
	pop hl
	pop bc
	jr nc, InsertHiscoreOLD ;greater? replace this one, jump
	ld a, l
	add a, $10
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;next score
	dec b
	jr nz, .scoreloop
	ret
InsertHiscoreOLD: ;79EF, C
	push hl
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, LOW(wHiscores.end)
	sub a, l
	ld c, a
	ld a, HIGH(wHiscores.end) ;CF8B, end of the hiscore table
	sbc a, h
	ld b, a ;BC is now number of bytes to shift?
	or c
	jr z, .writeEntry ;if at the end, jump ahead
	ld hl, $CF7A
	ld de, $CF8A
.shiftloop ;F8
	ld a, [hl-]
	ld [de], a
	dec de
	dec bc
	ld a, b
	or c
	jr nz, .shiftloop
.writeEntry ;e
	pop hl
	ld de, wScore
	ld b, $06
.scoreLoop
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .scoreLoop
	ld a, l
	sub $10
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	ld de, wPlayerName
	ld b, $0A ;length
.nameLoop ;FA
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .nameLoop
	call CallSaveSRAM_OLD
	ret

DefaultHiscoreTable: ;7A34, hiscore table. $9 letters, $6 digits, and ended with 00
db "DYLAN",   0,0,0,0,0,5,0,0,0,0,0
db "FRED",  0,0,0,0,0,0,0,4,0,0,0,0
db "BOB", 0,0,0,0,0,0,0,0,0,3,0,0,0
db "SUPERMAN",      0,0,0,0,0,2,0,0
db "DYLAN",   0,0,0,0,0,0,0,0,0,1,0
ENDC

EntityLogicGasCan: ;7A84
	ld a, [wEntityCollided]
	or a
	jr z, .update
	xor a
	ld [wCollisionType], a
.update ;4
	call CallMoveBomb
	ld e, l
	ld d, h
	ld a, e
	add a, $07 ;y rotation (top down)
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	add a, $07
	ld [de], a ;spin
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
	ld a, [wFuelAmountHi]
	add a, $40 ;a quarter
	ld [wFuelAmountHi], a
	jr nc, .done
	ld a, $FF
	ld [wFuelAmountLo], a
	ld [wFuelAmountHi], a
.done;8
	xor a
	ld [wCollisionType], a
	ret
	
EntityLogicMushroom: ;7ADC
	ld a, [wEntityCollided]
	or a
	jr z, .update
	xor a
	ld [wCollisionType], a
.update
	call CallMoveBomb
	ld e, l
	ld d, h
	ld a, l
	add a, $07 ;y spin
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	add a, $09
	ld [de], a ;spin
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
	ld a, [wHealth]
	inc a
	cp $09
	adc a, $FF
	ld [wHealth], a
	xor a
	ld [wCollisionType], a
	ret

SetAlertTiles: ;7B2D
	ldh a, [hGameState]
	dec a
	jr nz, .notplanetskip
	ld a, [$C2A1]
	cpl
	and $03
	ret nz
.notplanetskip
	call CalcClosestDistance
	ld a, [wClosestDist]
	cp $06
	jr nz, .skip1
	ld a, [wFrameCounterLo]
	and $20
	jr z, .skip1
	ld a, [$CB49]
	or a
	jr nz, .skip2
	ld a, [$C29A]
	or a
	jr nz, .skip2
	ld a, $06
	ld [$C110], a
.skip2
	ld a, [wClosestDist]
.skip1
	ld c, a ;used for inactive tile counter
	ld b, a ;active tile counter
	ld hl, $9983
	or a
	jr z, .noleftactive
.setleftactive
	ldh a, [rSTAT]
	and $02
	jr nz, .setleftactive
	ld a, $8E ;left-side alert on
	ld [hl+], a
	dec b
	jr nz, .setleftactive
.noleftactive
	ld a, $06
	sub a, c
	ld b, a
	jr z, .noleftinactive
	jr c, .noleftinactive
.setleftinactive
	ldh a, [rSTAT]
	and $02
	jr nz, .setleftinactive
	ld a, $8D ;left-side alert off
	ld [hl+], a
	dec b
	jr nz, .setleftinactive
.noleftinactive
	ld a, [wClosestDist]
	cp $06
	jr nz, .skeepload
	ld a, [wFrameCounterLo]
	and $20
	jr z, .skeepload
	ld a, [wClosestDist]
.skeepload
	ld c, a
	ld b, a
	ld hl, $9992
	or a
	jr z, .norightactive
.setrightactive
	ldh a, [rSTAT]
	and $02
	jr nz, .setrightactive
	ld a, $8C ;right-side alert on
	ld [hl-], a
	dec b
	jr nz, .setrightactive
.norightactive
	ld a, $06
	sub a, c
	ld b, a
	jr z, .norightinactive
	jr c, .norightinactive
.setrightinactive
	ldh a, [rSTAT]
	and $02
	jr nz, .setrightinactive
	ld a, $8B ;right-side alert off
	ld [hl-], a
	dec b
	jr nz, .setrightinactive
.norightinactive
	ret
	
HighEXDamageEnts: ;7BC0
	inc hl
	ld a, [hl+]
	sub $1E
	ld e, a
	inc hl
	ld a, [hl+]
	sub $1E
	ld d, a ;save bomb ent position into DE
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.testEnt
	ld a, [hl+]
	bit 7, a ;test intangible bit
	jr nz, .nextEnt ;jump if set
	or a
	jr z, .nextEnt ;jump if no model
	push bc
	push hl
	inc hl
	ld a, [hl+]
	sub a, e
	cp $3C
	jr nc, .restoreCounter ;jump if out of range
	inc hl
	ld a, [hl+]
	sub a, d
	cp $3C
	jr nc, .restoreCounter ;jump if out of range
	pop hl
	push hl
	push de
	ld a, $28
	call CallDamageEntity
	pop de
.restoreCounter ;10, 9
	pop hl
	pop bc
.nextEnt ;1E, 1B
	ld a, l
	add a, ENTITY_SIZE - 1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jr nz, .testEnt
	ret

BombDamageEnts: ;7BFE
	inc hl
	ld a, [hl+]
	sub $05
	ld e, a
	inc hl
	ld a, [hl+]
	sub $05
	ld d, a ;D and E are now Xpos and Zpos, minus 5 ea.
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop
	ld a, [hl+]
	bit 7, a
	jr nz, .next ;jump if disabled flag set
	or a
	jr z, .next ;jump if empty slot
	push bc ;save counter
	push hl ;save ent pointer
	inc hl
	ld a, [hl+]
	sub a, e ;check X
	cp $0A
	jr nc, .restorecounter
	inc hl
	ld a, [hl+]
	sub a, d ;check Z
	cp $0A
	jr nc, .restorecounter
	pop hl
	push hl
	push de ;save bomb position
	ld a, $0F
	call CallDamageEntity
	pop de ;bomb pos
.restorecounter
	pop hl ;ent pointer
	pop bc ;counter
.next
	ld a, l
	add a, ENTITY_SIZE - 1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jr nz, .loop
	ret
	
EntityLogicTimeBomb: ;7C3C
	ld a, [$CB02]
	inc a
	ld [$CB02], a ;update count
	ld a, [$C2AD] ;objectives
	or a
	jr z, .checkBOOM
	xor a
	ldh [$FFA1], a ;clear out rotation
	ldh a, [$FFDF]
	sub $28
	ldh [$FFDF], a ;no idea.. offset?
	ldh a, [$FFE0]
	sbc a, $00
	ldh [$FFE0], a
	ldh a, [$FFDD]
	sub $78
	ldh [$FFDD], a ;offset?
	ldh a, [$FFDE]
	sbc a, $00
	ldh [$FFDE], a
	ld a, [wTimerFramesHi]
	cp $0A
	jp nc, .checkBOOM ;if above $A, jump
	ld a, [wTimerDigit3]
	ld c, a
	ld a, [wTimerDigit2]
	push hl
	swap a
	or c
	ld c, a ;digits in C and A
	ld b, $00
	call Draw3DNumber
	pop hl
.checkBOOM ;35, 7C7E
	ld a, [wTimerFramesLo]
	ld e, a
	ld a, [wTimerFramesHi]
	or e
	ret nz ;if seconds left, do nothing
	call CallHighEXDamageEnts
	ld a, [$C2B8]
	or a
	ret z
	ld a, [wHealth]
	sub $0A ;owie
	ld [wHealth], a
	ret

EntityLogicSpewer: ;7C98 - "opening cone", volcano?
	push hl
	ld a, $16
	call GetMatchingEntitySlots
	pop hl
	cp $03
	ret nc ;if already have three spawned, return
	push hl
	call NextRand
	pop hl
	and $3F
	ret nz ;1 in 0x40 chance
	ld a, $16 ;entity ID
	call EntityDropNewEntity
	ret c
	ld a, e
	add a, $12
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld a, $50
	ld [hl-], a
	dec hl
	ld [hl], $01 ;set word at offset $12 to $0150
	ld a, e
	add a, $05
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;y position
	ld a, $C4
	ld [de], a
	inc de
	ld a, $FF ;x orientation
	ld [de], a
	inc de
	ld a, $C0 ;z orientation
	ld [de], a
	ret

DrawBall: ;7CD2
	;passed H is diameter, L is Y, C is X
	ld a, h
	srl a
	ld d, a ;h/2 in D (radius)
	ld a, c
	sub a, d
	ld c, a ;C -= D (X?)
	ld a, l
	sub a, d
	ld l, a ;L -= D (Y?)
	cp $58
	ret nc
	ld e, l ;backup L into E
	ld a, h
	dec a
	cpl ;negate H?
	swap a
	and %11110000 ;low bits are now the only ones present, as high bits
	ld l, a ;and save to L
	ld a, c
	and %00000111
	rlca ;shift up (use only every second X)
	or l
	ld l, a ;construct a table using diameter for row and shifted/masked X as column
	ld a, l
	add a, LOW(BallFrameTable)
	ld l, a
	ld a, h
	push af ;backup diameter
	ld a, HIGH(BallFrameTable)
	adc a, $00
	ld h, a ;HL += 4642 (oval pointer table)
	pop af
	cp $09
	jp c, .smallradius ;if diameter was below 09, jump
	ld a, [hl+]
	ld h, [hl]
	ld l, e ;restore the backup L (Y)
	ld e, a ;load the gfx pointer into H and E
	ld a, c ;C into A (X)
	rrca
	rrca
	rrca
	and %00011111 ;the top five bits, shifted down
	add a, HIGH(wMonoBufferColumn1)
	ld d, h ;table pointer's now in DE
	ld h, a ;monobuffer's now in HL
	ld b, $03 ;three wide, two tall
	ld c, l
.drawloop ;BB
	ld a, [de] ;grab circle graphic data
	or [hl] ;overlay on the buffer
	ld [hl+], a ;save
	inc de ;next
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de ;16 times
	ld l, c ;next line
	inc h
	dec b ;loop?
	jr nz, .drawloop ;loop
	ret
	
.radius3 ;7D56, value was 3
	ld a, [hl+]
	ld h, [hl]
	ld l, e
	ld e, a
	ld a, c
	rrca
	rrca
	rrca
	and %00011111
	add a, HIGH(wMonoBufferColumn1)
	ld d, h
	ld h, a
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	dec l
	dec l
	dec l
	inc h
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de] ;six bytes
	or [hl]
	ld [hl+], a
	inc de
	ret
	
.smallradius ;7D81
	dec a ;hl used for table
	jr z, .radius1 ;if 1, jump
	dec a
	jr z, .radius2 ;if 2, jump to 7DDA
	dec a
	jr z, .radius3 ;if 3, jump to 7D56
	ld a, [hl+]
	ld h, [hl] ;else, read word
	ld l, e
	ld e, a
	ld a, c
	rrca
	rrca
	rrca
	and %00011111
	add a, HIGH(wMonoBufferColumn1)
	ld d, h
	ld h, a
	ld b, $02 ;two wide
	ld c, l
.eightloop ;DB
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de] ;eight bytes
	or [hl]
	ld [hl+], a
	inc de
	ld l, c
	inc h
	dec b
	jr nz, .eightloop
	ret
.radius1 ;7DC1, 3D, value was 1
	ld a, [hl+]
	ld h, [hl]
	ld l, e
	ld e, a
	ld a, c
	rrca
	rrca
	rrca
	and %00011111
	add a, HIGH(wMonoBufferColumn1)
	ld d, h
	ld h, a
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	dec l
	inc h
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de ;two bytes
	ret
.radius2 ;7DDA, value was 2
	ld a, [hl+]
	ld h, [hl]
	ld l, e
	ld e, a
	ld a, c
	rrca
	rrca
	rrca
	and %00011111
	add a, HIGH(wMonoBufferColumn1)
	ld d, h
	ld h, a
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	dec l
	dec l
	inc h
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de ;four bytes
	ret
	
SetEntityLogicPointer: ;7DFC
	add a, a
	add a, LOW(EntityLogicPointers)
	ld e, a
	ld a, HIGH(EntityLogicPointers)
	adc a, $00
	ld d, a ;5022, passed A is offset into two bytes
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ret

TurnEntTowardsPlayer: ;7E0B
	call CallGetAngleToEntity
	ld c, a ;backup angle to C
	ld e, l
	ld d, h ;backup HL into DE
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance HL to Z orientation
	ld a, [hl]
	sub a, c ;subtract angle from orientation
	jr z, .doneturning ;if even, skip
	cp $88
	jr nc, .turnright
	cp $78
	jr c, .turnleft
	;else choose a random direction+amount
	call NextRand
	and $07
	sub $04
	add a, [hl]
	ld [hl], a
	jr .doneturning
.turnleft ;B
	ld a, [hl]
	sub $04
	ld [hl], a
	jr .doneturning
.turnright ;15
	ld a, [hl]
	add a, $04
	ld [hl], a
.doneturning ;1D, A, 4
	ld h, d
	ld l, e
	ret
	
EntityLogicRamp: ;7E3D, ramp logic
	ld a, [wEntityCollided]
	or a
	ret z
	jp CallPlayerJump ;if colliding, jump
	
EntityLogicMissilePickup: ;7E45
	ld a, [wEntityCollided]
	or a
	jr z, .update
	xor a
	ld [wCollisionType], a
.update
	call CallMoveBomb
	ld e, l
	ld d, h
	ld a, e
	add a, $07
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;y rot
	ld a, [de]
	add a, $07
	ld [de], a ;spin
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
	call CallDestroyEntityObject
	call CallCleanUpPickupItem
	ld a, $12
	ld [wQueueSFX], a
	ld a, [wMissileCount]
	cp MISSILES_MAX
	ret nc
	inc a
	ld [wMissileCount], a
	ret

EntityLogicBase: ;7E94
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;z orientation?
	ld a, [de]
	add a, $05
	ld [de], a ;speen??? the bases used to spin earlier
	ld a, [wMissionBasesLeft]
	inc a
	ld [wMissionBasesLeft], a
	ld a, [$C356]
	or a
	jr z, .ret
	;collision
	ld a, $02
	ld [$CB07], a ;friendly collision!
	ld a, [wLurchTarget]
	bit 7, a
	jr nz, .ret ;must be bouncing in a certain hemisphere to be able to enter
	xor a
	ld e, a
	ld a, [wViewDir]
	ld d, a
	sub a, e
	add a, $20
	ld e, a
	cp $40
	jr nc, .ret
	ld a, [wTutSawAllRadarText]
	or a
	jr nz, .enterbase
	ld hl, $7CD1
	call CallCheckTutScriptProgress
	jr c, .enterbase
	ld hl, $7D70
	call CallDisplayTutorialLesson
	call CallRestoreGUIAndMusic
	ret
.enterbase ;12, A
	ld a, $09
	ld [wQueueNoise], a
	ld a, $05
	ld [wSubscreen], a
.ret ;3C, 30, 22
	ret
	
EntityLogicGun: ;7EEA, turret/"gun" logic
	ld a, [$CAF8]
	inc a
	ld [$CAF8], a
	ld a, [$C2B8]
	or a
	ret z ;if clear, don't do anything
	ld e, l
	ld d, h ;load DE with entity pointer
	ld a, e
	add a, $07
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance 7 to z orientation
	ld a, [de]
	add a, $0A
	ld [de], a ;spin it by $A
	call NextRand
	and $1F
	ret nz ;1 in 32 chance
	ld a, $14 ;entity 14, ants?
	call GetMatchingEntitySlots
	cp $03
	ret nc ;if 3 or more of specified entity exist, return
	ld a, $14
	call CallEntityDropNewEntity ;else, shoot!
	ld a, $FF
	ld [$CA8C], a
	ret
;7F1D
	

SECTION "2:7F23", ROMX[$7F23], BANK[2]
EntityLogicAlienBase2: ;7F23
	ld a, [$CAF9]
	inc a
	ld [$CAF9], a ;increase count
	call GetDistanceFromPlayer
	ret c
	cp $12
	ret nc ;return if far enough away
	call CallBarOutScreen
	call CallBumpedRecoil ;else bump us away!
	ret
	
EntityLogicSceneryEight: ;7F38
	ld a, [wEntityCollided]
	or a
	ret z
	ld a, $02
	ld [wCollisionType], a
	ret
	
DestroyAllHostiles: ;7F43
	ld hl, wEntityTable
	ld b, ENTITY_SLOTS
.loop ;7F48
	ld a, [hl]
	or a
	jr z, .next
	bit 7, a
	jr nz, .next ;skip if deloaded or hidden
	add a, LOW(IgnoreModelForClosestTable)
	ld e, a
	ld a, HIGH(IgnoreModelForClosestTable)
	adc a, $00
	ld d, a ;table at 5122.. TODO: is this just a "hostile" table?
	ld a, [de]
	or a
	jr z, .next ;if not, go to the next one
	inc hl ;else advance to the position
	call CallDestroyEntityObject ;else kill it!!
	dec hl
.next ;15, 11, 5
	ld a, l
	add a, ENTITY_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .loop
	ret
;7F6E