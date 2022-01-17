SECTION "B:4000", ROMX[$4000], BANK[$B]
INCLUDE "src/3Dmath.asm"
;this bank is identical to bank 1 up until $4900, where models start appearing?

SECTION "B Models", ROMX[$4900], BANK[$B]
M_PowerCrystal_B:;4900, power crystal
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
	db 8 ;number of vertices in group
	db $f, $e7, $f
	db $f, $e7, $f1
	db $f, $c9, $f
	db $f, $c9, $f1
	db $f1, $e7, $f
	db $f1, $e7, $f1
	db $f1, $c9, $f
	db $f1, $c9, $f1
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $46, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $1e, $0
	db $0, $92, $0
	db $0, $d8, $46
	db $0, $d8, $ba
	db vEND
.frame1
.frame14
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $f, $e7, $f
	db $f, $e7, $f1
	db $f, $c9, $f
	db $f, $c9, $f1
	db $f1, $e7, $f
	db $f1, $e7, $f1
	db $f1, $c9, $f
	db $f1, $c9, $f1
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $44, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $1c, $0
	db $0, $94, $0
	db $0, $d8, $44
	db $0, $d8, $bc
	db vEND
.frame2
.frame13
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $11, $e9, $11
	db $11, $e9, $ef
	db $11, $c7, $11
	db $11, $c7, $ef
	db $ef, $e9, $11
	db $ef, $e9, $ef
	db $ef, $c7, $11
	db $ef, $c7, $ef
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $40, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $18, $0
	db $0, $98, $0
	db $0, $d8, $40
	db $0, $d8, $c0
	db vEND
.frame3
.frame12
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $14, $ec, $14
	db $14, $ec, $ec
	db $14, $c4, $14
	db $14, $c4, $ec
	db $ec, $ec, $14
	db $ec, $ec, $ec
	db $ec, $c4, $14
	db $ec, $c4, $ec
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $3b, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $13, $0
	db $0, $9d, $0
	db $0, $d8, $3b
	db $0, $d8, $c5
	db vEND
.frame4
.frame11
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $18, $f0, $18
	db $18, $f0, $e8
	db $18, $c0, $18
	db $18, $c0, $e8
	db $e8, $f0, $18
	db $e8, $f0, $e8
	db $e8, $c0, $18
	db $e8, $c0, $e8
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $34, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $c, $0
	db $0, $a4, $0
	db $0, $d8, $34
	db $0, $d8, $cc
	db vEND
.frame5
.frame10
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $1b, $f3, $1b
	db $1b, $f3, $e5
	db $1b, $bd, $1b
	db $1b, $bd, $e5
	db $e5, $f3, $1b
	db $e5, $f3, $e5
	db $e5, $bd, $1b
	db $e5, $bd, $e5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $2f, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $7, $0
	db $0, $a9, $0
	db $0, $d8, $2f
	db $0, $d8, $d1
	db vEND
.frame6
.frame9
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $1d, $f5, $1d
	db $1d, $f5, $e3
	db $1d, $bb, $1d
	db $1d, $bb, $e3
	db $e3, $f5, $1d
	db $e3, $f5, $e3
	db $e3, $bb, $1d
	db $e3, $bb, $e3
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $2b, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $3, $0
	db $0, $ad, $0
	db $0, $d8, $2b
	db $0, $d8, $d5
	db vEND
.frame7
.frame8
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $1e, $f6, $1e
	db $1e, $f6, $e2
	db $1e, $ba, $1e
	db $1e, $ba, $e2
	db $e2, $f6, $1e
	db $e2, $f6, $e2
	db $e2, $ba, $1e
	db $e2, $ba, $e2
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $2a, $d8, $0
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $2, $0
	db $0, $ae, $0
	db $0, $d8, $2a
	db $0, $d8, $d6
	db vEND
.faces
	db 24
	
	db $0, $1e, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $0, $4
	fEdgeIdx $0, $1f, $2
	
	db $0, $e2, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $6, $2
	fEdgeIdx $3, $23, $1
	
	db $8, $1e, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $1, $0
	fEdgeIdx $4, $1c, $6
	
	db $8, $e2, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $2, $3
	fEdgeIdx $7, $20, $5
	
	db $0, $1e, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $5, $1
	fEdgeIdx $a, $1d, $8
	
	db $0, $e2, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $3, $7
	fEdgeIdx $9, $21, $b
	
	db $f8, $1e, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $4, $5
	fEdgeIdx $e, $1e, $c
	
	db $f8, $e2, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $7, $6
	fEdgeIdx $d, $22, $f
	
	db $0, $8, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $a, $4
	fEdgeIdx $10, $13, $1f
	
	db $0, $f8, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $b, $2
	fEdgeIdx $17, $14, $23
	
	db $1e, $8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $a, $0
	fEdgeIdx $11, $10, $1c
	
	db $1e, $f8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $b, $3
	fEdgeIdx $14, $15, $20
	
	db $0, $8, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $a, $1
	fEdgeIdx $12, $11, $1d
	
	db $0, $f8, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $b, $7
	fEdgeIdx $15, $16, $21
	
	db $e2, $8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $a, $5
	fEdgeIdx $13, $12, $1e
	
	db $e2, $f8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $b, $6
	fEdgeIdx $16, $17, $22
	
	db $1e, $0, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $2, $0
	fEdgeIdx $1, $18, $0
	
	db $8, $0, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $0, $2
	fEdgeIdx $6, $18, $7
	
	db $8, $0, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $3, $1
	fEdgeIdx $5, $19, $4
	
	db $1e, $0, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $1, $3
	fEdgeIdx $8, $19, $9
	
	db $e2, $0, $f8 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $7, $5
	fEdgeIdx $b, $1a, $a
	
	db $f8, $0, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $5, $7
	fEdgeIdx $c, $1a, $d
	
	db $f8, $0, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $6, $4
	fEdgeIdx $f, $1b, $e
	
	db $e2, $0, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $4, $6
	fEdgeIdx $2, $1b, $3
.edges
	db 36
	mEdge 12, 0
	mEdge 12, 2
	mEdge 12, 4
	mEdge 12, 6
	mEdge 8, 1
	mEdge 8, 3
	mEdge 8, 0
	mEdge 8, 2
	mEdge 13, 1
	mEdge 13, 3
	mEdge 13, 5
	mEdge 13, 7
	mEdge 9, 5
	mEdge 9, 7
	mEdge 9, 4
	mEdge 9, 6
	mEdge 10, 0
	mEdge 10, 1
	mEdge 10, 5
	mEdge 10, 4
	mEdge 11, 2
	mEdge 11, 3
	mEdge 11, 7
	mEdge 11, 6
	mEdge 0, 2
	mEdge 1, 3
	mEdge 5, 7
	mEdge 4, 6
	mEdge 0, 1
	mEdge 1, 5
	mEdge 5, 4
	mEdge 4, 0
	mEdge 2, 3
	mEdge 3, 7
	mEdge 7, 6
	mEdge 6, 2
	
M_Grasshopper: ;4BD3
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $a, $0, $ec
	db $a, $0, $0
	db $f6, $0, $0
	db $f6, $0, $ec
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $a, $ce, $a
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $d8, $14
	db $0, $ec, $e2
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $a, $f6, $e2
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $f6, $c4
	db vEND
.edges
	db 15
	mEdge 0, 1
	mEdge 0, 4
	mEdge 2, 3
	mEdge 3, 5
	mEdge 4, 8
	mEdge 5, 9
	mEdge 6, 7
	mEdge 6, 8
	mEdge 6, 9
	mEdge 7, 8
	mEdge 7, 9
	mEdge 7, 10
	mEdge 8, 9
	mEdge 8, 10
	mEdge 9, 10
.faces
	db 12
	
	db $15, $15, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $6, $9
	fEdgeIdx $a, $6, $8
	
	db $eb, $15, $8 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $8, $6
	fEdgeIdx $6, $9, $7
	
	db $eb, $15, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $7, $a
	fEdgeIdx $d, $9, $b
	
	db $15, $15, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $9, $a
	fEdgeIdx $b, $a, $e
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $8, $a
	fEdgeIdx $e, $c, $d
	
	db $0, $e5, $f0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $6, $8
	fEdgeIdx $c, $8, $7
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $2, $0
	fEdgeIdx $2, $2
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $5, $0
	fEdgeIdx $3, $3
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $5, $0
	fEdgeIdx $5, $5
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $4, $0
	fEdgeIdx $4, $4
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $0, $0
	fEdgeIdx $1, $1
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $0, $0
	
M_Slug: ;4C92
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $f, $0, $5

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
.frame6
.frame12
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $ec, $0, $42
	db $11, $0, $30
	db $da, $0, $1b
	db $f6, $ce, $26
	db $fd, $e9, $30
	db $ea, $e9, $29
	db $a, $ce, $45
	db $d3, $ce, $30
	db $0, $ea, $0
	db $ec, $0, $c8
	db vEND
.frame1
.frame5
.frame7
.frame11
.frame13
.frame15
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $fa, $0, $40
	db $1a, $0, $2b
	db $e0, $0, $21
	db $fd, $ce, $24
	db $5, $e9, $2c
	db $f3, $e9, $2a
	db $1f, $d6, $3e
	db $d6, $d6, $36
	db $0, $e7, $0
	db $fa, $0, $cc
	db vEND
.frame2
.frame4
.frame8
.frame10
.frame14
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $5, $0, $3c
	db $21, $0, $24
	db $e5, $0, $25
	db $2, $ce, $21
	db $d, $e9, $27
	db $fa, $e9, $29
	db $2a, $d6, $33
	db $e1, $d6, $3b
	db $0, $e4, $0
	db $5, $0, $d2
	db vEND
.frame3
.frame9
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $f, $0, $35
	db $26, $0, $1b
	db $eb, $0, $27
	db $7, $ce, $1d
	db $12, $e9, $20
	db $0, $e9, $27
	db $2a, $ce, $28
	db $f3, $ce, $3c
	db $0, $e1, $0
	db $e, $0, $da
	db vEND
.faces
	db 10
	
	db $c, $f4, $1a ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $5, $3
	fEdgeIdx $0, $1, $2
	
	db $e6, $f4, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $5, $2
	fEdgeIdx $3, $0, $4
	
	db $1c, $f2, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $5, $0
	fEdgeIdx $1, $5, $6
	
	db $ed, $f1, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $5, $4
	fEdgeIdx $7, $3, $8
	
	db $1a, $f0, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $0, $5
	fEdgeIdx $9, $5, $a
	
	db $e8, $f3, $f0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $1, $a
	fEdgeIdx $7, $b, $a
	
	db $18, $f3, $f2 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $a, $b
	fEdgeIdx $9, $c, $d
	
	db $e6, $ee, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $a, $1
	fEdgeIdx $c, $b, $e
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $8, $0
	fEdgeIdx $f, $f
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $9, $0
	fEdgeIdx $10, $10
.edges
	db 17
	mEdge 2, 5
	mEdge 5, 3
	mEdge 3, 2
	mEdge 4, 5
	mEdge 2, 4
	mEdge 5, 0
	mEdge 0, 3
	mEdge 1, 5
	mEdge 4, 1
	mEdge 10, 0
	mEdge 5, 10
	mEdge 1, 10
	mEdge 10, 11
	mEdge 11, 0
	mEdge 1, 11
	mEdge 6, 8
	mEdge 7, 9
	
M_Spider: ;4DCA
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $ec, $0
	db $0, $d8, $0
	db $0, $e2, $d
	db $0, $e2, $f3
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $16, $e2, $0

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
	db 8 ;number of vertices in group
	db $26, $d4, $10
	db $d5, $d8, $f0
	db $29, $d8, $f0
	db $dd, $d8, $10
	db $38, $f9, $1c
	db $be, $0, $e4
	db $3e, $0, $e4
	db $ce, $0, $1c
	db vEND
.frame1
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2a, $d4, $10
	db $d3, $d8, $f0
	db $27, $d8, $f0
	db $db, $d8, $10
	db $40, $f9, $1c
	db $ba, $0, $e4
	db $3a, $0, $e4
	db $ca, $0, $1c
	db vEND
.frame2
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2d, $d8, $10
	db $d6, $d4, $ed
	db $25, $d8, $f0
	db $d9, $d8, $10
	db $46, $0, $1c
	db $c0, $f9, $df
	db $36, $0, $e4
	db $c6, $0, $1c
	db vEND
.frame3
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $2b, $d8, $10
	db $da, $d4, $ed
	db $23, $d8, $f0
	db $d7, $d8, $10
	db $42, $0, $1c
	db $c8, $f9, $df
	db $32, $0, $e4
	db $c2, $0, $1c
	db vEND
.frame4
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $29, $d8, $10
	db $dd, $d8, $ed
	db $26, $d4, $ed
	db $d5, $d8, $10
	db $3e, $0, $1c
	db $ce, $0, $df
	db $38, $f9, $df
	db $be, $0, $1c
	db vEND
.frame5
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $27, $d8, $10
	db $db, $d8, $ed
	db $2a, $d4, $ed
	db $d3, $d8, $10
	db $3a, $0, $1c
	db $ca, $0, $df
	db $40, $f9, $df
	db $ba, $0, $1c
	db vEND
.frame6
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $25, $d8, $10
	db $d9, $d8, $ed
	db $2d, $d8, $ed
	db $d6, $d4, $13
	db $36, $0, $1c
	db $c6, $0, $df
	db $46, $0, $df
	db $c0, $f9, $21
	db vEND
.frame7
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $23, $d8, $10
	db $d7, $d8, $ed
	db $2b, $d8, $ed
	db $da, $d4, $13
	db $32, $0, $1c
	db $c2, $0, $df
	db $42, $0, $df
	db $c8, $f9, $21
	db vEND
.faces
	db 16
	
	db $a, $e9, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $1
	fEdgeIdx $0, $1, $2
	
	db $f6, $e9, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $5, $1
	fEdgeIdx $3, $4, $1
	
	db $f6, $e9, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $3, $1
	fEdgeIdx $5, $6, $4
	
	db $a, $e9, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $4, $1
	fEdgeIdx $7, $2, $6
	
	db $a, $17, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $0
	fEdgeIdx $0, $8, $9
	
	db $f6, $17, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $2, $0
	fEdgeIdx $3, $9, $a
	
	db $f6, $17, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $5, $0
	fEdgeIdx $5, $a, $b
	
	db $a, $17, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $3, $0
	fEdgeIdx $7, $b, $8
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $6, $0
	fEdgeIdx $c, $c
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $7, $0
	fEdgeIdx $d, $d
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $8, $0
	fEdgeIdx $e, $e
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $9, $0
	fEdgeIdx $f, $f
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $a, $0
	fEdgeIdx $10, $10
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $b, $0
	fEdgeIdx $11, $11
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $c, $0
	fEdgeIdx $12, $12
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $d, $0
	fEdgeIdx $13, $13
.edges
	db 20
	mEdge 4, 2
	mEdge 2, 1
	mEdge 1, 4
	mEdge 2, 5
	mEdge 5, 1
	mEdge 5, 3
	mEdge 3, 1
	mEdge 3, 4
	mEdge 4, 0
	mEdge 0, 2
	mEdge 0, 5
	mEdge 0, 3
	mEdge 4, 6
	mEdge 5, 7
	mEdge 4, 8
	mEdge 5, 9
	mEdge 6, 10
	mEdge 7, 11
	mEdge 8, 12
	mEdge 9, 13
	
M_RocketTruck: ;4F90
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $f6, $46
	db $0, $e7, $18
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $14, $0, $26
	db $14, $0, $c4
	db $1e, $f6, $2d
	db $1e, $f6, $f
	db $1e, $f6, $ba

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
	db $14, $ea, $f
	db vEND
.frame1
.frame6
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $da, $b
	db vEND
.frame2
.frame5
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $ca, $4
	db vEND
.frame3
.frame4
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $bd, $fa
	db vEND
.faces
	db 13
	
	db $0, $1e, $9 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $0, $2
	fEdgeIdx $0, $1, $2
	
	db $d, $18, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $2, $0
	fEdgeIdx $3, $1, $4
	
	db $f3, $18, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $7
	fEdgeIdx $0, $5, $6
	
	db $16, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $4, $2
	fEdgeIdx $7, $8, $9, $3
	
	db $ea, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $3, $5
	fEdgeIdx $a, $5, $b, $c
	
	db $0, $16, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $5, $4
	fEdgeIdx $d, $c, $e, $8
	
	db $8, $e3, $9 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $0, $1
	fEdgeIdx $4, $f, $10
	
	db $f8, $e3, $9 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $7, $1
	fEdgeIdx $6, $11, $f
	
	db $e, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $6, $1
	fEdgeIdx $12, $10, $13
	
	db $f2, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $9, $1
	fEdgeIdx $14, $15, $11
	
	db $0, $f0, $e5 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $1, $9
	fEdgeIdx $13, $15, $16
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $9, $b, $a
	fEdgeIdx $16, $17, $d, $18
	
	db $0, $e1, $fc ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $d, $b, $a
	fEdgeIdx $19, $1a, $d, $1b
.edges
	db 28
	mEdge 3, 0
	mEdge 0, 2
	mEdge 2, 3
	mEdge 6, 2
	mEdge 0, 6
	mEdge 3, 7
	mEdge 7, 0
	mEdge 6, 10
	mEdge 10, 4
	mEdge 4, 2
	mEdge 11, 7
	mEdge 3, 5
	mEdge 5, 11
	mEdge 10, 11
	mEdge 5, 4
	mEdge 0, 1
	mEdge 1, 6
	mEdge 7, 1
	mEdge 8, 6
	mEdge 1, 8
	mEdge 7, 9
	mEdge 9, 1
	mEdge 9, 8
	mEdge 9, 11
	mEdge 10, 8
	mEdge 12, 13
	mEdge 13, 11
	mEdge 10, 12
	
M_Humanoid: ;50A0
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $e4, $0
	db $0, $df, $9
	db $0, $da, $5
	db $0, $c3, $a
	db $0, $c2, $4
	db $0, $ba, $4
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $9, $df, $fc
	db $5, $da, $fd
	db $a, $c3, $fb
	db $4, $c2, $fe
	db $4, $ba, $fe
	db $6, $df, $0
	db $8, $c4, $fe

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
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $7, $ee, $4
	db $6, $fd, $fa
	db $9, $fe, $1
	db $f9, $ee, $3
	db $fa, $0, $0
	db $f7, $0, $7
	db $e, $d0, $fb
	db $d, $dc, $0
	db $f, $df, $3
	db $f2, $d0, $fb
	db $f3, $dc, $0
	db $f1, $df, $3
	db vEND
.frame1
.frame6
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $7, $ed, $7
	db $6, $ff, $a
	db $9, $ff, $11
	db $f9, $ee, $fd
	db $fa, $fd, $f3
	db $f7, $0, $f9
	db $d, $ce, $f6
	db $c, $da, $f8
	db $e, $de, $f9
	db $f3, $d0, $0
	db $f4, $d7, $a
	db $f2, $d8, $e
	db vEND
.frame2
.frame5
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $7, $ee, $3
	db $6, $0, $0
	db $9, $0, $7
	db $f9, $ee, $4
	db $fa, $fd, $fa
	db $f7, $fe, $1
	db $e, $d0, $fb
	db $d, $dc, $0
	db $f, $df, $3
	db $f2, $d0, $fb
	db $f3, $dc, $0
	db $f1, $df, $3
	db vEND
.frame3
.frame4
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $7, $ee, $fd
	db $6, $fd, $f3
	db $9, $0, $f9
	db $f9, $ed, $7
	db $fa, $ff, $a
	db $f7, $ff, $11
	db $d, $d0, $0
	db $c, $d7, $a
	db $e, $d8, $e
	db $f3, $ce, $f6
	db $f4, $da, $f8
	db $f2, $de, $f9
	db vEND
.faces
	db 27
	
	db $12, $16, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $1, $6
	fEdgeIdx $0, $1, $2
	
	db $ee, $16, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $7, $1
	fEdgeIdx $3, $4, $0
	
	db $0, $13, $e8 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $0, $6
	fEdgeIdx $3, $2, $5
	
	db $17, $f3, $10 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $1, $2, $8
	fEdgeIdx $1, $6, $7, $8
	
	db $e9, $f1, $10 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $7, $9, $2
	fEdgeIdx $4, $9, $a, $6
	
	db $0, $fa, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $6, $8, $9
	fEdgeIdx $5, $8, $b, $9
	
	db $1a, $3, $10 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $2, $3, $a
	fEdgeIdx $7, $c, $d, $e
	
	db $e6, $4, $10 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $9, $b, $3
	fEdgeIdx $a, $f, $10, $c
	
	db $0, $2, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $8, $a, $b
	fEdgeIdx $b, $e, $11, $f
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $3, $b
	fEdgeIdx $d, $10, $11
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $d, $4
	fEdgeIdx $12, $13, $14
	
	db $1a, $0, $11 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $4, $5, $e
	fEdgeIdx $14, $15, $16, $17
	
	db $e6, $0, $11 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $d, $f, $5
	fEdgeIdx $13, $18, $19, $15
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $c, $e, $f
	fEdgeIdx $12, $17, $1a, $18
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $5, $f
	fEdgeIdx $16, $19, $1a
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $14, $0
	fEdgeIdx $1b, $1b
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $14, $15, $0
	fEdgeIdx $1c, $1c
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $15, $16, $0
	fEdgeIdx $1d, $1d
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $11, $17, $0
	fEdgeIdx $1e, $1e
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $17, $18, $0
	fEdgeIdx $1f, $1f
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $18, $19, $0
	fEdgeIdx $20, $20
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $12, $1a, $0
	fEdgeIdx $21, $21
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1a, $1b, $0
	fEdgeIdx $22, $22
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1b, $1c, $0
	fEdgeIdx $23, $23
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $13, $1d, $0
	fEdgeIdx $24, $24
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1d, $1e, $0
	fEdgeIdx $25, $25
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1e, $1f, $0
	fEdgeIdx $26, $26
.edges
	db 39
	mEdge 0, 1
	mEdge 1, 6
	mEdge 6, 0
	mEdge 0, 7
	mEdge 7, 1
	mEdge 6, 7
	mEdge 1, 2
	mEdge 2, 8
	mEdge 8, 6
	mEdge 7, 9
	mEdge 9, 2
	mEdge 8, 9
	mEdge 2, 3
	mEdge 3, 10
	mEdge 10, 8
	mEdge 9, 11
	mEdge 11, 3
	mEdge 10, 11
	mEdge 12, 13
	mEdge 13, 4
	mEdge 4, 12
	mEdge 4, 5
	mEdge 5, 14
	mEdge 14, 12
	mEdge 13, 15
	mEdge 15, 5
	mEdge 14, 15
	mEdge 16, 20
	mEdge 20, 21
	mEdge 21, 22
	mEdge 17, 23
	mEdge 23, 24
	mEdge 24, 25
	mEdge 18, 26
	mEdge 26, 27
	mEdge 27, 28
	mEdge 19, 29
	mEdge 29, 30
	mEdge 30, 31
	
M_MouseShip: ;52E4
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $28, $e8, $d8
	db $28, $dc, $d8
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $c4, $46
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $ec, $0
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e2, $28
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $d8, $0
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $d8, $0
	db $0, $e2, $d8
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $e2, $e2, $b0
	db vEND
.edges
	db 25
	mEdge 0, 2
	mEdge 0, 5
	mEdge 0, 13
	mEdge 1, 3
	mEdge 1, 6
	mEdge 1, 12
	mEdge 2, 8
	mEdge 2, 13
	mEdge 3, 9
	mEdge 3, 12
	mEdge 4, 7
	mEdge 4, 10
	mEdge 5, 6
	mEdge 5, 7
	mEdge 5, 8
	mEdge 5, 11
	mEdge 6, 7
	mEdge 6, 9
	mEdge 6, 11
	mEdge 7, 8
	mEdge 7, 9
	mEdge 7, 10
	mEdge 8, 9
	mEdge 8, 11
	mEdge 9, 11
.faces
	db 13
	
	db $0, $e2, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $6, $7
	fEdgeIdx $d, $c, $10
	
	db $0, $1e, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $7, $9
	fEdgeIdx $16, $13, $14
	
	db $e4, $0, $f2 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $5, $7
	fEdgeIdx $13, $e, $d
	
	db $0, $1e, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $9, $b
	fEdgeIdx $17, $16, $18
	
	db $0, $e2, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $5, $b
	fEdgeIdx $12, $c, $f
	
	db $1c, $0, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $6, $b
	fEdgeIdx $18, $11, $12
	
	db $e4, $0, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $8, $b
	fEdgeIdx $f, $e, $17
	
	db $1c, $0, $f2 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $7, $6
	fEdgeIdx $11, $14, $10
	
	db $1f, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $a, $4
	fEdgeIdx $a, $15, $b
	
	db $1e, $0, $7 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $1, $c
	fEdgeIdx $9, $3, $5
	
	db $1c, $0, $f2 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $6, $1, $3
	fEdgeIdx $8, $11, $4, $3
	
	db $1e, $0, $f9 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $0, $d
	fEdgeIdx $7, $0, $2
	
	db $1c, $0, $e ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $5, $0, $2
	fEdgeIdx $6, $e, $1, $0
	
M_Junction: ;53CF
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 12 ;number of vertices in group
	db $1b, $bd, $33
	db $1b, $bd, $cd
	db $33, $bd, $1b
	db $33, $bd, $e5
	db $d8, $ea, $3c
	db $d8, $ea, $c4
	db $3e, $ea, $da
	db $3e, $ea, $26
	db $bd, $0, $bd
	db $bd, $0, $43
	db $d3, $a6, $d3
	db $d3, $a6, $2d
	db vEND
.edges
	db 28
	mEdge 0, 1
	mEdge 0, 9
	mEdge 1, 8
	mEdge 2, 3
	mEdge 2, 11
	mEdge 3, 10
	mEdge 4, 6
	mEdge 4, 14
	mEdge 6, 12
	mEdge 5, 7
	mEdge 5, 15
	mEdge 7, 13
	mEdge 8, 9
	mEdge 10, 11
	mEdge 12, 14
	mEdge 15, 13
	mEdge 16, 18
	mEdge 16, 17
	mEdge 16, 20
	mEdge 18, 19
	mEdge 18, 22
	mEdge 19, 17
	mEdge 19, 23
	mEdge 17, 21
	mEdge 20, 22
	mEdge 20, 21
	mEdge 22, 23
	mEdge 23, 21
.faces
	db 9
	
	db $1e, $7, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $16, $12, $10, $14
	fEdgeIdx $18, $14, $10, $12
	
	db $1e, $7, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $f, $d, $7
	fEdgeIdx $9, $a, $f, $b
	
	db $0, $7, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $14, $10, $11, $15
	fEdgeIdx $19, $12, $11, $17
	
	db $0, $7, $e2 ;normal
	db 4 ;number of edges
	fEdgeGroup $17, $13, $12, $16
	fEdgeIdx $1a, $16, $13, $14
	
	db $e2, $7, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $15, $11, $13, $17
	fEdgeIdx $1b, $17, $15, $16
	
	db $0, $6, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $a, $b, $2
	fEdgeIdx $3, $5, $d, $4
	
	db $0, $6, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $9, $8, $1
	fEdgeIdx $0, $1, $c, $2
	
	db $e2, $7, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $c, $e, $4
	fEdgeIdx $6, $8, $e, $7
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $15, $17, $16, $14
	fEdgeIdx $19, $1b, $1a, $18
	
M_Speedboat: ;54A3
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 8 ;number of vertices in group
	db $f6, $dd, $25
	db $a, $ec, $f4
	db $11, $0, $b5
	db $11, $e7, $e7
	db $19, $f1, $0
	db $e7, $0, $19
	db $db, $0, $b5
	db $25, $e7, $32
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $db, $db, $9c
	db $0, $e2, $4b
	db vEND
.edges
	db 24
	mEdge 0, 3
	mEdge 1, 2
	mEdge 16, 12
	mEdge 17, 10
	mEdge 17, 11
	mEdge 17, 14
	mEdge 17, 15
	mEdge 4, 5
	mEdge 4, 6
	mEdge 4, 8
	mEdge 5, 7
	mEdge 5, 9
	mEdge 6, 7
	mEdge 6, 8
	mEdge 7, 9
	mEdge 8, 9
	mEdge 10, 11
	mEdge 10, 12
	mEdge 10, 15
	mEdge 11, 13
	mEdge 11, 14
	mEdge 12, 13
	mEdge 12, 15
	mEdge 13, 14
.faces
	db 14
	
	db $0, $e5, $f0 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $a, $11
	fEdgeIdx $4, $10, $3
	
	db $9, $e9, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $11, $a
	fEdgeIdx $12, $6, $3
	
	db $f7, $e9, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $b, $11
	fEdgeIdx $5, $14, $4
	
	db $1d, $9, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $9, $5
	fEdgeIdx $a, $e, $b
	
	db $e3, $9, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $4, $8
	fEdgeIdx $d, $8, $9
	
	db $0, $1c, $e ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $5, $4
	fEdgeIdx $8, $c, $a, $7
	
	db $0, $1d, $f5 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $8, $9, $7
	fEdgeIdx $c, $d, $f, $e
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $d, $c
	fEdgeIdx $11, $10, $13, $15
	
	db $1a, $f0, $fd ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $c, $f
	fEdgeIdx $12, $11, $16
	
	db $e6, $f0, $fd ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $e, $d
	fEdgeIdx $13, $14, $17
	
	db $0, $1f, $6 ;normal
	db 5 ;number of edges
	fEdgeGroup $c, $d, $e, $11, $f
	fEdgeIdx $16, $15, $17, $5, $6
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $2, $0
	fEdgeIdx $1, $1
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $3, $0
	fEdgeIdx $0, $0
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $c, $0
	fEdgeIdx $2, $2
	
M_BlockTank: ;5592
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $e2, $c4, $f1
	db $1e, $e2, $f
	db $1e, $e2, $3c
	db $1e, $e2, $c4
	db $2d, $0, $5a
	db $2d, $0, $a6
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $d3, $4b
	db $0, $d3, $0
	db vEND
.edges
	db 23
	mEdge 12, 13
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 7
	mEdge 1, 2
	mEdge 1, 6
	mEdge 2, 3
	mEdge 2, 4
	mEdge 2, 6
	mEdge 3, 7
	mEdge 3, 5
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
.faces
	db 11
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $3, $2, $4
	fEdgeIdx $c, $a, $6, $7
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $d, $c, $0
	fEdgeIdx $0, $0
	
	db $0, $1a, $11 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $7, $6, $1
	fEdgeIdx $1, $3, $e, $5
	
	db $1f, $0, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $7
	fEdgeIdx $3, $2, $9
	
	db $e1, $0, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $6, $2
	fEdgeIdx $4, $5, $8
	
	db $0, $16, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $0, $1, $2
	fEdgeIdx $6, $2, $1, $4
	
	db $1c, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $9, $b, $7
	fEdgeIdx $10, $12, $16, $11
	
	db $0, $16, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $b, $a, $6
	fEdgeIdx $e, $11, $15, $f
	
	db $0, $16, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $8, $9, $5
	fEdgeIdx $c, $d, $14, $12
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $9, $8
	fEdgeIdx $13, $15, $16, $14
	
	db $e4, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $8, $4
	fEdgeIdx $b, $f, $13, $d
	
M_PatrolTank: ;5663
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $ec, $e2, $e2
	db $14, $e2, $14
	db $14, $0, $dc
	db $ec, $0, $18
	db $e2, $ec, $ce
	db $1e, $ec, $32
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $ec, $c4, $d8
	db $0, $d8, $22
	db $0, $d8, $0
	db $0, $d0, $ec
	db vEND
.edges
	db 26
	mEdge 12, 0
	mEdge 13, 14
	mEdge 15, 0
	mEdge 15, 1
	mEdge 15, 2
	mEdge 15, 3
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 8
	mEdge 1, 2
	mEdge 1, 9
	mEdge 2, 3
	mEdge 2, 10
	mEdge 3, 11
	mEdge 4, 5
	mEdge 4, 7
	mEdge 4, 9
	mEdge 5, 6
	mEdge 5, 8
	mEdge 6, 7
	mEdge 6, 11
	mEdge 7, 10
	mEdge 8, 9
	mEdge 8, 11
	mEdge 9, 10
	mEdge 10, 11
.faces
	db 14
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $0, $0
	fEdgeIdx $0, $0
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $e, $d, $0
	fEdgeIdx $1, $1
	
	db $0, $f, $1b ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $0, $1
	fEdgeIdx $3, $2, $6
	
	db $eb, $17, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $1, $2
	fEdgeIdx $4, $3, $9
	
	db $0, $1c, $f3 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $f, $2
	fEdgeIdx $b, $5, $4
	
	db $0, $1c, $e ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $8, $9, $1
	fEdgeIdx $6, $8, $16, $a
	
	db $ea, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $9, $a, $2
	fEdgeIdx $9, $a, $18, $c
	
	db $0, $1e, $f6 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $a, $b, $3
	fEdgeIdx $b, $c, $19, $d
	
	db $16, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $b, $8, $0
	fEdgeIdx $7, $d, $17, $8
	
	db $15, $17, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $3, $0
	fEdgeIdx $2, $5, $7
	
	db $0, $ee, $1a ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $9, $8, $5
	fEdgeIdx $e, $10, $16, $12
	
	db $0, $e7, $ed ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $b, $a, $7
	fEdgeIdx $13, $14, $19, $15
	
	db $e4, $f2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $a, $9, $4
	fEdgeIdx $f, $15, $18, $10
	
	db $1c, $f2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $8, $b, $6
	fEdgeIdx $11, $12, $17, $14
	
M_HoverTank: ;575D
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 10 ;number of vertices in group
	db $d8, $e4, $c4
	db $ec, $e4, $0
	db $0, $da, $e2
	db $0, $de, $ec
	db $0, $de, $14
	db $0, $e4, $ba
	db $0, $e4, $3c
	db $0, $0, $ce
	db $14, $e4, $0
	db $28, $e4, $c4
	db vEND
.edges
	db 15
	mEdge 0, 5
	mEdge 0, 6
	mEdge 0, 7
	mEdge 1, 2
	mEdge 1, 5
	mEdge 1, 8
	mEdge 2, 5
	mEdge 2, 8
	mEdge 3, 4
	mEdge 5, 7
	mEdge 5, 8
	mEdge 5, 9
	mEdge 6, 7
	mEdge 6, 9
	mEdge 7, 9
.faces
	db 9
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $4, $0
	fEdgeIdx $8, $8
	
	db $14, $17, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $1, $5
	fEdgeIdx $6, $3, $4
	
	db $ec, $17, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $5, $8
	fEdgeIdx $7, $6, $a
	
	db $0, $1e, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $8, $1
	fEdgeIdx $3, $7, $5
	
	db $fa, $ee, $19 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $9
	fEdgeIdx $b, $9, $e
	
	db $6, $ee, $19 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $0, $7
	fEdgeIdx $9, $0, $2
	
	db $12, $e8, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $0, $6
	fEdgeIdx $c, $2, $1
	
	db $ee, $e8, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $6, $9
	fEdgeIdx $e, $c, $d
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $9, $6, $0
	fEdgeIdx $0, $b, $d, $1
	
M_SpikePillar: ;5800
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $f, $0, $e7
	db $e2, $0, $0
	db $f1, $0, $19
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $88, $0
	db vEND
.edges
	db 12
	mEdge 6, 0
	mEdge 6, 1
	mEdge 6, 2
	mEdge 6, 4
	mEdge 6, 5
	mEdge 6, 3
	mEdge 0, 1
	mEdge 0, 3
	mEdge 1, 2
	mEdge 2, 4
	mEdge 4, 5
	mEdge 5, 3
.faces
	db 6
	
	db $e6, $6, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $6, $0
	fEdgeIdx $7, $5, $0
	
	db $e6, $6, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $5, $6
	fEdgeIdx $5, $b, $4
	
	db $0, $6, $e1 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $4, $6
	fEdgeIdx $4, $a, $3
	
	db $1a, $6, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $6, $4
	fEdgeIdx $9, $2, $3
	
	db $1a, $6, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $1, $6
	fEdgeIdx $2, $8, $1
	
	db $0, $6, $1f ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $6
	fEdgeIdx $1, $6, $0
	
M_FlowerStem: ;586E
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $7, $9e, $fe
	db $7, $0, $fe
	db $c, $c9, $f2
	db $f7, $d7, $f6
	db vNONSPECIAL
	db 9 ;number of vertices in group
	db $0, $0, $4
	db $0, $9e, $4
	db $0, $bc, $ef
	db $0, $ca, $e2
	db $0, $d7, $e7
	db $0, $f2, $fd
	db $0, $e4, $ef
	db $4, $e4, $f9
	db $fb, $e4, $f9
	db vEND
.edges
	db 27
	mEdge 8, 9
	mEdge 8, 2
	mEdge 8, 3
	mEdge 9, 0
	mEdge 9, 1
	mEdge 0, 1
	mEdge 0, 2
	mEdge 1, 3
	mEdge 2, 3
	mEdge 10, 4
	mEdge 10, 5
	mEdge 10, 11
	mEdge 4, 11
	mEdge 4, 7
	mEdge 5, 11
	mEdge 5, 6
	mEdge 11, 12
	mEdge 12, 6
	mEdge 12, 7
	mEdge 12, 14
	mEdge 6, 16
	mEdge 7, 15
	mEdge 13, 14
	mEdge 13, 15
	mEdge 13, 16
	mEdge 14, 15
	mEdge 14, 16
.faces
	db 14
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $2, $3
	fEdgeIdx $2, $1, $8
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $1, $0
	fEdgeIdx $3, $4, $5
	
	db $ea, $0, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $0, $2, $8
	fEdgeIdx $0, $3, $6, $1
	
	db $0, $0, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $3, $2
	fEdgeIdx $6, $5, $7, $8
	
	db $16, $0, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $9, $8, $3
	fEdgeIdx $7, $4, $0, $2
	
	db $0, $8, $e2 ;normal
	db 8 ;number of edges
	fEdgeGroup $f, $d, $10, $6, $5, $a, $4, $7
	fEdgeIdx $15, $17, $18, $14, $f, $a, $9, $d
	
	db $15, $f, $11 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $5, $b
	fEdgeIdx $b, $a, $e
	
	db $18, $f8, $12 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $b, $5, $6
	fEdgeIdx $11, $10, $e, $f
	
	db $19, $f7, $10 ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $c, $6, $10
	fEdgeIdx $1a, $13, $11, $14
	
	db $18, $f2, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $10, $d, $e
	fEdgeIdx $1a, $18, $16
	
	db $e7, $f4, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $e, $d
	fEdgeIdx $17, $19, $16
	
	db $e6, $f5, $d ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $f, $7, $c
	fEdgeIdx $13, $19, $15, $12
	
	db $e9, $f6, $11 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $4, $b, $c
	fEdgeIdx $12, $d, $c, $10
	
	db $eb, $f, $11 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $b, $4
	fEdgeIdx $9, $b, $c
	
M_FlowerTop: ;597D
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $0, $0
	db $0, $ec, $0
	db $a, $fa, $a
	db $f6, $fa, $a
	db $a, $fa, $f6
	db $f6, $fa, $f6

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
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $46, $e4, $0
	db $ba, $e4, $0
	db $0, $e4, $46
	db $0, $e4, $ba
	db vEND
.frame1
.frame6
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $3f, $d6, $0
	db $c1, $d6, $0
	db $0, $d6, $3f
	db $0, $d6, $c1
	db vEND
.frame2
.frame5
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $32, $c8, $0
	db $ce, $c8, $0
	db $0, $c8, $32
	db $0, $c8, $ce
	db vEND
.frame3
.frame4
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $25, $c0, $0
	db $db, $c0, $0
	db $0, $c0, $25
	db $0, $c0, $db
	db vEND
.faces
	db 9
	
	db $0, $e5, $f0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $0, $2
	fEdgeIdx $0, $1, $2
	
	db $f0, $e5, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $0, $4
	fEdgeIdx $1, $3, $4
	
	db $0, $e5, $10 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $0, $5
	fEdgeIdx $3, $5, $6
	
	db $10, $e5, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $0, $3
	fEdgeIdx $5, $0, $7
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $0
	fEdgeIdx $8, $8
	
	db $0, $e3, $f5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $3, $2
	fEdgeIdx $9, $2, $a
	
	db $f5, $e3, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $2, $4
	fEdgeIdx $b, $4, $c
	
	db $0, $e3, $b ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $4, $5
	fEdgeIdx $d, $6, $e
	
	db $b, $e3, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $5, $3
	fEdgeIdx $f, $7, $10
.edges
	db 17
	mEdge 3, 0
	mEdge 0, 2
	mEdge 2, 3
	mEdge 0, 4
	mEdge 4, 2
	mEdge 0, 5
	mEdge 5, 4
	mEdge 3, 5
	mEdge 0, 1
	mEdge 8, 3
	mEdge 2, 8
	mEdge 6, 2
	mEdge 4, 6
	mEdge 9, 4
	mEdge 5, 9
	mEdge 7, 5
	mEdge 3, 7
	
M_Spider2: ;5A63
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $e2, $0

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
	db 13 ;number of vertices in group
	db $a, $f4, $0
	db $5, $eb, $a
	db $5, $eb, $f6
	db $d, $e6, $0
	db $fd, $f0, $0
	db $14, $d8, $f7
	db $14, $d8, $c
	db $ec, $d4, $f9
	db $ec, $d8, $2
	db $28, $0, $ec
	db $28, $0, $19
	db $d8, $f9, $f2
	db $d8, $0, $6
	db vEND
.frame1
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $7, $f5, $0
	db $3, $ec, $a
	db $3, $ec, $f6
	db $c, $e8, $0
	db $fb, $ef, $0
	db $14, $d8, $f4
	db $14, $d8, $9
	db $ec, $d8, $fe
	db $ec, $d4, $6
	db $28, $0, $e7
	db $28, $0, $14
	db $d8, $0, $fa
	db $d8, $f9, $f
	db vEND
.frame2
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $0, $f6, $0
	db $0, $ec, $a
	db $0, $ec, $f6
	db $a, $ec, $0
	db $f6, $ec, $0
	db $14, $d8, $f2
	db $14, $d8, $7
	db $ec, $d8, $fc
	db $ec, $d4, $9
	db $28, $0, $e4
	db $28, $0, $f
	db $d8, $0, $f6
	db $d8, $f9, $15
	db vEND
.frame3
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $f9, $f5, $0
	db $fd, $ec, $a
	db $fd, $ec, $f6
	db $5, $ef, $0
	db $f4, $e8, $0
	db $14, $d4, $f7
	db $14, $d8, $4
	db $ec, $d8, $f9
	db $ec, $d8, $e
	db $28, $f9, $ee
	db $28, $0, $a
	db $d8, $0, $f1
	db $d8, $0, $1e
	db vEND
.frame4
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $f6, $f4, $0
	db $fb, $eb, $a
	db $fb, $eb, $f6
	db $3, $f0, $0
	db $f3, $e6, $0
	db $14, $d4, $fa
	db $14, $d8, $2
	db $ec, $d8, $f7
	db $ec, $d8, $c
	db $28, $f9, $f6
	db $28, $0, $7
	db $d8, $0, $ec
	db $d8, $0, $19
	db vEND
.frame5
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $f9, $f5, $0
	db $fd, $ec, $a
	db $fd, $ec, $f6
	db $5, $ef, $0
	db $f4, $e8, $0
	db $14, $d8, $0
	db $14, $d4, $7
	db $ec, $d8, $f4
	db $ec, $d8, $9
	db $28, $0, $0
	db $28, $f9, $12
	db $d8, $0, $e7
	db $d8, $0, $14
	db vEND
.frame6
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $0, $f6, $0
	db $0, $ec, $a
	db $0, $ec, $f6
	db $a, $ec, $0
	db $f6, $ec, $0
	db $14, $d8, $fe
	db $14, $d4, $a
	db $ec, $d8, $f2
	db $ec, $d8, $7
	db $28, $0, $fa
	db $28, $f9, $19
	db $d8, $0, $e4
	db $d8, $0, $f
	db vEND
.frame7
	db vNONSPECIAL
	db 13 ;number of vertices in group
	db $7, $f5, $0
	db $3, $ec, $a
	db $3, $ec, $f6
	db $c, $e8, $0
	db $fb, $ef, $0
	db $14, $d8, $fa
	db $14, $d8, $10
	db $ec, $d4, $f7
	db $ec, $d8, $4
	db $28, $0, $f4
	db $28, $0, $24
	db $d8, $f9, $ee
	db $d8, $0, $a
	db vEND
.faces
	db 16
	
	db $7, $e8, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $0
	fEdgeIdx $7, $0, $1
	
	db $e7, $fb, $11 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $5, $0
	fEdgeIdx $2, $3, $0
	
	db $e7, $fb, $ef ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $3, $0
	fEdgeIdx $4, $5, $3
	
	db $7, $e8, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $4, $0
	fEdgeIdx $6, $1, $5
	
	db $19, $5, $11 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $1
	fEdgeIdx $7, $8, $9
	
	db $f9, $18, $12 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $2, $1
	fEdgeIdx $2, $9, $a
	
	db $f9, $18, $ee ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $5, $1
	fEdgeIdx $4, $a, $b
	
	db $19, $5, $ef ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $3, $1
	fEdgeIdx $6, $b, $8
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $6, $0
	fEdgeIdx $c, $c
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $7, $0
	fEdgeIdx $d, $d
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $8, $0
	fEdgeIdx $e, $e
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $9, $0
	fEdgeIdx $f, $f
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $a, $0
	fEdgeIdx $10, $10
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $b, $0
	fEdgeIdx $11, $11
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $c, $0
	fEdgeIdx $12, $12
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $9, $d, $0
	fEdgeIdx $13, $13
.edges
	db 20
	mEdge 2, 0
	mEdge 0, 4
	mEdge 2, 5
	mEdge 5, 0
	mEdge 5, 3
	mEdge 3, 0
	mEdge 3, 4
	mEdge 2, 4
	mEdge 4, 1
	mEdge 1, 2
	mEdge 1, 5
	mEdge 1, 3
	mEdge 0, 6
	mEdge 0, 7
	mEdge 0, 8
	mEdge 0, 9
	mEdge 6, 10
	mEdge 7, 11
	mEdge 8, 12
	mEdge 9, 13
	
M_PlantAnim: ;5C93
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $0, $0

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
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $11, $ee, $23
	db $ef, $ee, $23
	db $11, $ee, $dd
	db $ef, $ee, $dd
	db $46, $f8, $0
	db $ba, $f8, $0
	db $23, $ee, $11
	db $dd, $ee, $11
	db $23, $ee, $ef
	db $dd, $ee, $ef
	db $0, $f8, $46
	db $0, $f8, $ba
	db vEND
.frame1
.frame6
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $11, $e9, $20
	db $ef, $e9, $20
	db $11, $e9, $e0
	db $ef, $e9, $e0
	db $41, $f8, $0
	db $bf, $f8, $0
	db $20, $e9, $11
	db $e0, $e9, $11
	db $20, $e9, $ef
	db $e0, $e9, $ef
	db $0, $f8, $41
	db $0, $f8, $bf
	db vEND
.frame2
.frame5
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $11, $e3, $1b
	db $ef, $e3, $1b
	db $11, $e3, $e5
	db $ef, $e3, $e5
	db $39, $f8, $0
	db $c7, $f8, $0
	db $1b, $e3, $11
	db $e5, $e3, $11
	db $1b, $e3, $ef
	db $e5, $e3, $ef
	db $0, $f8, $39
	db $0, $f8, $c7
	db vEND
.frame3
.frame4
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $11, $de, $16
	db $ef, $de, $16
	db $11, $de, $ea
	db $ef, $de, $ea
	db $2f, $f8, $0
	db $d1, $f8, $0
	db $16, $de, $11
	db $ea, $de, $11
	db $16, $de, $ef
	db $ea, $de, $ef
	db $0, $f8, $2f
	db $0, $f8, $d1
	db vEND
.faces
	db 8
	
	db $0, $e4, $f2 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $1, $2
	fEdgeIdx $0, $1, $2
	
	db $f2, $e4, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $9, $7
	fEdgeIdx $3, $4, $5
	
	db $0, $e4, $e ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $4, $3
	fEdgeIdx $6, $7, $8
	
	db $e, $e4, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $8, $a
	fEdgeIdx $9, $a, $b
	
	db $0, $e2, $8 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $2, $1
	fEdgeIdx $c, $1, $d
	
	db $8, $e2, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $7, $9
	fEdgeIdx $e, $4, $f
	
	db $0, $e2, $f8 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $3, $4
	fEdgeIdx $10, $7, $11
	
	db $f8, $e2, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $a, $8
	fEdgeIdx $12, $a, $13
.edges
	db 20
	mEdge 0, 1
	mEdge 1, 2
	mEdge 2, 0
	mEdge 0, 9
	mEdge 9, 7
	mEdge 7, 0
	mEdge 0, 4
	mEdge 4, 3
	mEdge 3, 0
	mEdge 0, 8
	mEdge 8, 10
	mEdge 10, 0
	mEdge 11, 2
	mEdge 1, 11
	mEdge 5, 7
	mEdge 9, 5
	mEdge 12, 3
	mEdge 4, 12
	mEdge 6, 10
	mEdge 8, 6
	
M_Mouse: ;5DC7
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $0, $3c
	db $0, $e2, $1e
	db $0, $d3, $ec
	db $0, $0, $d8
	db vNONSPECIAL | vMIRRORED
	db 2 ;number of vertices in group
	db $14, $0, $1e
	db $1e, $0, $d8

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
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $c3, $ba
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $1d, $d9, $26
	db vEND
.frame1
.frame6
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $bf, $c4
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $19, $d8, $1c
	db vEND
.frame2
.frame5
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $bd, $cf
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $17, $db, $12
	db vEND
.frame3
.frame4
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $bc, $db
	db vNONSPECIAL | vMIRRORED
	db 1 ;number of vertices in group
	db $14, $df, $a
	db vEND
.faces
	db 8
	
	db $17, $f1, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $1, $4
	fEdgeIdx $3, $0, $1
	
	db $e9, $f1, $f ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $1, $0
	fEdgeIdx $2, $3, $4
	
	db $1a, $ef, $3 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $4, $1, $2
	fEdgeIdx $5, $0, $6, $7
	
	db $e5, $f0, $3 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $7, $2, $1
	fEdgeIdx $8, $9, $6, $2
	
	db $0, $f3, $e3 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $2, $7
	fEdgeIdx $7, $9, $a
	
	db $f9, $4, $1e ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $1, $9
	fEdgeIdx $0, $b, $c
	
	db $7, $4, $1e ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $1, $5
	fEdgeIdx $d, $2, $e
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $8, $0
	fEdgeIdx $f, $f
.edges
	db 16
	mEdge 1, 4
	mEdge 4, 0
	mEdge 5, 1
	mEdge 1, 0
	mEdge 0, 5
	mEdge 6, 4
	mEdge 1, 2
	mEdge 2, 6
	mEdge 5, 7
	mEdge 7, 2
	mEdge 7, 6
	mEdge 1, 9
	mEdge 9, 4
	mEdge 10, 1
	mEdge 5, 10
	mEdge 3, 8
	
M_FlatSlug: ;5E97
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 12 ;number of vertices in group
	db $ce, $0, $4b
	db $e7, $da, $58
	db $e7, $f3, $f3
	db $e7, $f3, $4b
	db $e7, $0, $ce
	db $e7, $0, $58
	db $19, $da, $58
	db $19, $f3, $f3
	db $19, $f3, $4b
	db $19, $0, $ce
	db $19, $0, $58
	db $32, $0, $4b
	db vEND
.edges
	db 18
	mEdge 0, 4
	mEdge 0, 5
	mEdge 1, 3
	mEdge 2, 3
	mEdge 2, 4
	mEdge 2, 7
	mEdge 3, 5
	mEdge 3, 8
	mEdge 4, 5
	mEdge 4, 9
	mEdge 5, 10
	mEdge 6, 8
	mEdge 7, 8
	mEdge 7, 9
	mEdge 8, 10
	mEdge 9, 10
	mEdge 9, 11
	mEdge 10, 11
.faces
	db 10
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $3, $2, $7
	fEdgeIdx $c, $7, $3, $5
	
	db $0, $1d, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $7, $2, $4
	fEdgeIdx $9, $d, $5, $4
	
	db $1f, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $5, $4, $2
	fEdgeIdx $3, $6, $8, $4
	
	db $0, $16, $ea ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $a, $5, $3
	fEdgeIdx $7, $e, $a, $6
	
	db $e1, $0, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $8, $7, $9
	fEdgeIdx $f, $e, $c, $d
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $4, $5, $a
	fEdgeIdx $f, $9, $8, $a
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $a, $9
	fEdgeIdx $10, $11, $f
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $5
	fEdgeIdx $1, $0, $8
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $6, $0
	fEdgeIdx $b, $b
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $1, $0
	fEdgeIdx $2, $2
	
M_PlantedDiamond: ;5F59
	db 3 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $14, $d8, $ec
	db $ec, $d8, $14
	db $a, $f6, $f6
	db $f6, $f6, $a
	db $f1, $0, $f1
	db $f1, $0, $f
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $88, $0
	db vEND
.edges
	db 24
	mEdge 12, 0
	mEdge 12, 1
	mEdge 12, 2
	mEdge 12, 3
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 4
	mEdge 1, 2
	mEdge 1, 5
	mEdge 2, 3
	mEdge 2, 6
	mEdge 3, 7
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
	db 13
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $2, $1, $0
	fEdgeIdx $5, $9, $7, $4
	
	db $1e, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $1, $2, $6
	fEdgeIdx $f, $8, $7, $a
	
	db $1c, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $8, $5
	fEdgeIdx $f, $12, $14, $10
	
	db $0, $f6, $e2 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $2, $3, $7
	fEdgeIdx $11, $a, $9, $b
	
	db $0, $e, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $b, $a, $6
	fEdgeIdx $11, $13, $16, $12
	
	db $0, $e, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $8, $9, $4
	fEdgeIdx $c, $10, $15, $e
	
	db $0, $f6, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $0, $1, $5
	fEdgeIdx $c, $6, $4, $8
	
	db $e4, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $9, $b, $7
	fEdgeIdx $d, $e, $17, $13
	
	db $e2, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $3, $0, $4
	fEdgeIdx $d, $b, $5, $6
	
	db $1e, $7, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $1, $c
	fEdgeIdx $2, $7, $1
	
	db $0, $7, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $c
	fEdgeIdx $1, $4, $0
	
	db $e2, $7, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $c
	fEdgeIdx $0, $5, $3
	
	db $0, $7, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $c
	fEdgeIdx $3, $9, $2
	
M_PlantedHalfDiamond: ;6040
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $28, $b0, $d8
	db $d8, $b0, $28
	db $14, $ec, $ec
	db $ec, $ec, $14
	db $e2, $0, $e2
	db $e2, $0, $1e
	db vEND
.edges
	db 20
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 4
	mEdge 1, 2
	mEdge 1, 5
	mEdge 2, 3
	mEdge 2, 6
	mEdge 3, 7
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
	db 9
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $2, $1, $0
	fEdgeIdx $1, $5, $3, $0
	
	db $1e, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $1, $2, $6
	fEdgeIdx $b, $4, $3, $6
	
	db $1c, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $8, $5
	fEdgeIdx $b, $e, $10, $c
	
	db $0, $f6, $e2 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $2, $3, $7
	fEdgeIdx $d, $6, $5, $7
	
	db $0, $e, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $b, $a, $6
	fEdgeIdx $d, $f, $12, $e
	
	db $0, $e, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $8, $9, $4
	fEdgeIdx $8, $c, $11, $a
	
	db $0, $f6, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $0, $1, $5
	fEdgeIdx $8, $2, $0, $4
	
	db $e4, $e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $9, $b, $7
	fEdgeIdx $9, $a, $13, $f
	
	db $e2, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $3, $0, $4
	fEdgeIdx $9, $7, $1, $2
	
M_HexPrism: ;60F2
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $28, $df, $0
	db $28, $df, $ec
	db $14, $1, $0
	db $14, $1, $ec
	db $ec, $bc, $0
	db $ec, $bc, $ec
	db vEND
.edges
	db 18
	mEdge 0, 2
	mEdge 0, 4
	mEdge 0, 9
	mEdge 2, 6
	mEdge 2, 11
	mEdge 4, 6
	mEdge 4, 5
	mEdge 6, 7
	mEdge 5, 7
	mEdge 5, 1
	mEdge 7, 3
	mEdge 1, 3
	mEdge 1, 8
	mEdge 3, 10
	mEdge 8, 10
	mEdge 8, 9
	mEdge 10, 11
	mEdge 9, 11
.faces
	db 8
	
	db $0, $0, $1f ;normal
	db 6 ;number of edges
	fEdgeGroup $6, $2, $b, $a, $3, $7
	fEdgeIdx $7, $3, $4, $10, $d, $a
	
	db $0, $0, $e1 ;normal
	db 6 ;number of edges
	fEdgeGroup $5, $1, $8, $9, $0, $4
	fEdgeIdx $6, $9, $c, $f, $2, $1
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $9, $8, $a
	fEdgeIdx $10, $11, $f, $e
	
	db $e5, $f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $0, $9, $b
	fEdgeIdx $4, $0, $2, $11
	
	db $e5, $f1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $4, $0, $2
	fEdgeIdx $3, $5, $1, $0
	
	db $0, $e1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $5, $4, $6
	fEdgeIdx $7, $8, $6, $5
	
	db $1b, $f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $8, $1, $3
	fEdgeIdx $d, $e, $c, $b
	
	db $1b, $f1, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $1, $5, $7
	fEdgeIdx $a, $b, $9, $8
	
M_Pillar: ;619C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $7, $0, $f4
	db $7, $88, $f4
	db $f1, $0, $0
	db $f1, $88, $0
	db $f9, $0, $c
	db $f9, $88, $c
	db vEND
.edges
	db 18
	mEdge 0, 2
	mEdge 0, 1
	mEdge 0, 5
	mEdge 2, 3
	mEdge 2, 7
	mEdge 1, 3
	mEdge 1, 4
	mEdge 3, 6
	mEdge 4, 6
	mEdge 4, 8
	mEdge 6, 10
	mEdge 8, 10
	mEdge 8, 9
	mEdge 10, 11
	mEdge 9, 11
	mEdge 9, 5
	mEdge 11, 7
	mEdge 5, 7
.faces
	db 8
	
	db $0, $1f, $0 ;normal
	db 6 ;number of edges
	fEdgeGroup $8, $4, $1, $0, $5, $9
	fEdgeIdx $c, $9, $6, $1, $2, $f
	
	db $0, $1f, $0 ;normal
	db 6 ;number of edges
	fEdgeGroup $a, $6, $3, $2, $7, $b
	fEdgeIdx $d, $a, $7, $3, $4, $10
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $9, $8
	fEdgeIdx $b, $d, $e, $c
	
	db $e5, $0, $f1 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $7, $5, $9
	fEdgeIdx $e, $10, $11, $f
	
	db $1b, $0, $f1 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $a, $8, $4
	fEdgeIdx $8, $a, $b, $9
	
	db $e5, $0, $f ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $2, $0, $5
	fEdgeIdx $11, $4, $0, $2
	
	db $0, $0, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $0, $2, $3
	fEdgeIdx $5, $1, $0, $3
	
	db $1b, $0, $f ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $1, $3, $6
	fEdgeIdx $8, $6, $5, $7
	
M_Spike: ;6246 (unused?)
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $e8, $92, $a
	db $f6, $88, $a
	db $f2, $92, $28
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $92, $ec
	db $0, $0, $a
	db vEND
.edges
	db 17
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 4
	mEdge 0, 6
	mEdge 0, 7
	mEdge 1, 3
	mEdge 1, 5
	mEdge 1, 6
	mEdge 1, 7
	mEdge 2, 3
	mEdge 2, 4
	mEdge 2, 6
	mEdge 3, 5
	mEdge 3, 6
	mEdge 4, 5
	mEdge 4, 7
	mEdge 5, 7
.faces
	db 10
	
	db $0, $1e, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $6
	fEdgeIdx $d, $9, $b
	
	db $0, $1e, $f6 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $2, $3
	fEdgeIdx $c, $e, $a, $9
	
	db $10, $17, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $0, $6
	fEdgeIdx $b, $1, $3
	
	db $f0, $17, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $6, $1
	fEdgeIdx $5, $d, $7
	
	db $ee, $19, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $5, $3
	fEdgeIdx $5, $6, $c
	
	db $12, $19, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $4
	fEdgeIdx $2, $1, $a
	
	db $0, $f8, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $4
	fEdgeIdx $e, $10, $f
	
	db $1d, $fa, $f7 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $4, $7
	fEdgeIdx $4, $2, $f
	
	db $e3, $fa, $f7 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $7, $5
	fEdgeIdx $6, $8, $10
	
	db $0, $0, $1f ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $7
	fEdgeIdx $8, $0, $4
	
M_RadarDish: ;62EB
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $d8, $d8, $a
	db $0, $c4, $a
	db $0, $d8, $0
	db $0, $ec, $a
	db $0, $0, $0
	db $28, $d8, $a
	db vEND
.edges
	db 9
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 3
	mEdge 1, 2
	mEdge 1, 5
	mEdge 2, 3
	mEdge 2, 4
	mEdge 2, 5
	mEdge 3, 5
.faces
	db 5
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $2, $0
	fEdgeIdx $6, $6
	
	db $6, $f3, $e5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $1, $5
	fEdgeIdx $7, $3, $4
	
	db $fa, $f3, $e5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $0, $1
	fEdgeIdx $3, $1, $0
	
	db $fa, $d, $e5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $3, $0
	fEdgeIdx $1, $5, $2
	
	db $6, $d, $e5 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $5, $3
	fEdgeIdx $5, $7, $8
	
M_unknown: ;634C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $fe, $fe, $d8
	db $f6, $f6, $f6
	db $f6, $0, $b0
	db $d8, $0, $92
	db $ce, $0, $ec
	db $ec, $0, $e2
	db $fb, $0, $d3
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $0, $0, $92
	db $0, $fb, $d3
	db $0, $0, $e2
	db vEND
.edges
	db 21
	mEdge 0, 2
	mEdge 1, 3
	mEdge 4, 6
	mEdge 4, 12
	mEdge 6, 8
	mEdge 8, 10
	mEdge 10, 12
	mEdge 11, 9
	mEdge 11, 13
	mEdge 5, 7
	mEdge 5, 13
	mEdge 7, 9
	mEdge 14, 15
	mEdge 14, 12
	mEdge 14, 13
	mEdge 15, 12
	mEdge 15, 13
	mEdge 15, 16
	mEdge 12, 13
	mEdge 12, 16
	mEdge 13, 16
.faces
	db 10
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $0
	fEdgeIdx $0, $0
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $3, $0
	fEdgeIdx $1, $1
	
	db $0, $1f, $0 ;normal
	db 5 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $8, $6, $4, $c
	fEdgeIdx $6, $5, $4, $2, $3
	
	db $0, $1f, $0 ;normal
	db 5 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $7, $9, $b, $d
	fEdgeIdx $a, $9, $b, $7, $8
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $d, $e
	fEdgeIdx $d, $12, $e
	
	db $16, $16, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $c, $e
	fEdgeIdx $c, $f, $d
	
	db $ea, $16, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $f, $e
	fEdgeIdx $e, $10, $c
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $c, $10
	fEdgeIdx $14, $12, $13
	
	db $15, $15, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $10, $c
	fEdgeIdx $f, $11, $13
	
	db $eb, $15, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $d, $10
	fEdgeIdx $11, $10, $14
	
M_SpikeSpinner: ;640C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $50, $ce, $0
	db $14, $d8, $ec
	db $ec, $d8, $14
	db $ec, $c4, $ec
	db $ec, $c4, $14
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $0, $ce, $b0
	db $0, $ce, $50
	db $0, $0, $0
	db vEND
.edges
	db 28
	mEdge 12, 2
	mEdge 12, 3
	mEdge 12, 4
	mEdge 12, 5
	mEdge 0, 2
	mEdge 0, 5
	mEdge 0, 9
	mEdge 0, 7
	mEdge 1, 3
	mEdge 1, 4
	mEdge 1, 6
	mEdge 1, 8
	mEdge 10, 2
	mEdge 10, 3
	mEdge 10, 6
	mEdge 10, 7
	mEdge 11, 4
	mEdge 11, 5
	mEdge 11, 8
	mEdge 11, 9
	mEdge 2, 3
	mEdge 2, 5
	mEdge 2, 7
	mEdge 3, 4
	mEdge 3, 6
	mEdge 4, 5
	mEdge 4, 8
	mEdge 5, 9
.faces
	db 17
	
	db $1e, $0, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $b, $4
	fEdgeIdx $1a, $12, $10
	
	db $1e, $0, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $3, $a
	fEdgeIdx $e, $18, $d
	
	db $a, $0, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $1, $3
	fEdgeIdx $18, $a, $8
	
	db $a, $0, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $4, $1
	fEdgeIdx $b, $1a, $9
	
	db $5, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $1, $4
	fEdgeIdx $17, $8, $9
	
	db $e2, $0, $f6 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $5, $b
	fEdgeIdx $13, $1b, $11
	
	db $0, $e1, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $b, $5
	fEdgeIdx $19, $10, $11
	
	db $1c, $f2, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $4, $c
	fEdgeIdx $1, $17, $2
	
	db $0, $f2, $e4 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $5, $c
	fEdgeIdx $2, $19, $3
	
	db $e4, $f2, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $2, $c
	fEdgeIdx $3, $15, $0
	
	db $0, $f2, $1c ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $3, $c
	fEdgeIdx $0, $14, $1
	
	db $e2, $0, $a ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $a, $2
	fEdgeIdx $16, $f, $c
	
	db $fb, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $0, $2
	fEdgeIdx $15, $5, $4
	
	db $f6, $0, $e2 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $0, $5
	fEdgeIdx $1b, $6, $5
	
	db $f6, $0, $1e ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $2, $0
	fEdgeIdx $7, $16, $4
	
	db $0, $e1, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $a
	fEdgeIdx $d, $14, $c
	
	db $5, $1f, $0 ;normal
	db 8 ;number of edges
	fEdgeGroup $8, $1, $6, $a, $7, $0, $9, $b
	fEdgeIdx $12, $b, $a, $e, $f, $7, $6, $13
	
M_WaterStrider: ;651E
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $28, $0, $0
	db $14, $0, $22
	db $ec, $0, $de
	db $50, $3c, $0
	db $28, $3c, $bb
	db $d8, $3c, $45
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $d8, $0
	db vEND
.edges
	db 18
	mEdge 0, 2
	mEdge 0, 5
	mEdge 0, 6
	mEdge 0, 12
	mEdge 2, 3
	mEdge 2, 12
	mEdge 2, 11
	mEdge 4, 5
	mEdge 4, 1
	mEdge 4, 9
	mEdge 4, 12
	mEdge 5, 8
	mEdge 5, 12
	mEdge 1, 3
	mEdge 1, 7
	mEdge 1, 12
	mEdge 3, 10
	mEdge 3, 12
.faces
	db 13
	
	db $ec, $14, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $c, $5
	fEdgeIdx $1, $3, $c
	
	db $0, $14, $18 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $c, $4
	fEdgeIdx $7, $c, $a
	
	db $14, $14, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $4, $c
	fEdgeIdx $f, $8, $a
	
	db $14, $14, $f4 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $c, $3
	fEdgeIdx $d, $f, $11
	
	db $0, $14, $e8 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $c, $2
	fEdgeIdx $4, $11, $5
	
	db $ec, $14, $f4 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $c
	fEdgeIdx $3, $0, $5
	
	db $0, $e1, $0 ;normal
	db 6 ;number of edges
	fEdgeGroup $5, $4, $1, $3, $2, $0
	fEdgeIdx $1, $7, $8, $d, $4, $0
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $b, $0
	fEdgeIdx $6, $6
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $6, $0
	fEdgeIdx $2, $2
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $8, $0
	fEdgeIdx $b, $b
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $9, $0
	fEdgeIdx $9, $9
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $7, $0
	fEdgeIdx $e, $e
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $a, $0
	fEdgeIdx $10, $10
	
M_Jet: ;65E7
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 6 ;number of vertices in group
	db $b5, $0, $db
	db $b5, $0, $c2
	db $b5, $0, $b5
	db $19, $f8, $ce
	db $5, $f1, $a6
	db $a, $f1, $fb
	db vNONSPECIAL
	db 6 ;number of vertices in group
	db $0, $ce, $9c
	db $0, $ea, $c8
	db $0, $f6, $fb
	db $0, $ec, $ab
	db $0, $e7, $0
	db $0, $0, $4b
	db vEND
.edges
	db 31
	mEdge 0, 2
	mEdge 2, 4
	mEdge 2, 7
	mEdge 4, 9
	mEdge 1, 3
	mEdge 5, 3
	mEdge 5, 8
	mEdge 3, 6
	mEdge 6, 8
	mEdge 6, 10
	mEdge 7, 9
	mEdge 7, 11
	mEdge 12, 13
	mEdge 12, 15
	mEdge 13, 15
	mEdge 14, 8
	mEdge 14, 9
	mEdge 14, 10
	mEdge 14, 11
	mEdge 14, 17
	mEdge 8, 9
	mEdge 8, 10
	mEdge 8, 15
	mEdge 9, 11
	mEdge 9, 15
	mEdge 10, 16
	mEdge 10, 17
	mEdge 11, 16
	mEdge 11, 17
	mEdge 15, 16
	mEdge 16, 17
.faces
	db 17
	
	db $e9, $14, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $10, $a, $11
	fEdgeIdx $1e, $19, $1a
	
	db $17, $14, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $10, $11, $b
	fEdgeIdx $1b, $1e, $1c
	
	db $ea, $16, $1 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $10, $f, $8
	fEdgeIdx $15, $19, $1d, $16
	
	db $16, $16, $1 ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $b, $9, $f
	fEdgeIdx $1d, $1b, $17, $18
	
	db $0, $16, $16 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $9, $8
	fEdgeIdx $16, $18, $14
	
	db $f2, $e4, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $11, $a
	fEdgeIdx $11, $13, $1a
	
	db $f2, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $8, $e
	fEdgeIdx $11, $15, $f
	
	db $e, $e4, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $e, $9
	fEdgeIdx $17, $12, $10
	
	db $0, $e1, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $9, $e
	fEdgeIdx $f, $14, $10
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $0
	fEdgeIdx $0, $0
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $3, $0
	fEdgeIdx $4, $4
	
	db $e, $e4, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $b, $11
	fEdgeIdx $13, $12, $1c
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $f, $d, $c
	fEdgeIdx $d, $e, $c
	
	db $fa, $1f, $fe ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $8, $5, $3
	fEdgeIdx $7, $8, $6, $5
	
	db $f4, $1d, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $a, $8
	fEdgeIdx $8, $9, $15
	
	db $6, $1f, $0 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $4, $9, $7
	fEdgeIdx $2, $1, $3, $a
	
	db $c, $1d, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $9, $b
	fEdgeIdx $b, $a, $17
	
M_unknown2: ;6707
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $ba, $f2, $e
	db $1c, $e4, $ac
	db $e, $f2, $0
	db vNONSPECIAL
	db 3 ;number of vertices in group
	db $0, $f2, $cf
	db $0, $e4, $e
	db $0, $0, $54
	db vEND
.edges
	db 15
	mEdge 0, 6
	mEdge 0, 5
	mEdge 1, 6
	mEdge 1, 4
	mEdge 2, 3
	mEdge 2, 6
	mEdge 3, 6
	mEdge 6, 4
	mEdge 6, 5
	mEdge 6, 7
	mEdge 4, 7
	mEdge 4, 8
	mEdge 5, 7
	mEdge 5, 8
	mEdge 7, 8
.faces
	db 11
	
	db $0, $1d, $f5 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $3, $2
	fEdgeIdx $5, $6, $4
	
	db $19, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $8, $5
	fEdgeIdx $c, $e, $d
	
	db $13, $18, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $6, $7
	fEdgeIdx $c, $8, $9
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $0, $6
	fEdgeIdx $8, $1, $0
	
	db $0, $e3, $b ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $2, $3
	fEdgeIdx $6, $5, $4
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $6, $0
	fEdgeIdx $1, $8, $0
	
	db $e7, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $4, $8
	fEdgeIdx $e, $a, $b
	
	db $ed, $18, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $7, $6
	fEdgeIdx $7, $a, $9
	
	db $0, $1f, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $6, $1
	fEdgeIdx $3, $7, $2
	
	db $0, $e1, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $1, $6
	fEdgeIdx $7, $3, $2
	
	db $0, $e1, $5 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $8, $4, $6
	fEdgeIdx $8, $d, $b, $7
	
M_unknown3: ;67B5
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $e0, $f0, $f4
	db $10, $f0, $b4
	db $8, $f8, $fc
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $0, $f4, $c4
	db $c4, $f8, $c4
	db $de, $ec, $a
	db $3c, $fc, $c4
	db $1e, $ec, $a
	db $0, $f8, $d8
	db $0, $f0, $8
	db $0, $0, $34
	db vEND
.edges
	db 22
	mEdge 6, 2
	mEdge 6, 3
	mEdge 7, 0
	mEdge 7, 8
	mEdge 0, 8
	mEdge 0, 11
	mEdge 8, 5
	mEdge 9, 1
	mEdge 9, 10
	mEdge 1, 10
	mEdge 1, 11
	mEdge 10, 4
	mEdge 2, 11
	mEdge 3, 11
	mEdge 11, 12
	mEdge 11, 4
	mEdge 11, 5
	mEdge 12, 4
	mEdge 12, 5
	mEdge 12, 13
	mEdge 4, 13
	mEdge 5, 13
.faces
	db 15
	
	db $0, $e2, $6 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $b, $2, $6
	fEdgeIdx $1, $d, $c, $0
	
	db $0, $1e, $fa ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $b, $3, $6
	fEdgeIdx $0, $c, $d, $1
	
	db $0, $e1, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $7, $8
	fEdgeIdx $4, $2, $3
	
	db $4, $e1, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $a, $9
	fEdgeIdx $7, $9, $8
	
	db $9, $e2, $2 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $b, $0, $8
	fEdgeIdx $6, $10, $5, $4
	
	db $f7, $e2, $2 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $b, $4, $a
	fEdgeIdx $9, $a, $f, $b
	
	db $0, $e1, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $d, $4, $b
	fEdgeIdx $10, $15, $14, $f
	
	db $f7, $1e, $fe ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $b, $5, $8
	fEdgeIdx $4, $5, $10, $6
	
	db $0, $1f, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $8, $7
	fEdgeIdx $2, $4, $3
	
	db $9, $1e, $fe ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $b, $1, $a
	fEdgeIdx $b, $f, $a, $9
	
	db $fc, $1f, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $9, $a
	fEdgeIdx $9, $7, $8
	
	db $12, $19, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $b, $c
	fEdgeIdx $12, $10, $e
	
	db $1a, $10, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $d, $5
	fEdgeIdx $12, $13, $15
	
	db $ee, $19, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $c, $b
	fEdgeIdx $f, $11, $e
	
	db $e6, $10, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $4, $d
	fEdgeIdx $13, $11, $14
	
M_Dino: ;68B4
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $7, $f2, $36
	db $38, $0, $b9
	db $15, $f9, $c7
	db $7, $0, $36
	db $f2, $f2, $d5
	db vNONSPECIAL
	db 5 ;number of vertices in group
	db $0, $f9, $60
	db $0, $eb, $3d
	db $0, $f2, $21
	db $0, $e4, $f1
	db $0, $f9, $28
	db vEND
.edges
	db 29
	mEdge 10, 0
	mEdge 10, 1
	mEdge 10, 11
	mEdge 0, 1
	mEdge 0, 6
	mEdge 0, 11
	mEdge 0, 12
	mEdge 1, 7
	mEdge 1, 11
	mEdge 1, 12
	mEdge 2, 4
	mEdge 2, 6
	mEdge 4, 6
	mEdge 4, 5
	mEdge 4, 9
	mEdge 6, 7
	mEdge 6, 14
	mEdge 5, 3
	mEdge 5, 7
	mEdge 5, 8
	mEdge 3, 7
	mEdge 7, 14
	mEdge 11, 12
	mEdge 11, 13
	mEdge 12, 13
	mEdge 12, 14
	mEdge 8, 14
	mEdge 8, 9
	mEdge 14, 9
.faces
	db 14
	
	db $e7, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $0, $a
	fEdgeIdx $2, $5, $0
	
	db $19, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $a, $1
	fEdgeIdx $8, $2, $1
	
	db $ee, $18, $6 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $b, $c
	fEdgeIdx $6, $5, $16
	
	db $12, $18, $6 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $c, $b
	fEdgeIdx $8, $9, $16
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $0, $6, $7
	fEdgeIdx $7, $3, $4, $f
	
	db $0, $1c, $e ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $5, $4, $9
	fEdgeIdx $1b, $13, $d, $e
	
	db $e6, $11, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $4, $6, $e
	fEdgeIdx $1c, $e, $c, $10
	
	db $12, $19, $fd ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $7, $5, $8
	fEdgeIdx $1a, $15, $12, $13
	
	db $e2, $0, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $0, $c, $e
	fEdgeIdx $10, $4, $6, $19
	
	db $1c, $f7, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $c, $1, $7
	fEdgeIdx $15, $19, $9, $7
	
	db $f9, $1e, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $2, $6
	fEdgeIdx $c, $a, $b
	
	db $7, $1e, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $3
	fEdgeIdx $11, $12, $14
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $b, $d
	fEdgeIdx $18, $16, $17
	
	db $0, $1f, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $e, $8
	fEdgeIdx $1b, $1c, $1a
	
M_SuperTank: ;69B2
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 8 ;number of vertices in group
	db $f4, $d9, $4f
	db $f4, $d9, $0
	db $dc, $f7, $b8
	db $d3, $0, $af
	db $24, $0, $5a
	db $1b, $e5, $ee
	db $24, $d3, $d3
	db $12, $e2, $36
	db vEND
.edges
	db 24
	mEdge 0, 2
	mEdge 1, 3
	mEdge 4, 5
	mEdge 4, 6
	mEdge 4, 9
	mEdge 4, 11
	mEdge 5, 7
	mEdge 5, 8
	mEdge 5, 10
	mEdge 6, 7
	mEdge 6, 9
	mEdge 7, 8
	mEdge 8, 9
	mEdge 8, 10
	mEdge 9, 11
	mEdge 10, 11
	mEdge 10, 12
	mEdge 10, 14
	mEdge 11, 13
	mEdge 11, 15
	mEdge 12, 13
	mEdge 12, 14
	mEdge 13, 15
	mEdge 14, 15
.faces
	db 14
	
	db $0, $1f, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $c, $e, $f
	fEdgeIdx $16, $14, $15, $17
	
	db $0, $e6, $11 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $c, $d, $b
	fEdgeIdx $f, $10, $14, $12
	
	db $e2, $f8, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $e, $c
	fEdgeIdx $10, $11, $15
	
	db $1e, $f8, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $d, $f
	fEdgeIdx $13, $12, $16
	
	db $0, $1e, $f9 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $a, $8, $9
	fEdgeIdx $e, $f, $d, $c
	
	db $0, $e1, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $b, $f, $e
	fEdgeIdx $11, $f, $13, $17
	
	db $0, $16, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $6, $7, $5
	fEdgeIdx $2, $3, $9, $6
	
	db $e3, $c, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $5, $8
	fEdgeIdx $d, $8, $7
	
	db $e9, $15, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $8
	fEdgeIdx $7, $6, $b
	
	db $0, $1e, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $4, $5, $a
	fEdgeIdx $f, $5, $2, $8
	
	db $1d, $c, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $9, $4
	fEdgeIdx $5, $e, $4
	
	db $17, $15, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $9, $6
	fEdgeIdx $3, $4, $a
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $3, $0
	fEdgeIdx $1, $1
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $0
	fEdgeIdx $0, $0
	
M_ArmorTank: ;6A9C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $7, $df, $4b
	db $7, $df, $18
	db $f, $d6, $6
	db $2d, $0, $a6
	db $1e, $eb, $b4
	db $db, $0, $2d
	db $16, $eb, $33
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $1e, $d3, $97
	db $0, $0, $5a
	db vEND
.edges
	db 23
	mEdge 0, 2
	mEdge 4, 5
	mEdge 4, 8
	mEdge 4, 12
	mEdge 1, 3
	mEdge 14, 8
	mEdge 5, 9
	mEdge 5, 13
	mEdge 6, 7
	mEdge 6, 8
	mEdge 6, 11
	mEdge 7, 9
	mEdge 7, 10
	mEdge 8, 9
	mEdge 8, 12
	mEdge 9, 13
	mEdge 10, 13
	mEdge 10, 15
	mEdge 11, 12
	mEdge 11, 15
	mEdge 12, 13
	mEdge 12, 15
	mEdge 13, 15
.faces
	db 13
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $e, $0
	fEdgeIdx $5, $5
	
	db $1a, $12, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $a, $7, $9
	fEdgeIdx $f, $10, $c, $b
	
	db $1c, $d, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $d, $9
	fEdgeIdx $6, $7, $f
	
	db $0, $11, $1a ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $7, $6, $8
	fEdgeIdx $d, $b, $8, $9
	
	db $e6, $12, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $c, $8, $6
	fEdgeIdx $a, $12, $e, $9
	
	db $e4, $d, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $8, $c
	fEdgeIdx $3, $2, $e
	
	db $0, $1e, $7 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $8, $4, $5
	fEdgeIdx $6, $d, $2, $1
	
	db $0, $1c, $f3 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $4, $c, $d
	fEdgeIdx $7, $1, $3, $14
	
	db $16, $a, $ed ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $f, $a
	fEdgeIdx $10, $16, $11
	
	db $ea, $a, $ed ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $b, $f
	fEdgeIdx $15, $12, $13
	
	db $0, $1b, $f1 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $c, $f
	fEdgeIdx $16, $14, $15
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $0, $2, $0
	fEdgeIdx $0, $0
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $1, $3, $0
	fEdgeIdx $4, $4
	
M_MobileTurret: ;6B7C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 8 ;number of vertices in group
	db $e8, $fa, $c4
	db $8, $ee, $0
	db $8, $ee, $3c
	db $e2, $fa, $ee
	db $f4, $f4, $fa
	db $c, $f4, $dc
	db $7, $0, $30
	db $6, $e8, $0
	db vEND
.edges
	db 23
	mEdge 0, 6
	mEdge 0, 11
	mEdge 2, 4
	mEdge 5, 3
	mEdge 1, 7
	mEdge 1, 10
	mEdge 6, 8
	mEdge 6, 13
	mEdge 8, 11
	mEdge 8, 15
	mEdge 8, 13
	mEdge 7, 9
	mEdge 7, 12
	mEdge 9, 10
	mEdge 9, 12
	mEdge 9, 14
	mEdge 10, 11
	mEdge 10, 14
	mEdge 11, 15
	mEdge 12, 14
	mEdge 12, 13
	mEdge 14, 15
	mEdge 15, 13
.faces
	db 12
	
	db $0, $1c, $f2 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $d, $f, $e
	fEdgeIdx $13, $14, $16, $15
	
	db $e4, $b, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $9, $c
	fEdgeIdx $13, $f, $e
	
	db $1c, $b, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $d, $8
	fEdgeIdx $9, $16, $a
	
	db $0, $1e, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $f, $b, $a
	fEdgeIdx $11, $15, $12, $10
	
	db $e4, $e, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $e, $a
	fEdgeIdx $d, $f, $11
	
	db $f6, $1e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $9, $a, $1
	fEdgeIdx $4, $b, $d, $5
	
	db $1c, $e, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $b, $f
	fEdgeIdx $9, $8, $12
	
	db $a, $1e, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $8, $6, $0
	fEdgeIdx $1, $8, $6, $0
	
	db $f2, $1b, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $7, $c
	fEdgeIdx $e, $b, $c
	
	db $e, $1b, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $d, $6
	fEdgeIdx $6, $a, $7
	
	db $11, $0, $d8 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $2, $0
	fEdgeIdx $2, $2
	
	db $39, $23, $b0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $3, $0
	fEdgeIdx $3, $3
	
M_PointyTank: ;6C4C
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 3 ;number of vertices in group
	db $a, $e4, $24
	db $d0, $f4, $1a
	db $d8, $f4, $aa
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $0, $da, $5e
	db $0, $da, $12
	db $28, $d0, $9c
	db $0, $d2, $2
	db $0, $0, $c4
	db $0, $0, $24
	db $0, $f4, $78
	db $0, $e4, $d0
	db vEND
.edges
	db 27
	mEdge 6, 7
	mEdge 8, 5
	mEdge 9, 0
	mEdge 9, 1
	mEdge 9, 13
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 12
	mEdge 0, 13
	mEdge 1, 2
	mEdge 1, 12
	mEdge 1, 13
	mEdge 2, 11
	mEdge 2, 12
	mEdge 2, 4
	mEdge 2, 13
	mEdge 10, 11
	mEdge 10, 4
	mEdge 10, 5
	mEdge 11, 3
	mEdge 11, 12
	mEdge 3, 12
	mEdge 3, 13
	mEdge 3, 5
	mEdge 4, 13
	mEdge 4, 5
	mEdge 13, 5
.faces
	db 18
	
	db $3c, $d3, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $8, $0
	fEdgeIdx $1, $1
	
	db $8, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $4, $2, $b
	fEdgeIdx $10, $11, $e, $c
	
	db $f9, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $3, $5, $a
	fEdgeIdx $10, $13, $17, $12
	
	db $0, $e4, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $5, $4
	fEdgeIdx $11, $12, $19
	
	db $0, $1d, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $4, $5
	fEdgeIdx $1a, $18, $19
	
	db $b, $1d, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $2, $4
	fEdgeIdx $18, $f, $e
	
	db $b, $1d, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $2, $d
	fEdgeIdx $b, $9, $f
	
	db $f5, $1d, $1 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $d, $3
	fEdgeIdx $6, $8, $16
	
	db $f5, $1d, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $5, $3
	fEdgeIdx $16, $1a, $17
	
	db $1d, $9, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $1, $d
	fEdgeIdx $4, $3, $b
	
	db $e3, $9, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $d, $0
	fEdgeIdx $2, $4, $8
	
	db $8, $e2, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $2, $c
	fEdgeIdx $14, $c, $d
	
	db $f8, $e2, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $c, $3
	fEdgeIdx $13, $14, $15
	
	db $0, $1c, $f2 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $9, $0
	fEdgeIdx $5, $3, $2
	
	db $d, $1b, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $c, $2
	fEdgeIdx $9, $a, $d
	
	db $0, $1f, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $c
	fEdgeIdx $a, $5, $7
	
	db $f3, $1b, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $c
	fEdgeIdx $7, $6, $15
	
	db $28, $d8, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $7, $6, $0
	fEdgeIdx $0, $0
	
M_HoverTank2: ;6D67
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $f8, $d8, $b8
	db $30, $0, $c0
	db $20, $f0, $10
	db $e0, $f0, $90
	db vNONSPECIAL
	db 7 ;number of vertices in group
	db $0, $d0, $c8
	db $0, $d8, $20
	db $0, $d8, $d0
	db $0, $f8, $b0
	db $0, $f8, $30
	db $0, $f0, $60
	db $0, $e0, $f0
	db vEND
.edges
	db 29
	mEdge 0, 1
	mEdge 0, 8
	mEdge 0, 9
	mEdge 1, 8
	mEdge 1, 9
	mEdge 8, 9
	mEdge 10, 6
	mEdge 10, 14
	mEdge 10, 7
	mEdge 11, 12
	mEdge 11, 6
	mEdge 11, 7
	mEdge 12, 4
	mEdge 12, 5
	mEdge 12, 13
	mEdge 2, 4
	mEdge 2, 7
	mEdge 3, 5
	mEdge 3, 6
	mEdge 4, 13
	mEdge 4, 14
	mEdge 4, 7
	mEdge 5, 13
	mEdge 5, 6
	mEdge 5, 14
	mEdge 13, 14
	mEdge 6, 14
	mEdge 6, 7
	mEdge 14, 7
.faces
	db 17
	
	db $e8, $14, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $1, $9
	fEdgeIdx $5, $3, $4
	
	db $18, $14, $ff ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $9, $0
	fEdgeIdx $1, $5, $2
	
	db $0, $1c, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $8, $0
	fEdgeIdx $0, $3, $1
	
	db $f6, $1d, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $d, $e
	fEdgeIdx $14, $13, $19
	
	db $a, $1d, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $e, $d
	fEdgeIdx $16, $18, $19
	
	db $f4, $e4, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $d, $4
	fEdgeIdx $c, $e, $13
	
	db $f4, $1c, $4 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $d, $5
	fEdgeIdx $d, $e, $16
	
	db $e8, $13, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $7, $e
	fEdgeIdx $7, $8, $1c
	
	db $0, $1d, $b ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $a, $6
	fEdgeIdx $1b, $8, $6
	
	db $18, $13, $fc ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $e, $6
	fEdgeIdx $6, $7, $1a
	
	db $f2, $1c, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $7, $4
	fEdgeIdx $14, $1c, $15
	
	db $e, $1c, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $5, $6
	fEdgeIdx $1a, $18, $17
	
	db $f9, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $b, $c, $4
	fEdgeIdx $15, $b, $9, $c
	
	db $7, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $b, $6, $5, $c
	fEdgeIdx $9, $a, $17, $d
	
	db $0, $e2, $7 ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $7, $6
	fEdgeIdx $a, $b, $1b
	
	db $ea, $16, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $7
	fEdgeIdx $10, $f, $15
	
	db $16, $16, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $6, $5
	fEdgeIdx $11, $12, $17
	
M_MiniDino: ;6E7E
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $d0, $0, $94
	db $ee, $f4, $a0
	db $fa, $0, $0
	db $fa, $f4, $0
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $0, $f4, $9a
	db $0, $dc, $88
	db $0, $f6, $b8
	db $0, $e8, $c4
	db $0, $fa, $f4
	db $0, $f4, $ee
	db $0, $ee, $6
	db $0, $fa, $24
	db vEND
.edges
	db 31
	mEdge 8, 9
	mEdge 8, 10
	mEdge 8, 2
	mEdge 8, 3
	mEdge 9, 10
	mEdge 11, 13
	mEdge 11, 14
	mEdge 0, 2
	mEdge 0, 4
	mEdge 1, 3
	mEdge 1, 5
	mEdge 2, 3
	mEdge 2, 12
	mEdge 2, 4
	mEdge 3, 12
	mEdge 3, 5
	mEdge 12, 4
	mEdge 12, 5
	mEdge 12, 13
	mEdge 4, 5
	mEdge 4, 6
	mEdge 5, 7
	mEdge 13, 6
	mEdge 13, 7
	mEdge 13, 14
	mEdge 6, 7
	mEdge 6, 14
	mEdge 6, 15
	mEdge 7, 14
	mEdge 7, 15
	mEdge 14, 15
.faces
	db 21
	
	db $e7, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $7, $f
	fEdgeIdx $1e, $1c, $1d
	
	db $19, $11, $f9 ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $f, $6
	fEdgeIdx $1a, $1e, $1b
	
	db $ee, $18, $6 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $e, $d
	fEdgeIdx $17, $1c, $18
	
	db $12, $18, $6 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $d, $e
	fEdgeIdx $1a, $16, $18
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $d, $e, $b
	fEdgeIdx $5, $18, $6
	
	db $e2, $0, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $7, $d, $c
	fEdgeIdx $11, $15, $17, $12
	
	db $1c, $f7, $9 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $d, $6, $4
	fEdgeIdx $10, $12, $16, $14
	
	db $0, $1f, $fe ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $c, $2, $8
	fEdgeIdx $3, $e, $c, $2
	
	db $f0, $1a, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $3, $5
	fEdgeIdx $11, $e, $f
	
	db $10, $1a, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $4, $2
	fEdgeIdx $c, $10, $d
	
	db $f3, $1c, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $1, $5
	fEdgeIdx $f, $9, $a
	
	db $d, $1c, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $4, $0
	fEdgeIdx $7, $d, $8
	
	db $e1, $0, $0 ;normal
	db 3 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $8, $a, $9
	fEdgeIdx $0, $1, $4
	
	db $0, $0, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $6, $7, $5, $4
	fEdgeIdx $14, $19, $15, $13
	
	db $d, $e4, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $5, $1
	fEdgeIdx $9, $f, $a
	
	db $f3, $e4, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $0, $4
	fEdgeIdx $d, $7, $8
	
	db $0, $e1, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $c, $3
	fEdgeIdx $b, $c, $e
	
	db $0, $e1, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $6, $f
	fEdgeIdx $1d, $19, $1b
	
	db $10, $e6, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $5, $3
	fEdgeIdx $e, $11, $f
	
	db $f0, $e6, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $2, $4
	fEdgeIdx $10, $c, $d
	
	db $0, $e4, $e ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $5, $c
	fEdgeIdx $10, $13, $11
	
M_unknown4: ;6FC8
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 7 ;number of vertices in group
	db $4, $e8, $c8
	db $8, $e8, $df
	db $18, $f8, $0
	db $e0, $0, $0
	db $e8, $f8, $a0
	db $28, $f8, $0
	db $20, $f8, $40
	db vNONSPECIAL
	db 4 ;number of vertices in group
	db $0, $d8, $9f
	db $0, $e4, $c8
	db $0, $e0, $df
	db $0, $e8, $20
	db vEND
.edges
	db 34
	mEdge 14, 15
	mEdge 14, 0
	mEdge 14, 1
	mEdge 15, 0
	mEdge 15, 1
	mEdge 15, 16
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 9
	mEdge 1, 3
	mEdge 1, 8
	mEdge 2, 16
	mEdge 2, 17
	mEdge 2, 4
	mEdge 16, 3
	mEdge 16, 17
	mEdge 3, 17
	mEdge 3, 5
	mEdge 4, 9
	mEdge 4, 7
	mEdge 4, 12
	mEdge 5, 6
	mEdge 5, 8
	mEdge 5, 13
	mEdge 6, 8
	mEdge 6, 11
	mEdge 6, 13
	mEdge 8, 11
	mEdge 9, 7
	mEdge 9, 10
	mEdge 7, 10
	mEdge 7, 12
	mEdge 10, 12
	mEdge 11, 13
.faces
	db 20
	
	db $ea, $16, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $10, $2, $11
	fEdgeIdx $f, $b, $c
	
	db $16, $16, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $10, $11
	fEdgeIdx $10, $e, $f
	
	db $ea, $16, $3 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $10, $f, $0
	fEdgeIdx $7, $b, $5, $3
	
	db $16, $16, $3 ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $10, $3, $1, $f
	fEdgeIdx $5, $e, $9, $4
	
	db $ea, $16, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $e, $0
	fEdgeIdx $3, $0, $1
	
	db $16, $16, $fb ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $1, $e
	fEdgeIdx $0, $4, $2
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $9, $a, $c
	fEdgeIdx $14, $12, $1d, $20
	
	db $0, $1f, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $d, $b, $8
	fEdgeIdx $16, $17, $21, $1b
	
	db $ec, $18, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $9, $4, $2
	fEdgeIdx $7, $8, $12, $d
	
	db $16, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $3, $5, $8, $1
	fEdgeIdx $9, $11, $16, $a
	
	db $ea, $ea, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $7, $c
	fEdgeIdx $20, $1e, $1f
	
	db $16, $ea, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $4, $c
	fEdgeIdx $1f, $13, $14
	
	db $ea, $ea, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $a, $9
	fEdgeIdx $1c, $1e, $1d
	
	db $16, $ea, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $7, $9
	fEdgeIdx $12, $13, $1c
	
	db $ea, $ea, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $6, $d
	fEdgeIdx $17, $15, $1a
	
	db $ea, $ea, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $8, $6
	fEdgeIdx $15, $16, $18
	
	db $16, $ea, $3 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $8, $b
	fEdgeIdx $19, $18, $1b
	
	db $16, $ea, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $d, $6
	fEdgeIdx $19, $21, $1a
	
	db $0, $e3, $b ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $e
	fEdgeIdx $2, $6, $1
	
	db $0, $e1, $0 ;normal
	db 5 ;number of edges
	fEdgeGroup $3, $11, $2, $0, $1
	fEdgeIdx $9, $10, $c, $7, $6
	
M_Neotank: ;7113
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 15 ;number of vertices in group
	db $e8, $ca, $ac
	db $ed, $e0, $0
	db $ed, $e0, $48
	db $e2, $0, $ca
	db $12, $0, $42
	db $dc, $fa, $b8
	db $e8, $ee, $c4
	db $1e, $fa, $54
	db $18, $ee, $2a
	db $f4, $e8, $ee
	db $f4, $e8, $0
	db $e8, $e2, $e8
	db $c, $dc, $d0
	db $12, $e2, $18
	db $c, $d6, $ea
	db vEND
.edges
	db 50
	mEdge 0, 12
	mEdge 1, 13
	mEdge 2, 4
	mEdge 3, 5
	mEdge 6, 7
	mEdge 6, 9
	mEdge 6, 10
	mEdge 7, 8
	mEdge 7, 11
	mEdge 8, 9
	mEdge 8, 14
	mEdge 9, 15
	mEdge 10, 12
	mEdge 10, 11
	mEdge 10, 15
	mEdge 12, 13
	mEdge 12, 17
	mEdge 12, 18
	mEdge 13, 11
	mEdge 13, 16
	mEdge 13, 19
	mEdge 11, 14
	mEdge 14, 15
	mEdge 14, 16
	mEdge 15, 17
	mEdge 16, 17
	mEdge 16, 21
	mEdge 17, 20
	mEdge 18, 19
	mEdge 18, 20
	mEdge 18, 22
	mEdge 19, 21
	mEdge 19, 23
	mEdge 20, 21
	mEdge 20, 27
	mEdge 21, 26
	mEdge 22, 23
	mEdge 22, 25
	mEdge 22, 29
	mEdge 22, 27
	mEdge 23, 24
	mEdge 23, 26
	mEdge 23, 28
	mEdge 24, 25
	mEdge 24, 28
	mEdge 25, 29
	mEdge 26, 28
	mEdge 26, 27
	mEdge 28, 29
	mEdge 29, 27
.faces
	db 27
	
	db $39, $b0, $28 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $5, $3, $0
	fEdgeIdx $3, $3
	
	db $0, $1e, $f9 ;normal
	db 4 ;number of edges
	fEdgeGroup $1d, $1c, $1a, $1b
	fEdgeIdx $31, $30, $2e, $2f
	
	db $0, $1e, $7 ;normal
	db 4 ;number of edges
	fEdgeGroup $1c, $1d, $19, $18
	fEdgeIdx $2c, $30, $2d, $2b
	
	db $ea, $16, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $17, $1a, $1c
	fEdgeIdx $2a, $29, $2e
	
	db $eb, $16, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $1c, $18, $17
	fEdgeIdx $2a, $2c, $28
	
	db $16, $16, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $16, $1d, $1b
	fEdgeIdx $27, $26, $31
	
	db $15, $16, $5 ;normal
	db 3 ;number of edges
	fEdgeGroup $1d, $16, $19
	fEdgeIdx $2d, $26, $25
	
	db $0, $e2, $7 ;normal
	db 4 ;number of edges
	fEdgeGroup $19, $16, $17, $18
	fEdgeIdx $2b, $25, $24, $28
	
	db $ef, $e6, $fe ;normal
	db 4 ;number of edges
	fEdgeGroup $15, $1a, $17, $13
	fEdgeIdx $1f, $23, $29, $20
	
	db $e, $e5, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $12, $16, $1b, $14
	fEdgeIdx $1d, $1e, $27, $22
	
	db $0, $ea, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $13, $17, $16, $12
	fEdgeIdx $1c, $20, $24, $1e
	
	db $f2, $1c, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $13, $d, $10, $15
	fEdgeIdx $1f, $14, $13, $1a
	
	db $e, $1c, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $14, $11, $c, $12
	fEdgeIdx $1d, $1b, $10, $11
	
	db $0, $e2, $f9 ;normal
	db 4 ;number of edges
	fEdgeGroup $14, $1b, $1a, $15
	fEdgeIdx $21, $22, $2f, $23
	
	db $0, $1f, $fc ;normal
	db 4 ;number of edges
	fEdgeGroup $15, $10, $11, $14
	fEdgeIdx $21, $1a, $19, $1b
	
	db $0, $1e, $f8 ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $e, $f, $11
	fEdgeIdx $19, $17, $16, $18
	
	db $0, $1f, $4 ;normal
	db 4 ;number of edges
	fEdgeGroup $12, $c, $d, $13
	fEdgeIdx $1c, $11, $f, $14
	
	db $ea, $15, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $b, $e, $10
	fEdgeIdx $13, $12, $15, $17
	
	db $16, $16, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $a, $c, $11, $f
	fEdgeIdx $e, $c, $10, $18
	
	db $0, $16, $16 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $a, $b, $d
	fEdgeIdx $f, $c, $d, $12
	
	db $0, $e2, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $7, $b, $a, $6
	fEdgeIdx $4, $8, $d, $6
	
	db $f3, $e4, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $8, $e, $b, $7
	fEdgeIdx $7, $a, $15, $8
	
	db $c, $e3, $ff ;normal
	db 4 ;number of edges
	fEdgeGroup $f, $9, $6, $a
	fEdgeIdx $e, $b, $5, $6
	
	db $11, $d3, $0 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $4, $2, $0
	fEdgeIdx $2, $2
	
	db $14, $23, $23 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $d, $1, $0
	fEdgeIdx $1, $1
	
	db $0, $28, $d3 ;normal
	db 2 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $c, $0, $0
	fEdgeIdx $0, $0
	
	db $0, $e2, $f6 ;normal
	db 4 ;number of edges
	fEdgeGroup $9, $f, $e, $8
	fEdgeIdx $9, $b, $16, $a
	
M_BaseProng: ;72E0
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 4 ;number of vertices in group
	db $5, $ba, $fb
	db $fb, $ba, $5
	db $f6, $0, $f6
	db $f6, $0, $a
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $88, $d8
	db vEND
.edges
	db 16
	mEdge 8, 0
	mEdge 8, 1
	mEdge 8, 2
	mEdge 8, 3
	mEdge 0, 1
	mEdge 0, 3
	mEdge 0, 5
	mEdge 1, 2
	mEdge 1, 4
	mEdge 2, 3
	mEdge 2, 6
	mEdge 3, 7
	mEdge 4, 6
	mEdge 4, 5
	mEdge 6, 7
	mEdge 7, 5
.faces
	db 8
	
	db $0, $15, $e9 ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $8
	fEdgeIdx $3, $9, $2
	
	db $1f, $3, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $8, $2
	fEdgeIdx $7, $1, $2
	
	db $0, $ee, $1a ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $0, $8
	fEdgeIdx $1, $4, $0
	
	db $e1, $3, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $3, $8
	fEdgeIdx $0, $5, $3
	
	db $1f, $2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $1, $2, $6, $4
	fEdgeIdx $8, $7, $a, $c
	
	db $0, $2, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $2, $3, $7, $6
	fEdgeIdx $a, $9, $b, $e
	
	db $e1, $2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $5, $7, $3, $0
	fEdgeIdx $6, $f, $b, $5
	
	db $0, $2, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $0, $1
	fEdgeIdx $8, $d, $6, $4
	
M_PowerLines: ;7375
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 5 ;number of vertices in group
	db $fa, $b8, $6
	db $fa, $ac, $0
	db $6, $b8, $fa
	db $f4, $0, $f4
	db $f4, $0, $c
	db vNONSPECIAL
	db 2 ;number of vertices in group
	db $0, $a0, $c4
	db $0, $a0, $3c
	db vEND
.edges
	db 23
	mEdge 10, 2
	mEdge 10, 3
	mEdge 10, 4
	mEdge 10, 5
	mEdge 11, 0
	mEdge 11, 1
	mEdge 11, 2
	mEdge 11, 3
	mEdge 0, 1
	mEdge 0, 2
	mEdge 0, 8
	mEdge 1, 3
	mEdge 1, 9
	mEdge 2, 3
	mEdge 2, 5
	mEdge 3, 4
	mEdge 4, 5
	mEdge 4, 7
	mEdge 5, 6
	mEdge 6, 8
	mEdge 6, 7
	mEdge 8, 9
	mEdge 9, 7
.faces
	db 12
	
	db $1f, $2, $0 ;normal
	db 5 ;number of edges
	fEdgeGroup $8, $6, $5, $2, $0
	fEdgeIdx $a, $13, $12, $e, $9
	
	db $e1, $2, $0 ;normal
	db 5 ;number of edges
	fEdgeGroup $7, $9, $1, $3, $4
	fEdgeIdx $11, $16, $c, $b, $f
	
	db $0, $1f, $6 ;normal
	db 3 ;number of edges
	fEdgeGroup $2, $3, $b
	fEdgeIdx $6, $d, $7
	
	db $1f, $1, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $2, $b
	fEdgeIdx $4, $9, $6
	
	db $0, $e3, $f4 ;normal
	db 3 ;number of edges
	fEdgeGroup $0, $b, $1
	fEdgeIdx $8, $4, $5
	
	db $e1, $1, $fe ;normal
	db 3 ;number of edges
	fEdgeGroup $1, $b, $3
	fEdgeIdx $b, $5, $7
	
	db $0, $1f, $fa ;normal
	db 3 ;number of edges
	fEdgeGroup $3, $2, $a
	fEdgeIdx $1, $d, $0
	
	db $1f, $1, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $a, $2
	fEdgeIdx $e, $3, $0
	
	db $e1, $1, $2 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $3, $a
	fEdgeIdx $2, $f, $1
	
	db $0, $e3, $c ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $4, $a
	fEdgeIdx $3, $10, $2
	
	db $0, $2, $e1 ;normal
	db 4 ;number of edges
	fEdgeGroup $0, $1, $9, $8
	fEdgeIdx $a, $8, $c, $15
	
	db $0, $2, $1f ;normal
	db 4 ;number of edges
	fEdgeGroup $4, $5, $6, $7
	fEdgeIdx $11, $10, $12, $14
	
M_VIXIVText: ;744A
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 34 ;number of vertices in group
	db $b8, $20, $0
	db $48, $20, $0
	db $a8, $20, $0
	db $58, $20, $0
	db $94, $e0, $0
	db $6c, $e0, $0
	db $a4, $e0, $0
	db $5c, $e0, $0
	db $b0, $4, $0
	db $50, $4, $0
	db $bc, $e0, $0
	db $44, $e0, $0
	db $cc, $e0, $0
	db $34, $e0, $0
	db $e0, $20, $0
	db $20, $20, $0
	db $d0, $20, $0
	db $30, $20, $0
	db $d0, $e0, $0
	db $30, $e0, $0
	db $e0, $e0, $0
	db $20, $e0, $0
	db $f8, $0, $0
	db $8, $0, $0
	db $f8, $e0, $0
	db $8, $e0, $0
	db $e8, $e0, $0
	db $18, $e0, $0
	db $e8, $20, $0
	db $18, $20, $0
	db $f8, $20, $0
	db $8, $20, $0
	db $0, $10, $0
	db $0, $f0, $0
	db vEND
.edges
	db 34
	mEdge 0, 2
	mEdge 0, 12
	mEdge 2, 4
	mEdge 4, 6
	mEdge 6, 8
	mEdge 8, 10
	mEdge 10, 12
	mEdge 14, 16
	mEdge 14, 20
	mEdge 16, 18
	mEdge 18, 20
	mEdge 32, 30
	mEdge 32, 31
	mEdge 33, 24
	mEdge 33, 25
	mEdge 22, 26
	mEdge 22, 28
	mEdge 23, 29
	mEdge 23, 27
	mEdge 9, 7
	mEdge 9, 11
	mEdge 1, 3
	mEdge 1, 13
	mEdge 3, 5
	mEdge 5, 7
	mEdge 11, 13
	mEdge 19, 17
	mEdge 19, 21
	mEdge 17, 15
	mEdge 15, 21
	mEdge 24, 26
	mEdge 28, 30
	mEdge 31, 29
	mEdge 27, 25
.faces
	db 5
	
	db $0, $0, $1f ;normal
	db 7 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $d, $1, $3, $5, $7, $9
	fEdgeIdx $14, $19, $16, $15, $17, $18, $13
	
	db $0, $0, $1f ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $13, $15, $f, $11
	fEdgeIdx $1a, $1b, $1d, $1c
	
	db $0, $0, $1f ;normal
	db 12 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $18, $1a, $16, $1c, $1e, $20, $1f, $1d, $17, $1b, $19, $21
	fEdgeIdx $d, $1e, $f, $10, $1f, $b, $c, $20, $11, $12, $21, $e
	
	db $0, $0, $1f ;normal
	db 4 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $14, $12, $10, $e
	fEdgeIdx $8, $a, $9, $7
	
	db $0, $0, $1f ;normal
	db 7 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $4, $2, $0, $c, $a, $8
	fEdgeIdx $4, $3, $2, $0, $1, $6, $5
	
M_FinalBase: ;7558
	db 2 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL | vMIRRORED
	db 14 ;number of vertices in group
	db $b0, $de, $50
	db $b0, $de, $b0
	db $28, $0, $c8
	db $38, $0, $d8
	db $28, $0, $38
	db $38, $0, $28
	db $fc, $d8, $fc
	db $fc, $d8, $4
	db $f8, $e0, $f8
	db $f8, $e0, $8
	db $d8, $0, $d8
	db $f0, $f8, $f0
	db $d8, $0, $28
	db $f0, $f8, $10
	db vNONSPECIAL
	db 1 ;number of vertices in group
	db $0, $b8, $0
	db vEND
.edges
	db 56
	mEdge 0, 11
	mEdge 0, 9
	mEdge 0, 24
	mEdge 2, 7
	mEdge 2, 5
	mEdge 2, 20
	mEdge 1, 8
	mEdge 1, 10
	mEdge 1, 25
	mEdge 3, 4
	mEdge 3, 6
	mEdge 3, 21
	mEdge 4, 6
	mEdge 4, 21
	mEdge 6, 21
	mEdge 8, 10
	mEdge 8, 25
	mEdge 10, 25
	mEdge 11, 9
	mEdge 11, 24
	mEdge 9, 24
	mEdge 7, 5
	mEdge 7, 20
	mEdge 5, 20
	mEdge 28, 12
	mEdge 28, 14
	mEdge 28, 13
	mEdge 28, 15
	mEdge 12, 14
	mEdge 12, 13
	mEdge 12, 16
	mEdge 14, 15
	mEdge 14, 18
	mEdge 13, 15
	mEdge 13, 17
	mEdge 15, 19
	mEdge 16, 17
	mEdge 16, 18
	mEdge 16, 22
	mEdge 17, 19
	mEdge 17, 23
	mEdge 18, 19
	mEdge 18, 26
	mEdge 19, 27
	mEdge 20, 22
	mEdge 20, 24
	mEdge 20, 21
	mEdge 22, 26
	mEdge 22, 23
	mEdge 24, 26
	mEdge 24, 25
	mEdge 26, 27
	mEdge 21, 25
	mEdge 21, 23
	mEdge 25, 27
	mEdge 27, 23
.faces
	db 28
	
	db $e1, $fd, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $c, $e, $1c
	fEdgeIdx $18, $1c, $19
	
	db $0, $fd, $e1 ;normal
	db 3 ;number of edges
	fEdgeGroup $d, $c, $1c
	fEdgeIdx $1a, $1d, $18
	
	db $1f, $fd, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $f, $d, $1c
	fEdgeIdx $1b, $21, $1a
	
	db $0, $fd, $1f ;normal
	db 3 ;number of edges
	fEdgeGroup $e, $f, $1c
	fEdgeIdx $19, $1f, $1b
	
	db $e4, $f2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $c, $10, $12, $e
	fEdgeIdx $1c, $1e, $25, $20
	
	db $0, $f2, $e4 ;normal
	db 4 ;number of edges
	fEdgeGroup $d, $11, $10, $c
	fEdgeIdx $1d, $22, $24, $1e
	
	db $0, $f2, $1c ;normal
	db 4 ;number of edges
	fEdgeGroup $e, $12, $13, $f
	fEdgeIdx $1f, $20, $29, $23
	
	db $1c, $f2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $f, $13, $11, $d
	fEdgeIdx $21, $23, $27, $22
	
	db $e2, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $10, $16, $1a, $12
	fEdgeIdx $25, $26, $2f, $2a
	
	db $0, $f6, $e2 ;normal
	db 4 ;number of edges
	fEdgeGroup $11, $17, $16, $10
	fEdgeIdx $24, $28, $30, $26
	
	db $1e, $f6, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $13, $1b, $17, $11
	fEdgeIdx $27, $2b, $37, $28
	
	db $0, $f6, $1e ;normal
	db 4 ;number of edges
	fEdgeGroup $12, $1a, $1b, $13
	fEdgeIdx $29, $2a, $33, $2b
	
	db $f6, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $16, $14, $18, $1a
	fEdgeIdx $2f, $2c, $2d, $31
	
	db $a, $e2, $0 ;normal
	db 4 ;number of edges
	fEdgeGroup $1b, $19, $15, $17
	fEdgeIdx $37, $36, $34, $35
	
	db $0, $e2, $f6 ;normal
	db 4 ;number of edges
	fEdgeGroup $17, $15, $14, $16
	fEdgeIdx $30, $35, $2e, $2c
	
	db $0, $e2, $a ;normal
	db 4 ;number of edges
	fEdgeGroup $1a, $18, $19, $1b
	fEdgeIdx $33, $31, $32, $36
	
	db $0, $e8, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $7, $14, $2
	fEdgeIdx $3, $16, $5
	
	db $f3, $19, $f3 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $7, $2
	fEdgeIdx $4, $15, $3
	
	db $14, $e8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $5, $2, $14
	fEdgeIdx $17, $4, $5
	
	db $f3, $19, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $9, $0
	fEdgeIdx $0, $12, $1
	
	db $0, $e8, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $b, $0, $18
	fEdgeIdx $13, $0, $2
	
	db $14, $e8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $9, $18, $0
	fEdgeIdx $1, $14, $2
	
	db $ec, $e8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $4, $15, $3
	fEdgeIdx $9, $d, $b
	
	db $d, $19, $f3 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $4, $3
	fEdgeIdx $a, $c, $9
	
	db $0, $e8, $14 ;normal
	db 3 ;number of edges
	fEdgeGroup $6, $3, $15
	fEdgeIdx $e, $a, $b
	
	db $ec, $e8, $0 ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $1, $19
	fEdgeIdx $10, $6, $8
	
	db $d, $19, $d ;normal
	db 3 ;number of edges
	fEdgeGroup $8, $a, $1
	fEdgeIdx $6, $f, $7
	
	db $0, $e8, $ec ;normal
	db 3 ;number of edges
	fEdgeGroup $a, $19, $1
	fEdgeIdx $7, $11, $8
	
M_XLegsJoined: ;7733
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 16 ;number of vertices in group
	db $c, $26, $0
	db $e8, $d8, $0
	db $f2, $d8, $0
	db $d2, $d8, $0
	db $de, $d8, $0
	db $2, $26, $0
	db $fa, $26, $0
	db $16, $26, $0
	db $10, $d8, $0
	db $1c, $d8, $0
	db $ce, $26, $0
	db $c6, $26, $0
	db $ec, $26, $0
	db $e4, $26, $0
	db $30, $d8, $0
	db $3c, $d8, $0
	db vEND
.edges
	db 16
	mEdge 0, 1
	mEdge 0, 7
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 6
	mEdge 6, 7
	mEdge 8, 9
	mEdge 8, 15
	mEdge 9, 10
	mEdge 10, 11
	mEdge 11, 12
	mEdge 12, 13
	mEdge 13, 14
	mEdge 14, 15
.faces
	db 2
	
	db $0, $0, $1f ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $b, $a, $9, $8, $f, $e, $d, $c
	fEdgeIdx $c, $b, $a, $8, $9, $f, $e, $d
	
	db $0, $0, $1f ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $1, $0, $7, $6, $5, $4, $3
	fEdgeIdx $3, $2, $0, $1, $7, $6, $5, $4
	
M_XLogo: ;77B7
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 20 ;number of vertices in group
	db $f9, $fc, $0
	db $f2, $2, $0
	db $f9, $11, $0
	db $0, $a, $0
	db $c, $26, $0
	db $e8, $d8, $0
	db $f2, $d8, $0
	db $d2, $d8, $0
	db $de, $d8, $0
	db $2, $26, $0
	db $fa, $26, $0
	db $16, $26, $0
	db $10, $d8, $0
	db $1c, $d8, $0
	db $ce, $26, $0
	db $c6, $26, $0
	db $ec, $26, $0
	db $e4, $26, $0
	db $30, $d8, $0
	db $3c, $d8, $0
	db vEND
.edges
	db 20
	mEdge 0, 5
	mEdge 0, 13
	mEdge 1, 8
	mEdge 1, 14
	mEdge 2, 9
	mEdge 2, 17
	mEdge 3, 4
	mEdge 3, 18
	mEdge 4, 11
	mEdge 5, 6
	mEdge 6, 7
	mEdge 7, 8
	mEdge 9, 10
	mEdge 10, 11
	mEdge 12, 13
	mEdge 12, 19
	mEdge 14, 15
	mEdge 15, 16
	mEdge 16, 17
	mEdge 18, 19
.faces
	db 2
	
	db $0, $0, $1f ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $6, $5, $0, $d, $c, $13, $12, $3, $4, $b
	fEdgeIdx $d, $c, $4, $5, $12, $11, $10, $3, $2, $b
	
	db $0, $0, $1f ;normal
	db 10 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $a, $9, $2, $11, $10, $f, $e, $1, $8, $7
	fEdgeIdx $a, $9, $0, $1, $e, $f, $13, $7, $6, $8
	
M_XLeg1: ;7857
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $10, $d8, $0
	db $1c, $d8, $0
	db $ce, $26, $0
	db $c6, $26, $0
	db $ec, $26, $0
	db $e4, $26, $0
	db $30, $d8, $0
	db $3c, $d8, $0
	db vEND
.edges
	db 8
	mEdge 0, 1
	mEdge 0, 7
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 6
	mEdge 6, 7
.faces
	db 1
	
	db $0, $0, $1f ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $3, $2, $1, $0, $7, $6, $5, $4
	fEdgeIdx $4, $3, $2, $0, $1, $7, $6, $5
	
M_XLeg2: ;789F
	db 1 ;precision
	dw .verts, .edges, .faces
.verts
	db vNONSPECIAL
	db 8 ;number of vertices in group
	db $c, $26, $0
	db $e8, $d8, $0
	db $f2, $d8, $0
	db $d2, $d8, $0
	db $de, $d8, $0
	db $2, $26, $0
	db $fa, $26, $0
	db $16, $26, $0
	db vEND
.edges
	db 8
	mEdge 0, 1
	mEdge 0, 7
	mEdge 1, 2
	mEdge 2, 3
	mEdge 3, 4
	mEdge 4, 5
	mEdge 5, 6
	mEdge 6, 7
.faces
	db 1
	
	db $0, $0, $1f ;normal
	db 8 | fALWAYSVISIBLE ;number of edges
	fEdgeGroup $2, $1, $0, $7, $6, $5, $4, $3
	fEdgeIdx $3, $2, $0, $1, $7, $6, $5, $4
;78E7