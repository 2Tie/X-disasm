SECTION "8:TOP", ROMX[$4000], BANK[8]
MapObjectTables: ;4000
	dw MapObjectsLevel1
	dw MapObjectsLevel2
	dw MapObjectsLevel3
	dw MapObjectsLevel4
	dw MapObjectsLevel5
	dw MapObjectsLevel6
	dw MapObjectsLevel7
	dw MapObjectsLevel8
	dw MapObjectsLevel9
	dw MapObjectsLevel10
	dw BLANK_POINTER ;escape!
	dw MapObjectsLevelTut ;tut
	
MoveBriefingEntForward: ;4018, briefing logic
	ld a, l
	add a, $0E
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	ld b, a
	ld c, $00
	call CallMoveEntityForward
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [de]
	add a, [hl]
	ld [hl], a
	ret
	
BreifingEntBounce: ;403B, briefing logic
	ld e, l
	ld d, h
	ld a, e
	add a, $14
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld a, [hl] ;ent byte 14
	add a, $04
	ld [hl], a ;increment
	cp $80
	jr nc, .cont ;if negative, keep going
	cp $18
	jp nc, .negate ;if > $18, set value to -$18
.cont ;5
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;bc sign-extended incremented byte
	ld a, e
	add a, $04
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld a, [hl] ;ent byte 4/5
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;+= incremented byte
	ld l, e
	ld h, d
	jp BriefingEntMoveOffsets ;and jump
.negate ;406D
	ld [hl], $E8
	ret

EntityLogicMiniRadar: ;4070, mini radar logic
	ld e, l
	ld d, h ;backup pointer
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance to speed byte
	ld a, [de]
	ld c, a ;load into C
	inc de
	ld a, [de]
	ld b, a ;speedup into B
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;z orientation
	bit 0, b
	jr nz, .bit
	ld a, [hl]
	add a, c
	ld [hl+], a
	ret
.bit ;4
	res 0, b
	ld a, [hl]
	cp b
	ret z
	add a, c
	ld [hl+], a
	ret
	
BriefingEntMoveOffsets: ;4097, called by briefing entity?
	ld e, l
	ld d, h
	ld a, e
	add a, $0D
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	inc de
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extended ent byte D into BC
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;add to first word (x?)
	ld a, [de]
	inc de
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extended ent byte E into BC
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;add to second word (Y?)
	ld a, [de]
	inc de
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a ;sign-extend ent byte F into BC
	ld a, [hl]
	add a, c
	ld [hl+], a
	ld a, [hl]
	adc a, b
	ld [hl+], a ;add to third word (Z?)
	ret
	
BriefingEntRotate: ;40D2, briefing logic
	push hl
	inc hl
	ld a, [hl+]
	ld b, a ;hi X
	inc hl
	ld a, [hl+]
	ld d, a ;hi Z
	ld a, l
	add a, $09
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl byte D
	ld a, b
	sub a, [hl]
	ld b, a ;whee
	inc hl ;hl byte e
	ld a, d
	sub a, [hl]
	ld d, a ;whee
	ld c, $00
	ld e, c
	call CallGetAngleToOffset
	pop hl
	push hl
	sub $80
	ld c, a ;angle to c
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, c
	sub a, [hl] ;orientation
	add a, $08
	cp $10
	jr c, .doneTurn
	sub $08
	cp $90
	jr c, .turnRight
	cp $70
	jr nc, .turnLeft
	ld a, [hl]
	sub $80
	ld [hl], a
	jr .doneTurn
.turnRight ;A
	ld a, [hl]
	add a, $01
	ld [hl], a
	jr .doneTurn
.turnLeft ;C
	ld a, [hl]
	sub $01
	ld [hl], a
.doneTurn ;1A, A, 4
	pop hl
	ld a, l
	add a, $0F
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	ld b, a
	ld c, $00
	call CallMoveEntityForward
	ret
	

DrawCountdownDigit: ;412E
	rlca
	rlca
	rlca
	rlca ;move passed value up a nybble
	ld c, a
	rlca
	add a, c ;and times 3
	add a, LOW(TunnelCountdownGFX)
	ld l, a
	ld a, HIGH(TunnelCountdownGFX)
	adc a, $00
	ld h, a
	ld de, $D740 ;1bpp buffer coord
	ld b, $02
.outerloop ;4142
	ld c, $14
.innerloop ;4144
	ld a, [hl+]
	ld [de], a
	inc e
	dec c
	jp nz, .innerloop
	inc hl
	inc hl
	inc hl
	inc hl
	ld e, $40
	inc d
	dec b
	jp nz, .outerloop
	ret

IterateOverMapObjects: ;4157
	ldh a, [hXPosHi]
	sub $20
	ldh [$FFF5], a
	ldh a, [hYPosHi]
	sub $20
	ldh [$FFF7], a
	ld a, [wCurLevel]
	rrca ;use level as word offset
	and $7E
	add a, LOW(MapObjectTables)
	ld l, a
	ld a, HIGH(MapObjectTables)
	adc a, $00
	ld h, a ;top of bank table
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	xor a ;clear incrementer
.loop ;4175
	inc a ;if a is FF, return
	ret z
.loopnoincrement ;4177
	push af ;save incrementer
	bit 7, [hl] ;check top bit of value
	jp z, .checkobject ;if not set, jump
	;else, value was >= $80
	push hl ;save our position
	ld b, a ;save our slot number into b
	ld a, [hl+]
	ld c, a ;C is now our read byte
	inc a
	jp z, .respawnscommand ;if FF (-1?), jump
	inc a
	jp z, .dblprecisioncommand ;if FE (-2?), jump
	inc a
	jp z, .jumpcommand ;if FD (-3?), jump
	jp .modifyentitycommand
	
.jumpcommand ;4190, value was -3
	pop hl
	inc hl
	ld a, [hl+] ;-3 ($FD) means load next word into HL (a jump)
	ld h, [hl]
	ld l, a
	pop af
	jp .loopnoincrement
.dblprecisioncommand ;4199, value was -2
	ld a, $01
	ldh [$FF97], a ;load 01 into FF97
	pop hl
	inc hl
	ld a, b ;restore slot value into A
	jp .checkobjectkeepprecision
.respawnscommand ;41A3, value was -1
	xor a
	ld [wFoundEntityPointerLo], a ;clear out selected entity
	ld [wFoundEntityPointerHi], a
	ld a, b ;restore slot value
	call GetMapObjectDestroyedFlag
	jp z, .comalive ;jump if alive
	pop hl
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;otherwise advance 6 bytes and loop
	pop af
	jp .loop 
.comalive ;41BE
	pop hl
	pop af
	push af ;restore position and iterator
	call DestroyMapObject
	inc hl
	xor a
	push af ;stack is now iterator and zero
	ld a, [hl+]
	ld c, a ;set up for next byte to be an object entry
	ld a, $01
	ldh [$FF97], a ;extra precision
	jp .createentity
	
.modifyentitycommand ;41D0, value wasn't -1, -2, or -3
	;interpret it as a positive number (0-9) with a flag set
	ld a, [wFoundEntityPointerLo]
	ld e, a
	ld a, [wFoundEntityPointerHi]
	ld d, a ;load those values into DE
	or e
	ld a, c ;read value
	call nz, ModifyEntityValue ;if DE held any values, call. saves next byte or two into offsets.
	pop hl
	ld a, l
	add a, $03
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;read position += 3 (the call above reads two bytes)
	pop af ;restore our iterator
	jp .loopnoincrement
	
.checkobject ;41EA, top bit wasn't set
	ld c, a ;slot value into C
	xor a
	ldh [$FF97], a ;00 into 97
	ld a, c ;restore slot value
.checkobjectkeepprecision ;41EF
	call GetMapObjectDestroyedFlag ;call with slot value
	jp z, .objectalive ;jump if alive
	ldh a, [$FF97]
	or a ;0 or 1 based on how we got here
	ld a, $03
	jr z, .jmpahead
	ld a, $05
.jmpahead
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;jump ahead 3 or 5 based on FF97 (the read byte plus X/Y)
	xor a
	ld [wFoundEntityPointerLo], a
	ld [wFoundEntityPointerHi], a ;zero out these bytes again
	pop af
	jp .loop ;don't increment
	
.objectalive ;420F
	;specified entity is currently alive
	xor a
	ld [wFoundEntityPointerLo], a
	ld [wFoundEntityPointerHi], a ;zero these out
	ld a, [hl+] ;re-read the entry i guess (should be a model ID for this object)
	or a
	jp z, .ret ;if zero, we're reached the end of the object list
	ld c, a ;backup read value
	ldh a, [$FF97]
	or a
	jp z, .noinc1
	inc hl ;if ff97 set, skip a byte?? should never happen
.noinc1 ;4223
	ldh a, [$FFF5]
	ld b, a ;load FFF5 into B
	ld a, [hl+]
	sub a, b ;subtract it from next value
	cp $40
	jp nc, .skipObjY ;if $40 or above, jump ahead
	ldh a, [$FF97]
	or a
	jp z, .noinc2
	inc hl
.noinc2 ;4234
	ldh a, [$FFF7]
	ld b, a
	ld a, [hl-]
	sub a, b
	cp $40
	jp nc, .skipObjXY ;same but with FFF7, if $40 or above jump ahead
	ldh a, [$FF97]
	or a
	jp z, .nodec
	dec hl
	dec hl
.nodec ;4246
	pop af
	push af
	call FindEntityData ;check if an entity with that map object ID exists
	jp nc, .createentity ;if not, try to make it
	ldh a, [$FF97] ;entity found, so contnue onwards with reading
	or a
	ld a, $02
	jr z, .jmpaheadagain
	ld a, $04
.jmpaheadagain
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance past the rest of the entry
	pop af
	jp .loop 
	
.createentity ;4261
	push hl
	ld a, c
	push bc
	call GetFreeEntity
	pop bc
	pop de
	jp c, .ret ;if none found, return
	ld a, c
	ld [hl+], a ;set the model
	ld a, l
	ld [wFoundEntityPointerLo], a ;save pointer to THIS entity's X
	ld a, h
	ld [wFoundEntityPointerHi], a
	ldh a, [$FF97]
	or a
	jr z, .loadwith0
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	jr .loadedPos
.loadwith0
	xor a
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	xor a
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
.loadedPos
	ld a, l
	add a, $05
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;skip over third coord and orientations
	push bc
	ld a, LOW(EntityLogicPointers-2)
	add a, c
	add a, c ;model ID as word offset into $5020 in bank 2
	ld c, a
	ld a, HIGH(EntityLogicPointers)
	adc a, $00
	ld b, a ;BC is pointer address
	call RetrieveWordFromBank2
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl+], a ;write the entity logic pointer
	pop bc
	ld a, LOW(EntityHealthValues)
	add a, c
	ld c, a
	ld a, HIGH(EntityHealthValues)
	adc a, $00
	ld b, a ;the same with $50CC
	call RetrieveWordFromBank2
	ld a, c
	ld [hl+], a ;write health to the entity
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;clear out the rest of the vals
	pop af
	ld [hl+], a ;except write our map object ID into the final byte
	or a
	jr nz, .skippop
	pop af
.skippop
	ld l, e
	ld h, d ;DE is our new position
	jp .loop 
.ret ;42D3
	pop af
	or a
	ret nz
	pop af
	ret
	
.skipObjXY ;42D8
	ldh a, [$FF97]
	or a
	ld a, $02
	jr z, .useless
	ld a, $02
.useless
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop af
	jp .loop
	
.skipObjY ;42EB
	ldh a, [$FF97]
	or a
	ld a, $01
	jr z, .skipplz
	ld a, $02
.skipplz
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop af
	jp .loop 
	
GetMapObjectDestroyedFlag: ;42FE
	ld e, a ;backup read byte
	rrca
	rrca
	rrca ;divide val by 8
	and $1F
	add a, LOW(wEntityDestroyedFlags)
	ld c, a
	ld a, HIGH(wEntityDestroyedFlags)
	adc a, $00
	ld b, a ;BC is $C240 + val/8
	ld a, e
	and $07
	ld e, a ;and our val & 7 is used to grab a bit from $0000
	ld d, $00
	ld a, [de]
	ld e, a
	ld a, [bc]
	and e ;use top val as mask for value in $C240 table
	ret ;returns zero if alive, nonzero if dead
	
CheckDeloadEntity: ;4317
	push hl ;save our spot in the entity list
	call EntityProximity
	pop hl
	ret c ;return if carry set
	dec hl
	xor a
	ld [hl+], a ;clear model
	ld a, l
	add a, ENTITY_SIZE - 2 ;going from second entry to last)
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	xor a
	ld [hl+], a ;clear out map object ID as well
	ret

FindEntityData: ;432B
	push hl
	push bc
	ld hl, wEntityTable+ENTITY_SIZE-1 ;final byte in entity 0
	ld e, ENTITY_SLOTS
	ld bc, ENTITY_SIZE
.searchloop
	cp [hl]
	jp z, .found ;if value matches accumulator, jump?
	add hl, bc
	dec e
	jp nz, .searchloop
	pop bc
	pop hl
	and a ;clear carry flag
	ret
.found ;4342
	pop bc
	pop hl
	scf ;set carry flag
	ret
	
EntityProximity: ;4346
	ld e, l
	ld d, h ;de is our entity position
	ld a, e
	add a, $17
	ld e, a
	ld a, d
	adc a, $00
	ld d, a ;advance to the final byte?
	ld a, [de]
	or a
	scf
	ret z ;if not a map object, return with carry set
	inc hl ;go to its Xhi
	ldh a, [hXPosHi]
	sub $20
	ld b, a ;our X - 20
	ld a, [hl+]
	sub a, b ;subtract our X from its X
	cp $40
	jr nc, .clrflag ;if not within 40 units, clear and return
	inc hl ;go to its Y hi
	ldh a, [hYPosHi]
	sub $20
	ld b, a
	ld a, [hl-] ;hl now at Y lo
	sub a, b
	cp $40
	jr nc, .clrflag
	ret
.clrflag
	and a
	ret
	
DestroyEntityObject: ;436F
	push hl
	push de
	dec hl
	set 7, [hl] ;set disassemble flag on model
	ld a, l
	add a, $17
	ld e, a
	ld a, h
	adc a, $00
	ld d, a
	ld a, [de]
	res 2, a ;clear assembly flag
	ld [de], a
	ld a, l
	add a, $18
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld e, a ;grab map ID
	rrca
	rrca
	rrca
	and $1F
	add a, LOW(wEntityDestroyedFlags)
	ld l, a
	ld a, HIGH(wEntityDestroyedFlags)
	adc a, $00
	ld h, a ;HL is byte
	ld a, e
	and $07
	ld e, a
	ld d, $00
	ld a, [de] ;load bitflag
	or [hl]
	ld [hl], a ;set to destroy
	pop de
	pop hl
	ret

DestroyMapObject: ;43A3
	ld e, a
	rrca
	rrca
	rrca
	and $1F
	add a, LOW(wEntityDestroyedFlags)
	ld c, a
	ld a, HIGH(wEntityDestroyedFlags)
	adc a, $00
	ld b, a ;BC is the byte
	ld a, e
	and $07
	ld e, a
	ld d, $00
	ld a, [de] 
	ld e, a ;the mask
	ld a, [bc]
	or e
	ld [bc], a ;set the flag
	ret
;43BD

SECTION "8:4500", ROMX[$4500], BANK[8]
TunnelCountdownGFX: ;4500
	INCBIN "build/gfx/TunnelCountdown.1bpp"
	
PlayerJump: ;45C0
	xor a
	ld [wCollisionType], a
	ld a, [wFlyingFlag]
	or a
	ret nz
	ldh a, [hZPosLow]
	cp $14
	ret nz
	ldh a, [hZPosHi]
	cp $00
	ret nz ;must not be flying, and z position must be $0014
	ld a, [wLurchCounter]
	bit 7, a
	jr z, .pos
	cpl
	inc a ;invert lurch counter
	srl a
	srl a
	srl a
	ld c, a ;divide by eight
	jr .hop
.pos ;B
	srl a
	srl a
	ld c, a ;divide by four
	cp $11
	jr c, .hop ;below 11? jump
	ldh a, [hSpeedTier]
	cp spdTURBO
	jr nz, .hop
	ld a, $80
	ld [wFlyingFlag], a ;we're flying!
.hop ;14, B, 5
	ld a, [wFlightPitch]
	add a, c
	ld [wFlightPitch], a
	ld a, $04
	ld [wQueueNoise], a
	ret

ClearAllTunnelEnts: ;4606
	ld hl, wTunnelEntities
	ld bc, TUNNEL_ENTITIES_SIZE - 1
	ld a, $FF
	ld d, TUNNEL_ENTITIES_COUNT
.loop
	ld [hl+], a
	add hl, bc
	dec d
	jr nz, .loop
	ret
	
MoveTunnelEntsCloser: ;4616
	ld hl, wTunnelEntities
	ld bc, TUNNEL_ENTITIES_SIZE
	ld d, TUNNEL_ENTITIES_COUNT
.loop
	ld a, [hl]
	cp $FF
	sbc a, $00 ;if $FF stay $FF, otherwise decrement
	ld [hl], a
	add hl, bc
	dec d
	jr nz, .loop
CollapseTunnelEnts: ;4628
	ld hl, wTunnelEntities
	ld a, $09
.mainloop
	push af
	ld a, [hl]
	cp $FF
	jr nz, .nextent ;we're searching for FF entries
	push hl
	ld e, l
	ld d, h ;hl backup in de
	ld a, l
	add a, TUNNEL_ENTITIES_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl is at the next entity
	ld bc, wTunnelEntitiesEnd
	ld a, c
	sub a, l
	ld c, a
	ld a, b
	sbc a, h
	ld b, a ;BC = wTunnelEntitiesEnd -= next entity (how much space left??)
.loop
	ld a, [hl+]
	ld [de], a ;move next entity into this one
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop ;until b = 0, aka copy the rest of the list down
	ld a, l
	sub TUNNEL_ENTITIES_SIZE
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;move to final entity
	ld [hl], $FF ;overwrite it with FF
	pop hl
.nextent
	ld a, l
	add a, TUNNEL_ENTITIES_SIZE
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;hl to next ent
	pop af
	dec a
	jr nz, .mainloop
	ret
;4667

SECTION "8:4683", ROMX[$4683], BANK[$8]
ModifyEntityTable: ;4683, offset table, how many bytes to copy, padding byte
	dw $000D, 2 ;80, map value 1
	dw $000F, 2 ;81, map value 2
	dw $0011, 2 ;82, map value 3
	dw $0013, 2 ;83, map value 4
	dw $0006, 1 ;84, x orientation, byte
	dw $0008, 1 ;85, z orientation, byte
	dw $0009, 2 ;86, entity logic
	dw $000B, 1 ;87, entity HP
	dw $0004, 2 ;88, y position, word
	dw $0007, 1 ;89, y orientation, byte

ModifyEntityValue: ;46AB
	;DE is pointer into entity data, a is an index into the table above.
	;writes 1 or 2 bytes from hl into the entity
	res 7, a ;clear top bit of read value to get the positive index
	sla a
	sla a ;table is four bytes each
	add a, LOW(ModifyEntityTable)
	ld c, a
	ld a, HIGH(ModifyEntityTable)
	adc a, $00
	ld b, a
	ld a, [bc]
	add a, e
	ld e, a
	inc bc
	ld a, [bc]
	adc a, d
	ld d, a ;increment DE with a word from the table
	ld a, [hl+] ;read a byte
	ld [de], a ;save it to our DE address
	inc bc
	ld a, [bc]
	cp $01 ;if third byte from table is 1, return
	ret z
	inc de
	ld a, [hl+]
	ld [de], a ;else save a second byte
	ret

DrakeEntityLogic: ;46CB, logic for Drake and Sugi Tank Three
	push hl
	call NextRand
	and $1F ;1 in 32 chance
	jp nz, .doneShooting
	ld a, l
	add a, $13
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;third mapiterator word
	ld a, [de]
	or a
	jp nz, .doneShooting ;if value nonzero, jump
	add a, $50
	ld e, a
	ld d, $02 ;DE is $0250 + value
	push de
	push hl
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;BC is X, DE is Y
	pop hl
	push hl
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	cpl
	add a, $01
	ldh [$FFCF], a
	ld a, [hl+]
	cpl
	adc a, $00
	ldh [$FFD0], a ;inverted Z to CF/D0
	pop hl
	push hl
	push de
	push bc
	ld de, wQueueNoise
	ld a, $0D ;drake noises
	call CallEntityPlayShootShound
	pop bc
	pop de
	pop hl
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance pointer to Z orientation
	ld a, $20
	ld [wParticleAge], a
	ld a, [hl]
	cpl
	inc a
	pop hl
	call GenerateParticle
.doneShooting ;4729
	pop hl
	ld e, l
	ld d, h ;backup pointer
	ld a, e
	add a, $0C
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;advance poitner to shot at byte
	bit 0, [hl]
	jr z, .doneshot ;if not shot at, skip ahead
	res 0, [hl] ;else reset it
	ld a, e
	add a, $10
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;advance to first mapiterator byte
	ld a, [hl-]
	add a, [hl] ;add with speed change?
	ld [hl], a ;and update speed change
.doneshot ;D
	ld a, e
	add a, $0E
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;speedup byte
	ld a, [hl+]
	ld b, a ;load it into B
	inc hl
	inc hl ;advance to second mapiterator value
	ld a, [hl]
	or a
	jr z, .zerovalue
	dec [hl]
	jr nz, .move
	inc hl
	ld a, [hl]
	add a, b
	ld [hl+], a
	jr .move
.zerovalue ;9
	inc hl
	ld a, [hl]
	ld c, a
	ld a, e
	add a, $07
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;z orientation
	bit 7, b ;check sign of speedup byte
	ld a, [hl]
	jr nz, .turnLeft ;if negative, jump
	add a, $02
	ld [hl], a ;increment orientation by 2
	cp c
	jr z, .equal
	jr .move
.turnLeft ;8
	sub $02
	ld [hl], a
	cp c
	jr nz, .move
.equal ;8
	ld a, e
	add a, $0D
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;speed
	ld a, [hl+]
	inc hl
	inc hl
	inc hl
	ld [hl], a ;write it to second iterator word
.move ;31, 2B, 13, D
	ld a, e
	add a, $0F
	ld l, a
	ld a, d
	adc a, $00
	ld h, a ;first map iterator word byte
	ld a, [hl+]
	ld b, a ;load it into B
	ld c, $00
	ld l, e
	ld h, d
	call CallMoveEntityForward
	ret
	
CleanUpPickupItem: ;479B
	dec hl
	xor a
	ld [hl+], a ;wipe entity
	ld a, [wGameOverTimer]
	or a
	jr nz, .ret
	ld a, [wLevelClearCountdown]
	or a
	jr nz, .ret
	call CallDrawMesonBeam ;used for flair
.ret
	ld a, $09
	ret
	
	
MapObjectsSharedBases: ;47B0, jumped to by the map object lists - the radar bases?
	mapobjEntry $3, $a0, $60
		mapobjSetYPos $fffe
	mapobjEntry $3, $20, $60
		mapobjSetYPos $fffe
	mapobjEntry $3, $e0, $20
		mapobjSetYPos $fffe
	mapobjEntry $3, $60, $20
		mapobjSetYPos $fffe
	mapobjEntry $3, $a0, $e0
		mapobjSetYPos $fffe
	mapobjEntry $3, $20, $e0
		mapobjSetYPos $fffe
	mapobjEntry $3, $e0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $3, $60, $a0
		mapobjSetYPos $fffe
MapObjectsSharedSilo: ;47E0, nuclear silo
	mapobjEntry $3f, $e0, $64
		mapobjSetYPos $7000
		mapobjSetYRot $40
	mapobjEntry $18, $e0, $64
		mapobjSetYPos $fffe
MapObjectsSharedScenery: ;47EF
	mapobjPreciseEntry $54, $9f64, $5d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $a09c, $5d00
		mapobjSetYRot $40
	mapobjPreciseEntry $54, $dd00, $649c
	mapobjPreciseEntry $54, $dd00, $6364
		mapobjSetYRot $80
	mapobjEntry $6, $a0, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $a0, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $48
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $48
		mapobjSetYPos $fffe
	mapobjEntry $30, $c0, $40
		mapobjSetVal1 $1
	mapobjEntry $35, $e0, $78
	mapobjEntry $35, $c8, $60
	mapobjEntry $35, $e0, $48
	mapobjEntry $45, $90, $60
		mapobjSetYPos $ff00
	mapobjEntry $45, $b0, $60
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $40
		mapobjSetYPos $ffa6
	mapobjEntry $6, $e0, $40
		mapobjSetYPos $fffe
	mapobjEntry $35, $f8, $60
	mapobjPreciseEntry $54, $1f64, $5d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $209c, $5d00
		mapobjSetYRot $40
	mapobjEntry $d, $60, $60
	mapobjEntry $6, $30, $60
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $60
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $48
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $48
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $50
		mapobjSetYPos $fffe
	mapobjEntry $30, $40, $40
		mapobjSetVal1 $7
	mapobjEntry $8, $60, $78
	mapobjEntry $8, $78, $60
	mapobjEntry $8, $60, $48
	mapobjEntry $8, $48, $60
	mapobjEntry $45, $20, $70
		mapobjSetYPos $ff00
	mapobjEntry $45, $20, $50
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $40
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $40
		mapobjSetYPos $ffce
	mapobjEntry $1, $0, $40
	mapobjPreciseEntry $54, $df64, $1d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $e09c, $1d00
		mapobjSetYRot $40
	mapobjEntry $d, $a0, $20
	mapobjEntry $6, $b0, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $b0, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $90, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $90, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $8
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $8
		mapobjSetYPos $fffe
	mapobjEntry $8, $a0, $38
	mapobjEntry $8, $b8, $20
	mapobjEntry $8, $a0, $8
	mapobjEntry $8, $87, $20
	mapobjEntry $45, $e0, $30
		mapobjSetYPos $ff00
	mapobjEntry $6, $a0, $14
		mapobjSetYPos $fffe
	mapobjEntry $45, $e0, $0
		mapobjSetYPos $ffce
	mapobjEntry $1, $c0, $0
	mapobjEntry $6, $0, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $0, $2c
		mapobjSetYPos $fffe
	mapobjPreciseEntry $54, $5f64, $1d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $609c, $1d00
		mapobjSetYRot $40
	mapobjEntry $d, $20, $20
	mapobjEntry $6, $30, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $30, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $60, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $60, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $8
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $8
		mapobjSetYPos $fffe
	mapobjEntry $3f, $0, $0
		mapobjSetYPos $7000
		mapobjSetYRot $40
	mapobjEntry $b, $0, $0
		mapobjSetYRot $20
	mapobjEntry $8, $20, $38
	mapobjEntry $8, $38, $20
	mapobjEntry $8, $20, $8
	mapobjEntry $8, $7, $20
	mapobjEntry $45, $50, $20
		mapobjSetYPos $ff00
	mapobjEntry $45, $70, $20
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $0
		mapobjSetYPos $ffce
	mapobjEntry $1, $40, $0
	mapobjPreciseEntry $54, $9f64, $dd00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $a09c, $dd00
		mapobjSetYRot $40
	mapobjEntry $d, $e0, $e0
	mapobjEntry $6, $a0, $f0
		mapobjSetYPos $fffe
	mapobjEntry $6, $a0, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $f0
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $f0
		mapobjSetYPos $fffe
	mapobjEntry $30, $c0, $c0
		mapobjSetVal1 $3
	mapobjEntry $6, $e0, $f4
		mapobjSetYPos $fffe
		mapobjSetYRot $20
	mapobjEntry $8, $e0, $c8
	mapobjEntry $8, $c8, $e0
	mapobjEntry $8, $f8, $e0
	mapobjEntry $45, $b0, $e0
		mapobjSetYPos $ff00
	mapobjEntry $45, $90, $e0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $c0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $e0, $c0
		mapobjSetYPos $ffce
	mapobjPreciseEntry $54, $1f64, $dd00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $209c, $dd00
		mapobjSetYRot $40
	mapobjEntry $d, $60, $e0
	mapobjEntry $6, $30, $e0
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $e0
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $f0
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $f0
		mapobjSetYPos $fffe
	mapobjEntry $30, $40, $c0
		mapobjSetVal1 $5
	mapobjEntry $8, $60, $f8
	mapobjEntry $8, $78, $e0
	mapobjEntry $8, $60, $c8
	mapobjEntry $8, $48, $e0
	mapobjEntry $45, $20, $d0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $c0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $c0
		mapobjSetYPos $ffce
	mapobjEntry $1, $0, $c0
	mapobjPreciseEntry $54, $df64, $9d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $e09c, $9d00
		mapobjSetYRot $40
	mapobjEntry $d, $a0, $a0
	mapobjEntry $6, $b0, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $b0, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $90, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $90, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $b8
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $b8
		mapobjSetYPos $fffe
	mapobjEntry $8, $a0, $b8
	mapobjEntry $8, $b8, $a0
	mapobjEntry $8, $a0, $88
	mapobjEntry $8, $87, $a0
	mapobjEntry $45, $e0, $b0
		mapobjSetYPos $ff00
	mapobjEntry $45, $e0, $90
		mapobjSetYPos $ffd0
	mapobjEntry $6, $a0, $80
		mapobjSetYPos $fffe
	mapobjEntry $45, $e0, $80
		mapobjSetYPos $ffce
	mapobjPreciseEntry $54, $5f64, $9d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $609c, $9d00
		mapobjSetYRot $40
	mapobjEntry $6, $60, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $60, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $b8
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $b8
		mapobjSetYPos $fffe
	mapobjEntry $6, $30, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $30, $90
		mapobjSetYPos $fffe
	mapobjEntry $8, $20, $b8
	mapobjEntry $8, $38, $a0
	mapobjEntry $8, $20, $88
	mapobjEntry $8, $7, $a0
	mapobjEntry $45, $50, $a0
		mapobjSetYPos $ff00
	mapobjEntry $45, $70, $a0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $80
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $80
		mapobjSetYPos $ffce
	mapobjEND

MapObjectsLevel1: ;4BDA, level 1 map objects
	mapobjEntry $4e, $f9, $6b
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $34, $d7, $46
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $f8, $50
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $34, $19, $68
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $4e, $46, $55
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $33, $61, $66
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $50, $38, $60
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $4e, $a7, $12
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $34, $ea, $29
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $b9, $8
		mapobjSetVal1 $fef1
		mapobjSetVal2 $d800
	mapobjEntry $50, $b4, $20
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $34, $19, $27
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $4e, $47, $17
		mapobjSetVal1 $3f6
		mapobjSetVal2 $d300
	mapobjEntry $33, $6a, $29
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $50, $34, $20
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $34, $9a, $d3
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $4e, $bd, $e5
		mapobjSetVal1 $3f6
		mapobjSetVal2 $d300
	mapobjEntry $34, $e5, $d6
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $c8, $d0
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $50, $ad, $e0
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $4e, $65, $e9
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $34, $28, $eb
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $4e, $18, $cc
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $33, $49, $c6
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $50, $2d, $e0
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $3a, $f0, $e0
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $4e, $9b, $aa
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $d300
	mapobjEntry $34, $ba, $92
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $b5, $82
		mapobjSetVal1 $fef1
		mapobjSetVal2 $ce00
	mapobjEntry $50, $ab, $a0
		mapobjSetVal1 $4014
		mapobjSetVal2 $214
		mapobjSetVal4 $f6
	mapobjEntry $3a, $18, $a0
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjRespawn $c, $2000, $a000
	mapobjEntry $4e, $23, $af
		mapobjSetVal1 $5f6
		mapobjSetVal2 $d300
	mapobjEntry $4e, $69, $93
		mapobjSetVal1 $5f6
		mapobjSetVal2 $d300
	mapobjJump MapObjectsSharedBases
	
MapObjectsLevel2: ;4D42
	mapobjEntry $34, $e5, $63
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $58, $65
		mapobjSetVal1 $fef6
		mapobjSetVal2 $1
	mapobjEntry $34, $17, $76
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $54, $59
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $46, $78
		mapobjSetVal1 $fef3
		mapobjSetVal2 $da00
	mapobjEntry $34, $b2, $24
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $4e, $9c, $14
		mapobjSetVal1 $fdf9
		mapobjSetVal2 $e000
	mapobjEntry $34, $eb, $36
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $bd, $a
		mapobjSetVal1 $fef3
		mapobjSetVal2 $da00
	mapobjEntry $34, $63, $23
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $38, $11
		mapobjSetVal1 $fef6
		mapobjSetVal2 $ee00
	mapobjEntry $4e, $1a, $15
		mapobjSetVal1 $fdf9
		mapobjSetVal2 $e000
	mapobjEntry $34, $2b, $5
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $39, $2d
		mapobjSetVal1 $fef3
		mapobjSetVal2 $da00
	mapobjEntry $34, $fb, $fb
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $a5, $d5
		mapobjSetVal1 $fef6
		mapobjSetVal2 $1
	mapobjEntry $34, $cc, $d8
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $d1, $c4
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $ea, $d7
		mapobjSetVal1 $fef3
		mapobjSetVal2 $da00
	mapobjEntry $3a, $60, $e0
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $34, $26, $e9
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
		mapobjSetVal1 $fdf9
		mapobjSetVal2 $e000
	mapobjEntry $34, $41, $d5
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $56, $eb
		mapobjSetVal1 $fef3
		mapobjSetVal2 $da00
	mapobjEntry $34, $c5, $a5
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $9b, $94
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $f1, $92
		mapobjSetVal1 $fef6
		mapobjSetVal2 $ee01
	mapobjEntry $4e, $97, $b9
		mapobjSetVal1 $fdf9
		mapobjSetVal2 $e000
	mapobjEntry $34, $eb, $83
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $d5, $87
		mapobjSetVal1 $fef1
		mapobjSetVal2 $d800
	mapobjEntry $3a, $40, $a0
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $52, $5d, $a5
		mapobjSetVal1 $fef6
		mapobjSetVal2 $1
	mapobjEntry $34, $1c, $a6
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $4c, $8c
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $69, $85
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $33, $28, $ac
		mapobjSetVal1 $fef1
		mapobjSetVal2 $da00
	mapobjRespawn $12, $e400, $6600
	mapobjRespawn $12, $6600, $2500
	mapobjRespawn $12, $f800, $f800
	mapobjRespawn $12, $c000, $b000
	mapobjRespawn $12, $5800, $a800
	mapobjJump MapObjectsSharedBases

MapObjectsLevel3: ;4EB0
	mapobjRespawn $3, $a000, $6000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $2000, $6000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $e000, $2000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $6000, $2000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $a000, $e000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $2000, $e000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $e000, $a000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $6000, $a000
		mapobjSetYPos $fffe
	mapobjEntry $34, $f0, $60
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $c0, $50
		mapobjSetVal1 $fef6
		mapobjSetVal2 $1
	mapobjEntry $52, $50, $70
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $70, $50
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $20, $5f
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $34, $40, $50
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $90, $20
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $c0, $20
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $e0, $21
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $a0, $4
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $a8, $3c
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $52, $c0, $18
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $28, $30
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $18, $10
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $3f, $20
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $61, $20
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjRespawn $2e, $0, $500
		mapobjSetYRot $80
		mapobjSetVal1 $2020
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $2303
	mapobjEntry $34, $68, $8
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $d0, $d0
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $a0, $df
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $c0, $e0
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $52, $f8, $f8
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $60, $f0
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $60, $d0
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $40, $e0
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $21, $e0
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $34, $60, $e0
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $40, $d0
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjRespawn $2e, $1c00, $e000
		mapobjSetYRot $40
		mapobjSetVal1 $d030
		mapobjSetVal2 $c040
		mapobjSetVal3 $b050
		mapobjSetVal4 $2803
	mapobjEntry $52, $90, $90
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $e0, $9e
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $c0, $a1
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $52, $b7, $b6
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $b8, $88
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $50, $60, $a2
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f1
		mapobjSetVal2 $ec00
	mapobjEntry $34, $40, $a0
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $28, $88
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $52, $18, $b8
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjEntry $34, $70, $88
		mapobjSetLogic $2ece
		mapobjSetVal1 $fbfb
		mapobjSetVal2 $1
	mapobjJump MapObjectsSharedSilo

MapObjectsLevel5: ;50B1
	mapobjRespawn $1f, $4000, $6000
		mapobjSetYRot $20
		mapobjSetVal1 $1
	mapobjEntry $54, $41, $62
		mapobjSetYRot $e0
	mapobjEntry $54, $42, $61
		mapobjSetYRot $60
	mapobjEntry $17, $28, $78
		mapobjSetYPos $ffe7
	mapobjEntry $17, $28, $48
		mapobjSetYPos $ffe7
	mapobjEntry $5, $58, $78
	mapobjEntry $33, $20, $68
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjEntry $33, $60, $58
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjRespawn $1f, $c000, $2000
		mapobjSetYRot $e0
		mapobjSetVal1 $2
	mapobjEntry $54, $bf, $22
		mapobjSetYRot $20
	mapobjEntry $54, $be, $21
		mapobjSetYRot $a0
	mapobjEntry $17, $a8, $38
		mapobjSetYPos $ffe7
	mapobjEntry $17, $d8, $8
		mapobjSetYPos $ffe7
	mapobjEntry $5, $a8, $8
	mapobjEntry $33, $a0, $28
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjEntry $33, $e0, $18
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjEntry $17, $40, $20
		mapobjSetYPos $ffe7
	mapobjEntry $17, $40, $3
		mapobjSetYPos $ffe7
	mapobjEntry $17, $28, $20
		mapobjSetYPos $ffe7
	mapobjEntry $17, $68, $38
		mapobjSetYPos $ffe7
	mapobjEntry $17, $18, $38
		mapobjSetYPos $ffe7
	mapobjEntry $17, $18, $8
		mapobjSetYPos $ffe7
	mapobjRespawn $1f, $c000, $e000
		mapobjSetYRot $a0
		mapobjSetVal1 $1
	mapobjEntry $54, $bf, $de
		mapobjSetYRot $60
	mapobjEntry $54, $be, $df
		mapobjSetYRot $e0
	mapobjEntry $5, $a8, $f8
	mapobjEntry $17, $d8, $f8
		mapobjSetYPos $ffe7
	mapobjEntry $17, $a8, $c8
		mapobjSetYPos $ffe7
	mapobjEntry $33, $20, $d8
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjEntry $33, $60, $e8
		mapobjSetVal1 $fdf6
		mapobjSetVal3 $e400
	mapobjEntry $17, $c0, $a0
		mapobjSetYPos $ffe7
	mapobjEntry $17, $c0, $83
		mapobjSetYPos $ffe7
	mapobjEntry $17, $d8, $a0
		mapobjSetYPos $ffe7
	mapobjEntry $17, $98, $b8
		mapobjSetYPos $ffe7
	mapobjEntry $17, $98, $88
		mapobjSetYPos $ffe7
	mapobjEntry $17, $e8, $b8
		mapobjSetYPos $ffe7
	mapobjRespawn $1f, $4000, $a000
		mapobjSetYRot $60
		mapobjSetVal1 $2
	mapobjEntry $54, $42, $9f
		mapobjSetYRot $20
	mapobjEntry $54, $41, $9e
		mapobjSetYRot $a0
	mapobjEntry $17, $28, $b8
		mapobjSetYPos $ffe7
	mapobjEntry $5, $58, $b8
	mapobjEntry $17, $59, $88
		mapobjSetYPos $ffe7
	mapobjEntry $4e, $a0, $e0
		mapobjSetVal1 $fef9
		mapobjSetVal2 $ec00
	mapobjEntry $4e, $27, $f5
		mapobjSetVal1 $fef9
		mapobjSetVal2 $ec00
	mapobjEntry $4e, $40, $c8
		mapobjSetVal1 $fef9
		mapobjSetVal3 $ec00
	mapobjEntry $2, $b0, $90
	mapobjEntry $4e, $10, $a0
		mapobjSetVal1 $fef9
		mapobjSetVal2 $ec00
	mapobjEntry $46, $20, $20
		mapobjSetYPos $7000
	mapobjEntry $46, $e0, $e0
		mapobjSetYPos $7000
	mapobjEntry $3f, $a0, $60
		mapobjSetYPos $7000
		mapobjSetYRot $40
	mapobjEntry $3f, $20, $e0
		mapobjSetYPos $7000
		mapobjSetYRot $40
	mapobjJump MapObjectsSharedBases
	
MapObjectsLevel4: ;5213
	mapobjEntry $5, $0, $60
	mapobjEntry $5, $0, $21
	mapobjEntry $5, $0, $e0
	mapobjEntry $5, $0, $a0
	mapobjEntry $1a, $e0, $50
		mapobjSetVal1 $36
	mapobjEntry $1a, $68, $68
		mapobjSetVal1 $36
	mapobjEntry $1a, $60, $8
		mapobjSetVal1 $52
	mapobjEntry $1a, $23, $20
		mapobjSetVal1 $11
	mapobjEntry $1a, $58, $b8
		mapobjSetVal1 $36
	mapobjEntry $1a, $1f, $9f
		mapobjSetVal1 $36
	mapobjEntry $1a, $f0, $28
		mapobjSetVal1 $36
	mapobjEntry $1a, $40, $47
		mapobjSetVal1 $36
	mapobjEntry $1a, $a0, $18
		mapobjSetVal1 $36
	mapobjEntry $1a, $e8, $e8
		mapobjSetVal1 $52
	mapobjEntry $1a, $d8, $d8
		mapobjSetVal1 $36
	mapobjEntry $1a, $40, $d0
		mapobjSetVal1 $40
	mapobjEntry $1a, $60, $ec
		mapobjSetVal1 $36
	mapobjEntry $1a, $fd, $bd
		mapobjSetVal1 $36
	mapobjEntry $1a, $a0, $a3
		mapobjSetVal1 $11
	mapobjEntry $1a, $a8, $98
		mapobjSetVal1 $36
	mapobjEntry $17, $c0, $60
		mapobjSetYPos $ffe7
	mapobjEntry $33, $f4, $40
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $e400
	mapobjEntry $50, $e1, $0
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f6
		mapobjSetVal2 $ec00
	mapobjEntry $17, $40, $60
		mapobjSetYPos $ffe7
	mapobjEntry $4e, $68, $67
		mapobjSetVal1 $fef9
		mapobjSetVal2 $ec00
	mapobjEntry $17, $c0, $20
		mapobjSetYPos $ffe7
	mapobjEntry $33, $f2, $0
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $e400
	mapobjEntry $50, $a0, $17
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f6
		mapobjSetVal2 $ec00
	mapobjEntry $17, $40, $20
		mapobjSetYPos $ffe7
	mapobjEntry $4e, $1f, $1f
		mapobjSetVal1 $fef9
		mapobjSetVal2 $ec00
	mapobjEntry $17, $c0, $e0
		mapobjSetYPos $ffe7
	mapobjEntry $33, $d9, $d8
		mapobjSetVal1 $fdf6
		mapobjSetVal2 $e400
	mapobjEntry $50, $f4, $c0
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f6
		mapobjSetVal2 $ec00
	mapobjEntry $17, $40, $e0
		mapobjSetYPos $ffe7
	mapobjEntry $4e, $60, $eb
		mapobjSetVal1 $fef9
		mapobjSetVal3 $ee00
	mapobjEntry $17, $c0, $a0
		mapobjSetYPos $ffe7
	mapobjEntry $50, $a8, $97
		mapobjSetLogic $2ece
		mapobjSetVal1 $2f6
		mapobjSetVal2 $ec00
	mapobjEntry $33, $f6, $80
		mapobjSetVal1 $fdf9
		mapobjSetVal2 $e400
	mapobjEntry $17, $40, $a0
		mapobjSetYPos $ffe7
	mapobjEntry $4e, $11, $b1
		mapobjSetVal1 $2f9
		mapobjSetVal2 $ec00
	mapobjJump MapObjectsSharedBases
	
MapObjectsLevel6: ;532A
	mapobjEntry $4e, $90, $62
		mapobjSetVal1 $2fb
		mapobjSetVal2 $ec01
	mapobjEntry $4e, $a0, $5c
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ec01
	mapobjEntry $1d, $fb, $5c
	mapobjEntry $3b, $fa, $5c
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $d3, $6a
	mapobjEntry $3b, $d2, $6a
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $99, $4f
	mapobjEntry $3b, $9c, $4c
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3b, $d9, $54
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3a, $d7, $54
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $1d, $cc, $44
	mapobjEntry $3b, $cf, $46
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3b, $28, $69
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $27, $67
	mapobjEntry $3a, $4a, $7a
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $4d, $68, $68
		mapobjSetVal2 $ec01
	mapobjEntry $3b, $61, $50
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $13, $4b
	mapobjEntry $3b, $16, $4e
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $33, $58, $78
		mapobjSetVal1 $fef9
		mapobjSetVal2 $e401
	mapobjEntry $33, $7d, $78
		mapobjSetVal1 $fef9
		mapobjSetVal2 $e401
	mapobjEntry $3b, $95, $23
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3a, $c0, $10
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $1d, $54, $6
	mapobjEntry $3b, $2, $10
		mapobjSetYRot $80
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3b, $39, $12
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $36, $3d
	mapobjEntry $3b, $33, $3a
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $33, $2c
	mapobjEntry $3b, $36, $2f
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $17, $17
	mapobjEntry $3b, $15, $15
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3b, $69, $33
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3a, $6f, $4
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $1d, $4c, $25
	mapobjEntry $3b, $4f, $28
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $dc, $cb
	mapobjEntry $3b, $da, $cf
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $3a, $b1, $ec
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $3b, $13, $e4
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $3d, $e6
	mapobjEntry $3b, $38, $e8
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $5c, $f8
	mapobjEntry $3b, $58, $f6
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $1d, $8d, $98
	mapobjEntry $43, $20, $20
		mapobjSetYPos $7000
	mapobjEntry $43, $e0, $e0
		mapobjSetYPos $7000
	mapobjRespawn $27, $2400, $e600
	mapobjRespawn $27, $1f00, $e300
	mapobjRespawn $27, $1b00, $e900
	mapobjRespawn $27, $1e00, $df00
	mapobjJump MapObjectsSharedBases

MapObjectsLevel7: ;54AA
	mapobjRespawn $7, $a000, $5b00
		mapobjSetYPos $ff44
	mapobjRespawn $7, $1800, $ad00
		mapobjSetYPos $ff50
	mapobjRespawn $7, $4000, $2000
		mapobjSetYPos $ff4c
	mapobjRespawn $7, $c000, $e000
		mapobjSetYPos $ff5a
	mapobjEntry $a, $40, $50
	mapobjEntry $3a, $3c, $48
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $4e, $67, $4c
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $4e, $27, $52
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $5a, $66
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $a, $c0, $10
	mapobjEntry $3a, $bc, $8
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $47, $94, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $323
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $4e, $e9, $28
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $a3, $25
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $250
		mapobjSetVal4 $f6
	mapobjEntry $34, $d8, $13
		mapobjSetYPos $ff6a
	mapobjEntry $4e, $16, $1c
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $47, $67, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $320
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $34, $38, $2f
		mapobjSetYPos $ff6a
	mapobjEntry $4e, $48, $2f
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $58, $9
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $47, $9b, $cc
		mapobjSetYPos $ff38
		mapobjSetVal1 $337
		mapobjSetVal2 $1e00
		mapobjSetVal3 $ff
	mapobjEntry $4e, $e6, $e5
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $a6, $eb
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $d4, $d4
		mapobjSetYPos $ff6a
	mapobjEntry $4e, $f4, $d4
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $a, $40, $d0
	mapobjEntry $3a, $3c, $c8
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $4e, $27, $d2
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $19, $f7
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $65, $d4
		mapobjSetYPos $ff6a
	mapobjEntry $a, $c0, $90
	mapobjEntry $3a, $bc, $88
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $47, $aa, $a9
		mapobjSetYPos $ff6a
		mapobjSetVal1 $325
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $47, $da, $8a
		mapobjSetYPos $ff6a
		mapobjSetVal1 $328
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $4e, $99, $97
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $dd, $a8
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $59, $ab
		mapobjSetYPos $ff38
	mapobjEntry $4e, $1a, $a0
		mapobjSetVal1 $fd00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $56, $9d
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjJump MapObjectsSharedBases
	
MapObjectsLevel8: ;565A
	mapobjRespawn $3, $a000, $6000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $2000, $6000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $e000, $2000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $6000, $2000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $a000, $e000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $2000, $e000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $e000, $a000
		mapobjSetYPos $fffe
	mapobjRespawn $3, $6000, $a000
		mapobjSetYPos $fffe
	mapobjEntry $4d, $ac, $68
	mapobjEntry $2d, $f7, $77
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $2d, $e9, $56
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $34, $27, $52
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ee01
	mapobjEntry $49, $5a, $66
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4032
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjRespawn $38, $2800, $5800
	mapobjEntry $4d, $28, $57
		mapobjSetVal2 $ec01
	mapobjEntry $2d, $5a, $6c
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $a, $c0, $10
	mapobjEntry $3a, $bc, $8
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $47, $94, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $334
		mapobjSetVal2 $1e00
		mapobjSetVal3 $fa
	mapobjEntry $49, $a3, $25
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4050
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $d8, $13
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ee01
	mapobjRespawn $38, $a000, $500
	mapobjEntry $2d, $d2, $15
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $2d, $f5, $2d
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $47, $67, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $32d
		mapobjSetVal2 $1e00
		mapobjSetVal3 $fa
	mapobjEntry $34, $38, $2f
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ee01
	mapobjEntry $49, $58, $9
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $4d, $0, $3
		mapobjSetVal2 $ec01
	mapobjEntry $2d, $4c, $27
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $34, $a6, $eb
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ec01
	mapobjEntry $49, $d4, $d4
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4032
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $2d, $ae, $e9
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $3a, $3c, $c8
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $a, $40, $d0
	mapobjEntry $49, $19, $f7
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $65, $d4
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ec01
	mapobjRespawn $38, $0, $e000
	mapobjEntry $2d, $cd, $a6
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $a, $c0, $90
	mapobjEntry $3a, $bc, $88
		mapobjSetLogic $1a7f
		mapobjSetVal1 $4014
		mapobjSetVal2 $f14
		mapobjSetVal4 $f6
	mapobjEntry $4e, $99, $97
		mapobjSetVal1 $fefd
		mapobjSetVal2 $ec00
	mapobjEntry $49, $dd, $a8
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjRespawn $38, $d000, $9800
	mapobjEntry $2d, $5f, $a9
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $2d, $60, $8b
		mapobjSetVal1 $fd0a
		mapobjSetVal2 $1
	mapobjEntry $47, $59, $ab
		mapobjSetYPos $ff38
		mapobjSetVal1 $31e
		mapobjSetVal2 $1e00
		mapobjSetVal3 $fa
	mapobjEntry $34, $1a, $a0
		mapobjSetLogic $2ece
		mapobjSetVal1 $fefb
		mapobjSetVal2 $ec01
	mapobjEntry $49, $56, $9d
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $405a
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjRespawn $38, $7000, $9800
	mapobjJump MapObjectsSharedSilo
	
MapObjectsLevel9: ;585E
	mapobjEntry $3, $a0, $60
		mapobjSetYPos $fffe
	mapobjEntry $3, $20, $60
		mapobjSetYPos $fffe
	mapobjEntry $3, $e0, $20
		mapobjSetYPos $fffe
	mapobjEntry $3, $60, $20
		mapobjSetYPos $fffe
	mapobjEntry $3, $a0, $e0
		mapobjSetYPos $fffe
	mapobjEntry $3, $20, $e0
		mapobjSetYPos $fffe
	mapobjEntry $3, $e0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $3, $60, $a0
		mapobjSetYPos $fffe
	mapobjEntry $47, $1b, $74
		mapobjSetYPos $ff38
		mapobjSetVal1 $328
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $4e, $27, $52
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $5a, $66
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $34, $94, $9
		mapobjSetVal1 $5
		mapobjSetVal2 $1
	mapobjEntry $47, $94, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $335
		mapobjSetVal2 $1e00
		mapobjSetVal3 $ff
	mapobjEntry $4e, $a3, $25
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $47, $67, $9
		mapobjSetYPos $ff38
		mapobjSetVal1 $326
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $4e, $38, $2f
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $58, $9
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $47, $9b, $cc
		mapobjSetYPos $ff38
		mapobjSetVal1 $32a
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $34, $9b, $cc
		mapobjSetVal1 $5
		mapobjSetVal2 $1
	mapobjEntry $4e, $a6, $eb
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $d4, $d4
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4046
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $47, $27, $d2
		mapobjSetYPos $ff38
		mapobjSetVal1 $334
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $49, $19, $f7
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $403c
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $4e, $65, $d4
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $47, $da, $8a
		mapobjSetYPos $ff6a
		mapobjSetVal1 $330
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $34, $da, $8a
		mapobjSetVal1 $5
		mapobjSetVal2 $1
	mapobjEntry $4e, $99, $97
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjEntry $49, $dd, $a8
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4046
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $47, $59, $ab
		mapobjSetYPos $ff38
		mapobjSetVal1 $337
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $34, $59, $ab
		mapobjSetVal1 $5
		mapobjSetVal2 $1
	mapobjEntry $49, $1a, $a0
		mapobjSetYPos $ff6a
		mapobjSetLogic $7f1d
		mapobjSetVal1 $4032
		mapobjSetVal2 $232
		mapobjSetVal4 $f6
	mapobjEntry $4e, $56, $9d
		mapobjSetVal1 $fb00
		mapobjSetVal2 $ec00
	mapobjRespawn $18, $e000, $6400
	mapobjRespawn $20, $df9c, $1900
		mapobjSetYPos $ff6b
		mapobjSetVal1 $6fdf
		mapobjSetVal2 $da0c
		mapobjSetVal3 $1d90
		mapobjSetVal4 $4520
	mapobjRespawn $20, $e000, $1900
		mapobjSetYPos $ff6d
		mapobjSetVal1 $70e0
		mapobjSetVal2 $d80c
		mapobjSetVal3 $1c90
		mapobjSetVal4 $4420
	mapobjRespawn $20, $e064, $1900
		mapobjSetYPos $ff6b
		mapobjSetVal1 $70e1
		mapobjSetVal2 $d60c
		mapobjSetVal3 $1b90
		mapobjSetVal4 $4320
	mapobjEntry $6, $e, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $de, $80
		mapobjSetYPos $fffe
		mapobjSetYRot $20
	mapobjEntry $6, $fa, $b0
		mapobjSetYPos $fffe
		mapobjSetYRot $20
	mapobjEntry $6, $40, $34
		mapobjSetYPos $fffe
		mapobjSetYRot $20
	mapobjEntry $6, $e0, $2d
	mapobjEntry $34, $e1, $1a
		mapobjSetYRot $80
		mapobjSetVal1 $fb05
		mapobjSetVal2 $1
	mapobjEntry $34, $df, $1b
		mapobjSetYRot $80
		mapobjSetVal1 $fb05
		mapobjSetVal2 $1
	mapobjJump MapObjectsSharedScenery

MapObjectsLevel10: ;5A4A
	mapobjRespawn $3, $a000, $6000
		mapobjSetYPos $fffe
	mapobjRespawn $2e, $9d00, $6000
		mapobjSetYRot $40
		mapobjSetVal1 $60b0
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $4603
	mapobjRespawn $3, $2000, $6000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $13, $60
		mapobjSetYRot $40
		mapobjSetVal1 $6030
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $34, $21, $60
		mapobjSetVal1 $0
		mapobjSetVal2 $1
	mapobjRespawn $3, $e000, $2000
		mapobjSetYPos $fffe
	mapobjEntry $33, $e1, $20
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjRespawn $3, $6000, $2000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $53, $20
		mapobjSetYRot $40
		mapobjSetVal1 $2070
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $33, $61, $20
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjRespawn $3, $a000, $e000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $93, $e0
		mapobjSetYRot $40
		mapobjSetVal1 $e0ab
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $33, $a1, $e0
		mapobjSetVal1 $5
		mapobjSetVal2 $1
	mapobjRespawn $3, $2000, $e000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $13, $e0
		mapobjSetYRot $40
		mapobjSetVal1 $e030
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $33, $21, $f0
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjRespawn $3, $e000, $a000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $d3, $60
		mapobjSetYRot $40
		mapobjSetVal1 $a0f0
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $34, $e1, $a0
		mapobjSetVal1 $0
		mapobjSetVal2 $1
	mapobjRespawn $3, $6000, $a000
		mapobjSetYPos $fffe
	mapobjEntry $2e, $53, $60
		mapobjSetYRot $40
		mapobjSetVal1 $a070
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1903
	mapobjEntry $34, $61, $a0
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $34, $db, $54
	mapobjEntry $2, $40, $60
		mapobjSetVal2 $ec01
	mapobjEntry $47, $32, $6a
		mapobjSetVal1 $328
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjRespawn $4b, $8100, $0
	mapobjEntry $5, $95, $0
	mapobjEntry $5, $80, $15
	mapobjEntry $17, $98, $10
		mapobjSetYPos $ffe7
	mapobjEntry $17, $90, $28
		mapobjSetYPos $ffe7
	mapobjEntry $2, $c0, $20
		mapobjSetVal2 $ec01
	mapobjEntry $5, $6c, $0
	mapobjEntry $17, $70, $18
		mapobjSetYPos $ffe7
	mapobjEntry $17, $70, $28
		mapobjSetYPos $ffe7
	mapobjEntry $33, $58, $29
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $5, $80, $ec
	mapobjEntry $17, $98, $f0
		mapobjSetYPos $ffe7
	mapobjEntry $17, $90, $d8
		mapobjSetYPos $ffe7
	mapobjRespawn $44, $f500, $f400
	mapobjEntry $2, $c0, $e0
		mapobjSetVal2 $ec01
	mapobjEntry $33, $dc, $d5
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjEntry $17, $70, $e8
		mapobjSetYPos $ffe7
	mapobjEntry $17, $58, $f0
		mapobjSetYPos $ffe7
	mapobjEntry $47, $a8, $ab
		mapobjSetVal1 $328
		mapobjSetVal2 $3200
		mapobjSetVal3 $ff
	mapobjEntry $2, $40, $a0
		mapobjSetVal2 $ec01
	mapobjEntry $33, $29, $99
		mapobjSetVal1 $fb
		mapobjSetVal2 $1
	mapobjRespawn $18, $e000, $6400
	mapobjPreciseEntry $54, $9f64, $5d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $a09c, $5d00
		mapobjSetYRot $40
	mapobjPreciseEntry $54, $dd00, $649c
	mapobjPreciseEntry $54, $dd00, $6364
		mapobjSetYRot $80
	mapobjEntry $6, $a0, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $50
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $48
		mapobjSetYPos $fffe
	mapobjRespawn $30, $c000, $4000
		mapobjSetHP $1
	mapobjEntry $9, $c0, $40
		mapobjSetYPos $7f00
	mapobjEntry $35, $e0, $78
	mapobjEntry $35, $c8, $60
	mapobjEntry $35, $e0, $48
	mapobjEntry $45, $b0, $60
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $40
		mapobjSetYPos $ffa6
	mapobjEntry $45, $e0, $40
		mapobjSetYPos $ffce
	mapobjEntry $35, $f8, $60
	mapobjPreciseEntry $54, $1f64, $5d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $209c, $5d00
		mapobjSetYRot $40
	mapobjEntry $8, $60, $60
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $60
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $78
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $48
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $70
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $50
		mapobjSetYPos $fffe
	mapobjRespawn $30, $4000, $4000
		mapobjSetHP $1
	mapobjEntry $9, $40, $40
		mapobjSetYPos $7f00
	mapobjEntry $8, $60, $78
	mapobjEntry $8, $78, $60
	mapobjEntry $8, $60, $48
	mapobjEntry $8, $48, $60
	mapobjEntry $45, $20, $50
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $40
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $40
		mapobjSetYPos $ffce
	mapobjEntry $1, $0, $40
	mapobjPreciseEntry $54, $df64, $1d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $e09c, $1d00
		mapobjSetYRot $40
	mapobjEntry $8, $a0, $20
	mapobjEntry $6, $90, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $8
		mapobjSetYPos $fffe
	mapobjEntry $8, $a0, $38
	mapobjEntry $8, $b8, $20
	mapobjEntry $8, $a0, $8
	mapobjEntry $8, $87, $20
	mapobjEntry $45, $e0, $10
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $e0, $0
		mapobjSetYPos $ffce
	mapobjEntry $1, $c0, $0
	mapobjPreciseEntry $54, $5f64, $1d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $609c, $1d00
		mapobjSetYRot $40
	mapobjEntry $8, $20, $20
	mapobjEntry $6, $30, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $60, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $60, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $38
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $8
		mapobjSetYPos $fffe
	mapobjRespawn $b, $0, $0
		mapobjSetYRot $20
	mapobjEntry $2e, $fb, $0
		mapobjSetYRot $40
		mapobjSetVal1 $10
		mapobjSetVal2 $3050
		mapobjSetVal3 $6060
		mapobjSetVal4 $1b0b
	mapobjEntry $8, $20, $38
	mapobjEntry $8, $38, $20
	mapobjEntry $8, $20, $8
	mapobjEntry $8, $7, $20
	mapobjEntry $45, $50, $20
		mapobjSetYPos $ff00
	mapobjEntry $45, $70, $20
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $0
		mapobjSetYPos $ffce
	mapobjEntry $1, $40, $0
	mapobjPreciseEntry $54, $9f64, $dd00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $a09c, $dd00
		mapobjSetYRot $40
	mapobjEntry $8, $e0, $e0
	mapobjEntry $6, $a0, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $b8, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $87, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $d0
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $f0
		mapobjSetYPos $fffe
	mapobjRespawn $30, $c000, $c000
		mapobjSetHP $1
	mapobjEntry $9, $c0, $c0
		mapobjSetYPos $7f00
	mapobjEntry $8, $e0, $f8
	mapobjEntry $8, $e0, $c8
	mapobjEntry $8, $c8, $e0
	mapobjEntry $8, $f8, $e0
	mapobjEntry $45, $90, $e0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $c0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $e0, $c0
		mapobjSetYPos $ffce
	mapobjPreciseEntry $54, $1f64, $dd00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $209c, $dd00
		mapobjSetYRot $40
	mapobjEntry $8, $60, $e0
	mapobjEntry $6, $10, $e0
		mapobjSetYPos $fffe
	mapobjEntry $6, $38, $c8
		mapobjSetYPos $fffe
	mapobjEntry $6, $7, $f8
		mapobjSetYPos $fffe
	mapobjEntry $6, $70, $f0
		mapobjSetYPos $fffe
	mapobjEntry $6, $50, $d0
		mapobjSetYPos $fffe
	mapobjRespawn $30, $4000, $c000
		mapobjSetHP $1
	mapobjEntry $9, $40, $c0
		mapobjSetYPos $7f00
	mapobjEntry $8, $60, $f8
	mapobjEntry $8, $78, $e0
	mapobjEntry $8, $60, $c8
	mapobjEntry $8, $48, $e0
	mapobjEntry $45, $20, $d0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $c0
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $c0
		mapobjSetYPos $ffce
	mapobjEntry $1, $0, $c0
	mapobjPreciseEntry $54, $df64, $9d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $e09c, $9d00
		mapobjSetYRot $40
	mapobjEntry $8, $a0, $a0
	mapobjEntry $6, $90, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $f0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $6, $d0, $a0
		mapobjSetYPos $fffe
	mapobjEntry $6, $f8, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $c8, $b8
		mapobjSetYPos $fffe
	mapobjEntry $8, $a0, $b8
	mapobjEntry $8, $b8, $a0
	mapobjEntry $8, $a0, $88
	mapobjEntry $8, $87, $a0
	mapobjEntry $45, $e0, $90
		mapobjSetYPos $ffd0
	mapobjEntry $45, $a0, $80
		mapobjSetYPos $ffa6
	mapobjEntry $45, $e0, $80
		mapobjSetYPos $ffce
	mapobjPreciseEntry $54, $5f64, $9d00
		mapobjSetYRot $c0
	mapobjPreciseEntry $54, $609c, $9d00
		mapobjSetYRot $40
	mapobjEntry $6, $60, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $78, $b8
		mapobjSetYPos $fffe
	mapobjEntry $6, $48, $88
		mapobjSetYPos $fffe
	mapobjEntry $6, $10, $b0
		mapobjSetYPos $fffe
	mapobjEntry $6, $30, $90
		mapobjSetYPos $fffe
	mapobjEntry $8, $20, $b8
	mapobjEntry $8, $38, $a0
	mapobjEntry $8, $20, $88
	mapobjEntry $8, $7, $a0
	mapobjEntry $45, $70, $a0
		mapobjSetYPos $ffd0
	mapobjEntry $45, $20, $80
		mapobjSetYPos $ffa6
	mapobjEntry $45, $60, $80
		mapobjSetYPos $ffce
	mapobjEND

MapObjectsLevelTut: ;5EF2
	mapobjEntry $6, $a5, $40
		mapobjSetYPos $fffe
	mapobjEntry $d, $9f, $60
	mapobjEntry $d, $a1, $60
	mapobjEntry $d, $b0, $5b
	mapobjEntry $d, $b0, $59
	mapobjEntry $d, $90, $5b
	mapobjEntry $d, $90, $59
	mapobjEntry $35, $a0, $50
	mapobjEntry $35, $9c, $4a
	mapobjEntry $35, $a4, $4a
	mapobjEntry $35, $9f, $68
	mapobjEntry $35, $a1, $68
	mapobjEntry $35, $9e, $70
	mapobjEntry $35, $a2, $70
	mapobjEntry $35, $c5, $76
	mapobjEntry $35, $d8, $66
	mapobjEntry $35, $c6, $56
	mapobjEntry $35, $d9, $48
	mapobjEntry $35, $ea, $52
	mapobjEntry $35, $e8, $65
	mapobjEntry $35, $e7, $74
	mapobjEntry $35, $f6, $71
	mapobjEntry $35, $fb, $57
	mapobjEntry $35, $fb, $42
	mapobjEntry $35, $87, $45
	mapobjEntry $35, $86, $68
	mapobjEntry $35, $82, $54
	mapobjEntry $35, $93, $73
	mapobjEntry $35, $85, $7c
	mapobjEntry $d, $a0, $78
	mapobjEntry $d, $c1, $66
	mapobjEntry $d, $d9, $77
	mapobjEntry $d, $e4, $57
	mapobjEntry $d, $c7, $44
	mapobjEntry $d, $c6, $67
	mapobjEntry $d, $c7, $54
	mapobjEntry $d, $b7, $7c
	mapobjEntry $d, $bc, $74
	mapobjEntry $d, $f2, $73
	mapobjEntry $d, $ea, $4e
	mapobjEntry $d, $b9, $4b
	mapobjEntry $d, $b6, $6f
	mapobjEntry $30, $40, $40
		mapobjSetVal1 $9
	mapobjEntry $35, $10, $70
	mapobjEntry $35, $30, $70
	mapobjEntry $35, $10, $50
	mapobjEntry $35, $30, $50
	mapobjEntry $35, $50, $70
	mapobjEntry $35, $70, $70
	mapobjEntry $35, $70, $50
	mapobjEntry $35, $50, $50
	mapobjEntry $d, $60, $60
	mapobjEntry $d, $20, $60
	mapobjEntry $d, $40, $78
	mapobjEntry $6, $a5, $30
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $20
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $10
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $0
		mapobjSetYPos $fffe
	mapobjPreciseEntry $54, $ff80, $d00
		mapobjSetYRot $c0
	mapobjEntry $d, $8b, $37
	mapobjEntry $d, $c0, $39
	mapobjEntry $d, $bb, $22
	mapobjEntry $d, $d0, $2a
	mapobjEntry $d, $d1, $f
	mapobjEntry $d, $c0, $8
	mapobjEntry $d, $b5, $15
	mapobjEntry $6, $b3, $27
	mapobjEntry $6, $c4, $28
	mapobjEntry $6, $8c, $2d
	mapobjEntry $6, $8c, $15
	mapobjEntry $6, $96, $4
	mapobjEntry $6, $87, $5
	mapobjEntry $6, $c9, $2
	mapobjEntry $6, $cc, $3c
	mapobjEntry $6, $ac, $3d
	mapobjEntry $35, $b8, $3c
	mapobjEntry $35, $b1, $2f
	mapobjEntry $35, $c3, $1c
	mapobjEntry $35, $db, $27
	mapobjEntry $35, $86, $1f
	mapobjEntry $35, $99, $2b
	mapobjEntry $35, $9b, $3c
	mapobjEntry $35, $99, $16
	mapobjEntry $35, $b7, $3
	mapobjEntry $35, $d8, $18
	mapobjEntry $35, $cc, $10
	mapobjEntry $3, $0, $10
	mapobjPreciseEntry $54, $80, $d00
		mapobjSetYRot $40
	mapobjEntry $d, $70, $10
	mapobjEntry $35, $40, $8
	mapobjEntry $35, $60, $20
	mapobjEntry $d, $70, $30
	mapobjEntry $6, $a5, $c0
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $d0
		mapobjSetYPos $fffe
	mapobjEntry $35, $8b, $f1
	mapobjEntry $35, $ad, $f7
	mapobjEntry $35, $a1, $e2
	mapobjEntry $35, $86, $d4
	mapobjEntry $35, $d2, $dd
	mapobjEntry $35, $c1, $c1
	mapobjEntry $35, $c4, $ee
	mapobjEntry $35, $ea, $de
	mapobjEntry $35, $e5, $c1
	mapobjEntry $35, $d8, $ce
	mapobjEntry $35, $fb, $cc
	mapobjEntry $35, $c6, $fb
	mapobjEntry $35, $c1, $d3
	mapobjEntry $35, $91, $c6
	mapobjEntry $d, $9e, $f9
	mapobjEntry $d, $85, $e4
	mapobjEntry $d, $87, $ca
	mapobjEntry $d, $bd, $df
	mapobjEntry $d, $b0, $dc
	mapobjEntry $d, $d2, $c7
	mapobjEntry $d, $d2, $e8
	mapobjEntry $d, $d9, $fb
	mapobjEntry $d, $b7, $ee
	mapobjEntry $d, $a5, $ed
	mapobjEntry $d, $98, $d8
	mapobjEntry $d, $94, $e9
	mapobjEntry $d, $97, $cb
	mapobjEntry $d, $b9, $cb
	mapobjEntry $d, $e1, $e6
	mapobjEntry $d, $dd, $d7
	mapobjEntry $35, $30, $f0
	mapobjEntry $35, $30, $d0
	mapobjEntry $35, $10, $d0
	mapobjEntry $35, $50, $f0
	mapobjEntry $35, $70, $f0
	mapobjEntry $35, $70, $d0
	mapobjEntry $35, $50, $d0
	mapobjEntry $d, $20, $e0
	mapobjEntry $d, $60, $e0
	mapobjEntry $6, $a5, $80
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $90
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $a0
		mapobjSetYPos $fffe
	mapobjEntry $6, $a5, $b0
		mapobjSetYPos $fffe
	mapobjEntry $d, $9d, $ba
	mapobjEntry $d, $88, $a8
	mapobjEntry $d, $8d, $99
	mapobjEntry $d, $9c, $a5
	mapobjEntry $d, $87, $89
	mapobjEntry $d, $97, $87
	mapobjEntry $d, $b9, $99
	mapobjEntry $d, $bd, $b1
	mapobjEntry $d, $cd, $b8
	mapobjEntry $d, $da, $9e
	mapobjEntry $d, $cb, $8b
	mapobjEntry $d, $cd, $a6
	mapobjEntry $d, $ec, $89
	mapobjEntry $d, $de, $87
	mapobjEntry $d, $e9, $ae
	mapobjEntry $d, $bd, $86
	mapobjEntry $35, $93, $b9
	mapobjEntry $35, $96, $a5
	mapobjEntry $35, $95, $98
	mapobjEntry $35, $89, $89
	mapobjEntry $35, $cb, $95
	mapobjEntry $35, $be, $a7
	mapobjEntry $35, $c4, $af
	mapobjEntry $35, $d1, $b7
	mapobjEntry $35, $df, $a6
	mapobjEntry $35, $e7, $bd
	mapobjEntry $35, $d1, $8c
	mapobjEntry $35, $c4, $81
	mapobjEntry $35, $b9, $8c
	mapobjEntry $35, $b2, $84
	mapobjEntry $35, $ad, $ba
	mapobjEntry $35, $b2, $b6
	mapobjEntry $35, $af, $ae
	mapobjEntry $35, $af, $89
	mapobjEntry $35, $ad, $9a
	mapobjEntry $35, $86, $b9
	mapobjEntry $35, $82, $b8
	mapobjEntry $35, $87, $9c
	mapobjEntry $35, $c0, $be
	mapobjEntry $6, $c8, $a1
	mapobjEntry $6, $b3, $a7
	mapobjEntry $6, $93, $ac
	mapobjEntry $6, $8a, $93
	mapobjEntry $6, $9a, $9c
	mapobjEntry $6, $c4, $99
	mapobjEntry $d, $10, $b0
	mapobjEntry $d, $f, $8f
	mapobjEntry $d, $30, $b0
	mapobjEntry $d, $30, $90
	mapobjEntry $d, $50, $b0
	mapobjEntry $d, $70, $b0
	mapobjEntry $d, $70, $90
	mapobjEntry $d, $50, $90
	mapobjEntry $35, $20, $a0
	mapobjEntry $35, $60, $a0
	mapobjEND


DrawMinimap: ;6163
	ldh a, [hGameState]
	dec a
	jr nz, .notplanet ;if not 1, jump ahead
	ld a, [$C2A1]
	cpl
	and $03 ;if planet, return if C2A1 isn't 3
	ret nz
.notplanet
	push hl ;our map bg address
	ldh a, [hGameState]
	cp $02
	jr z, .skeep ;if tunnel? jump ahead
	ldh a, [hXPosHi] ;else
	add a, $80
	rlca
	rlca
	and $03
	ld c, a
	ldh a, [hYPosHi]
	cpl
	add a, $81
	swap a
	and $0C
	add a, c ;a has XY coord packed in two bits each
	ld c, a ;load it into c, then call
	call MaskXYBitpairs
.skeep
	pop hl
	ld d, $10
	ld a, [$C2E9]
	or a
	jr z, .skipdec
	dec a
	ld [$C2E9], a ;decrement C2E9 if not already zero
	ld a, [$C2EA] ;use $10 in D if it is, C2EA if it's not
	ld d, a ;$10 means player's not on the map ($F cells)
.skipdec
	xor a
	call DrawMinimapRow
	call DrawMinimapRow
	call DrawMinimapRow
	call DrawMinimapRow
	;now draw the tank's position
	ld hl, wMapTankCellPos
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, [$C2A1] ;animation frame
	and $07
	cp $04
	jp nc, .bottomjump ;first four frames, skip
	ldh a, [hXPosHi]
	add a, $80
	swap a
	and $03 ;high nybble, masked to 0-3
	rlca ;multiplied by two, the dot's only drawn at even pixels
	ld d, $00
	ld e, a ;e is now the resulting 0-6 even
	ld a, [de] ;grab from toprom table
	ld e, a ;e now has bit a set
	sra a
	or e
	ld e, a ;e is now a pair of masked bits
	ldh a, [hYPosHi]
	add a, $80
	cpl
	inc a
	swap a
	and $03
	rlca ;ypos is similarly masked to 0-6 evens
	add a, LOW(wMapTankCellPos)
	ld l, a
	ld a, HIGH(wMapTankCellPos)
	adc a, $00
	ld h, a
	ld a, [hl] ;D058 + ypos
	or e
	ld [hl+], a ;write our masked pair here
	ld a, [hl]
	or e
	ld [hl], a ;and in the following byte too
.bottomjump
	ld de, wMapTankCellPos
	ld hl, $8910 ;the the tank pip tile
	ld b, $04
.bottomloop
	inc l
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [de]
	ld [hl+], a
	inc de
	inc l
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jp nz, .bottomloop
	ret
	
DrawMinimapRow: ;6207
	;passed c is what cell the player is in, a is the next cell to draw
	ld b, $04 ;loops, what column we're in
.loop ;6209
	push af
	ld a, b
	and $01
	xor $01
	jp z, .oddB ;if bit one of B set, skip
	ld a, $03
.oddB
	ldh [$FF90], a ;we're storing either 0 or 3 to this
	pop af
	push af ;restore our passed a (starts as zero)
	cp c ;compare to (passed) c
	jr z, .equalsc
	cp d ;compare to (passed) d
	jr z, .equalsd
	jr .unequal
.equalsd
	ld a, [$C2E9]
	and $01
	jr nz, .C2E9not1
	jr .equalscend
.equalsc
	ldh a, [rSTAT]
	and $02
	jr nz, .equalsc
	ld a, $91 ;this is our current cell
	ld [hl+], a
	jr .branchesend
.unequal
	call MaskMapCell ;this uses our current a (current cell)
	jr z, .equalscend
.C2E9not1
	ldh a, [rSTAT]
	and $02
	jr nz, .C2E9not1
	ldh a, [$FF90] ;our saved 0 or 3 based on B's evenness earlier
	add a, $90 ;this is a seen cell
	ld [hl+], a
	jr .branchesend
.equalscend
	ldh a, [rSTAT]
	and $02
	jr nz, .equalscend
	ldh a, [$FF90]
	add a, $8F ;this is an unseen cell
	ld [hl+], a
.branchesend
	pop af
	inc a
	dec b
	jp nz, .loop
	ld b, a
	ld a, l
	add a, $1C ;scroll to the next map row
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, b
	ret
	
MaskXYBitpairs: ;6262
	ld d, $00
	cp $08 ;comparing ypos
	jr nc, .firsttable ;if Y bitpair is 3 or 2, jump
	ld e, a
	ld a, [de]
	ld e, a ;else load the toprom 2nd table value into e
	ld a, [$C359]
	or e
	ld [$C359], a ;and mask C359 with it
	ret
.firsttable ;6273
	;if Y was 3 or 2
	and $07 ;mask 
	ld e, a
	ld a, [de]
	ld e, a ;load the toprom 1st table value into e
	ld a, [$C35A]
	or e
	ld [$C35A], a ;and mask C35A with is
	ret
	
MaskMapCell: ;6280
	push de
	ld d, $00
	cp $08
	jr nc, .firsttable
	ld e, a
	ld a, [de]
	ld e, a
	ld a, [$C359]
	and e
	pop de
	ret
.firsttable
	and $07
	ld e, a
	ld a, [de]
	ld e, a
	ld a, [$C35A]
	and e
	pop de
	ret
;629B