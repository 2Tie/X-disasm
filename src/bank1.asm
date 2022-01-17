SECTION "bank 1 base", ROMX[$4000], BANK[1]
;most of this bank is dedicated to models?
MODELBANK:
RotateCoordByAngle: ;4000
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
	
MultiplyValues: ;40CB
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

SECTION "1:4100", ROMX[$4100], BANK[1]
SinTable: ;4100-41FF: todo, can i generate these?
	INCBIN "src/sintable.bin"
CosTable: ;4200-42FF: symmetrical table
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

SECTION "1:4800", ROMX[$4800], BANK[1]
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
	
SECTION "1:4900", ROMX[$4900], BANK[1]
ModelHeadersTable: ;4900-49FF: model header pointers
	dw M_PowerCube ;1
	dw M_Tank
	dw M_RadarBase
	dw $4F2F 
	dw $4AC9 
	dw M_Ramp
	dw M_AlienGlider
	dw M_Beacon ;8
	dw M_Bomb
	dw $73B3 
	dw $7C7F
	dw M_PowerCrystal
	dw M_Tree
	dw $555E 
	dw $55D1 ;fired missile
	dw $7764 ;10
	dw $75DB 
	dw M_Mine
	dw $784A 
	dw $5618 
	dw $5CD6 
	dw $72C2 
	dw $5ECB 
	dw $602F ;18
	dw $61E5 
	dw M_Shack
	dw $6263 
	dw $7353 
	dw $638C 
	dw $65AE 
	dw M_Garage
	dw M_CruiseMissile ;20
	dw $720C 
	dw $6913 
	dw $69D6 
	dw $55D1 ;missile?
	dw $6BD1 
	dw $6E95 
	dw $70BC 
	dw $70BC ;28
	dw $784A 
	dw $7C43 
	dw $7C70 
	dw $7C73 
	dw $7C76 
	dw $7C79 
	dw $7C7C 
	dw $5442 ;30
	dw $7C82 
	dw $7C85 
	dw $7C88 
	dw $7C8B 
	dw $7C8E 
	dw $7C91 
	dw $7C94 
	dw $7C97 ;38
	dw $7C9A 
	dw $7CA0 
	dw $7C9D 
	dw $55D1 
	dw $7CA3 
	dw $7CF4 
	dw $7CA9 
	dw $7CAC ;40
	dw $7CAF 
	dw $7CB2 
	dw $7CBB 
	dw $7CBE 
	dw $7CB5 
	dw $7CB8 
	dw $7CC1 
	dw $7CC4 ;48
	dw $7CC7 
	dw $7CE2 
	dw $7CEE 
	dw $7CCA 
	dw $7CCD 
	dw $7CD0 
	dw $7CD3 
	dw $7CD6 ;50
	dw $7CD9 
	dw $7CDC 
	dw $7CDF 
	dw $7CE5 
	dw $7CE8 
	dw $56B4 
	dw $56DC 
	dw $5710 ;58
	dw $5733 
	dw $5759 
	dw $578C 
	dw $57B8 
	dw $57E1 
	dw $5810 
	dw $583F 
	dw $586B ;60
	dw $5897 
	dw $58BA 
	dw $58EA 
	dw $5913 
	dw $5940 
	dw $5969 
	dw $59A0 
	dw $59D0 ;68
	dw $59F9 
	dw $5A1F 
	dw $5A48 
	dw $5A6B 
	dw $5A9B 
	dw $5AC1 
	dw $5AE7 
	dw $5B10 ;70
	dw $5B3D 
	dw $5B69 
	dw $5B99 
	dw $5BC9 
	dw $5BF5 
	dw $5C2C 
	dw $5C59 
	dw $5C7C ;78
	dw $5CA9 
	dw $788C 
	dw $78C7 
	dw $790F 
	dw $7966 
	dw $79D3 
	dw $7CF7 
	dw $7CFA ;80
	
	
SECTION "1:4A00", ROMX[$4A00], BANK[1]
M_PowerCube: ;4A00: power cube model header
	db vThisBank
	db 1 ;precision 1
	dw .verts, .edges, .faces
.verts ;4A08
	db vNONSPECIAL | vMIRRORED
	db $04 ;group vert count
	db $E0, $C0, $20 
	db $20, $00, $20 
	db $E0, $C0, $E0 
	db $20, $00, $E0 ;the verts
	db vEND
.edges ;4A17
	db $0C ;count
	mEdge 0, 1 
	mEdge 1, 2 
	mEdge 2, 3 
	mEdge 3, 0 
	mEdge 0, 4 
	mEdge 1, 5 
	mEdge 2, 6 
	mEdge 3, 7
	mEdge 4, 5 
	mEdge 5, 6 
	mEdge 6, 7 
	mEdge 7, 4 ;the edges (offsets into vertdata)
.faces ;4A30
	db $06 ;number of faces 
	
	db $00, $00, $E1 ;face normal
	db $04 ;number of edges for this face
	db $1C, $18, $14, $10 ;face data 1 (offsets)
	db $08, $09, $0A, $0B ;face data 2 (indexes)
	
	db $1F, $00, $00 
	db $04 
	db $18, $08, $04, $14 
	db $05, $01, $06, $09 
	
	db $00, $00, $1F 
	db $04 
	db $08, $0C, $00, $04 
	db $00, $01, $02, $03 
	
	db $E1, $00, $00 
	db $04 
	db $0C, $1C, $10, $00 
	db $03, $04, $0B, $07 
	
	db $00, $1F, $00 
	db $04 
	db $0C, $08, $18, $1C 
	db $0A, $06, $02, $07 
	
	db $00, $E1, $00 
	db $04 
	db $10, $14, $04, $00 
	db $00, $05, $08, $04

M_Ramp: ;4A79: ramp model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $46, $0, $46
	db $46, $0, $ba
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $dd, $0
	db vEND
.faces
	db 4
	
	db $19, $ee, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $2
	fEdgeIdx $4, $5, $0
	
	db $0, $e6, $ef ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $3
	fEdgeIdx $5, $6, $1
	
	db $ed, $e7, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $4, $1
	fEdgeIdx $6, $7, $2
	
	db $0, $f4, $1d ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $4, $0
	fEdgeIdx $7, $4, $3
.edges
	db 8
	mEdge 0, 2
	mEdge 2, 3
	mEdge 3, 1
	mEdge 1, 0
	mEdge 0, 4
	mEdge 2, 4
	mEdge 3, 4
	mEdge 1, 4
	
M_LaserTurret: ;4AC9: laser turret model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED | 2
	db 3 ;number of vertices in group
	db $d, $0, $16
	db $19, $0, $0
	db $d, $0, $ea
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $3, $ee, $46
	db $5, $ee, $0
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $f1, $46
	db $0, $eb, $46
	db $0, $f3, $0
	db $0, $e9, $0
	db $0, $ee, $f6
	db $0, $dd, $ec
	db vEND
.faces
	db 15
	
	db $0, $e5, $10 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $c, $0
	fEdgeIdx $b, $6, $0
	
	db $e, $e5, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $c, $2
	fEdgeIdx $6, $7, $1
	
	db $e, $e5, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $c, $4
	fEdgeIdx $7, $8, $2
	
	db $0, $e5, $f0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $c, $5
	fEdgeIdx $8, $9, $3
	
	db $f2, $e5, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $c, $3
	fEdgeIdx $9, $a, $4
	
	db $f2, $e5, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $c, $1
	fEdgeIdx $a, $b, $5
	
	db $0, $0, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $7, $b
	fEdgeIdx $f, $e, $d, $c
	
	db $16, $ea, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $b, $d, $8
	fEdgeIdx $c, $11, $18, $10
	
	db $ea, $ea, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $9, $d
	fEdgeIdx $d, $12, $19, $11
	
	db $ea, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $a, $c, $9
	fEdgeIdx $e, $13, $1a, $12
	
	db $16, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $6, $8, $c
	fEdgeIdx $f, $10, $1b, $13
	
	db $15, $eb, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $d, $e
	fEdgeIdx $18, $15, $14
	
	db $eb, $eb, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $9, $e
	fEdgeIdx $19, $16, $15
	
	db $eb, $15, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $c, $e
	fEdgeIdx $1a, $17, $16
	
	db $15, $15, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $8, $e
	fEdgeIdx $1b, $14, $17
.edges
	db 29
	mEdge 1, 0
	mEdge 0, 2
	mEdge 2, 4
	mEdge 4, 5
	mEdge 5, 3
	mEdge 3, 1
	mEdge 0, 12
	mEdge 2, 12
	mEdge 4, 12
	mEdge 5, 12
	mEdge 3, 12
	mEdge 1, 12
	mEdge 6, 11
	mEdge 11, 7
	mEdge 7, 10
	mEdge 10, 6
	mEdge 6, 8
	mEdge 11, 13
	mEdge 7, 9
	mEdge 10, 12
	mEdge 8, 14
	mEdge 13, 14
	mEdge 9, 14
	mEdge 12, 14
	mEdge 8, 13
	mEdge 13, 9
	mEdge 9, 12
	mEdge 12, 8
	mEdge 14, 15
	
M_Beacon: ;4BD5: diamond tower model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $23, $0, $0
	db $5, $f6, $0
	db $f, $d8, $0
	db $a, $c4, $0
	db vNONSPECIAL
	db 9 ;number of vertices in group
	db $0, $0, $23
	db $0, $0, $dd
	db $0, $f6, $5
	db $0, $f6, $fb
	db $0, $d8, $f
	db $0, $d8, $f1
	db $0, $c4, $a
	db $0, $c4, $f6
	db $0, $ba, $0
	db vEND
.faces
	db 16
	
	db $9, $e4, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $8, $a, $2
	fEdgeIdx $0, $7, $8, $4
	
	db $9, $e4, $f7 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $0, $2, $b
	fEdgeIdx $1, $4, $9, $5
	
	db $f7, $e4, $f7 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $9, $b, $3
	fEdgeIdx $2, $5, $a, $6
	
	db $f7, $e4, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $1, $3, $a
	fEdgeIdx $3, $6, $b, $7
	
	db $15, $7, $15 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $a, $c, $4
	fEdgeIdx $8, $f, $10, $c
	
	db $15, $7, $eb ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $4, $d, $b
	fEdgeIdx $c, $11, $d, $9
	
	db $eb, $7, $eb ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $b, $d, $5
	fEdgeIdx $a, $d, $12, $e
	
	db $eb, $7, $15 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $3, $5, $c
	fEdgeIdx $b, $e, $13, $f
	
	db $16, $fb, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $6, $f, $d
	fEdgeIdx $14, $19, $15, $11
	
	db $ea, $fb, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $d, $f, $7
	fEdgeIdx $12, $15, $1a, $16
	
	db $ea, $fb, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $5, $7, $e
	fEdgeIdx $13, $16, $1b, $17
	
	db $16, $fb, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $c, $e, $6
	fEdgeIdx $10, $17, $18, $14
	
	db $12, $ee, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $10, $f
	fEdgeIdx $1c, $1d, $19
	
	db $ee, $ee, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $10, $7
	fEdgeIdx $1d, $1e, $1a
	
	db $ee, $ee, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $10, $e
	fEdgeIdx $1e, $1f, $1b
	
	db $12, $ee, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $10, $6
	fEdgeIdx $1f, $1c, $18
.edges
	db 32
	mEdge 8, 0
	mEdge 0, 9
	mEdge 9, 1
	mEdge 1, 8
	mEdge 0, 2
	mEdge 9, 11
	mEdge 1, 3
	mEdge 8, 10
	mEdge 10, 2
	mEdge 2, 11
	mEdge 11, 3
	mEdge 3, 10
	mEdge 2, 4
	mEdge 11, 13
	mEdge 3, 5
	mEdge 10, 12
	mEdge 12, 4
	mEdge 4, 13
	mEdge 13, 5
	mEdge 5, 12
	mEdge 4, 6
	mEdge 13, 15
	mEdge 5, 7
	mEdge 12, 14
	mEdge 14, 6
	mEdge 6, 15
	mEdge 15, 7
	mEdge 7, 14
	mEdge 6, 16
	mEdge 15, 16
	mEdge 7, 16
	mEdge 14, 16
	
M_Tank: ;4D03: tank model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $ea, $0, $c8
	db $0, $f5, $43
	db $0, $df, $b
	db $16, $0, $c8
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $2d, $f5, $21
	db $24, $f5, $bd
	db $21, $0, $16
	db $16, $e6, $d3
	db $16, $e3, $0
	db $16, $e3, $3f
	db $16, $d4, $c8
	db vEND
.faces
	db 19
	
	db $8, $e4, $b ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $1, $2
	fEdgeIdx $0, $5, $6
	
	db $f8, $e4, $b ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $5, $2
	fEdgeIdx $4, $9, $5
	
	db $0, $e1, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $b, $a
	fEdgeIdx $c, $b, $a
	
	db $d, $e4, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $a
	fEdgeIdx $6, $a, $d
	
	db $f3, $e4, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $2, $5
	fEdgeIdx $c, $9, $e
	
	db $15, $e9, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $a, $6
	fEdgeIdx $d, $7, $1
	
	db $eb, $e9, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $b, $5
	fEdgeIdx $8, $e, $3
	
	db $0, $e6, $ee ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $6, $a
	fEdgeIdx $8, $2, $7, $b
	
	db $0, $1e, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $8, $9
	fEdgeIdx $13, $19, $18
	
	db $a, $1a, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $8, $1
	fEdgeIdx $14, $13, $0
	
	db $f6, $1a, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $9, $5
	fEdgeIdx $18, $17, $4
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $8, $3, $0
	fEdgeIdx $19, $1a, $1c, $1b
	
	db $12, $19, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $6, $3, $8
	fEdgeIdx $1, $15, $1a, $14
	
	db $ee, $19, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $7, $5, $9
	fEdgeIdx $16, $3, $17, $1b
	
	db $0, $16, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $0, $3
	fEdgeIdx $2, $16, $1c, $15
	
	db $4d, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $e, $0
	fEdgeIdx $f, $f
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $d, $f, $0
	fEdgeIdx $10, $10
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $10, $0
	fEdgeIdx $11, $11
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $11, $0
	fEdgeIdx $12, $12
.edges
	db 29
	mEdge 1, 4
	mEdge 4, 6
	mEdge 6, 7
	mEdge 7, 5
	mEdge 5, 1
	mEdge 1, 2
	mEdge 4, 2
	mEdge 6, 10
	mEdge 7, 11
	mEdge 5, 2
	mEdge 2, 10
	mEdge 10, 11
	mEdge 11, 2
	mEdge 4, 10
	mEdge 5, 11
	mEdge 12, 14
	mEdge 13, 15
	mEdge 10, 16
	mEdge 11, 17
	mEdge 1, 8
	mEdge 4, 8
	mEdge 6, 3
	mEdge 7, 0
	mEdge 5, 9
	mEdge 1, 9
	mEdge 8, 9
	mEdge 8, 3
	mEdge 9, 0
	mEdge 3, 0
	
M_RadarBase: ;4E31: radar shop model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED | 2
	db 6 ;number of vertices in group
	db $20, $ea, $d6
	db $25, $f9, $d1
	db $32, $0, $32
	db $32, $0, $ce
	db $25, $dd, $25
	db $25, $dd, $db
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $e7, $c6, $3b
	db $19, $9e, $f7
	db $32, $b2, $19
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $9d, $25
	db vNONSPECIAL | 2
	db 2 ;number of vertices in group
	db $0, $dd, $0
	db $0, $d5, $5
	db vEND
.edges
	db 29
	mEdge 0, 1
	mEdge 0, 2
	mEdge 1, 3
	mEdge 2, 3
	mEdge 4, 6
	mEdge 4, 5
	mEdge 4, 8
	mEdge 6, 7
	mEdge 6, 10
	mEdge 7, 5
	mEdge 7, 11
	mEdge 5, 9
	mEdge 8, 10
	mEdge 8, 9
	mEdge 10, 11
	mEdge 11, 9
	mEdge 18, 19
	mEdge 12, 13
	mEdge 12, 17
	mEdge 12, 20
	mEdge 13, 16
	mEdge 13, 20
	mEdge 14, 15
	mEdge 14, 16
	mEdge 14, 20
	mEdge 15, 17
	mEdge 15, 20
	mEdge 16, 20
	mEdge 17, 20
.faces
	db 13
	
	db $0, $a, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $3, $2, $0
	fEdgeIdx $0, $2, $3, $1
	
	db $0, $8, $e2 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $f, $e, $14
	fEdgeIdx $1a, $16, $18
	
	db $12, $e, $eb ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $e, $10, $14
	fEdgeIdx $18, $17, $1b
	
	db $12, $19, $ff ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $d, $14, $10
	fEdgeIdx $14, $15, $1b
	
	db $0, $1e, $8 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $14, $d
	fEdgeIdx $11, $13, $15
	
	db $ee, $19, $ff ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $11, $14
	fEdgeIdx $13, $12, $1c
	
	db $ee, $e, $eb ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $f, $14, $11
	fEdgeIdx $19, $1a, $1c
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $13, $12, $0
	fEdgeIdx $10, $10
	
	db $e3, $a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $6, $4, $8
	fEdgeIdx $c, $8, $4, $6
	
	db $0, $a, $1d ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $6, $a
	fEdgeIdx $e, $a, $7, $8
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $b, $a, $8
	fEdgeIdx $d, $f, $e, $c
	
	db $0, $a, $e3 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $4, $5, $9
	fEdgeIdx $d, $6, $5, $b
	
	db $1d, $a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $5, $7, $b
	fEdgeIdx $f, $b, $9, $a
	
M_Commander: ;4F2F: general face model header
		db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 28 ;number of vertices in group
	db $11, $24, $2f
	db $ef, $24, $2f
	db $8, $1a, $42
	db $f8, $1a, $42
	db $32, $11, $10
	db $ce, $11, $10
	db $17, $6, $33
	db $e9, $6, $33
	db $3c, $2, $f8
	db $c4, $2, $f8
	db $8, $fd, $2f
	db $f8, $fd, $2f
	db $28, $fd, $2c
	db $d8, $fd, $2c
	db $3c, $f2, $f8
	db $c4, $f2, $f8
	db $19, $f0, $31
	db $e7, $f0, $31
	db $32, $e2, $10
	db $ce, $e2, $10
	db $10, $db, $27
	db $f0, $db, $27
	db $17, $e1, $3e
	db $e9, $e1, $3e
	db $3a, $cd, $12
	db $c6, $cd, $12
	db $17, $ba, $2f
	db $e9, $ba, $2f
	db vLIST
	db 2
	dw $4f93
	dw $4fa8
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $13, $2f, $2a
	db $ed, $2f, $2a
	db $17, $41, $23
	db $e9, $41, $23
	db $13, $2f, $2a
	db $ed, $2f, $2a
	db vEND
	
.verts2
	db vNONSPECIAL
	db 6
	db $14, $33, $29 
	db $EC, $33, $29 
	db $17, $44, $23 
	db $E9, $44, $23 
	db $13, $2D, $2B 
	db $ED, $2D, $2B 
	db vEND 
	
.faces
	db 15
	
	db $0, $c, $1d ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1e, $1f, $1, $0
	fEdgeIdx $0, $1, $2, $3
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1c, $1d, $21, $20
	fEdgeIdx $4, $5, $6, $7
	
	db $1f, $f9, $ff ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1e, $0, $a, $6, $c, $4
	fEdgeIdx $3, $8, $9, $a, $b, $c
	
	db $e1, $f9, $ff ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $1, $1f, $5, $d, $7
	fEdgeIdx $d, $1, $e, $f, $10, $11
	
	db $0, $1c, $e ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $3, $2
	fEdgeIdx $2, $12, $13, $14
	
	db $fa, $fd, $1f ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $a, $10, $c
	fEdgeIdx $9, $15, $16, $a
	
	db $f5, $ff, $1d ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $d, $11, $b
	fEdgeIdx $10, $17, $18, $11
	
	db $1b, $0, $10 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $12, $e, $8, $4
	fEdgeIdx $19, $1a, $1b, $1c
	
	db $e5, $0, $10 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $9, $f, $13
	fEdgeIdx $1d, $1e, $1f, $20
	
	db $0, $4, $1f ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $b, $11, $13, $15, $14, $12, $10
	fEdgeIdx $21, $18, $22, $23, $24, $25, $26, $15
	
	db $13, $f2, $14 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $10, $12, $4
	fEdgeIdx $16, $26, $1c, $b
	
	db $ed, $f2, $14 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $13, $11, $d, $5
	fEdgeIdx $22, $17, $f, $20
	
	db $0, $ef, $1a ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $3, $b, $a
	fEdgeIdx $13, $27, $21, $28
	
	db $0, $e2, $f7 ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $12, $14, $15, $13, $19, $1b, $1a, $18
	fEdgeIdx $25, $24, $23, $29, $2a, $2b, $2c, $2d
	
	db $0, $e1, $0 ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $12, $16, $17, $13, $15, $14
	fEdgeIdx $2e, $2f, $30, $23, $24, $25
.edges
	db 49
	mEdge 30, 31
	mEdge 31, 1
	mEdge 1, 0
	mEdge 0, 30
	mEdge 28, 29
	mEdge 29, 33
	mEdge 33, 32
	mEdge 32, 28
	mEdge 0, 10
	mEdge 10, 6
	mEdge 6, 12
	mEdge 12, 4
	mEdge 4, 30
	mEdge 11, 1
	mEdge 31, 5
	mEdge 5, 13
	mEdge 13, 7
	mEdge 7, 11
	mEdge 1, 3
	mEdge 3, 2
	mEdge 2, 0
	mEdge 10, 16
	mEdge 16, 12
	mEdge 13, 17
	mEdge 17, 11
	mEdge 18, 14
	mEdge 14, 8
	mEdge 8, 4
	mEdge 4, 18
	mEdge 5, 9
	mEdge 9, 15
	mEdge 15, 19
	mEdge 19, 5
	mEdge 10, 11
	mEdge 17, 19
	mEdge 19, 21
	mEdge 21, 20
	mEdge 20, 18
	mEdge 18, 16
	mEdge 3, 11
	mEdge 10, 2
	mEdge 19, 25
	mEdge 25, 27
	mEdge 27, 26
	mEdge 26, 24
	mEdge 24, 18
	mEdge 18, 22
	mEdge 22, 23
	mEdge 23, 19
	
M_Bomb: ;50F1: diamond model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $9, $0, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $d, $0
	db $0, $f3, $0
	db $0, $0, $9
	db $0, $0, $f7
	db vEND
.faces
	db 8
	
	db $14, $f2, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $3, $0
	fEdgeIdx $0, $1, $4
	
	db $14, $f2, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $5
	fEdgeIdx $1, $2, $5
	
	db $ec, $f2, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $3, $1
	fEdgeIdx $2, $3, $6
	
	db $ec, $f2, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $3, $4
	fEdgeIdx $3, $0, $7
	
	db $14, $e, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $4
	fEdgeIdx $9, $8, $4
	
	db $14, $e, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $2, $0
	fEdgeIdx $a, $9, $5
	
	db $ec, $e, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $2, $5
	fEdgeIdx $b, $a, $6
	
	db $ec, $e, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $1
	fEdgeIdx $8, $b, $7
.edges
	db 12
	mEdge 4, 3
	mEdge 0, 3
	mEdge 5, 3
	mEdge 1, 3
	mEdge 4, 0
	mEdge 0, 5
	mEdge 5, 1
	mEdge 1, 4
	mEdge 2, 4
	mEdge 2, 0
	mEdge 2, 5
	mEdge 2, 1
	
M_AlienGlider: ;5177: bird model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $0, $f6, $46
	db $0, $ec, $23
	db $0, $ec, $f6
	db $0, $f6, $d0
	db $0, $0, $28
	db $0, $0, $f6
	db $f, $f6, $1e
	db $f1, $f6, $1e
	db $f, $f6, $ec
	db $f1, $f6, $ec

	db vLIST
	db 16
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frame10
	dw .frame11
	dw .frame12
	dw .frame13
	dw .frame14
	dw .frame15
.frame0
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2d, $f6, $f
	db $d3, $f6, $f
	db $2d, $f6, $f1
	db $d3, $f6, $f1
	db $41, $e8, $e2
	db $bf, $e8, $e2
	db $14, $f6, $ba
	db $ec, $f6, $ba
	db vEND
.frame1
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2b, $fd, $f
	db $d5, $fd, $f
	db $2b, $fd, $f1
	db $d5, $fd, $f1
	db $41, $f3, $e2
	db $bf, $f3, $e2
	db $14, $f3, $bb
	db $ec, $f3, $bb
	db vEND
.frame2
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $29, $4, $f
	db $d7, $4, $f
	db $29, $4, $f1
	db $d7, $4, $f1
	db $41, $ff, $e2
	db $bf, $ff, $e2
	db $14, $f0, $bc
	db $ec, $f0, $bc
	db vEND
.frame3
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $26, $8, $f
	db $da, $8, $f
	db $26, $8, $f1
	db $da, $8, $f1
	db $3e, $a, $e2
	db $c2, $a, $e2
	db $14, $ee, $bc
	db $ec, $ee, $bc
	db vEND
.frame4
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $25, $9, $f
	db $db, $9, $f
	db $25, $9, $f1
	db $db, $9, $f1
	db $3c, $11, $e2
	db $c4, $11, $e2
	db $14, $ed, $bd
	db $ec, $ed, $bd
	db vEND
.frame5
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $26, $8, $f
	db $da, $8, $f
	db $26, $8, $f1
	db $da, $8, $f1
	db $3b, $15, $e2
	db $c5, $15, $e2
	db $14, $ee, $bc
	db $ec, $ee, $bc
	db vEND
.frame6
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $29, $4, $f
	db $d7, $4, $f
	db $29, $4, $f1
	db $d7, $4, $f1
	db $3c, $13, $e2
	db $c4, $13, $e2
	db $14, $f0, $bc
	db $ec, $f0, $bc
	db vEND
.frame7
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2b, $fd, $f
	db $d5, $fd, $f
	db $2b, $fd, $f1
	db $d5, $fd, $f1
	db $3e, $c, $e2
	db $c2, $c, $e2
	db $14, $f3, $bb
	db $ec, $f3, $bb
	db vEND
.frame8
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2d, $f6, $f
	db $d3, $f6, $f
	db $2d, $f6, $f1
	db $d3, $f6, $f1
	db $41, $4, $e2
	db $bf, $4, $e2
	db $14, $f6, $ba
	db $ec, $f6, $ba
	db vEND
	db vEND
.frame9
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2b, $ef, $f
	db $d5, $ef, $f
	db $2b, $ef, $f1
	db $d5, $ef, $f1
	db $41, $f9, $e2
	db $bf, $f9, $e2
	db $14, $f9, $bb
	db $ec, $f9, $bb
	db vEND
	db vEND
.frame10
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $29, $e8, $f
	db $d7, $e8, $f
	db $29, $e8, $f1
	db $d7, $e8, $f1
	db $41, $ed, $e2
	db $bf, $ed, $e2
	db $14, $fc, $bc
	db $ec, $fc, $bc
	db vEND
	db vEND
.frame11
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $26, $e4, $f
	db $da, $e4, $f
	db $26, $e4, $f1
	db $da, $e4, $f1
	db $3e, $e2, $e2
	db $c2, $e2, $e2
	db $14, $fe, $bc
	db $ec, $fe, $bc
	db vEND
	db vEND
.frame12
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $25, $e3, $f
	db $db, $e3, $f
	db $25, $e3, $f1
	db $db, $e3, $f1
	db $3c, $db, $e2
	db $c4, $db, $e2
	db $14, $ff, $bd
	db $ec, $ff, $bd
	db vEND
	db vEND
.frame13
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $26, $e4, $f
	db $da, $e4, $f
	db $26, $e4, $f1
	db $da, $e4, $f1
	db $3b, $d7, $e2
	db $c5, $d7, $e2
	db $14, $fe, $bc
	db $ec, $fe, $bc
	db vEND
	db vEND
.frame14
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $29, $e8, $f
	db $d7, $e8, $f
	db $29, $e8, $f1
	db $d7, $e8, $f1
	db $3c, $d9, $e2
	db $c4, $d9, $e2
	db $14, $fc, $bc
	db $ec, $fc, $bc
	db vEND
	db vEND
.frame15
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2b, $ef, $f
	db $d5, $ef, $f
	db $2b, $ef, $f1
	db $d5, $ef, $f1
	db $3e, $e0, $e2
	db $c2, $e0, $e2
	db $14, $f9, $bb
	db $ec, $f9, $bb
	db vEND
.faces
	db 12
	
	db $ff, $f6, $1 ;normal
	db 6 ;number of edges
	fEdgeGroup $7, $9, $3, $8, $6, $0
	fEdgeIdx $0, $2, $4, $5, $3, $1
	
	db $14, $17, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $6, $4
	fEdgeIdx $0, $a, $11
	
	db $ec, $17, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $7
	fEdgeIdx $11, $b, $1
	
	db $11, $1a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $6, $8, $5
	fEdgeIdx $a, $2, $c, $12
	
	db $ef, $1a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $4, $5, $9
	fEdgeIdx $b, $12, $d, $3
	
	db $d, $1b, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $8, $3
	fEdgeIdx $c, $4, $13
	
	db $f3, $1b, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $5, $3
	fEdgeIdx $d, $13, $5
	
	db $0, $e1, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $c, $a, $6
	fEdgeIdx $18, $16, $14, $2
	
	db $0, $e1, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $b, $d, $9
	fEdgeIdx $15, $17, $19, $3
	
	db $ee, $e6, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $c, $e
	fEdgeIdx $16, $1c, $1a
	
	db $12, $e6, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $f, $d, $b
	fEdgeIdx $1d, $17, $1b
	
	db $0, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $3, $11
	fEdgeIdx $1e, $1f, $20
.edges
	db 33
	mEdge 0, 6
	mEdge 0, 7
	mEdge 6, 8
	mEdge 7, 9
	mEdge 8, 3
	mEdge 9, 3
	mEdge 1, 6
	mEdge 1, 7
	mEdge 2, 8
	mEdge 2, 9
	mEdge 4, 6
	mEdge 4, 7
	mEdge 5, 8
	mEdge 5, 9
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 0, 4
	mEdge 4, 5
	mEdge 5, 3
	mEdge 6, 10
	mEdge 7, 11
	mEdge 10, 12
	mEdge 11, 13
	mEdge 8, 12
	mEdge 9, 13
	mEdge 10, 14
	mEdge 11, 15
	mEdge 12, 14
	mEdge 13, 15
	mEdge 3, 16
	mEdge 3, 17
	mEdge 16, 17
	
M_TunnelEntrance: ;5442: tunnel entrance model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $30, $0, $3c
	db $28, $0, $a
	db $14, $0, $c4
	db $1e, $d8, $34
	db $19, $d8, $14
	db $1e, $f6, $3a
	db $14, $e2, $36
	db vEND
.faces
	db 8
	
	db $0, $fa, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $7, $6
	fEdgeIdx $c, $7, $f, $6
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $9, $8
	fEdgeIdx $f, $13, $10, $12
	
	db $0, $e4, $f2 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $9, $5, $4
	fEdgeIdx $10, $b, $11, $a
	
	db $1d, $f4, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $6, $8, $2
	fEdgeIdx $6, $12, $8, $0
	
	db $e3, $f4, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $1, $3, $9
	fEdgeIdx $7, $1, $9, $13
	
	db $1c, $f4, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $8, $4
	fEdgeIdx $8, $a, $2
	
	db $e4, $f4, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $3, $5
	fEdgeIdx $9, $3, $b
	
	db $0, $fa, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $d, $c
	fEdgeIdx $d, $5, $e, $4
.edges
	db 20
	mEdge 0, 2
	mEdge 1, 3
	mEdge 2, 4
	mEdge 3, 5
	mEdge 10, 12
	mEdge 11, 13
	mEdge 0, 6
	mEdge 1, 7
	mEdge 2, 8
	mEdge 3, 9
	mEdge 4, 8
	mEdge 5, 9
	mEdge 0, 1
	mEdge 10, 11
	mEdge 12, 13
	mEdge 6, 7
	mEdge 8, 9
	mEdge 4, 5
	mEdge 6, 8
	mEdge 7, 9
	
M_Tree: ;54E8: tree model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $f4, $0, $0
	db $f4, $e0, $0
	db $e0, $e0, $e0
	db $20, $e0, $20
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $80, $0
	db vEND
.faces
	db 6
	
	db $0, $f6, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $5, $8
	fEdgeIdx $0, $1, $2
	
	db $1e, $f6, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $5, $6
	fEdgeIdx $1, $3, $4
	
	db $0, $f6, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $6, $7
	fEdgeIdx $4, $5, $6
	
	db $e2, $f6, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $7, $4
	fEdgeIdx $6, $7, $2
	
	db $e2, $f6, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $3, $2
	fEdgeIdx $8, $9, $a, $b
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $7, $6
	fEdgeIdx $0, $7, $5, $3
.edges
	db 12
	mEdge 4, 5
	mEdge 5, 8
	mEdge 4, 8
	mEdge 5, 6
	mEdge 6, 8
	mEdge 6, 7
	mEdge 7, 8
	mEdge 4, 7
	mEdge 0, 1
	mEdge 1, 3
	mEdge 2, 3
	mEdge 0, 2
	
M_UNK1: ;555E: ??? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $2, $3, $14
	db $2, $3, $4
	db $3, $ff, $e
	db $3, $ff, $fe
	db $0, $fd, $8
	db $0, $fd, $f8
	db $fd, $ff, $2
	db $fd, $ff, $f2
	db $fe, $3, $fc
	db $fe, $3, $ec
	db $0, $0, $2
	db $0, $0, $fe
	db vEND
.faces
	db 6
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $0
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $3, $0
	fEdgeIdx $1, $1
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $5, $0
	fEdgeIdx $2, $2
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $7, $0
	fEdgeIdx $3, $3
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $9, $0
	fEdgeIdx $4, $4
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $b, $0
	fEdgeIdx $5, $5
.edges
	db 6
	mEdge 0, 1
	mEdge 2, 3
	mEdge 4, 5
	mEdge 6, 7
	mEdge 8, 9
	mEdge 10, 11
	
M_Ammo: ;55D1: ammo model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $0, $0, $28
	db $0, $0, $f0
	db $0, $ec, $d8
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $12, $a, $d8
	db vEND
.faces
	db 3
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $6, $3, $0
	
	db $f, $1b, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $4
	fEdgeIdx $6, $5, $2
	
	db $f, $e5, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $3
	fEdgeIdx $6, $4, $1
.edges
	db 7
	mEdge 0, 2
	mEdge 0, 3
	mEdge 0, 4
	mEdge 1, 2
	mEdge 1, 3
	mEdge 1, 4
	mEdge 0, 1
	
M_Ant: ;5618: ant? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $0, $0, $0
	db $7, $f8, $f5
	db $fa, $9, $f8
	db $f7, $f7, $ed
	db $8, $6, $4
	db $6, $fa, $3
	db $1, $1, $14
	db $fa, $fa, $ee
	db $f7, $fc, $e
	db $7, $8, $f3
	db $f7, $f7, $5
	db vEND
.faces
	db 10
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $0
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $0
	fEdgeIdx $1, $1
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $3, $0
	fEdgeIdx $2, $2
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $4, $0
	fEdgeIdx $3, $3
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $5, $0
	fEdgeIdx $4, $4
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $6, $0
	fEdgeIdx $5, $5
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $7, $0
	fEdgeIdx $6, $6
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $8, $0
	fEdgeIdx $7, $7
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $9, $0
	fEdgeIdx $8, $8
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $a, $0
	fEdgeIdx $9, $9
.edges
	db 10
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 3
	mEdge 0, 4
	mEdge 0, 5
	mEdge 0, 6
	mEdge 0, 7
	mEdge 0, 8
	mEdge 0, 9
	mEdge 0, 10
	
M_LetterA: ;56B4: letter A model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d8, $0
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $f4, $0, $0
	db $e7, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 3
	mEdge 0, 4
	mEdge 1, 2
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterB: ;56DC: letter B model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $ec, $0
	db $e7, $0, $0
	db $19, $14, $0
	db $e7, $28, $0
	db vEND
.edges
	db 5
	mEdge 0, 1
	mEdge 0, 4
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 5 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4
	fEdgeIdx $0, $1, $2, $3, $4
	
M_LetterC: ;5710: letter C model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $19, $d8, $0
	db $e7, $0, $0
	db $19, $28, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 1, 2
.faces
	db 1
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_LetterD: ;5733: letter D model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $0, $0
	db $e7, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 0, 2
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterE: ;5759: letter E model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $19, $d8, $0
	db $e7, $d8, $0
	db $e7, $0, $0
	db $0, $0, $0
	db $e7, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 4
	mEdge 2, 3
	mEdge 4, 5
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_LetterF: ;578C: letter F model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $e7, $0, $0
	db $0, $0, $0
	db $e7, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 0, 4
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterG:;57B8: letter G model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $c, $d8, $0
	db $e7, $0, $0
	db $19, $28, $0
	db $19, $0, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterH: ;57E1: letter H model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $0, $0
	db $e7, $28, $0
	db $19, $d8, $0
	db $19, $0, $0
	db $19, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 2
	mEdge 1, 4
	mEdge 3, 5
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterI: ;5810: letter I model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $e7, $d8, $0
	db $0, $d8, $0
	db $19, $d8, $0
	db $e7, $28, $0
	db $0, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 2
	mEdge 1, 4
	mEdge 3, 5
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2

M_LetterJ: ;not in model list
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $0, $d8, $0
	db $19, $d8, $0
	db $0, $28, $0
	db $e7, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 2
	mEdge 1, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterK: ;586B: letter K model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $28, $0
	db $e7, $0, $0
	db $19, $d8, $0
	db $19, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 2, 3
	mEdge 2, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterL: ;5897: letter L model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 1, 2
.faces
	db 1
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_LetterM: ;58BA: letter M model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $28, $0
	db $e7, $d8, $0
	db $0, $0, $0
	db $19, $d8, $0
	db $19, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_LetterN: ;58EA: letter N model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $28, $0
	db $e7, $d8, $0
	db $19, $28, $0
	db $19, $d8, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterO: ;5913: letter O model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $0, $0
	db $0, $28, $0
	db $19, $0, $0
	db $0, $d8, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_LetterP: ;5940: letter P model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $28, $0
	db $19, $ec, $0
	db $e7, $0, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 0, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterQ: ;5969: letter Q model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $e7, $0, $0
	db $0, $28, $0
	db $19, $0, $0
	db $0, $d8, $0
	db $0, $0, $0
	db $19, $28, $0
	db vEND
.edges
	db 5
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 0
	mEdge 4, 5
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 5 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4
	fEdgeIdx $0, $1, $2, $3, $4
	
M_LetterR: ;59A0: letter R model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $28, $0
	db $19, $ec, $0
	db $e7, $0, $0
	db $19, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 0, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_LetterS: ;59D0: letter S model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $c, $d8, $0
	db $e7, $ec, $0
	db $19, $14, $0
	db $e7, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterT: ;59F9: letter T model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $0, $d8, $0
	db $0, $28, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 2, 3
.faces
	db 1
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_ModelU: ;5A1F: letter U model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $28, $0
	db $19, $28, $0
	db $19, $d8, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_LetterV: ;5A48: letter V model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $e7, $d8, $0
	db $0, $28, $0
	db $19, $d8, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 1, 2
.faces
	db 1
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_LetterW: ;5A6B: letter W model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $f4, $28, $0
	db $0, $0, $0
	db $c, $28, $0
	db $19, $d8, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_LetterX: ;5A9B: letter X model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $28, $0
	db $e7, $28, $0
	db $19, $d8, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 2, 3
.faces
	db 1
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_LetterY: ;5AC1: letter Y model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $0, $0, $0
	db $19, $d8, $0
	db $e7, $28, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 2, 3
.faces
	db 1
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_LetterZ: ;5AE7: letter Z model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $e7, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_Number0: ;5B10: number 0 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $19, $28, $0
	db $e7, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Number1: ;5B3D: number 1 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $f0, $e6, $0
	db $0, $d8, $0
	db $f0, $28, $0
	db $10, $28, $0
	db $0, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 4
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_Number2: ;5B69: number 2 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $19, $ec, $0
	db $e7, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Number3: ;5B99: number 3 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $ec, $0
	db $0, $0, $0
	db $19, $14, $0
	db $e7, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Number4: ;5BC9: number 4 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $e7, $d8, $0
	db $e7, $14, $0
	db $19, $14, $0
	db $c, $ec, $0
	db $c, $28, $0
	db vEND
.edges
	db 3
	mEdge 0, 1
	mEdge 1, 2
	mEdge 3, 4
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
M_Number5: ;5BF5: number 5 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $19, $d8, $0
	db $e7, $d8, $0
	db $e7, $0, $0
	db $19, $0, $0
	db $19, $28, $0
	db $e7, $28, $0
	db vEND
.edges
	db 5
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 5 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4
	fEdgeIdx $0, $1, $2, $3, $4
	
M_Number6: ;5C2C: number 6 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $c, $d8, $0
	db $e7, $0, $0
	db $e7, $28, $0
	db $19, $14, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 1, 3
	mEdge 2, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Number7: ;5C59: number 7 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $f4, $28, $0
	db vEND
.edges
	db 2
	mEdge 0, 1
	mEdge 1, 2
.faces
	db 1
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $1
	
M_Number8: ;5C7C: number 8 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $e7, $d8, $0
	db $19, $d8, $0
	db $e7, $28, $0
	db $19, $28, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Number9: ;5CA9: number 9 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $19, $d8, $0
	db $19, $0, $0
	db $f4, $28, $0
	db $e7, $ec, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 1, 3
	mEdge 0, 3
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
M_Pendulum: ;5CD6: pendulum model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $1e, $0, $f6
	db $32, $0, $0
	db $1e, $0, $a
	db $14, $ba, $0
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ba, $0

	db vLIST
	db 16
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frame10
	dw .frame11
	dw .frame12
	dw .frame13
	dw .frame14
	dw .frame15
.frame0
.frame15
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ce, $22
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $e5, $21
	db $14, $d3, $2b
	db $a, $c2, $35
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $db, $38
	db vEND
.frame1
.frame14
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d2, $20
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $e8, $1c
	db $14, $d8, $28
	db $a, $c8, $34
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e1, $34
	db vEND
.frame2
.frame13
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $da, $18
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $ee, $e
	db $14, $e2, $1e
	db $a, $d6, $2e
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ee, $27
	db vEND
.frame3
.frame12
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e1, $9
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $f0, $f9
	db $14, $eb, $b
	db $a, $e7, $1f
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $fa, $f
	db vEND
.frame4
.frame11
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e1, $f7
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $e7, $e1
	db $14, $eb, $f5
	db $a, $f0, $7
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $fa, $f1
	db vEND
.frame5
.frame10
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $da, $e8
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $d6, $d2
	db $14, $e2, $e2
	db $a, $ee, $f2
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ee, $d9
	db vEND
.frame6
.frame9
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d2, $e0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $c8, $cc
	db $14, $d8, $d8
	db $a, $e8, $e4
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e1, $cc
	db vEND
.frame7
.frame8
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ce, $de
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $c2, $cb
	db $14, $d3, $d5
	db $a, $e5, $df
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $db, $c8
	db vEND
.faces
	db 20
	
	db $e, $fa, $e4 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $6
	fEdgeIdx $0, $4, $3
	
	db $e, $fa, $1c ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $6
	fEdgeIdx $1, $5, $4
	
	db $e1, $4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $0, $6
	fEdgeIdx $2, $3, $5
	
	db $f2, $fa, $e4 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $1, $7
	fEdgeIdx $6, $9, $a
	
	db $f2, $fa, $1c ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $3, $7
	fEdgeIdx $7, $a, $b
	
	db $1f, $4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $5, $7
	fEdgeIdx $8, $b, $9
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $7, $0
	fEdgeIdx $c, $c
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $9, $0
	fEdgeIdx $d, $d
	
	db $e, $f9, $e5 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $9, $a
	fEdgeIdx $10, $e, $1a
	
	db $0, $ff, $e1 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $9, $b
	fEdgeIdx $e, $f, $1b
	
	db $f2, $f9, $e5 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $9, $d
	fEdgeIdx $f, $11, $1c
	
	db $f2, $ec, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $9, $f
	fEdgeIdx $11, $13, $1d
	
	db $0, $e6, $ef ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $9, $e
	fEdgeIdx $13, $12, $1e
	
	db $e, $ec, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $9, $c
	fEdgeIdx $12, $10, $1f
	
	db $12, $13, $10 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $10, $c
	fEdgeIdx $14, $16, $1a
	
	db $0, $1d, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $10, $a
	fEdgeIdx $15, $14, $1b
	
	db $ee, $13, $10 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $10, $b
	fEdgeIdx $17, $15, $1c
	
	db $ee, $4, $19 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $10, $d
	fEdgeIdx $19, $17, $1d
	
	db $0, $fd, $1f ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $10, $f
	fEdgeIdx $18, $19, $1e
	
	db $12, $4, $19 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $10, $e
	fEdgeIdx $16, $18, $1f
.edges
	db 32
	mEdge 0, 2
	mEdge 2, 4
	mEdge 4, 0
	mEdge 0, 6
	mEdge 2, 6
	mEdge 4, 6
	mEdge 1, 3
	mEdge 3, 5
	mEdge 5, 1
	mEdge 1, 7
	mEdge 3, 7
	mEdge 5, 7
	mEdge 6, 7
	mEdge 8, 9
	mEdge 9, 10
	mEdge 9, 11
	mEdge 9, 12
	mEdge 9, 13
	mEdge 9, 14
	mEdge 9, 15
	mEdge 10, 16
	mEdge 11, 16
	mEdge 12, 16
	mEdge 13, 16
	mEdge 14, 16
	mEdge 15, 16
	mEdge 12, 10
	mEdge 10, 11
	mEdge 11, 13
	mEdge 13, 15
	mEdge 15, 14
	mEdge 14, 12
	
M_BouncingCone: ;5ECB: bouncing cone model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts

	db vLIST
	db 16
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frame10
	dw .frame11
	dw .frame12
	dw .frame13
	dw .frame14
	dw .frame15
.frame0
.frame15
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ec, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $31, $0, $e
	db $46, $0, $0
	db $31, $0, $f2
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $14
	db $0, $0, $ec
	db vEND
.frame1
.frame14
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ea, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $2f, $0, $f
	db $43, $0, $0
	db $2f, $0, $f1
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $16
	db $0, $0, $ea
	db vEND
.frame2
.frame13
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e3, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $2a, $0, $14
	db $3c, $0, $0
	db $2a, $0, $ec
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $1d
	db $0, $0, $e3
	db vEND
.frame3
.frame12
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d9, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $23, $0, $1b
	db $32, $0, $0
	db $23, $0, $e5
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $27
	db $0, $0, $d9
	db vEND
.frame4
.frame11
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d9, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $1b, $0, $23
	db $27, $0, $0
	db $1b, $0, $dd
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $32
	db $0, $0, $ce
	db vEND
.frame5
.frame10
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e3, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $14, $0, $2a
	db $1d, $0, $0
	db $14, $0, $d6
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $3c
	db $0, $0, $c4
	db vEND
.frame6
.frame9
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ea, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $f, $0, $2f
	db $16, $0, $0
	db $f, $0, $d1
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $43
	db $0, $0, $bd
	db vEND
.frame7
.frame8
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ec, $0
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $e, $0, $31
	db $14, $0, $0
	db $e, $0, $cf
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $46
	db $0, $0, $ba
	db vEND
.faces
	db 8
	
	db $2, $ea, $16 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $1, $7
	fEdgeIdx $9, $0, $8
	
	db $8, $e4, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $1
	fEdgeIdx $a, $1, $9
	
	db $8, $e4, $f4 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $5, $3
	fEdgeIdx $b, $2, $a
	
	db $2, $ea, $ea ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $8, $5
	fEdgeIdx $c, $3, $b
	
	db $fe, $ea, $ea ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $6, $8
	fEdgeIdx $d, $4, $c
	
	db $f8, $e4, $f4 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $6
	fEdgeIdx $e, $5, $d
	
	db $f8, $e4, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $4
	fEdgeIdx $f, $6, $e
	
	db $fe, $ea, $16 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $7, $2
	fEdgeIdx $8, $7, $f
.edges
	db 16
	mEdge 7, 1
	mEdge 1, 3
	mEdge 3, 5
	mEdge 5, 8
	mEdge 8, 6
	mEdge 6, 4
	mEdge 4, 2
	mEdge 2, 7
	mEdge 0, 7
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 5
	mEdge 0, 8
	mEdge 0, 6
	mEdge 0, 4
	mEdge 0, 2
	
M_NuclearSilo: ;602F: nuclear silo model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $11, $b5, $ef
	db $11, $b5, $11
	db vNONSPECIAL | vMIRRORED | 2
	db 4 ;number of vertices in group
	db $3e, $0, $c2
	db $c2, $0, $3e
	db $ce, $e7, $ce
	db $ce, $e7, $32
	db vNONSPECIAL | 2
	db 4 ;number of vertices in group
	db $c9, $f1, $1e
	db $c9, $f1, $e2
	db $c2, $0, $25
	db $c2, $0, $db
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $83, $0
	db $0, $e7, $0
	db vEND
.edges
	db 28
	mEdge 12, 13
	mEdge 12, 14
	mEdge 13, 15
	mEdge 14, 15
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 16
	mEdge 0, 17
	mEdge 1, 3
	mEdge 1, 16
	mEdge 1, 17
	mEdge 2, 3
	mEdge 2, 16
	mEdge 2, 17
	mEdge 3, 16
	mEdge 3, 17
	mEdge 4, 5
	mEdge 4, 7
	mEdge 4, 9
	mEdge 5, 6
	mEdge 5, 8
	mEdge 6, 7
	mEdge 6, 10
	mEdge 7, 11
	mEdge 8, 10
	mEdge 8, 9
	mEdge 10, 11
	mEdge 11, 9
.faces
	db 14
	
	db $1c, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $6, $5, $8
	fEdgeIdx $18, $16, $13, $14
	
	db $0, $e, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $6, $a
	fEdgeIdx $1a, $17, $15, $16
	
	db $0, $e, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $5, $4, $9
	fEdgeIdx $19, $14, $10, $12
	
	db $e4, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $4, $7, $b
	fEdgeIdx $1b, $12, $11, $17
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $b, $a, $8
	fEdgeIdx $19, $1b, $1a, $18
	
	db $0, $a, $e3 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $3, $10
	fEdgeIdx $c, $b, $e
	
	db $1d, $a, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $10, $3
	fEdgeIdx $8, $9, $e
	
	db $0, $f6, $e3 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $11
	fEdgeIdx $f, $b, $d
	
	db $1d, $f6, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $3, $11
	fEdgeIdx $a, $8, $f
	
	db $0, $f6, $1d ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $1, $11
	fEdgeIdx $7, $4, $a
	
	db $e3, $f6, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $11, $2
	fEdgeIdx $5, $7, $d
	
	db $e3, $a, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $10
	fEdgeIdx $6, $5, $c
	
	db $0, $a, $1d ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $10, $1
	fEdgeIdx $4, $6, $9
	
	db $1c, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $e, $f, $d
	fEdgeIdx $0, $1, $3, $2
	
M_Shack: ;6136: shack model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 9 ;number of vertices in group
	db $28, $0, $10
	db $28, $0, $f6
	db $32, $ce, $1a
	db $36, $ba, $e8
	db $14, $0, $10
	db $1c, $d8, $18
	db $14, $0, $f6
	db $1e, $ce, $ec
	db $19, $c4, $1
	db vEND
.faces
	db 8
	
	db $0, $6, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $5, $4
	fEdgeIdx $0, $5, $8, $4
	
	db $0, $e3, $b ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $7, $6
	fEdgeIdx $8, $9, $a, $b
	
	db $0, $6, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $2, $6, $7
	fEdgeIdx $2, $7, $a, $6
	
	db $e1, $6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $3, $7, $5
	fEdgeIdx $1, $6, $9, $5
	
	db $1f, $6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $0, $4, $6
	fEdgeIdx $3, $4, $b, $7
	
	db $0, $6, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $9, $b, $a
	fEdgeIdx $c, $d, $e, $f
	
	db $0, $6, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $c, $e, $f
	fEdgeIdx $10, $11, $12, $13
	
	db $3c, $d3, $d3 ;normal
	db 2 ;number of edges
	fEdgeGroup $10, $11, $7
	fEdgeIdx $14, $14
.edges
	db 21
	mEdge 0, 1
	mEdge 1, 3
	mEdge 3, 2
	mEdge 2, 0
	mEdge 0, 4
	mEdge 1, 5
	mEdge 3, 7
	mEdge 2, 6
	mEdge 4, 5
	mEdge 5, 7
	mEdge 7, 6
	mEdge 6, 4
	mEdge 8, 9
	mEdge 9, 11
	mEdge 11, 10
	mEdge 10, 8
	mEdge 13, 12
	mEdge 12, 14
	mEdge 14, 15
	mEdge 15, 13
	mEdge 16, 17
	
M_TallGrass: ;61E5: tall grass model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $0, $0, $0
	db $18, $d2, $f0
	db $fc, $da, $e2
	db $e2, $e2, $fa
	db $ee, $d6, $18
	db $14, $ca, $14
	db $14, $e6, $fa
	db $4, $ec, $ec
	db $ea, $f0, $2
	db $fc, $e8, $14
	db $10, $d8, $8
	db vEND
.faces
	db 5
	
	db $f4, $f1, $19 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $6, $0
	fEdgeIdx $1, $2, $0
	
	db $e, $ee, $15 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $7, $0
	fEdgeIdx $4, $5, $3
	
	db $10, $ec, $12 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $8, $3
	fEdgeIdx $8, $7, $6
	
	db $12, $ee, $ee ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $9, $4
	fEdgeIdx $b, $a, $9
	
	db $e4, $f4, $fb ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $a, $5
	fEdgeIdx $e, $d, $c
.edges
	db 15
	mEdge 0, 1
	mEdge 1, 6
	mEdge 6, 0
	mEdge 0, 2
	mEdge 2, 7
	mEdge 7, 0
	mEdge 0, 3
	mEdge 3, 8
	mEdge 8, 0
	mEdge 0, 4
	mEdge 4, 9
	mEdge 9, 0
	mEdge 0, 5
	mEdge 5, 10
	mEdge 10, 0
	
M_UNK2: ;6263: big wall? model header
	db vThisBank
	db 2 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $0, $25
	db $0, $0, $a
	db $0, $d8, $18
	db $0, $d8, $fe
	db $0, $b0, $25
	db $0, $b0, $a
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $5d, $0, $0
	db $5d, $0, $e6
	db $5d, $d8, $f3
	db $5d, $d8, $d8
	db $5d, $b0, $0
	db $5d, $b0, $e6
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $a3, $a
	db vEND
.faces
	db 15
	
	db $f5, $f7, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $7, $b, $2
	fEdgeIdx $0, $6, $c, $7
	
	db $b, $f7, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $0, $2, $a
	fEdgeIdx $1, $7, $d, $8
	
	db $1f, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $6, $a, $c
	fEdgeIdx $2, $8, $e, $9
	
	db $f5, $9, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $8, $c, $3
	fEdgeIdx $3, $9, $f, $a
	
	db $b, $9, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $1, $3, $d
	fEdgeIdx $4, $a, $10, $b
	
	db $e1, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $9, $d, $b
	fEdgeIdx $5, $b, $11, $6
	
	db $f5, $9, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $b, $f, $4
	fEdgeIdx $c, $12, $18, $13
	
	db $b, $9, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $2, $4, $e
	fEdgeIdx $d, $13, $19, $14
	
	db $1f, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $a, $e, $10
	fEdgeIdx $e, $14, $1a, $15
	
	db $f5, $f7, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $c, $10, $5
	fEdgeIdx $f, $15, $1b, $16
	
	db $b, $f7, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $3, $5, $11
	fEdgeIdx $10, $16, $1c, $17
	
	db $e1, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $d, $11, $f
	fEdgeIdx $11, $17, $1d, $12
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $f, $11, $5, $4
	fEdgeIdx $1d, $1c, $1f, $18
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $10, $e
	fEdgeIdx $1f, $1b, $1a, $19
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $12, $0
	fEdgeIdx $1e, $1e
.edges
	db 32
	mEdge 7, 0
	mEdge 0, 6
	mEdge 6, 8
	mEdge 8, 1
	mEdge 1, 9
	mEdge 9, 7
	mEdge 7, 11
	mEdge 0, 2
	mEdge 6, 10
	mEdge 8, 12
	mEdge 1, 3
	mEdge 9, 13
	mEdge 11, 2
	mEdge 2, 10
	mEdge 10, 12
	mEdge 12, 3
	mEdge 3, 13
	mEdge 13, 11
	mEdge 11, 15
	mEdge 2, 4
	mEdge 10, 14
	mEdge 12, 16
	mEdge 3, 5
	mEdge 13, 17
	mEdge 15, 4
	mEdge 4, 14
	mEdge 14, 16
	mEdge 16, 5
	mEdge 5, 17
	mEdge 17, 15
	mEdge 5, 18
	mEdge 4, 5
	
M_Creature1: ;638C: creature1 model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $0, $46
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $6, $0, $1e
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $ec, $28
	db $a, $ec, $28

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f7, $0
	db $0, $dd, $f6
	db $1e, $ed, $e7
	db $e2, $ed, $e7
	db $0, $ed, $d9
	db $27, $0, $fa
	db $d9, $0, $fa
	db $1e, $0, $d4
	db $e2, $0, $d4
	db $a, $d1, $c4
	db vEND
.frame1
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f8, $0
	db $0, $de, $f6
	db $1e, $ef, $e7
	db $e2, $ef, $e7
	db $0, $f0, $d9
	db $2c, $0, $fa
	db $d4, $0, $fa
	db $28, $0, $d4
	db $d8, $0, $d4
	db $7, $d3, $c3
	db vEND
.frame2
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f7, $0
	db $0, $de, $f6
	db $1e, $ee, $e7
	db $e2, $ee, $e7
	db $0, $ee, $d9
	db $29, $0, $fa
	db $d7, $0, $fa
	db $2d, $0, $d4
	db $d3, $0, $d4
	db $0, $d1, $c4
	db vEND
.frame3
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f5, $0
	db $0, $db, $f7
	db $1e, $ea, $e7
	db $e2, $ea, $e7
	db $0, $e9, $d9
	db $1f, $0, $fa
	db $e1, $0, $fa
	db $28, $0, $d4
	db $d8, $0, $d4
	db $f9, $cc, $c6
	db vEND
.frame4
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f7, $0
	db $0, $dd, $f6
	db $1e, $ed, $e7
	db $e2, $ed, $e7
	db $0, $ee, $d9
	db $14, $0, $fa
	db $ec, $0, $fa
	db $1d, $0, $d4
	db $e3, $0, $d4
	db $f6, $d2, $c4
	db vEND
.frame5
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f8, $0
	db $0, $df, $f6
	db $1e, $ef, $e7
	db $e2, $ef, $e7
	db $0, $f0, $d9
	db $f, $0, $fa
	db $f1, $0, $fa
	db $13, $0, $d4
	db $ed, $0, $d4
	db $f9, $d4, $c3
	db vEND
.frame6
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f8, $0
	db $0, $de, $f6
	db $1e, $ee, $e7
	db $e2, $ee, $e7
	db $0, $ef, $d9
	db $12, $0, $fa
	db $ee, $0, $fa
	db $f, $0, $d4
	db $f1, $0, $d4
	db $0, $d1, $c4
	db vEND
.frame7
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $f6, $ec, $28
	db $0, $f5, $0
	db $0, $db, $f7
	db $1e, $ea, $e7
	db $e2, $ea, $e7
	db $0, $ea, $d9
	db $1c, $0, $fa
	db $e4, $0, $fa
	db $13, $0, $d4
	db $ed, $0, $d4
	db $7, $cc, $c5
	db vEND
.faces
	db 17
	
	db $0, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $1
	fEdgeIdx $2, $1, $0
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $3, $0
	fEdgeIdx $3, $3
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $d, $0
	fEdgeIdx $5, $5
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $8, $0
	fEdgeIdx $4, $4
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $e, $c, $0
	fEdgeIdx $7, $7
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $9, $0
	fEdgeIdx $6, $6
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $f, $0
	fEdgeIdx $8, $8
	
	db $0, $1e, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $5, $4
	fEdgeIdx $12, $9, $e
	
	db $d, $1c, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $4, $8
	fEdgeIdx $e, $a, $f
	
	db $3, $1e, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $8, $a
	fEdgeIdx $f, $b, $10
	
	db $fd, $1e, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $a, $9
	fEdgeIdx $10, $c, $11
	
	db $f3, $1c, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $9, $5
	fEdgeIdx $11, $d, $12
	
	db $0, $e2, $9 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $4, $5
	fEdgeIdx $13, $9, $17
	
	db $10, $e6, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $8, $4
	fEdgeIdx $14, $a, $13
	
	db $7, $e5, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $a, $8
	fEdgeIdx $15, $b, $14
	
	db $f9, $e5, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $9, $a
	fEdgeIdx $16, $c, $15
	
	db $f0, $e6, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $5, $9
	fEdgeIdx $17, $d, $16
.edges
	db 24
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 0
	mEdge 0, 3
	mEdge 8, 11
	mEdge 11, 13
	mEdge 9, 12
	mEdge 12, 14
	mEdge 10, 15
	mEdge 5, 4
	mEdge 4, 8
	mEdge 8, 10
	mEdge 10, 9
	mEdge 9, 5
	mEdge 4, 6
	mEdge 8, 6
	mEdge 10, 6
	mEdge 9, 6
	mEdge 5, 6
	mEdge 4, 7
	mEdge 8, 7
	mEdge 10, 7
	mEdge 9, 7
	mEdge 5, 7
	
M_UNK3: ;65AE: ball? coin? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $ec, $0
	db $14, $f6, $0
	db $14, $a, $0
	db $0, $14, $0
	db $ec, $a, $0
	db $ec, $f6, $0
	db vEND
.faces
	db 1
	
	db $0, $e7, $0 ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5
	fEdgeIdx $0, $1, $2, $3, $4, $5
.edges
	db 6
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 0
	
M_Garage: ;65E9: garage model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $1e, $0, $28
	db $1e, $0, $d8
	db $23, $e2, $2d
	db $23, $e2, $d3
	db $19, $c4, $23
	db $19, $c4, $dd

	db vLIST
	db 16
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frame10
	dw .frame11
	dw .frame12
	dw .frame13
	dw .frame14
	dw .frame15
.frame0
.frame15
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1e, $0, $28
	db $5, $0, $28
	db $5, $0, $28
	db $e2, $0, $28
	db $23, $e2, $2d
	db $fb, $e2, $2d
	db $fb, $e2, $2d
	db $dd, $e2, $2d
	db $19, $c4, $23
	db $5, $c4, $23
	db $5, $c4, $23
	db $e7, $c4, $23
	db vEND
.frame1
.frame14
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1f, $0, $28
	db $6, $0, $28
	db $3, $0, $28
	db $e1, $0, $28
	db $24, $e2, $2d
	db $fd, $e2, $2d
	db $fa, $e2, $2d
	db $dc, $e2, $2d
	db $1a, $c4, $23
	db $6, $c4, $23
	db $3, $c4, $23
	db $e6, $c4, $23
	db vEND
.frame2
.frame13
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $24, $0, $28
	db $b, $0, $28
	db $ff, $0, $28
	db $dc, $0, $28
	db $29, $e2, $2d
	db $1, $e2, $2d
	db $f5, $e2, $2d
	db $d7, $e2, $2d
	db $1f, $c4, $23
	db $b, $c4, $23
	db $ff, $c4, $23
	db $e1, $c4, $23
	db vEND
.frame3
.frame12
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $2b, $0, $28
	db $12, $0, $28
	db $f8, $0, $28
	db $d5, $0, $28
	db $30, $e2, $2d
	db $8, $e2, $2d
	db $ee, $e2, $2d
	db $d0, $e2, $2d
	db $26, $c4, $23
	db $12, $c4, $23
	db $f8, $c4, $23
	db $da, $c4, $23
	db vEND
.frame4
.frame11
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $33, $0, $28
	db $1a, $0, $28
	db $f0, $0, $28
	db $cd, $0, $28
	db $38, $e2, $2d
	db $10, $e2, $2d
	db $e6, $e2, $2d
	db $c8, $e2, $2d
	db $2e, $c4, $23
	db $1a, $c4, $23
	db $f0, $c4, $23
	db $d2, $c4, $23
	db vEND
.frame5
.frame10
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $3a, $0, $28
	db $21, $0, $28
	db $e9, $0, $28
	db $c6, $0, $28
	db $3f, $e2, $2d
	db $17, $e2, $2d
	db $df, $e2, $2d
	db $c1, $e2, $2d
	db $35, $c4, $23
	db $21, $c4, $23
	db $e9, $c4, $23
	db $cb, $c4, $23
	db vEND
.frame6
.frame9
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $3f, $0, $28
	db $26, $0, $28
	db $e4, $0, $28
	db $c1, $0, $28
	db $44, $e2, $2d
	db $1c, $e2, $2d
	db $da, $e2, $2d
	db $bc, $e2, $2d
	db $3a, $c4, $23
	db $26, $c4, $23
	db $e4, $c4, $23
	db $c6, $c4, $23
	db vEND
.frame7
.frame8
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $41, $0, $28
	db $28, $0, $28
	db $e2, $0, $28
	db $bf, $0, $28
	db $46, $e2, $2d
	db $1e, $e2, $2d
	db $d8, $e2, $2d
	db $ba, $e2, $2d
	db $3c, $c4, $23
	db $28, $c4, $23
	db $e2, $c4, $23
	db $c4, $c4, $23
	db vEND
.faces
	db 11
	
	db $1f, $5, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $0, $4, $6
	fEdgeIdx $1a, $1, $1b, $3
	
	db $0, $5, $e1 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $2, $6, $7
	fEdgeIdx $0, $3, $5, $4
	
	db $e1, $5, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $3, $7, $5
	fEdgeIdx $1f, $4, $1e, $2
	
	db $1e, $f6, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $4, $8, $a
	fEdgeIdx $1b, $6, $1c, $8
	
	db $0, $f6, $e2 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $6, $a, $b
	fEdgeIdx $5, $8, $b, $9
	
	db $e2, $f6, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $7, $b, $9
	fEdgeIdx $1e, $9, $1d, $7
	
	db $0, $e1, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $9, $b, $a
	fEdgeIdx $a, $1d, $b, $1c
	
	db $0, $5, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $d, $11, $10
	fEdgeIdx $c, $e, $f, $d
	
	db $0, $f6, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $11, $15, $14
	fEdgeIdx $f, $11, $12, $10
	
	db $0, $5, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $f, $13, $12
	fEdgeIdx $13, $15, $16, $14
	
	db $0, $f6, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $12, $13, $17, $16
	fEdgeIdx $16, $18, $19, $17
.edges
	db 32
	mEdge 2, 3
	mEdge 0, 4
	mEdge 1, 5
	mEdge 2, 6
	mEdge 3, 7
	mEdge 6, 7
	mEdge 4, 8
	mEdge 5, 9
	mEdge 6, 10
	mEdge 7, 11
	mEdge 8, 9
	mEdge 10, 11
	mEdge 12, 13
	mEdge 12, 16
	mEdge 13, 17
	mEdge 16, 17
	mEdge 16, 20
	mEdge 17, 21
	mEdge 20, 21
	mEdge 14, 15
	mEdge 14, 18
	mEdge 15, 19
	mEdge 18, 19
	mEdge 18, 22
	mEdge 19, 23
	mEdge 22, 23
	mEdge 0, 2
	mEdge 4, 6
	mEdge 8, 10
	mEdge 9, 11
	mEdge 5, 7
	mEdge 1, 3
	
M_CruiseMissile: ;6825: rocket model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e2, $46
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $a, $e2, $ce
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $ec, $ce
	db $0, $d8, $ce
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $6, $e2, $f6
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $e8, $f6
	db $0, $dc, $f6
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1e, $e2, $ba
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $ba
	db $0, $c4, $ba
	db vEND
.faces
	db 8
	
	db $16, $ea, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $1
	fEdgeIdx $3, $4, $0
	
	db $ea, $ea, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $4
	fEdgeIdx $1, $5, $3
	
	db $ea, $16, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $2
	fEdgeIdx $2, $6, $1
	
	db $16, $16, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $1, $3
	fEdgeIdx $0, $7, $2
	
	db $0, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $1, $9
	fEdgeIdx $10, $9, $8
	
	db $0, $1f, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $2, $a
	fEdgeIdx $11, $b, $a
	
	db $1f, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $3, $b
	fEdgeIdx $12, $d, $c
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $4, $c
	fEdgeIdx $13, $f, $e
.edges
	db 20
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 3
	mEdge 0, 4
	mEdge 1, 4
	mEdge 4, 2
	mEdge 2, 3
	mEdge 3, 1
	mEdge 5, 9
	mEdge 9, 1
	mEdge 6, 10
	mEdge 10, 2
	mEdge 7, 11
	mEdge 11, 3
	mEdge 8, 12
	mEdge 12, 4
	mEdge 1, 5
	mEdge 2, 6
	mEdge 3, 7
	mEdge 4, 8
.verts2
	db $10 
	db 1 
	db $00, $00, $09 
	db $18 
	db 1 
	db $08, $00, $FB 
	db $10 
	db 1 
	db $00, $E9, $07 
	db $18 
	db 1 
	db $06, $E9, $FD 
	db $10 
	db 2 
	db $0E, $EC, $1A 
	db $1D, $EC, $00 
	db $18 
	db 1 
	db $0E, $EC, $E6 
	db $10 
	db 4 
	db $E3, $EC, $00 
	db $F2, $EC, $1A 
	db $0B, $E0, $14 
	db $17, $E0, $00 
	db $18 
	db 1 
	db $0B, $E0, $EC 
	db $10 
	db 3 
	db $E9, $E0, $00 
	db $F5, $E0, $14 
	db $00, $D7, $00
	
M_Shield: ;6913: shield? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $eb, $0, $ec
	db $15, $0, $15
	db $a, $e2, $b
	db $f6, $e2, $f6
	db $3c, $e2, $0
	db $1e, $e2, $cd
	db $e2, $e2, $34
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $b5, $0
	db vEND
.edges
	db 24
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 6
	mEdge 1, 2
	mEdge 1, 7
	mEdge 2, 3
	mEdge 2, 4
	mEdge 3, 5
	mEdge 4, 5
	mEdge 4, 7
	mEdge 5, 6
	mEdge 6, 7
	mEdge 14, 8
	mEdge 14, 10
	mEdge 14, 11
	mEdge 14, 9
	mEdge 14, 12
	mEdge 14, 13
	mEdge 8, 10
	mEdge 8, 13
	mEdge 10, 11
	mEdge 11, 9
	mEdge 9, 12
	mEdge 12, 13
.faces
	db 10
	
	db $0, $a, $1d ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $0, $1, $7
	fEdgeIdx $b, $2, $0, $4
	
	db $e3, $a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $1, $2, $4
	fEdgeIdx $9, $4, $3, $6
	
	db $0, $a, $e3 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $2, $3, $5
	fEdgeIdx $8, $6, $5, $7
	
	db $1d, $a, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $3, $0, $6
	fEdgeIdx $a, $7, $1, $2
	
	db $ee, $18, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $d, $e
	fEdgeIdx $c, $13, $11
	
	db $0, $18, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $c, $e
	fEdgeIdx $11, $17, $10
	
	db $12, $18, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $e, $c
	fEdgeIdx $16, $f, $10
	
	db $12, $18, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $b, $e
	fEdgeIdx $f, $15, $e
	
	db $0, $18, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $a, $e
	fEdgeIdx $e, $14, $d
	
	db $ee, $18, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $e, $a
	fEdgeIdx $12, $c, $d
	
M_Rifle: ;69D6: rifle? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $1e, $6
	db $0, $1e, $f6
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $8, $16, $c0
	db $a, $18, $a8
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $ec, $6c
	db $0, $ec, $54
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $6, $f2, $f4
	db $6, $f2, $e4
	db $8, $f6, $b4
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $ec, $b4
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $8, $e2, $b4

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $e0, $a8
	db $0, $fa, $9c
	db $0, $f2, $58
	db $0, $f2, $30
	db $0, $e6, $64
	db $0, $e6, $3c
	db vEND
.frame1
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $f8, $e4, $a8
	db $8, $f6, $9c
	db $fc, $f0, $5a
	db $fc, $f0, $32
	db $4, $e8, $62
	db $4, $e8, $3a
	db vEND
.frame2
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $f4, $ec, $a8
	db $e, $ec, $9c
	db $fa, $ec, $5e
	db $fa, $ec, $36
	db $6, $ec, $5e
	db $6, $ec, $36
	db vEND
.frame3
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $f8, $f6, $a8
	db $8, $e4, $9c
	db $fc, $e8, $62
	db $fc, $e8, $3a
	db $4, $f0, $5a
	db $4, $f0, $32
	db vEND
.frame4
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $f8, $a8
	db $0, $de, $9c
	db $0, $e6, $64
	db $0, $e6, $3c
	db $0, $f2, $58
	db $0, $f2, $30
	db vEND
.frame5
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $8, $f6, $a8
	db $f8, $e4, $9c
	db $4, $e8, $62
	db $4, $e8, $3a
	db $fc, $f0, $5a
	db $fc, $f0, $32
	db vEND
.frame6
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $c, $ec, $a8
	db $f2, $ec, $9c
	db $6, $ec, $5e
	db $6, $ec, $36
	db $fa, $ec, $5e
	db $fa, $ec, $36
	db vEND
.frame7
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $8, $e4, $a8
	db $f8, $f6, $9c
	db $4, $f0, $5a
	db $4, $f0, $32
	db $fc, $e8, $62
	db $fc, $e8, $3a
	db vEND
.faces
	db 18
	
	db $0, $f4, $1d ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $9, $8
	fEdgeIdx $2, $a, $1
	
	db $0, $c, $e3 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $a, $b
	fEdgeIdx $3, $d, $4
	
	db $1f, $4, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $0, $8, $a
	fEdgeIdx $0, $1, $b, $3
	
	db $e1, $4, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $b, $9
	fEdgeIdx $0, $4, $c, $2
	
	db $0, $16, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $a, $2, $3
	fEdgeIdx $d, $6, $1f, $7
	
	db $0, $1f, $2 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $2, $4, $5
	fEdgeIdx $1f, $5, $20, $1e
	
	db $0, $f6, $e2 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $c, $d
	fEdgeIdx $20, $8, $10, $9
	
	db $1f, $ff, $1 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $c, $4, $2
	fEdgeIdx $e, $8, $5, $6
	
	db $e1, $ff, $1 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $d, $b, $3
	fEdgeIdx $9, $f, $7, $1e
	
	db $0, $1f, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $8, $9
	fEdgeIdx $11, $a, $12
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $c, $f, $10
	fEdgeIdx $10, $15, $17, $16
	
	db $0, $e1, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $10, $f
	fEdgeIdx $14, $17, $13
	
	db $1f, $0, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $f, $c
	fEdgeIdx $13, $15, $21
	
	db $e1, $0, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $d, $10
	fEdgeIdx $16, $14, $22
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $11, $e, $12
	fEdgeIdx $18, $1a, $19
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $7, $0
	fEdgeIdx $1b, $1b
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $13, $14, $0
	fEdgeIdx $1c, $1c
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $15, $16, $0
	fEdgeIdx $1d, $1d
.edges
	db 35
	mEdge 0, 1
	mEdge 0, 8
	mEdge 0, 9
	mEdge 1, 10
	mEdge 1, 11
	mEdge 2, 4
	mEdge 2, 10
	mEdge 3, 11
	mEdge 4, 12
	mEdge 5, 13
	mEdge 8, 9
	mEdge 8, 10
	mEdge 9, 11
	mEdge 10, 11
	mEdge 10, 12
	mEdge 11, 13
	mEdge 12, 13
	mEdge 7, 8
	mEdge 7, 9
	mEdge 7, 15
	mEdge 7, 16
	mEdge 12, 15
	mEdge 13, 16
	mEdge 15, 16
	mEdge 14, 17
	mEdge 17, 18
	mEdge 18, 14
	mEdge 6, 7
	mEdge 19, 20
	mEdge 21, 22
	mEdge 3, 5
	mEdge 2, 3
	mEdge 4, 5
	mEdge 7, 12
	mEdge 7, 13
	
M_PowerCrystal: ;6BCE: spiky cube model header
	vBankB $4900
	
M_Fuel: ;6BD1: gas model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 11 ;number of vertices in group
	db $12, $0, $7
	db $12, $0, $f9
	db $ee, $0, $7
	db $ee, $0, $f9
	db $ee, $dd, $7
	db $ee, $dd, $f9
	db $12, $d3, $7
	db $12, $d3, $f9
	db $fe, $d3, $7
	db $fe, $d3, $f9
	db $ee, $d3, $0

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $db, $7
	db $b, $d8, $7
	db $f, $de, $7
	db $b, $e4, $7
	db $7, $df, $7
	db $a, $df, $7
	db $3, $f0, $7
	db $2, $eb, $7
	db $0, $e4, $7
	db $fe, $eb, $7
	db $fd, $f0, $7
	db $f9, $fc, $7
	db $f1, $f7, $7
	db $f9, $f4, $7
	db $f1, $f0, $7
	db vEND
.frame1
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $dd, $7
	db $b, $da, $7
	db $f, $e0, $7
	db $b, $e6, $7
	db $7, $e2, $7
	db $a, $e1, $7
	db $3, $f6, $7
	db $2, $f1, $7
	db $0, $ea, $7
	db $fe, $f1, $7
	db $fd, $f6, $7
	db $f9, $fa, $7
	db $f1, $f6, $7
	db $f9, $f2, $7
	db $f1, $ee, $7
	db vEND
.frame2
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $e2, $7
	db $b, $df, $7
	db $f, $e5, $7
	db $b, $eb, $7
	db $7, $e7, $7
	db $a, $e6, $7
	db $3, $f7, $7
	db $2, $f2, $7
	db $0, $eb, $7
	db $fe, $f2, $7
	db $fd, $f7, $7
	db $f9, $f4, $7
	db $f1, $f0, $7
	db $f9, $ec, $7
	db $f1, $e8, $7
	db vEND
.frame3
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $e8, $7
	db $b, $e5, $7
	db $f, $eb, $7
	db $b, $f1, $7
	db $7, $ed, $7
	db $a, $ec, $7
	db $3, $f6, $7
	db $2, $f1, $7
	db $0, $ea, $7
	db $fe, $f1, $7
	db $fd, $f6, $7
	db $f9, $ef, $7
	db $f1, $eb, $7
	db $f9, $e7, $7
	db $f1, $e3, $7
	db vEND
.frame4
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $ea, $7
	db $b, $e7, $7
	db $f, $ed, $7
	db $b, $f3, $7
	db $7, $ee, $7
	db $a, $ee, $7
	db $3, $f0, $7
	db $2, $eb, $7
	db $0, $e4, $7
	db $fe, $eb, $7
	db $fd, $f0, $7
	db $f9, $ed, $7
	db $f1, $e8, $7
	db $f9, $e5, $7
	db $f1, $e1, $7
	db vEND
.frame5
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $e8, $7
	db $b, $e5, $7
	db $f, $eb, $7
	db $b, $f1, $7
	db $7, $ed, $7
	db $a, $ec, $7
	db $3, $eb, $7
	db $2, $e5, $7
	db $0, $df, $7
	db $fe, $e5, $7
	db $fd, $eb, $7
	db $f9, $ef, $7
	db $f1, $eb, $7
	db $f9, $e7, $7
	db $f1, $e3, $7
	db vEND
.frame6
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $e2, $7
	db $b, $df, $7
	db $f, $e5, $7
	db $b, $eb, $7
	db $7, $e7, $7
	db $a, $e6, $7
	db $3, $e8, $7
	db $2, $e3, $7
	db $0, $dc, $7
	db $fe, $e3, $7
	db $fd, $e8, $7
	db $f9, $f4, $7
	db $f1, $f0, $7
	db $f9, $ec, $7
	db $f1, $e8, $7
	db vEND
.frame7
	db vNONSPECIAL
	db 15 ;number of vertices in group
	db $7, $dd, $7
	db $b, $da, $7
	db $f, $e0, $7
	db $b, $e6, $7
	db $7, $e2, $7
	db $a, $e1, $7
	db $3, $eb, $7
	db $2, $e5, $7
	db $0, $df, $7
	db $fe, $e5, $7
	db $fd, $eb, $7
	db $f9, $fa, $7
	db $f1, $f6, $7
	db $f9, $f2, $7
	db $f1, $ee, $7
	db vEND
.faces
	db 20
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $3, $2
	fEdgeIdx $0, $a, $1, $5
	
	db $e1, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $3, $5, $4
	fEdgeIdx $1, $b, $2, $6
	
	db $f0, $e5, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $9, $8
	fEdgeIdx $2, $c, $4, $7
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $9, $7, $6
	fEdgeIdx $4, $d, $3, $8
	
	db $1f, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $1, $0
	fEdgeIdx $3, $e, $0, $9
	
	db $0, $0, $e1 ;normal
	db 5 ;number of edges
	fEdgeGroup $3, $1, $7, $9, $5
	fEdgeIdx $a, $e, $d, $c, $b
	
	db $0, $0, $1f ;normal
	db 5 ;number of edges
	fEdgeGroup $6, $0, $2, $4, $8
	fEdgeIdx $9, $5, $6, $7, $8
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $a, $0
	fEdgeIdx $f, $f
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $4, $0
	fEdgeIdx $10, $10
	
	db $0, $28, $d3 ;normal
	db 2 ;number of edges
	fEdgeGroup $b, $c, $0
	fEdgeIdx $11, $11
	
	db $11, $0, $d8 ;normal
	db 2 ;number of edges
	fEdgeGroup $c, $d, $2
	fEdgeIdx $12, $12
	
	db $39, $23, $b0 ;normal
	db 2 ;number of edges
	fEdgeGroup $d, $e, $8
	fEdgeIdx $13, $13
	
	db $3c, $d3, $d3 ;normal
	db 2 ;number of edges
	fEdgeGroup $e, $f, $6
	fEdgeIdx $14, $14
	
	db $28, $d8, $23 ;normal
	db 2 ;number of edges
	fEdgeGroup $f, $10, $0
	fEdgeIdx $15, $15
	
	db $39, $b0, $28 ;normal
	db 2 ;number of edges
	fEdgeGroup $11, $13, $6
	fEdgeIdx $16, $16
	
	db $11, $d3, $0 ;normal
	db 2 ;number of edges
	fEdgeGroup $13, $15, $4
	fEdgeIdx $17, $17
	
	db $14, $23, $23 ;normal
	db 2 ;number of edges
	fEdgeGroup $12, $14, $8
	fEdgeIdx $18, $18
	
	db $0, $28, $d3 ;normal
	db 2 ;number of edges
	fEdgeGroup $16, $17, $8
	fEdgeIdx $19, $19
	
	db $11, $0, $d8 ;normal
	db 2 ;number of edges
	fEdgeGroup $17, $18, $0
	fEdgeIdx $1a, $1a
	
	db $39, $23, $b0 ;normal
	db 2 ;number of edges
	fEdgeGroup $18, $19, $8
	fEdgeIdx $1b, $1b
.edges
	db 28
	mEdge 0, 1
	mEdge 2, 3
	mEdge 4, 5
	mEdge 6, 7
	mEdge 8, 9
	mEdge 0, 2
	mEdge 2, 4
	mEdge 4, 8
	mEdge 8, 6
	mEdge 6, 0
	mEdge 1, 3
	mEdge 3, 5
	mEdge 5, 9
	mEdge 9, 7
	mEdge 7, 1
	mEdge 9, 10
	mEdge 10, 4
	mEdge 11, 12
	mEdge 12, 13
	mEdge 13, 14
	mEdge 14, 15
	mEdge 15, 16
	mEdge 17, 19
	mEdge 19, 21
	mEdge 18, 20
	mEdge 22, 23
	mEdge 23, 24
	mEdge 24, 25
	
M_UNK4: ;6E95: ??? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $28, $0, $ba
	db $28, $0, $f1
	db $25, $e2, $c0
	db $25, $e2, $eb
	db $32, $0, $0
	db $3c, $ce, $f6
	db $3c, $ce, $46

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $1b, $0, $f
	db $1b, $0, $2d
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $e, $e6, $f
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $d8, $e6, $f
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $f2, $e6, $f
	db $e, $e6, $2d
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $d8, $e6, $2d
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $f2, $e6, $2d
	db vEND
.frame1
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $12
	db $ec, $0, $f
	db $14, $0, $2d
	db $e5, $0, $29
	db $e, $e6, $16
	db $df, $e6, $13
	db $27, $e6, $d
	db $f8, $e6, $a
	db $7, $e6, $31
	db $d8, $e6, $2d
	db $20, $e6, $28
	db $f1, $e6, $24
	db vEND
.frame2
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $16
	db $f3, $0, $f
	db $d, $0, $2d
	db $e5, $0, $25
	db $11, $e6, $1f
	db $e9, $e6, $18
	db $24, $e6, $c
	db $fc, $e6, $5
	db $3, $e6, $36
	db $db, $e6, $2e
	db $16, $e6, $23
	db $ee, $e6, $1b
	db vEND
.frame3
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $1a
	db $fa, $0, $f
	db $6, $0, $2d
	db $e5, $0, $21
	db $16, $e6, $26
	db $f5, $e6, $1b
	db $1f, $e6, $d
	db $fe, $e6, $2
	db $1, $e6, $39
	db $e0, $e6, $2d
	db $a, $e6, $20
	db $e9, $e6, $14
	db vEND
.frame4
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $1e
	db $0, $0, $f
	db $0, $0, $2d
	db $e5, $0, $1e
	db $1b, $e6, $2b
	db $0, $e6, $1c
	db $1b, $e6, $11
	db $0, $e6, $2
	db $0, $e6, $3a
	db $e5, $e6, $2b
	db $0, $e6, $20
	db $e5, $e6, $11
	db vEND
.frame5
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $21
	db $6, $0, $f
	db $fa, $0, $2d
	db $e5, $0, $1a
	db $1f, $e6, $2d
	db $a, $e6, $1b
	db $16, $e6, $14
	db $1, $e6, $2
	db $fe, $e6, $39
	db $e9, $e6, $26
	db $f5, $e6, $20
	db $e0, $e6, $d
	db vEND
.frame6
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $25
	db $d, $0, $f
	db $f3, $0, $2d
	db $e5, $0, $16
	db $24, $e6, $2e
	db $16, $e6, $18
	db $11, $e6, $1b
	db $3, $e6, $5
	db $fc, $e6, $36
	db $ee, $e6, $1f
	db $e9, $e6, $23
	db $db, $e6, $c
	db vEND
.frame7
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $1b, $0, $29
	db $14, $0, $f
	db $ec, $0, $2d
	db $e5, $0, $12
	db $27, $e6, $2d
	db $20, $e6, $13
	db $e, $e6, $24
	db $7, $e6, $a
	db $f8, $e6, $31
	db $f1, $e6, $16
	db $df, $e6, $28
	db $d8, $e6, $d
	db vEND
.faces
	db 12
	
	db $0, $fa, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $0, $4, $5
	fEdgeIdx $0, $4, $8, $5
	
	db $1f, $fd, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $2, $6, $4
	fEdgeIdx $3, $7, $b, $4
	
	db $0, $fa, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $3, $7, $6
	fEdgeIdx $2, $6, $a, $7
	
	db $e1, $fd, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $1, $5, $7
	fEdgeIdx $1, $5, $9, $6
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $6, $7
	fEdgeIdx $8, $b, $a, $9
	
	db $0, $e1, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $a, $c, $d
	fEdgeIdx $e, $11, $10, $f
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $a, $0
	fEdgeIdx $c, $c
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $b, $0
	fEdgeIdx $d, $d
	
	db $0, $0, $e1 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $e, $14, $12
	fEdgeIdx $12, $13, $14
	
	db $0, $0, $e1 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $f, $15, $13
	fEdgeIdx $15, $16, $17
	
	db $0, $0, $e1 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $18, $16
	fEdgeIdx $18, $19, $1a
	
	db $0, $0, $e1 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $11, $19, $17
	fEdgeIdx $1b, $1c, $1d
.edges
	db 30
	mEdge 0, 1
	mEdge 1, 3
	mEdge 3, 2
	mEdge 2, 0
	mEdge 0, 4
	mEdge 1, 5
	mEdge 3, 7
	mEdge 2, 6
	mEdge 4, 5
	mEdge 5, 7
	mEdge 7, 6
	mEdge 6, 4
	mEdge 8, 10
	mEdge 9, 11
	mEdge 10, 11
	mEdge 11, 13
	mEdge 13, 12
	mEdge 12, 10
	mEdge 14, 20
	mEdge 20, 18
	mEdge 18, 14
	mEdge 15, 21
	mEdge 21, 19
	mEdge 19, 15
	mEdge 16, 24
	mEdge 24, 22
	mEdge 22, 16
	mEdge 17, 25
	mEdge 25, 23
	mEdge 23, 17
	
M_Truck: ;70BC: truck model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $1b, $fb, $25
	db $1b, $fb, $c2
	db $15, $ce, $c
	db $15, $ce, $a9

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
.frame5
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $10, $0, $4d
	db $12, $0, $34
	db $c, $f3, $57
	db $a, $dd, $3e
	db $d, $dd, $1f
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $d, $c8, $15
	db vEND
.frame1
.frame4
.frame7
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $10, $fe, $4d
	db $12, $fe, $34
	db $c, $f0, $57
	db $a, $db, $3e
	db $d, $db, $1f
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $d, $c7, $12
	db vEND
.frame2
.frame3
.frame6
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $10, $fa, $4d
	db $12, $fa, $34
	db $c, $ec, $57
	db $a, $d7, $3e
	db $d, $d7, $1f
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $d, $c6, $f
	db vEND
.faces
	db 14
	
	db $1f, $fc, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $4, $6, $2
	fEdgeIdx $2, $4, $6, $0
	
	db $e1, $fc, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $7, $5, $1
	fEdgeIdx $7, $5, $3, $1
	
	db $0, $f1, $1b ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $5, $4
	fEdgeIdx $8, $3, $9, $2
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $7, $6
	fEdgeIdx $9, $5, $a, $4
	
	db $0, $f, $e5 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $3, $2
	fEdgeIdx $a, $7, $b, $6
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $3, $1, $0
	fEdgeIdx $b, $1, $8, $0
	
	db $1f, $fa, $3 ;normal
	db 5 ;number of edges
	fEdgeGroup $10, $a, $8, $c, $e
	fEdgeIdx $14, $c, $e, $10, $12
	
	db $e1, $fa, $3 ;normal
	db 5 ;number of edges
	fEdgeGroup $9, $b, $11, $f, $d
	fEdgeIdx $d, $15, $13, $11, $f
	
	db $0, $12, $19 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $9, $d, $c
	fEdgeIdx $16, $f, $17, $e
	
	db $0, $e8, $14 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $d, $f, $e
	fEdgeIdx $17, $11, $18, $10
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $f, $11, $10
	fEdgeIdx $18, $13, $19, $12
	
	db $0, $10, $e5 ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $11, $b, $a
	fEdgeIdx $19, $15, $1a, $14
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $9, $8
	fEdgeIdx $1a, $d, $16, $c
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $12, $0
	fEdgeIdx $1b, $1b
.edges
	db 28
	mEdge 0, 2
	mEdge 1, 3
	mEdge 0, 4
	mEdge 1, 5
	mEdge 4, 6
	mEdge 5, 7
	mEdge 6, 2
	mEdge 7, 3
	mEdge 0, 1
	mEdge 4, 5
	mEdge 6, 7
	mEdge 2, 3
	mEdge 8, 10
	mEdge 9, 11
	mEdge 8, 12
	mEdge 9, 13
	mEdge 12, 14
	mEdge 13, 15
	mEdge 14, 16
	mEdge 15, 17
	mEdge 16, 10
	mEdge 17, 11
	mEdge 8, 9
	mEdge 12, 13
	mEdge 14, 15
	mEdge 16, 17
	mEdge 10, 11
	mEdge 16, 18
	
M_SpinningCone: ;720C: spinning cone model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e2, $0

	db vLIST
	db 4
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
.frame0
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $46
	db $21, $0, $16
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $15, $0, $c7
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $df, $0, $16
	db vEND
.frame1
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $b, $0, $43
	db $23, $0, $0
	db $b, $0, $bd
	db $e4, $0, $d7
	db $e4, $0, $29
	db vEND
.frame2
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $15, $0, $39
	db $21, $0, $ea
	db $0, $0, $ba
	db $df, $0, $ea
	db $eb, $0, $39
	db vEND
.frame3
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $1c, $0, $29
	db $1c, $0, $d7
	db $f5, $0, $bd
	db $dd, $0, $0
	db $f5, $0, $43
	db vEND
.faces
	db 6
	
	db $f, $e7, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $2
	fEdgeIdx $5, $6, $0
	
	db $16, $ea, $fd ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $0, $3
	fEdgeIdx $6, $7, $1
	
	db $0, $e4, $f2 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $0, $4
	fEdgeIdx $7, $8, $2
	
	db $ea, $ea, $fd ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $0, $5
	fEdgeIdx $8, $9, $3
	
	db $f1, $e7, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $0, $1
	fEdgeIdx $9, $5, $4
	
	db $0, $1f, $0 ;normal
	db 5 ;number of edges
	fEdgeGroup $1, $2, $3, $4, $5
	fEdgeIdx $0, $1, $2, $3, $4
.edges
	db 10
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 1
	mEdge 1, 0
	mEdge 2, 0
	mEdge 3, 0
	mEdge 4, 0
	mEdge 5, 0
	
M_PaperAirplane: ;72C2: paper airplane model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $23
	db $0, $a, $e5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $6, $0, $ec

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
.frame7
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1f, $2, $dd
	db vEND
.frame1
.frame6
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1f, $fe, $dd
	db vEND
.frame2
.frame5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1d, $f6, $dd
	db vEND
.frame3
.frame4
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1b, $f2, $dd
	db vEND
.faces
	db 6
	
	db $1a, $11, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $1
	fEdgeIdx $1, $3, $0
	
	db $e6, $11, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $3, $0
	fEdgeIdx $5, $2, $0
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $2
	fEdgeIdx $2, $4, $1
	
	db $0, $ee, $e7 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $1, $2
	fEdgeIdx $5, $3, $4
	
	db $2, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $4
	fEdgeIdx $1, $7, $6
	
	db $fe, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $3, $0
	fEdgeIdx $9, $2, $8
.edges
	db 10
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 3
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 1
	mEdge 0, 4
	mEdge 4, 2
	mEdge 0, 5
	mEdge 5, 3
	
M_UNK5: ;7353: ??? model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $14, $3c
	db $0, $0, $ce
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $14, $0, $a
	db $3c, $f6, $28
	db $3c, $f3, $a
	db vEND
.faces
	db 4
	
	db $f1, $e5, $5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $2, $0
	fEdgeIdx $3, $1, $0
	
	db $f, $e5, $5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $3, $1
	fEdgeIdx $2, $4, $0
	
	db $f7, $e2, $3 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $4, $2, $1
	fEdgeIdx $7, $5, $3, $9
	
	db $9, $e2, $3 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $5, $7, $1
	fEdgeIdx $6, $8, $a, $4
.edges
	db 11
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 3
	mEdge 2, 1
	mEdge 3, 1
	mEdge 2, 4
	mEdge 3, 5
	mEdge 4, 6
	mEdge 5, 7
	mEdge 1, 6
	mEdge 1, 7
	
M_OpeningCone: ;73B3: opening cone model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $74
	db $0, $0, $8c
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $2e, $0, $2e
	db $74, $0, $0
	db $2e, $0, $d2
	db $1e, $d7, $1e
	db $1e, $d7, $e2

	db vLIST
	db 32
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
	dw .frame8
	dw .frame9
	dw .frame10
	dw .frame11
	dw .frame12
	dw .frame13
	dw .frame14
	dw .frame15
	dw .frame16
	dw .frame17
	dw .frame18
	dw .frame19
	dw .frame20
	dw .frame21
	dw .frame22
	dw .frame23
	dw .frame24
	dw .frame25
	dw .frame26
	dw .frame27
	dw .frame28
	dw .frame29
	dw .frame30
	dw .frame31
.frame0
.frame31
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $d0, $0
	db $0, $d0, $0
	db $0, $d0, $0
	db $0, $d0, $0
	db vEND
.frame1
.frame30
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $ce, $0
	db $0, $ce, $0
	db $0, $ce, $0
	db $0, $ce, $0
	db vEND
.frame2
.frame29
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $cb, $0
	db $0, $cb, $0
	db $0, $cb, $0
	db $0, $cb, $0
	db vEND
.frame3
.frame28
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $c6, $3
	db $0, $c6, $fd
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $3, $c6, $0
	db vEND
.frame4
.frame27
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $bf, $6
	db $0, $bf, $fa
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $6, $bf, $0
	db vEND
.frame5
.frame26
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $b9, $d
	db $0, $b9, $f3
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $d, $b9, $0
	db vEND
.frame6
.frame25
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $b0, $17
	db $0, $b0, $e9
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $17, $b0, $0
	db vEND
.frame7
.frame24
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $ab, $24
	db $0, $ab, $dc
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $24, $ab, $0
	db vEND
.frame8
.frame23
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $ab, $37
	db $0, $ab, $c9
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $37, $ab, $0
	db vEND
.frame9
.frame22
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $b2, $4b
	db $0, $b2, $b5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $4b, $b2, $0
	db vEND
.frame10
.frame21
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $be, $5b
	db $0, $be, $a5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $5b, $be, $0
	db vEND
.frame11
.frame20
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $d0, $69
	db $0, $d0, $97
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $69, $d0, $0
	db vEND
.frame12
.frame19
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $e2, $71
	db $0, $e2, $8f
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $71, $e2, $0
	db vEND
.frame13
.frame18
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $f3, $73
	db $0, $f3, $8d
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $73, $f3, $0
	db vEND
.frame14
.frame17
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $fd, $74
	db $0, $fd, $8c
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $74, $fd, $0
	db vEND
.frame15
.frame16
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $0, $74
	db $0, $0, $8c
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $74, $0, $0
	db vEND
.faces
	db 16
	
	db $17, $f1, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $8, $2
	fEdgeIdx $8, $10, $0
	
	db $f, $f1, $17 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $8
	fEdgeIdx $1, $10, $9
	
	db $f, $f1, $e9 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $6, $4
	fEdgeIdx $11, $2, $a
	
	db $17, $f1, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $6, $a
	fEdgeIdx $3, $11, $b
	
	db $e9, $f1, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $7, $1
	fEdgeIdx $12, $4, $c
	
	db $f1, $f1, $e9 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $b
	fEdgeIdx $5, $12, $d
	
	db $f1, $f1, $17 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $3, $5
	fEdgeIdx $13, $6, $e
	
	db $e9, $f1, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $9
	fEdgeIdx $7, $13, $f
	
	db $0, $e4, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $9, $8
	fEdgeIdx $f, $14, $8
	
	db $d, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $8, $a
	fEdgeIdx $9, $15, $a
	
	db $0, $e4, $f3 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $a, $b
	fEdgeIdx $b, $16, $c
	
	db $f3, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $b, $9
	fEdgeIdx $d, $17, $e
	
	db $7, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $e, $a
	fEdgeIdx $18, $19, $15
	
	db $0, $e1, $f9 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $d, $b
	fEdgeIdx $1a, $1b, $16
	
	db $f9, $e1, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $f, $9
	fEdgeIdx $1c, $1d, $17
	
	db $0, $e1, $7 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $c, $8
	fEdgeIdx $1e, $1f, $14
.edges
	db 32
	mEdge 0, 2
	mEdge 2, 4
	mEdge 4, 6
	mEdge 6, 1
	mEdge 1, 7
	mEdge 7, 5
	mEdge 5, 3
	mEdge 3, 0
	mEdge 0, 8
	mEdge 8, 4
	mEdge 4, 10
	mEdge 10, 1
	mEdge 1, 11
	mEdge 11, 5
	mEdge 5, 9
	mEdge 9, 0
	mEdge 2, 8
	mEdge 6, 10
	mEdge 7, 11
	mEdge 3, 9
	mEdge 9, 8
	mEdge 8, 10
	mEdge 10, 11
	mEdge 11, 9
	mEdge 8, 14
	mEdge 14, 10
	mEdge 10, 13
	mEdge 13, 11
	mEdge 11, 15
	mEdge 15, 9
	mEdge 9, 12
	mEdge 12, 8
	
M_Scientist: ;75DB: stick figure model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $c4, $0
	db $7, $cc, $0
	db $0, $d3, $0
	db $0, $e9, $0
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $f, $0, $0
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $f9, $cc, $0

	db vLIST
	db 8
	dw .frame0
	dw .frame1
	dw .frame2
	dw .frame3
	dw .frame4
	dw .frame5
	dw .frame6
	dw .frame7
.frame0
.frame1
.frame2
.frame3
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $ea, $d3, $0
	db vEND
.frame4
.frame5
.frame6
.frame7
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $ea, $cc, $0
	db vEND
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 9 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8
.edges
	db 9
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 3, 5
	mEdge 2, 7
	mEdge 2, 6
	mEdge 6, 0
	mEdge 2, 8
	
M_Mine: ;7643: mine model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $f1, $0
	db $0, $bf, $0
	db $0, $e2, $32
	db $0, $e2, $ce
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $1f, $0, $29
	db $1f, $0, $d7
	db $f, $d8, $32
	db $f, $d8, $ce
	db $19, $d8, $0
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $e7, $32
	db $0, $e7, $ce
	db $0, $c9, $32
	db $0, $c9, $ce
	db $0, $d8, $32
	db $0, $d8, $ce
	db vEND
	db vEND
.faces
	db 16
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $4, $0
	fEdgeIdx $0, $0
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $5, $0
	fEdgeIdx $1, $1
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $6, $0
	fEdgeIdx $2, $2
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $7, $0
	fEdgeIdx $3, $3
	
	db $16, $16, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $8, $c, $0
	fEdgeIdx $7, $9, $f, $8
	
	db $16, $ea, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $10, $1, $c
	fEdgeIdx $6, $a, $e, $9
	
	db $ea, $ea, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $9, $d, $1
	fEdgeIdx $5, $b, $d, $a
	
	db $ea, $16, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $e, $0, $d
	fEdgeIdx $4, $8, $c, $b
	
	db $16, $16, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $c, $a, $f
	fEdgeIdx $f, $13, $17, $10
	
	db $16, $ea, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $1, $11, $a
	fEdgeIdx $e, $12, $16, $13
	
	db $ea, $ea, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $d, $b, $11
	fEdgeIdx $d, $11, $15, $12
	
	db $ea, $16, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $0, $f, $b
	fEdgeIdx $c, $10, $14, $11
	
	db $0, $0, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $9, $10, $8
	fEdgeIdx $4, $5, $6, $7
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $f, $a, $11, $b
	fEdgeIdx $17, $16, $15, $14
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $12, $0
	fEdgeIdx $18, $18
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $13, $0
	fEdgeIdx $19, $19
.edges
	db 26
	mEdge 0, 4
	mEdge 0, 5
	mEdge 0, 6
	mEdge 0, 7
	mEdge 14, 9
	mEdge 9, 16
	mEdge 16, 8
	mEdge 8, 14
	mEdge 14, 0
	mEdge 8, 12
	mEdge 16, 1
	mEdge 9, 13
	mEdge 0, 13
	mEdge 13, 1
	mEdge 1, 12
	mEdge 12, 0
	mEdge 0, 15
	mEdge 13, 11
	mEdge 1, 17
	mEdge 12, 10
	mEdge 15, 11
	mEdge 11, 17
	mEdge 17, 10
	mEdge 10, 15
	mEdge 2, 18
	mEdge 3, 19
	
M_Antenna: ;7764: reactor rods model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 9 ;number of vertices in group
	db $f, $0, $1a
	db $1e, $0, $0
	db $f, $0, $e6
	db $6, $f4, $b
	db $c, $f4, $0
	db $6, $f4, $f5
	db $6, $dc, $b
	db $c, $bc, $0
	db $6, $c0, $f5
	db vEND
.faces
	db 13
	
	db $0, $e8, $13 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $7, $6
	fEdgeIdx $0, $6, $c, $b
	
	db $f0, $e7, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $3, $9, $7
	fEdgeIdx $1, $7, $d, $6
	
	db $ef, $e7, $f7 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $5, $b, $9
	fEdgeIdx $2, $8, $e, $7
	
	db $0, $e8, $ed ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $a, $b
	fEdgeIdx $3, $9, $f, $8
	
	db $10, $e7, $f7 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $2, $8, $a
	fEdgeIdx $4, $a, $10, $9
	
	db $11, $e7, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $0, $6, $8
	fEdgeIdx $5, $b, $11, $a
	
	db $0, $e1, $0 ;normal
	db 6 ;number of edges
	fEdgeGroup $6, $7, $9, $b, $a, $8
	fEdgeIdx $c, $d, $e, $f, $10, $11
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $c, $0
	fEdgeIdx $17, $17
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $d, $0
	fEdgeIdx $12, $12
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $e, $0
	fEdgeIdx $16, $16
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $f, $0
	fEdgeIdx $13, $13
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $10, $0
	fEdgeIdx $15, $15
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $11, $0
	fEdgeIdx $14, $14
.edges
	db 24
	mEdge 0, 1
	mEdge 1, 3
	mEdge 3, 5
	mEdge 5, 4
	mEdge 4, 2
	mEdge 2, 0
	mEdge 1, 7
	mEdge 3, 9
	mEdge 5, 11
	mEdge 4, 10
	mEdge 2, 8
	mEdge 0, 6
	mEdge 6, 7
	mEdge 7, 9
	mEdge 9, 11
	mEdge 11, 10
	mEdge 10, 8
	mEdge 8, 6
	mEdge 7, 13
	mEdge 9, 15
	mEdge 11, 17
	mEdge 10, 16
	mEdge 8, 14
	mEdge 6, 12
	
M_Arrow: ;784A: arrow model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 7 ;number of vertices in group
	db $0, $0, $3c
	db $0, $e2, $0
	db $0, $f6, $a
	db $0, $f1, $c4
	db $0, $f, $c4
	db $0, $a, $a
	db $0, $1e, $0
	db vEND
.faces
	db 1
	
	db $a, $7, $5 ;normal
	db 7 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6
.edges
	db 7
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 6
	mEdge 6, 0
	
M_BlockLetterL: ;788C: block letter L model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $e2, $e2, $0
	db $f4, $e2, $0
	db $f4, $c, $0
	db $1e, $c, $0
	db $1e, $1e, $0
	db $e2, $1e, $0
	db vEND
.edges
	db 6
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5
	fEdgeIdx $0, $1, $2, $3, $4, $5
	
M_BlockLetterU: ;78C7: block letter U model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $e2, $e2, $0
	db $f4, $e2, $0
	db $f4, $c, $0
	db $e2, $11, $0
	db $ef, $1e, $0
	db vEND
.edges
	db 10
	mEdge 0, 2
	mEdge 2, 4
	mEdge 4, 5
	mEdge 5, 3
	mEdge 3, 1
	mEdge 1, 7
	mEdge 7, 9
	mEdge 9, 8
	mEdge 8, 6
	mEdge 6, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	
M_BlockLetterN: ;790F: block letter N model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $e2, $e2, $0
	db $ef, $e2, $0
	db $c, $0, $0
	db $c, $e2, $0
	db $1e, $e2, $0
	db $1e, $1e, $0
	db $11, $1e, $0
	db $f4, $0, $0
	db $f4, $1e, $0
	db $e2, $1e, $0
	db vEND
.edges
	db 10
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 6
	mEdge 6, 7
	mEdge 7, 8
	mEdge 8, 9
	mEdge 9, 0
.faces
	db 1
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	
M_BlockLetterA: ;7966: block letter A model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 8 ;number of vertices in group
	db $ef, $e2, $0
	db $e2, $ef, $0
	db $f4, $11, $0
	db $e2, $1e, $0
	db $f4, $1e, $0
	db $f8, $f4, $0
	db $f4, $f8, $0
	db $f4, $0, $0
	db vEND
.edges
	db 16
	mEdge 0, 1
	mEdge 1, 3
	mEdge 3, 7
	mEdge 7, 9
	mEdge 9, 5
	mEdge 5, 4
	mEdge 4, 8
	mEdge 8, 6
	mEdge 6, 2
	mEdge 2, 0
	mEdge 10, 11
	mEdge 11, 13
	mEdge 13, 15
	mEdge 15, 14
	mEdge 14, 12
	mEdge 12, 10
.faces
	db 2
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $3, $7, $9, $5, $4, $8, $6, $2
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	
	db $0, $0, $0 ;normal
	db 6 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $b, $d, $f, $e, $c
	fEdgeIdx $a, $b, $c, $d, $e, $f
	
M_BlockLetterR: ;79D3: block letter R model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $e2, $e2, $0
	db $15, $e2, $0
	db $1e, $eb, $0
	db $1e, $4, $0
	db $15, $4, $0
	db $1e, $c, $0
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $f4, $ef, $0
	db $f4, $fc, $0
	db $f4, $c, $0
	db $f4, $1e, $0
	db $e2, $1e, $0
	db vEND
.edges
	db 16
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 15
	mEdge 15, 13
	mEdge 13, 11
	mEdge 11, 10
	mEdge 10, 12
	mEdge 12, 14
	mEdge 14, 0
	mEdge 6, 7
	mEdge 7, 9
	mEdge 9, 8
	mEdge 8, 6
.faces
	db 2
	
	db $0, $0, $0 ;normal
	db 9 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $a, $b, $c, $d, $e, $f, $10, $11, $12
	fEdgeIdx $9, $a, $b, $c, $d, $e, $f, $10, $11, $12
	
M_UNK6: ;7A51: unlisted
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 42 ;number of vertices in group
	db $f8, $ec, $0
	db $8, $ec, $0
	db $f0, $f7, $0
	db $10, $f7, $0
	db $f0, $14, $0
	db $10, $14, $0
	db $fa, $14, $0
	db $6, $14, $0
	db $fa, $a, $0
	db $6, $a, $0
	db $fa, $0, $0
	db $6, $0, $0
	db $fa, $f9, $0
	db $6, $f9, $0
	db $ea, $14, $0
	db $16, $14, $0
	db $32, $14, $0
	db $3b, $c, $0
	db $3b, $1, $0
	db $34, $fb, $0
	db $21, $fb, $0
	db $21, $f7, $0
	db $3b, $f7, $0
	db $3b, $ec, $0
	db $c5, $ec, $0
	db $1c, $ec, $0
	db $16, $f4, $0
	db $16, $ff, $0
	db $1b, $5, $0
	db $2f, $5, $0
	db $2f, $9, $0
	db $16, $9, $0
	db $d1, $ec, $0
	db $d1, $fb, $0
	db $df, $fb, $0
	db $df, $ec, $0
	db $ec, $ec, $0
	db $df, $14, $0
	db $df, $7, $0
	db $d1, $7, $0
	db $d1, $14, $0
	db $c5, $14, $0
	db vEND
.edges
	db 42
	mEdge 0, 1
	mEdge 1, 3
	mEdge 3, 5
	mEdge 5, 7
	mEdge 7, 9
	mEdge 9, 8
	mEdge 8, 6
	mEdge 6, 4
	mEdge 4, 2
	mEdge 2, 0
	mEdge 12, 13
	mEdge 13, 11
	mEdge 11, 10
	mEdge 10, 12
	mEdge 25, 23
	mEdge 23, 22
	mEdge 22, 21
	mEdge 21, 20
	mEdge 20, 19
	mEdge 19, 18
	mEdge 18, 17
	mEdge 17, 16
	mEdge 16, 15
	mEdge 15, 31
	mEdge 31, 30
	mEdge 30, 29
	mEdge 29, 28
	mEdge 28, 27
	mEdge 27, 26
	mEdge 26, 25
	mEdge 24, 32
	mEdge 32, 33
	mEdge 33, 34
	mEdge 34, 35
	mEdge 35, 36
	mEdge 36, 14
	mEdge 14, 37
	mEdge 37, 38
	mEdge 38, 39
	mEdge 39, 40
	mEdge 40, 41
	mEdge 41, 24
.faces
	db 4
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $b, $c, $d, $e, $f, $10, $11, $12, $13
	fEdgeIdx $a, $b, $c, $d, $e, $f, $10, $11, $12, $13
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
	fEdgeIdx $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d
	
	db $0, $0, $0 ;normal
	db 12 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29
	fEdgeIdx $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29
	
M_UNK7: ;7B94: unlisted
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 22 ;number of vertices in group
	db $c2, $ec, $0
	db $3e, $ec, $0
	db $c2, $14, $0
	db $3e, $14, $0
	db $c2, $7, $0
	db $a8, $7, $0
	db $a8, $f9, $0
	db $c2, $f9, $0
	db $a5, $ec, $0
	db $9c, $f6, $0
	db $9c, $a, $0
	db $a5, $14, $0
	db $64, $ec, $0
	db $64, $f7, $0
	db $48, $f7, $0
	db $48, $fb, $0
	db $64, $fb, $0
	db $64, $5, $0
	db $48, $5, $0
	db $48, $9, $0
	db $64, $9, $0
	db $64, $14, $0
	db vEND
.edges
	db 22
	mEdge 0, 7
	mEdge 7, 6
	mEdge 6, 5
	mEdge 5, 4
	mEdge 4, 2
	mEdge 2, 11
	mEdge 11, 10
	mEdge 10, 9
	mEdge 9, 8
	mEdge 8, 0
	mEdge 1, 12
	mEdge 12, 13
	mEdge 13, 14
	mEdge 14, 15
	mEdge 15, 16
	mEdge 16, 17
	mEdge 17, 18
	mEdge 18, 19
	mEdge 19, 20
	mEdge 20, 21
	mEdge 21, 3
	mEdge 3, 1
.faces
	db 2
	
	db $0, $0, $0 ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	fEdgeIdx $0, $1, $2, $3, $4, $5, $6, $7, $8, $9
	
	db $0, $0, $0 ;normal
	db 12 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $b, $c, $d, $e, $f, $10, $11, $12, $13, $14, $15
	fEdgeIdx $a, $b, $c, $d, $e, $f, $10, $11, $12, $13, $14, $15
	
M_TrainingRing: ;7C43: flight training ring model header
	db vThisBank
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $c4, $9c, $0
	db $3c, $9c, $0
	db $3c, $0, $0
	db $c4, $0, $0
	db vEND
.edges
	db 4
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 0
.faces
	db 1
	
	db $0, $ea, $f4 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2, $3
	fEdgeIdx $0, $1, $2, $3
	
;all these are off-bank, consist of 01 and a pointer
;7C70: grasshopper model header
	vBankB $4BD3
;7C73: animated plant model header
	vBankB $5C93
;7C76: slug model header
	vBankB $4C92
;7C79: humanoid model header
	vBankB $50A0
;7C7C: mouse ship model header
	vBankB $52E4
;7C7F: center base model header
	vBankB $53CF
;7C82: speedboat model header
	vBankB $54A3
;7C85: block tank model header
	vBankB $5592
;7C88: patrol tank model header
	vBankB $5663
;7C8B: hover tank model header
	vBankB $575D
;7C8E: spike pillar model header
	vBankB $5800
;7C91: spider model header
	vBankB $4DCA
;7C94: rocket truck model header
	vBankB $4F90
;7C97: flower stem model header
	vBankB $586E
;7C9A: flower top model header
	vBankB $597D
;7C9D: mouse model header
	vBankB $5DC7
;7CA0: spider 2 model header
	vBankB $5A63
;7CA3: flat slug model header
	vBankB $5E97
;7CA6: spike model header (not in list)
	vBankB $6246
;7CA9: pillar model header
	vBankB $619C
;7CAC: hexagonal prism model header
	vBankB $60F2
;7CAF: planted half diamond model header
	vBankB $6040
;7CB2: planted diamond model header
	vBankB $5F59
;7CB5: spike spinner model header
	vBankB $640C
;7CB8: water strider model header
	vBankB $651E
;7CBB: radar dish model header
	vBankB $62EB
;7CBE: ??? model header
	vBankB $634C
;7CC1: jet model header
	vBankB $65E7
;7CC4: ??? model header
	vBankB $6707
;7CC7: ??? model header
	vBankB $67B5
;7CCA: dino model header
	vBankB $68B4
;7CCD: supertank model header
	vBankB $69B2
;7CD0: armortank model header
	vBankB $6A9C
;7CD3: mobile turret model header
	vBankB $6B7C
;7CD6: pointy tank model header
	vBankB $6C4C
;7CD9: hovertank model header
	vBankB $6D67
;7CDC: mini dino model header
	vBankB $6E7E
;7CDF: ??? model header
	vBankB $6FC8
;7CE2: neotank model header
	vBankB $7113
;7CE5: radar shop prong model header
	vBankB $72E0
;7CE8: power lines model header
	vBankB $7375
;7CEB: block text VIXIV model header (unreferenced)
	vBankB $744A
;7CEE: final base? model header
	vBankB $7558
;7CF1: X Legs together model header (unreferenced)
	vBankB $7733
;7CF4: X Logo model header
	vBankB $77B7
;7CF7: X Leg 1 model header
	vBankB $7857
;7CFA: X Leg 2 model header
	vBankB $789F
;7CFD: "GAME OVER"
	db "GAME OVER", 00
;7D07 - end of bank filled with FF's