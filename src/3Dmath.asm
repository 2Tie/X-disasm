RotateCoordByAngle_B: ;4000
	;pass two coordinates and an angle as BC and A
	;returns resulting coordinates in BC
	;c1' = c1*cos(angle) - c2*sin(angle)
	;c2' = c1*sin(angle) + c2*cos(angle)
	push bc ;sav the bytes passed (c1 and c2)
	ld h, HIGH(SinTable)
	ldh [$FFA6], a ;(FFA5)
	ld l, a ;passed a is the lower part of $41XX address (angle?)
	ld d, c ;load c2 into d
	ld c, [hl] ;sin(angle) saved into c
	ld h, $47
	ld a, c
	or a
	jp nz, .pass1read1 ;if the address had a value, skip
	ld h, $00
	jp .pass1skip ;else set new address page to 00 and jump ahead
.pass1read1 ;4014
	;value at the address
	ld a, b
	or a
	jp nz, .pass1read2 ;if c1 != 0, skip
	ld h, $00
	jp .pass1skip ;else set value to 0 and skip to next tableread (first element is always 0)
.pass1read2 ;401E
	;value in b
	ld l, a ;put c1 value into L
	ld e, [hl] ;load e with value at $47XX where XX is passed c1
	ld l, c
	ld a, [hl] ;load a with value at $47XX where XX is sin(angle)
	add a, e
	ld l, a ;add them together, use as new offset
	inc h ;increment the page
	ld h, [hl] ;load h with $48XX, XX from summed values
	ld a, c ;load a with sin(angle)
	xor b ;xor with c1 (clears carry)
	rla ;shift top bit into carry/multiply by two
	jp nc, .pass1skip ;jump if top bit wasn't set?
	xor a
	sub a, h
	ld h, a ;else negate our $48XX value. (this does abs())
.pass1skip ;402F
	ld c, d ;restore the passed c2
	ld d, h ;d loaded with our final value for pass 1 (??)
	;now the second part, using C2 and cos(angle) table
	ld h, HIGH(CosTable)
	ldh a, [$FFA6] ;restore the passed a
	ld l, a ;use it as a lower adress
	ld b, [hl] ;load b with cos(angle)
	ld h, $47
	ld a, c
	or a
	jp nz, .pass1read3 ;make sure the passed c2 had a value
	ld h, $00
	jp .pass1end
.pass1read3 ;4043
	ld a, b 
	or a
	jp nz, .pass1read4 ;make sure our retrieved value isn't zero
	ld h, $00
	jp .pass1end
.pass1read4 ;404D
	ld l, a
	ld e, [hl] ;load $47XX into e, where XX is cos(angle)
	ld l, c 
	ld a, [hl] ;load $47XX into a, where XX is c2
	add a, e ;then add them together
	ld l, a
	inc h
	ld h, [hl] ;load h with value at $48XX, XX being the sum above
	ld a, c ;load c2 into a
	xor b ;xor with $42XX value (clears carry)
	rla ;shift top bit into carry/mult by two
	jp nc, .pass1end ;if top bit of c2 isn't set, negate our $48XX value
	xor a
	sub a, h
	ld h, a
.pass1end ;405E
	ld a, h
	sub a, d ;cos sum - sin sum
	ldh [$FFA0], a ;store the result (c2') in FFA0
	pop bc
	;second half time!
	push bc ;restore the passed c1 and c2, passed a is still in FFA6
	ld h, HIGH(CosTable)
	ldh a, [$FFA6]
	ld l, a
	ld c, [hl] ;save the cos(angle) (again)
	ld h, $47
	ld a, c
	or a
	jp nz, .pass2read1
	ld h, $00
	jp .pass2skip
.pass2read1 ;4076
	ld a, b
	or a
	jp nz, .pass2read2 ;check passed c1 for value
	ld h, $00
	jp .pass2skip
.pass2read2 ;4080
	ld l, a
	ld e, [hl] ;if c1 nonzero, read $47XX using c1
	ld l, c ;also read $47XX using cos(angle)
	ld a, [hl]
	add a, e ;add them together
	ld l, a
	inc h
	ld h, [hl] ;read $48XX where XX is the sum above
	ld a, c
	xor b
	rla
	jp nc, .pass2skip ;if top bit was set, negate read value
	xor a
	sub a, h
	ld h, a
.pass2skip ;4091
	pop bc
	ld d, h ;store first value into d
	ld h, HIGH(SinTable)
	ldh a, [$FFA6]
	ld l, a
	ld b, [hl] ;sin(angle)
	ld h, $47
	ld a, c
	or a
	jp nz, .pass2read3
	ld h, $00
	jp .end
.pass2read3 ;40A5
	ld a, b
	or a
	jp nz, .pass2read4
	ld h, $00
	jp .end
.pass2read4 ;40AF
	ld l, a
	ld e, [hl] ;sin(angle)
	ld l, c
	ld a, [hl] ;c2
	add a, e
	ld l, a
	inc h
	ld h, [hl] ;48XX c2+sin(angle)
	ld a, c
	xor b
	rla
	jp nc, .end
	xor a
	sub a, h
	ld h, a
.end ;40C0
	ld a, h
	add a, d ;sin sum + cos sum
	ld b, a ;load result (c1') into b
	ldh a, [$FFA0]
	ld c, a ;load c2' into c
	sla b ;mult by 2
	sla c ;mult by 2
	ret
	
MultiplyValues_B: ;40CB
	;bc are input values, result saved to H
	ld h, $47
	ld a, c
	or a
	jp nz, .notzero1 ;check if passed c is zero
	ld h, $00
	jp .ret
.notzero1 ;40D7
	ld a, b
	or a
	jp nz, .notzero2 ;check if passed b is zero
	ld h, $00
	jp .ret
.notzero2 ;40E1
	ld l, a
	ld e, [hl] ;load e with the value at $47XX, XX being passed b
	ld l, c
	ld a, [hl] ;load a with the value at $47XX, XX being passed c
	add a, e ;add them together
	ld l, a
	inc h
	ld h, [hl] ;load h with the value at $48XX, XX being sum above
	ld a, c
	xor b ;xor the passed values together
	rla
	jp nc, .ret
	xor a
	sub a, h ;if top bit was set, negate h
	ld h, a
.ret ;40F2
	ret ;an h of 0 is returned if 0th element is ever grabbed
;$00's until $4100

SECTION "B:4100", ROMX[$4100], BANK[$B]
SinTable_B: ;4100-41FF: todo, can i generate these?
	INCBIN "src/sintable.bin"
CosTable_B: ;4200-42FF: symmetrical table
	INCBIN "src/costable.bin"
;4300-43FF: exponential? table, 0x40 - 0xFF
INCREMENT = 0.5
INCREMENT = INCREMENT + (1.0 >> 10)
VALUE = 64.0
    REPT 256
    db (VALUE >> 16)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT + (1.0 >> 9)
    ENDR
;4400-44FF: exponential? table, 0x00 - 0x40
INCREMENT = 0.0
INCREMENT = INCREMENT + (1.0 >> 10)
VALUE = 0.0
    REPT 256
    db (VALUE >> 16)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT + (1.0 >> 9)
    ENDR
;4500-45FF: exponential? tables
INCREMENT = 0.0
INCREMENT = INCREMENT + (1.0>>2)
VALUE = 0.0
    REPT 256
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT + (1.0 >> 1)
    ENDR
;4600-46FF: symmetrical tables?
INCREMENT = 24.0
VALUE = 0.0
    REPT 7
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 << 3)
    ENDR
	  
INCREMENT = 16.0
VALUE = 0.0
    REPT 5
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 << 3)
    ENDR
	  
INCREMENT = 12.0
VALUE = 0.0
    REPT 4
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 << 3)
    ENDR
	  
	REPT 6
INCREMENT = 10.0
VALUE = 0.0
    REPT 4
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 << 3)
    ENDR
	  
INCREMENT = 11.0
VALUE = 0.0
    REPT 4
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 << 3)
    ENDR
	ENDR
	
INCREMENT = 7.0
VALUE = 0.0
    REPT 29
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 >> 1)
    ENDR
	
INCREMENT = 3.0
VALUE = 0.0
    REPT 3
    db ((VALUE >> 16) & $FF)
VALUE = VALUE + INCREMENT
INCREMENT = INCREMENT - (1.0 >> 1)
    ENDR
	
	REPT $A0
	db 0
	ENDR
;4700-47FF: symmetrical table
	INCBIN "src/4700.bin" ;todo

;4800-48FF: linear table (logarithmic? increase climbs quickly at start but lower over time)
	INCBIN "src/4800.bin"
;INCREMENT = 0.5
;VALUE = 0.0
;    REPT 256
	;value starts at 0
;    db ((VALUE >> 16) & $FF)
;VALUE = MUL(INCREMENT, INCREMENT);X^2? ;INCREMENT - (1.0 >> 12);MUL(1.0 + (1.25 >> 5), INCREMENT)
;INCREMENT = INCREMENT + (1.5 >> 6)
;    ENDR
	