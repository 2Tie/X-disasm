;macros

loadpalette: MACRO 
	ld a, ((\1 << 6) | (\2 << 4) | (\3 << 2) | \4) 
ENDM

;briefing commands
bcomEnd: MACRO ;command 0
	db 0
ENDM

bcomLoadModel: MACRO ;command 1
	db 1, \1, \2, LOW(\3), HIGH(\3), LOW(\4), HIGH(\4), LOW(\5), HIGH(\5), \6, \7, \8
ENDM

bcomSetEntLogic: MACRO ;command 2
	db 2, \1, LOW(\2), HIGH(\2)
ENDM

bcomWait: MACRO ;command 3
	db 3, \1
ENDM

bcomText: MACRO ;command 5
SETCHARMAP CHARS
	db 5, \1
	db \2, 00
SETCHARMAP main
ENDM

bcomText1Line: MACRO ;also 5
SETCHARMAP CHARS
	db 5, \1, 00
SETCHARMAP main
ENDM

bcomSetBubbleSize: MACRO ;command 8
	db 8, \1, \2
ENDM

bcomLookAtScreen: MACRO ;command C
	db $C
ENDM

bcomNullModel: MACRO ;command E
	db $E, \1
ENDM

bcomStatic: MACRO ;command F
	REPT \1
	db $F
	ENDR
ENDM

bcomPlayInterfaceSound: MACRO ;command 11
	db $11, \1
ENDM

bcomPlayGeneralSound: MACRO ;command 12
	db $12, \1
ENDM

bcomPlayExplosionSound: MACRO ;command 13
	db $13, \1
ENDM

bcomLoadImage: MACRO ;command 14
	db $14, LOW(\1), HIGH(\1)
ENDM

bcomExplodeEntity: MACRO ;command 15
	db $15, \1
ENDM

bcomWipeScreen: MACRO ;command 16
	db $16
ENDM

bcomCopyPosition: MACRO ;command 17
	db $17, \1, \2
ENDM

bcomEnableAnimations: MACRO ;command 18
	db $18
ENDM

bcomDisableAnimations: MACRO ;command 19
	db $19
ENDM

bcomSetEntityMovementXY: MACRO ;command 1A
	db $1A, \1, \2, \3 ;entity, x, and y
ENDM

bcomSetEntityMovementXYZ0: MACRO ;command 1B
	db $1B, \1, \2, \3, \4, \5 ;might be able to make this last one 0
ENDM

bcomPlayMusic: MACRO ;command 1C
	db $1C, \1
ENDM

;gamestate macros
tutRawCall: MACRO ;command 3
	db 3, LOW(\1), HIGH(\1)
ENDM

tutShowBriefing: MACRO ;command 4
	db 4, LOW(\1), HIGH(\1)
ENDM

tutScreenText: MACRO ;command 5
	db 5, LOW(\1), HIGH(\1)
ENDM

tutReturnControl: MACRO ;command 6
	db 6
ENDM

tutJump: MACRO ;command 7
	db 7, LOW(\1), HIGH(\1)
ENDM

tutJumpIfEqual: MACRO ;command 8
	db 8, \1, LOW(\2), HIGH(\2)
ENDM

tutSetLoopCounter: MACRO ;command 9
	db 9, \1
ENDM

tutLoop: MACRO ;command A
	db $A
ENDM

tutLoadFromAddress: MACRO ;command B
	db $B, LOW(\1), HIGH(\1)
ENDM

tutDrawArrow: MACRO ;command C
	db $C, \1
ENDM

tutClearArrow: MACRO ;command D
	db $D
ENDM

tutJumpNZ: MACRO ;command E
	db $E, \1, LOW(\2), HIGH(\2)
ENDM

tutWriteValue: MACRO ;command F
	db $F, \1, LOW(\2), HIGH(\2)
ENDM

tutCallPos: MACRO ;command 10
	db $10, LOW(\1), HIGH(\1)
ENDM

tutRet: MACRO ;command 11
	db $11
ENDM

tutSetSubLoopCounter: MACRO ;command 12
	db $12, \1
ENDM

tutSubLoop: MACRO ;command 13
	db $13
ENDM

tutJumpC: MACRO ;command 14
	db $14,  \1, LOW(\2), HIGH(\2)
ENDM

tutJumpNC: MACRO ;command 15
	db $15, \1, LOW(\2), HIGH(\2)
ENDM

tutClearText: MACRO ;command 16
	db $16
ENDM

tutSetTimer: MACRO ;command 17
	db $17, LOW(\1), HIGH(\1), LOW(\2), HIGH(\2)
ENDM

tutClearTimer: MACRO ;command 18
	db $18
ENDM

tutBarScreen: MACRO ;command 19
	db $19
ENDM

;map object list macros
mapobjEntry: MACRO
	db \1, \2, \3
ENDM

mapobjRespawn: MACRO
	db $ff, \1, LOW(\2), HIGH(\2), LOW(\3), HIGH(\3)
ENDM

mapobjPreciseEntry: MACRO
	db $fe, \1, LOW(\2), HIGH(\2), LOW(\3), HIGH(\3)
ENDM

mapobjJump: MACRO
	db $fd, LOW(\1), HIGH(\1)
ENDM

mapobjSetVal1: MACRO
	db $80, LOW(\1), HIGH(\1)
ENDM

mapobjSetVal2: MACRO
	db $81, LOW(\1), HIGH(\1)
ENDM

mapobjSetVal3: MACRO
	db $82, LOW(\1), HIGH(\1)
ENDM

mapobjSetVal4: MACRO
	db $83, LOW(\1), HIGH(\1)
ENDM

mapobjSetXRot: MACRO
	db $84, \1, 0
ENDM

mapobjSetZRot: MACRO
	db $85, \1, 0
ENDM

mapobjSetLogic: MACRO
	db $86, LOW(\1), HIGH(\1)
ENDM

mapobjSetHP: MACRO
	db $87, \1, 0
ENDM

mapobjSetYPos: MACRO
	db $88, LOW(\1), HIGH(\1)
ENDM

mapobjSetYRot: MACRO
	db $89, \1, 0
ENDM

mapobjEND: MACRO
	db 0
ENDM


;tunnel data macros
TUN_ENT_BARRIER EQU 0
TUN_ENT_SHUTTER_CLOSE_DOWNWARD EQU 1
TUN_ENT_SHUTTER_CLOSE_UPWARD EQU 2
TUN_ENT_SHUTTER_CLOSE_LEFTWARD EQU 3 ;3 is rightward?
TUN_ENT_SHUTTER_CLOSE_RIGHTWARD EQU 4 ;4 is leftward?
TUN_ENT_DOOR_LEFT EQU 5
TUN_ENT_DOOR_RIGHT EQU 6

TUN_ENT_EXIT EQU 8

TUN_ENT_LEFT EQU $A
TUN_ENT_RIGHT EQU $B
TUN_ENT_SHUTTER_LEFT EQU $C
TUN_ENT_SHUTTER_RIGHT EQU $D
TUN_ENT_EARTH EQU $E

tunEnd: MACRO
	db 0
ENDM
tunTurnLeft: MACRO
	db $01, \1
ENDM
tunTurnRight: MACRO
	db $02, \1
ENDM
tunSetLength: MACRO
	db $03, \1
ENDM
tunStub1: MACRO
	db $04, \1
ENDM
tunStub2: MACRO
	db $05, \1
ENDM
tunStub3: MACRO
	db $06, \1
ENDM
tunStub4: MACRO
	db $07, \1
ENDM
tunEntity: MACRO
	db $08, \1, \2, \3, \4, \5, \6
ENDM
tunWidth: MACRO
	db $09, \1
ENDM
tunHeight: MACRO
	db $0A, \1
ENDM
tunDimensions: MACRO
	db $0B, \1, \2
ENDM
tunOuterLoop: MACRO
	db $0C, LOW(\1), HIGH(\1), \2
ENDM
tunLoop: MACRO
	db $0D, LOW(\1), HIGH(\1), \2
ENDM


;music track macros
SongHeader: MACRO
	db \1, LOW(\2), HIGH(\2), LOW(\3), HIGH(\3), LOW(\4), HIGH(\4), LOW(\5), HIGH(\5), LOW(\6), HIGH(\6)
ENDM

musJUMP: MACRO
	dw $FFFF, \1
ENDM
musEND: MACRO
	dw $0000
ENDM

musSectionEnd: MACRO
	db $00
ENDM
musRepeatNote: MACRO
	db $01
ENDM
musNote: MACRO
	db \1
ENDM
musSetLoop: MACRO
	db $9B, \1
ENDM
musLoop: MACRO
	db $9C
ENDM
musLoadNoteData: MACRO
	db $9D, \1, \2, \3
ENDM
musLoadWaveData: MACRO
	db $9D, LOW(\1), HIGH(\1), \2
ENDM
musLoadNoteLengthTable: MACRO
	db $9E, LOW(\1), HIGH(\1)
ENDM
musSetPitchOffset: MACRO
	db $9F, \1
ENDM
musNoteLengthFromTable: MACRO
	db $A0 + \1
ENDM

;continue/results screen macro
conEnd: MACRO
	db $00
ENDM
conPointedNumber: MACRO 
	db $01, LOW(\1), HIGH(\1)
ENDM
conLiteralNumber: MACRO
	db $02, \1
ENDM
conJumpEqual: MACRO
	db $03, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conJumpNotEqual: MACRO
	db $04, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conJumpDiv4Equal: MACRO
	db $05, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conJumpDiv4NotEqual: MACRO
	db $06, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conJumpGreaterEqual: MACRO
	db $07, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conJumpLessEqual: MACRO
	db $08, LOW(\1), HIGH(\1), \2, LOW(\3), HIGH(\3)
ENDM
conLevelNumber: MACRO
	db $0B, LOW(\1), HIGH(\1)
ENDM
conReadMinusPointed: MACRO
	db $0C, \1, LOW(\2), HIGH(\2)
ENDM
conNewline: MACRO
	db $0D
ENDM
conBigStar: MACRO
	db $0E
ENDM
conSmallStar: MACRO
	db $0F
ENDM
conAdvanceVRAM: MACRO
	db $10, \1
ENDM
conJump: MACRO
	db $11, LOW(\1), HIGH(\1)
ENDM
conIncVal1: MACRO
	db $12, LOW(\1), HIGH(\1)
ENDM
conDecVal1: MACRO
	db $13, LOW(\1), HIGH(\1)
ENDM
conIncVal2: MACRO
	db $14, LOW(\1), HIGH(\1)
ENDM
conDecVal2: MACRO
	db $15, LOW(\1), HIGH(\1)
ENDM

;model macros and constants
vThisBank EQU 0
vBankB: MACRO
	db 1, LOW(\1), HIGH(\1)
ENDM
;vGroup EQUS "db"
vEND EQU 0
vLIST EQU 1
vJUMP EQU 2
vNONSPECIAL EQU %00010000
vMIRRORED EQU %00001000
fALWAYSVISIBLE EQU %10000000

mEdge: MACRO
	db \1*4, \2*4
ENDM

fEdgeGroup: MACRO
	REPT _NARG
	db \1*4
	SHIFT
	ENDR
	;_NARG gets argument number?
ENDM

fEdgeIdx: MACRO
	REPT _NARG
	db \1
	SHIFT
	ENDR
	;_NARG gets argument number?
ENDM