SECTION "9:TOP", ROMX[$4000], BANK[9]
TunnelFinal: ;4000, the escape tunnel at the end of the game
	db 3, 0, 0
	tunSetLength $1
	tunEntity $fd, $fc, $3, $8, TUN_ENT_SHUTTER_LEFT, %11111111
	tunEntity $0, $fc, $3, $8, TUN_ENT_SHUTTER_RIGHT, %11111111
:	tunSetLength $6
	tunLoop :-, $3
	tunEntity $fd, $fe, $2, $4, TUN_ENT_DOOR_LEFT, %01010101
	tunEntity $0, $fe, $3, $4, TUN_ENT_DOOR_RIGHT, %01010101
:	tunSetLength $6
	tunLoop :-, $3
:	tunSetLength $6
	tunEntity $fd, $fe, $2, $4, TUN_ENT_DOOR_LEFT, %11001100
	tunEntity $0, $fe, $3, $4, TUN_ENT_DOOR_RIGHT, %11001100
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fd, $fe, $2, $4, TUN_ENT_DOOR_LEFT, %01010101
	tunEntity $0, $fe, $3, $4, TUN_ENT_DOOR_RIGHT, %01010101
	tunSetLength $6
	tunSetLength $6
	tunLoop :-, $2
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EARTH, %00000000
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd
	
TunnelToTetamus: ;4069, demo + resume tunnel
	db 03, 00, 00
	tunSetLength $1
	tunEntity $fd, $fc, $3, $8, TUN_ENT_SHUTTER_LEFT, %11111111
	tunEntity $0, $fc, $3, $8, TUN_ENT_SHUTTER_RIGHT, %11111111
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $2
:	tunSetLength $6
	tunTurnRight $6
	tunLoop :-, $a
:	tunSetLength $6
	tunLoop :-, $2
:	tunSetLength $6
	tunTurnLeft $6
	tunLoop :-, $a
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $6, $3
:	tunSetLength $6
	tunLoop :-, $7
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $6
	tunLoop :-, $3
	tunDimensions $4, $2
	tunSetLength $5
	tunEntity $fd, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunEntity $1, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunEntity $fd, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunEntity $1, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunEntity $fd, $fc, $2, $8, TUN_ENT_DOOR_LEFT, %10001000
	tunEntity $0, $fc, $3, $8, TUN_ENT_DOOR_RIGHT, %10001000
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %00000000
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd
	
;4150, unused?
	db 03, 00, 00 ;unused timer?
	tunSetLength $1
	tunEntity $fd, $fc, $3, $8, TUN_ENT_SHUTTER_LEFT, %11111111 ;x, y, w, h, type, fillpattern
	tunEntity $0, $fc, $3, $8, TUN_ENT_SHUTTER_RIGHT, %11111111 ;these are the starting shutters
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $6, $5
:	tunSetLength $6
	tunLoop :-, $7
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $fd, $8, $3, TUN_ENT_BARRIER, %11001100 ;stationary barrier
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $0, $8, $3, TUN_ENT_BARRIER, %11001100
:	tunSetLength $6
	tunLoop :-, $4
	tunDimensions $a, $8
:	tunSetLength $6
	tunLoop :-, $a
	tunDimensions $8, $5
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $7
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $8
	tunDimensions $8, $6
:	tunSetLength $6
	tunLoop :-, $8
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $8
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %00000000 ;"EXIT"
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;41DA, demo tunnel
	db 2, 5, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $5
	tunEntity $fd, $fc, $2, $8, TUN_ENT_DOOR_LEFT, %11111111
	tunEntity $0, $fc, $3, $8, TUN_ENT_DOOR_RIGHT, %11111111
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $3
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $5
	tunSetLength $6
	tunTurnRight $6
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $2
:	tunSetLength $6
	tunLoop :-, $5
	tunEntity $0, $0, $2, $1, TUN_ENT_LEFT, %10101010
	tunSetLength $6
	tunWidth $2
	tunSetLength $6
	tunTurnLeft $3
	tunSetLength $6
	tunTurnLeft $5
	tunSetLength $6
	tunTurnLeft $7
	tunSetLength $6
	tunTurnLeft $8
	tunSetLength $6
	tunTurnLeft $7
	tunSetLength $6
	tunTurnLeft $5
	tunSetLength $6
	tunTurnLeft $3
	tunSetLength $6
	tunTurnLeft $1
	tunSetLength $6
	tunSetLength $6
	tunTurnLeft $3
	tunSetLength $6
	tunTurnLeft $5
	tunSetLength $6
	tunTurnLeft $7
	tunSetLength $6
	tunTurnLeft $9
	tunSetLength $6
	tunTurnLeft $b
	tunWidth $4
	tunSetLength $6
	tunTurnLeft $a
	tunSetLength $6
	tunTurnLeft $7
	tunSetLength $6
	tunTurnLeft $5
	tunSetLength $6
	tunTurnLeft $3
	tunSetLength $6
	tunEntity $fd, $fd, $3, $6, TUN_ENT_BARRIER, %10101010
:	tunSetLength $6
	tunLoop :-, $4
	tunEntity $0, $fd, $4, $6, TUN_ENT_BARRIER, %10101010
:	tunSetLength $6
	tunLoop :-, $5
	tunEntity $fd, $fd, $3, $6, TUN_ENT_BARRIER, %10101010
:	tunSetLength $6
	tunLoop :-, $5
	tunEntity $0, $fd, $4, $6, TUN_ENT_BARRIER, %10101010
:	tunSetLength $6
	tunTurnRight $2
	tunLoop :-, $e
	tunOuterLoop :------, $3
	tunSetLength $0
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %00000000
:	tunSetLength $0
	tunLoop :-, $9
	tunEnd

;42BA, demo + alien (bomb) tunnel
	db 4, 0, 0 ;unused
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fd, $fc, $2, $8, TUN_ENT_DOOR_LEFT, %11111111
	tunEntity $0, $fc, $3, $8, TUN_ENT_DOOR_RIGHT, %11111111
	tunSetLength $5
	tunSetLength $5
	tunTurnLeft $5
	tunSetLength $4
	tunTurnLeft $a
	tunSetLength $4
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $4
	tunTurnLeft $5
	tunHeight $3
	tunSetLength $6
	tunTurnRight $5
	tunSetLength $4
	tunTurnRight $5
	tunSetLength $4
	tunTurnRight $5
	tunSetLength $4
	tunTurnRight $5
	tunSetLength $4
	tunTurnLeft $5
	tunSetLength $5
	tunEntity $fe, $fd, $2, $1, TUN_ENT_SHUTTER_CLOSE_DOWNWARD, %10101010
	tunSetLength $5
	tunSetLength $5
	tunHeight $2
	tunSetLength $4
	tunSetLength $4
	tunTurnLeft $5
	tunSetLength $5
	tunTurnLeft $6
	tunSetLength $5
	tunTurnLeft $7
	tunSetLength $5
	tunTurnLeft $8
	tunSetLength $5
	tunTurnLeft $9
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $5
	tunEntity $0, $1, $2, $1, TUN_ENT_RIGHT, %10101010
	tunSetLength $5
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $2
	tunTurnRight $a
	tunSetLength $2
	tunTurnRight $f
	tunSetLength $2
	tunTurnRight $f
	tunSetLength $2
	tunTurnRight $a
	tunSetLength $4
	tunSetLength $4
	tunSetLength $4
	tunEntity $fd, $ff, $2, $3, TUN_ENT_BARRIER, %1010101
	tunSetLength $4
	tunTurnLeft $2
	tunSetLength $4
	tunTurnLeft $3
	tunSetLength $4
	tunEntity $1, $ff, $2, $3, TUN_ENT_BARRIER, %1010101
	tunTurnLeft $4
	tunSetLength $4
	tunTurnLeft $5
	tunSetLength $4
	tunTurnLeft $6
	tunSetLength $4
	tunTurnLeft $a
	tunSetLength $6
	tunHeight $1
	tunSetLength $6
	tunEntity $fe, $ff, $1, $2, TUN_ENT_BARRIER, %1111
	tunSetLength $6
	tunWidth $2
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $6
	tunSetLength $6
	tunTurnRight $8
	tunSetLength $6
	tunTurnRight $a
	tunSetLength $6
	tunTurnRight $c
	tunSetLength $6
	tunDimensions $a, $4
	tunSetLength $a
	tunSetLength $a
	tunSetLength $a
	tunEntity $fa, $ff, $1, $4, TUN_ENT_SHUTTER_CLOSE_RIGHTWARD, %11001100
	tunEntity $6, $ff, $2, $4, TUN_ENT_SHUTTER_CLOSE_LEFTWARD, %11001100
	tunTurnLeft $1
	tunSetLength $8
	tunTurnLeft $2
	tunSetLength $a
	tunTurnLeft $3
	tunSetLength $8
	tunTurnLeft $4
	tunSetLength $8
	tunTurnLeft $5
	tunSetLength $8
	tunTurnLeft $6
	tunSetLength $8
	tunEntity $fa, $1, $c, $3, TUN_ENT_BARRIER, %11011101
	tunTurnLeft $7
	tunSetLength $8
	tunTurnLeft $8
	tunSetLength $5
	tunTurnLeft $9
	tunSetLength $a
	tunTurnLeft $a
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fb, $0, $1, $4, TUN_ENT_SHUTTER_CLOSE_RIGHTWARD, %11111111
	tunSetLength $5
	tunSetLength $5
	tunTurnRight $2
	tunDimensions $8, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $3, $0, $2, $4, TUN_ENT_SHUTTER_CLOSE_LEFTWARD, %10111011
	tunTurnLeft $3
	tunSetLength $5
	tunWidth $6
	tunSetLength $5
	tunSetLength $5
	tunDimensions $1e, $1e
	tunSetLength $19
	tunSetLength $19
	tunDimensions $2, $2
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $6
	tunSetLength $7
	tunSetLength $8
	tunWidth $3
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $5
	tunTurnLeft $2
	tunSetLength $5
	tunTurnLeft $2
	tunEntity $fc, $fc, $3, $8, TUN_ENT_BARRIER, %1010101
	tunSetLength $5
	tunTurnLeft $4
	tunSetLength $5
	tunTurnLeft $7
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $7
	tunEntity $1, $fc, $4, $8, TUN_ENT_BARRIER, %10101010
	tunSetLength $5
	tunTurnRight $8
	tunSetLength $5
	tunTurnRight $9
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnLeft $1
	tunEntity $fc, $1, $8, $8, TUN_ENT_BARRIER, %1010101
	tunSetLength $5
	tunTurnLeft $2
	tunSetLength $5
	tunTurnLeft $3
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunTurnRight $1
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunTurnRight $1
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fd, $4, $2, TUN_ENT_BARRIER, %1010101
	tunSetLength $6
	tunTurnLeft $1
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunTurnLeft $3
	tunEntity $fe, $ff, $4, $2, TUN_ENT_BARRIER, %1010101
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $6
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunEntity $fe, $1, $4, $2, TUN_ENT_BARRIER, %1010101
	tunEntity $fe, $fd, $4, $2, TUN_ENT_BARRIER, %1010101
	tunTurnLeft $3
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunTurnLeft $1
	tunSetLength $6
	tunSetLength $6
	tunDimensions $a, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $2, $a
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $2, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $3, $2
	tunSetLength $6
	tunEntity $fd, $fe, $1, $2, TUN_ENT_SHUTTER_CLOSE_RIGHTWARD, %11001100
	tunSetLength $6
	tunSetLength $6
	tunDimensions $4, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $5, $3
	tunSetLength $6
	tunSetLength $6
	tunEntity $1, $1, $4, $4, TUN_ENT_SHUTTER_CLOSE_LEFTWARD, %11001100
	tunSetLength $6
	tunDimensions $4, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $2, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $3, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $6, $3
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $0
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $9
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunEnd

;4585, demo tunnel
	db 2, 1, 0 ;unused
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunTurnRight $3
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $5
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $7
	tunSetLength $5
	tunTurnRight $8
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunTurnLeft $2
	tunSetLength $5
	tunTurnLeft $4
	tunSetLength $5
	tunTurnLeft $6
	tunSetLength $5
	tunTurnLeft $8
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $c
	tunSetLength $5
	tunTurnLeft $e
	tunSetLength $5
	tunTurnLeft $f
	tunDimensions $20, $20
	tunSetLength $5
	tunTurnLeft $d
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $7
	tunDimensions $3, $2
	tunSetLength $5
	tunTurnLeft $5
	tunSetLength $5
	tunTurnLeft $3
:	tunSetLength $5
	tunLoop :-, $6
	tunTurnRight $2
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $8
	tunSetLength $5
	tunTurnRight $a
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $8
	tunSetLength $5
	tunTurnLeft $6
	tunSetLength $5
	tunTurnLeft $4
	tunSetLength $5
	tunTurnRight $a
	tunSetLength $5
	tunTurnRight $c
	tunSetLength $5
	tunTurnRight $e
	tunDimensions $20, $20
	tunSetLength $5
	tunTurnRight $d
	tunSetLength $5
	tunTurnRight $a
	tunSetLength $5
	tunTurnRight $7
	tunSetLength $5
	tunTurnRight $4
	tunDimensions $3, $2
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunDimensions $20, $20
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $9
	tunEnd

;46A8, demo tunnel
	db 1, 7, 0 ;unused
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fe, $fe, $2, $4, TUN_ENT_BARRIER, %1010101
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $0, $fe, $3, $4, TUN_ENT_BARRIER, %1010101
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $6
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fe, $0, $4, $4, TUN_ENT_BARRIER, %11111111
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fe, $fe, $4, $2, TUN_ENT_BARRIER, %11111111
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $7
	tunSetLength $6
	tunTurnRight $a
	tunSetLength $6
	tunTurnRight $a
	tunSetLength $6
	tunTurnRight $a
	tunSetLength $6
	tunTurnRight $7
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunEnd

;475F, demo + alien (bomb) tunnel
	db 0, 0, 0 ;unused
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $6, $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $fc, $3, $8, TUN_ENT_DOOR_LEFT, %1010101
	tunEntity $0, $fc, $3, $8, TUN_ENT_DOOR_RIGHT, %1010101
	tunSetLength $6
	tunSetLength $6
	tunDimensions $3, $3
	tunSetLength $6
	tunDimensions $6, $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $3, $3
	tunSetLength $6
	tunDimensions $6, $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $1
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunDimensions $4, $3
	tunTurnRight $6
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $1
	tunSetLength $6
	tunTurnLeft $28
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnLeft $1
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunTurnRight $28
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $5
	tunSetLength $4
	tunSetLength $3
	tunSetLength $2
	tunSetLength $1
	tunSetLength $1
	tunSetLength $2
	tunSetLength $3
	tunEntity $fd, $0, $1, $8, TUN_ENT_SHUTTER_CLOSE_RIGHTWARD, %11111111
	tunSetLength $4
	tunSetLength $5
	tunSetLength $6
	tunTurnRight $28
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $2
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $6
	tunSetLength $6
	tunTurnRight $a
	tunSetLength $6
	tunTurnRight $6
	tunSetLength $6
	tunTurnRight $4
	tunSetLength $6
	tunTurnRight $2
	tunDimensions $5, $3
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fd, $fd, $2, $6, TUN_ENT_DOOR_LEFT, %11111111
	tunEntity $1, $fd, $3, $6, TUN_ENT_DOOR_RIGHT, %11111111
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $8
	tunSetLength $6
	tunTurnLeft $c
	tunDimensions $5, $4
	tunSetLength $6
	tunTurnLeft $10
	tunSetLength $6
	tunTurnLeft $c
	tunSetLength $6
	tunDimensions $5, $2
	tunTurnLeft $8
	tunSetLength $6
	tunTurnLeft $4
	tunDimensions $7, $3
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $4, $4
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $28
	tunDimensions $20, $20
	tunSetLength $19
	tunSetLength $19
	tunSetLength $19
	tunDimensions $2, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $6, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $0, $1, $4, $3, TUN_ENT_BARRIER, %10101010
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $1, $4, $3, TUN_ENT_BARRIER, %11111111
	tunTurnLeft $2
	tunSetLength $5
	tunTurnLeft $4
	tunSetLength $5
	tunEntity $fc, $fc, $4, $3, TUN_ENT_BARRIER, %11001100
	tunTurnLeft $6
	tunSetLength $5
	tunTurnLeft $8
	tunSetLength $5
	tunEntity $0, $fc, $4, $3, TUN_ENT_BARRIER, %11110000
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $c
	tunSetLength $5
	tunTurnLeft $e
	tunSetLength $5
	tunTurnLeft $c
	tunSetLength $5
	tunTurnLeft $a
	tunSetLength $5
	tunTurnLeft $8
	tunSetLength $5
	tunTurnLeft $6
	tunSetLength $5
	tunTurnLeft $4
	tunSetLength $5
	tunTurnLeft $2
	tunSetLength $5
	tunDimensions $3, $2
	tunTurnRight $2
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $8
	tunSetLength $5
	tunTurnRight $a
	tunSetLength $5
	tunTurnRight $8
	tunSetLength $5
	tunTurnRight $6
	tunSetLength $5
	tunTurnRight $4
	tunSetLength $5
	tunTurnRight $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnLeft $28
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $28
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $3, $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunTurnRight $32
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $4, $3
	tunTurnLeft $2
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $6
	tunSetLength $6
	tunTurnLeft $8
	tunSetLength $6
	tunTurnLeft $6
	tunSetLength $6
	tunTurnLeft $4
	tunSetLength $6
	tunTurnLeft $2
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $3, $4, $1, TUN_ENT_SHUTTER_CLOSE_UPWARD, %1010101
	tunEntity $0, $fd, $4, $1, TUN_ENT_SHUTTER_CLOSE_DOWNWARD, %1010101
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunSetLength $0
	tunEnd

;49AF, demo + tetamus tunnel (junction to TL)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
:	tunSetLength $5
	tunTurnRight $6
	tunLoop :-, $5
:	tunSetLength $5
	tunTurnLeft $6
	tunLoop :-, $5
:	tunSetLength $5
	tunLoop :-, $3
	tunDimensions $6, $3
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $0, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $fe, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $6
	tunLoop :-, $3
	tunDimensions $6, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $fe, $3, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $1, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $5
	tunLoop :-, $8
:	tunSetLength $5
	tunTurnLeft $5
	tunLoop :-, $8
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $6, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $6
:	tunSetLength $4
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $4
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4AA6, demo + tetamus tunnel (TL to junction)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $6
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $6, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $5
	tunLoop :-, $8
:	tunSetLength $5
	tunTurnRight $5
	tunLoop :-, $8
	tunDimensions $6, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $1, $fe, $2, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $fe, $3, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $2
:	tunSetLength $6
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $6
	tunLoop :-, $4
	tunDimensions $6, $3
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $fe, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fc, $0, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $3
:	tunSetLength $5
	tunTurnLeft $6
	tunLoop :-, $5
:	tunSetLength $5
	tunTurnRight $6
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $2
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4B97, demo + tetamus tunnel (junction to TR)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $8
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunTurnRight $2
	tunLoop :-, $8
	tunDimensions $2, $2
:	tunSetLength $5
	tunTurnLeft $2
	tunLoop :-, $8
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $7
	tunDimensions $3, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fd, $4, $3, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fd, $4, $3, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $7
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $8
:	tunSetLength $5
	tunTurnRight $2
	tunLoop :-, $6
:	tunSetLength $5
	tunTurnLeft $2
	tunLoop :-, $6
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $4
	tunLoop :-, $8
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4C84, demo + tetamus tunnel (TR to junction)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $8
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $4
:	tunSetLength $5
	tunTurnLeft $2
	tunLoop :-, $6
:	tunSetLength $5
	tunTurnRight $2
	tunLoop :-, $6
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $7
	tunDimensions $3, $4
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fd, $4, $3, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunEntity $fe, $1, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunEntity $fe, $fd, $4, $3, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $3, $4
	tunSetLength $5
	tunEntity $fe, $1, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $7
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunTurnLeft $2
	tunLoop :-, $8
	tunDimensions $2, $2
:	tunSetLength $5
	tunTurnRight $2
	tunLoop :-, $8
	tunDimensions $2, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4D6D, demo + tetamus tunnel (junction to BR)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $3
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $3, $6
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fc, $4, $2, TUN_ENT_BARRIER, %11001100
	tunEntity $fe, $2, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fc, $4, $2, TUN_ENT_BARRIER, %11001100
	tunEntity $fe, $2, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $a
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4E57, demo + tetamus tunnel (BR to junction)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $a
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $3, $6
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fc, $4, $2, TUN_ENT_BARRIER, %11001100
	tunEntity $fe, $2, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fc, $4, $2, TUN_ENT_BARRIER, %11001100
	tunEntity $fe, $2, $4, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $1, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $4, $1, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $3, $4
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $3
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;4F41, demo + tetamus tunnel (junction to BL)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $6, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $0, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $0, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;5074, demo + tetamus tunnel (BL to junction)
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $4
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $2, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnLeft $3
	tunLoop :-, $3
	tunDimensions $6, $2
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $0, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $0, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunEntity $fe, $fe, $1, $4, TUN_ENT_BARRIER, %11001100
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunSetLength $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $4
	tunLoop :-, $5
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunTurnRight $3
	tunLoop :-, $3
	tunDimensions $4, $2
:	tunSetLength $5
	tunLoop :-, $4
	tunDimensions $4, $2
:	tunSetLength $4
	tunLoop :-, $5
	tunDimensions $3, $3
	tunSetLength $4
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd

;51A7, tunnel????
	db 0, 0, 0 ;unused
:	tunSetLength $6
	tunLoop :-, $6
	tunDimensions $6, $4
:	tunSetLength $6
	tunLoop :-, $f
:	tunSetLength $6
	tunTurnRight $5
	tunLoop :-, $7
:	tunSetLength $6
	tunLoop :-, $5
:	tunSetLength $6
	tunTurnLeft $5
	tunLoop :-, $7
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $4, $4
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $6, $4
:	tunSetLength $6
	tunLoop :-, $5
	tunDimensions $6, $6
:	tunSetLength $6
	tunLoop :-, $5
	tunSetLength $6
	tunEntity $fc, $2, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $fc, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunEntity $fc, $ff, $8, $2, TUN_ENT_BARRIER, %11001100
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunSetLength $6
	tunDimensions $4, $6
:	tunSetLength $6
	tunLoop :-, $a
	tunDimensions $6, $6
:	tunSetLength $6
	tunLoop :-, $3
	tunSetLength $1
	tunEntity $c0, $0, $1, $1, TUN_ENT_EXIT, %0
:	tunSetLength $0
	tunLoop :-, $6
	tunEnd


PrintTutorialTextPage: ;5247
	;passed c is read table value?
	call CallLoadCharsetEnglish ;doesn't touch c
.startloop ;524A
	ld a, [hl+] ;this is our letters buffer
	cp $24
	jp nz, .pastloop
	ld a, [hl+]
	or a
	jr z, .pastloop
	sub $31 ;if bytes are 24, then not 0, sub 31, call 3025, then loop
	call CallLoadCharset ;seq here is 24, >31
	jp .startloop
.pastloop ;525C
	call Handle2024Seq
	or a
	ret z ;this only happens at the bottom branch of ^ func
	push hl
	push bc
	push af
	call CallTextDrawChar
	pop af
	pop bc
	pop hl
	sub $20
	ld e, a
	ld a, [$C27B] ;2nd pointer
	add a, e
	ld e, a
	ld a, [$C27C]
	adc a, $00
	ld d, a
	call GetByteFromBank5
	add a, c
	ld c, a
	jp .startloop
	
Handle2024Seq: ;5280
	;just read a byte from HL
	cp $20
	ret nz ;if it's not $20, return
	push af
	push hl
	push bc
	ld a, [wLoadedCharset]
	push af
	push de ;save all registers
	ld de, $43E6 ;second pointer for english charset
	call GetByteFromBank5 ;returns it in a
	pop de
	ld e, a ;e is bank5 byte
.found20 ;-e4? when finds a 20
	ld a, c ;c += b5b*2
	add a, e
	ld c, a
.loop1 ;5296
	ld a, [hl+]
	cp $24
	jp nz, .handlenot24
	ld a, [hl+] ;if byte was 24
	or a
	jr z, .handlenot24
	sub $31 ;and next byte wasn't 0
	call CallLoadCharset ;same as above; seq was 20, 24, >31
	jp .loop1 ;loop
	
.handlenot24;52A8
	or a
	jr z, .foundzero
	cp $20
	jr z, .found20 ;
	ld a, c
	cp $9A
	jr nc, .todechl ;
	pop af
	ld a, [wLoadedCharset]
	push af
	push hl
.loop2 ;52BA
	ld a, [hl+]
	cp $24
	jp nz, .handleanothernot24
	ld a, [hl+]
	or a
	jr z, .handleanothernot24
	sub $31
	call CallLoadCharset ;seq was 20, ???, 24, >31
	jp .loop2 ;loop
	
.handleanothernot24 ;52CC
	or a
	jr z, .zero20 ;if zero
	cp $20
	jr z, .zero20 ;or 20, skip
	sub $20
	ld e, a
	ld a, [$C27B]
	add a, e
	ld e, a
	ld a, [$C27C]
	adc a, $00
	ld d, a
	call GetByteFromBank5
	add a, c
	ld c, a
	cp $9A
	jr c, .loop2 ;52BA
	pop hl
	pop af
	call CallLoadCharset
	dec hl
	jr .loop3setup ;
.zero20
	pop hl
.foundzero
	pop af
	call CallLoadCharset
	pop bc
	pop hl
	pop af
	ret
	
.todechl ;52FB, +47
	dec hl
	pop af
.loop3setup ;+B
	ld a, b
	add a, $0D
	ld b, a
	ld a, [$CB1C]
	ld c, a
	add sp, $06
.loop3 ;5307
	ld a, [hl+]
	cp $24
	jp nz, .ret
	ld a, [hl+]
	or a
	jr z, .ret
	sub $31
	call CallLoadCharset ;same ol 24, >31 sequence
	jp .loop3 ;loop
.ret
	ret
	
HandleSomeLetters: ;531A
	call CallLoadCharsetEnglish
	push hl ;points to a string
	push de
	ld b, $00
.loop
	ld a, [hl+]
	cp $24
	jp nz, .english
	ld a, [hl+] ;first value was $24 (dollar sign), we want to load a charset
	or a
	jr z, .english ;to 5333
	sub $31 ;second value wasn't 00, subtract '1' to get the jp charset
	call CallLoadCharset
	jp .loop
	
.english ;5333
	sub $20
	jr c, .eol
	ld e, a ;read value was > 20, a letter?
	ld a, [$C27B]
	add a, e
	ld e, a
	ld a, [$C27C] ;2nd charset pointer
	adc a, $00
	ld d, a ;passed DE += charset pointer 2
	call GetByteFromBank5
	add a, b
	ld b, a ; b+= retireved value
	jr .loop
.eol ;13
	srl b
	ld a, c
	sub a, b
	ld c, a ;C -= our found B value / 2
	pop de
	pop hl
	ret

;5352
	db "$1Demo Mode", 00
SETCHARMAP CHARS
RadarTutText8: ;535E-53B4
	db  "$PＥＸＩＴ$Hをえらふ<LP><LP>$Kﾞ$Hか、<NL>", \
	"<NL>", \
	"$PＢ$Kホ<LP><LP>ﾞタン$Hまたは$Kスタートホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞ<NL>", \
	"$Kレータ<LP><LP>ﾞー$P基$H地から<NL>", \
	"$H出られる。<NL>", 00
RadarTutText7: ;53B5-53F1
	db  "$P白$Hいふ<LP><LP><LP>$Kﾞ$Hふ<LP><LP><LP>$Kﾞ$Hんは、<NL>", \
	"$H今、君か<LP><LP>$Kﾞ$Hいる$Kエリア$Hた<LP><LP>$Kﾞ$H。<NL>", 00
RadarTutText6: ;53F2-543C, needs 1 char
	db  "$Hか<LP><LP>$Kﾞ$Hめん$P中央$Hの<NL>", \
	"$P下$Hにある$Kマス$P", 223, "$Hを<NL>", \ ;DF in P set
	"$H「$Kク<LP><LP>ﾞリット<LP><LP>ﾞスクリーン$H」とよふ<LP><LP>$Kﾞ$H。<NL>", 00
RadarTutText5: ;543D-549F
	db  "$Hいちと<LP><LP>$Kﾞ$Hに<NL>", \
	"$Hそうひ<LP><LP>$Kﾞ$Hて<LP><LP>$Kﾞ$Hきる$P兵器$Hは<NL>", \
	"$H１<LP><LP><LP>つた<LP><LP>$Kﾞ$Hけた<LP><LP>$Kﾞ$H。<NL>", \
	"$P右$Hの$Kメニュー$Hからえらへ<LP><LP>$Kﾞ$H。<NL>", 00
RadarTutText4: ;54A0-54EC
	db  "$Hえらひ<LP><LP>$Kﾞ$Hたい方の<NL>", \
	"$Kメニュー$Hか<LP><LP>$Kﾞ$Hめんは<NL>", \
	"$H「$P十$Kホ<LP><LP>ﾞタン$Hの$P左右$H」て<LP><LP>$Kﾞ$Hきりかえる。<NL>", 00
RadarTutText3: ;54ED-5548
	db  "$P右$Hか<LP><LP>$Kﾞ$H「そうひ<LP><LP>$Kﾞ$Hする$P兵器$H」<NL>", \
	"$P左$Hか<LP><LP>$Kﾞ$H「$P補給$Kアイテム$H」の<NL>", \
	"$Kメニュー$Hか<LP><LP>$Kﾞ$Hめんた<LP><LP>$Kﾞ$H。<NL>", 00
RadarTutText2: ;5549-559A
	db  "$P十$Kホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞ<NL>", \
	"$Kアイテム$Hなと<LP><LP>$Kﾞ$Hをえらひ<LP><LP>$Kﾞ<NL>", \
	"$H「$PＡ$Kホ<LP><LP>ﾞタン$H」て<LP><LP>$Kﾞ$P　", 38, 39, "$Hする。<NL>", 00 ;26 and 27 in P set
RadarTutText1: ;559B-55E9
	db  "$Hここは、$Kレータ<LP><LP>ﾞー$P基$H地。<NL>", \
	"$Kミサイル$Hなと<LP><LP>$Kﾞ$Hの$P補給$Hや<NL>", \
	"$P兵器$Hをそうひ<LP><LP>$Kﾞ$Hて<LP><LP>$Kﾞ$Hきる。<NL>", 00
	
;55EA: tutorial text pages??
db  1
db  "$Hようこそ、<NL>", \
	"$Kトレーニンク<LP><LP>ﾞアカテ<LP><LP>ﾞミー$Hへ$P！<NL>", \
	"$H私か<LP><LP>$Kﾞコーチ$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hっせんにそなえ、$Hここに、<NL>", \
	"$Kテタムス$H２を$P　$Hちゅうし<LP><LP><LP>$Kﾞ$Hつに<NL>", \
	"$H再$P現$Hした<NL>", "$Kシミュレーター$Hを、<NL>", \
	"$Hよういした。", 00
db  1
db  "$Hます<LP><LP>$Kﾞ$Hは<NL>", \
	"$Kスヘ<LP><LP>ﾟースタンク<NL>", \
	"$H「$PＶＩＸＩＶ$H」の<NL>", \
	"$P基本$Hきのうを<NL>", \
	"$Hせつめいしなか<LP><LP><LP>$Kﾞ$Hらの<NL>", \
	"$Kフリー$H走行を$P　$H行なう。<NL>", \
	"$PＶＩＸＩＶ$Hは<NL>", \
	"$H走行$Kシステム$Hに<NL>", \
	"$Kキ<LP><LP>ﾞア$Hほうしきを<NL>", \
	"$Hさいようしている。<NL>", 00
db  1
db  "$Hていし$P　$Hし<LP><LP>$Kﾞ$Hょうたいから<NL>", \
	"$P十$Kホ<LP><LP>ﾞタン$Hを$P　$H上に$P押$Hすたひ<LP><LP>$Kﾞ$H、<NL>", \
	"$PＬＯＷ$H、$PＭＥＤ$H、$PＨＩＧＨ$Hの<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hゅんに、$Kキ<LP><LP>ﾞア$Hか<LP><LP>$Kﾞ<NL>", \
	"$Hきりかわる。<NL>", \
	"$Hまた、上へ$P押$Hしつつ<LP><LP>$Kﾞ$Hけると<NL>", \
	"$Kターホ<LP><LP>ﾞスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hか<LP><LP>$Kﾞ$P　$Hえられ<NL>", \
	"$P下$Hへ$P押$Hしつつ<LP><LP>$Kﾞ$Hけると<NL>", \
	"$Kハ<LP>ﾞック$Hて<LP><LP>$Kﾞ$Hきる。<NL>", 00
db  1
db  "$Kフィールト<LP><LP>ﾞ$Hへ出たら$P　$Hます<LP><LP>$Kﾞ$H、<NL>", \
	"$P十$Kホ<LP><LP>ﾞタン$Hを上へ<NL>", \
	"$H１<LP><LP>、２回$P押$Hし、<NL>", \
	"$PＬＯＷ$Hか$PＭＥＤ$Hの<NL>", \
	"$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hて<LP><LP>$Kﾞ$H進め。<NL>", \
	"$Hなれてきたら$P　ＨＩＧＨ$Hや、<NL>", \
	"$Kハ<LP>ﾞック$Hなと<LP><LP>$Kﾞ$Hも$P　$Hためせ。<NL>", \
	"$Hせんかいは、$P十$Kホ<LP><LP>ﾞタン$Hの<NL>", \
	"$P左右$Hて<LP><LP>$Kﾞ$P　$H行う。<NL>", 00
db  $FF
;58C9
db  "$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hは、", 00 ;text printed in tutorial!
;58DA
db  "$Hこの$Kメーター$Hにひょうし<LP><LP><LP>$Kﾞ$Hされる。", 00

;58F8
db  "$P十$Kホ<LP><LP>ﾞタン$Hの上$P下$Hて<LP><LP>$Kﾞ", 00
;5913
db  "$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hを$Kコントロール$Hせよ$P！", 00

;5932
db  "$Hこれは$PＶＩＸＩＶ$Hか<LP><LP>$Kﾞ$H向いている", 00
;594E
db  "$H方か<LP><LP>$Kﾞ$Hくをしめす、$Kコンハ<LP><LP>ﾟス$Hた<LP><LP>$Kﾞ$P！", 00

;5974
db  "$P十$Kホ<LP><LP>ﾞタン$Hの$P左右$Hて<LP><LP>$Kﾞ", 00
;598F
db  "$PＶＩＸＩＶ$Hはせんかいする。", 00

;59A1, this is played when taking damage
db  1
db  "$Hきをつけろ$P！<NL>", \
	"$Hふ<LP><LP>$Kﾞ$Hつかると<NL>", \
	"$PＶＩＸＩＶ$Hか<LP><LP>$Kﾞ<NL>", \
	"$Kタ<LP><LP>ﾞメーシ<LP><LP>ﾞ$Hをうけてしまう$P！<NL>", \
	"$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hちょうせいと<NL>", \
	"$P左右$Hのせんかいを<NL>", \
	"$P十$Kホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞ<NL>", \
	"$Hしんちょうに$P　$H行なえ$P！<NL>", 00
db  $FF
;5A31
db  "$Hこれは、$Kシールト<LP><LP>ﾞ$Hの<NL>", 00
;5A45
db "$Kタ<LP><LP>ﾞメーシ<LP><LP>ﾞメーター$Hた<LP><LP>$Kﾞ$H。", 00

;5A61
db  1
db  "$Kコックヒ<LP><LP>ﾟット$P中央$Hの<NL>", \
	"$H「$Kレータ<LP><LP>ﾞースクリーン$H」は<NL>", \
	"$PＶＩＸＩＶ$Hを$P　中$Hしんに、<NL>", \
	"$Hふきんの$Kフィールト<LP><LP>ﾞ$Hを、<NL>", \
	"$Hま上から見た$P　$Hようすを<NL>", \
	"$Hうつし出す。<NL>", \
	"$Hしゅういのものは、<NL>", \
	"$Kレータ<LP><LP>ﾞースクリーン$H上に<NL>", \
	"$P白$Hい$Kト<LP><LP>ﾞット$Hとして$P　$Hうつる。<NL>", 00
db  1
db  "$Kレータ<LP><LP>ﾞースクリーン$H上の<NL>", \
	"$Hくろい$Kエリア$Hか<LP><LP>$Kﾞ<NL>", \
	"$H君の「しかい」た<LP><LP>$Kﾞ$H。<NL>", \
	"$Hつまり、$P　$Hくろい$Kエリア$Hの<NL>", \
	"$P中$Hにある$Kト<LP><LP>ﾞット$Hのみを<NL>", \
	"$H君は、<NL>", \
	"$Kフロントカ<LP><LP>ﾞラス$Hこ<LP><LP>$Kﾞ$Hしに<NL>", \
	"$H見るわけた<LP><LP>$Kﾞ$H。<NL>", 00
db  1
db  "$Hて<LP><LP>$Kﾞ$Hは、$Kレータ<LP><LP>ﾞー$Hを見なか<LP><LP>$Kﾞ$Hら<NL>", \
	"$Hしゅういのものと<NL>", \
	"$PＶＩＸＩＶ$Hの、<NL>", \
	"$P位置$Hかんけいを、<NL>", \
	"$Hはあく$P　$Hするつもりて<LP><LP>$Kﾞ<NL>", \
	"$Hもう１<LP><LP>と<LP><LP>$Kﾞ<NL>", \
	"$Kフリー$H走行た<LP><LP>$Kﾞ$H。<NL>", 00
db  $FF

;5C26
db  "$Hこれか<LP><LP>$Kﾞレータ<LP><LP>ﾞー$Hた<LP><LP>$Kﾞ$P！", 00

;5C43
db  "$Hさまさ<LP><LP>$Kﾞ$Hまなふ<LP><LP><LP>$Kﾞ$Hったいは、", 00
;5C60
db  "$Kレータ<LP><LP>ﾞー$H上に$Kト<LP><LP>ﾞット$Hて<LP><LP>$Kﾞ$Hあらわされる$P！", 00

;5C89
db  1
db  "$Hけいこく$P音$Hか<LP><LP>$Kﾞ<NL>", "$Hなりた<LP><LP>$Kﾞ$Hしたら<NL>", \
	"$H「ていし」せよ$P！<NL>", \
	"$Hこれは、$P敵$Hとの接$P近$Hを<NL>", \
	"$Hしらせているのた<LP><LP>$Kﾞ$P！<NL>", \
	"$Kレータ<LP><LP>ﾞー$H上て<LP><LP>$Kﾞ$H、<NL>", \
	"$H「てんめつする$Kト<LP><LP>ﾞット$H」か<LP><LP>$Kﾞ$H、<NL>", \
	"$P敵$Hた<LP><LP>$Kﾞ$P！<NL>", 00
db  1
db  "$Hたた<LP><LP>$Kﾞ$Hちにていしし、<NL>", \
	"$H「$P止$Hったまま」<NL>", \
	"$Hてんめつする$Kト<LP><LP>ﾞット$Hか<LP><LP>$Kﾞ<NL>", \
	"$H「$Kレータ<LP><LP>ﾞー$Hのま上」に<NL>", \
	"$H来るまて<LP><LP>$Kﾞ$Hせんかいせよ$P！<NL>", \
	"$P正面$Hに$P敵$Hか<LP><LP><LP>$Kﾞ<NL>", \
	"$H見えるはす<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$H。", 00
db  $FF

;5DB8
db  "$Hこの$Kランフ<LP><LP>ﾟ$Hか<LP><LP>$Kﾞ$Hてんめつする時", 00
;5DD6
db  "$P敵$Hは$P近$Hくにいる、ていしせよ$P！<NL>", 00

;5DF0
db  "$Kレータ<LP><LP>ﾞー$H上のてんめつする", 00
;5E04
db  "$Kト<LP><LP>ﾞット$Hか<LP><LP>$Kﾞ$P敵$Hた<LP><LP>$Kﾞ$P！", 00

;5E23
db  "$Hせんかいし、$P敵$Hに", 00
;5E32
db  "$H照準を合わせろ", 00

;5E3C
db  "$Hよし$P！", 00
;5E44
db  "$Hゆっくりと$P敵$Hに$P近$Hつ<LP><LP>$Kﾞ$Hけ$P！", 00

;5E63
db  "$P十$Kホ<LP><LP>ﾞタン$Hを１<LP><LP>と<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$Hけ上におし", 00
;5E8A
db  "$PＬＯＷ$Hて<LP><LP>$Kﾞ$H進め$P！", 00

;5E9F
db  "$Hあるていと<LP><LP>$Kﾞ$P近$Hつ<LP><LP>$Kﾞ$Hいたら", 00
;5EBC
db "$Hていしせよ$P！", 00

;5EC7, too close!
db  "$P近$Hつ<LP><LP>$Kﾞ$Hきすき<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$P！", 00

;5EE8, briefing
db  1
db  "$PＶＩＸＩＶ$Hは<NL>", \
	"$H「$Kレーサ<LP><LP>ﾞーヒ<LP><LP>ﾞーム$H」を<NL>", \
	"$Hそうひ<LP><LP>$Kﾞ$Hしている。<NL>", \
	"$P敵$Hに照準を合わせ<NL>", \
	"$H「$PＡ$Kホ<LP><LP>ﾞタン$H」て<LP><LP>$Kﾞ$H発$P射$Hする$P！<NL>", \
	"$P敵$Hの$P　$Hはかいには、<NL>", \
	"$Hすう回のこうけ<LP><LP>$Kﾞ$Hきか<LP><LP><LP>$Kﾞ<NL>", \
	"$Hひつようた<LP><LP>$Kﾞ$H。", 00
db  $FF

;5F8B
db  "$H今た<LP><LP>$Kﾞ$P！敵$Hをうて$P！", 00

;5FA1
db  "$PＡ$Kホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞレーサ<LP><LP>ﾞーヒ<LP><LP>ﾞーム$Hを", 00
;5FC5
db  "$H発$P射$Hせよ$P！", 00

;5FD3, briefing
db  1
db  "$Hよくやった$P！<NL>", \
	"$P敵$Hなと<LP><LP>$Kﾞ$Hの$P　$Hほとんと<LP><LP>$Kﾞ$Hは、<NL>", \
	"$Hその破片て<LP><LP>$Kﾞ<NL>", \
	"$Kホ<LP><LP>ﾞーナスキャラクター$Hを<NL>", \
	"$H作りた<LP><LP>$Kﾞ$Hす。<NL>", \
	"$Hこの$Kタンク$Hの$P場$H合は<NL>", \
	"$Kマッシュルーム$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hこの$Kマッシュルーム$Hによって<NL>", \
	"$PＶＩＸＩＶ$Hは$Kシールト<LP><LP>ﾞ$Hを<NL>", \
	"$H回ふくて<LP><LP>$Kﾞ$Hきる。<NL>", 00
db  1
db  "$Kマッシュルーム$Hに<NL>", \
	"$H照準を合わせ<NL>", "$P近$Hつ<LP><LP>$Kﾞ$Hけは<LP><LP>$Kﾞ$H、<NL>", \
	"$H「$Kトラクターヒ<LP><LP>ﾞーム$H」という<NL>", \
	"$Hとくしゅこうせんて<LP><LP>$Kﾞ$H、<NL>", \
	"$Hし<LP><LP><LP>$Kﾞ$Hと<LP><LP>$Kﾞ$Hうてきに$P　$Hひろえる、<NL>", \
	"$Hやってみなさい。<NL>", 00
db  $FF

;611F
db  "$P正面$Hから接$P近$Hし、", 00
;6130
db  "$Kマッシュルーム$Hをひろえ$P！", 00

;6143, briefing
db  1
db  "$Kマッシュルーム$Hは、<NL>", \
	"$Hひろえたかね？<NL>", \
	"$Hて<LP><LP>$Kﾞ$Hは$P　$Hつき<LP><LP>$Kﾞ$Hの、<NL>", \
	"$Kトレーニンク<LP><LP>ﾞ$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hこんと<LP><LP>$Kﾞ$Hの$Kタンク$Hは、<NL>", \
	"$Hうこ<LP><LP>$Kﾞ$Hいている。<NL>", \
	"$Hついせきし、はかいせよ$P！<NL>", 00
db  1
db  "$P敵$Hを$P　$Hついせきする$P場$H合<NL>", \
	"$Hなと<LP><LP>$Kﾞ$Hは、<NL>", \
	"$Kハ<LP><LP>ﾞックキ<LP><LP>ﾞア$Hの<NL>", \
	"$Hうまい$P　$Hかつようか<LP><LP>$Kﾞ<NL>", \
	"$Hゆうこうた<LP><LP>$Kﾞ$P！<NL>", 00
db  $FF

;6228
db  "$Hます<LP><LP>$Kﾞ$H、$P敵$Hに", 00
;623A
db  "$H照準を合わせろ$P！", 00

;6248
db  "$PＬＯＷ$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hて<LP><LP>$Kﾞ<NL>", 00
;6263
db  "$H接$P近$Hせよ$P！", 00

;6271 used in a couple places
db  "$Hよし$P！　$Hよくやったそ<LP><LP>$Kﾞ$P！", 00

;628A
db  "$H今た<LP><LP>$Kﾞ$H、発$P射$Hせよ$P！", 00

;62A2, briefing
db  1
db  "$H見うしなってしまったか。<NL>", \
	"$Hふふ、また<LP><LP>$Kﾞ$P　$Kアマ$Hいな・・・<NL>", \
	"$P敵$Hをついせきする時は、<NL>", \
	"$Hつねにあいてを<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hふ<LP><LP>$Kﾞ$Hんのしかいの$P中$Hへ<NL>", \
	"$Kキーフ<LP><LP>ﾟ$Hせよ。<NL>", \
	"$Hはやすき<LP><LP>$Kﾞ$Hる$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hは<NL>", \
	"$Hきんもつた<LP><LP>$Kﾞ$P！<NL>", \
	"$Hもう１<LP><LP>と<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$P！<NL>", 00
db  $FF

;635D, briefing
db  1
db  "$Hふむ、$P　$Hなかなかやるな。<NL>", \
	"$Hさすか<LP><LP>$Kﾞ$Hは$P　$Hえらは<LP><LP>$Kﾞ$Hれた<NL>", \
	"$Hせんし、た<LP><LP>$Kﾞ$H。<NL>", \
	"$Hつき<LP><LP>$Kﾞ$Hの$Kステッフ<LP><LP>ﾟ$Hへ$P　$H進もう。<NL>", \
	"$Hし<LP><LP><LP>$Kﾞ$Hっせんて<LP><LP>$Kﾞ$Hは、<NL>", \
	"$P強力$Hな$P兵器$Hを<NL>", \
	"$Hそうひ<LP><LP>$Kﾞ$Hするために・・<NL>", 00
db  1
db  "$H「$Kレータ<LP><LP>ﾞー$P基$H地」という<NL>", \
	"$Hたてものに<NL>", \
	"$P入$Hる$P　$Hひつようか<LP><LP>$Kﾞ$Hある。<NL>", \
	"$Kテタムス$H２の$P　<NL>", \
	"$P各$Kエリア$Hこ<LP><LP>$Kﾞ$Hとにある、<NL>", \
	"$H施設の１<LP><LP><LP>つた<LP><LP>$Kﾞ$H。<NL>", \
	"$P入$Hり$Kロ$Hの$P　$H方にある<NL>", \
	"$H２$P本$Hの$Kケ<LP><LP>ﾞート$Hか<LP><LP>$Kﾞ$H、$P入$Hる時の<NL>", \
	"$Hめやす$P　$Hとなる。<NL>", 00
db  1
db  "$P基$H地に$P入$Hる$P場$H合、<NL>", \
	"$Hます<LP><LP>$Kﾞ$H、２$P本$Hの$Kケ<LP><LP>ﾞート$Hの<NL>", \
	"$H「$P中$H間て<LP><LP>$Kﾞ$P　$Hていし」せよ。<NL>", \
	"$Hそして、$P基$H地の$P入$Hり$Kロ$Hに<NL>", \
	"$H照準か<LP><LP><LP>$Kﾞ$Hあうまて<LP><LP>$Kﾞ<NL>", \
	"$Hせんかいせよ$P！<NL>", \
	"$Hそのまま$P　$H前進すれは<LP><LP>$Kﾞ<NL>", \
	"$P基$H地に$P入$Hれる。<NL>", 00
db  1
db  "$P中$Hて<LP><LP>$Kﾞ$Hは<NL>", "$P基$H地にかんする<NL>", \
	"$Hし<LP><LP><LP>$Kﾞ$Hゅうようなせつめいか<LP><LP><LP>$Kﾞ<NL>", \
	"$H行なわれる。<NL>", \
	"$P中央$Hの$Kホ<LP><LP>ﾞート<LP><LP>ﾞ$Hの<NL>", \
	"$Hないようを、<NL>", "$Hかくし<LP><LP>$Kﾞ$Hつに<NL>", \
	"$Hりかいしなさい。", 00
db  $FF

;65EF
db  "$H照準をここへ合わせる。", 00

;65FD, low speed plz
db  "$PＬＯＷ$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hて<LP><LP>$Kﾞ$H進め。", 00

;661C
db  "$H２$P本$Hの$Kケ<LP><LP>ﾞート$Hの<NL>", 00
;6632
db  "$H間て<LP><LP>$Kﾞ$Hていしせよ$P！", 00

;6646
db  "$Hせんかいし、照準を<NL>", 00
;6653
db  "$P基$H地の$P入$Hり$Kロ$Hに合わせろ$P！", 00

;666E
db  "$H前進し、$P基$H地に$P入$Hれ", 00
;6682
db  00

;6683
db  "$Kレータ<LP><LP>ﾞー$P基$H地に$P入$Hり", 00
;669A
db  "$Kロックオン$Hをそうひ<LP><LP>$Kﾞ$Hせよ$P！", 00
;66B4
db  00

;66B5, briefing
db  1
db  "$Hよし$P！<NL>", "$Hて<LP><LP>$Kﾞ$Hは$P　$H「$Kロックオン$H」の<NL>", \
	"$Hせつめいを$P　$H行う$P！<NL>", \
	"$Kミサイル$Hて<LP><LP>$Kﾞ$Hなけれは<LP><LP>$Kﾞ<NL>", \
	"$Hはかいて<LP><LP>$Kﾞ$Hきない$P敵$Hを<NL>", \
	"$Hたおすための、<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hゅうような<NL>", \
	"$Kトレーニンク<LP><LP>ﾞ$Hた<LP><LP>$Kﾞ$P！<NL>", 00
db  1
db  "$Hもし、$Kロックオン$Hを<NL>", \
	"$Hまた<LP><LP>$Kﾞ$P　$Hそうひ<LP><LP>$Kﾞ$Hして<NL>", \
	"$Hいなけれは<LP><LP>$Kﾞ$H、<NL>", "$Hもう１<LP><LP><LP>と<LP><LP>$Kﾞ<NL>", \
	"$Kレータ<LP><LP>ﾞー$P基$H地に$P入$Hり<NL>", \
	"$P右$Hか<LP><LP><LP>$Kﾞ$Hわの$Kメニュー$Hの<NL>", \
	"$H１<LP><LP>は<LP><LP>$Kﾞ$Hん$P　$H上にある<NL>", \
	"$Kロックオン$Hをそうひ<LP><LP>$Kﾞ$Hし、<NL>", \
	"$Hふたたひ<LP><LP>$Kﾞフィールト<LP><LP>ﾞ$Hに<NL>", \
	"$Hもと<LP><LP>$Kﾞ$Hりなさい。<NL>", 00
db  $FF

;6825
db  "$Kテスト$H用に", 00
;682F
db  "$Kミサイル$Hを$Kフル$Hそうひ<LP><LP>$Kﾞ$Hした。", 00

;684C
db  "$P止$Hったまま$P　$Hせんかいし<NL>", 00
;6861
db  "$P敵$Hに照準をあわせろ$P！", 00

;6872, brief
db  1
db  "$Kミサイル$Hを発$P射$Hするために、<NL>", \
	"$Hます<LP><LP>$Kﾞ$P敵$Hに$Kロックオン$Hをする。<NL>", \
	"$P敵$Hに照準を<NL>", \
	"$H合わせたまま、$PＬＯＷ$Hか<NL>", \
	"$PＭＥＤ$Kキ<LP><LP>ﾞア$Hて<LP><LP>$Kﾞ$P近$Hつ<LP><LP>$Kﾞ$Hけ。<NL>", \
	"$Hしんこ<LP><LP>$Kﾞ$Hう$P音$Hとともに<NL>", \
	"$Kフロントカ<LP><LP><LP>ﾞラス$Hの$Kスミ$Hに<NL>", \
	"$Kカーソル$Hか<LP><LP><LP>$Kﾞ$H、あらわれたら<NL>", \
	"$Hあいす<LP><LP>$Kﾞ$Hする、<NL>", \
	"$Hそこて<LP><LP>$Kﾞ$H「$PＢ$Kホ<LP><LP>ﾞタン$H」を$P押$Hせ$P！<NL>", 00
db  1
db  "$Hうまく$Kロックオン$Hて<LP><LP>$Kﾞ$Hきたら<NL>", \
	"$P敵$Hのうしろに回りこみ、<NL>", \
	"$Hついせきせよ。<NL>", \
	"$Hそして、私の指$P示$Hを$P　$Hまて。<NL>", \
	"$H君か<LP><LP><LP>$Kﾞ$H、りそうてきな<NL>", \
	"$Kホ<LP><LP>ﾟシ<LP><LP><LP>ﾞション$Hにつけたら、<NL>", \
	"$Hあいす<LP><LP>$Kﾞ$Hする。<NL>", \
	"$Hそこて<LP><LP>$Kﾞ$H「$PＢ$Kホ<LP><LP>ﾞタン$H」を$P押$Hせ$P！<NL>", \
	"$Kミサイル$Hか発$P射$Hされる$P！<NL>", 00
db  $FF

;6A2B
db  "$Kタンク$Hに照準を合わせ<NL>", 00
;6A3A
db  "$Hゆっくりと$P近$Hつ<LP><LP>$Kﾞ$Hけ$P！", 00

;6A54
db  "$PＢ$Kホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞロックオン$Hせよ$P！", 00

;6A74
db  "$Hよし、今た<LP><LP>$Kﾞ", 00
;6A71
db  "$Hもう１<LP><LP>と<LP><LP>$Kﾞ$PＢ$Kホ<LP><LP>ﾞタン$Hを$P押$Hせ$P！", 00

;6AA6
db  "$Hよし$P！　$Kロックオン$P　$Hせいこうた<LP><LP>$Kﾞ$P！", 00
;6AC8
db  "$Hうしろから", 00
;6AD0
db  "$H「$PＬＯＷ$Kキ<LP><LP>ﾞア$H」て<LP><LP>$Kﾞ$P　$Hついせきせよ$P！", 00

;6AF7, brief unused??
db  1
db  "$Hは<LP><LP>$Kﾞ$Hかやろう$P！！　$Kヒ<LP><LP>ﾞシッ$P！<NL>", \
	"$H指$P示$Hと<LP><LP>$Kﾞ$Hうりに<NL>", \
	"$Hこうと<LP><LP>$Kﾞ$Hうしろ$P！！<NL>", \
	"$Hかるはす<LP><LP>$Kﾞ$Hみなこうと<LP><LP>$Kﾞ$Hうは<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hっせんて<LP><LP>$Kﾞ$Hは<NL>", \
	"$Hいのちとりになるそ<LP><LP>$Kﾞ$P！<NL>", \
	"$Kロックオン$Hしたら<NL>", \
	"$Hつき<LP><LP>$Kﾞ$Hの指$P示$Hを$P　$Hまて$P！<NL>", 00
db  $FF

;6BB3, briefing
db  1
db  "$Hて<LP><LP>$Kﾞ$Hは、つき<LP><LP>$Kﾞ$Hの$Kレッスン$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$PＶＩＸＩＶ$Hには<NL>", \
	"$H「$Kオートファインタ<LP><LP>ﾞー$H」<NL>", \
	"$Kシステム$Hという、<NL>", \
	"$Hきのうか<LP><LP>$Kﾞ$Hある。<NL>", \
	"$Hこれは$P　$H１しゅの<NL>", \
	"$Hたんちそうちて<LP><LP>$Kﾞ<NL>", \
	"$Hあらゆる$P　$Hし<LP><LP>$Kﾞ$Hょうきょうに<NL>", \
	"$Hし<LP><LP><LP>$Kﾞ$Hと<LP><LP>$Kﾞ$Hう$P　対応$Hする。<NL>", \
	"$Hこの$Kシステム$Hは$P　$H君を・・・<NL>", 00
db  1
db  "$Hし<LP><LP><LP>$Kﾞ$Hっせんて<LP><LP>$Kﾞ$Hの<NL>", \
	"$P各$Kミッション$Hに$P　$Hおいて<NL>", \
	"$H君か<LP><LP>$Kﾞ$P　$Hさか<LP><LP>$Kﾞ$Hすへ<LP><LP>$Kﾞ$Hき<NL>", \
	"$P敵$Hなと<LP><LP>$Kﾞ$Hの$P　位置$Hまて<LP><LP>$Kﾞ<NL>", \
	"$Hみちひ<LP><LP>$Kﾞ$Hいてくれる。<NL>", \
	"$Hたた<LP><LP>$Kﾞ$Hし・・・<NL>", \
	"$Hかんちて<LP><LP>$Kﾞ$Hきるきょりには<NL>", \
	"$Hけ<LP><LP>$Kﾞ$Hんかいか<LP><LP>$Kﾞ$Hあることに<NL>", \
	"$Hちゅういせよ。<NL>", 00
db  1
db  "$Hて<LP><LP>$Kﾞ$Hは$P　$Hためしてみよう。<NL>", \
	"$Kシミュレーター$H上の<NL>", \
	"$Kフィールト<LP><LP>ﾞ$Hのと<LP><LP>$Kﾞ$Hこかに、<NL>", \
	"$H１<LP><LP>$P本$Hの$Kミサイル$Hを<NL>", \
	"$Hはいちした。<NL>", \
	"$H今回、$Kファインタ<LP><LP>ﾞー$Hは<NL>", \
	"$Kミサイル$Hに$Kセット$Hされている。<NL>", \
	"$Kフィールト<LP><LP>ﾞ$Hに$P　$H出ると<NL>", \
	"$P白$Hい小さな$P　$Kカーソル$Hか<LP><LP>$Kﾞ$H・・<NL>", 00
db  1
db  "$Kフロントカ<LP><LP>ﾞラス$Hの<NL>", \
	"１<LP><LP>は<LP><LP>$Kﾞ$Hん$P下$Hに<NL>", \
	"$Hしんこ<LP><LP>$Kﾞ$Hう$P音$Hと$P　$Hともに<NL>", \
	"$Hあらわれる。<NL>", \
	"$Hます<LP><LP>$Kﾞ$H「ていし$P　$Hしたまま」<NL>", \
	"$Kカーソル$Hか<LP><LP>$Kﾞ$P　$Hきえた方向に<NL>", \
	"$Hせんかいせよ。<NL>", \
	"$Hそして$Kカーソル$Hか<LP><LP>$Kﾞ<NL>", \
	"$Hふたたひ<LP><LP>$Kﾞ$Hあらわれたら、<NL>", \
	"$H指$P示$Hに$P　$Hしたか<LP><LP>$Kﾞ$Hえ。<NL>", 00
db  $FF

;6EE6
db  "$H「ていし」し、$Kカーソル$Hか<LP><LP>$Kﾞ<NL>",  00
;6EFF
db  "$Hあらわれるまて<LP><LP>$Kﾞ$Hせんかいせよ$P！", 00

;6F19
db  "$Kカーソル$Hか<LP><LP>$Kﾞ$Hつねに", 00
;6F2D
db  "$Kセンター$Hに来るようにしつつ", 00
;6F3F
db  "$H「ゆっくり」前進せよ$P！", 00

;6F4F
db  "$Hよし$P！", 00
;6F57
db  "$Kミサイル$Hを$P手$Hに$P入$Hれたそ<LP><LP>$Kﾞ$P！", 00

;6F77, briefing
db  1
db  "$Hよし、て<LP><LP>$Kﾞ$Hは$P　$Hつき<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$Kテタムス$H２には<NL>", \
	"$H地$P下$Hいと<LP><LP>$Kﾞ$Hう$P　$Hのために、<NL>", \
	"$H「$Kトンネルネットワーク$H」<NL>", \
	"$Hという$P　$Hせつひ<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ$Hある。<NL>", \
	"$H「$Kトンネルエントランス$H」<NL>", \
	"$Hという<NL>", "$Hかいてんする<NL>", \
	"出$P入$Hり$Kロ$Hを<NL>", "$Hもつ、<NL>", \
	"$H４$P本$Hの$Kトンネル$Hは・・・<NL>", 00
db  1
db  "$P全$Hて、<NL>", \
	"$H「$Kシ<LP><LP>ﾞャンクション$H」という<NL>", \
	"$P中央$H施設へと<NL>", \
	"$Hつうし<LP><LP><LP>$Kﾞ$Hている。<NL>", "$Hもちろん、<NL>", \
	"$Kシ<LP><LP>ﾞャンクション$Hから<NL>", \
	"$Hと<LP><LP>$Kﾞ$Hの$Kエントランス$Hへも<NL>", \
	"$Kトンネル$Hをとおって<NL>", \
	"$Hいと<LP><LP>$Kﾞ$Hう可$P能$Hた<LP><LP>$Kﾞ$H。<NL>", 00
db  1
db  "$H君は、つき<LP><LP>$Kﾞ$Hの$Kレッスン$Hて<LP><LP>$Kﾞ$H、<NL>", \
	"$Kシミュレーター$H上に、<NL>", \
	"$H再$P現$Hされた<NL>", \
	"$Kトンネルネットワーク$Hを<NL>", \
	"$Hたいけんする。<NL>", \
	"$Kトンネル$P内$Hの<NL>", \
	"そうし<LP><LP>$Kﾞ$Hゅうには<NL>", \
	"$Hちゅういか<LP><LP>$Kﾞ$P　$Hひつようた<LP><LP>$Kﾞ$H、<NL>", \
	"$Hせつめいしよう。<NL>", 00
db  1
db  "$Kトンネル$Hの$P中$Hて<LP><LP>$Kﾞ$Hは<NL>", \
	"$H「$P十$Kホ<LP><LP>ﾞタン$Hの上$P下$H」て<LP><LP>$Kﾞ<NL>", \
	"$PＶＩＸＩＶ$Hの「$P高$Hさ」を<NL>", \
	"$Hちょうせいする。<NL>", \
	"$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hは、$P変化$Hしない。<NL>", \
	"$Kホ<LP><LP>ﾞタン$Hを$P　下$Hに$P押$Hすと、<NL>", \
	"$PＶＩＸＩＶ$Hは「上しょう」し、<NL>", \
	"$H上に$P押$Hすと「$P下$Hこう」する。<NL>", \
	"$Hせんかいは、いつもと<LP><LP>$Kﾞ$Hうり<NL>", \
	"$P左右$Hて<LP><LP>$Kﾞ$H行なえ。<NL>", 00
db  1
db  "$Kトンネル$Hをぬけると、<NL>", \
	"$Kシ<LP><LP>ﾞャンクション$Hの<NL>", "$P中$Hた<LP><LP>$Kﾞ$H。<NL>", \
	"$H「$P補給$H施設」を$P　$Hえらふ<LP><LP>$Kﾞ$Hと<NL>", \
	"$Kミサイル$H、ねんりょう、<NL>", \
	"$Kシールト<LP><LP>ﾞ$Hのうち<NL>", \
	"$Hいす<LP><LP>$Kﾞ$Hれかひとつの<NL>", \
	"$H「$Kフルチャーシ<LP><LP>ﾞ$H」か<LP><LP>$Kﾞ$Hて<LP><LP>$Kﾞ$Hきる。<NL>", \
	"$Hためしたまえ、そして・・・<NL>", 00
db  1
db  "$H「$PＥＸＩＴ$Kヘ<LP><LP>ﾞース$H」<NL>", \
	"$Hを$P　$Hえらひ<LP><LP>$Kﾞ$H、<NL>", \
	"$Kシ<LP><LP>ﾞャンクション$Hから出ろ。<NL>", \
	"$Hまた「$Kセレクトトンネル$H」て<LP><LP>$Kﾞ<NL>", \
	"$Hきほ<LP><LP>$Kﾞ$Hうする<NL>", \
	"$Kエントランス$Hから<NL>", \
	"$H出てもよい。$P　$Hか<LP><LP>$Kﾞ$H、<NL>", \
	"$Hひと<LP><LP>$Kﾞ$Hい$P　$Kタ<LP><LP>ﾞメーシ<LP><LP>ﾞ$Hを<NL>", \
	"$Hうけたら、さいしょの<NL>", \
	"$Kトンネル$Hから$P　$Hやりなおした<LP><LP>$Kﾞ$H。<NL>", 00
db  $FF

;73E9
db  "$Hこれか<LP><LP>$Kﾞトンネル$Hの出$P入$Hり$Kロ", 00
;7405
db  "$Kトンネルエントランス$Hた<LP><LP>$Kﾞ$P！", 00

;741D
db  "$Kトンネル$Hは$Kシ<LP><LP>ﾞャンクション$Hに", 00
;7436
db  "$Hつうし<LP><LP><LP>$Kﾞ$Hている。", 00

;7448
db  "$Kタイミンク<LP><LP>ﾞ$Hをはかり", 00
;7459
db  "$Hすは<LP><LP>$Kﾞ$Hやく$P入$Hれ$P！", 00
;7470
db  00

;7471
db  "$Kトンネル$Hに$P　$Hそって", 00
;7483
db  "$H進め$P！", 00

;748B
db  "$H今、$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞコントロール$Hは", 00
;74A5
db  "$H出来ない$P！", 00

;74AF, used in tunnel AND flight tutorials
db  "$P十$Kホ<LP><LP>ﾞタン$Hの上$P下$Hて<LP><LP>$Kﾞ", 00
;74CA
db  "$P高$Hさを$P　$Kコントロール$Hせよ$P！", 00

;74E4
db  "$Hかへ<LP><LP><LP>$Kﾞ$Hにふ<LP><LP>$Kﾞ$Hつかると", 00
;74FE
db  "$Kタ<LP><LP>ﾞメーシ<LP><LP>ﾞ$Hをうけるそ<LP><LP>$Kﾞ$P！", 00

;751A, breifing
db  1
db  "$Hよし、君に<NL>", \
	"$Kテタムス$H２の$P　$H「$Kマッフ<LP><LP>ﾟ$H」を<NL>", \
	"$Hみせよう。<NL>", \
	"$Hこの$Kマッフ<LP><LP>ﾟ$Hをみれは<LP><LP>$Kﾞ<NL>", \
	"$Kトンネル$Hと<NL>", \
	"$Kシ<LP><LP>ﾞャンクション$Hの<NL>", \
	"$P位置$Hかんけいか<LP><LP>$Kﾞ$H、<NL>", \
	"$Hかくにんて<LP><LP>$Kﾞ$Hきる。<NL>", 00
db  1
db  "$Hさらに、走行$P中$Hの<NL>", \
	"$H「$Kエリアナンハ<LP><LP>ﾞー$H」なと<LP><LP>$Kﾞ$Hか<LP><LP>$Kﾞ<NL>", \
	"$Hわかる。<NL>", \
	"$Hて<LP><LP>$Kﾞ$Hは$P　$H「$Kスタートホ<LP><LP>ﾞタン$H」を<NL>", \
	"$P押$Hしてみなさい。<NL>", \
	"$Hよく$P　$Hみたら、<NL>", \
	"$Hもういちと<LP><LP>$Kﾞ<NL>", \
	"$Kスタートホ<LP><LP>ﾞタン$Hを<NL>", \
	"$P押$Hしなさい。<NL>", 00
db  $FF

;7641, briefing
db  1
db  "$Kマッフ<LP><LP>ﾟ$H上て<LP><LP>$Kﾞ<NL>", \
	"$Hてんめつしていた<NL>", \
	"$H「$P十字$Hの$Kカーソル$H」か<LP><LP>$Kﾞ<NL>", \
	"$PＶＩＸＩＶ$Hか<LP><LP>$Kﾞ$Hいる<NL>", \
	"$Kホ<LP><LP>ﾟシ<LP><LP>ﾞション$Hを$P示$Hす。<NL>", \
	"$Kマッフ<LP><LP>ﾟ$Hは$P　$Kテタムス$H２を、<NL>", \
	"$H「へいめんに$P　$Hてんかい」<NL>", \
	"$Hした$P　$Hものた<LP><LP>$Kﾞ$H。<NL>", \
	"$H「$Kスタートホ<LP><LP>ﾞタン$H」て<LP><LP>$Kﾞ<NL>", \
	"$Hみることか<LP><LP>$Kﾞ$P　$Hて<LP><LP>$Kﾞ$Hきる。<NL>", 00
db  1
db  "$Hさて$Kトレーニンク<LP><LP>ﾞ$Hも、<NL>", \
	"$Hおわりに$P　近$Hつ<LP><LP>$Kﾞ$Hいた。<NL>", \
	"$PＶＩＸＩＶ$Hは<NL>", \
	"$P空中$Hせんにそなえ、<NL>", \
	"$H「ひこう$P　$Hきのう」を、もつ。<NL>", \
	"$Hさいこ<LP><LP>$Kﾞ$Hの$Kレッスン$Hは<NL>", \
	"$Hひこうくんれんた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hひこう$P中$Hのそうさは<NL>", \
	"$Kトンネル$Hの$P中$Hと<NL>", \
	"$Hほほ<LP><LP>$Kﾞ$P同$Hし<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$H。<NL>", 00
db  1
db  "$Hひこうには<NL>", "$P十$Kホ<LP><LP>ﾞタン$Hを上に<NL>", \
	"$P押$Hしつつ<LP><LP>$Kﾞ$Hけた時の<NL>", \
	"$Hさいこうそくと<LP><LP>$Kﾞ$H、<NL>", \
	"$H「$Kターホ<LP><LP>ﾞスヒ<LP><LP>ﾟート<LP><LP>ﾞ$H」を使う。<NL>", \
	"$Hこの$Kスヒ<LP><LP>ﾟート<LP><LP>ﾞ$Hのまま<NL>", \
	"$Kヒ<LP><LP>ﾟラミット<LP><LP>ﾞ$P型$Kオフ<LP><LP>ﾞシ<LP><LP>ﾞェ$Hの<NL>", \
	"$Hけいしゃをりようして<NL>", \
	"$Hりりくするのた<LP><LP>$Kﾞ$P！<NL>", 00
db  1
db  "$Hさらにもうひとつ、<NL>", \
	"$Kターホ<LP><LP>ﾞスヒ<LP><LP>ﾟート<LP><LP>ﾞ$P中$Hは<NL>", \
	"$Hねんりょうを$P　$Hしょうひ<NL>", \
	"$Hすることを、<NL>", \
	"$Hおほ<LP><LP>$Kﾞ$Hえておけ。<NL>", \
	"$Hしたか<LP><LP>$Kﾞ$Hって$P　$Hひこうには、<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hゅうふ<LP><LP>$Kﾞ$Hんな<NL>", \
	"$Hねんりょうか<LP><LP>$Kﾞ$P　$Hひつようた<LP><LP>$Kﾞ$H、<NL>", \
	"$Hねんりょう$Kメーター$Hに<NL>", \
	"$Hちゅういせよ。<NL>", 00
db  1
db  "$Hまた、ひこう$P中$Hは<NL>", \
	"$H地上の$P　$Hものを<NL>", \
	"$H見おとしやすい$P　$Hのて<LP><LP>$Kﾞ<NL>", \
	"$Hし<LP><LP>$Kﾞ$Hっせんて<LP><LP>$Kﾞ$Hは<NL>", \
	"$Hむやみに$P　$Hとは<LP><LP>$Kﾞ$Hないほうか<LP><LP>$Kﾞ<NL>", \
	"$Hよい$P　$Hた<LP><LP>$Kﾞ$Hろう。<NL>",  00
db  $14 ;???
db  "$Hて<LP><LP>$Kﾞ$Hは、<NL>", \
	"$Hさいしゅうくんれんを<NL>", \
	"$P開始$Hする$P！！<NL>", 00
db  $FF

;7A00
db  "$P十$Kホ<LP><LP>ﾞタン$Hの上を$P押$Hしたまま<NL>", 00
;7A1B
db  "$Kヒ<LP><LP>ﾟラミット<LP><LP>ﾞ$Hにつっこめ$P！", 00

;7A33
db  "$Hよし$P！", 00
;7A3B
db  "$H今、とひ<LP><LP>$Kﾞ$Hたった。", 00

;7A4D
db  "$Hこれはこうと<LP><LP>$Kﾞメーター$Hた<LP><LP>$Kﾞ$P！", 00
;7A6A
db  00

;7A6B
db  "$Kターホ<LP><LP>ﾞ$Hはねんりょうをしょうひする", 00
;7A83
db  "$Hひこうの時も$P同$Hし<LP><LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$P！", 00


;7AA3, briefing
db  1
db  "$Hよし<NL>", "$H君は合格た<LP><LP>$Kﾞ$P！<NL>", \
	"$Kワーフ<LP><LP>ﾟトンネル$Hて<LP><LP>$Kﾞ<NL>", \
	"$Kテタムス$H２へ<NL>", \
	"$H向かってくれ$P！<NL>", \
	"$Hすて<LP><LP>$Kﾞ$Hにさいしょの<NL>", \
	"$Kミッション$Hか<LP><LP>$Kﾞ<NL>", \
	"$H君のとうちゃくを<NL>", \
	"$Hまっているらしい。<NL>", 00
db  1
db  "$Hくれく<LP><LP>$Kﾞ$Hれもちゅういし、<NL>", \
	"$H任務をはたして<NL>", \
	"$Hくれたまえ。<NL>", \
	"$Hて<LP><LP>$Kﾞ$Hは、またあおう、<NL>", \
	"$Hこううんを祈る$P！<NL>", 00
db  $14
db  "$Kスヘ<LP><LP>ﾟースタンク$P　ＶＩＸＩＶ<NL>", \
	"$H発進せよ$P！！！<NL>", 00
db  $FF


;7B8D
db  "$Kミサイル$Hを使いはたした$P！", 00
;7BA0
db  00

;7BA1, says to stop and turn to face the enemy
db  "$P止$Hって、$P敵$Hの方に", 00
;7BB2
db  "$H向きをかえろ$P！", 00

;7BBE
db  "$Hこら$P！！", 00
;7BC7
db  "$H私のいうことを$P　$Hきけ$P！<NL>", 00

;7BDC
db  "$H「ていし」し、$Kカーソル$Hか<LP><LP>$Kﾞ", 00
;7BF4
db  "$Hあらわれるまて<LP><LP>$Kﾞ$P　$Hせんかいせよ$P！", 00

;7C11
db  "$Hそうひ<LP><LP>$Kﾞ$Hする$P兵器$Hを", 00
;7C27
db  "$Hまちか<LP><LP>$Kﾞ$Hえているそ<LP><LP>$Kﾞ$P！", 00
;7C41
db  00

;7C42
db  "$Kレータ<LP><LP>ﾞー$P基$H地に$P入$Hれ$P！", 00
;7C5C
db  00

;7C5D
db  "$Kヒ<LP><LP>ﾟラミット<LP><LP>ﾞ$Hにつっこめ$P！", 00
;7C75
db  00

;7C76
db  "$Kトンネルエントランス$Hに$P入$Hれ$P！", 00
;7C8F
db  00

;7C90
db  "$P十$Kホ<LP><LP>ﾞタン$Hて<LP><LP>$Kﾞ", 00
;7CA4
db  "$Hこうと<LP><LP>$Kﾞ$Hをちょうせいし", 00
;7CB8
db  "$Hとひ<LP><LP>$Kﾞ$Hつつ<LP><LP>$Kﾞ$Hけなさい$P！", 00


;7CD4
db  "$Hそうひ<LP><LP>$Kﾞ$Hした、$P兵器$Hは", 00
;7CEB
db  "$Hここに$P　$Hひょうし<LP><LP>$Kﾞ$Hされる", 00

;7D04
db  "$Kカヘ<LP><LP>ﾞ$Hに$P　$Hふ<LP><LP>$Kﾞ$Hつかりすき<LP><LP>$Kﾞ$Hるそ<LP><LP>$Kﾞ$P！", 00
;7D32
db  "$Hもういちと<LP><LP>$Kﾞ$Hやりなおせ$P！", 00
;7D49
db  00

;7D4A
db  "$Hます<LP><LP>$Kﾞ$P　敵$Hを$K", 00
;7D5D
db  "$Hさか<LP><LP>$Kﾞ$Hしにゆけ$P！", 00

;7D70, briefing used by tunnel entity, don't enter until you get briefed in the radar base
db  1
db  "$Hきょかするまて<LP><LP>$Kﾞ<NL>", \
	"$Hこの$P　$Hたてものに、<NL>", \
	"$P入$Hるんし<LP><LP>$Kﾞ$Hゃない$P！<NL>", \
	"$H指$P示$Hを$P　$Hまつんた<LP><LP>$Kﾞ$H。<NL>", \
	"$Hおちつけ、<NL>", \
	"$H君も$P　$Hまた<LP><LP>$Kﾞ$Hまた<LP><LP>$Kﾞ$P　$Kアオ$Hいな。<NL>", 00
db  $FF


;7DF1, briefing, missed timer in base segment
db  1
db  "$H時間か<LP><LP>$Kﾞ$H、<NL>", \
	"$Hかかりすき<LP><LP>$Kﾞ$Hた<LP><LP>$Kﾞ$Hそ<LP><LP>$Kﾞ$H。<NL>", \
	"$H時間き<LP><LP>$Kﾞ$Hれた<LP><LP>$Kﾞ$H、<NL>", \
	"$Hもとの$P位置$Hから<NL>", \
	"$Hやりなおせ。<NL>", \
	"$Hかならす<LP><LP>$Kﾞ$H「$PＬＯＷ$H」て<LP><LP>$Kﾞ<NL>", \
	"$Hはしらの$P中$H間$P　$Hまて<LP><LP>$Kﾞ$H進め$P！<NL>", 00
db  $FF

;7E8D
db  "$P空中$Hの「しかくい$P　$Hわく」を", 00
;7EA3
db  "$Hくく<LP><LP>$Kﾞ$Hって$P　$Hみなさい。", 00

;7EBB
db  "$Hこれを$P　$Hみれは<LP><LP>$Kﾞ$Hそうこう$P中$Hの", 00
;7EDA
db  "$Kエリア$Hか<LP><LP>$Kﾞ$P　$Hわかる。", 00

;7EF1
db  "$Hてんめつする$P　$Kト<LP><LP>ﾞット$Hか<LP><LP>$Kﾞ", 00
;7F0D
db  "$Hけんさ<LP><LP>$Kﾞ$Hいの$P　位置$Hた<LP><LP>$Kﾞ$P！", 00

;7F2C
db  "$Hしかく$P　$Hをのか<LP><LP>$Kﾞ$Hさす<LP><LP>$Kﾞ", 00
;7F48
db  "$Hくく<LP><LP>$Kﾞ$Hりぬけ$P　$Hなさい$K!", 00
;7F62
db  "$Hやりなおした<LP><LP>$Kﾞ$H。", 00

;7F73
db  "$P高$Hさを$P　$Hすこし$P下$Hけ<LP><LP>$Kﾞ$Hよ。", 00

;7F92
db  "$Hよし、いいそ<LP><LP>$Kﾞ!", 00
;7FA1
db  "$Hその$P　$Hちょうした<LP><LP>$Kﾞ!", 00

SETCHARMAP main
;7FB6