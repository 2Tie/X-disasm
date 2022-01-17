SECTION "Bank 4 top", ROMX[$4000], BANK[$4]
ModelHeights: ;4000
	db $1E, $16, $1E, $32, $0F, $14, $14, $1E, $0A, $0A, $14, $1E, $14, $0A, $0A, $1E, $0A, $1E, $0A, $0A, $19, $14, $14, $1E, $0F, $1E, $14, $14, $28, $28, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $3C, $1E, $1E, $1E, $28, $28, $3C, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $0F, $28, $28, $1E, $1E, $1E, $1E, $28, $1E, $28, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E

RestoreGUIAndMusic: ;4054
	;called in demo, training
	call LoadFullGUI
	ld a, TRACK_LEVEL_STATE
	ld [wQueueMusic], a
	ret
	
LoadFullGUI: ;405D
	ld a, [$CB49]
	cp $01
	ret z
	ld a, $FF
	ldh [hGameState], a
	call CallDisableLCD
	call ClearAllVRAM
	call ClearWRAM
	call LoadGuiSpecials
	call CallDrawHealthBar
	ld hl, $99CE ;start of map
	call CallDrawMinimap
	ld a, [wInventory1] ;inventory?
	call CallPrintInterfaceString
	call CallDrawCompass
	call CallSetAlertTiles
	call CallEmpty1022D ;likely a debug func
	call CallDrawSpeedDisplay
	call CallDrawFuel
	call CallDrawMissileCount
	call CallDrawSurfaceAndSky ;nop this for optional performance increase?
	ld c, $6F ;coords
	ld b, $7F
	ld e, $35 ;the minimap + tile
	call CallDrawMinimapPips
	call CallDrawMaxedHorizon ;???
	call CallDrawRadarBG
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	or $02
	ldh [rIE], a
	ld a, $60
	ldh [rLYC], a
	xor a
	ld [wBJustPressed], a
	ld [wAJustPressed], a
	ld [wTargetSCY], a
	ldh [rSCY], a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF0], a
	ldh [$FFF2], a
	ldh [$FFEE], a
	call CallCopyWRAMToVRAM
	call CallCopyWRAMToVRAM
	ld a, $01
	ldh [hGameState], a
	ld [$CA9C], a
	loadpalette 0, 2, 1, 0
	ldh [rOBP0], a
	loadpalette 0, 1, 0, 0
	ldh [rOBP1], a
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	loadpalette 0, 0, 2, 3 ;nighttime palette
	jr nz, .loadpal ;if C0AF = 2C, set to daytime/tunnel?
	call CallLoadTunnelHealthGFX ;??
	loadpalette 3, 3, 1, 0 ;daytime palette
.loadpal
	ldh [rBGP], a
	ldh [hBGP], a
	loadpalette 1, 0, 2, 3
	ldh [hIntP], a
	xor a
	ldh [hPauseFlag], a
	ld a, $19
	ld [wLevelStartTimer], a
	ret
	
EntityLogicCoin: ;4109
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;Y position
	ld a, [de]
	sub $1E
	ld [de], a ;move it down?
	inc de
	ld a, [de]
	sbc a, $00
	ld [de], a ;move it down
	ld a, l
	add a, $07
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;z orientation (top spin)
	ld a, [de]
	add a, $20
	ld [de], a ;speen~
	ld a, l
	add a, $0D
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;speed
	ld a, [de]
	inc a
	ld [de], a ;increment
	cp $05
	ret c ;if less than five, return
	ld a, $FF
	call CallDamageEntity
	ld a, [wHealth]
	inc a
	cp $09
	ret nc
	ld [wHealth], a ;increase health by one!
	ret

DrawHealthBar: ;4144
	ld a, [$C29A]
	or a
	ret nz
	ldh a, [hGameState]
	dec a
	jr nz, .notplanet
	ld a, [$C2A1] ;animation frame?
	cpl
	and $03
	ret nz
.notplanet
	ld a, [wHealth]
	cp $08
	jr c, .drawemptyhealth ;if less than eight, jump to drawing
	cp $80
	jr c, .caphealth ;if less than 80 (not negative), cap the health
	xor a
	jr .drawemptyhealth ;else it's negative, lower bounds is zero
.caphealth
	ld a, $08
	ld [wHealth], a
.drawemptyhealth
	ld b, a
	push bc
	ld hl, $9873 ;where the top health bar goes
	ld a, $08
	sub a, b
	jr z, .drawremaininghealth ;if health full, skip past drawing empty health
	ld b, a
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, $89 ;empty health
	ld [hl+], a
	inc a
	ld [hl+], a
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .statloop
.drawremaininghealth
	pop bc
	ld a, b
	or a
	ret z
.statloop2
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop2
	ld a, $87
	ld [hl+], a
	inc a
	ld [hl+], a
	ld a, l
	add a, $1E
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec b
	jp nz, .statloop2
	ret

DrawFuel: ;41A6
	;sets certain values in vram (background maps)
	ldh a, [hGameState]
	dec a
	jr nz, .nonzero
	ld a, [$C2A1]
	and $01 ;update every other animation frame
	ret nz
.nonzero
	ld hl, $9A04
	ld a, [$CA82]
	rrca
	rrca
	rrca
	and $1F
	ld b, a
	and $07
	sub $01
	adc a, $00
	sub $01
	adc a, $00
	add a, $0F
	ld c, a
	ld a, b
	cp $18
	jr nc, .over17
	cp $10
	jr nc, .overf
	cp $08
	jr nc, .over7
	ld a, c
	ld [hl+], a
	ld a, $0F
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret
.over7
	ld a, $14
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, $0F
	ld [hl+], a
	ld [hl+], a
	ret
.overf
	ld a, $14
	ld [hl+], a
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, $0F
	ld [hl+], a
	ret
.over17
	ld a, $14
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], c
	ret
	
IF UNUSED == 1
DrawTunnelHeaderValues: ;41FA
	ld hl, $CA85 ;tunnel header values!
	ld b, $03
	ld de, $99C4
.loop
	ld a, [hl+]
	sla a
	add a, $AA ;subtracting 86, or $56? segmented digits start at $19
	ld c, a
.statloop1
	ldh a, [rSTAT]
	and rSTAT_MODE_NOT_BLANKING
	jr nz, .statloop1
	ld a, c ;top tile
	ld [de], a
	ld a, e
	add a, $20 ;next row down?
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
.statloop2
	ldh a, [rSTAT]
	and rSTAT_MODE_NOT_BLANKING
	jr nz, .statloop2
	ld a, c
	inc a ;bottom tile
	ld [de], a
	ld a, e
	sub $1F ;next row
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	dec b
	jr nz, .loop
	ret
ENDC

Empty1022D: ;422D
	ret
;422E

SECTION "4:4261", ROMX[$4261], BANK[4]
CheckEntityCollision: ;4261 
	ld a, [wGameOverTimer]
	or a
	ret nz ;return if timer active
	ld a, [wLevelClearCountdown]
	or a
	ret nz ;return if timer active
	push hl ;save ent position pointer
	dec hl
	ld a, [hl+] ;load model
	ldh [$FFD1], a ;model
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;BC holds X
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;DE holds Y
	ld a, [hl+]
	ldh [$FFCF], a
	ld a, [hl+]
	ldh [$FFD0], a ;CF/D0 holds Z
	ld hl, hXLoCopy
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;our X into HL
	ld a, l
	sub $41
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ; minus 0041
	ld a, c
	cp l
	ld a, b
	sbc a, h ;their X minus ours
	cp $80
	jp nc, .nocol ;jump if negative!
	ld a, l
	add a, $82
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;our X plus 41
	ld a, c
	cp l
	ld a, b
	sbc a, h
	cp $80
	jp c, .nocol ;jump if positive!
	ld hl, hYLoCopy ;now do the same with Y
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $41
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	ld a, e
	cp l
	ld a, d
	sbc a, h
	cp $80
	jp nc, .nocol ;jump if their y - our y < 41
	ld a, l
	add a, $82
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	cp l
	ld a, d
	sbc a, h
	cp $80
	jp c, .nocol ;jump if their y - our y > 41
	ldh a, [$FFD1] ;model
	dec a
	ld hl, ModelHeights
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl] ;grab value from table
	sla a ;times 2
	ldh [$FFD1], a ;save value
	ldh a, [$FFCF] ;model Z
	sub a, [hl] ;minus height
	ld l, a
	ldh a, [$FFD0]
	sbc a, $00
	ld h, a
	ld a, l
	ldh [$FFCC], a
	ld a, h
	ldh [$FFCD], a ;save bottom of collision box
	ld hl, hZPosLow
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl ;negate our Z
	ldh a, [$FFD1]
	cpl
	inc a
	add a, l
	ld l, a
	ld a, h
	adc a, $FF
	ld h, a ;add height to our Z
	ldh a, [$FFCC]
	cp l
	ldh a, [$FFCD]
	sbc a, h
	cp $80
	jr nc, .nocol ;if not clipped, jump
	ldh a, [$FFD1]
	rlca
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;height again to our Z
	ldh a, [$FFCC]
	cp l
	ldh a, [$FFCD]
	sbc a, h
	cp $80
	jr c, .nocol ;if not clipped, jump
	ld a, $01
	ld [$CB07], a
	ld [$C356], a
	pop hl
	ld a, l
	ld [$C357], a
	ld a, h
	ld [$C358], a ;save collided model's X to here
	ret
.nocol ;4334, 25, 12
	pop hl
	ret
;4336

SECTION "4:55D0", ROMX[$55D0], BANK[4]
IF UNUSED == 1
MissionReportTilemap: ;55D0
	db $14, $20
	db $00, $01, $02, $02, $03, $04, $04, $04, $01, $03, $05, $06, $07, $08, $09, $09 
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0A 
	db $0B, $0C, $0D, $0D, $0E, $0F, $0F, $0F, $0C, $0E, $10, $11, $12, $13, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $15, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $16, $01, $02, $02, $03, $04, $04, $04, $01, $03, $05, $06, $07, $17, $14, $14 
	db $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $15 
	db $18, $0C, $0D, $0D, $0E, $0F, $0F, $0F, $0C, $0E, $10, $11, $12, $19, $09, $09 
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $1A
;5852
	INCBIN "build/gfx/ModelViewerBorder.rle"

MissionReport: ;5933
	call CallDisableLCD
	call ClearAllVRAM
	xor a
	ldh [hGameState], a
	ld [wScrollYFlag], a
	ld a, $08
	ldh [rSCX], a
	ld a, $FF
	ldh [rWX], a
	ld hl, MissionReportTilemap
	ld de, $0001
	ld bc, $00A5
	call LoadTileMap
	call Refresh3DWindow
	call CallDrawHalf3D
	call CallDrawHalf3D
	call ClearWRAM
	call CallLoadAlphanumerics
	ld a, $6C
	ld [wTargetSCY], a
	ldh [rSCY], a
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP0], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP1], a
	ld a, $0E
	ld [$C33A], a ;unknown
	ld hl, wReportPointer
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;follow the pointer
.drawMissionReport ;loop
	call UnusedDrawMissionReportLine
	ld a, [hl] ;next text
	or a
	jr nz, .drawMissionReport ;keep going until a double 00 to end the report
	ld a, $A3
	call CallFlashScreen
.inputloop
	call UpdateInputs
	ld a, [wCurrentInput]
	ld c, a
	ld a, [wChangedInputs]
	and c
	bit INPUT_START, a
	ret nz
	or a
	jr nz, .doneinputs
	jr .inputloop
.doneinputs
	ld a, [$CB16] ;unknown
	or a
	ret nz
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF0], a
	ldh [$FFF2], a
	ldh [$FFEE], a
	ld a, $34
	ld [wPitchLurch], a
	ld [wPitchAngleR], a
	ld [wPitchAngle], a
	xor a
	ld [wModelExploding], a
	ldh [hRenderXOffLo], a
	ldh [hRenderXOffHi], a
	ldh [$FFDF], a
	ldh [$FFE0], a
	ldh [$FFDD], a
	ldh [$FFDE], a
	ldh [$FFDB], a
	ldh [$FFA4], a
	ldh [$FFA5], a
	ldh [$FFA3], a
	ldh [$FFA1], a
	ld [wHideEntities], a
	ld a, $01
	ldh [$FFDC], a
	ld a, $32
	ld [wLurchTarget], a
	ld a, $D0
	ldh [$FF9B], a
	loadpalette 2, 0, 1, 3
	ldh [rBGP], a
.modelsLoop ;59F4
	ld a, [wUpdateCounter]
	inc a
	ld [wUpdateCounter], a
	xor a
	ld [$C339], a
	ld a, $08
	ld [$C33A], a
	xor a
	ld bc, $000A
	call CallRotateCoordsAndSaveInvert
	ld a, c
	ld a, b
	ld a, [$C31C] ;these ops the wrong direction?
	ld a, [$C31E] ;these ops the wrong direction?
	ld a, [wCurrentInput]
	bit INPUT_DOWN, a
	jr z, .up
	ld a, $6C
	ld [wTargetSCY], a
.up ;5
	ld a, [wCurrentInput]
	bit INPUT_UP, a
	jr z, .select
	xor a
	ld [wTargetSCY], a
.select ;4
	call CallCopyWRAMToVRAM
	call UpdateInputs
	ld a, [wCurrentInput]
	ld d, a
	ld a, [wChangedInputs]
	and d
	bit INPUT_SELECT, a ;Select advances model
	jp z, .checkInputs
	ld a, [$C29B]
	inc a
	cp $55
	jp c, .saveModel
	xor a ;else loop it
.saveModel ;5A47
	ld [$C29B], a
.checkInputs ;5A4A
	ld a, [wChangedInputs]
	and d
	bit INPUT_START, a ;start exits
	ret nz
	ld a, [wLurchTarget]
	ld e, a
	bit INPUT_RIGHT, d ;right increases lurch
	jr nz, .left
	inc e
	inc e
.left ;2
	bit INPUT_LEFT, d ;left decreases lurch
	jr nz, .gotlurch 
	dec e
	dec e
.gotlurch ;2
	ld a, e
	or a
	jr z, .saveLurch
	cp $80
	inc a
	jr nc, .saveLurch
	sub $02
.saveLurch ;7, 2
	ld [wLurchTarget], a
	sra e
	ldh a, [$FFA4]
	add a, e
	ldh [$FFA4], a
	ld a, [$CA8A]
	ld e, a
	bit INPUT_A, d ;A adds two to CA8A
	jr nz, .b
	ld a, e
	add a, $80
	add a, $02
	jr c, .b
	sub $80
	ld e, a
.b ;A, 3
	bit INPUT_B, d ;B subtracts two to CA8A
	jr nz, .yump
	ld a, e
	add a, $80
	sub $02
	jr c, .yump
	sub $80
	ld e, a
.yump ;A, 3
	ld a, e
	or a
	jr z, .saveca8a
	cp $80
	jr nc, .inc
	sub $02
.inc ;2
	inc a
.saveca8a ;7
	ld [$CA8A], a
	ld c, a
	cp $80
	ld a, $00
	adc a, $FF
	ld b, a
	ldh a, [$FFDB]
	add a, c
	ldh [$FFDB], a
	ldh a, [$FFDC]
	adc a, b
	ldh [$FFDC], a
	cp $40
	jr c, .done
	cp $A0
	jr nc, .clear
	ld a, $3F
	ldh [$FFDC], a
	ld a, $FF
	ldh [$FFDB], a
	xor a
	ld [$CA8A], a
	jr .done
.clear ;E
	xor a
	ldh [$FFDC], a
	ldh [$FFDB], a
	ld [$CA8A], a
.done ;1A, 8
	ldh a, [$FFA4]
	ldh [$FFA1], a
	ld a, [wLurchTarget]
	cpl
	inc a
	ldh a, [$FFA4]
	push af
	xor a
	ldh [$FFA4], a
	ld a, [$C29B]
	inc a
	call CallDrawModel
	pop af
	ldh [$FFA4], a
	ld a, [$C29B]
	inc a
	ld de, $D058
	call CallLoadModelName
	ld hl, $D058
	ld bc, $0000
	call CallCopyEnglishStringToWRAM
	jp .modelsLoop
	
;5B03

SECTION "4:5B37", ROMX[$5B37], BANK[4]
IncrementMissionHelpPointer: ;5B37
	ld a, [$C33A]
	inc a
	ld [$C33A], a
	ret
UnusedDrawMissionReportLine: ;5B3F
	push hl ;save per-level pointer
	ld c, $FF
.lengthloop ;FB
	ld a, [hl+]
	inc c
	or a
	jr nz, .lengthloop ;loop until we find a zero, c is our loop number?
	ld a, $14 ;screen width in tiles
	sub a, c ;$14 - loop count
	srl a ;divide by two
	inc a ;plus one
	ld c, a ;save to C (now a centered offset!)
	ld a, [$C33A] ;multiple of eight? ;F8
	rlca
	rlca
	rlca ;rotate left three? ;C7
	ld d, $00
	rla
	rl d
	rla
	rl d ;rotate lowest two bits into D
	add a, c ;add the rest, up to 1C in multiples of four, to our C
	ld e, a ;and save it to E
	ld hl, $9800
	add hl, de ;advance into tilemap VRAM
	ld e, l
	ld d, h ;save this spot in DE
	pop hl ;restore our pointer
	ld a, [$C33A]
	inc a
	ld [$C33A], a ;increment by one
.copyloop ;E7 loop
	ld a, [hl+] ;grab a tile
	or a
	ret z ;return if byte is zero
	cp $41
	jr nc, .letter ;if above 41, jump
	cp $30
	jr nc, .over30 ;if above  or equal to 30 (never encountered?), jump
	ld a, $A4 ;default (blank) tile is A4
	jr .write
.over30 ;4
	sub $96 ;plus 6A?
	jr .write
.letter ;C
	sub $C1 ;plus 3F?
.write ;6, 2
	ld [de], a ;write A to tilemap
	inc de ;next tile
	jr .copyloop
.deadloop ;F9
	ld a, [hl+]
	ld [de], a
	or a
	ret z
	inc de
	jr .deadloop
	ret
ENDC

TestEntityHasCollisions: ;5B8D
	dec hl
	ld a, [hl]
	push hl ;save pointer
	push af ;save model?
	xor a
	ld [hl+], a ;wipe model (so we don't collide with ourself!)
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;x into BC
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;y into DE
	ld a, [hl+]
	ldh [$FFCF], a
	ld a, [hl+]
	ldh [$FFD0], a ;Z into this'n
	call EntsCollision
	rl c ;save collision flag
	pop af
	pop de
	ld [de], a ;restore model
	inc de ;our model pointer's now in DE (collided entity pointer is in HL)
	rr c ;restore collision flag
	ret

TestParticleEntsCollision: ;5BAD
	;sets carry if collision found; HL is then loaded with the ent
	inc hl
	inc hl
	inc hl ;advance to X pos
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a ;load X into BC
	inc hl
	inc hl ;advance to Y pos
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a ;load Y into DE
	ld a, [hl+]
	ldh [$FFCF], a
	ld a, [hl+]
	ldh [$FFD0], a ;load Z into CF/D0
EntsCollision: ;5BC0
	ld hl, wEntityTable
	ld a, ENTITY_SLOTS
.entloop ;5BC5
	push af ;iterator
	ld a, [hl+]
	or a
	jp z, .nextent ;if no model, next
	bit 7, a
	jp nz, .nextent ;if hidden, next
	ldh [$FFD1], a ;ent model into D1
	push bc ;partX
	push de ;partY
	push hl ;ent(X)
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;load X into HL
	ld a, l
	sub $41
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a ;X -= $0041
	ld a, c
	cp l
	ld a, b
	sbc a, h
	cp $80 ;compare part X with offset ent X
	jp nc, .nextentpops ;if part x < ent x - 41, next
	ld a, l
	add a, $82
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;X += $0082 (to the other side)
	ld a, c
	cp l
	ld a, b
	sbc a, h
	cp $80
	jp c, .nextentpops ;if part x > ent x + 41, next
	pop hl
	push hl ;restore ent pointer
	inc hl
	inc hl ;advance to Y
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	sub $41
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	ld a, e
	cp l
	ld a, d
	sbc a, h
	cp $80
	jp nc, .nextentpops ;if part y < ent y - 41, next
	ld a, l
	add a, $82
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, e
	cp l
	ld a, d
	sbc a, h
	cp $80
	jr c, .nextentpops ;if part y > ent y + 41, next
	ldh a, [$FFD1]
	dec a ;model index
	ld hl, ModelHeights
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl] ;grab height
	sla a
	ldh [$FFD1], a ;height*2 for add later
	ldh a, [$FFCF]
	add a, [hl]
	ld l, a
	ldh a, [$FFD0]
	adc a, $00
	ld h, a
	ld a, l
	ldh [$FFCC], a
	ld a, h
	ldh [$FFCD], a ;CC/CD is part Z - model height
	pop hl
	push hl ;restore ent pointer
	ld a, l
	add a, $04
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advance HL to ent Z
	ld a, [hl+]
	ld h, [hl]
	ld l, a ;ent Z in HL
	ldh a, [$FFD1] ;height
	cpl
	inc a
	add a, l
	ld l, a
	ld a, h
	adc a, $FF
	ld h, a ;HL is ent Z - height
	ldh a, [$FFCC]
	cp l
	ldh a, [$FFCD]
	sbc a, h
	cp $80
	jr nc, .nextentpops ;if part Z < ent z - height, next
	ldh a, [$FFD1] ;height
	rlca ;height * 2
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ldh a, [$FFCC]
	cp l
	ldh a, [$FFCD]
	sbc a, h
	cp $80
	jr c, .nextentpops ;if part Z > ent z + height, next
	pop hl
	add sp, $06 ;pop the three words
	scf ;set carry, collision found!
	ret
.nextentpops ;5C7B
	pop hl
	pop de
	pop bc
.nextent ;5C7E
	ld a, l
	add a, ENTITY_SIZE - 1
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop af
	dec a
	jp nz, .entloop
	xor a
	ret
	
IF UNUSED == 1
CheckSerial: ;5C8D
	ld a, [wSerialControl1]
	ld [wSerialControl2], a
	ld a, [wSerialControl1]
	cp (1<<rSC_ON)|(1<<rSC_CLOCK)
	jr nz, .doneWaiting ;if our control isn't master, skip
	call WaitForVBlank ;if we are master, wait?
	call WaitForVBlank
.doneWaiting ;6
	di
	xor a
	ldh [rIF], a
	ld [$C26D], a
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	or (1<<VBLANK)|(1<<SERIAL)
	ldh [rIE], a
	xor a
	ldh [rSB], a ;send blank to SB
	ld a, [wSerialControl2]
	ldh [rSC], a
	ld [wSerialControl1], a
	xor a
	ld [$C267], a
	ld [$C264], a
	ld [$C263], a
	ld [$C266], a
	ld [$C268], a
	ld [$C269], a
	ld [$C26E], a
	ld a, $20
	ld [$C265], a
	ld a, $03
	ld [$C262], a
	reti
	
BoxRoomTilemap: ;5CDC
	db $14, $12 
	db $00, $01, $01, $01, $02, $03, $03, $04, $01, $01, $01, $05, $06, $03, $03, $07, $08, $09 
	db $0A, $0B, $0B, $0B, $0C, $0D, $0D, $0E, $0B, $0B, $0F, $10, $0D, $11, $12, $13, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $17, $14, $14, $14, $14 
	db $15, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $16, $18, $14, $14, $14, $14 
	db $19, $1A, $1A, $1A, $1B, $1C, $1C, $1D, $1A, $1A, $1E, $1F, $1C, $20, $21, $22, $14, $14 
	db $23, $01, $01, $01, $02, $03, $03, $24, $01, $01, $01, $25, $26, $03, $03, $27, $28, $29
;5E46
	INCBIN "build/gfx/BoxRoom.rle"
	
DisplayHiscores: ;602F
	call CallDisableLCD
	call ClearAllVRAM
	call LoadGuiSpecials
	ld a, $A1
	call CallFlashScreen
	call CallLoadSRAM_OLD
	ld a, $03
	ldh [$FFDB], a
	ldh [$FFDC], a
.loop
	xor a
	ld [wHideEntities], a
	ldh [hRenderXOffLo], a
	ldh [hRenderXOffHi], a
	ld [$C339], a
	ld [$C33A], a
	ld a, $34
	ld [wPitchLurch], a
	ld [wPitchAngle], a
	xor a
	ldh [$FFA4], a
	ldh [$FFA5], a
	ldh [$FFA3], a
	ldh [$FFA1], a
	ldh a, [$FFDC]
	cp $0A
	jr nc, .getinput
	ldh a, [$FFDB]
	add a, $8C
	ldh [$FFDB], a
	ldh a, [$FFDC]
	adc a, $00
	ldh [$FFDC], a
.getinput ;c
	ld a, $05
	call DrawHiscoreEntries
	call UpdateInputs
	ld a, [wCurrentInput]
	ld c, a
	ld a, [wChangedInputs]
	and c
	bit INPUT_START, a
	ret nz ;end
	call CallCopyWRAMToVRAM
	jr .loop

DrawHiscoreEntries: ;608F
	ld b, a
	ld a, $FE
	ldh [$FFDE], a
	ld a, $B4
	ldh [$FFDD], a
	ld hl, wHiscores
.particle ;C0
	push bc
	push hl
	ld a, $96
	ldh [$FFDF], a
	ld a, $FD
	ldh [$FFE0], a
	call Draw3DString
	pop hl
	push hl
	ld a, l
	add a, $0A
	ld l, a
	ld a, h
	adc a, $00
	ld h, a ;advanced to the numbers
	xor a
	ldh [$FFDF], a
	ld a, $01
	ldh [$FFE0], a
	call CopyHLtoPlayerName
	ld hl, wPlayerName ;name?
	call Draw3DString
	ldh a, [$FFDD]
	add a, $78
	ldh [$FFDD], a
	ldh a, [$FFDE]
	adc a, $00
	ldh [$FFDE], a
	pop hl
	ld a, l
	add a, $10
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	pop bc
	dec b
	jr nz, .particle
	ret
	
CopyHLtoPlayerName: ;60DC
	ld de, wPlayerName
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	ld a, [hl+]
	add a, $5B
	ld [de], a
	inc de
	xor a
	ld [de], a
	ld hl, wPlayerName
	ld b, $05
.loadname
	ld a, [hl]
	cp $5B
	jr nz, .ret
	ld a, $20
	ld [hl+], a
	dec b
	jr nz, .loadname
.ret
	ret
	
EnterHiscoreName: ;6110
	call CallDisableLCD
	call ClearAllVRAM
	call WipeWholeScreenTiles
	ld hl, TitleScreenPlanetTilemap
	call LoadBank7TilesetOffset80
	ld hl, $9863
	call Refresh3DWindow.customPos
	xor a
	ldh [$FFF3], a
	ldh [$FFEF], a
	ld a, $80
	ldh [$FFF1], a
	ld a, $58
	ldh [$FFED], a
	ld a, $80
	ldh [$FFF4], a
	ldh [$FFF0], a
	ldh [$FFF2], a
	ldh [$FFEE], a
	xor a
	ld [wHideEntities], a
	ld [wTargetSCY], a
	ldh [rSCY], a
	ld a, $08
	ldh [rSCX], a
	loadpalette 2, 3, 1, 0
	ldh [rBGP], a
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $A3
	call CallFlashScreen
	ldh a, [rLCDC]
	res rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	xor a
	ld [wCurrentLetter], a
	ld [$C311], a
	ld hl, $C307
	ld [hl+], a ;C307
	ld [hl+], a ;C308
	ld [hl+], a ;C309
	ld [hl+], a ;C30A
	ld [hl+], a ;C30B
	ld [hl+], a ;C30C
	ld [hl+], a ;C30D
	ld [hl+], a ;C30E
	ld [hl+], a ;C30F
.enterloop ;6170
	xor a
	ld [wHideEntities], a
	ldh [hRenderXOffLo], a
	ldh [hRenderXOffHi], a
	ld [wPitchLurch], a
	ld [wPitchAngle], a
	call UpdateInputs
	ld a, [wCurrentInput]
	ld e, a
	ld a, [wChangedInputs]
	and e
	ld d, a
	bit INPUT_START, a
	jr z, .enterletters ;to 61B9
	ld hl, $C307
	ld a, [hl+]
	cp "D"
	ret nz
	ld a, [hl+]
	cp "Y"
	jr nz, .darren
	ld a, [hl+]
	cp "L"
	ret nz
.special ;E5
	ld a, $01
	ld [wDidTetamusTunnel], a
	ret
.darren ;61A4, A
	cp "A"
	ret nz
	ld a, [hl+]
	cp "R"
	ret nz
	ld a, [hl+]
	cp "R"
	ret nz
	ld a, [hl+]
	cp "E"
	ret nz
	ld a, [hl+]
	cp "N"
	ret nz
	jr .special
.enterletters ;61B9
	bit INPUT_A, d
	jr z, .b
	ld a, [$C311]
	inc a
	cp $08
	ret nc
	ld [$C311], a
.b
	bit INPUT_B, d
	jr z, .right
	ld a, [$C311]
	sub $01
	jr c, .right
	ld [$C311], a
	inc a
	ld hl, $C307
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld [hl], $00
.right
	ld a, [wCurrentLetter]
	ld d, a
	bit INPUT_RIGHT, e
	jr z, .left
	ld a, d
	add a, $04
	ld d, a
.left
	bit INPUT_LEFT, e
	jr z, .donedirections
	ld a, d
	sub $04
	ld d, a
.donedirections
	ld a, d
	or a
	jr z, .save
	cp $80
	jr nc, .add
	sub $04
.add
	add a, $02
.save
	ld [wCurrentLetter], a
	ld d, a
	ld a, [wViewDir]
	add a, d
	ld [wViewDir], a
	ld a, [wViewDir]
	ld c, a
	ld b, $1A
.drawlettersloop ;A5
	push bc
	ld a, b
	sla a
	sla a
	sla a
	add a, c
	ld d, a
	ld bc, $6400
	call CallRotateCoordByAngle
	ld e, b
	ld a, c
	cp $80
	ld a, $00
	adc a, $FF
	sla c
	rla
	sla c
	rla
	ld b, a
	ld a, e
	cp $80
	ld a, $00
	adc a, $FF
	sla e
	rla
	sla e
	rla
	ld d, a
	ld a, c
	ldh [$FFDF], a
	ld a, b
	ldh [$FFE0], a
	ld a, e
	ldh [$FFDB], a
	ld a, d
	add a, $07
	ldh [$FFDC], a
	ld a, $64
	ldh [$FFDD], a
	ld a, $01
	ldh [$FFDE], a
	pop bc
	push bc
	ld a, b
	sla a
	sla a
	sla a
	add a, c
	add a, $80
	ldh [$FFA1], a
	ld a, b
	add a, $55 ;letter A offset
	call CallDrawModel
	pop bc
	dec b
	jr nz, .drawlettersloop
	ld a, $06
	ldh [$FFDC], a
	xor a
	ldh [$FFDF], a
	ldh [$FFDB], a
	ldh [$FFDD], a
	ld a, $FF
	ldh [$FFE0], a
	ld a, $02
	ldh [$FFDE], a
	xor a
	ldh [$FFA1], a
	ldh [$FFA5], a
	ldh [$FFA3], a
	ld a, [$C311]
	ld hl, $C307
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [wViewDir]
	cpl
	inc a
	sub $84
	and $F8
	rrca
	rrca
	rrca
	add a, $41
	cp $5B
	jr c, .draw 
	ld a, $20
.draw ;2
	ld [hl], a
	ld hl, $C307
	call Draw3DString
	call CallCopyWRAMToVRAM
	jp .enterloop
ENDC

CheckRadarStatic: ;62B4
	;updates 10 groups of 8 bytes, starting at D058.
	ld a, [wCurLevel]
	cp LEVEL_TUTORIAL
	jr z, .clear
	ldh a, [hGameState]
	dec a
	jr nz, .update ;if not on planet, skip
	ld a, [wUpdateCounter]
	and $01
	ret nz ;return every other animation frame, if on planet
.update
	ld a, [wHealth]
	sub $02
	jr nc, .clear
	add a, $10 ;else we're low on health. add 16
	cpl ;invert,
	and $1F ;and grab the low 5 bits
	ld c, a ;c is a bit pattern, for radar static. 1 every row for 1 health, 2 every row for 0 health
	ld a, [wFrameCounterLo]
	and $F8 ;grab top five bits of the timer
	rrca
	rrca
	rrca ;and shift it down to $00 - $1F range
	and $07 ;only grab the bottom three bits now, scroll offset
	ld b, a ;store it into B
	ld a, c ;modified health from before
.loop
	rrca ;shift down
	dec b
	jr nz, .loop
	ld hl, wRadarBuffer
	ld b, $10
.bottomloop
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a
	rrca
	ld [hl+], a ;load the pattern to eight bytes, ten times
	rrca
	dec b
	jr nz, .bottomloop
	ret
.clear ;62FC, 41, we're in the tutorial, no pattern
	ld hl, wRadarBuffer
	ld b, $10
	xor a
.clearloop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	dec b
	jr nz, .clearloop
	ret
	
DrawRadarStatic: ;630E, called after CheckRadarStatic
	ldh a, [hGameState]
	dec a
	jr nz, .drawstatic
	ld a, [wUpdateCounter]
	and $01
	ret z
.drawstatic
	call CallOverlayRadar ;places the radar gfx over what's in D058
	ld hl, wRadarBuffer
	ld de, $83A1
	ld b, $40
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl+] ;load from static
	ld [de], a ;write to bitplane
	inc e
	inc e
	ld a, [hl+] ;load from static
	ld [de], a ;write to bitplane
	inc de
	inc e
	dec b
	jr nz, .statloop
	ret
	
EntityLogicMilitaryBase: ;6336
	ld a, [$CB12]
	inc a
	ld [$CB12], a
	ld a, [wEntityCollided]
	or a
	jp z, .ret
	ld a, [wLurchTarget]
	bit 7, a
	jp nz, .ret ;leave if lurching
	ld a, $02
	ld [wCollisionType], a
	ld a, l
	ld [wJunctionPointerLo], a
	ld a, h
	ld [wJunctionPointerHi], a
	call CallHandleJunctionState
	call CallRestoreGUIAndMusic
.ret
	ret
	
EntityLogicBomb: ;6360, bomb logic
	ld a, l
	add a, $04
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;load ypos into DE
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	or c
	jr nz, .move ;if it's not zero, jump?
	push hl
	call CallGetDistanceFromPlayer
	jr c, .boom ;if not loaded, jump
	cp $08 ;are we closer than $10 to player?
	jr nc, .boom
	ld a, [wHealth]
	sub $02 ;ouch
	ld [wHealth], a
	ld a, [wScreenShakeCounter]
	add a, $14
	ld [wScreenShakeCounter], a
.boom
	pop hl
	push hl
	call CallBombDamageEnts
	pop hl
	ld a, $FF
	call CallDamageEntity ;kill this
	ld a, $02
	ld [wFlash3DWindow], a ;flash once
	ret
.move
	call CallMoveBomb
	ret
;639E

SECTION "4:63F7", ROMX[$63F7], BANK[4]
IF UNUSED == 1
ShowMissionHelp: ;63F7
	call ClearAllVRAM
	xor a
	ld [wScrollYFlag], a
	ld a, $08
	ldh [rSCX], a
	ld hl, MissionHelpTilemap
	ld de, $0001
	ld bc, $00A5
	call LoadTileMap
	xor a
	ld [wTargetSCY], a
	ldh [rSCY], a
	loadpalette 1, 2, 3, 0
	ldh [rBGP], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP0], a
	loadpalette 3, 2, 1, 0
	ldh [rOBP1], a
	call CallLoadAlphanumerics
	ld a, [wCurLevel]
	and $FC
	rrca ;shift into a word offset for table
	add a, LOW(MissionHelpTable)
	ld l, a
	ld a, $00
	adc a, HIGH(MissionHelpTable) ;table at 6AAF
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr z, .none
	ld a, $06
	ld [$C33A], a
.lineloop ;F7
	ld a, [hl]
	or a
	jr z, .done
	call UnusedDrawMissionReportLine
	jr .lineloop
.none
	ld a, $07
	ld [$C33A], a
	ld hl, NoHelpTextLine1 ;help lines?
	call UnusedDrawMissionReportLine
	call IncrementMissionHelpPointer ;increments C33A
	ld hl, NoHelpTextLine2
	call UnusedDrawMissionReportLine
	call IncrementMissionHelpPointer
	ld hl, NoHelpTextLine3
	call UnusedDrawMissionReportLine
	call IncrementMissionHelpPointer
	ld hl, NoHelpTextLine4
	call UnusedDrawMissionReportLine
	call IncrementMissionHelpPointer
.done ;2E
	ld a, $A3
	call CallFlashScreen
	call WaitForStartPress
	ret

ENDC

ScaleByDistance: ;6477
	;shifts E9-EC upward based on 00 bytes
	ld b, $11
	ldh a, [$FFE8]
	ld l, a
	ldh a, [$FFE7]
	or l ;OR the two bytes together
	ret z ;return if they both are blank, scale factor of zero
	ldh a, [$FFEC]
	or a
	jr nz, .scaleBits ;if sixth byte has value, start with B $11
	ldh a, [$FFEB]
	or a
	jr z, .checkThird ;if fifth byte (high scalee) zero, check next
	ldh [$FFEC], a
	ldh a, [$FFEA]
	ldh [$FFEB], a
	ldh a, [$FFE9]
	ldh [$FFEA], a ;move three bytes up one
	ld b, $09 ;nine instead of $11
	xor a
	ldh [$FFE9], a ;wipe E9
	push af ;push one because we shifted one, jump
	jr .scaleBits ;to 64D0
.checkThird
	ldh a, [$FFEA]
	or a
	jr z, .checkFourth ;if low scalee zero as well, jump ahead.
	ldh [$FFEC], a
	ldh a, [$FFE9]
	ldh [$FFEB], a ;move them up two
	ld b, $01 ;b is 1
	xor a
	ldh [$FFE9], a ;replace the donors with 0
	ldh [$FFEA], a
	push af
	push af ;push two because we shifted two, jump
	jr .scaleBits
	
.checkFourth
	ldh a, [$FFE9]
	or a
	jr z, .zeroVal ;if entire value zero, jump ahead
	ldh [$FFEC], a ;move this up three
	ld b, $F9
	xor a
	ldh [$FFE9], a ;clear these out
	ldh [$FFEA], a
	ldh [$FFEB], a
	push af
	push af
	push af ;push three because we shifted three, jump
	jr .scaleBits
.zeroVal
	xor a
	ldh [$FFE9], a ;scaled the value too far away! all zero, return
	ldh [$FFEA], a
	ldh [$FFEB], a
	ldh [$FFEC], a
.ret ;64D0
	ret
	
.scaleBits 
	;jumped to with pushes equal to how many bytes were shifted up, among E9/EA/EB/EC
	;B is $11 minus multiples of 8, for how many bytes shifted?
	ldh a, [$FFE8] ;high scalar
	or a
	jr nz, .HighValue ;if it has values, use them
	ldh a, [$FFE7]
	ldh [$FFE8], a ;otherwise move low bits up and add eight to processing?
	xor a
	ldh [$FFE7], a ;if E8 is zero, shift E7 into it
	ld a, b
	add a, $08
	ld b, a ;and add eight bits to process?
	bit 7, b
	jr z, .startProcessing ;if not overflowed, process
	jp .end ;else we're done scaling!
.HighValue
	xor a
	push af ;push a zero to push result up a byte
	bit 7, b
	jp nz, .end ;if overflowed, end
.startProcessing
	ld c, $80 ;bit carrier/flag?
	ld d, $00 ;holds carry outs from the scaling
.shiftScalerUp
	ldh a, [$FFEC]
	ld e, a ;top value byte in E
	ldh a, [$FFE8]
	cp $80
	jr nc, .loop ;if E8 (scaler) negative, start
	cp e
	jr nc, .loop ;if E8 >= EC, start
	srl c
	ldh a, [$FFE7]
	sla a
	ldh [$FFE7], a
	ldh a, [$FFE8]
	rla
	ldh [$FFE8], a ;else multiply scaler by two, rotate C flag down?
	inc b
	jr .shiftScalerUp ;increment b and try again?
.loop
	ldh a, [$FFE8]
	ld h, a
	ldh a, [$FFE7]
	ld l, a ;scalar in HL
	ldh a, [$FFEB]
	sbc a, l
	ld l, a
	ldh a, [$FFEC]
	sbc a, h
	ld h, a ;hl = EB/EC - E7/E8, aka value - scaler
	jr nc, .saveVal ;if result is positive (scalar < value), jump
	ld a, d
	or a ;clear carry
	jr z, .updateFlag ;if d (remainder) = 0, jump; else, set d to 0 and save hl back
	ld d, $00
.saveVal
	ld a, l
	ldh [$FFEB], a
	ld a, h
	ldh [$FFEC], a ;save the difference to hi value
	scf ;set carry
.updateFlag
	rl c ;shift C to the right (bring in bit signalling if the subtract worked or not)
	jr nc, .shiftVal
	ld a, c
	push af ;if the bit overflowed, save the new C
	ld c, $01 ;and start with a new C
.shiftVal
	dec b
	jr z, .end ;if we've run out of bits to scale by, finish
	ld hl, $FFE9
	sla [hl]
	inc l
	rl [hl]
	inc l
	rl [hl]
	inc l
	rl [hl] ;else divide the value by two
	rl d ;and collect results in D
	jr .loop
.end ;6549?
	pop af
	ldh [$FFE9], a ;zeroes or C's pushed now get assigned to value results
	pop af
	ldh [$FFEA], a
	pop af
	ldh [$FFEB], a
	pop af
	ldh [$FFEC], a
	ret
	
EntityLogicSprog1: ;6556
	ld a, l
	add a, $06
	ld e, a
	ld a, h
	adc a, $00
	ld d, a ;x rotation
	ld a, [de]
	or a
	jp z, CallEntityLogicToughEnemy
	add a, $04
	ld [de], a ;spin
	ld bc, $0000
	ld a, $1E
	call CallMoveEntityBySpecifiedAmts
	ret

BarOutScreen: ;656F
	ld a, $CC
	ld h, $D0
	ld b, $10
.outerloop
	ld c, $58
	ld l, $00
.innerloop
	ld [hl+], a
	rrca
	cpl
	dec c
	jr nz, .innerloop
	inc h
	dec b
	jr nz, .outerloop
	ret
	
IF UNUSED == 1
LoadAuxGUIOLD: ;6584
	ld hl, ScientistCargoGFX
	ld de, VRAM_Begin
	ld bc, $0080
.loop
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ld de, $8AA0 ;destination address
	call CallLoadSegmentNumbers
	ld a, $03
	ld [$CB14], a
	ret
	
DrawHealthOLD: ;65A1
	ld hl, wOAMStart
	ld a, [wHealth]
	ld c, a ;for how many health we have
	cp $05
	jr c, .initDraw
	ld c, $05 ;draw at most five
.initDraw ;2
	or a
	jr z, .doneDrawing ;if none, skip
	ld b, $80 ;start Y
	ld e, $84 ;start X
.drawSegment ;CF
	ld a, b
	ld [hl+], a ;write Y
	ld a, e
	ld [hl+], a ;write X
	ld a, $04
	ld [hl+], a ;tile
	xor a
	ld [hl+], a ;no attributes
	ld a, b
	ld [hl+], a ;write Y
	add a, $08
	ld b, a ;third will be +8
	ld a, e
	add a, $08
	ld [hl+], a ;write x + 8
	ld a, $06
	ld [hl+], a ;tile 6
	xor a
	ld [hl+], a ;no attributes
	ld a, b
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, $05
	ld [hl+], a ;tile 5
	xor a
	ld [hl+], a
	ld a, b
	ld [hl+], a
	sub $10
	ld b, a
	ld a, e
	add a, $08
	ld [hl+], a
	ld a, $07
	ld [hl+], a ;tile 7
	xor a
	ld [hl+], a
	dec c
	jr nz, .drawSegment
.doneDrawing ;35
	ld a, [wHealth]
	cpl
	add a, $06
	jr z, .done
	rlca
	rlca
	ld c, a
	xor a
.blankLoop
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a ;blank out the ones we didn't write to
	dec c
	jr nz, .blankLoop
.done ;b
	ret
ENDC

LoadShopkeepFrame: ;65FA, passed A is a multiple of $08, range is $00 to $38
	ld d, $DC
	ld hl, FvargGFX
	and $38 ;make sure the passed value is valid
	rrca
	rrca
	rrca ;divide by 8, so it's now 0 - 7
	add a, h
	ld h, a ;HL os now $70F0 + $100 * frame
	push hl
	inc hl
	ld c, $04
.wramloopouter
	ld b, $20
	ld e, $38 ;starting at DC38?
.wramloopinner 
	ld a, [hl+]
	ld [de], a
	inc hl
	inc e
	dec b
	jr nz, .wramloopinner
	inc d
	dec c
	jr nz, .wramloopouter
	pop hl
	ld de, $95B0 ;tile data
	ld c, $04
.outerloop
	ld b, $20
.statloop
	ldh a, [rSTAT]
	and $02
	jr nz, .statloop
	ld a, [hl+]
	ld [de], a ;save to tile data
	inc hl
	inc de
	inc de
	dec b
	jr nz, .statloop
	ld a, e
	add a, $70
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec c
	jr nz, .outerloop
	ret
	
EntityLogicBlackBox: ;663B
	ld a, [wEntityCollided]
	or a
	jr z, .ret
	ld a, [wHasCargo]
	or a
	jr nz, .ret
	dec hl
	ld [hl], $00
	ld a, CARGO_BOX
	ld [wHasCargo], a
	xor a
	ld [wCollisionType], a ;wipe when collecting it
.ret
	ret
	
EntityLogicSuperGun: ;6654
	xor a
	ld [$CB05], a
	ld a, [wCrosshairTargetEntityLo]
	cp l
	ret nz
	ld a, [wCrosshairTargetEntityHi]
	cp h
	ret nz ;do nothing if crosshair isn't over this entity
	ld a, [$C2AD]
	or a
	ret z ;return if zero [thing] left
	ldh a, [$FFDC]
	cp $03
	ret nc ;really don't know what these are about
	ld a, $01
	ld [$CB05], a ;otherwise set it
	ret

IF UNUSED == 1
ScientistCargoGFX: ;6672
	INCBIN "build/gfx/CargoScientist.2bpp"
BlackBoxCargoGFX: ;66B2
	INCBIN "build/gfx/CargoBlackBox.2bpp"
NoHelpTextLine1: ;66F2
	db "NO HELP", 00
NoHelpTextLine2: ;66FA
	db "AVAILABLE", 00
NoHelpTextLine3: ;6704
	db "FOR THIS", 00
NoHelpTextLine4: ;670D
	db "MISSION", 00
	db 00
MissionHelpTilemap: ;6716, tileset!
	db $14, $12 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 
	db $01, $02, $02, $02, $02, $03, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $05, $06 
	db $01, $07, $07, $07, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $0B, $0C, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $0D, $0E, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $0F, $10, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $11, $12, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $13, $14, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $15, $16, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $17, $18, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $19, $1A, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $1B, $1C, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $1D, $1E, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $1F, $20, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $21, $22, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $23, $24, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $25, $26, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $01, $07, $07, $07, $07, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $0A 
	db $27, $28, $28, $28, $28, $29, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2A, $2B, $0A 
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;6880
	INCBIN "build/gfx/MissionHelp.rle"
	
MissionHelpTable: ;6AAF, mission help table
	dw Mission1Help 
	dw Mission2Help 
	dw Mission3Help 
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw BLANK_POINTER
	dw Mission15Help 
	
Mission1Help: ;6ACD
	db " ", 00
	db "HELP", 00
	db " ", 00
	db "THE CRYSTAL IS", 00
	db "LOCATED TO THE", 00
	db "NORTHEAST FROM", 00
	db "THE BASE      ", 00
	db 00
	
Mission2Help: ;6B13
	db " ", 00
	db "HELP", 00
	db " ", 00
	db "FOLLOW THE    ", 00
	db "DIRECTION OF  ", 00
	db "THE TANKS BACK", 00
	db "TO THEIR BASE ", 00
	db "AND DESTROY IT", 00
	db 00
	
Mission3Help: ;6B68
	db " ", 00
	db "HELP", 00
	db " ", 00
	db "THE GUN FIRES ", 00
	db "MISSILES THAT ", 00
	db "TRACK YOU     ", 00
	db " ", 00
	db "FLY BACKWARDS ", 00
	db "AND SHOOT THEM", 00
	db 00
	
Mission15Help: ;6BBF
	db " ", 00
	db "HELP", 00
	db " ", 00
	db " ", 00
	db "YOU ARE ON", 00
	db "YOUR OWN FOR", 00
	db "THIS ONE", 00
	db " ", 00
	db "GOOD LUCK", 00
	db 00
	

MissionOneReportText: ;6BF8
	db " ", 00
	db "MISSION ONE", 00
	db " ", 00, " ", 00, " ", 00, " ", 00, " ", 00
	db "COLLECT", 00
	db " ", 00
	db "ONE CRYSTAL", 00
	db 00
MissionTwoReportText: ;6C27
	db " ", 00
	db "MISSION TWO", 00
	db " ", 00, " ", 00, " ", 00
	db "DESTROY FIVE", 00
	db "TIME BOMBS", 00
	db 00
MissionThreeReportText: ;6C54
	db " ", 0
	db "MISSION THREE", 00
	db " ", 00, " ", 00
	db "DESTROY THE", 00
	db "HEAVY TANK", 00
	db 00
MissionFourReportText: ;6C80
	db " ", 00
	db "MISSION FOUR", 00
	db " ", 00, " ", 00
	db "FIND OUR", 00
	db "SCIENTIST", 00
	db 00
MissionFiveReportText: ;6CA7
	db " ", 00
	db "MISSION FIVE", 00
	db " ", 00, " ", 00, " ", 00
	db "DESTROY THE", 00
	db "ENEMY TUNNEL", 00
	db 00
MissionSixReportText: ;6CD6
	db " ", 00
	db "MISSION SIX", 00
	db " ", 00, " ", 00, " ", 00
	db "ESCORT THE", 00
	db "CONVOY OF TRUCKS", 00
	db 00
MissionSevenReportText: ;6D07
	db " ", 00
	db "MISSION SEVEN", 00
	db " ", 00, " ", 00
	db "DESTROY THE FOUR", 00
	db "GLIDERS AND", 00
	db "COLLECT THE", 00
	db "REACTOR RODS", 00
	db 00
MissionEightReportText: ;6D52
	db " ", 00
	db "MISSION EIGHT", 00
	db " ", 00, " ", 00
	db "DESTROY THE LARVA", 00
	db 00
MissionNineReportText: ;6D79
	db " ", 00
	db "MISSION NINE", 00
	db " ", 00, " ", 00
	db "DESTROY THE CRUISE", 00
	db "MISSILE THAT IS", 00
	db "HEADING FOR THE", 00
	db "SILO", 00
	db 00
MissionTenReportText: ;6DC5
	db " ", 00
	db "MISSION TEN", 00
	db " ", 00, " ", 00
	db "DESTROY THE BIG", 00
	db "ALIEN BASE", 00
	db 00
MissionElevenReportText: ;6DF3
	db " ", 00
	db "MISSION ELEVEN", 00
	db " ", 00, " ", 00
	db "REPORT            ", 00
	db "MINE FIELD SIGHTED", 00
	db "FRIENDLY CRAFT    ", 00
	db "STRANDED WITHIN   ", 00
	db " ", 00, " ", 00
	db "OBJECTIVES        ", 00
	db "COLLECT PERSONNEL ", 00
	db "FROM STRANDED     ", 00
	db "CRAFT AND RETURN  ", 00
	db "TO BASE           ", 00
	db 00
MissionTwelveReportText: ;6EB8
	db " ", 00
	db "MISSION TWELVE", 00
	db " ", 00, " ", 00
	db "TRAINING MODE", 00
	db 00
MissionThirteenReportText: ;6EDC
	db " ", 00
	db "MISSION THIRTEEN", 00
	db " ", 00, " ", 00
	db "REPORT            ", 00
	db "MINES BECOMING A  ", 00
	db "MAJOR HAZARD      ", 00
	db " ", 00, " ", 00
	db "OBJECTIVES        ", 00
	db "DETONATE ALL MINES", 00
	db "WITH TIME BOMBS OR", 00
	db "SIMILAR HIGH EX   ", 00
	db "AND RETURN TO BASE", 00
	db 00
MissionFourteenReportText: ;6F90
	db " ", 00
	db "MISSION FOURTEEN", 00
	db " ", 00, " ", 00
	db "REPORT            ", 00
	db "MAJOR CLUSTER OF  ", 00
	db "ENEMY BASES       ", 00
	db "SIGHTED EASTWARDS ", 00
	db " ", 00
	db "EXTREME CAUTION", 00
	db " ", 00
	db "OBJECTIVES        ", 00
	db "SEEK AND DESTROY  ", 00
	db "AND RETURN TO BASE", 00
	db 00
MissionFifteenReportText: ;7041
	db " ", 00
	db "MISSION FIFTEEN", 00
	db " ", 00, " ", 00
	db "REPORT            ", 00
	db "FORMATION OF ENEMY", 00
	db "FORCES SIGHTED TO ", 00
	db "THE NORTH         ", 00
	db " ", 00
	db "EXTREME DANGER", 00
	db " ", 00
	db "OBJECTIVES        ", 00
	db "DESTROY ALL ENEMY ", 00
	db "AND RETURN TO BASE", 00
	db 00

FvargGFX: ;70F0
	INCBIN "build/gfx/Fvarg.2bpp"
ELSE
MissionOneReportText EQU BLANK_POINTER
MissionTwoReportText EQU BLANK_POINTER
MissionThreeReportText EQU BLANK_POINTER
MissionFourReportText EQU BLANK_POINTER
MissionFiveReportText EQU BLANK_POINTER
MissionSixReportText EQU BLANK_POINTER
MissionSevenReportText EQU BLANK_POINTER
MissionEightReportText EQU BLANK_POINTER
MissionNineReportText EQU BLANK_POINTER
MissionTenReportText EQU BLANK_POINTER
MissionElevenReportText EQU BLANK_POINTER
MissionTwelveReportText EQU BLANK_POINTER
ENDC
;0x78F0: overwritten darker version of...

;0x7A78-0x7D58: end of level text + stars?