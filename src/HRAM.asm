SECTION "HRAM", HRAM[$FF80]
hDMARoutine:: ds 11 ;FF80-FF8A is our DMA routine
	ds $7 ;FF8B - FF91
hPauseFlag:: db ;FF92
hGameState:: db ;FF93, 01 is planet and 02 is tunnel. 00 when paused. -1 when in subscreen?
hSpeedTier:: db ;FF94, from 00 is rev, stop, low, med, high, turbo, tunnel, flight
spdREV EQU 0
spdSTOP EQU 1
spdLOW EQU 2
spdMED EQU 3
spdHIGH EQU 4
spdTURBO EQU 5
spdTUNNEL EQU 6
spdFLIGHT EQU 7

hIntP:: db ;FF95, handles the interface palette?
hBGP:: db ;FF96
;FF97, used for double precision on map object positions?
	ds $4
	db ;FF9B is an address offset?
	db
hLoadedBank:: db ;FF9D
hRenderXOffset::
hRenderXOffLo:: db
hRenderXOffHi:: db;FF9E/FF9F: a word, used for shifting rendered objects left or right on the screen
;FFA0 stores the difference of values from $48XX table
;FFA1 entity y rotation
;FFA2 holds the vertex table type
;FFA3 entity z rotation
;FFA4 ??? used with word reading, relates to FFA2 bit 1
;FFA5 entity x rotation
;FFA6 stores the passed A register when reading tables in the $4000 region
SECTION "HRAM FFA7", HRAM[$FFA7]
hViewAngle:: db ;FFA7
hZLoCopy:: db ;FFA8: Z position copy
hZHiCopy:: db
hYLoCopy:: db ;FFAA: Y position copy
hYHiCopy:: db
hXLoCopy:: db ;FFAC: X position copy
hXHiCopy:: db
hItemType:: db ;FFAE - checked in the input routine, set to type of currently handled item

;processed normals saved to FFB2 - FFB7

;FFB8-FFBF are the coords of previous processed tunnel frames
;FFC0-FFC7 are the coords of current processed tunnel frames

SECTION "random", HRAM[$FFC8]
hRandSeed:: 
hRandSeedLo:: db ;FFC8/FFC9, current random seed
hRandSeedHi:: db
hRandLast:: 
hRandLastLo:: db ;FFCA/FFCB, previous seed
hRandLastHi:: db

;FFCE reset in the normal-reading function?
;FFCF sometimes holds latest third byte we read from third pointer blob
;FFD0 holds difference between third bytes read from third pointer blob
;FFD1 sometimes holds one of the previous two. junction writes 0 to it on start, and level loop checks it after junction state resolves.

;FFD5, FFD7, and FFD9 hold values related to viewing angle

;FFDB entity zpos\  Y offset?
;FFDC entity xrot \
;FFDD entity yrot | all these are used to modify the bytes gotten via the $4000 tables
;FFDE entity zrot |
;FFDF entity xpos / X offset?
;FFE0 entity ypos/

SECTION "hram2", HRAM[$FFE1]
hYPos:: 
hYPosLow:: db ;FFE1: Y position, word
hYPosHi:: db ;FFE2
hZPos::
hZPosLow:: db ;FFE3
hZPosHi:: db ;FFE4
hXPos::
hXPosLow:: db ;FFE5: X position, word
hXPosHi:: db ;FFE6

;FFE7/E8 distance to scale value by
;FFE9/FFEA/FFEB/FFEC value to scale by distance

;E7/E8 left alone, E9/EA/EB get moved through each other? EC status?

;FFED/FFEE holds a word
;FFEF/FFF0 holds a word
;FFF1/FFF2 holds a word
;FFF3/FFF4 holds a word
;these first four values get compared to these last four
;FFF5-FFFA hold word values for something (tile data offsets? three words)
;above + FFFB/FFFC hold vert coords (left top, bottom right) for tunnel frames

;FFFD used in the vblank handler, incremented every frame
;FFFE holds something, either $7F, $80, or $81