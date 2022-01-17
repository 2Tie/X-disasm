SECTION "7:TOP", ROMX[$4000], BANK[7]
;4000
	db $0C 
	db $12 
	db $2E 
	db $1A 
	db $1F 
	db $27 
	db $07 
	db $38 
	db $20 
	db $4B 
	db $7E 
	db $0B
	db $00
	db $00
	db $00
	db $00
EntLockableTable: ;4010
	db 0, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0
	
GenerateDebris: ;4065
	ld a, $08
.loop
	push af
	call NextRand
	and $0F
	ld [$CA9E], a ;roll once, save to CA9E (used for particle life)
	call NextRand
	and $0F
	ld l, a ;roll twice, save to L
	push hl
	call NextRand
	pop hl
	push bc
	push de
	ld h, $01 ;debris particles
	call GenerateParticle
	pop de
	pop bc
	pop af
	dec a
	jr nz, .loop
	ret
	
UpdatePitchTilt: ;4089
	xor a
	ld [wFlyTiltRaw], a
	ld a, [$CB52]
	or a
	ret nz
	ld a, [wTurnSpeed]
	add a, $40
	ld c, a
	ldh a, [hViewAngle]
	ld b, a
	ldh a, [hSpeedTier]
	sla a ;times two, pointer table entry?
	add a, LOW(PitchTablePointers)
	ld l, a
	ld a, HIGH(PitchTablePointers)
	adc a, $00
	ld h, a ;table at 4190
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;follow pinter
.loop
	ld a, [hl+] ;first value is threshold
	inc a
	ret z ;return if FF
	dec a
	cp c ;compare to turn speed
	ld a, [hl+] ;second value is amount?
	jr nc, .gotval ;if we're within that value, use it
	jr .loop
.gotval
	ld c, a ;save it
	add a, b ;add to angle
	ldh [hViewAngle], a ;save
	ld a, c
	or a
	jr z, .dotilts;if amount is zero, jump
	ld a, [wLurchCounter]
	add a, $80
	cp $88
	jr c, .dotilts
	sub $04
	sub $80
	ld [wLurchCounter], a ;increment counter to a certain point
.dotilts ;10, 7
	xor a
	ld [wGroundTiltRaw], a ;clear grounded turning tilt
	ld a, [wFlyingFlag]
	or a
	ret z
	ld a, c
	cpl
	cp $80
	sbc a, $FF
	inc a
	sra a
	ld [wFlyTiltRaw], a
	ret
	
;tables. first value is a turnspeed threshold, second is how much to pitch.
PitchTableUnk: ;40E2, unknown table. possibly used for ground tilt?
	db $22, $FE 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $5E, $01 
	db $80, $02 
	db $FF, $FF

PitchTableRev: ;40F0, reverse
	db $10, $FB 
	db $13, $FC 
	db $1D, $FD 
	db $2C, $FE 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $54, $01 
	db $63, $02 
	db $6D, $03 
	db $70, $04 
	db $80, $05 
	db $FF, $FF
PitchTableStop: ;410A, stop
	db $10, $F7 
	db $13, $F8 
	db $1D, $F9 
	db $2C, $FB 
	db $3A, $FD 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $46, $01 
	db $54, $03 
	db $63, $05 
	db $6D, $07 
	db $70, $08 
	db $80, $09 
	db $FF, $FF
PitchTableLow: ;4128, low
	db $10, $FA 
	db $13, $FB 
	db $1D, $FC 
	db $2C, $FD 
	db $3F, $FE 
	db $40, $00 
	db $41, $00 
	db $54, $02 
	db $63, $03 
	db $6D, $04 
	db $70, $05 
	db $80, $06 
	db $FF, $FF
PitchTableMed: ;4142, medium
	db $10, $FB 
	db $13, $FC 
	db $1D, $FD 
	db $2C, $FE 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $54, $01 
	db $63, $02 
	db $6D, $03 
	db $70, $04 
	db $80, $05 
	db $FF, $FF
PitchTableHigh: ;415C, high
	db $10, $FA 
	db $13, $FB 
	db $1D, $FC 
	db $2C, $FE 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $54, $01 
	db $63, $02 
	db $6D, $04 
	db $70, $05 
	db $80, $06 
	db $FF, $FF
PitchTableTurbo: ;4176, turbo/tunnel/flight
	db $10, $F7 
	db $13, $F9 
	db $1D, $FC 
	db $2C, $FE 
	db $3F, $FF 
	db $40, $00 
	db $41, $00 
	db $54, $01 
	db $63, $02 
	db $6D, $04 
	db $70, $07 
	db $80, $09 
	db $FF, $FF
PitchTablePointers: ;4190, pointer table
	dw PitchTableRev, PitchTableStop, PitchTableLow, PitchTableMed, PitchTableHigh, PitchTableTurbo, PitchTableTurbo, PitchTableTurbo

CheckEntityLockable: ;41A0
	push hl
	dec a
	add a, LOW(EntLockableTable)
	ld l, a
	ld a, HIGH(EntLockableTable)
	adc a, $00
	ld h, a
	ld a, [hl+]
	pop hl
	ret
;41AD

SECTION "7:422A", ROMX[$422A], BANK[7]
CruiseMissileLogic: ;422A, cruise missile logic?
	ld a, [$CAFE]
	inc a
	ld [$CAFE], a ;update cruise missile count
	ld e, l
	ld d, h
	ld l, e
	ld h, d
	ld a, l
	add a, $16 ;penultimate byte
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	bit 1, [hl] ;check bit 1
	jr nz, .checkSiloExists ;if set, jump
	ld l, e
	ld h, d ;else restore pointer
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;and advance to speed
	ld b, $05
.checkspeedloop ;F6
	dec b
	jr z, .zeroloop
	ld a, [hl+]
	ld c, a ;save current speed to C
	cp $80
	ld a, [hl+]
	jr z, .checkspeedloop
	ld b, a
	push hl
	ld l, e
	ld h, d
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	sub a, c
	ld c, a
	ld a, c
	add a, $03 ;x - speed + 3
	cp $06
	jr nc, .bigX
	inc hl
	ld a, [hl+]
	sub a, b
	ld b, a
	ld a, b ;unnecessary
	add a, $03 ;y - loop + 3
	cp $06
	jr nc, .calcSpeedAngle
	pop hl
	dec hl
	ld a, $80
	ld [hl-], a
	ld [hl-], a ;overwrite speed and deltaspeed to $80
	ret
.bigX ;12
	inc hl
	ld a, [hl+]
	sub a, b
	ld b, a ;y - loop
.calcSpeedAngle ;B
	add sp, $02 ;discard the push'd HL
	push de
	ld d, b ;b = y-loop
	ld b, c ;c = x-speed
	ld c, $00
	ld e, c ;DE is y-loop, BC is x-speed
	push de
	call CallGetAngleToOffset ;figure out its angle based on the vector
	pop de ;restore Y
	pop hl ;restore ent pointer
	jr .haveAngle
.zeroloop ;ran out of loops
	ld l, e
	ld h, d ;load ent pointer
	ld a, l
	add a, $16
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to penultimate byte
	set 1, [hl] ;set bit 1
.checkSiloExists ;5E
	ld hl, wEntityTable
	ld a, $18 ;nuclear silo
	push de
	call CallFindEntityWithModel
	pop de
	ret c ;return if no silo
	bit 7, [hl] ;check top bit
	jr z, .siloExists ;if not exploding, continue
	dec de
	ret ;else return
.siloExists
	inc hl
	push hl ;save silo pointer
	push de ;save missile pointer
	call CallGetDistanceBetweenEnts ;distance in A, carry set if Y < X
	pop de
	pop hl ;restore pointers
	jr c, .calcOffsetAngle ;if X greater, jump
	cp $09
	jr nc, .calcOffsetAngle ;if greater than 9, jump
	push hl
	push de
	ld a, e
	add a, $04
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;advance missile pointer to Y pos
	ld a, [hl+]
	ld c, a
	ld a, [hl-]
	ld b, a ;ypos to BC
	ld a, c
	add a, $0A
	ld a, b
	adc a, $00 ;add 10 to ypos (nonsaved)
	jr c, .yCleanup ;if overflow, do nothing
	ld a, c
	add a, $05
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;add 5 to ypos
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a ;and save it
.yCleanup ;C
	pop de
	pop hl
.calcOffsetAngle ;28, 24
	call CallGetAngleBetweenEnts
.haveAngle ;52
	sub $80 ;invert it
	ld c, a
	push hl ;ent pointer
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;z orientation (top-down spin)
	ld a, c
	sub a, [hl] ;turn it based on angle
	add a, $04
	cp $08
	jr c, .checkSiloCollision ;if it's behind us, jump
	sub $04
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft
	ld a, [hl]
	sub $80
	ld [hl], a ;flip if other way!
	jr .checkSiloCollision
.turnRight ;A
	ld a, [hl]
	add a, $03
	ld [hl], a
	jr .checkSiloCollision
.turnLeft ;C
	ld a, [hl]
	sub $03
	ld [hl], a
.checkSiloCollision ;1A, A, 4
	pop hl
	ld bc, $5000
	call CallMoveEntityForward
	call CallTestEntityHasCollisions
	ret nc ;return if no collisions!
	dec hl
	ld a, [hl+]
	cp $18 ;silo
	jr nz, .ret ;if collision was not with the silo, return
	push hl
	call ClearAllScreenText
	ld hl, SiloDestroyedText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $19
	ld [wGameOverTimer], a
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	pop hl
	push hl
	ld a, $FA
	call CallDamageEntity
	pop hl
	ld a, $FA
	call CallDamageEntity
.ret ;23
	ret
	
DisableLCD: ;0x1C348 bank 7
	ld a, [rIE] ;save interrupts enabled
	push af
	xor a
	ld [rIF], a
	ld [rIE], a ;clear int flags and enables
	ld a, [rLCDC]
	bit 7, a
	jr z, .end ;jump ahead if display is off
.wait1
	ld a, [rSTAT]
	and $03
	dec a ;wait until lcdc isn't 1 AKA no vblank
	jr z, .wait1
.wait2
	ld a, [rSTAT]
	and $03
	dec a
	jr nz, .wait2 ;wait until vblank; we've just waited a frame
	ld a, $14
.waitmore
	nop
	nop
	dec a
	jr nz, .waitmore ;burn some time here.
	xor a
	ld [rLCDC], a ;clear lcd control (lcd off)
.end
	xor a
	ld [rIF], a ;clear interrupt flags
	pop af
	ld [rIE], a ;restore our saved interrupts
	ret
	
RollValByTilt: ;0x4375
	ld a, [wFlyTilt]
	or a
	ret z ;if no tilt, return
	push hl
	ld h, $00
	ld a, c ;view direction
	sub $40
	cp $80
	ld l, a ;modified view direction
	ld a, $00 ;bit holder?
	adc a, $FF ;set first bit based on sign
	rl l
	rla
	rl l
	rla
	rl l
	rla
	rl l
	rla
	rl l
	rla ;rotate five bits into A from our view direction
	ld h, a ;and save it to H (six bits)
	ld a, [wFlyTilt]
	bit 7, a ;check sign
	jr nz, .neg
	cp $02
	jr nc, .add
	sra h ;divide by two if tilt level is only one
.add
	ld a, b
	add a, h
	ld b, a ;b += h
	pop hl
	ret
.neg
	cp $FF
	jr c, .sub
	sra h ;divide by two if tilt level is only one
.sub
	ld a, b
	sub a, h
	ld b, a ;b -= h
	pop hl
	ret

RollCoordsByTilt: ;0x43B4 ;called by 3d math stuff?
	;BC is X:Z, HL is Y:Z 
	ld a, [wFlyTilt]
	or a
	ret z ;if no tilt, return
	push bc ;store passed BC
	ld a, c
	rla
	rl b
	rla
	rl b
	rla
	rl b
	rla
	rl b
	rla
	rl b ;rotate bc left 5 times
	ld a, b
	cp $80
	ld c, a ;store rotated b into c
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extend rotated b into bc
	ld a, [wFlyTilt]
	bit 7, a
	jr nz, .negativetilt
	cp $02
	jr nc, .lessthan2
	sra b
	rr c ;divide bc by two
.lessthan2
	add hl, bc ;hl += bc
	pop bc
	ret
.negativetilt
	cp $FF
	jr c, .lessthanFF
	sra b
	rr c ;divide bc by two
.lessthanFF
	ld a, l
	sub a, c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a ;hl -= bc
	pop bc
	ret
	
LoadGoalEntityID: ;43F5
	ld a, [wCurLevel]
	and $FC
	rrca
	rrca ;divide by four to get byte offset
	add a, $00
	ld l, a
	ld a, $40
	adc a, $00
	ld h, a ;offset's for table at the top of the bank
	ld a, [hl+]
	ld [wGoalEntityID], a ;load byte into C2EB
	ret
	
UpdateGoalCompassAndAltimeter: ;4409
	ld a, [wGoalEntityID]
	ld c, a ;byte from top of bank into C
	ld b, ENTITY_SLOTS ;B is counter
	ld hl, wEntityTable ;HL is the ent table
	ld a, [wGoalEntityPointerLo]
	ld e, a
	ld a, [wGoalEntityPointerHi]
	ld d, a ;DE is the goal ent pointer
	or e
	jr z, .checkdistance ;if no goal ent, jump
	dec de
	ld a, [de]
	inc de
	cp c
	jp z, .checkdistance ;if the ent already matches the target, jump
	xor a
	ld e, a
	ld d, a ;else clear out DE
.checkdistance ;4427
	ld a, $5A
	ld [wGoalEntityDistance], a ;max distance?
.distanceloop
	ld a, [hl+]
	cp c
	jp nz, .nextent ;if ent table entry matches target, don't jump
	push hl
	push de
	push bc
	call CallGetDistanceFromPlayer
	pop bc
	pop de
	pop hl
	jp c, .nextent ;if Y difference > X, jump??
	push bc
	ld c, a ;distance into C
	ld a, [wGoalEntityDistance]
	cp c ;old - new
	ld a, c
	pop bc
	jp c, .nextent ;if new was larger, jump
	ld [wGoalEntityDistance], a
	ld e, l
	ld d, h ;else save pointer (new target)
.nextent ;444D
	ld a, l
	add a, ENTITY_SIZE - 1 ;advance to next entity
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b ;reduce counter
	jp nz, .distanceloop
	;we've now gone through all ents and have our target
	ld a, [wGoalEntityPointerLo]
	ld c, a
	ld a, [wGoalEntityPointerHi]
	or c
	jr nz, .updateGoal ;if already have a target, jump
	ld a, d
	or e
	jr z, .updateGoal ;if no new target, jump
	ld a, $0F ;found one!
	ld [wQueueSFX], a
.updateGoal ;9, 5
	ld a, d
	ld [wGoalEntityPointerHi], a
	ld a, e
	ld [wGoalEntityPointerLo], a
	or d
	jp z, .wipeOAM ;if no goal, jump
	ld l, e
	ld h, d
	call CallGetAngleToEntity ;returns a coarse angle (in 1/8ths a full spin)
	sub $80
	ld c, a
	ld a, [wViewDir]
	sub a, c
	ld d, a ;save an angle to D
	ld hl, wCrosshairTargetEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [wGoalEntityPointerLo]
	cp l
	jr nz, .offsetCompass
	ld a, [wGoalEntityPointerHi]
	cp h
	jr nz, .offsetCompass ;jump if not matching?
	;cursor ent and goal ent match!
	ld a, [$C328] ;?
	ld l, a
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;C328 extended into HL
	ld a, [$C32A] ;?
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;add C32A to HL
	sra h
	rr l ;divide by two?
	ld a, l
	cpl
	inc a
	ld d, a ;negate, save to D
.offsetCompass ;22, 1C
	ld a, [wGoalCompassOffset]
	ld e, a
	ld b, $00
	ld a, [wGoalCompassPos]
	sub a, d ;subtract angle
	jr z, .equal ;if equal, jump
	cp $80
	jr c, .right ;if positive, jump
	;result was negative (left)
	bit 7, e
	jr z, .incComp ;if e positive, jump
	ld e, $FF ;else reset E
.incComp
	inc e ;increment E
	jr .moveComp
.right
	bit 7, e
	jr nz, .decComp
	ld e, $00
.decComp
	dec e
	jr .moveComp
.equal
	ld e, $00
.moveComp
	ld a, [wGoalCompassPos]
	ld c, a
	add a, e
	ld [wGoalCompassPos], a ;set new offset
	ld d, a
	sub $40 ;40 is edge of screen, this makes it range from -1 to -7F
	cp $80
	ld a, e
	ld [wGoalCompassOffset], a
	jr nc, .checkCrossedMidpoint ;if onscreen, check for bleep
	jp .wipeOAM
.checkCrossedMidpoint
	ld a, d
	cp $80
	ccf
	rra
	xor c
	rla
	jr nc, .startOAMstuff 
	ld a, $0F ;bleep!
	ld [wQueueSFX], a ;replay sound if we crossed over the middle of the screen
.startOAMstuff ;5
	ld b, Y_FLIP ;attribute, it's in front of us
	ld hl, wTargetCompassOAMData
	ld a, $68 ;ypos
	ld [hl+], a
	ld a, b
	or a
	jr nz, .negateX
	ld a, d ;x offset
	add a, $C0 ;unused, is this the "behind you" branch?
	jr .writeOAM
.negateX
	ld a, d ;x offset
	cpl
	inc a ;negate
	add a, $40
	cp $80
.writeOAM
	add a, $14
	ld [hl+], a ;xpos
	ld a, $0C
	ld [hl+], a ;tile
	ld a, b
	ld [hl+], a ;attribute
	jr .doaltimeter
.wipeOAM ;451D
	ld hl, wTargetCompassOAMData
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.doaltimeter ;8
	ld hl, hZPos
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load Z into HL
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l ;times eight?
	ld a, l
	cpl
	inc a ;negate lo
	add a, $61
	ld hl, wAltimeterOAMData
	ld [hl+], a ;Ypos
	ld a, $08
	ld [hl+], a ;Xpos
	ld a, $0D
	ld [hl+], a ;tile
	xor a
	ld [hl+], a ;attrib
	ret

DrawLockLine: ;4549
	;DE is XY length
	push bc
	push de
	push hl
	ld a, c
	add a, e
	ld e, a
	ld a, b
	add a, d
	ld d, a ;de += bc
	ld l, b
	ld a, l
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a ;HL is sign-extended B
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;BC is sign-extended C
	ld a, c
	add a, $40
	ldh [$FFF5], a
	ld a, b
	adc a, $00
	ldh [$FFF6], a
	ld a, $34
	ld c, a
	ld a, l
	add a, c
	ldh [$FFF7], a
	ld a, h
	adc a, $00
	ldh [$FFF8], a
	ld l, d
	ld a, l
	cp $80
	ld a, $00
	adc a, $FF
	ld h, a
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	ld a, e
	add a, $40
	ldh [$FFF9], a
	ld a, d
	adc a, $00
	ldh [$FFFA], a
	ld a, l
	add a, c
	ldh [$FFFB], a
	ld a, h
	adc a, $00
	ldh [$FFFC], a ;set up coords
	call CallProjectLine
	jr c, .ret ;if projection failed, return
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
.ret
	pop hl
	pop de
	pop bc
	ret
	
OrbitTarget: ;45B7
	ld hl, wLockedEntity
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret z ;return if no entity
	ld a, $01
	ld [$CB52], a
	xor a
	ld [wTurnSpeed], a
	ld a, [wCurrentInput]
	and (1<<INPUT_LEFT) | (1<<INPUT_RIGHT)
	ret z ;return if left or right not pressed
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;DE and BC are the target's X and Y
	push bc
	push de ;back them up
	ldh a, [hXPosLow]
	sub a, c
	ld c, a
	ldh a, [hXPosHi]
	sbc a, b
	ld b, a
	ldh a, [hYPosLow]
	sub a, e
	ld e, a
	ldh a, [hYPosHi]
	sbc a, d
	ld d, a ;subtract our positions to get a relative offset
	ld a, [wCurrentInput]
	bit INPUT_RIGHT, a
	ld a, $FD
	jr nz, .setangle
	cpl
	inc a
.setangle
	ld h, a
	ldh a, [hViewAngle]
	sub a, h
	ldh [hViewAngle], a ;modify our angle
	ld a, h
	call CallProjectXYToCamera
	pop hl
	ld a, l
	add a, e
	ldh [hYLoCopy], a
	ld a, h
	adc a, d
	ldh [hYHiCopy], a
	pop hl
	ld a, l
	add a, c
	ldh [hXLoCopy], a
	ld a, h
	adc a, b
	ldh [hXHiCopy], a
	ret
	
CheckClosestTargetedEntity: ;4610
	ld a, [wModelExploding]
	or a
	ret nz
	push hl
	ldh a, [$FFDF]
	ld c, a
	ldh a, [$FFE0]
	ld b, a ;ent X into BC
	ldh a, [$FFDD]
	ld l, a
	ldh a, [$FFDE]
	ld h, a ;ent Z into HL
	ldh a, [$FFDB]
	ld e, a
	ldh a, [$FFDC]
	ld d, a ;ent Y into DE
	push hl
	push bc ;save X and Z
	ld a, l
	sub $40
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;Z minus $40
	ld a, c
	sub $41
	ld c, a
	ld a, b
	sbc a, $00
	ld b, a ;X minus 41
	push de ;save Y
	call ProjectPoint
	ld a, c
	ld [$C320], a
	ldh [$FFF5], a
	ld a, b
	ld [$C321], a
	ldh [$FFF6], a ;X:Z
	ld a, l
	ld [$C322], a
	ldh [$FFF7], a
	ld a, h
	ld [$C323], a
	ldh [$FFF8], a ;Y:Z
	ld a, [wCrosshairXOffset]
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend crosshair X into DE
	ld a, c
	sub a, e
	ld c, a
	ld a, b
	sbc a, d
	ld b, a ;X:Z minus crosshair X
	bit 7, b
	jp z, .pop4ret ;if positive, return
	ld a, [wPitchAngle]
	sub $34
	ld e, a ;pitch offset
	ld a, [wCrosshairYOffset]
	sub a, e
	ld e, a 
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend crosshair Y into DE
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a ;Y:Z minus crosshair Y
	bit 7, h
	jp z, .pop4ret ;if positive, jump
	pop de
	pop bc
	pop hl ;restore X, Y, and Z
	ld a, c
	add a, $41
	ld c, a
	ld a, b
	adc a, $00
	ld b, a ;X + 0041
	push de ;save Y
	call ProjectPoint
	ld a, c
	ld [$C324], a
	ldh [$FFF9], a
	ld a, b
	ld [$C325], a
	ldh [$FFFA], a
	ld a, l
	ld [$C326], a
	ldh [$FFFB], a
	ld a, h
	ld [$C327], a
	ldh [$FFFC], a
	ld a, [wCrosshairXOffset]
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	ld a, c
	sub a, e
	ld c, a
	ld a, b
	sbc a, d
	ld b, a
	bit 7, b
	jp nz, .popy ;if new offset is negative, jump
	ld a, [$C2BD]
	sub $34
	ld e, a
	ld a, [wCrosshairYOffset]
	sub a, e
	ld e, a
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a
	ld a, l
	sub a, e
	ld l, a
	ld a, h
	sbc a, d
	ld h, a
	bit 7, h
	jp nz, .popy ;if new offset is negative, jump
	pop de ;restore Y
	ld a, [wCrosshairDistanceLo] ;set to FF?
	cp e
	ld a, [wCrosshairDistanceHi] ;set to FF?
	sbc a, d
	jp c, .popret ;if not closer, jump!
	ld a, e
	ld [wCrosshairDistanceLo], a
	ld a, d
	ld [wCrosshairDistanceHi], a ;else save new distance,
	pop hl
	ld a, l
	ld [wCrosshairTargetEntityLo], a
	ld a, h
	ld [wCrosshairTargetEntityHi], a
	ld a, [$C321] ;X:Z 1 hi
	inc a
	cp $02
	jr nc, .ret
	ld a, [$C323] ;Y:Z 1 hi
	inc a
	cp $02
	jr nc, .ret
	ld a, [$C325] ;X:Z 2 hi
	inc a
	cp $02
	jr nc, .ret
	ld a, [$C327] ;Y:Z 2 hi
	inc a
	cp $02
	jr nc, .ret
	ld a, [$C320] ;X:Z 1 lo
	ld [$C328], a
	ld a, [$C322] ;X:Y 1 lo
	ld [$C329], a
	ld a, [$C324] ;X:Z 2 lo
	ld [$C32A], a
	ld a, [$C326] ;Y:Z 2 lo
	ld [$C32B], a
	ldh a, [$FFDF]
	ld [$CAD4], a
	ldh a, [$FFE0]
	ld [$CAD5], a
	ldh a, [$FFDD]
	ld [$CAD6], a
	ldh a, [$FFDE]
	ld [$CAD7], a
	ldh a, [$FFDB]
	ld [$CAD8], a
	ldh a, [$FFDC]
	ld [$CAD9], a
.ret
	ret
.popy
	pop de
.popret
	pop hl
	ret
.pop4ret
	add sp, $08
	ret
	

DrawRadarBG: ;475D
	ld hl, $99A9 ;radar area
	ld a, $3A ;radar tile
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	ld hl, $99C9 ;second row
	ld a, $3B
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	ld hl, $99E9 ;third row
	ld a, $3C
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	ld hl, $9A09 ;fourth row
	ld a, $3D
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	add a, $04
	ld [hl+], a
	ld hl, $83A0 ;radar tiledata
	ld de, $4A00 ;radar gfx
	ld b, $80
.copyloop
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .copyloop
	ret
	
OverlayRadar: ;47AB
	ld de, RadarGFX + 1
	ld hl, wRadarBuffer
	ld b, $20
.loop
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	inc de
	ld a, [de]
	or [hl]
	ld [hl+], a
	inc de
	inc de
	dec b
	jp nz, .loop
	ret

FlashScreen: ;0x47CC
	push af
	ldh a, [rBGP]
	ld e, a
	ldh a, [rOBP0]
	ld d, a
	ldh a, [rOBP1]
	ld c, a
	xor a
	ldh [rBGP], a ;clear palettes momentarily
	ldh [rOBP0], a
	ldh [rOBP1], a
	pop af
	ldh [rLCDC], a
	bit 7, a
	jr z, .skip ;if lcd is off, skip waiting for vblank
.vblankloop
	ldh a, [rSTAT]
	and $03
	dec a
	jr nz, .vblankloop
.skip
	ld a, c
	ldh [rOBP1], a
	ld a, d
	ldh [rOBP0], a
	ld a, e
	ldh [rBGP], a;restore palettes now that we've hit vblank again
	ret

PlaceEntityInView: ;47F5
	ld bc, $2300 ;23 units ahead
PlaceEntityAhead: ;47F8
	push hl ;entity pointer
	ld a, [wViewDir]
	cpl
	inc a ;negate
	ld d, a ;load into D
	call CallRotateCoordByAngle ;rotate passed distance by our view angle
	pop hl
	push hl
	push hl ;entity pointer
	ld e, b
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	ld d, a ;extend resulting B into DE, and C into BC
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b ;BC << 3
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d ;DE << 3
	ldh a, [hXPosLow]
	add a, c
	ld [hl+], a
	ldh a, [hXPosHi]
	adc a, b
	ld [hl+], a
	ldh a, [hYPosLow]
	add a, e
	ld [hl+], a
	ldh a, [hYPosHi]
	adc a, d
	ld [hl+], a ;write our position plus the distance to the entity's position
	pop de
	dec de ;DE points to entity model
	pop hl
	push hl ;entity pointer
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;HL += 7 (Z orientation)
	ld a, [wViewDir]
	add a, $80
	ld [hl], a ;set orientation to face us
	pop hl
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;set pointer to entity logic pointer
	ld a, [de] ;model
	dec a ;use model as offset
	call CallSetEntityLogicPointer
	ret
	
LightTankManLogic: ;485F, logic called by light tanks and man
	ld a, [$CB03]
	inc a
	ld [$CB03], a ;increment humantank counter
	ld e, l
	ld d, h ;backup pointer
	dec de
	ld a, [de] ;load model
	cp $2E ;man
	jr nz, .doneFootsteps ;if not man (light tank), jump ahead
	ld a, [wUpdateCounter]
	and $01
	jr nz, .doneFootsteps ;skip every other update
	push hl
	push de
	push bc ;backup everything
	ld de, wQueueNoise
	ld a, $11 ;footstep
	call CallEntityPlayShootShound
	pop bc
	pop de
	pop hl ;restore everything
.doneFootsteps ;15, E
	ld e, l
	ld d, h ;backup pointer
	ld a, l
	add a, $16
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to penultimate byte
	bit 1, [hl] ;test bit 1 (targets)
	jr nz, .notargets ;if set (no targets), jump to C8EF
	ld l, e
	ld h, d ;restore pointer
	ld a, l
	add a, $0D
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to speed... are these targets?
	ld b, $04
.targetloop
	dec b
	jr z, .setnotargets ;to C8E3
	ld a, [hl+]
	ld c, a
	cp $80
	ld a, [hl+]
	jr z, .targetloop
	ld b, a
	push hl ;save pointer
	ld l, e
	ld h, d ;restore pointer
	ld a, l
	add a, $01
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;low x
	ld a, [hl+]
	sub a, c
	ld c, a
	ld a, c
	add a, $03
	cp $06
	jr nc, .highX ;jump if high x
	inc hl
	ld a, [hl+] ;low y
	sub a, b
	ld b, a
	ld a, b
	add a, $03
	cp $06
	jr nc, .hasTarget ;jump if high y
	pop hl
	dec hl
	ld a, $80
	ld [hl-], a
	ld [hl-], a ;else reset these
	ret
.highX ;12
	inc hl
	ld a, [hl+]
	sub a, b
	ld b, a ;handle y
.hasTarget ;B
	add sp, $02
	push de
	ld d, b
	ld b, c
	ld c, $00
	ld e, c
	push de
	call CallGetAngleToOffset
	pop de
	pop hl
	jr .haveAngle
.setnotargets ;43
	ld l, e
	ld h, d
	ld a, l
	add a, $16
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	set 1, [hl] ;set penultimate byte bit
.notargets ;5E
	ld l, e
	ld h, d
	ld a, l
	add a, $13
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;final target
	ld a, [hl] ;load value ($80?)
	ld hl, wEntityTable
	push de
	call CallFindEntityWithModel
	pop de
	jr nc, .entFound ;jump if ent found
	ld l, e
	ld h, d
	jp .moveEnt ;otherwise restore pointer and jump
.entFound ;5
	inc hl
	call CallGetAngleBetweenEnts
.haveAngle ;2A
	sub $80 ;invert angle
	ld c, a
	push hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance to Z orientation (top-down spin)
	ld a, c
	sub a, [hl] ;get the difference
	add a, $08
	cp $10
	jr c, .doneTurning ;if behind us, jump
	sub $08
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft
	ld a, [hl]
	sub $20
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
	pop hl
.moveEnt ;493C
	ld e, l
	ld d, h
	ld a, e
	add a, $14
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	ld b, a
	ld c, $00
	call CallMoveEntityForward
	call CallTestEntityHasCollisions
	ret nc ;return if no collisions
	dec de
	dec hl
	ld a, [hl+]
	cp $03 ;radar?
	jr nz, .boom ;not a match, jump
	push hl
	call CallGetEntityArea
	inc a
	ld [wLatestRadarDestroyed], a
	pop hl
	push hl
	ld c, $64
	call CallFlashEntityCell
	pop hl
.boom ;10
	ld a, $FF
	call CallDamageEntity
	ret
	
;496E
	dw $4974 ;pointer to ?
;4970
	dw 0, 0
;4974
	dw $4000, $6000, 0, $FF00, $FFFF, $FFFF
REPT $80
	db 0
ENDR
	
RadarGFX: ;4A00 - 4AFF: radar graphics
	INCBIN "build/gfx/Radar.2bpp"
	
JunctionStockedTilemap: ;4B00
	db $14, $12 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01 
	db $02, $02, $02, $03, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $05, $00, $06, $07, $07 
	db $07, $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0A, $00, $06, $07, $07, $07, $08 
	db $09, $09, $0B, $0C, $0D, $0E, $0F, $10, $11, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09 
	db $12, $13, $14, $15, $16, $17, $11, $09, $09, $0A, $00, $06, $18, $19, $1A, $08, $09, $09, $09, $1B 
	db $09, $1C, $1D, $1E, $1F, $09, $09, $0A, $00, $06, $20, $21, $22, $08, $09, $09, $23, $24, $25, $26 
	db $27, $28, $29, $09, $09, $0A, $00, $06, $2A, $2B, $2C, $08, $09, $09, $2D, $2E, $2F, $30, $31, $32 
	db $33, $09, $09, $0A, $00, $06, $34, $35, $36, $08, $09, $09, $37, $38, $39, $3A, $3B, $3C, $3D, $09 
	db $09, $0A, $00, $06, $3E, $3F, $40, $08, $09, $09, $41, $42, $43, $44, $45, $46, $47, $09, $09, $0A 
	db $00, $06, $48, $49, $4A, $08, $09, $09, $4B, $4C, $4D, $4E, $4F, $09, $09, $09, $09, $0A, $00, $06 
	db $50, $51, $52, $08, $09, $09, $53, $54, $55, $56, $57, $58, $59, $09, $09, $0A, $00, $06, $5A, $5B 
	db $40, $08, $09, $09, $5C, $5D, $5E, $5F, $60, $61, $62, $09, $09, $0A, $00, $06, $63, $64, $65, $08 
	db $09, $09, $66, $67, $68, $69, $6A, $6B, $6C, $09, $09, $0A, $00, $06, $6D, $6E, $6F, $08, $09, $09 
	db $70, $71, $72, $73, $74, $75, $76, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $77, $78 
	db $79, $7A, $7B, $7C, $7D, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $09, $09, $09, $09 
	db $09, $09, $09, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $09, $09, $09, $09, $09, $09 
	db $09, $09, $09, $0A, $00, $7E, $7F, $7F, $7F, $80, $81, $81, $81, $81, $81, $81, $81, $81, $81, $81 
	db $81, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;4C6A
	INCBIN "build/gfx/JunctionShopStocked.rle"
	
JunctionBoughtTilemap: ;5244
	db $14, $12 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01 
	db $02, $02, $02, $03, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $05, $00, $06, $07, $07 
	db $07, $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0A, $00, $06, $07, $07, $07, $08 
	db $09, $09, $0B, $0C, $0D, $0E, $0F, $10, $11, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09 
	db $12, $13, $14, $15, $16, $17, $11, $09, $09, $0A, $00, $06, $18, $19, $1A, $08, $09, $09, $09, $1B 
	db $1C, $1D, $1E, $1F, $20, $09, $09, $0A, $00, $06, $21, $22, $23, $08, $09, $09, $24, $25, $26, $27 
	db $28, $29, $2A, $09, $09, $0A, $00, $06, $2B, $2C, $2D, $08, $09, $09, $2E, $2F, $30, $31, $32, $33 
	db $34, $09, $09, $0A, $00, $06, $35, $36, $37, $08, $09, $09, $38, $39, $3A, $3B, $3C, $3D, $3E, $09 
	db $09, $0A, $00, $06, $3F, $40, $41, $08, $09, $09, $42, $43, $44, $45, $46, $47, $48, $09, $09, $0A 
	db $00, $06, $49, $4A, $4B, $08, $09, $09, $4C, $4D, $4E, $4F, $50, $09, $09, $09, $09, $0A, $00, $06 
	db $51, $52, $53, $08, $09, $09, $54, $55, $56, $57, $58, $59, $5A, $09, $09, $0A, $00, $06, $5B, $5C 
	db $41, $08, $09, $09, $5D, $5E, $5F, $60, $61, $62, $63, $09, $09, $0A, $00, $06, $64, $65, $66, $08 
	db $09, $09, $67, $68, $69, $6A, $6B, $6C, $6D, $09, $09, $0A, $00, $06, $6E, $6F, $70, $08, $09, $09 
	db $71, $72, $73, $74, $75, $76, $77, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $78, $79 
	db $7A, $7B, $7C, $7D, $7E, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $09, $09, $09, $09 
	db $09, $09, $09, $09, $09, $0A, $00, $06, $07, $07, $07, $08, $09, $09, $09, $09, $09, $09, $09, $09 
	db $09, $09, $09, $0A, $00, $7F, $80, $80, $80, $81, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82 
	db $82, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;53AE
	INCBIN "build/gfx/JunctionShopBought.rle"
		
JunctionShopTilemap: ;5980
	db $14, $12 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $01, $02, $02, $02, $03, $04, $04, $04, $04, $04, $04, $04, $04, $05, $00, $00, $00, $00, $06, $07 
	db $08, $09, $0A, $0B, $0B, $0C, $0B, $0B, $0B, $0D, $0B, $0E, $00, $00, $00, $00, $06, $0F, $10, $11 
	db $0A, $0B, $12, $13, $14, $15, $16, $17, $18, $0E, $00, $00, $00, $00, $06, $19, $1A, $1B, $0A, $0B 
	db $1C, $1D, $1E, $1F, $20, $21, $0B, $0E, $00, $00, $00, $00, $06, $22, $23, $24, $0A, $0B, $25, $26 
	db $27, $28, $29, $2A, $2B, $0E, $00, $00, $00, $00, $06, $2C, $2D, $2E, $0A, $0B, $2F, $30, $31, $32 
	db $33, $34, $35, $0E, $00, $00, $00, $00, $06, $36, $37, $38, $0A, $0B, $0B, $39, $3A, $3B, $3C, $3D 
	db $3E, $0E, $00, $00, $00, $00, $06, $3F, $40, $41, $0A, $0B, $42, $43, $44, $45, $46, $47, $48, $0E 
	db $00, $00, $00, $00, $06, $49, $4A, $4B, $0A, $0B, $4C, $4D, $4E, $4F, $50, $51, $52, $0E, $00, $00 
	db $00, $00, $06, $53, $54, $55, $0A, $0B, $56, $57, $58, $59, $5A, $5B, $5C, $0E, $00, $00, $00, $00 
	db $06, $5D, $5E, $5F, $0A, $0B, $60, $61, $62, $63, $64, $65, $66, $0E, $00, $00, $00, $00, $06, $67 
	db $68, $69, $0A, $0B, $6A, $6B, $6C, $6D, $6E, $6F, $70, $0E, $00, $00, $00, $00, $06, $71, $72, $73 
	db $0A, $0B, $74, $75, $76, $77, $78, $79, $7A, $0E, $00, $00, $00, $00, $06, $7B, $7C, $7D, $0A, $0B 
	db $7E, $7F, $80, $81, $82, $83, $84, $0E, $00, $00, $00, $00, $06, $85, $86, $87, $0A, $0B, $88, $89 
	db $8A, $8B, $8C, $8D, $8E, $0E, $00, $00, $00, $00, $06, $8F, $90, $91, $0A, $0B, $92, $93, $94, $95 
	db $96, $97, $98, $0E, $00, $00, $00, $00, $06, $99, $9A, $9B, $0A, $0B, $0B, $0B, $0B, $0B, $0B, $0B 
	db $0B, $0E, $00, $00, $00, $00, $9C, $9D, $9D, $9D, $9E, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9F, $A0 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;5AE0
	INCBIN "build/gfx/JunctionShop.rle"
		
tilesetMainInterface: ;6291 tileset for tunnels?
	db $14, $12 ;dimensions
	db $00, $01, $02, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C 
	db $0D, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0F, $10, $06, $07, $11, $12, $13, $14, $07, $07, $07 
	db $07, $07, $07, $07, $07, $07, $07, $07, $07, $06, $07, $11, $15, $13, $14, $07, $07, $07, $07, $07 
	db $07, $07, $07, $07, $07, $07, $07, $06, $07, $11, $07, $13, $14, $07, $07, $07, $07, $07, $07, $07 
	db $07, $07, $07, $07, $07, $06, $07, $11, $07, $13, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07 
	db $07, $07, $07, $06, $07, $11, $07, $13, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 
	db $07, $06, $07, $11, $07, $13, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $16 
	db $17, $18, $19, $1A, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $1B, $07, $07, $07 
	db $07, $07, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 
	db $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $14, $07 
	db $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $1B, $07, $07, $07, $07, $07, $14, $07, $07, $07 
	db $07, $07, $07, $07, $07, $07, $07, $07, $07, $1C, $1D, $1E, $1F, $1F, $14, $07, $07, $07, $07, $07 
	db $07, $07, $07, $07, $07, $07, $07, $20, $07, $07, $07, $07, $14, $07, $07, $07, $07, $07, $07, $07 
	db $07, $07, $07, $07, $07, $20, $07, $07, $07, $07, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07 
	db $07, $07, $07, $20, $07, $07, $07, $07, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 
	db $07, $20, $07, $07, $07, $07, $14, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $21 
	db $22, $22, $22, $22, $23, $24, $25, $07, $07, $07, $07, $07, $07, $07, $07, $26, $27, $28, $07, $07 
	db $07, $07, $29, $01, $2A, $07, $07, $07, $07, $07, $07, $07, $07, $2B, $2C, $28, $07, $07, $07, $07
;63FB
	INCBIN "build/gfx/3DWindowBorder.rle"

RadarBaseTilemap: ;6616
	db $14, $12 
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $03, $04, $04, $04, $04, $05, $06, $07 
	db $08, $09, $09, $09, $09, $09, $09, $09, $09, $0A, $0B, $0C, $0C, $0C, $0C, $0D, $06, $0E, $0F, $0C 
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $10, $11, $0C, $0C, $0C, $0C, $0D, $06, $12, $13, $0C, $0C, $0C 
	db $0C, $0C, $0C, $0C, $0C, $14, $15, $0C, $0C, $0C, $0C, $0D, $06, $16, $17, $0C, $0C, $0C, $0C, $0C 
	db $0C, $0C, $0C, $18, $19, $0C, $0C, $0C, $0C, $0D, $06, $1A, $1B, $0C, $0C, $0C, $0C, $0C, $0C, $0C 
	db $0C, $1C, $1D, $0C, $0C, $0C, $0C, $0D, $06, $1E, $1F, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $20 
	db $21, $0C, $0C, $0C, $0C, $0D, $06, $22, $23, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $24, $25, $26 
	db $26, $26, $26, $27, $06, $28, $29, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2A, $2B, $0C, $0C, $0C 
	db $0C, $2C, $06, $2D, $2E, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2A, $2B, $0C, $0C, $0C, $0C, $2C 
	db $06, $2F, $30, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2A, $2B, $0C, $0C, $0C, $0C, $2C, $06, $31 
	db $32, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2A, $2B, $0C, $0C, $0C, $0C, $2C, $06, $33, $34, $0C 
	db $0C, $0C, $0C, $0C, $0C, $0C, $0C, $2A, $35, $36, $36, $36, $36, $37, $06, $38, $39, $0C, $0C, $0C 
	db $0C, $0C, $0C, $0C, $0C, $2A, $3A, $0C, $0C, $0C, $0C, $0D, $06, $3B, $3C, $0C, $0C, $0C, $0C, $0C 
	db $0C, $0C, $0C, $3D, $3E, $0C, $0C, $0C, $0C, $0D, $06, $3F, $40, $0C, $0C, $0C, $0C, $0C, $0C, $0C 
	db $0C, $41, $42, $0C, $0C, $0C, $0C, $0D, $06, $43, $44, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $45 
	db $46, $0C, $0C, $0C, $0C, $0D, $06, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $47, $48, $0C 
	db $0C, $0C, $0C, $0D, $06, $0C, $0C, $49, $49, $49, $49, $49, $49, $49, $49, $4A, $3A, $0C, $0C, $0C 
	db $0C, $0D, $4B, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4C, $4D, $4E, $4F, $4F, $4F, $4F, $50
;6780
	INCBIN "build/gfx/RadarBaseInterior.rle"
	
presentsGFX: ;6A6D
	INCBIN "build/gfx/Presents.1bpp"
	
TitleScreenPlanetTilemap: ;6BED: planet tileset for title screen
	db $14, $12
	db $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00 
	db $01, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00, $03, $04, $05, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $07, $08, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $01, $00, $09, $0A, $0B, $0C, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $0D, $0E, $0F, $10, $11, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $12, $13, $14, $15, $16, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $17, $18, $19, $1A, $1B, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $1C 
	db $1D, $1E, $1F, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $21, $22, $23 
	db $24, $25, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $26, $27, $28, $29, $2A, $2B 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2C, $2D, $2E, $2F, $30, $31, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $32, $33, $00, $34, $00, $35, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $36, $37, $00, $38, $39, $3A, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $3B, $3C, $3D, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $3E, $3F, $40, $41, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $42, $43, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $44, $00, $01, $45, $46, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $47 
	db $48, $00, $49, $4A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $4B, $4C, $00 
	db $4D, $4E, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $4F
;6D57
	INCBIN "build/gfx/TitlePlanet.rle"
GameOverTilemap: ;71EB: tileset for game over
	db $14, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $04, $00, $00 
	db $05, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $07, $00, $00, $08, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A, $00, $00, $0B, $00, $0C, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0D, $0E, $00, $00, $0F, $00, $10, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $11, $12, $00, $00, $13, $00, $14, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $15, $16, $00, $00, $17, $00, $18, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $19, $1A, $00, $00, $1B, $00, $1C, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $1D, $1E, $00, $00, $1F, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $21, $22, $00, $00, $23, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $24, $25 
	db $00, $00, $26, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $27, $28, $00, $00 
	db $29, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2A, $2B, $00, $00, $2C, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2D, $2E, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;7355
	INCBIN "build/gfx/GameOverText.rle"
ContinueBottomTilemap: ;7609: tileset for game over bottom frame
	db $14, $05 
	db $00, $01, $01, $01, $02, $03, $04, $04, $04, $05, $03, $04, $06, $04, $05, $03, $04, $07, $08, $05 
	db $03, $04, $09, $0A, $05, $03, $04, $04, $0B, $05, $03, $04, $04, $04, $05, $03, $04, $04, $04, $05 
	db $03, $0C, $04, $04, $05, $03, $0D, $04, $04, $05, $03, $0E, $04, $04, $05, $03, $0F, $04, $10, $05 
	db $03, $04, $11, $12, $05, $03, $04, $04, $0B, $05, $03, $04, $04, $04, $05, $03, $04, $04, $04, $05 
	db $03, $04, $04, $04, $05, $03, $04, $04, $04, $05, $03, $04, $04, $04, $05, $13, $14, $14, $14, $15
;766F
	INCBIN "build/gfx/ContinueBottomBox.rle"
MissionResultsBorderTilemap: ;777A: tileset for mission clear screen
	db $14, $0D 
	db $00, $01, $02, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03 
	db $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04 
	db $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03 
	db $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05 
	db $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03 
	db $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06 
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03 
	db $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03 
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03 
	db $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03 
	db $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03 
	db $03, $04, $05, $06, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $04, $05, $06, $03, $03, $03 
	db $03, $03, $03, $03, $03, $03, $03, $07, $08, $09, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
;7880
	INCBIN "build/gfx/MissionClearBorder.rle"
	
IF UNUSED == 1
StaffRollTilemap: ;78D1
	db $20, $20
REPT 8
REPT 8
	db $00, $01, $02, $03
ENDR
REPT 8
	db $04, $05, $06, $07
ENDR
REPT 8
	db $02, $03, $00, $01
ENDR
REPT 8
	db $06, $07, $04, $05
ENDR
ENDR
;7CD3
	INCBIN "build/GFX/StaffRollStars.rle"
ENDC

ContinueTextTilemap: ;7D40: tileset for continue
	db $14, $0D 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $05, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $08, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $0B, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0D, $0E, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $0F, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $11, $12, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $13, $14, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $15, $16, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $17 
	db $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;7E46
	INCBIN "build/gfx/ContinueText.rle"
;7F90