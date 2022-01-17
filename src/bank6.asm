SECTION "6:TOP", ROMX[$4000], BANK[6]
LevelTimeLimits: ;4000
dw $003C 
dw $0046 
dw $0000 
dw $003C 
dw $0000 
dw $0032 
dw $0032 
dw $000F 
dw $3710 
dw $001E 
dw $0000 
dw $0000

SetLevelTimer: ;4018
	ld a, [wCurLevel]
	rrca
	and $FE ;turn level into word offset
	add a, LOW(LevelTimeLimits)
	ld l, a
	ld a, HIGH(LevelTimeLimits) ;4000 is a table, nice
	adc a, $00
	ld h, a
	ld a, [hl+] ;first byte into C313
	ld [wTimerFramesHi], a
	ld c, a
	ld a, [hl+]
	ld [wTimerFramesLo], a ;second byte into C312
	or c
	ld a, $01
	jr nz, .settime
	ld a, $00
.settime
	ld [wTimerEnableFlag], a ;1 written if pointer had a value, 0 if not
	ret
	
Level1ProgressFunc: ;403A
	call CallCheckGameOverCondition
	ld a, [wHasCargo]
	cp CARGO_CRYSTAL
	jr nz, .nocrystal
	scf
	ret
.nocrystal ;2
	xor a
	ret
	
LeftCountTextPointers: ;4048, pointers
	dw Left1Text
	dw Left2Text
	dw Left3Text
	dw Left4Text
	dw Left5Text
	dw Left6Text
	dw Left7Text
PrintHowManyLeft: ;4056
	dec a
	sla a ;use as pointer
	add a, LOW(LeftCountTextPointers)
	ld l, a
	ld a, HIGH(LeftCountTextPointers)
	adc a, $00
	ld h, a ;that's a pointer table
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $32
	call CallTryWriteScreenText
	ret

Level2ProgressFunc: ;406A
	call CallCheckGameOverCondition
	ld a, [$C2C8] ;?
	ld c, a
	ld a, [$CB02] ;bomb counter
	cp c
	jr z, .return ;if equal, jump
	jr nc, .return ;if bomb counter greater than UNK, jump
	or a
	jr nz, .bombsleft ;if bombs left, jump
	call ClearAllScreenText
	ld hl, Level2NoBombsText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, Level2NoBombsText2
	ld c, $32
	call CallTryWriteScreenText
	ld a, [$CB02] ;bomb counter
	jr .return
.bombsleft ;18, bombs left
	push af
	ld hl, Level2BlankTXT
	ld c, $32
	call CallTryWriteScreenText
	pop af
	call PrintHowManyLeft
	ld a, [$CB02] ;bomb counter
.return ;2D, 2B, 10
	ld [$C2C8], a
	cp $01
	ret nc ;if bombs left, return with zero
	call CallTriggerMissionComplete
	scf ;else set carry!
	ret
	
Level3ProgressFunc: ;40AF
	ld a, [wMissionBasesLeft] ;bases left
	ld [$C2C8], a
	or a
	jp nz, .checkhumankills
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	push hl
	call CallWriteTimeOverTexts
	pop hl
	ld a, $19
	ld [wGameOverTimer], a
	ret
.checkhumankills ;40CE
	ld a, [$C2C9]
	ld c, a ;old in C
	ld a, [$CB03]
	ld [$C2C9], a
	or a ;new in a
	jr z, .secondkilled ;if new is zero, jump
	cp c ;new minus old
	ret nc ;if equal, return
	;if old is more, 
	call ClearAllScreenText
	ld hl, PenHumanTankDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, PenHumanTankDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	ld hl, PenHumanTankDestroyedText3
	ld c, $32
	call CallTryWriteScreenText
	ret
.secondkilled ;1E
	ld a, [wLevelClearCountdown]
	or a
	jr nz, .complete
	call ClearAllScreenText
	ld hl, HumanoidTankDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, HumanoidTankDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
.complete ;13
	call CallTriggerMissionComplete
	scf
	ret

Level6ProgressFunc: ;4117
	call CallCheckGameOverCondition
	ld a, [$C2C8] ;bases left
	ld c, a
	ld a, [$CB0B]
	ld [$C2C8], a ;bases left
	cp c
	jr nc, .ret ;if no change, just return
	call ClearAllScreenText
	ld hl, Level6TruckDestroyedText
	ld c, $32
	call CallTryWriteScreenText
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	ld hl, Level6BlankText
	ld c, $32
	call CallTryWriteScreenText
	ld a, $19
	ld [wGameOverTimer], a
.ret
	and a
	ret
	
	
Level7ProgressFunc: ;414B
	call CallCheckGameOverCondition
	ld a, [$C2C2]
	cp $04
	ld a, $18 ;silo?
	jr nc, .setGoal ;if four enemies have been killed, change target to $18
	ld a, [$CB01] ;?
	or a
	ld a, $07 ;glider?
	jr z, .setGoal
	ld a, $10 ;antenna?
.setGoal ;A, 2
	ld [wGoalEntityID], a ;load with $18, $07, or $10
	and a
	ret

Level4ProgressFunc: ;4166
	call CallCheckGameOverCondition
	ld a, [$CB13] ;?
	or a
	jr z, .targetbuilding
	ld a, $11 ;scientist
	ld [wGoalEntityID], a
	ret
.targetbuilding ;6
	ld a, $1A ;shack
	ld [wGoalEntityID], a
	ld a, [wHasCargo]
	cp CARGO_SCIENTIST ;cargo ID for scientist
	jr nz, .done
	ld a, $18 ;silo
	ld [wGoalEntityID], a
.done ;5
	and a
	ret

Level8ProgressFunc: ;4188
	ld hl, wTimerFrames
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr nz, .checkbutts ;if there's yet time, jump
	;else
	ld a, $44 ;butterfly model
	ld [wGoalEntityID], a
	xor a
	ld [wTimerEnableFlag], a ;disable timer
.checkbutts
	ld a, [$C2C9]
	ld c, a
	ld a, [$CB0D]
	ld [$C2C9], a ;humantanks backup?
	or a
	jr nz, .hasbutterflies
	;all tanks destroyed!
	ld a, [$CB0E] ;?
	or a
	jr nz, .hasbutterflies
	ld hl, AllButterfliesDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, AllButterfliesDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	call CallTriggerMissionComplete
	ret
.hasbutterflies
	cp c
	jr nc, .checkbases
	call CallPrintHowManyLeft
	ret
.checkbases
	ld a, [$C2C8] ;bases backup
	ld c, a
	ld a, [wMissionBasesLeft]
	cp c
	jr z, .savebases
	jr nc, .savebases
	or a
	jr nz, .getold 
;else, mission loss
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, TRACK_ALARM
	ld [wQueueMusic], a
	push hl
	call CallWriteTimeOverTexts
	pop hl
	ld a, $19
	ld [wGameOverTimer], a
	ret
.getold ;15
	ld a, [wMissionBasesLeft]
.savebases ;1D, 1B
	ld [$C2C8], a ;bases backup
	ret

Level9ProgressFunc: ;41F3
	ld a, [$CB0F]
	or a
	jr nz, .checkmissile
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, $05
	ld [$C108], a
	call CallWriteTimeOverTexts
	ld a, $19
	ld [wGameOverTimer], a
	ret
.checkmissile ;13
	ld a, [$C2C9]
	ld c, a
	ld a, [$CAFE]
	ld [$C2C9], a
	or a
	jr z, .missiledestroyed
	cp c
	ret nc
	call CallPrintHowManyLeft
	ret
.missiledestroyed
	ld hl, CruiseMissileDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, CruiseMissileDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	call CallTriggerMissionComplete
	ret

Level5ProgressFunc: ;4233
	ld a, [$C2C8]
	ld c, a
	ld a, [$CAFA]
	ld [$C2C8], a
	cp c
	jp nc, .firstdestroyed ;jump if none destroyed
	or a
	jp z, .firstdestroyed ;jump if last destroyed
	call ClearAllScreenText
	ld hl, OneAlienTunnelLeftText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, OneAlienTunnelLeftText2
	ld c, $32
	call CallTryWriteScreenText
	ld hl, OneAlienTunnelLeftText3
	ld c, $32
	call CallTryWriteScreenText
	ret
.firstdestroyed ;4261
	or a
	ret nz ;return if bases left
	ld hl, AlienTunnelDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, AlienTunnelDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	call CallTriggerMissionComplete
	ret

Level10ProgressFunc: ;4277
	call CallCheckGameOverCondition
	ld a, [$C2CB]
	ld c, a
	ld a, [$CB12]
	ld [$C2CB], a
	cp c
	jr nc, .checkTunnels
	ld hl, JunctionDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, JunctionDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
.checkTunnels
	ld a, [$C2CA]
	ld c, a
	ld a, [$CB11]
	ld [$C2CA], a
	cp c
	jr nc, .checkMothership
	ld hl, TunnelEntranceDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, TunnelEntranceDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
.checkMothership
	ld a, [$CB0A]
	ld [$C2C8], a
	ld a, [$CAF9]
	or a
	ret nz
	ld hl, MothershipDestroyedText1
	ld c, $32
	call CallTryWriteScreenText
	ld hl, MothershipDestroyedText2
	ld c, $32
	call CallTryWriteScreenText
	ld a, [wGameOverTimer]
	or a
	ret nz
	ld a, [wLevelClearCountdown]
	or a
	ret nz
	call CallTriggerMissionComplete
	ld hl, MissionCompleteText
	ld c, $32
	call CallTryWriteScreenText
	di
	call CallTriggerMissionComplete
	xor a
	ld [wTimerEnableFlag], a ;disable timer
	ld a, $1D
	ld [wQueueMusic], a
	ei
	ret

LevelEscapeProgressFunc: ;42F3
	ret
LevelTutorialProgressFunc: ;42F4
	ret
;42F5

SECTION "6:4400", ROMX[$4400], BANK[6]
SFX_Queue_Table: ;4400: $21 pointers - pointers for queued SFX
	dw SFX_OptionChange.play
	dw SFX_OptionSelect.play
	dw SFX_GearShift.play 
	dw SFX_unk4.play
	dw SFX_ValidLockTarget.play 
	dw SFX_Bump.play
	dw SFX_Bump.play2
	dw SFX_ShieldPickup.play ;8
	dw SFX_FuelPickup.play 
	dw SFX_PlayerLazer.play 
	dw SFX_QuadLazer.play 
	dw SFX_QuadLazer.play2
	dw SFX_Plasma.play
	dw SFX_Plasma.play
	dw SFX_TargetLocated.play
	dw SFX_DeflectedBeam.play ;10
	dw SFX_GliderDeploy.play
	dw SFX_ItemCollected.play 
	dw SFX_unk13.play
	dw SFX_unk13.play2
	dw SFX_unk15.play
	dw SFX_OptionChange.play
	dw SFX_unk17.play 
	dw SFX_unk18.play ;18
	dw SFX_unk19.play 
	dw SFX_unk19.play2
	dw SFX_unk19.play3 
	dw SFX_unk19.play4
	dw SFX_unk1D.play 
	dw SFX_unk1D.play2
	dw SFX_unk1D.play3
	dw SFX_unk1D.play4 ;20
	dw SFX_unk13.play3

SFX_Playing_Table: ;4442: $21 pointers - pointers for playing SFX
	dw SFX_GenericContinueShort
	dw SFX_OptionSelect.continue 
	dw SFX_GenericContinueShort
	dw SFX_unk4.continue
	dw SFX_GenericContinueShort
	dw SFX_GenericContinueShort
	dw SFX_GenericContinueShort
	dw SFX_ShieldPickup.continue ;8
	dw SFX_FuelPickup.continue
	dw SFX_PlayerLazer.continue 
	dw SFX_QuadLazer.continue 
	dw SFX_GenericContinueShort
	dw SFX_Plasma.continue
	dw SFX_Plasma.continue
	dw SFX_TargetLocated.continue 
	dw SFX_DeflectedBeam.continue ;10
	dw SFX_GliderDeploy.continue
	dw SFX_ItemCollected.continue 
	dw SFX_unk13.continue
	dw SFX_unk13.continue
	dw SFX_unk15.continue
	dw SFX_GenericContinueShort
	dw SFX_unk17.continue
	dw SFX_unk17.continue ;18
	dw SFX_unk19.continue 
	dw SFX_unk19.continue
	dw SFX_unk19.continue
	dw SFX_unk19.continue
	dw SFX_unk1D.continue
	dw SFX_unk1D.continue 
	dw SFX_unk1D.continue 
	dw SFX_unk1D.continue ;20
	dw SFX_unk13.continue

Noise_Queue_Table: ;4484: $1D pointers - pointers for queued noise
	dw Noise_unk1.play
	dw Noise_Explode.play
	dw Noise_EnemyDamage.play
	dw Noise_Liftoff.play
	dw Noise_MissileShot.play
	dw Noise_HighEx.play
	dw Noise_unk7.play
	dw Noise_Turbo.play
	dw Noise_BaseEnter.play
	dw Removed_Noise_unka.play
	dw Noise_FormingEnt.play
	dw Noise_unkC.play
	dw Noise_Drake.play 
	dw Noise_Drake.play2 
	dw Noise_Drake.play3 
	dw Noise_Drake.play4
	dw Noise_TankSteps.play
	dw Noise_TankSteps.play2
	dw Noise_TankSteps.play3
	dw Noise_TankSteps.play4
	dw Noise_unkC.play
	dw Noise_unkC.play2
	dw Noise_unkC.play3
	dw Noise_unkC.play4
	dw Removed_Noise_unk19.play
	dw Removed_Noise_unk19.play 
	dw Removed_Noise_unk19.play 
	dw Removed_Noise_unk19.play
	dw Noise_Splash.play

Noise_Playing_Table: ;44BE: $1D pointers - pointers for playing noise
	dw Noise_unk1.continue
	dw Noise_Explode.continue
	dw Noise_EnemyDamage.continue 
	dw Noise_Liftoff.continue
	dw Noise_MissileShot.continue 
	dw Noise_MissileShot.continue 
	dw Noise_MissileShot.continue  
	dw Noise_Turbo.continue 
	dw Noise_BaseEnter.continue
	dw Removed_Noise_unka.continue 
	dw Noise_FormingEnt.continue
	dw Noise_unkC.continue
	dw Noise_Drake.continue
	dw Noise_Drake.continue 
	dw Noise_Drake.continue 
	dw Noise_Drake.continue 
	dw Noise_TankSteps.continue1
	dw Noise_TankSteps.continue2 
	dw Noise_TankSteps.continue2 
	dw Noise_TankSteps.continue2 
	dw Noise_unkC.continue
	dw Noise_unkC.continue
	dw Noise_unkC.continue 
	dw Noise_unkC.continue
	dw Removed_Noise_unk19.continue
	dw Removed_Noise_unk19.continue
	dw Removed_Noise_unk19.continue 
	dw Removed_Noise_unk19.continue
	dw Noise_Splash.continue

Track_Data_Table: ;44F8, $28 pointers - track data pointers
	dw Track_TitleScreen
	dw Track_Urgent
	dw Track_FinalMission
	dw Track_Results
	dw Track_Alarm
	dw Track_Base
	dw Track_07
	dw Track_Death ;8 
	dw Track_Scientist
	dw Track_Ambient1WithIntro 
	dw Track_Ambient1 
	dw Track_Ambient2
	dw Track_Ambient3
	dw Track_Presents 
	dw Track_Training
	dw Track_Ambient3WithIntro ;10
	dw Track_Imposter 
	dw Track_Tunnel
	dw Track_Ambient2WithIntro
	dw Track_Recap
	dw Track_MissionComplete
	dw Track_ItemReveal
	dw Track_Boss
	dw Track_SiloInterior ;18
	dw Track_Encounter 
	dw Track_Ambient4WithIntro
	dw Track_Ambient4 
	dw Track_Eerie
	dw Track_Fanfare
	dw Track_Credits
	dw Track_TunnelTraining 
	dw Track_LevelIntro ;$5C12 ;20 
	dw Track_LevelIntro 
	dw Track_BriefingIntro
	dw Track_Shanty
	dw Track_Ambient5WithIntro
	dw Track_Ambient5 
	dw Track_PlaceCrystal
	dw Track_07WithIntro
	dw Track_Training2

CheckSFXPriority1: ;4548
	ld a, [wCurrentSFX] ;currently playing SFX
	cp $09 ;fuel
	ret z
	cp $10 ;deflect
	ret z
	cp $11 ;glider deploy
	ret z
	cp $12 ;collectable pickup
	ret
CheckSFXPriority2: ;4557
	ld a, [wCurrentSFX]
	cp $0F ;radar
	ret z
	cp $06 ;bump
	ret z
	cp $07 ;bump 2
	ret z
	cp $0B ;quad
	ret z
	cp $0C ;meson
	ret

SFX_unk1D:
.regs1 ;4569
	db $77, $80, $20, $10, $86
.regs2 ;456E
	db $77, $80, $30, $11, $86
.regs3 ;4573
	db $77, $80, $50, $12, $86
.regs4 ;4578
	db $77, $80, $60, $13, $86
.regsend ;457D
	db $7F, $80, $10, $E3, $86
.play ;4582
	ld hl, .regs1
.merge
	call CheckSFXPriority1
	ret z
	ld a, $18
	jp StartSFX
.play2 ;458E
	ld hl, .regs2
	jr .merge
.play3 ;4893
	ld hl, .regs3
	jr .merge
.play4 ;4898
	ld hl, .regs4
	jr .merge
.continue ;459D
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld a, [hl]
	inc [hl]
	cp $01
	jp z, Ch1Reset
	ld hl, .regsend
	jp LoadChannelRegisters
	
SFX_unk19:
.regs1 ;45B2
	db $3C, $EB, $20, $70, $C7
.regs2 ;45B7
	db $3C, $EB, $30, $70, $C7
.regs3 ;45BC
	db $3C, $EB, $50, $70, $C7
.regs4 ;45C1
	db $3C, $EB, $70, $70, $C7
.regsend ;45C6
	db $3C, $EB, $10, $6E, $C7
.play ;45CB
	ld hl, .regs1
.merge
	call CheckSFXPriority1
	ret z
	ld a, $06
	jp StartSFX
.play2 ;45D7
	ld hl, .regs2
	jr .merge
.play3 ;45DC
	ld hl, .regs3
	jr .merge
.play4 ;45E1
	ld hl, .regs4
	jr .merge
.continue ;45E6
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld a, [hl]
	inc [hl]
	cp $03
	jp z, Ch1Reset
	cp $01
	jr z, .pt2
	ret
.pt2 ;1
	ld hl, .regsend
	jp LoadChannelRegisters

SFX_unk18:
.regs ;4600
	db $00, $00, $E0, $E0, $87
.play ;4605
	ld a, $05
	ld hl, .regs
	jp StartSFX
	
SFX_unk17:
.regs
	db $4E, $80, $61, $D0, $86
.play ;4612
	ld a, $05
	ld hl, .regs
	jp StartSFX
.continue ;461A
	call SFX_Increment
	and a
	ret nz
	jp Ch1Reset
	
SFX_PlayerLazer:
.regs ;4622
	db $00, $00, $E0, $90, $87
.play ;4627
	call CheckSFXPriority1
	ret z
	ld a, $90
	ld [$C106], a
	ld a, $02
	ld hl, .regs
	jp StartSFX
.continue ;4638
	ld hl, $C104
	ld a, [hl]
	inc [hl]
	cp $22
	jp z, Ch1Reset
	cp $04
	jr nz, .pt2
	inc l
	inc [hl]
.pt2 ;2
	ld hl, $C106
	ld c, $29
	bit 0, a
	jr nz, .pt3
	ld c, $02
.pt3 ;2
	ld a, c
	add a, [hl]
	ldh [rNR13], a
	ld hl, $C105
	ld a, [hl]
	and a
	ret z
	ld [hl], $00
	ld a, $10
	ldh [rNR12], a
	ld a, $87
	ldh [rNR14], a
	ret
	
SFX_Plasma:
.regs1 ;4668
	db $2C, $80, $39, $A0, $87
.regs2
	db $BE, $80, $1F, $80, $87
.regs3 ;4672
	db $BE, $00, $1F, $D0, $87
.play ;4677
	ld a, $05
	ld hl, .regs1
	jp StartSFX
.continue ;467F
	ld hl, $C104
	ld a, [hl]
	ld c, a
	inc [hl]
	cp $05
	jr nz, .pt2
	inc l
	inc [hl]
	dec l
.pt2 ;3
	cp $18
	jp z, Ch1Reset
	inc l
	ld a, [hl]
	and a
	ret z
	ld hl, .regs2
	bit 0, c
	jr z, .end
	ld hl, .regs3
.end ;3
	jp LoadChannelRegisters

SFX_unk4:
.regs ;46A2
	db $00, $BD, $90, $BB, $C7
.play ;46A7
	call CheckSFXPriority1
	ret z
	ld a, $03
	ld hl, .regs
	jp StartSFX
.continue ;46B3
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	inc [hl]
	ld a, [hl]
	cp $02
	jp z, Ch1Reset
	ld hl, .regs
	jp LoadChannelRegisters
	
SFX_GearShift:
.regs ;46C8
	db $00, $BD, $A0, $70, $C7
.play ;46CD
	call CheckSFXPriority1
	ret z
	call CheckSFXPriority2
	ret z
	ld a, $02
	ld hl, .regs
	jp StartSFX

SFX_unk15:
.regs1
	db $00, $FC, $A2, $83, $C7
.regs2
	db $00, $FA, $E2, $C1, $C7
.play ;46E7
	ld a, $06
	ld hl, .regs2
	jp StartSFX
.continue ;46EF
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	inc [hl]
	ld a, [hl]
	cp $05
	jp z, Ch1Reset
	ld hl, .regs2
	and $01
	jp z, LoadChannelRegisters
	ld hl, .regs1
	jp LoadChannelRegisters

SFX_ShieldPickup:
.regs1 ;470c
	db $00, $80, $E1, $AC, $C7 
.regs2 ;4711
	db $00, $80, $E1, $B6, $C7 
.regs3 ;4716
	db $00, $80, $E1, $C8, $C7
.play ;471B
	ld a, $05
	ld hl, .regs1
	jp StartSFX
.continue ;4723
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	inc [hl]
	ld a, [hl]
	ld hl, .regs2
	cp $01
	jr z, .nextset
	ld hl, .regs3
	cp $02
	jr z, .nextset
	ld hl, .regs2
	cp $03
	jr z, .nextset
	cp $04
	jp z, Ch1Reset
	ret
.nextset
	jp LoadChannelRegisters

SFX_OptionSelect:
.regs1
	db $00, $80, $D0, $A9, $87
.regs2 ;4750, what uses this?
	db $00, $80, $30, $A9, $87
.play ;4755
	call CheckSFXPriority1
	ret z
	ld a, $04
	ld hl, .regs1
	jp StartSFX
.continue ;4761
	call SFX_Increment
	and a
	ret nz ;return if not done yet
	ld hl, $C104
	inc [hl]
	ld a, [hl]
	cp $02
	jr z, Ch1Reset
	ld hl, .regs2
	jp LoadChannelRegisters
	
SFX_ValidLockTarget:
.regs ;4775
	db $00, $BC, $E1, $D9, $C7
.play ;477A
	call CheckSFXPriority1
	ret z
	ld a, $03
	ld hl, .regs
	jp StartSFX

SFX_OptionChange:
.regs ;4786
	db $00, $BC, $E1, $E0, $C7
.play;478B
	call CheckSFXPriority1 ;check if certain sounds are playing
	ret z ;if they are, return
	ld a, $03
	ld hl, .regs
	jp StartSFX
;4797

SECTION "6:47A4", ROMX[$47A4], BANK[6]
SFX_GenericContinueShort: ;47A4
	call SFX_Increment
	and a
	ret nz ;return if not done yet, otherwise fall into
Ch1Reset: ;47A9, resets channel 1 stuff
	xor a
	ld [$C101], a
	ldh [rNR10], a ;sweep
	ld a, $08
	ldh [rNR12], a ;volume
	ld a, $80
	ldh [rNR14], a ;freq hi
	ld hl, $C0BF
	res 7, [hl]
	ret

SFX_QuadLazer:
.regs1 ;47BD
	db $9B, $80, $E0, $00, $C3
.regs2 ;47C2
	db $94, $80, $90, $80, $C1 
.regs3 ;47C7
	db $9B, $80, $60, $00, $C3 
.continue ;47CC
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld a, [hl]
	cp $02
	jp z, Ch1Reset
	inc [hl]
	ld hl, .regs2
	jp LoadChannelRegisters
.play ;47E1
	ld a, $05
	ld hl, .regs1
	jp StartSFX
.play2 ;47E9
	ld a, $04
	ld hl, .regs3
	jp StartSFX

SFX_Bump:
.regs1
	db $1C, $80, $F0, $34, $84 
.regs2
	db $1C, $80, $80, $FF, $C4
.play ;47FB
	ld a, $0F
	ld hl, .regs1
	jp StartSFX
.play2
	ld a, $06
	ld hl, .regs2
	jp StartSFX

SFX_DeflectedBeam:
.regs1
	db $00, $00, $E1, $A3, $87
.regs2
	db $00, $00, $10, $A3, $87
.play ;4815
	ld a, $0B
	ld hl, .regs1
	jp StartSFX
.continue ;481D
	call SFX_Increment
	and a
	ret nz
	ld hl, .regs2
	ld de, $C104
	ld a, [de]
	push af
	inc a
	ld [de], a
	pop af
	and a
	jr z, .done
	cp $01
	jp z, Ch1Reset
	ret
.done ;6
	jp LoadChannelRegisters
	
	
SFX_GliderDeploy:
.regs ;4839
	db $00, $3E,$E5, $06, $C7
.volume ;483E
	db $D5, $C5, $B5, $A5, $94, $85, $45, $35, $35, $37, $37, $27, $27, $27, $27, $27, $27, $17, $17, $17, 0
.play ;4853
	ld a, $04
	ld hl, .regs
	jp StartSFX
.continue ;485B
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	inc [hl]
	ld c, [hl]
	ld b, $00
	ld hl, .volume
	add hl, bc
	ld a, [hl]
	and a
	jp z, Ch1Reset
	ldh [rNR12], a
	ldh a, [rDIV]
	and $7F
	ldh [rNR13], a
	ld a, $C7
	ldh [rNR14], a
	ret

SFX_ItemCollected:
.regs ;487D
	db $00, $00, $F3, $90, $87
.freqs ;4882
	db $97, $AC, $BA, $90, $97, $AC, $BA, $90, $97, $AC, $BA, 0
.play ;488E
	ld a, $05
	ld hl, .regs
	jp StartSFX
.continue ;4896
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld c, [hl]
	ld a, c
	ld d, $66
	cp $03
	jr nc, .pt2
	ld d, $32
	cp $06
	jr nc, .pt2
	ld d, $E4
.pt2 ;8, 2
	ld a, d
	ldh [rNR12], a ;volume
	inc [hl]
	ld b, $00
	ld hl, .freqs
	add hl, bc
	ld a, [hl]
	and a
	jp z, Ch1Reset
	ldh [rNR13], a
	ld a, $87
	ldh [rNR14], a
	ret
	
LoadTwoSFXBytes: ;48C4
	ld c, LOW(rNR12)
	ld [c], a
	inc c
	inc c
	ld a, b
	ld [c], a
	ret
	
SFX_TargetLocated:
.regs ;48CC
	db $5B, $80, $84, $90, $87
.play ;48D1
	ld a, $03
	ld hl, .regs
	jp StartSFX
.continue ;48D9
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld c, [hl]
	inc [hl]
	ld b, $00
	jr SFX_FuelPickup.pt2
	
SFX_FuelPickup:
.regs1 ;48E7
	db $3D, $80, $F4, $B3, $87 
.regs2
	db $D2, $B2, $A2, $92, $82
;48F1 ???
	db $72, $62, $52, $43, $43, $33, $33, $23, $23, $23, $13, $13, 0
.play ;48FE
	ld a, $03
	ld hl, .regs1
	jp StartSFX
.continue ;4906	
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	ld c, [hl]
	inc [hl]
	ld b, $00
.pt2 ;4912
	ld hl, .regs2
	add hl, bc
	ld a, [hl]
	and a
	jp z, Ch1Reset
	ld b, $87
	jr LoadTwoSFXBytes ;to 48C4

SFX_unk13:
.regs1 ;491F
	db $00, $C0, $80, $90, $87
.regs2 ;4924
	db $00, $C0, $80, $A0, $87
.regs3 ;4929
	db $00, $C0, $80, $B0, $87
	
.play3 ;492E
	ld a, [.regs1 + 3]
	ld [$C106], a
	ld a, $05
	ld hl, .regs3
	jp StartSFX
	
.play ;493C
	ld a, [.regs1 + 3]
	ld [$C106], a
	ld a, $03
	ld hl, .regs2
	jp StartSFX
.play2 ;494A
	ld a, [.regs1 + 3]
	ld [$C106], a
	ld a, $02
	ld hl, .regs1
	jp StartSFX
.continue ;4958
	call SFX_Increment
	and a
	ret nz
	ld hl, $C104
	inc [hl]
	ld a, [hl]
	cp $12
	jp z, Ch1Reset
	cp $04
	jr nz, .pt2
	ld a, $20
	ldh [rNR12], a
	ld a, $87
	ldh [rNR14], a
.pt2
	ld a, [$C106]
	dec a
	dec a
	dec a
	ld [$C106], a
	ldh [rNR13], a
	ret

Ch2Reset: ;497F, resets channel 2 stuff
	ld a, $08
	ldh [rNR22], a ;ch 2 volume
	ld a, $80
	ldh [rNR24], a ;freq hi
	ld hl, $C0CF
	res 7, [hl]
	ret
	
CheckNoisePriority2: ;498D
	ld a, [wCurrentNoise]
	cp $06
	ret
	
CheckNoisePriority1: ;4993
	ld a, [wCurrentNoise]
	cp $1D
	ret
	
CheckNoisePriority3: ;4999
	ld a, [wCurrentNoise]
	cp $02
	ret z
	cp $03
	ret z
	cp $05
	ret z
	cp $06
	ret

Noise_Splash:
.regs1 ;49A8
	db $00, $57, $60, $80 
.regs2 ;49AC
	db $00, $87, $60, $80
.play ;49B0
	ld a, $0F
	ld hl, .regs1
	jp StartSFX
.continue ;49B8
	call SFX_Increment
	and a
	ret nz
	ld hl, $C11C
	ld a, [hl]
	inc [hl]
	cp $03
	jp z, Ch4Reset
	and a
	ret nz
	ld hl, .regs2
	jp LoadChannelRegisters.c4

Removed_Noise_unk19:
.play ;49CF
.continue
	ret

Noise_TankSteps:
.regs1 ;49D0
	db $00, $45, $65, $80 
.regs2 
	db $00, $65, $65, $80 
.regs3
	db $00, $95, $65, $80 
.regs4
	db $00, $E5, $65, $80 
.regs5 ;49E0
	db $00, $37, $46, $80
	
.play ;49E4
	ld hl, .regs1
.merge
	call CheckNoisePriority1
	ret z
	call CheckNoisePriority3
	ret z
	ld a, $09
	jp StartSFX
.play2 ;49F4
	ld hl, .regs2
	jr .merge
.play3 ;49F9
	ld hl, .regs3
	jr .merge
.play4 ;49FE
	ld hl, .regs4
	jr .merge
	
.continue1 ;4A03
	call SFX_Increment
	and a
	ret nz
	jp Ch4Reset
	
.continue2 ;4A0B
	call SFX_Increment
	and a
	ret nz
	ld hl, $C11C
	ld a, [hl]
	inc [hl]
	cp $01
	jp z, Ch4Reset
	ld hl, .regs5
	jp LoadChannelRegisters.c4

Noise_Drake:
.regs1 ;4A20
	db $00, $20, $3F, $80
.regs2;4A24
	db $00, $30, $3F, $80 
.regs3
	db $00, $50, $3F, $80 
.regs4
	db $00, $70, $3F, $80
	
.play ;4A30
	ld hl, .regs1
.merge
	call CheckNoisePriority1
	ret z
	call CheckNoisePriority3
	ret z
	ld a, $02
	jp StartSFX
	
.play2 ;4A40
	ld hl, .regs2
	jr .merge
.play3 ;4A45
	ld hl, .regs3
	jr .merge
.play4 ;4A4A
	ld hl, .regs4
	jr .merge

.continue ;4A4F
	call SFX_Increment
	and a
	ret nz
	ld hl, .poly
	call GetPolynomialOffset2
	jp z, Ch4Reset
	cp $FF
	jr z, .pt2
	ldh [$FF22], a
	ret
.pt2 ;3
	ld c, $21
	ld a, $10
	ld [c], a
	inc c
	ld a, $2F
	ld [c], a
	inc c
	ld a, $80
	ld [c], a
	ret
.poly ;4A72
	db $6B, $3D, $3C, $FF, $2E, $2D, $2C, $1F, $1E, $1D, $1C, $0F, $0E, 0

GetPolynomialOffset2: ;4A80
	push hl
	ld hl, $C11C
	ld a, [hl]
	ld c, a
	ld [$C11D], a
	inc [hl]
	ld b, $00
	pop hl
	add hl, bc
	ld a, [hl]
	and a
	ret

Noise_unkC:
.regs1 ;4A91
	db $E0, $1B, $01, $C0
.regs2 ;4A95
	db $E0, $1B, $02, $C0
.regs3 ;4A99
	db $E0, $2B, $01, $C0
.regs4 ;4A9D
	db $E0, $3A, $02, $C0
.regs5 ;4AA1
	db $E0, $3A, $02, $C0
.regstable ;4AA5, table
	dw .regs1 
	dw .regs2  
	dw .regs2 
	dw .regs2  
	dw .regs2 
	dw .regs3 
	dw .regs3  
	dw .regs4  
	dw .regs3 
	dw .regs3 
	dw .regs5 
	dw .regs4 

.polys ;4ABD	
	db $12, $13, $12, 0
	
.play2 ;4AC1
	ld a, $AB
	ld c, a
	ld a, $4A
	ld hl, .regs2
	jr .merge
.play3 ;4ACB
	ld a, $B1
	ld c, a
	ld a, $4A
	ld hl, .regs2
	jr .merge
.play4 ;4AD5
	ld a, $B7
	ld c, a
	ld a, $4A
	ld hl, .regs3
	jr .merge

.play ;4ADF
	ld a, LOW(.regstable)
	ld c, a
	ld a, HIGH(.regstable)
	ld hl, .regs1
.merge
	ld b, a
	call CheckNoisePriority1
	ret z
	call CheckNoisePriority3
	ret z
	ld a, b
	ld [$C11F], a
	ld a, c
	ld [$C11E], a
	ld a, $0E
	jp StartSFX
.continue ;4AFD
	call SFX_Increment
	and a
	ret nz
	ld hl, .polys
	call GetPolynomialOffset2
	jp z, Ch4Reset
	ld [$C11B], a
	ld hl, $C11D
	inc [hl]
	ld a, [hl]
	push af
	ld a, [$C11E]
	ld l, a
	ld a, [$C11F]
	ld h, a
	pop af
	call FetchPointedWord
	jp LoadChannelRegisters.c4

Noise_FormingEnt:
.poly ;4B23
	db $03, $05, $07, $15, $16, $17, $24, $25, $27, $FF, $35, $37, $44, $45, $46, 0
.regs ;4B33
	db $00, $40, $01, $80
.play ;4B37
	ld a, $02
	ld hl, .regs
	jp StartSFX
.continue ;4B3F
	call SFX_Increment
	and a
	ret nz
	ld hl, .poly
	call GetPolynomialOffset2
	jp z, Ch4Reset
	cp $FF
	jr z, .pt2
	ldh [rNR43], a
	ret
.pt2 ;3
	ld c, $21
	ld a, $D0
	ld [c], a
	inc c
	ld a, $34
	ld [c], a
	inc c
	ld a, $80
	ld [c], a
	ret

Noise_unk1:
.play ;4B62
.continue ;the same spot
	ret

Noise_Liftoff:
.regs1 ;4B63
	db $00, $1D, $35, $80
.regs2 ;4B67
	db $00, $30, $37, $80
.regs3 ;4B6B
	db $00, $10, $37, $80
.play ;4B6F
	call CheckNoisePriority1
	ret z
	ld a, $03
	ld hl, .regs1
	jp StartSFX
.continue ;4B7B
	call SFX_Increment
	and a
	ret nz
	ld hl, $C11C
	ld a, [hl]
	inc [hl]
	cp $06
	jr z, .pt2 
	cp $0E
	jr z, .pt3
	cp $25
	jp z, Ch4Reset
	ret
.pt2
	ld hl, .regs2
	jp LoadChannelRegisters.c4
.pt3
	ld hl, .regs3
	jp LoadChannelRegisters.c4

Noise_HighEx:
.poly ;4B9F
	db $65, $64, $65, $57, $56, $65, $FF, $45, $44, $45, $46, $46, $46, $45, $45, $44, $44, $37, $37, $37, $63, $63, $35, $27, $25, $FE, $26, $27, $27, $34, $35, $63, $37, $37, $37, $44, $44, $44, $44, $44, $44, $44, 0
.play ;4BCA
	ld a, LOW(.poly)
	ld [$C11E], a
	ld a, HIGH(.poly)
	ld [$C11F], a
	ld a, $05
	ld hl, Noise_MissileShot.regs1
	jp StartSFX

Noise_MissileShot:
.regs1 ;4BDC
	db $00, $F0, $63, $80
.regs2 ;4BE0
	db $00, $60, $37, $80
.poly ;4be4
	db $65, $64, $65, $57, $56, $65, $FF, $37, $63, $37, $44, $44, $44, $37, $37, $63, $63, $37, $37, $37, $35, $35, $34, $26, $24, $26, $26, $27, $27, 0
.play ;4C02
	ld a, LOW(.poly)
	ld [$C11E], a
	ld a, HIGH(.poly)
	ld [$C11F], a
	ld a, $02
	ld hl, .regs1
	jp StartSFX
.continue ;4C14
	call SFX_Increment
	and a
	ret nz
.tableloop ;C9
	ld hl, $C11C ;progress into table
	ld c, [hl]
	inc [hl]
	ld a, [$C11E]
	ld l, a
	ld a, [$C11F]
	ld h, a ;table pointer
	ld b, $00
	add hl, bc
	ld a, [hl]
	and a
	jp z, Ch4Reset
	cp $FF
	jr z, .pt2
	cp $FE
	jr z, .pt3
	ldh [rNR43], a ;position in Poly loaded into polynomial reg
	ld hl, $C11D
	ld a, [hl]
	and a
	ret z
	ld [hl], $00
	ld hl, .regs2
	jp LoadChannelRegisters.c4
.pt3 ;10
	ld a, $20
	ldh [rNR42], a
	ld a, $80
	ldh [rNR44], a
	jr .tableloop
.pt2 ;4C50
	ld hl, $C11D
	inc [hl]
	jr .tableloop

Noise_unk7:
.regs ;4C56
	db $00, $A0, $4E, $80
.poly ;4C5A
	db $4C, $3F, $6B, $3D, $3C, $FF, $2F, $2E, $2D, $2C, $1F, $1E, $1D, $1C, $0F, $0E, $0D, $0C, $0B, $0A, $09, 0
.play ;4C70
	ld a, LOW(.poly)
	ld [$C11E], a
	ld a, HIGH(.poly)
	ld [$C11F], a
	ld a, $02
	ld hl, .regs
	jp StartSFX

Noise_Explode:
.poly ;4C82
	db $55, $77, $57, $64, $57, $64, $65, $64, $55, $74, $57, $87, $57, $57, $57, $57, $55, $57, $57, $76, $57, $57, $57, $57, $55, $57, $57, $57, $87, $57, $57, $57, $57, $57, $57, $57, $64, $64, $64, $64, $65, $65, $66, $67, $74, $74, $75, $76, $77, $84, $84, $85, $85, $86, $85, $84, $77, $76, $75, $74, $67, $66, $65, $64, $86, $86, $86, $86, $86, $86, $86, $86, 0
.regs1 ;4CCB
	db $00, $3B, $25, $C0
.regs2 ;4CCF
	db $00, $F6, $57, $80
.play ;4CD3
	call CheckNoisePriority1
	ret z
	call CheckNoisePriority2
	ret z
	ld a, $02
	ld hl, .regs1
	jp StartSFX
.continue ;4CE3
	ld hl, $C11C
	ld a, [hl]
	ld c, a
	inc [hl]
	cp $02
	jr z, .pt2
	ld b, $00
	ld hl, .poly
	add hl, bc
	ld a, [hl]
	ldh [rNR43], a ;polynomial
	and a
	ret nz
	jp Ch4Reset
.pt2
	ld hl, .regs2
	jp LoadChannelRegisters.c4
	
GetPolynomialOffset: ;4D01
	ld de, $C11C
	ld a, [de]
	ld c, a
	ld b, $00
	inc a
	ld [de], a
	add hl, bc
	ld a, [hl]
	and a
	ret

Noise_BaseEnter:
.continue ;4D0E
	call SFX_Increment
	and a
	ret nz
	ld hl, .poly
	call GetPolynomialOffset
	jp z, Ch4Reset
	ldh [rNR43], a
	ret
.poly ;4D1F
	db $46, $45, $37, $35, $34, $24, $17, $16, $15, $14, $07, 0
.regs ;4D2B
	db $00, $19, $47, $80
.play ;4D2F
	ld a, $01
	ld hl, .regs 
	jp StartSFX

Noise_Turbo:
.continue ;4D37
	ret
.play
	ret

Noise_EnemyDamage:
.regs2 ;4D39
	db $00, $93, $47, $80
.regs1
	db $00, $A2, $3D, $80
.play ;4D41
	call CheckNoisePriority1
	ret z
	call CheckNoisePriority2
	ret z
	ld a, $03
	ld hl, .regs1
	jp StartSFX
.continue ;4D51
	call SFX_Increment
	and a
	ret nz
	ld hl, $C11C
	ld a, [hl]
	inc [hl]
	and a
	jr z, .pt2
	cp $0A
	jp z, Ch4Reset
	ret
.pt2 ;6
	ld hl, .regs2 
	jp LoadChannelRegisters.c4
	
Removed_Noise_unka: ;4D6A
.play
.continue
	ret
;4D6B
	
SECTION "6:4D70", ROMX[$4D70], BANK[6]
Ch4Reset: ;4D70, resets channel 4 stuff
	xor a
	ld [$C119], a ;playing noise?
	ld a, $08
	ldh [rNR42], a ;volume
	ld a, $80
	ldh [rNR44], a ;counter
	ld [$C12A], a
	ld hl, $C0EF
	res 7, [hl]
	ret


SFX3: ;4D85
.regs
	db $80, $00, $20, $40, $85

.queue ;4D8A
	call LoadWaveNum.w3
	ld a, [.regs + 3] ;lo freq
	ld [wWavScratch1], a ;scratch 1
	ld a, [.regs + 4] ;hi freq
	and $0F
	ld [wWavScratch2], a ;scratch 2
	ld hl, .regs
	jp LoadChannelRegisters.c3

.getinfo ;4DA1
	ld hl, wWavElapsed
	inc [hl]
	ld e, [hl]
	ld a, [wWavScratch1]
	ld l, a
	ld a, [wWavScratch2]
	ld h, a
	ld a, e ;returns elapsed time in A and frequency in HL
	ret
	
.play ;4DB0, 3 playing
	call .getinfo
	cp $16
	jp z, SFXCleanup ;if elapsed is $16, jump
	cp $06
	jr c, .start ;if elapsed less than $06, jump
	ld bc, $FFF3 ;(0 - $D)
.add
	add hl, bc ;subtract D from the frequency
	ld a, l
	ldh [rNR33], a ;CH3 freq. lo
	ld [wWavScratch1], a
	ld a, h
	ld [wWavScratch2], a
	or $C0 ;set high bits
	ldh [rNR34], a ;CH3 freq. hi
	ret
.start
	ld bc, $000E
	jr .add

TriggerFadeout: ;4DD4, 1 queued
	ld a, [wCurrentTrack]
	and a
	ret z ;none playing
	cp $05
	ret z ;shieldless doesn't fadeout
	cp $08
	ret z ;game over doesn't fadeout
	ld hl, wFadeOutMusic
	ld a, [hl]
	and a
	ret nz ;return if fadeout already set
	ld [hl], $01 ;else, set it
	ret

UpdateCh3SFX: ;4DE8 TODO: update these to better names, I.E. Wave and what they are used for
	ld a, [wQueueWave]
	and a
	jr z, .nonequeued
	cp $01 ;fadeout
	jr z, TriggerFadeout ;to 4DD4
	cp $02
	jp z, SFX2.queue ;to 4F8B
	cp $03
	jr z, SFX3.queue ;to 4D8A
	cp $04
	jr z, SFX4.queue ;to 4E5A
	cp $05
	jp z, SFX5.queue ;to 4E95
	cp $06 ;radar ping
	jp z, SFX6.queue ;to 4EFA
	cp $07
	jp z, SFX7.queue ;to 4F2B
.nonequeued ;20
	ld a, [wPlayingWave] ;playing
	and a
	ret z
	cp $02
	jp z, SFX2.play ;4FAC
	cp $03
	jr z, SFX3.play ;4DB0
	cp $04
	jr z, SFX4.play ;4E39
	cp $05
	jr z, SFX5.play ;4E7A
	cp $06
	jp z, SFX6.play ;4EB2
	cp $07
	jp z, SFX7.play ;4F4D
	ret
	
SFX4: 
.regs1 ;4E2F, 4 wave 1
	db $80, $50, $60, $B0, $C7
.regs2 ;4E34, 4 wave 2
	db $80, $50, $40, $D3, $C7

.play ;4E39
	ld hl, wWavElapsed
	inc [hl]
	ld a, [hl]
	cp $19
	jp z, SFXCleanup ;if elapsed, jump
	cp $05
	jr c, .below5 ;if less than 5, jump
	inc l
	dec [hl]
	dec [hl]
	dec [hl]
.setfreq
	ld a, [hl]
	and %11111100
	ld c, a
	ldh a, [rDIV] ;get a time
	and %00000011 ;mask to low two bits
	or c ;use the other 6 bits from the word value
	ldh [rNR33], a ;CH3 freq. lo
	ret
.below5
	inc l
	jr .setfreq
	
.queue ;4E5A
	call LoadWaveNum.w4
	ld a, [.regs2 + 3]
	ld [wWavScratch1], a ;scratch 1
	ld hl, $C122 ;?
	inc [hl]
	ld a, [hl]
	bit 0, a
	ld hl, .regs1 ;reg data
	jr z, .load
	ld hl, .regs2 ;reg data
.load
	jp LoadChannelRegisters.c3 ;load the third channel with our data
	
SFX5: ;4E75
.regs ;wave 5
	db $80, $50, $20, $60, $C6
	
.play ;4E7A
	ld hl, wWavElapsed ;elapsed
	inc [hl]
	ld a, [hl]
	cp $13 ;cap
	jp z, SFXCleanup ;cleanup
	cp $04
	jr c, .usediv
	inc l
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ld a, [hl]
.load
	ldh [rNR33], a ;CH3 Freq. Lo
	ret
.usediv
	ldh a, [$FF04]
	jr .load
	
.queue ;4E95
	call LoadWaveNum.w5
	ld a, $60
	ld [wWavScratch1], a
	ld hl, .regs
	jp LoadChannelRegisters.c3
	
SFX6:
.regs1 ;4EA3, 6 wave 1
	db $80, $D0, $20, $50, $C6
.regs2 ;4EA8, 6 wave 2
	db $80, $D0, $40, $50, $C6
.regs3 ;4EAD, 6 wave 3
	db $80, $D0, $60, $50, $C6

.play ;4EB2
	ld hl, wWavElapsed ;elapsed
	inc [hl]
	ld a, [hl]
	cp $0E
	jr z, .capped ;if E, jump
	ld hl, wWavScratch2
	ld a, [hl] ;else load up scratch 2
	add a, $0F
	ld [hl], a ;and increase it
	ldh [rNR33], a ;CH3 Freq. Lo
	ret
.capped
	ld [hl], $00 ;clear elapsed
	ld a, $50
	ld [wWavScratch2], a ;scratch 2
	ld hl, wWavScratch1
	ld a, [hl]
	inc [hl] ;increment scratch 1
	ld hl, .regs2
	cp $00
	jr z, .loadregs
	ld hl, .regs3
	cp $01
	jr z, .loadregs
	cp $02
	jp z, .setSpotted
	ret
.setSpotted ;4EE5
	ld hl, wSpottedState
	ld a, [hl]
	cp $02 ;if spotted before,
	jr z, .cleanup ;skip
	ld a, $01
	ld [wSpottedState], a ;else load 1
.cleanup
	jp SFXCleanup ;cleanup
.loadregs ;1D/16
	jp LoadChannelRegisters.c3
	
;4EF8
.ret
	pop af
	ret
.queue ;4EFA
	push af
	ld a, [wPlayingWave] ;currently playing sound
	cp $06 ;this?
	jr z, .ret ;to 4EF8
	pop af
	call LoadWaveNum.w5 ;reuses wave 5
	ld a, $50
	ld [wWavScratch2], a
	ld hl, .regs1
	jp LoadChannelRegisters.c3

SFX7: ;this is the commander's talking blips
.waveform ;4F11 - 4F20 is a waveform
	db $EE, $EE, $EE, $EE, $EE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0E, $00	
.regs1 ;4F21
	db $80, $70, $40, $23, $C7
.regs2 ;4F26
	db $80, $70, $60, $23, $C7
	
.queue ;4F2B
	call LoadWaveNum.w7
	xor a
	ld [wWavScratch3], a ;clear out scratch 3 for iteration
	ldh a, [rDIV]
	and $01
	ld hl, .regs2 ;pick one of the two at random?
	jr z, .load
	ld hl, .regs1
.load
	call LoadChannelRegisters.c3
	ldh a, [rDIV]
	and $7F
	ldh [rNR33], a ;CH3 Freq. Lo
	ld [wWavScratch2], a ;scratch 2
	ret
	
;4F4B
.ret
	inc [hl]
	ret
.play ;4F4D
	ld hl, wWavScratch3
	ld a, [hl]
	inc [hl]
	cp $00
	ret nz ;only trigger this body every $100 ticks
	ld [hl], $00 ;unneeded?
	ld hl, wWavElapsed ;elapsed
	inc [hl] ;scratch 1
	ld a, [hl+]
	cp $02
	jr z, .ret ;on second lap end, increment scratch 2
	cp $06
	jr z, .end ;on sixth lap end, cleanup
	ld a, [hl+]
	and a
	jr nz, .checkforAnd ;jump on all but first lap end?
	ldh a, [rDIV]
	and $01
	jr z, .inc ;first run through, flip a coin if we should dec 3 or inc 1
	dec [hl]
	dec [hl]
	dec [hl]
.savefreq 
	ld a, [hl]
	ldh [rNR33], a ;CH3 Freq. Lo
	ret
.inc
	inc [hl]
	jr .savefreq
.checkforAnd
	ldh a, [rDIV]
	bit 3, a
	jr z, .savefreq
	and $3F
	add a, [hl]
	ld [hl], a ;i've lost track of things by here,
	jr .savefreq
.end
	jr SFXCleanup ;to 4FD1, cleanup
	
SFX2:
.regs ;4F86 2 wave
	db $80, $80, $20, $23, $C7
	
.queue ;4F8B
	call LoadWaveNum.w2
	ldh a, [rDIV]
	and $7F
	or $08
	ld [wWavScratch2], a ;scratch 2
.load
	ld hl, $4F86
	call LoadChannelRegisters.c3
	ldh a, [rDIV]
	and $7F
	or $08
	ldh [rNR33], a ;CH3 Freq. Lo
	ld [wWavScratch3], a ;scratch 3
	ret
	
.reload ;4FA9
	inc [hl]
	jr .load
.play ;4FAC
	ld hl, wWavElapsed ;elapsed
	inc [hl]
	ld a, [hl+]
	cp $03
	jr z, .reload ;if 3, get back
	cp $09
	jr z, .end ;if 9, cleanup
	ld a, [hl+] ;load scratch 1
	and a
	jr z, .dec ;first frame? jump
	ld a, [wWavScratch3] ;check scratch 3
	bit 0, a
	jr z, .dec ;if unset, jump
	inc [hl]
	inc [hl] ;scratch 2 += 2
.savfreq
	ld a, [hl]
	ldh [rNR33], a ;CH3 Freq. Lo
	ret
.dec
	dec [hl]
	dec [hl]
	dec [hl] ;scratch 2 -= 3
	jr .savfreq
.end 
	jr SFXCleanup ;to cleanup!

SFXCleanup: ;4FD1, sound cleanup?
	xor a
	ld [wPlayingWave], a ;wipe playing sound
	ldh [rNR30], a ;turn off channel 3
	ld hl, $C0DF
	res 7, [hl] ;clear high bit of DF?
	ld a, [$C0D6]
	ld l, a
	ld a, [$C0D7]
	ld h, a ;load HL with pointer from D6/D7?
	jr LoadWaveNum.passed ;to 5010
	
LoadWaveNum: ;4FE6
.w2
	call .PrepSFX
	ld hl, .waveform2
	jp LoadWave
.w4 ;4FEF, wave 4
	call .PrepSFX
	ld hl, .waveform4
	jp LoadWave
.w5 ;4FF8, wave 5 and wave 6
	call .PrepSFX
	ld hl, .waveform5
	jp LoadWave
.w7 ;5001, wave 7
	call .PrepSFX
	ld hl, SFX7.waveform
	jp LoadWave
.w3 ;500A, wave 3
	call .PrepSFX
	ld hl, .waveform3
.passed ;5010, called by reset
	jp LoadWave
	
.PrepSFX ;5013
	ld [wPlayingWave], a ;load playing sound
	ld hl, $C0DF
	set 7, [hl] ;set top bit
	xor a
	ld [wWavElapsed], a ;elapsed time
	ld [wWavScratch1], a ;scratch 1
	ld [wWavScratch2], a ;scratch 2
	ldh [rNR30], a ;channel 3 sound off
	ret
	
.waveform3 ;5028
	db $A7, $13, $32, $3F, $AB, $CD, $EF, $A7, $F1, $F1, $F1, $F1, $F1, $F1, $49, $B9
.waveform2 ;5038
	db $12, $34, $68, $B9, $86, $56, $43, $34, $56, $67, $89, $76, $43, $45, $44, $32
.waveform4 ;5048
	db $12, $13, $32, $3F, $89, $CD, $78, $97, $71, $61, $61, $61, $61, $61, $49, $B9
.waveform5 ;5058
	db $00, $00, $98, $76, $54, $32, $10, $91, $F8, $76, $04, $32, $12, $38, $E9, $19
	
StartSFX: ;5068
	;a is 3, hl points to sound register data
	push af ;save passed a
	dec e ;back up our position, now queue plus one
	ld a, [$C0F1]
	ld [de], a ;write playing track?
	inc e
	pop af
	inc e ;queue plus three
	ld [de], a ;write that passed value
	dec e
	xor a
	ld [de], a ;now wipe queue byte c108
	inc e
	inc e ;queeue plus four
	ld [de], a ;wipe c10a
	inc e ;queue plus five
	ld [de], a ;wipe c1ob
	push hl ;passed poitner
	ld a, e
	cp $05 ;if QueueSFX, jump
	jr z, .sfx
	cp $15 ;if QueueWave, jump
	jr z, .wave
	cp $1D
	jr z, .noise
	pop hl
	ret
.sfx ;A
	ld hl, $C0BF
	set 7, [hl]
	pop hl
	jr LoadChannelRegisters.c1
.wave ;0E
	ld hl, $C0DF
	set 7, [hl]
	pop hl
	jr LoadChannelRegisters.c3
.noise ;12
	ld hl, $C0EF
	set 7, [hl]
	pop hl
	jr LoadChannelRegisters.c4

LoadChannelRegisters: ;50A2
.c1
	push bc
	ld c, LOW(rNR10) ;channel 1
	ld b, rNR20 - rNR10 ;counter
	jr .loop ;to loop
.c2 ;50A9
	push bc
	ld c, LOW(rNR21) ;channel 2
	ld b, rNR30 - rNR21 ;counter
	jr .loop ;to loop
.c3 ;50B0
	push bc
	ld c, LOW(rNR30) ;channel 3
	ld b, rNR40 - rNR30 ;counter
	jr .loop ;to loop
.c4 ;50B7
	push bc
	ld c, LOW(rNR41) ;channel 4
	ld b, rNR50 - rNR41 ;counter
.loop
	ld a, [hl+]
	ld [c], a
	inc c
	dec b
	jr nz, .loop
	pop bc
	ret

StartPointedAudio: ;50C4, called if track queued
	inc e
	ld [$C0F1], a ;save passed track
PlayPointedAudio: ;50C8, called to keep playing a track
	inc e ;queue plus two (sfx) or one (track)
FetchPointedWord: ;50C9
	dec a
	sla a
	ld c, a
	ld b, $00 ;turn track ID into an offset for word table passed as HL
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl] ;fetch a word
	ld l, c
	ld h, b ;word is in HL, high byte in A
	ld a, h ;HL is used to jump to.
	ret
	
SFX_Increment: ;50D7, generic sfx increment?
	push de
	ld l, e
	ld h, d
	inc [hl] ;increment counter
	ld a, [hl+]
	cp [hl] ;next byte is the limit
	jr nz, .done
	dec l
	xor a
	ld [hl], a ;reset if it's done
.done
	pop de
	ret


LoadWave: ;50E4
	push bc
	ld c, LOW(rWave_0)
.loop
	ld a, [hl+]
	ld [c], a
	inc c
	ld a, c
	cp LOW(rLCDC)
	jr nz, .loop
	pop bc
	ret

InitSound: ;50F1
	ld a, $FF 
	ld [rNR51], a ;enable all sound channels in stereo
	ld a, $03 
	ld [wStereoSetting], a 
	xor a 
	ld [$C109], a 
	ld [$C12E], a
	ld [$C124], a
	ld [$C125], a
	ld [$C123], a
	ld [wAuxTimerActive], a
PrepForTrack: ;510D
	xor a 
	ld [$C101], a 
	ld [$C111], a 
	ld [$C119], a
	ld [$C0BF], a
	ld [$C0CF], a
	ld [$C0DF], a
	ld [$C0EF], a
	ld [wAuxTimerLo], a
	ld [wAuxTimerHi], a
	ld [$C12A], a
	ld [$C121], a
	ld [$C120], a
	ld [$C12C], a
	ld [$C12D], a 
	ld a, $08 
	ld [rNR12], a ;channel 1 volume
	ld [rNR22], a ;channel 2 volume
	ld [rNR42], a ;channel 4 volume
	ld a, $80 
	ld [rNR14], a ;channel 1 frequency
	ld [rNR24], a ;channel 2 frequency
	ld [rNR44], a ;channel 4 counter
	xor a 
	ld [rNR10], a ; channel 1 sweep off
	ld [rNR30], a ; channel 3 sound off
	ret
	
UpdatePlayingSound: ;514E, updates sound?
	ld de, wQueueSFX
	ld a, [de]
	and a
	jr z, .nonequeued 
	cp $22 ;only $01 - $22 valid range
	jr nc, .nonequeued 
	ld hl, SFX_Queue_Table 
	call StartPointedAudio ;else call this
	jp hl ;and jump away?
.nonequeued
	inc e
	ld a, [de] ;load currently playing track
	and a
	ret z ;if none, return
	ld hl, SFX_Playing_Table ;$21 word entries
	call PlayPointedAudio 
	jp hl ;otherwise call and jump away
	
UpdatePlayingNoiseCh: ;516B	
	ld a, [$C119] 
	cp $1D ;mutes?
	jr nz, .checkqueue 
	xor a
	ld [wQueueNoise], a 
.checkqueue
	ld de, wQueueNoise 
	ld a, [de]
	and a
	jr z, .nonequeued 
	cp $1E  ;only $01 - $1E valid range
	jr nc, .nonequeued 
	ld hl, $4484 
	call StartPointedAudio 
	jp hl
.nonequeued
	inc e
	ld a, [de]
	and a
	ret z
	ld hl, $44BE ;$1D word entries
	call PlayPointedAudio 
	jp hl

ResetSound: ;5193
	;enables sound, then clears C0A0 - C130
	ld a, $80 
	ld [rNR52], a ;enable sound
	ld a, $77 
	ld [rNR50], a ;max volume for left/right
	ld a, $FF 
	ld [rNR51], a ;all channels stereo enabled
	ld hl, $C0A0 
.loop
	ld [hl], 00 
	inc l 
	jr nz, .loop ;clears $C0A0 - $C100
	ld hl, wQueueSFX 
.loop2
	ld [hl], 00 
	inc l
	ld a, l
	cp $30 
	jr nz, .loop2 ;clears $C100 - $C2FF
	jp InitSound
	
HandleFadeOut: ;51B5
	ld a, [wFadeOutMusic]
	and a
	ret z ;if not fading out, return
	ld c, a ;backup value to C
	cp $01
	jr z, .firstrun
	jr .fade
.firstrun ;value was 1, start the fade
	xor a
	ldh [rNR30], a ;stop the channel 3
	ld hl, $C0DF
	set 7, [hl]
	ld hl, $C0EF
	set 7, [hl]
.fade ;continue the fade
	ld hl, wFadeOutTicks
	inc [hl] ;increment the tick counter
	ld a, [hl]
	cp $08
	ret nz ;if not at 08, return
	ld [hl], $00 ;reset it
	ld hl, wFadeOutMusic
	inc [hl] ;increment this counter
	ld b, $00
	ld a, [wCurrentTrack]
	ld hl, .table1
	cp $01 ;intro? 
	jr z, .loadtableval
	ld hl, .table1 ;was intro going to be a seperate fade table originally?
.loadtableval
	add hl, bc ;BC is our counter, HL is our table
	ld a, [hl]
	and a
	jr z, .zero ;if table value is zero, skip
	ld [$C0B6], a ;otherwise write it
	ld bc, $0009
	add hl, bc ;+= 9
	ld a, [hl] 
	ld [$C0C6], a ;and write next table value to here
	ret
.zero
	ld [wCurrentTrack], a
	ld [wFadeOutMusic], a
	ld [wFadeOutTicks], a ;cleanup!
	call Ch1Reset ;resets channel 1 stuff
	call Ch2Reset ;resets channel 2 stuff
	call SFXCleanup ;resets channel 3
	jp Ch4Reset ;resets channel 4 stuff
	
.table1 ;5211
	db $34, $34, $34, $23, $23, $23, $12, $12, $00
.table2 ;521A
	db $53, $43, $33, $32, $23, $23, $12, $12, $11

HandleQueuedTrack:
.reset ;5223
	jp InitSound
.entry ;5226, queued track is in A, HL has address to playing track
	cp $FF
	jr z, .reset ;passing -1 resets everything
	cp $29
	ret nc ;otherwise, if > $29, return (invalid ID)
	ld [hl], a ;we're playing the queued now
	ld b, a ;backup ID
	cp $03 ;boss idle
	jr z, .startWithSplash
	cp $17 ;boss active
	jr z, .startWithSplash
	cp $16 ;$0C with an intro, objective or something?
	jr z, .startWithCounter
	cp $01 ;title
	jr nz, .play
	call ResetSound
	ld a, $01
	ld [wCurrentTrack], a ;write track 1 (a got clobbered i guess?)
	ld b, a ;backup ID
.play ;9, E5, DC
	ld hl, Track_Data_Table ;the master track data pointer list?
	and $3F ;mask off invalid bits?
	call PlayPointedAudio
	call LoadNewTrackData
	jp LoadStereoTable
.startWithSplash ;23, 1F, track was $03 or $17 (final boss, give a whoosh!)
	push af
	xor a
	ld [$C119], a ;cancel noise sfx
	ld a, $01
	ld [$C123], a ;whoosh
	pop af
	jr .play
.startWithCounter ;28
	push af
	ld a, $01
	ld [wAuxTimerActive], a ;activate counter
	pop af
	jr .play

LoadMusicTrack: ;526C
	ld a, [wQueueMusic]
	ld b, a ;b has current track
	and a
	ret z ;if none, return
	ld a, [wCurLevel]
	and $FC
	rrca
	rrca
	ld [wLevelID], a ;save actual level number to C129
	ld hl, wLevelID
	xor a
	ld [wAuxTimerActive], a ;dunno
	ld a, b ;track
	cp $20 ;intro track
	jr z, .playintro ;if playing $20, jump
	cp $21 ;update track
	ret nz ;if not $21, return
	ld hl, TrackIDsSpotted ;enemy spotted
	ld a, [$C0AE]
	and a
	jr z, .checkspotted
	ld hl, TrackIDsObjective ;if nonzero, collected item/did objective?
	jr .gettrack
.checkspotted
	ld a, [wSpottedState]
	cp $02 ;enemy spotted?
	jr z, .gettrack ;if spotted, jump
	ld hl, TrackIDsAmbient
	jr .gettrack
.playintro ;52A5
	ld a, $01
	ld [wPlayingIntroJingle], a
	xor a
	ld [wSpottedState], a
	ld [wIntroJingleTimer], a
	ld hl, TrackIDsIntro
.gettrack ;52B4, HL has one of four music tables
	ld a, [wLevelID]
	ld c, a
	cp $09
	jr nz, .loadtrack ;if level $9, never play the intro jingle
	xor a
	ld [wPlayingIntroJingle], a
.loadtrack
	ld b, $00
	add hl, bc
	ld a, [hl]
	ld [wQueueMusic], a ;otherwise grab a value and feed it into the track
	ret
	
	
CheckPausedVolume: ;52C8
	ldh a, [hGameState]
	cp $01 ;planet?
	ret nz 
	ld hl, wHalfVolume
	ld a, [hl]
	ld b, a ;backup value
	ldh a, [hPauseFlag]
	ld [hl+], a ;write a new value
	ld e, a ;paused in E
	ld c, a ;paused in C
	xor b ;paused xor [C126]
	and c ;and paused
	ld [hl+], a ;save value to C127. this is only 1 on the frame the pause is triggered
	and a
	jr z, .notjustpaused ;jump if we didn't just pause
	ld a, $33
	ldh [rNR50], a ;half volume for left/right
	ld [hl-], a ;write volume to C128, only when paused?
	ld a, $10
	ldh [rNR42], a ;initial envelope 4 vol to $1
	ld a, $80
	ldh [rNR44], a ;restart envelope 4 sound (to apply new vol)
.clear
	xor a
	ld [hl], a ;clear out C127 or C128
	ret
.notjustpaused ;52ED
	dec l ;go back to C127
	ld a, e ;paused value
	and a
	jr nz, .clear ;if paused, jump
	inc l
	ld a, [hl] ;else check C128
	and a
	jr z, .clear ;if zero (not paused), jump
	ld a, $77
	ldh [rNR50], a ;restore full volume!
	ld [$C12A], a
	xor a
	ld [hl-], a ;wipe C128
	jr .clear


UpdateSound: 
.playSplash ;5302
	ld [hl], $00 ;clear value
	ld a, $1D
	ld [wQueueNoise], a ;play a whoosh sound
	jr .updateQueue ;resume
.entry ;530B, entry point
	ld hl, $C123
	ld a, [hl]
	and a
	jr nz, .playSplash ;to 5302
.updateQueue
	call CheckPausedVolume
	call LoadMusicTrack
	ld hl, wQueueMusic
	ld de, wSpottedState
	ld a, [de]
	cp $01
	jr nz, .notjustspotted
	ld a, $02 ;if spotted was 1,
	ld [de], a ;set it to 2
	ld a, [hl+]
	and a
	jr nz, .queued ;if a track was already queued, jump to 537C
	dec l
	push hl ;save address
	ld hl, TrackIDsJustSpotted
	ld a, [wLevelID]
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl]
	pop hl
	ld [hl+], a ;load up spotted track
	jr .queued ;to 537C
.notjustspotted
	ld a, [hl+]
	and a
	jr nz, .queued ;if a track is queued, jump to 537C
	ld hl, wPlayingIntroJingle
	ld a, [hl+]
	and a
	jr z, .noJingle ;if not playing intro jingle, jump 
	inc [hl] ;increment counter
	ld a, [hl-]
	cp $E0 ;jingle length
	jr nz, .playingTrack
	xor a ;if at $E0, reset flag
	ld [hl], a
	jr .playingTrack
.noJingle
	ld a, [wCurrentTrack] ;current track
	cp $15
	jr z, .playingTrack
	cp $1D
	jr z, .playingTrack ;if track 15 or 1D (fanfares?), skip ahead
	cp $01
	jr z, .skipnoise ;if 1 (title screen), skip this next call
	call UpdatePlayingNoiseCh
.skipnoise
	call UpdateCh3SFX ;not skipped because fadeout's handled in here
	call UpdatePlayingSound ;jumps using a pointer table based on queued & active track
.playingTrack
	call UpdatePlayingNotes
	call UpdateMotorRumble
	xor a
	ld [wQueueSFX], a
	ld [wQueueMusic], a
	ld [wQueueWave], a
	ld [wQueueNoise], a ;clear the queues
	ret
.queued ;537C
	call HandleQueuedTrack.entry
	jr .playingTrack
	
UpdateMotorRumble: ;5381
	ld a, [wAuxTimerActive]
	and a
	ret nz ;if counter flag set, return
	ld a, [$C119]
	and a
	ret nz
	ld a, [$C123]
	and a
	ret nz ;if splash flag set, return
	ldh a, [hGameState]
	cp $01
	ret nz ;if state is not planet, return
	ld a, [wCurrentTrack]
	cp TRACK_TITLE
	ret z
	cp TRACK_RESULTS ;level results
	ret z
	cp TRACK_BASE ;stations
	ret z
	cp $18 ;whistly ??
	ret z
	cp $28 ;tutorial copy?
	ret z
	ld hl, $C121 ;counter
	ld a, [$C120] ;speed backup
	ld b, a ;backup backup
	ldh a, [hSpeedTier]
	ld [$C120], a ;update backup
	ld d, a ;current backup
	ld e, $FF
	ld c, a ;current backup
	xor b ;current xor old
	jr z, .loadcounter ;if they're the same, jump
	and c
	ld e, a ;new on bits saved to e
	ld [hl], $00 ;reset counter
.loadcounter
	ld a, [hl] ;load counter
	cp $FF
	jr z, .incd
	inc [hl]
.incd
	ld hl, $C12A ;stereo volume?
	ld a, [hl]
	and a
	jr nz, .updateregister ;if nonzero, skip ahead
	ld a, e 
	cp $FF
	ret z ;otherwise return if no new bits
.updateregister
	ld [hl], $00 ;clear volume
	ld a, d ;current speed
	inc a ;++
	and $07 ;mask
	ld hl, .registerpointers
	call FetchPointedWord ;gets word A out of table HL, returned in HL
	jp LoadChannelRegisters.c4
	
.regrev ;53DE
	db $00, $0F, $34, $80
.regstop ;53E2
	db $00, $20, $57, $80
.reglow ;53E6
	db $00, $30, $56, $80
.regmed ;53EA
	db $00, $40, $55, $80
.reghigh ;53EE
	db $00, $40, $47, $80
.regturbo ;53F2
	db $00, $40, $35, $80
.regtunnel ;53F6, unused?
	db $00, $30, $14, $80

.registerpointers ;53FA
	dw .regrev, .regstop, .reglow, .regmed, .reghigh, .regturbo, .regtunnel
	
CheckAuxTimer: ;5408
	;passed A is song ID
	cp $16 ;item revealed?
	ret nz
	ld a, [wAuxTimerActive]
	and a
	ret z ;return if timer not active
	ld a, [wAuxTimerLo]
	ld l, a
	ld a, [wAuxTimerHi]
	ld h, a
	inc hl
	ld a, l
	ld [wAuxTimerLo], a
	ld a, h
	ld [wAuxTimerHi], a ;increment the counter
	ld a, h
	cp $01
	ret nz
	ld a, l
	cp $92
	ret nz ;tick until $0192
	xor a
	ld [wAuxTimerActive], a ;clear flag
	ld a, $01
	ld [$C12A], a ;flag this
	ret
	
LoadStereoTable: ;5433
	ld a, [wCurrentTrack]
	ld hl, TrackStereoTable
.loop
	dec a
	jr z, .loopdone
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl ;six bytes per entry
	jr .loop
.loopdone ;hl is now a table entry
	ld bc, wStereoSetting
	ld a, [hl+]
	ld [bc], a ;first byte to F5
	inc c
	xor a
	ld [bc], a ;0 to F6
	inc c
	ld a, [hl+]
	ld [bc], a ;second byte to F7
	inc c
	xor a
	ld [bc], a ;zero to F8
	inc c
	ld a, [hl+]
	ld [bc], a
	ldh [rNR51], a ;start with first stereo entry
	inc c
	ld a, [hl+]
	ld [bc], a
	inc c
	ld a, [hl+]
	ld [bc], a
	inc c
	ld a, [hl+]
	ld [bc], a ;load the four stereo values
	ret


UpdateStereo: ;5461
	ld hl, wStereoSetting
	ld a, [hl+]
	cp $01
	ret z ;if it was 1 (init sets it to 3) return
	inc [hl] ;increment wStereoTicks
	ld a, [hl+]
	cp [hl] ;compare wStereoTicks to wStereoThreshold
	ret nz ;return if they're not equal now
	dec l
	ld [hl], $00 ;if equal, reset counter to zero
	inc l
	inc l
	inc [hl] ;increase this lap counter
	ld a, [hl+]
	and $03 ;grab bottom two bits of laps
	ld c, l
	ld b, h ;backup HL to BC
	and a
	jr z, .load ;zero, use first
	inc c
	cp $01
	jr z, .load ;one, use second
	inc c
	cp $02
	jr z, .load ;two, use third
	inc c ;three, use fourth
.load
	ld a, [bc]
	ldh [rNR51], a ;load stereo selector with the chosen byte
	ret
	
MUS_LoadHLWordToDE: ;5489, word at HL pointer loaded into DE
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	ld a, [bc] ;read value from pointer
	ld [de], a ;and save it at DE
	inc e
	inc bc
	ld a, [bc]
	ld [de], a ;updated word
	ret
	
MUS_CopyHLWordToDE: ;5494
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	ret
	
LoadNewTrackData: ;549A
	call PrepForTrack ;resets a lot of the music state, but not all?
	ld de, $C0A0
	ld b, $00
	ld a, [hl+]
	ld [de], a ;first byte goes to A0
	inc e
	call MUS_CopyHLWordToDE
	ld de, $C0B0
	call MUS_CopyHLWordToDE
	ld de, $C0C0
	call MUS_CopyHLWordToDE
	ld de, $C0D0
	call MUS_CopyHLWordToDE
	ld de, $C0E0
	call MUS_CopyHLWordToDE
	ld hl, $C0B0
	ld de, $C0B4
	call MUS_LoadHLWordToDE
	ld hl, $C0C0
	ld de, $C0C4
	call MUS_LoadHLWordToDE
	ld hl, $C0D0
	ld de, $C0D4
	call MUS_LoadHLWordToDE
	ld hl, $C0E0
	ld de, $C0E4
	call MUS_LoadHLWordToDE ;load up a bunch of pointers
	ld bc, $0410
	ld hl, $C0B2
.loop ;sets all note lengths/delays to 1? start reading notes next frame
	ld [hl], $01
	ld a, c
	add a, l
	ld l, a
	dec b
	jr nz, .loop
	xor a
	ld [$C0BE], a
	ld [$C0CE], a
	ld [$C0DE], a ;wipe these
	ret
	
	
LoadNote:
.channel3 ;54FD
	push hl
	ld a, [wPlayingWave]
	and a
	jr nz, .finishch3
	xor a
	ldh [rNR30], a ;if playing nothing, mute the wave
	ld l, e
	ld h, d ;load wave at DE
	call LoadWave
.finishch3 
	pop hl
	jr .end
.entry ;550F, just read a $9D. read three bytes from X4
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;read byte from [hl]
	ld e, a
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;read byte from [hl]
	ld d, a
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;read byte from [hl]
	ld c, a ;three bytes at E, D, C
	ld a, [wFadeOutMusic]
	and a
	jr nz, .checkchannel ;if fading out, skip?
	inc l
	inc l
	ld [hl], e ;byte 1 into X6
	inc l
	ld [hl], d ;byte 2 into X7
	inc l
	ld [hl], c ;byte 3 into X8
	dec l
	dec l
	dec l
	dec l ;back to X4
.checkchannel
	push hl
	ld hl, wHandledChannel ;which channel?
	ld a, [hl]
	pop hl
	cp $03
	jr z, .channel3 ;if 3, jump to 54FD
.end ;30
	call MUS_IncrementHLPointer ;inc [hl]
	jp UpdatePlayingNotes.readnextdata ;already at X4

MUS_IncrementHLPointer: ;5545, increment pointer by one?
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a
	inc de
.save ;F1, 554B
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl-], a ;save new pointer
	pop de
	ret
MUS_NextSection: ;5551, increase X0 pointer by two
	push de
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a ;read pointer from X0
	inc de
	inc de ;next pointer in list
	jr MUS_IncrementHLPointer.save
	
MUS_ReadByteFromHL: ;555A, reads a note from pointed pointer
	ld a, [hl+]
	ld c, a
	ld a, [hl-]
	ld b, a
	ld a, [bc]
	ld b, a
	ret

MUS_timernonzero: 
.popandnext ;5561
	pop hl
	jr .backupandnext ;to 5595
.entry ;5564, note timer nonzero
	ld a, [wHandledChannel]
	cp $03
	jr nz, .checkXA
	ld a, [$C0D8]
	bit 7, a
	jr z, .checkXA
	ld a, [hl]
	cp $06
	jr nz, .checkXA
	ld a, $40 ;if channel is 3, C0D8 top bit set, AND timer is at 6,
	ldh [rNR32], a ;write $40 to ch3 output level (volume?)
.checkXA
	push hl ;X2
	ld a, l
	add a, $09
	ld l, a
	ld a, [hl] ;HL += 9, XB
	and a
	jr nz, .popandnext ;if XB is nonzero, jump up to 5561
	ld a, l
	add a, $04
	ld l, a ;XF
	bit 7, [hl]
	jr nz, .popandnext ;if top bit of XF set, jump up
	pop hl ;X2
	call HandleTremolo ;otherwise, call
	push hl ;X2
	call HandleVolumeChange
	pop hl ;X2
.backupandnext ;5595
	dec l
	dec l ;back off to X0
	jp UpdatePlayingNotes.nextchannel
	
MUS_SectionEnd: ;559A, read a byte 00
	dec l
	dec l
	dec l
	dec l ;back to X0
	call MUS_NextSection ;increment HL pointer by two
.savepointer
	ld a, l
	add a, $04
	ld e, a
	ld d, h ;DE = X4, HL = X0
	call MUS_LoadHLWordToDE ;X4 now holds next section pointer, hl incremented to X1
	cp $00
	jr z, .endofsong ;if no value, jump
	cp $FF
	jr z, .jump ;if it was -1, jump
	inc l ;otherwise advance to X2
	jp UpdatePlayingNotes.incthenreadnextdata ;and jump
.jump
	dec l ;back to X0
	push hl
	call MUS_NextSection ;advance sectionlist pointer to next entry
	call MUS_ReadByteFromHL ;grab value from [HL]
	ld e, a
	call MUS_IncrementHLPointer ;increment sectionlist pointer by one
	call MUS_ReadByteFromHL ;grab value from [hl]
	ld d, a
	pop hl ;X0
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl-], a ;jump back to the pointed section
	jr .savepointer
.endofsong
	ld hl, wCurrentTrack
	ld [hl], $00 ;stop playback
	call InitSound
	ret
	
MUS_LoadC0A1Word: ;55D5, just read a 9E
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;grab value from [hl]
	ld [$C0A1], a
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;grab value from [hl]
	ld [$C0A2], a ;load address
	jr MUS_LoadC0A0Byte.inc
MUS_LoadC0A0Byte: ;55E9, just read 9F
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;grab value from [hl]
	ld [$C0A0], a
.inc ;55F2, 9
	call MUS_IncrementHLPointer ;inc [hl]
	jr UpdatePlayingNotes.readnextdata ;to 565A, redo loop
	
SetLoopPoint: ;55F7, just read 9B
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;grab value from [hl]
	push hl ;save our position (X4)
	ld a, l
	add a, $0B
	ld l, a ;hl now XF
	ld c, [hl] ;load value
	ld a, b
	or c
	ld [hl], a ;XF |= read value
	ld b, h
	ld c, l
	dec c
	dec c ;BC is now XD
	pop hl
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a ;de is our X4 pointer
	inc de
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl-], a
	ld a, d ;increment and save de back to X4
	ld [bc], a ;save the upper byte to XD
	dec c
	ld a, e
	ld [bc], a ;lower byte to XC
	jr UpdatePlayingNotes.readnextdata ;to 565A
	
LoopBack: ;561B
	push hl
	ld a, l
	add a, $0B
	ld l, a ;hl now XF
	ld a, [hl]
	dec [hl] ;decrement the XF
	ld a, [hl]
	and $7F
	jr z, .zero ;if zero, jump
	ld b, h
	ld c, l
	dec c
	dec c
	dec c
	pop hl
	ld a, [bc]
	ld [hl+], a
	inc c
	ld a, [bc]
	ld [hl-], a ;else jump to our saved loop point
	jr UpdatePlayingNotes.readnextdata ;to 565A
.zero
	pop hl ;continue on
	jr MUS_LoadC0A0Byte.inc ;to 55F2

UpdatePlayingNotes: ;5637
	ld hl, wCurrentTrack
	ld a, [hl]
	and a
	ret z ;if nothing's playing, return
	call CheckAuxTimer
	call UpdateStereo
	call HandleFadeOut
	ld a, $01
	ld [wHandledChannel], a ;which channel we're handling rn
	ld hl, wNoteDataStart ;start with pointer for first channel
.channelloop ;564E
	;for each channel, read the timer and if needed, read to the next note
	inc l ;X1
	ld a, [hl+] ;grab the value
	and a
	jp z, MUS_timernonzero.backupandnext ;if pointer blank, skip this channel

	dec [hl] ;decrement X2, note timer
	jp nz, MUS_timernonzero.entry ;if nonzero, jump
.incthenreadnextdata ;5658
	inc l
	inc l ;now at X4
	
.readnextdata ;565A
	call MUS_ReadByteFromHL ;loads value from pointer at HL
	cp $00
	jp z, MUS_SectionEnd ;updates X0 pointer and restarts loop? a jump?
	cp $9D
	jp z, LoadNote.entry ;reads three bytes into X6, X7, X8 (or a wave if ch. 3)
	cp $9E
	jp z, MUS_LoadC0A1Word ;reads a word into C0A1/C0A2
	cp $9F
	jp z, MUS_LoadC0A0Byte ;loads a byte into C0A0
	cp $9B
	jp z, SetLoopPoint ;reads a loop count to XF, backs up position to XC/XD
	cp $9C
	jp z, LoopBack ;loop point. decrements XF and loads X4/X5 with XC/XD
	and $F0 ;otherwise, mask off the bottom nybble.
	cp $A0
	jr nz, .handleother ;if not $AX, jump to 56CE
	ld a, b ;otherwise, it was indeed $AX
	and $0F ;load backup of read value and now use the lower nybble
	ld c, a
	ld b, $00 ;lower nybble is now an offset in BC
	push hl ;save hl being X4
	ld de, $C0A1 ;holds a pointer
	ld a, [de]
	ld l, a
	inc e
	ld a, [de]
	ld h, a
	add hl, bc
	ld a, [hl] ;read a byte from table [C0A1/C0A2 + bc]
	pop hl ;restore X4 to HL
	push hl
	ld d, a ;save table byte to D
	inc l
	inc l
	inc l ;X7 now, reg length
	ld a, [hl]
	and $F0 ;top nybble
	jr nz, .topnybbleblank ;if written to, jump
	ld a, d ;else refresh table byte into A
	jr .writetoX3 ;and write it to X3
.topnybbleblank
	ld e, a ;top nybble of length was nonzero
	ld a, d ;refresh table byte to A
	push af ;and save the table value
	srl a ;table byte /2?
	sla e ;shift to check for carry
	jr c, .shifted
	ld d, a ;save byte/2 to d
	srl a ;byte/4
	sla e
	jr c, .shifted
	add a, d
.shifted ;8, 1
	ld c, a ;save table byte
	and a
	jr nz, .loadwithc
	ld c, $02 ;unless it was zero, then save 2
.loadwithc ;2
	ld de, wHandledChannel ;current channel
	ld a, [de]
	dec a ;zero offset
	ld e, a
	ld d, $00
	ld hl, $C0A8
	add hl, de
	ld [hl], c ;load C to C0A8 + channel (zero indexed)
	pop af ;restore table byte
.writetoX3 ;25
	pop hl ;X4
	dec l
	ld [hl+], a ;write table byte to X3, hl now X4 once more
	call MUS_IncrementHLPointer ;inc [hl]
	call MUS_ReadByteFromHL ;read byte from [hl]
.handleother ;56CE
	ld c, b
	ld b, $00
	call MUS_IncrementHLPointer ;inc [hl]
	ld a, [wHandledChannel] ;channel
	cp $04
	jp z, .ch4 ;if channel 4, jump
	push hl ;otherwise save X4
	ld a, l
	add a, $05
	ld l, a ;go to X9
	ld e, l
	ld d, h ;DE is now X9
	inc l
	inc l ;HL is now XB
	ld a, c
	cp $01
	jr z, .read01 ;if read byte was $01, jump
	ld [hl], $00 ;else write 0 to XB
	ld a, [$C0A0]
	and a
	jr z, .grabusingoffset ;if C0A0 is 0, jump
	ld l, a
	ld h, $00 ;else use it as an offset
	bit 7, l
	jr z, .loadBCoffset
	ld h, $FF ;match HL's sign
.loadBCoffset
	add hl, bc
	ld b, h
	ld c, l ;bc += hl ([C0A0] + read byte)
.grabusingoffset
	ld hl, PitchFreqTable
	add hl, bc
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a ;read a word from 58D0 + bc into X9/XA
	pop hl
	jp .prepnotedata
.read01 ;21
	ld [hl], $01 ;load 01 into XB
	pop hl
	jr .prepnotedata ;to 5729
.ch4 ;5710, channel 4
	push hl
	ld de, $C0E6
	ld hl, $5962
	add hl, bc
.dataloop
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, e
	cp $EB
	jr nz, .dataloop ;load five bytes from 5962 + read byte into C0E6 - C0EA
	ld c, LOW(rNR41)
	ld hl, $C0E4 ;load X4 for channel 4
	ld b, $00
	jr .loadnotedata ;to 5762
	
.prepnotedata ;5729
	push hl ;save X4 again
	ld b, $00
	ld a, [wHandledChannel] ;channel
	cp $01
	jr z, .ch1
	cp $02
	jr z, .ch2
	ld c, LOW(rNR30) ;else we're channel 3. load channel 3 on/off reg
	ld a, [$C0DF]
	bit 7, a
	jr nz, .c3length
	xor a
	ld [c], a ;set it to off
	ld a, $80
	ld [c], a ;and then on
.c3length
	inc c ;ch3 length
	inc l
	inc l
	inc l
	inc l ;X8
	ld a, [hl+]
	ld e, a ;load it into E (volume)
	ld d, $00 ;length
	jr .checkXB 
.ch2
	ld c, LOW(rNR21) ;ch2 length
	jr .loadnotedata
.ch1
	ld c, LOW(rNR10) ;ch1 sweep, inc'd to length
	jr .wipethenload
;unreachable?
	ld b, $33
	ld a, $1D
	ld [c], a
	jr .incthenload
.wipethenload
	ld a, $00
.incthenload
	inc c
.loadnotedata ;5762, E
	inc l
	inc l ;always X6 at this point
	ld a, [hl+] ;volume at X6?
	ld e, a
	inc l
	ld a, [hl+] ;length at X8?
	ld d, a ;load two values into DE
.checkXB
	push hl ;always X9 at this point
	inc l
	inc l ;XB
	ld a, [hl+]
	and a
	jr z, .loadusingnotedata
	ld e, $08 ;default volume?
.loadusingnotedata
	inc l
	inc l ;XE
	ld [hl], $00
	inc l
	ld a, [hl] ;XF
	pop hl ;X9
	bit 7, a
	jr nz, .decrement
	ld a, d
	or b
	ld [c], a ;length
	inc c
	ld a, e
	ld [c], a ;volume
	inc c
	ld a, [hl+] ;X9 = frequency/polynomial
	ld [c], a ;frequency
	inc c
	ld a, [hl] ;XA = frequency/counter
	or $80
	ld [c], a ;frequency
.decrement
	pop hl ;X4
	dec l ;X3
	ld a, [hl-] ;load X3
	ld [hl-], a ;into X2
	dec l ;X0
.nextchannel ;5790
	ld de, wHandledChannel
	ld a, [de]
	cp $04
	jr z, .done ;don't loop anymore if we handled all four
	inc a
	ld [de], a
	ld a, $10
	add a, l
	ld l, a ;otherwise increment channel counter and advance position
	jp .channelloop
.done
	ld hl, $C0BE
	inc [hl]
	ld hl, $C0CE
	inc [hl]
	ld hl, $C0DE
	inc [hl]
	ret
	
RetrieveTremoloValue: ;57AE
	ld a, b ;XE value
	srl a ;/= 2
	ld l, a
	ld h, $00 ;use as an offset
	add hl, de
	ld e, [hl] ;grab value from table, put in E
	ret

HandleTremolo: ;57B7
	push hl ;X2
	ld a, l
	add a, $06
	ld l, a
	ld a, [hl] ;X8
	and $0F
	jr z, .end ;if low nibble blank, ret
	ld [$C0F1], a ;save?
	ld a, [wHandledChannel] 
	ld c, LOW(rNR13)
	cp $01
	jr z, .loadreg ;channel 1, use $13
	ld c, LOW(rNR23)
	cp $02
	jr z, .loadreg ;channel 2, use $18
	ld c, LOW(rNR33)
	cp $03
	jr z, .loadreg ;channel 3, use $1D
.end ;18, bc
	pop hl ;X2
	ret
	
.loadreg ;C is loaded with something based on which channel
	inc l ;X9
	ld a, [hl+] 
	ld e, a
	ld a, [hl] ;XA
	ld d, a ;DE is X9/XA, saved freq
	push de ;save it
	ld a, l
	add a, $04
	ld l, a ;XE
	ld b, [hl] ;XE to B
	ld a, [$C0F1] ;low nybble
	cp $01
	jr z, .getvalue
	cp $03
	jr z,.useneg1
	jr .getvalue
.useneg1 ;nybble was 3
	ld hl, $FFFF ;-1 to HL
	jr .savefreqs
.getvalue ;nybble was 1 or 2 or > 3?
	ld de, .TremoloTable ;replace DE with table pointer
	call RetrieveTremoloValue ;call, grab value from table and put in E
	bit 0, b ;xe value even?
	jr nz, .checksign ;if not, jump
	swap e
.checksign
	ld a, e ;retrieved table value
	and $0F
	bit 3, a ;top bit of low nybble, positive or negative?
	jr z, .pos
	ld h, $FF
	or $F0
	jr .savelo
.pos
	ld h, $00
.savelo
	ld l, a
.savefreqs
	pop de
	add hl, de ;HL is either +1 or -1
	ld a, l
	ld [c], a ;freq. lo
	inc c
	ld a, h
	ld [c], a ;freq. high
	jr .end
	
.TremoloTable ;581D - 5871, table of nybbles!
	db $00, $00, $00, $00, $00, $00, $10, $00, $0F, $00, $00, $11, $00, $0F, $F0, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $01, $12, $10, $FF, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

HandleVolumeChange: ;5872
	;check ch1 first
	ld a, [$C0BB]
	and a
	jr nz, .ch2
	ld a, [$C0B7]
	and a
	jr z, .ch2
	and $0F ;BB is zero, B7 is nonzero
	ld b, a ;save low nybble
	ld hl, $C0A8
	ld a, [$C0BE]
	cp [hl]
	jr nz, .ch2
	ld c, LOW(rNR12) ;ch1 vol
	ld de, $C0BA
	ld a, [$C0BF]
	bit 7, a
	jr nz, .ch2
	call SetChVolume
.ch2
	ld a, [$C0CB]
	and a
	ret nz
	ld a, [$C0C7]
	and a
	ret z
	and $0F
	ld b, a
	ld hl, $C0A9
	ld a, [$C0CE]
	cp [hl]
	ret nz
	ld a, [$C0CF]
	bit 7, a
	ret nz
	ld c, LOW(rNR22) ;ch2 vol
	ld de, $C0CA
	call SetChVolume
	ret

SetChVolume: ;58BD
	;b is low nybble of XB, C is channel volume reg
	push bc
	dec b
	ld c, b
	ld b, $00
	ld hl, $5A6F
	add hl, bc ;5A6F + passed b
	ld a, [hl]
	pop bc
	ld [c], a ;load it to volume
	inc c
	inc c ;freq hi
	ld a, [de] ;XA
	or $80 ;top bit restarts note playback
	ld [c], a
	ret
	
PitchFreqTable: ;58D0 - 5961, word pointers? frequencies? is this some sort of pitch -> frequency table?
	dw $0F00 ;dummy, this is treated as an unplayed note?
	dw $002C 
	dw $009C 
	dw $0106 
	dw $016B 
	dw $01C9 
	dw $0223 
	dw $0277 
	dw $02C6 
	dw $0312 
	dw $0356 
	dw $039B 
	dw $03DA 
	dw $0416 
	dw $044E 
	dw $0483 
	dw $04B5 
	dw $04E5 
	dw $0511 
	dw $053B 
	dw $0563 
	dw $0589 
	dw $05AC 
	dw $05CE 
	dw $05ED 
	dw $060A 
	dw $0627 
	dw $0642 
	dw $065B 
	dw $0672 
	dw $0689 
	dw $069E 
	dw $06B2 
	dw $06C4 
	dw $06D6 
	dw $06E7 
	dw $06F7 
	dw $0706 
	dw $0714 
	dw $0721 
	dw $072D 
	dw $0739 
	dw $0744 
	dw $074F 
	dw $0759 
	dw $0762 
	dw $076B 
	dw $0773 
	dw $077B 
	dw $0783 
	dw $078A 
	dw $0790 
	dw $0797 
	dw $079D 
	dw $07A2 
	dw $07A7 
	dw $07AC 
	dw $07B1 
	dw $07B6 
	dw $07BA 
	dw $07BE 
	dw $07C1 
	dw $07C4 
	dw $07C8 
	dw $07CB 
	dw $07CE 
	dw $07D1 
	dw $07D4 
	dw $07D6 
	dw $07D9 
	dw $07DB 
	dw $07DD 
	dw $07DF

;5962 - 59B7?, a table of five byte entries that get copied into ch4 (noise) data - volume, length, length, poly, counter
	db $00, $00, $00, $00, $00 ;none
	db $C0, $82, $00, $F8, $5E ;noise 1
	db $C0, $42, $00, $00, $70 ;noise 2
	db $80, $57, $00, $00, $60 ;noise 3
	db $80, $F1, $00, $F4, $5E ;noise 4
	db $C0, $A1, $00, $00, $3F ;noise 5
	db $C0, $65, $00, $00, $80 ;noise 6
	db $80, $87, $00, $00, $60 ;noise 7
	db $80, $20, $00, $00, $47 ;noise 8
	db $80, $10, $00, $00, $47 ;noise 9
	db $80, $20, $00, $00, $54 ;noise A
	db $80, $10, $00, $00, $80 ;noise B
	db $80, $20, $00, $00, $55 ;noise C
	db $80, $30, $00, $00, $56 ;noise D
	db $80, $81, $00, $3A, $10 ;noise E
	db $C0, $80, $00, $00, $10 ;noise F
	db $C0, $23, $33, $45, $67 ;unknown if this is used, looks to overlap data?

SECTION "6:5A13", ROMX[$5A13], BANK[6]
NotelengthTable20: ;5A13, notelength table
	db $01, $02, $04, $08, $10, $20 
	db $06, $0C, $18 
NotelengthTable30:	;5A1C
	db $00, $03, $06, $0C, $18, $30 
	db $09, $12, $24 
	
	db $04, $08
NotelengthTable40: ;5A27: notelength table
	db $02, $04, $08, $10, $20, $40
	db $0C, $18, $30 
	
	db $05, $03, $01 
NotelengthTable50: ;5A33
	db $03, $05, $0A, $14, $28, $50 
	db $0F, $1E, $3C
NotelengthTable60: ;5A3C
	db $03, $06, $0C, $18, $30, $60
	db $12, $24, $48
;5A45
	db $08, $10, $02, $01
	db $04, $16, $14 
NotelengthTable70: ;5A4C
	db $03, $07, $0E, $1C, $38, $70 
	db $15, $2A, $54 
	db $09, $12, $02, $01, $09, $05
	
NotelengthTable80: ;5A5B: notelength table
	db $04, $08, $10, $20, $40, $80
	db $18, $30, $60
NotelengthTable90:;5A64 
	db $04, $09, $12, $24, $48, $90 
	db $1B, $36, $6C 
	db $0C, $18

;5A6F, volumes table?
	db $10, $20, $A7, $87, $60, $00, $47

TrackStereoTable: ;5A76 - 5B65, table of six-byte entries, stereo settings for each song. first byte is mode, second byte is threshold, then final four bytes are the stereo values.
	db $01, $00, $FF, $FF, $FF, $FF 
	db $01, $00, $FF, $00, $00, $00 
	db $01, $38, $FF, $F7, $FE, $7F 
	db $01, $00, $FF, $FF, $FF, $FF 
	db $01, $C0, $FF, $00, $00, $00 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $00, $FF, $FF, $FF, $FF 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $FF, $7F, $FF 
	db $01, $38, $FF, $F7, $FE, $7F 
	db $01, $60, $FF, $00, $00, $00 
	db $01, $C0, $FF, $00, $00, $00 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $02, $0C, $7F, $FF, $F7, $FF 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $00, $FF, $FF, $FF, $FF 
	db $01, $00, $FF, $FF, $FF, $FF 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $08, $FF, $FF, $FE, $FF 
	db $00, $00, $FF, $FF, $FF, $FF 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $02, $0C, $FF, $7F, $FF, $F7 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F 
	db $01, $18, $FF, $5F, $D7, $5F

	
TrackIDsIntro: ;5B66, level intro
	db $0A, $1A, $13, $10, $1A, $24, $24, $24, $24, $03, $0A, $0F
TrackIDsSpotted: ;5B72, enemy spotted track
	db $19, $19, $19, $19, $19, $19, $19, $19, $19, $17, $19, $0F
TrackIDsAmbient: ;5B7E, calm ambience
	db $0B, $1B, $0C, $0D, $1B, $25, $25, $25, $25, $03, $0B, $0F
TrackIDsObjective: ;5B8A, collected item/did objective track?
	db $0C, $1B, $0C, $19, $19, $25, $25, $25, $25, $03, $0B, $0F
TrackIDsJustSpotted: ;5B96, copy of TrackIDsSpotted
	db $19, $19, $19, $19, $19, $19, $19, $19, $19, $17, $19, $0F
	
LooseWave1: ;5BA2, wave data?
	db $03, $7B, $FF, $F7, $00, $FF, $BB, $77, $44, $40, $44, $40, $44, $40, $00, $00
LooseWave2: ;5BB2, wave data?
	db $03, $7B, $FF, $F7, $00, $FF, $BB, $77, $44, $44, $44, $00, $00, $00, $00, $00

LooseSection1: ;5BC2
	musLoadNoteData $a0, $21, $81
	musSectionEnd
LooseSection2: ;5BC7
	musLoadNoteData $c0, $0, $80
	musSectionEnd
LooseSection3: ;5BCC
	musLoadNoteData $40, $21, $81
	musSectionEnd
LooseSection4: ;5BD1
	musLoadNoteData $c5, $0, $80
	musSectionEnd
	
LooseSection5: ;5BD6, a music section? (c1)
	musLoadNoteData $40, $0, $40
	musSectionEnd
LooseSection6: ;5BDB, music section (c1)
	musLoadNoteData $50, $0, $40
	musSectionEnd
LooseSection7: ;5BE0
	musLoadNoteData $c0, $0, $40
	musSectionEnd
LooseSection8: ;5BE5, music section (c2)
	musLoadNoteData $60, $81, $0
	musSectionEnd
LooseSection9: ;5BEA, music section (c2)
	musLoadNoteData $80, $81, $0
	musSectionEnd
LooseSectionA: ;5BEF
	musLoadNoteData $83, $0, $0
	musSectionEnd
LooseSectionB: ;5BF4
	musLoadNoteData $84, $0, $1
	musSectionEnd
LooseSectionC: ;5BF9
	musLoadNoteData $80, $0, $0
	musSectionEnd
;5BFE
	musLoadNoteData $49, $0, $0
	musSectionEnd
;5C03
	musLoadNoteData $10, $0, $43
	musSectionEnd
;5C08
	musLoadNoteData $4a, $0, $43
	musSectionEnd
;5C0D
	musLoadNoteData $81, $0, $0
	musSectionEnd


Track_LevelIntro: ;5C12
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, .c4
.c1
	dw .c1s1
	musJUMP .c1
.c2
	dw .c2s1
	musJUMP .c2
.c3 ;5C29
	dw .c3s1
	musJUMP .c3
.c4 ;5C2F
	dw .c4s1
	musJUMP .c4
.c1s1 ;5C35
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
.c2s1 ;5C38
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
.c3s1 ;5C3B
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
.c4s1 ;5C3E
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
	
Track_Urgent: ;5C41
	SongHeader 0, NotelengthTable40, .c1, .c2, .c3, .c4
.c1 ;5C4C
	dw $71AD, 
:	dw .c1s2
	musJUMP :-
.c2 ;5C54
	dw $71AD 
:	dw .c2s2 
	musJUMP :-
.c3 ;5C5C
	dw $71AD, 
:	dw .c3s2
	musJUMP :-
.c4 ;5C64
	dw $71B0
:	dw .c4s2
	musJUMP :-
	
.c1s2 ;5C6C
	musLoadNoteData $60, $0, $3
	musSetLoop $20
	musNoteLengthFromTable $7
	musNote $40
	musNote $58
	musLoop
	musSectionEnd
.c2s2 ;5C77
	musLoadNoteData $e0, $81, $80
	musSetLoop $20
	musNoteLengthFromTable $3
	musNote $1c
	musLoop
	musSectionEnd
.c3s2 ;5C81
	musLoadWaveData Track_TitleScreen.w1, $20
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $60
	musNote $62
	musNote $64
	musNote $66
	musNote $68
	musNote $6a
	musNote $6c
	musNote $6e
	musNote $72
	musNote $6e
	musNote $72
	musNote $6e
	musNote $72
	musNote $6e
	musNote $72
	musNote $6e
	musNote $72
	musNote $6e
	musNote $72
	musNote $6a
	musNote $68
	musNote $66
	musNote $64
	musNote $62
	musNote $60
	musNote $5e
	musNote $5c
	musNote $5a
	musNote $58
	musNote $56
	musNote $54
	musLoop
	musSectionEnd
.c4s2 ;5CA9
	musSetLoop $3
	musNoteLengthFromTable $5
	musNote $10
	musNoteLengthFromTable $1
	musNote $b
	musNote $b
	musNote $b
	musNote $b
	musLoop
	musNoteLengthFromTable $5
	musNote $24
	musNoteLengthFromTable $1
	musNote $b
	musNote $b
	musNote $b
	musNote $b
	musSectionEnd
	
Track_FinalMission: ;5CBB
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER
.c1 ;5CC6
	dw .c1s1
:	dw .c1s2
	musJUMP :-
.c2 ;5CCE
	dw .c2s1
:	dw .c2s2
	musJUMP :-
.c3 ;5CD6
	dw .c3s1 
:	dw .c3s2
	musJUMP :-

.c1s1 ;5CDE
	musLoadNoteData $a2, $0, $40
	musNoteLengthFromTable $0
	musNote $68
	musNote $80
	musNote $68
	musNote $80
	musNote $6a
	musNote $82
	musNote $6a
	musNote $82
	musNoteLengthFromTable $1
	musNote $20
	musNote $22
	musNote $20
	musNote $22
	musLoadNoteData $80, $0, $40
	musNote $20
	musNote $22
	musNote $20
	musNote $22
.c1s2 ;5CF8
	musSetLoop $20
	musNote $20
	musNote $22
	musLoop
	musSectionEnd
.c2s1 ;5CFE
	musLoadNoteData $c0, $81, $0
	musNoteLengthFromTable $2
	musNote $38
	musNote $3a
	musNoteLengthFromTable $1
	musNote $16
	musNote $18
	musNote $16
	musNote $18
	musLoadNoteData $a0, $81, $0
	musNote $16
	musNote $18
	musNote $16
	musNote $18
	musLoadNoteData $80, $81, $0
	musSetLoop $a
	musNote $16
	musNote $18
	musLoop
.c2s2 ;5D1B
	musLoadNoteData $4e, $83, $80
	musNoteLengthFromTable $4
	musNote $3a
	musNote $3c
	musNote $30
	musLoadNoteData $40, $0, $81
	musNoteLengthFromTable $4
	musNote $30
	musLoadNoteData $81, $0, $0
	musSetLoop $20
	musNoteLengthFromTable $1
	musNote $18
	musLoop
	musSectionEnd
;5D33
	musSectionEnd
.c3s1 ;5D34
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $1
	musNote $46
	musRepeatNote
	musNote $48
	musRepeatNote
.c3s2 ;5D3D
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $16
	musRepeatNote
	musNote $18
	musRepeatNote
	musLoop
	musSectionEnd
	
Track_07: ;5D46
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, Track_LevelIntro.c4
.c1 ;5D51
	dw .c1s1 
	dw .c1s5 
	dw .c1s5 
	dw .c1s2 
	dw .c1s5 
	dw .c1s3
	dw .c1s5
	dw .c1s4 
	dw .c1s5 
	dw .c1s5 
	dw .c1s3 
	dw .c1s5 
	dw .c1s2 
	dw .c1s5 
	musJUMP .c1
.c2 ;5D71
	dw .c2s1 
	dw .c2s5
	dw .c2s5 
	dw .c2s2 
	dw .c2s5 
	dw .c2s3 
	dw .c2s5 
	dw .c2s4 
	dw .c2s5 
	dw .c2s5 
	dw .c2s3 
	dw .c2s5 
	dw .c2s2 
	dw .c2s5 
	musJUMP .c2
.c3 ;5D91
	dw .c3s1 
	musJUMP .c3
	
.c1s1 ;5D97
	musLoadNoteLengthTable NotelengthTable80
	musLoadNoteData $73, $0, $80
	musSectionEnd
.c1s2 ;5D9F
	musLoadNoteData $93, $0, $80
	musSectionEnd
.c1s3 ;5DA4
	musLoadNoteData $b3, $0, $80
	musSectionEnd
.c1s4 ;5DA9
	musLoadNoteData $d3, $0, $80
	musSectionEnd
.c1s5 ;5DAE
	musNoteLengthFromTable $1
	musNote $a
	musNote $22
	musNote $a
	musNote $22
	musNote $a
	musNote $22
	musNote $22
	musNote $a
	musNote $22
	musNote $a
	musSectionEnd
	
.c2s1 ;5DBA
	musLoadNoteLengthTable NotelengthTable80
	musLoadNoteData $92, $0, $43
	musSectionEnd
.c2s2 ;5DC2
	musLoadNoteData $b2, $0, $43
	musSectionEnd
.c2s3 ;5DC7
	musLoadNoteData $d2, $0, $43
	musSectionEnd
.c2s4 ;5DCC
	musLoadNoteData $f2, $0, $43
	musSectionEnd
.c2s5 ;5DD1
	musSetLoop $a
	musNoteLengthFromTable $1
	musNote $18
	musLoop
	musSectionEnd

.c3s1 ;5DD7
	musLoadNoteLengthTable NotelengthTable80
	musLoadWaveData Track_TitleScreen.w1, $40
	musSetLoop $20
	musNoteLengthFromTable $3
	musNote $a
	musLoop
	musSectionEnd
	
Track_Presents: ;5DE4
	SongHeader 0, NotelengthTable80, .c1, .c2, Track_LevelIntro.c3, .c4
.c1
	dw .c1s1 
	dw .c1s2
	dw .c1s3
	musEND
.c2	
	dw .c2s1 
	dw .c2s2
	dw .c2s3
	musEND	
.c4	
	dw .c4s1
	musEND
	
.c1s1 ;5E03
	musNoteLengthFromTable $7
	musRepeatNote
	musNoteLengthFromTable $8
	musRepeatNote
	musSectionEnd
.c2s1 ;5E08
	musNoteLengthFromTable $7
	musRepeatNote
	musNoteLengthFromTable $8
	musRepeatNote
	musSectionEnd
.c4s1 ;5E0D
	musSetLoop $6
	musNoteLengthFromTable $0
	musNote $1a
	musLoop
	musNoteLengthFromTable $8
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $0
	musRepeatNote
	musSectionEnd
	
.c1s2 ;5E1D
	musLoadNoteData $a5, $0, $0
	musNoteLengthFromTable $1
	musNote $72
	musNote $7a
	musSectionEnd
.c1s3 ;5E25
	musLoadNoteData $a7, $0, $0
	musNoteLengthFromTable $5
	musNote $8a
	musNoteLengthFromTable $0
	musRepeatNote
	musSectionEnd
	
.c2s2 ;5E2E
	musLoadNoteData $a5, $0, $0
	musNoteLengthFromTable $0
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $74
	musSectionEnd
.c2s3 ;5E37
	musLoadNoteData $a7, $0, $0
	musNoteLengthFromTable $5
	musNote $84
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd
	
Track_Base: ;5E40
	SongHeader 0, NotelengthTable40, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1
	dw .c1s1
	musJUMP .c1
.c2
	dw .c2s1
	musJUMP .c2

.c1s1 ;5E57
	musLoadNoteData $81, $0, $80
	musSetLoop $2
	musNoteLengthFromTable $0
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $6e
	musNote $78
	musNote $6a
	musNote $60
	musNote $64
	musNote $5a
	musNote $5e
	musNote $6c
	musNoteLengthFromTable $0
	musRepeatNote
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $5
	musRepeatNote
	musLoop
	musSectionEnd
.c2s1 ;5E71
	musLoadNoteData $81, $0, $0
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $86
	musNote $90
	musNote $82
	musNote $78
	musNote $7c
	musNote $72
	musNote $76
	musNote $84
	musRepeatNote
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $5
	musRepeatNote
	musLoop
	musSectionEnd
	
Track_Ambient1WithIntro: ;5E88
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER
.c1 ;5E93
	dw .c1s1 
	dw .c1s2 
	dw .c1s3 
.l1	dw .c1l1 
	musJUMP .l1
.c2 ;5E9F	
	dw .c2s1 
	dw .c2s2
	dw .c2s3 
.l2	dw .c2l1 
	musJUMP .l2
.c3 ;5EAB	
	dw .c3s1 
.l3	dw .c3l1 
	musJUMP .l3
	
.c1s1 ;5EB3
	musLoadNoteData $e1, $0, $0
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $34
	musNote $3c
	musNote $42
	musNote $4c
	musNote $54
	musNote $5a
	musNote $64
	musNote $6c
	musNote $38
	musNote $3e
	musNote $48
	musNote $50
	musNote $56
	musNote $60
	musNote $68
	musNote $6e
	musNote $6e
	musNote $66
	musNote $5c
	musNote $56
	musNote $4e
	musNote $44
	musNote $3e
	musNote $36
	musNote $48
	musNote $42
	musNote $3a
	musNote $30
	musNote $2a
	musNote $22
	musNote $18
	musNote $12
	musSectionEnd
.c1s2 ;5EDB
	musLoadNoteData $c0, $0, $0
	musNoteLengthFromTable $3
	musNote $34
	musSectionEnd
.c1s3 ;5EE2
	musLoadNoteData $c7, $0, $0
	musNoteLengthFromTable $8
	musNote $34
	musSectionEnd
	
.c2s1 ;5EE9
	musLoadNoteData $e1, $0, $0
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $42
	musNote $4c
	musNote $54
	musNote $5a
	musNote $64
	musNote $6c
	musNote $72
	musNote $7c
	musNote $48
	musNote $50
	musNote $56
	musNote $60
	musNote $68
	musNote $6e
	musNote $78
	musNote $80
	musNote $7e
	musNote $74
	musNote $76
	musNote $66
	musNote $5c
	musNote $56
	musNote $4e
	musNote $5c
	musNote $5a
	musNote $52
	musNote $48
	musNote $42
	musNote $3a
	musNote $30
	musNote $2a
	musNote $22
	musSectionEnd
.c2s2 ;5F11
	musLoadNoteData $c0, $0, $0
	musNoteLengthFromTable $3
	musNote $26
	musSectionEnd
.c2s3 ;5F18
	musLoadNoteData $c7, $0, $0
	musNoteLengthFromTable $8
	musNote $26
	musSectionEnd
	
.c3s1 ;5F1F
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $e
	musNoteLengthFromTable $4
	musNote $18
	musRepeatNote
	musSectionEnd
;5F2B
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c1l1 ;5F31
	musLoadNoteLengthTable NotelengthTable60
	musLoadNoteData $49, $81, $0
	musSetLoop $20
	musNoteLengthFromTable $1
	musNote $70
	musRepeatNote
	musNote $7a
	musNote $8e
	musRepeatNote
	musRepeatNote
	musLoop
	musSectionEnd
.c2l1 ;5F43
	musLoadNoteLengthTable NotelengthTable60
	musLoadNoteData $d, $84, $80
	musSetLoop $20
	musNoteLengthFromTable $4
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $90
	musRepeatNote
	musLoop
	musSectionEnd
.c3l1 ;5F53
	musLoadNoteLengthTable NotelengthTable60
	musSetLoop $20
	musNoteLengthFromTable $5
	musRepeatNote
	musLoop
	musSectionEnd
	
Track_Ambient1: ;5F5C
	SongHeader 0, NotelengthTable60, Track_Ambient1WithIntro.l1, Track_Ambient1WithIntro.l2, Track_Ambient1WithIntro.l3, BLANK_POINTER
	
Track_MissionComplete: ;5F67
	SongHeader 2, NotelengthTable80, .c1, .c2, .c3, Track_LevelIntro.c4
.c1 ;5F72
	dw LooseSection5
	dw .c1s1
	dw LooseSection6
	dw .c1s2 
	dw .c1s3 
	dw .c1s4 
:	dw LooseSection5
	dw .c1s5 
	dw .c1s5 
	musJUMP :-
.c2 ;5F88
	dw LooseSection8
	dw .c2s1 
	dw LooseSection9
	dw .c2s2 
	dw .c2s3 
	dw .c2s4 
:	dw LooseSection8
	dw .c2s5 
	musJUMP :-
.c3 ;5F9C
	dw .c3s1 
	dw .c3s2
:	dw .c3s3 
	musJUMP :-

.c1s1 ;5FA6
	musSetLoop $2
	musNoteLengthFromTable $0
	musNote $26
	musNote $2e
	musNote $34
	musNote $26
	musNote $2e
	musNote $34
	musNote $26
	musNote $46
	musNote $34
	musNote $26
	musNote $46
	musNote $4c
	musNote $26
	musNote $46
	musNote $4c
	musNote $26
	musNote $4c
	musNote $46
	musNote $26
	musNote $4c
	musNote $46
	musNote $26
	musNote $4c
	musNote $46
	musNote $26
	musNote $34
	musNote $46
	musNote $26
	musNote $34
	musNote $2e
	musLoop
	musSectionEnd
.c1s2 ;5FC9
	musNote $26
	musNote $2e
	musNote $34
	musNote $26
	musNote $2e
	musNote $34
	musNote $26
	musNote $46
	musNote $34
	musNote $26
	musNote $46
	musNote $4c
	musLoadNoteData $60, $0, $40
	musNote $26
	musNote $46
	musNote $4c
	musNote $26
	musNote $46
	musNote $4c
	musLoadNoteData $70, $0, $40
	musNote $26
	musNote $5e
	musNote $4c
	musNote $26
	musNote $5e
	musNote $64
	musSectionEnd
.c1s3 ;5FEA
	musLoadNoteData $80, $0, $40
	musNote $1c
	musNote $32
	musNote $38
	musNote $2a
	musNote $32
	musNote $38
	musNote $2a
	musNote $4a
	musNote $50
	musNote $4a
	musNote $2a
	musNote $38
	musNote $4a
	musNote $2a
	musNote $38
	musNote $32
	musSectionEnd
.c1s4 ;5FFF
	musLoadNoteData $60, $0, $40
	musNote $2a
	musNote $32
	musNote $38
	musNote $2a
	musNote $32
	musNote $38
	musNote $2a
	musNote $4a
	musNote $50
	musNote $4a
	musNote $2a
	musNote $38
	musNote $4a
	musNote $2a
	musNote $38
	musNote $32
	musSectionEnd
.c1s5 ;6014
	musNote $20
	musNote $1a
	musNote $20
	musNote $2a
	musNote $20
	musNote $2a
	musNote $32
	musNote $2a
	musNote $32
	musNote $38
	musNote $32
	musNote $38
	musNote $42
	musNote $38
	musNote $42
	musNote $4a
	musNote $42
	musNote $4a
	musNote $50
	musNote $4a
	musNote $50
	musNote $5a
	musNote $50
	musNote $5a
	musNote $62
	musNote $5a
	musNote $62
	musNote $68
	musNote $62
	musNote $68
	musNote $72
	musNote $68
	musNote $42
	musNote $7a
	musNote $72
	musNote $7a
	musNote $80
	musNote $8a
	musNote $80
	musNote $7a
	musNote $80
	musNote $7a
	musNote $72
	musNote $7a
	musNote $72
	musNote $68
	musNote $72
	musNote $68
	musNote $62
	musNote $68
	musNote $62
	musNote $5a
	musNote $62
	musNote $5a
	musNote $50
	musNote $5a
	musNote $50
	musNote $4a
	musNote $50
	musNote $4a
	musNote $42
	musNote $4a
	musNote $42
	musNote $38
	musNote $42
	musNote $38
	musNote $32
	musNote $38
	musNote $32
	musNote $2a
	musNote $32
	musNote $2a
	musSectionEnd

.c2s1 ;605D
	musNoteLengthFromTable $0
	musNote $56
	musNote $4c
	musNote $46
	musNote $4c
	musNote $46
	musNote $3e
	musNote $46
	musNote $3e
	musNote $34
	musNote $3e
	musNote $34
	musNote $2e
	musNote $26
	musNote $2e
	musNote $34
	musNote $2e
	musNote $34
	musNote $3e
	musNote $34
	musNote $3e
	musNote $46
	musNote $3e
	musNote $46
	musNote $4c
	musNote $46
	musNote $4c
	musNote $56
	musNote $4c
	musNote $56
	musNote $5e
	musNote $56
	musNote $5e
	musNote $64
	musNote $5e
	musNote $64
	musNote $6e
	musNote $64
	musNote $6e
	musNote $76
	musNote $6e
	musNote $76
	musNote $7c
	musLoadNoteData $70, $81, $0
	musNote $86
	musNote $7c
	musNote $76
	musNote $7c
	musNote $76
	musNote $6e
	musNote $76
	musNote $6e
	musNote $64
	musNote $6e
	musNote $64
	musNote $5e
	musNote $64
	musNote $5e
	musNote $56
	musNote $5e
	musNote $56
	musNote $4c
	musSectionEnd
.c2s2 ;609F
	musNote $56
	musNote $4c
	musNote $46
	musNote $4c
	musNote $46
	musNote $3e
	musNote $46
	musNote $3e
	musNote $34
	musNote $3e
	musNote $34
	musNote $2e
	musLoadNoteData $90, $81, $0
	musNote $26
	musNote $2e
	musNote $34
	musNote $3e
	musNote $46
	musNote $4c
	musNote $56
	musNote $5e
	musNote $64
	musNote $6e
	musNote $76
	musNote $7c
	musSectionEnd
.c2s3 ;60BC
	musLoadNoteData $a0, $81, $0
	musNote $80
	musNote $8a
	musNote $80
	musNote $7a
	musNote $80
	musNote $7a
	musNote $72
	musNote $7a
	musNote $72
	musNote $68
	musNote $72
	musNote $68
	musNote $62
	musNote $68
	musNote $62
	musNote $5a
	musNote $62
	musNote $5a
	musNote $50
	musSectionEnd
.c2s4 ;60D4
	musLoadNoteData $80, $81, $0
	musNote $5a
	musNote $50
	musNote $4a
	musNote $50
	musNote $4a
	musNote $42
	musNote $4a
	musNote $42
	musNote $38
	musLoadNoteData $60, $81, $0
	musNote $42
	musNote $38
	musNote $32
	musNote $38
	musNote $32
	musNote $2a
	musNote $20
	musNote $2a
	musNote $32
	musNote $2a
	musNote $32
	musNote $38
	musNote $32
	musNote $38
	musNote $42
	musNote $38
	musNote $42
	musNote $4a
	musSectionEnd
.c2s5 ;60F8
	musNote $42
	musNote $4a
	musNote $50
	musNote $4a
	musNote $50
	musNote $5a
	musNote $50
	musNote $5a
	musNote $62
	musNote $5a
	musNote $62
	musNote $68
	musNote $62
	musNote $68
	musNote $72
	musNote $68
	musNote $72
	musNote $7a
	musNote $72
	musNote $7a
	musNote $80
	musNote $8a
	musNote $80
	musNote $7a
	musNote $80
	musNote $7a
	musNote $72
	musNote $7a
	musNote $72
	musNote $68
	musNote $72
	musNote $68
	musNote $62
	musNote $68
	musNote $62
	musNote $5a
	musNote $62
	musNote $5a
	musNote $50
	musNote $5a
	musNote $50
	musNote $4a
	musSectionEnd

.c3s1 ;6123
	musLoadWaveData Track_TitleScreen.w1, $40
	musNoteLengthFromTable $5
	musNote $18
	musNoteLengthFromTable $8
	musNote $18
	musNoteLengthFromTable $2
	musNote $18
	musNoteLengthFromTable $8
	musNote $18
	musSectionEnd
.c3s2 ;6130
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $2
	musNote $4
	musLoadWaveData Track_TitleScreen.w1, $40
	musNote $4
	musSectionEnd
.c3s3 ;613C
	musLoadWaveData Track_Results.wav1, $40
	musSetLoop $20
	musNoteLengthFromTable $5
	musNote $1c
	musLoop
	musSectionEnd

Track_SiloInterior: ;6146
	SongHeader 0, NotelengthTable40, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1
	dw .c1s1 
	dw .c1s2 
	dw .c1s3 
	dw .c1s1 
	dw .c1s2 
	dw .c1s3 
	dw .c1s1
	musJUMP .c1
.c2
	dw .c2s1 
	dw .c2s2 
	dw .c2s3 
	dw .c2s1 
	dw .c2s2 
	dw .c2s3 
	dw .c2s1
	musJUMP .c2

.c1s1 ;6175
	musLoadNoteData $10, $0, $43
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $82
	musLoop
	musSetLoop $10
	musNote $82
	musLoop
	musSectionEnd
.c1s2 ;6183
	musLoadNoteData $1c, $0, $43
	musNoteLengthFromTable $4
	musNote $82
	musSectionEnd
.c1s3 ;618A
	musLoadNoteData $76, $0, $43
	musNote $82
	musSectionEnd

.c2s1 ;6190
	musLoadNoteData $10, $0, $0
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $82
	musLoop
	musSetLoop $10
	musNote $82
	musLoop
	musSectionEnd
.c2s2 ;619E
	musLoadNoteData $1c, $0, $0
	musNoteLengthFromTable $4
	musNote $82
	musSectionEnd
.c2s3 ;61A5
	musLoadNoteData $76, $0, $0
	musNote $82
	musSectionEnd

Track_ItemReveal: ;61AB
	SongHeader 0, NotelengthTable40, .c1, .c2, .c3, BLANK_POINTER
.w1 ;61B6
	db $11, $11, $22, $22, $33, $33, $44, $44, $11, $11, $22, $22, $33, $33, $44, $44
.c1 ;61C6
	dw .c1s1 
	dw .c1s2 
	dw .c1s3 
	dw .c1s4 
.l1	dw .c1s5 
	dw .c1s5
	dw .c1s5
	dw .c1s6
	dw .c1s7
	musJUMP .l1
.c2 ;61DC
	dw .c2s1 
	dw .c2s2
	dw .c2s3
	dw .c2s4
.l2	dw LooseSection1
	dw .c2s5
	dw LooseSection2 
	dw .c2s6
	dw LooseSection1
	dw .c2s7
	dw LooseSection1
	dw .c2s5
	dw LooseSection2 
	dw .c2s6
	dw LooseSection1
	dw .c2s7
	dw LooseSection1
	dw .c2s5
	dw LooseSection2
	dw .c2s6
	dw LooseSection1
	dw .c2s8
	dw .c2s9
	dw .c2s10 
	dw .c2s11 
	dw .c2s12
	musJUMP .l2
.c3 ;6214
	dw .c3s1 
	dw .c3s2
	dw .c3s3
.l3	dw .c3s4
	musJUMP .l3

.c1s1 ;6220
	musLoadNoteData $40, $0, $43
	musNoteLengthFromTable $3
	musRepeatNote
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $82
	musLoop
	musSetLoop $20
	musNote $82
	musLoop
	musSetLoop $20
	musNote $82
	musLoop
	musSetLoop $26
	musNote $82
	musLoop
	musSectionEnd
.c1s2 ;6238
	musLoadNoteData $4a, $0, $43
	musNoteLengthFromTable $4
	musNote $82
	musSectionEnd

.c2s1 ;623F
	musLoadNoteData $40, $0, $0
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $82
	musNote $82
	musNote $82
	musNote $82
	musNoteLengthFromTable $6
	musNote $82
	musSectionEnd
.c2s2 ;624D
	musLoadNoteData $4a, $0, $0
	musNoteLengthFromTable $4
	musNote $6a
	musSectionEnd

.c3s1 ;6254
	musLoadWaveData .w1, $63
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musSectionEnd
.c3s2 ;6262
	musLoadWaveData LooseWave1, $43
	musNoteLengthFromTable $3
	musNote $82
	musSectionEnd

.c1s3 ;6269
	musLoadNoteData $f2, $0, $81
	musNoteLengthFromTable $2
	musNote $58
	musNote $60
	musSectionEnd
.c1s4 ;6271
	musLoadNoteData $f4, $0, $81
	musNoteLengthFromTable $5
	musNote $70
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd

.c2s3 ;627A
	musLoadNoteData $f2, $0, $81
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $2
	musNote $5a
	musNote $66
	musSectionEnd
.c2s4 ;6284
	musLoadNoteData $f4, $0, $81
	musNoteLengthFromTable $5
	musNote $76
	musSectionEnd

.c3s3 ;628B
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd

.c1s5 ;629D
	musLoadNoteLengthTable NotelengthTable40
	musLoadNoteData $c1, $41, $40
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $46
	musNote $36
	musNote $3c
	musLoop
	musSetLoop $3
	musNote $40
	musNote $32
	musNote $36
	musLoop
	musNote $40
	musSetLoop $2
	musNote $4a
	musNote $36
	musNote $40
	musLoop
	musSetLoop $3
	musNote $4a
	musNote $3c
	musNote $46
	musLoop
	musNote $4a
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $46
	musNote $36
	musNote $3c
	musLoop
	musSetLoop $3
	musNote $40
	musNote $32
	musNote $36
	musLoop
	musNote $40
	musSetLoop $2
	musNote $4a
	musNote $36
	musNote $40
	musLoop
	musSetLoop $2
	musNote $4e
	musNote $40
	musNote $44
	musLoop
	musNote $4e
	musNote $58
	musNote $5c
	musNote $66
	musSectionEnd
.c1s6 ;62DE
	musLoadNoteData $a0, $81, $40
	musSetLoop $8
	musNoteLengthFromTable $3
	musNote $68
	musNoteLengthFromTable $2
	musNote $20
	musNote $38
	musLoop
	musSectionEnd
.c1s7 ;62EB
	musLoadNoteData $80, $0, $81
	musNoteLengthFromTable $0
	musNote $40
	musNote $42
	musNote $44
	musNote $46
	musNote $48
	musNote $4a
	musNote $4c
	musNote $4e
	musNoteLengthFromTable $4
	musNote $50
	musNoteLengthFromTable $1
	musNote $46
	musRepeatNote
	musNote $50
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $4c
	musNote $4e
	musNote $50
	musNote $52
	musNoteLengthFromTable $7
	musNote $54
	musNoteLengthFromTable $0
	musNote $56
	musNote $58
	musNote $5a
	musNote $5c
	musNoteLengthFromTable $7
	musNote $5e
	musNoteLengthFromTable $0
	musNote $58
	musNote $5a
	musNote $5c
	musNote $5e
	musNoteLengthFromTable $2
	musNote $60
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $90
	musNoteLengthFromTable $a
	musNote $8a
	musNote $90
	musNoteLengthFromTable $0
	musNote $8a
	musNoteLengthFromTable $a
	musNote $82
	musNote $8a
	musNoteLengthFromTable $0
	musNote $82
	musNoteLengthFromTable $a
	musNote $80
	musNote $82
	musNoteLengthFromTable $0
	musNote $80
	musNoteLengthFromTable $a
	musNote $78
	musNote $80
	musNoteLengthFromTable $0
	musNote $78
	musNoteLengthFromTable $a
	musNote $72
	musNote $78
	musNoteLengthFromTable $0
	musNote $72
	musNoteLengthFromTable $a
	musNote $6a
	musNote $72
	musNoteLengthFromTable $0
	musNote $6a
	musNoteLengthFromTable $a
	musNote $68
	musNote $6a
	musNoteLengthFromTable $0
	musNote $68
	musNoteLengthFromTable $a
	musNote $60
	musNote $68
	musNoteLengthFromTable $0
	musNote $60
	musNoteLengthFromTable $a
	musNote $5a
	musNote $60
	musNoteLengthFromTable $0
	musNote $5a
	musNoteLengthFromTable $a
	musNote $52
	musNote $5a
	musNoteLengthFromTable $0
	musNote $52
	musNoteLengthFromTable $a
	musNote $50
	musNote $52
	musNoteLengthFromTable $0
	musNote $50
	musNoteLengthFromTable $a
	musNote $48
	musNote $50
	musSectionEnd

.c2s5 ;6353
	musLoadNoteLengthTable NotelengthTable40
	musNoteLengthFromTable $1
	musNote $1e
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $8
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $8
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNoteLengthFromTable $8
	musNote $4a
	musNoteLengthFromTable $1
	musNote $40
	musRepeatNote
	musNote $4a
	musRepeatNote
	musNoteLengthFromTable $4
	musNote $4e
	musSectionEnd
.c2s6 ;63A1
	musNoteLengthFromTable $4
	musNote $58
	musNoteLengthFromTable $5
	musNote $58
	musSectionEnd
.c2s7 ;63A6
	musNoteLengthFromTable $5
	musNote $58
	musSectionEnd
.c2s8 ;63A9
	musNoteLengthFromTable $4
	musNote $58
	musSectionEnd
.c2s9 ;63AC
	musLoadNoteData $c0, $0, $1
	musNoteLengthFromTable $2
	musNote $44
	musNote $4e
	musNote $58
	musNote $5c
	musNoteLengthFromTable $0
	musNote $5c
	musNote $5e
	musNoteLengthFromTable $3
	musNote $60
	musNoteLengthFromTable $1
	musRepeatNote
	musNote $58
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $5a
	musNote $5c
	musNoteLengthFromTable $6
	musNote $5e
	musNoteLengthFromTable $3
	musNote $5e
	musNoteLengthFromTable $5
	musNote $5e
	musNoteLengthFromTable $0
	musNote $56
	musNote $58
	musNoteLengthFromTable $3
	musNote $5a
	musNoteLengthFromTable $1
	musRepeatNote
	musNote $52
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $54
	musNote $56
	musNoteLengthFromTable $6
	musNote $58
	musNoteLengthFromTable $3
	musNote $58
	musNoteLengthFromTable $5
	musNote $58
	musSectionEnd
.c2s10 ;63DA
	musLoadNoteData $e0, $21, $40
	musNoteLengthFromTable $8
	musNote $38
	musNoteLengthFromTable $2
	musNote $2e
	musNote $38
	musNoteLengthFromTable $4
	musNote $3c
	musNote $46
	musNoteLengthFromTable $7
	musNote $48
	musNoteLengthFromTable $2
	musNote $54
	musSectionEnd
.c2s11 ;63EB
	musLoadNoteData $e0, $0, $40
	musNoteLengthFromTable $4
	musNote $50
	musSectionEnd
.c2s12 ;63F2
	musLoadNoteData $e7, $0, $40
	musNoteLengthFromTable $5
	musNote $50
	musSectionEnd

.c3s4;63F9	
	musLoadNoteLengthTable NotelengthTable40
	musLoadWaveData LooseWave1, $20
	musSetLoop $3
	musNoteLengthFromTable $1
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNote $30
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $48
	musRepeatNote
	musNote $30
	musRepeatNote
	musLoop
	musSetLoop $10
	musNoteLengthFromTable $3
	musNote $a
	musLoop
	musNoteLengthFromTable $2
	musNote $30
	musNote $48
	musNote $18
	musNote $30
	musNote $2e
	musNote $46
	musNote $16
	musNote $2e
	musNoteLengthFromTable $2
	musNote $2c
	musNote $44
	musNote $14
	musNote $2c
	musNote $2a
	musNote $42
	musNote $12
	musNote $2a
	musNoteLengthFromTable $6
	musNote $28
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $3
	musNote $26
	musNoteLengthFromTable $5
	musNote $26
	musNoteLengthFromTable $3
	musRepeatNote
	musSectionEnd

Track_TitleScreen: ;64A8, first track data
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, .c4 ;byte, A1 pointer, then four pointers to each channel's data
.w1 ;64B3
	db $00, $88, $99, $AA, $BB, $CC, $DD, $EE, $00, $00, $00, $00, $FF, $FF, $FF, $FF
	
.c1 ;64C3
	dw .c1s1
:	dw .c1s2
	musJUMP :-
	
.c2 ;64CB
	dw .c2s1
:	dw .c2s2
	musJUMP :-
	
.c3 ;64D3
	dw .c3s1
:	dw .c3s2
	musJUMP :-
	
.c4 ;64DB
	dw .c4s1
	musJUMP Track_LevelIntro.c4
	
.c1s1 ;64E1
	musLoadNoteData $a1, $0, $0
.c1s2 ;64E5
	musSetLoop $2
	musNote $a0
	musNote $5a
	musNote $54
	musNote $4a
	musNote $42
	musNote $3c
	musNote $4a
	musNote $42
	musNote $3c
	musNote $32
	musNote $3c
	musNote $42
	musNote $32
	musNote $3c
	musNote $42
	musNote $4a
	musNote $54
	musLoop
	musNote $54
	musNote $4a
	musNote $42
	musNote $3c
	musNote $32
	musNote $2a
	musNote $32
	musNote $3c
	musNote $42
	musNote $4a
	musNote $54
	musNote $5a
	musNote $62
	musNote $6c
	musNote $72
	musNote $7a
	musNote $84
	musNote $8a
	musNote $84
	musNote $7a
	musNote $72
	musNote $6c
	musNote $62
	musNote $5a
	musNote $54
	musNote $4a
	musNote $42
	musNote $3c
	musNote $32
	musNote $3c
	musNote $42
	musNote $4a
	musSetLoop $2
	musNote $5e
	musNote $54
	musNote $4e
	musNote $46
	musNote $3c
	musNote $4e
	musNote $46
	musNote $3c
	musNote $36
	musNote $3c
	musNote $46
	musNote $36
	musNote $3c
	musNote $46
	musNote $4e
	musNote $54
	musLoop
	musNote $54
	musNote $4e
	musNote $46
	musNote $3c
	musNote $36
	musNote $2e
	musNote $36
	musNote $3c
	musNote $46
	musNote $4e
	musNote $54
	musNote $5e
	musNote $66
	musNote $6c
	musNote $76
	musNote $7e
	musNote $84
	musNote $8e
	musNote $84
	musNote $7e
	musNote $76
	musNote $6c
	musNote $66
	musNote $5e
	musNote $54
	musNote $4e
	musNote $46
	musNote $3c
	musNote $36
	musNote $3c
	musNote $46
	musNote $4e
	musSetLoop $2
	musNote $58
	musNote $50
	musNote $46
	musNote $40
	musNote $38
	musNote $46
	musNote $40
	musNote $38
	musNote $2e
	musNote $38
	musNote $40
	musNote $2e
	musNote $38
	musNote $40
	musNote $46
	musNote $50
	musLoop
	musNote $50
	musNote $46
	musNote $40
	musNote $38
	musNote $2e
	musNote $38
	musNote $40
	musNote $46
	musNote $50
	musNote $58
	musNote $5e
	musNote $68
	musNote $70
	musNote $76
	musNote $80
	musNote $88
	musNote $8e
	musNote $88
	musNote $80
	musNote $76
	musNote $70
	musNote $68
	musNote $5e
	musNote $58
	musNote $50
	musNote $46
	musNote $40
	musNote $38
	musNote $40
	musNote $46
	musNote $50
	musNote $58
	musSetLoop $2
	musNote $62
	musNote $5a
	musNote $50
	musNote $4a
	musNote $42
	musNote $50
	musNote $4a
	musNote $42
	musNote $38
	musNote $42
	musNote $4a
	musNote $38
	musNote $42
	musNote $4a
	musNote $50
	musNote $5a
	musLoop
	musNote $5a
	musNote $50
	musNote $4a
	musNote $42
	musNote $38
	musNote $32
	musNote $2a
	musNote $32
	musNote $38
	musNote $42
	musNote $4a
	musNote $50
	musNote $5a
	musNote $62
	musNote $68
	musNote $72
	musNote $7a
	musNote $80
	musNote $8a
	musNote $80
	musNote $7a
	musNote $72
	musNote $68
	musNote $62
	musNote $5a
	musNote $50
	musNote $4a
	musNote $42
	musNote $38
	musNote $42
	musNote $4a
	musNote $50
	musSectionEnd
.c2s1 ;65B3
	musLoadNoteData $c1, $0, $40
.c2s2 ;65B7
	musNote $a0
	musNote $7a
	musNote $72
	musNote $6c
	musNote $62
	musNote $5a
	musNote $54
	musNote $4a
	musNote $42
	musNote $3c
	musNote $32
	musNote $2a
	musNote $24
	musNote $1a
	musNote $12
	musNote $c
	musNote $2
	musNote $2
	musNote $c
	musNote $12
	musNote $1a
	musNote $24
	musNote $2a
	musNote $32
	musNote $3c
	musNote $42
	musNote $4a
	musNote $54
	musNote $5a
	musNote $62
	musNote $6c
	musNote $72
	musNote $7a
	musNote $72
	musNote $6c
	musNote $62
	musNote $5a
	musNote $54
	musNote $4a
	musNote $42
	musNote $3c
	musNote $32
	musNote $2a
	musNote $24
	musNote $1a
	musNote $12
	musNote $c
	musNote $2
	musNote $2
	musNote $c
	musNote $12
	musNote $1a
	musNote $24
	musNote $2a
	musNote $32
	musNote $3c
	musNote $42
	musNote $4a
	musNote $54
	musNote $5a
	musNote $62
	musNote $6c
	musNote $72
	musNote $7a
	musNote $84
	musNote $8e
	musNote $84
	musNote $7e
	musNote $76
	musNote $6c
	musNote $66
	musNote $5e
	musNote $54
	musNote $4e
	musNote $46
	musNote $3c
	musNote $36
	musNote $2e
	musNote $24
	musNote $1e
	musNote $16
	musNote $c
	musNote $c
	musNote $16
	musNote $1e
	musNote $24
	musNote $2e
	musNote $36
	musNote $3c
	musNote $46
	musNote $4e
	musNote $54
	musNote $5e
	musNote $66
	musNote $6c
	musNote $76
	musNote $7e
	musNote $76
	musNote $6c
	musNote $66
	musNote $5e
	musNote $54
	musNote $4e
	musNote $46
	musNote $3c
	musNote $36
	musNote $2e
	musNote $24
	musNote $1e
	musNote $16
	musNote $c
	musNote $2
	musNote $2
	musNote $c
	musNote $16
	musNote $1e
	musNote $24
	musNote $2e
	musNote $36
	musNote $3c
	musNote $46
	musNote $4e
	musNote $54
	musNote $5e
	musNote $66
	musNote $6c
	musNote $76
	musNote $7e
	musNote $84
	musNote $88
	musNote $80
	musNote $76
	musNote $70
	musNote $68
	musNote $5e
	musNote $58
	musNote $50
	musNote $46
	musNote $40
	musNote $38
	musNote $2e
	musNote $28
	musNote $20
	musNote $16
	musNote $10
	musNote $8
	musNote $8
	musNote $10
	musNote $16
	musNote $20
	musNote $28
	musNote $2e
	musNote $38
	musNote $40
	musNote $46
	musNote $50
	musNote $58
	musNote $5e
	musNote $68
	musNote $70
	musNote $76
	musNote $70
	musNote $68
	musNote $5e
	musNote $58
	musNote $50
	musNote $46
	musNote $40
	musNote $38
	musNote $2e
	musNote $28
	musNote $20
	musNote $16
	musNote $10
	musNote $8
	musNote $8
	musNote $10
	musNote $16
	musNote $20
	musNote $28
	musNote $2e
	musNote $38
	musNote $40
	musNote $46
	musNote $50
	musNote $58
	musNote $5e
	musNote $68
	musNote $70
	musNote $76
	musNote $80
	musNote $88
	musNote $8e
	musNote $8a
	musNote $80
	musNote $7a
	musNote $72
	musNote $68
	musNote $62
	musNote $5a
	musNote $50
	musNote $4a
	musNote $42
	musNote $38
	musNote $32
	musNote $2a
	musNote $20
	musNote $1a
	musNote $12
	musNote $8
	musNote $8
	musNote $12
	musNote $1a
	musNote $20
	musNote $2a
	musNote $32
	musNote $38
	musNote $42
	musNote $4a
	musNote $50
	musNote $5a
	musNote $62
	musNote $68
	musNote $72
	musNote $7a
	musNote $72
	musNote $68
	musNote $62
	musNote $5a
	musNote $50
	musNote $4a
	musNote $42
	musNote $38
	musNote $32
	musNote $2a
	musNote $20
	musNote $1a
	musNote $12
	musNote $8
	musNote $2
	musNote $2
	musNote $8
	musNote $12
	musNote $1a
	musNote $20
	musNote $2a
	musNote $32
	musNote $38
	musNote $42
	musNote $4a
	musNote $50
	musNote $5a
	musNote $62
	musNote $68
	musNote $72
	musNote $7a
	musNote $80
	musSectionEnd
.c3s1 ;66B9
	musLoadWaveData .w1, $20
.c3s2 ;66BD
	musNote $a5
	musNote $c
	musNote $c
	musNote $16
	musNote $16
	musNote $8
	musNote $8
	musNote $12
	musNote $12
	musSectionEnd
.c4s1 ;66C7
	musNoteLengthFromTable $3
	musNote $47
	musSectionEnd
	
Track_Ambient2: ;66CA, another track?
	SongHeader 0, NotelengthTable40, Track_ItemReveal.l1, Track_ItemReveal.l2, Track_ItemReveal.l3, BLANK_POINTER
	
Track_Ambient2WithIntro: ;66D5
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER
.c1 ;66E0
	dw Track_Ambient1WithIntro.c1s1
	dw Track_Ambient1WithIntro.c1s2 
	dw Track_Ambient1WithIntro.c1s3
	musJUMP Track_ItemReveal.l1
.c2 ;66EA
	dw Track_Ambient1WithIntro.c2s1 
	dw Track_Ambient1WithIntro.c2s2
	dw Track_Ambient1WithIntro.c2s3
	musJUMP Track_ItemReveal.l2
.c3 ;66F4
	dw Track_Ambient1WithIntro.c3s1
	musJUMP Track_ItemReveal.l3

Track_Alarm: ;66FA
	SongHeader 0, NotelengthTable20, .c1, .c2, .c3, Track_LevelIntro.c4
.c1 ;6705
	dw .c1s1
:	dw .c1s2
	dw .c1s3
	musJUMP :-
.c2 ;670F
	dw .c2s1
:	dw .c2s2
	musJUMP :-
.c3 ;6717
	dw .c3s1
:	dw .c3s2
	musJUMP :-
	
.c2s1 ;671f	
	musLoadNoteData $61, $0, $80
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c2s2 ;6728
	musNoteLengthFromTable $5
	musRepeatNote
	musSetLoop $e
	musNoteLengthFromTable $0
	musNote $42
	musNote $40
	musNote $42
	musRepeatNote
	musLoop
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd

.c1s1 ;6737
	musLoadNoteData $e0, $0, $40
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $34
	musNote $36
	musNote $38
	musNote $3a
	musNote $3c
	musNote $3e
	musNote $40
	musNote $42
	musNote $42
	musNote $40
	musNote $3e
	musNote $3c
	musNote $3a
	musNote $38
	musNote $36
	musNote $34
	musNote $32
	musNote $30
	musNote $2e
	musNote $2c
	musNoteLengthFromTable $1
	musNote $2a
	musNote $28
	musNote $26
	musNote $24
	musNote $22
	musNote $20
	musNote $1e
	musNote $1c
	musNote $1a
	musNote $18
	musNote $16
	musNote $14
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c1s2 ;6764
	musLoadNoteData $40, $0, $81
	musNoteLengthFromTable $3
	musNote $3c
	musNoteLengthFromTable $5
	musNote $3c
	musSectionEnd
.c1s3 ;676D
	musLoadNoteData $10, $0, $81
	musNoteLengthFromTable $3
	musNote $3c
	musNoteLengthFromTable $5
	musNote $3c
	musSectionEnd

.c3s1 ;6776
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $4c
	musNote $4e
	musNote $50
	musNote $52
	musNote $54
	musNote $56
	musNote $58
	musNote $5a
	musNote $5a
	musNote $58
	musNote $56
	musNote $54
	musNote $52
	musNote $50
	musNote $4e
	musNote $4c
	musNote $4a
	musNote $48
	musNote $46
	musNote $44
	musNoteLengthFromTable $1
	musNote $42
	musNote $40
	musNote $3e
	musNote $3c
	musNote $3a
	musNote $38
	musNote $36
	musNote $34
	musNote $32
	musNote $30
	musNote $2e
	musNote $2c
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
.c3s2 ;67A1
	musLoadWaveData Track_TitleScreen.w1, $40
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $5e
	musNote $60
	musNote $62
	musNote $64
	musNoteLengthFromTable $4
	musNote $66
	musNoteLengthFromTable $0
	musNote $64
	musNote $62
	musNote $78
	musLoop
	musSectionEnd
	
Track_Death: ;67B4	
	SongHeader 0, NotelengthTable40, .c1, .c2, .c3, Track_LevelIntro.c4
	
.w1 ;67BF
	db $00, $99, $AA, $BB, $CC, $DD, $EE, $FF, $09, $AB, $CD, $EF, $09, $AB, $CD, $EF
	
.c1 ;67CF
	dw .c1s1
	dw .c1s2 
:	dw LooseSectionA
	dw .c1s3
	dw LooseSectionB
	dw .c1s4
	dw LooseSectionA 
	dw .c1s5 
	dw LooseSectionB
	dw .c1s6 
	dw LooseSectionA
	dw .c1s3
	dw LooseSectionB 
	dw .c1s4 
	dw LooseSectionA
	dw .c1s5 
	dw LooseSectionB
	dw .c1s6
	dw .c1s7 
	musJUMP :-
.c2 ;67F9
	dw .c2s1 
	dw .c2s2 
:	dw LooseSectionA 
	dw .c2s3
	dw LooseSectionB
	dw .c2s4 
	dw LooseSectionA
	dw .c2s5 
	dw LooseSectionB
	dw .c2s6
	dw LooseSectionA
	dw .c2s3
	dw LooseSectionB
	dw .c2s4
	dw LooseSectionA 
	dw .c2s5
	dw LooseSectionB
	dw .c2s6
	dw .c2s7
	musJUMP :-
.c3 ;6823
	dw .c3s1 
	musJUMP Track_LevelIntro.c3
	
.c1s1 ;6829
	musLoadNoteData $e0, $0, $0
	musNoteLengthFromTable $0
	musNote $20
	musRepeatNote
	musNote $24
	musRepeatNote
	musNote $2a
	musRepeatNote
	musNote $2e
	musRepeatNote
	musNote $34
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $3c
	musRepeatNote
	musNote $42
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $26
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $3e
	musRepeatNote
	musNote $44
	musRepeatNote
	musNote $48
	musRepeatNote
	musNote $4e
	musRepeatNote
	musNote $52
	musRepeatNote
	musNote $56
	musRepeatNote
	musNoteLengthFromTable $2
	musRepeatNote
	musLoadNoteData $84, $0, $80
	musNoteLengthFromTable $2
	musNote $70
	musNote $78
	musLoadNoteData $87, $0, $80
	musNoteLengthFromTable $8
	musNote $88
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd
.c1s2 ;6868
	musLoadNoteData $a1, $0, $0
	musNoteLengthFromTable $0
	musNote $8e
	musNote $86
	musNote $80
	musNote $7c
	musNote $76
	musNote $6e
	musNote $68
	musNote $64
	musNote $5e
	musNote $56
	musNote $50
	musNote $4c
	musNote $76
	musNote $6e
	musNote $68
	musNote $64
	musNote $5e
	musNote $56
	musNote $50
	musNote $4c
	musNote $46
	musNote $3e
	musNote $38
	musNote $34
	musNote $5e
	musNote $56
	musNote $50
	musNote $4c
	musNote $46
	musNote $3e
	musNote $38
	musNote $34
	musNote $2e
	musNote $26
	musNote $20
	musNote $1c
	musNote $46
	musNote $3e
	musNote $38
	musNote $34
	musNote $2e
	musNote $26
	musNote $20
	musNote $1c
	musNote $16
	musNote $e
	musNote $8
	musNote $4
	musNoteLengthFromTable $7
	musRepeatNote
	musNoteLengthFromTable $8
	musRepeatNote
	musSectionEnd

.c2s1 ;68A2
	musLoadNoteData $f0, $0, $40
	musNoteLengthFromTable $0
	musNote $2a
	musRepeatNote
	musNote $2e
	musRepeatNote
	musNote $34
	musRepeatNote
	musNote $38
	musRepeatNote
	musNote $3e
	musRepeatNote
	musNote $42
	musRepeatNote
	musNote $46
	musRepeatNote
	musNote $4c
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $40
	musRepeatNote
	musNote $44
	musRepeatNote
	musNote $48
	musRepeatNote
	musNote $4e
	musRepeatNote
	musNote $52
	musRepeatNote
	musNote $58
	musRepeatNote
	musNote $5c
	musRepeatNote
	musNote $60
	musRepeatNote
	musNoteLengthFromTable $2
	musRepeatNote
	musLoadNoteData $84, $0, $80
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $2
	musNote $72
	musNote $7e
	musLoadNoteData $87, $0, $80
	musNoteLengthFromTable $8
	musNote $8e
	musSectionEnd
.c2s2 ;68E1
	musLoadNoteData $c1, $0, $40
	musNoteLengthFromTable $0
	musNote $2a
	musNote $34
	musNote $38
	musNote $34
	musNote $38
	musNote $42
	musNote $38
	musNote $42
	musNote $4c
	musNote $42
	musNote $4c
	musNote $50
	musNote $4c
	musNote $50
	musNote $5a
	musNote $50
	musNote $5a
	musNote $64
	musNote $5a
	musNote $64
	musNote $68
	musNote $64
	musNote $68
	musNote $72
	musNote $68
	musNote $72
	musNote $7c
	musNote $72
	musNote $7c
	musNote $80
	musNote $8a
	musNote $80
	musNote $7c
	musNote $72
	musNote $68
	musNote $64
	musNote $5a
	musNote $50
	musNote $4c
	musNote $42
	musNote $38
	musNote $34
	musNote $2a
	musNote $20
	musNote $1c
	musNote $12
	musNote $8
	musNote $4
	musNoteLengthFromTable $7
	musRepeatNote
	musNoteLengthFromTable $8
	musRepeatNote
	musLoadNoteLengthTable NotelengthTable30
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd

.c3s1 ;6920 (c3)
	musLoadWaveData .w1, $20
	musNoteLengthFromTable $1
	musNote $12
	musNote $16
	musNote $1c
	musNote $20
	musNote $26
	musNote $2a
	musNote $2e
	musNote $34
	musNote $14
	musNote $18
	musNote $1e
	musNote $22
	musNote $28
	musNote $2c
	musNote $30
	musNote $36
	musNote $3a
	musNote $40
	musNote $44
	musNote $48
	musNoteLengthFromTable $6
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $1a
	musNote $1c
	musNote $1e
	musNote $20
	musNoteLengthFromTable $2
	musNote $22
	musNoteLengthFromTable $4
	musNote $22
	musNoteLengthFromTable $0
	musNote $22
	musNote $20
	musNote $1e
	musNote $1c
	musNote $1a
	musNote $18
	musNote $16
	musNote $14
	musNote $12
	musNote $10
	musNote $e
	musNote $c
	musNoteLengthFromTable $8
	musNote $a
	musSectionEnd

.c1s3 ;6956
	musLoadNoteLengthTable NotelengthTable30
	musNoteLengthFromTable $2
	musNote $72
	musNote $7a
	musSectionEnd
.c1s4 ;695D
	musNoteLengthFromTable $5
	musNote $8a
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c1s5 ;6962
	musNoteLengthFromTable $2
	musNote $6c
	musNote $74
	musSectionEnd
.c1s6 ;6966
	musNoteLengthFromTable $5
	musNote $84
	musRepeatNote
	musSectionEnd
.c1s7 ;696A
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musSectionEnd

.c2s3 ;696F
	musNoteLengthFromTable $2
	musNote $74
	musNote $80
	musSectionEnd
.c2s4 ;6973
	musNoteLengthFromTable $5
	musNote $90
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c2s5 ;6978
	musNoteLengthFromTable $2
	musNote $6e
	musNote $7a
	musSectionEnd
.c2s6 ;697C
	musNoteLengthFromTable $5
	musNote $8a
	musRepeatNote
	musSectionEnd
.c2s7 ;6980
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musSectionEnd

Track_Results: ;6985
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, Track_LevelIntro.c4
.wav1
	db $00, $08, $89, $99, $AA, $BB, $BC, $C0, $00, $00, $00, $00, $00, $00, $BB, $CC
.c1 ;69A0
	dw .c1s1 
	musJUMP .c1
.c2 ;69A6
	dw .c2s1
	dw .c2s2
	dw .c2s3
	dw .c2s4
	musJUMP .c2
.c3 ;69B2
	dw .c3s1
	musJUMP .c3
	
.c1s1 ;69B8
	musLoadNoteData $60, $0, $80
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $1a
	musLoop
	musSectionEnd
	
.c2s1 ;69C2
	musLoadNoteData $d, $0, $80
	musNoteLengthFromTable $4
	musNote $28
	musSectionEnd
.c2s2 ;69C9
	musLoadNoteData $a0, $0, $80
	musNote $2c
	musSectionEnd
.c2s3 ;69CF
	musLoadNoteData $a7, $0, $80
	musNoteLengthFromTable $7
	musNote $2c
	musSectionEnd
.c2s4 ;69D6
	musLoadNoteData $61, $81, $40
	musNoteLengthFromTable $0
	musNote $32
	musNote $40
	musNote $44
	musNote $4a
	musNote $58
	musNote $5c
	musNote $62
	musNote $70
	musNote $74
	musNote $8c
	musNote $88
	musNote $7a
	musNote $74
	musNote $70
	musNote $62
	musNote $5c
	musNote $58
	musNote $4a
	musNote $44
	musNote $40
	musSectionEnd

.c3s1 ;69F0
	musLoadWaveData .wav1, $20
	musSetLoop $20
	musNoteLengthFromTable $5
	musNote $24
	musLoop
	musSectionEnd
	
Track_Tunnel: ;69FA
	SongHeader 0, NotelengthTable60, .c1, .c2, .c3, .c4
.c1 ;6A05
	dw .s1 
:	dw .c1s2
	dw .c1s3
	dw .c1s4
	musJUMP :-
.c2 ;6A11
	dw .s1
:	dw .c2s2
	dw .c2s3
	dw .c2s4
	dw LooseSection4
	dw .c2s5
	dw .c2s6
	musJUMP :-
.c3 ;6A23
	dw .s1
:	dw .c3s2
	dw .c3s3 
	musJUMP :-
.c4 ;6A2D
	dw .c4s1
:	dw .c4s2 
	musJUMP :-

.s1 ;6A35
	musNoteLengthFromTable $6
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c4s1
	musNoteLengthFromTable $7
	musRepeatNote
	musNoteLengthFromTable $1
	musRepeatNote
	musNote $1a
	musNote $1a
	musNote $1a
	musNote $1a
	musSectionEnd
	
.c1s2 ;6A43
	musLoadNoteData $a0, $21, $40
	musNoteLengthFromTable $3
	musNote $2c
	musNote $30
	musNote $26
	musNoteLengthFromTable $2
	musNote $2c
	musNote $30
	musNoteLengthFromTable $7
	musNote $3a
	musNoteLengthFromTable $2
	musNote $36
	musNoteLengthFromTable $3
	musNote $2c
	musNote $30
	musNoteLengthFromTable $3
	musNote $34
	musNoteLengthFromTable $2
	musNote $38
	musNoteLengthFromTable $1
	musNote $4c
	musNote $50
	musNoteLengthFromTable $1
	musNote $2e
	musNote $5e
	musNote $5a
	musNote $76
	musNoteLengthFromTable $2
	musNote $34
	musNote $38
	musNoteLengthFromTable $7
	musNote $42
	musNoteLengthFromTable $2
	musNote $3e
	musNoteLengthFromTable $3
	musNote $34
	musNote $38
	musNoteLengthFromTable $2
	musNote $3c
	musNote $32
	musNoteLengthFromTable $5
	musNote $3c
	musNoteLengthFromTable $8
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c1s3 ;6A76
	musLoadNoteData $a0, $21, $0
	musSetLoop $4
	musNoteLengthFromTable $1
	musNote $38
	musNote $20
	musNote $38
	musNote $20
	musNote $38
	musNote $20
	musNote $20
	musNote $38
	musNote $20
	musNote $38
	musNote $20
	musNote $38
	musNote $20
	musNote $38
	musNote $38
	musNote $20
	musLoop
	musSetLoop $4
	musNote $20
	musNote $38
	musNote $50
	musNote $38
	musNote $50
	musNote $38
	musNote $20
	musNote $50
	musNote $38
	musNote $50
	musNote $38
	musNote $20
	musNote $38
	musNote $50
	musNote $20
	musNote $38
	musLoop
	musSectionEnd
.c1s4 ;6AA2
	musLoadNoteData $a1, $0, $80
	musNoteLengthFromTable $0
	musNote $72
	musNote $6a
	musNote $72
	musNote $6a
	musNote $64
	musNote $6a
	musNote $64
	musNote $5c
	musNote $64
	musNote $5c
	musNote $56
	musNote $5c
	musNote $5a
	musNote $52
	musNote $5a
	musNote $52
	musNote $4c
	musNote $52
	musNote $4c
	musNote $44
	musNote $4c
	musNote $44
	musNote $3e
	musNote $44
	musNote $42
	musNote $3a
	musNote $42
	musNote $3a
	musNote $34
	musNote $3a
	musNote $34
	musNote $2c
	musNote $34
	musNote $2c
	musNote $26
	musNote $2c
	musNote $2a
	musNote $22
	musNote $2a
	musNote $22
	musNote $1c
	musNote $22
	musNote $1c
	musNote $14
	musNote $1c
	musNote $14
	musNote $e
	musNote $14
	musNoteLengthFromTable $4
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $6c
	musNote $72
	musNote $6c
	musNote $64
	musNote $6c
	musNote $64
	musNote $5e
	musNote $64
	musNote $5e
	musNote $56
	musNote $5e
	musNote $56
	musNote $54
	musNote $5a
	musNote $54
	musNote $4c
	musNote $54
	musNote $4c
	musNote $46
	musNote $4c
	musNote $46
	musNote $3e
	musNote $46
	musNote $3e
	musNote $3c
	musNote $42
	musNote $3c
	musNote $34
	musNote $3c
	musNote $34
	musNote $2e
	musNote $34
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $6a
	musNote $64
	musNote $6a
	musNote $64
	musNote $5c
	musNote $64
	musNote $5c
	musNote $5a
	musNote $5c
	musNote $5a
	musNote $52
	musNote $5a
	musNote $52
	musNote $4c
	musNote $52
	musNote $4c
	musNote $44
	musNote $4c
	musNote $44
	musNote $42
	musNote $44
	musNote $42
	musNote $3a
	musNote $42
	musNote $3a
	musNote $34
	musNote $3a
	musNote $34
	musNote $2c
	musNote $34
	musNote $2c
	musNote $2a
	musSetLoop $4
	musNoteLengthFromTable $1
	musNote $48
	musLoop
	musSetLoop $4
	musNote $4e
	musLoop
	musSetLoop $4
	musNote $52
	musLoop
	musSetLoop $4
	musNote $56
	musLoop
	musSectionEnd

.c2s2 ;6B32
	musLoadNoteData $c0, $21, $80
	musNoteLengthFromTable $3
	musNote $36
	musNote $3a
	musNote $30
	musNoteLengthFromTable $2
	musNote $36
	musNote $3a
	musNoteLengthFromTable $7
	musNote $44
	musNoteLengthFromTable $2
	musNote $40
	musNoteLengthFromTable $3
	musNote $36
	musNote $3a
	musNoteLengthFromTable $2
	musNote $3e
	musNote $34
	musNoteLengthFromTable $3
	musNote $42
	musNote $38
	musNoteLengthFromTable $2
	musNote $3e
	musNote $42
	musNoteLengthFromTable $7
	musNote $4c
	musNoteLengthFromTable $2
	musNote $48
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNoteLengthFromTable $2
	musNote $46
	musNote $3c
	musNoteLengthFromTable $5
	musNote $46
	musNoteLengthFromTable $8
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c2s3 ;6B5F
	musLoadNoteData $a0, $81, $40
	musSetLoop $4
	musNoteLengthFromTable $2
	musNote $3c
	musNoteLengthFromTable $1
	musNote $40
	musNote $3c
	musNoteLengthFromTable $2
	musNote $46
	musNoteLengthFromTable $1
	musNote $4a
	musNoteLengthFromTable $2
	musNote $3c
	musNoteLengthFromTable $1
	musNote $40
	musNote $3c
	musNote $40
	musNoteLengthFromTable $2
	musNote $46
	musNoteLengthFromTable $1
	musNote $4a
	musNote $38
	musLoop
	musSetLoop $4
	musNoteLengthFromTable $2
	musNote $34
	musNoteLengthFromTable $1
	musNote $38
	musNote $34
	musNoteLengthFromTable $2
	musNote $3e
	musNoteLengthFromTable $1
	musNote $42
	musNoteLengthFromTable $2
	musNote $34
	musNoteLengthFromTable $1
	musNote $38
	musNote $34
	musNote $38
	musNoteLengthFromTable $2
	musNote $3e
	musNoteLengthFromTable $1
	musNote $42
	musNote $30
	musLoop
	musSectionEnd
.c2s4 ;6B92
	musLoadNoteData $a6, $0, $80
	musNoteLengthFromTable $1
	musNote $72
	musSectionEnd
.c2s5 ;6B99
	musNote $6a
	musNote $64
	musNote $5c
	musNoteLengthFromTable $5
	musNote $5a
	musNoteLengthFromTable $8
	musRepeatNote
	musSectionEnd
.c2s6 ;6BA1
	musLoadNoteData $c4, $0, $81
	musNoteLengthFromTable $3
	musNote $3a
	musNote $3e
	musNote $34
	musNoteLengthFromTable $2
	musNote $3a
	musNote $3e
	musNoteLengthFromTable $7
	musNote $48
	musNoteLengthFromTable $2
	musNote $44
	musNoteLengthFromTable $3
	musNote $3a
	musNote $3e
	musNoteLengthFromTable $2
	musNote $42
	musNote $38
	musNoteLengthFromTable $5
	musNote $42
	musNoteLengthFromTable $8
	musRepeatNote
	musNoteLengthFromTable $2
	musNote $5a
	musNote $4c
	musNoteLengthFromTable $3
	musNote $5a
	musLoadNoteData $60, $0, $81
	musNoteLengthFromTable $4
	musNote $5a
	musLoadNoteData $c1, $0, $80
	musSetLoop $4
	musNoteLengthFromTable $0
	musNote $56
	musNote $6e
	musLoop
	musSetLoop $4
	musNote $5c
	musNote $74
	musLoop
	musSetLoop $4
	musNote $60
	musNote $78
	musLoop
	musSetLoop $4
	musNote $64
	musNote $7c
	musLoop
	musSectionEnd

.c3s2 ;6BDF
	musLoadWaveData LooseWave2, $20
	musNoteLengthFromTable $2
	musNote $18
	musNote $30
	musNote $1c
	musNote $34
	musNote $12
	musNote $2a
	musNote $10
	musNote $28
	musNote $e
	musNote $26
	musNote $18
	musNote $30
	musNote $a
	musNote $22
	musNote $4
	musNote $1c
	musNote $8
	musNote $20
	musNote $c
	musNote $24
	musNote $18
	musNote $30
	musNote $16
	musNote $2e
	musNote $8
	musNote $20
	musNote $12
	musNote $2a
	musNote $18
	musNote $30
	musNote $c
	musNote $24
	musSetLoop $f
	musNote $8
	musNote $20
	musLoop
	musSetLoop $21
	musNote $8
	musNote $20
	musLoop
	musSectionEnd
.c3s3 ;6C0F
	musSetLoop $f
	musNote $e
	musNote $26
	musLoop
	musNote $a
	musNote $22
	musSetLoop $8
	musNote $8
	musNote $20
	musLoop
	musSetLoop $4
	musNote $6
	musNote $1e
	musLoop
	musNote $4
	musNote $1c
	musNote $a
	musNote $22
	musNote $e
	musNote $26
	musNote $12
	musNote $2a
	musSectionEnd

.c4s2 ;6C29
	musSetLoop $f
	musNote $15
	musNote $47
	musNote $47
	musNote $47
	musNote $1a
	musNote $47
	musNote $47
	musNote $47
	musLoop
	musSetLoop $11
	musNote $15
	musNote $47
	musNote $47
	musNote $47
	musNote $1a
	musNote $47
	musNote $47
	musNote $47
	musLoop
	musSetLoop $e
	musNote $15
	musNote $47
	musNote $47
	musNote $47
	musNote $1a
	musNote $47
	musNote $47
	musNote $47
	musLoop
	musSetLoop $2
	musNote $15
	musNote $47
	musNote $47
	musNote $47
	musLoop
	musNote $15
	musNote $47
	musNote $1a
	musNote $47
	musNote $1a
	musNote $1a
	musNote $47
	musNote $1a
	musSectionEnd

Track_Recap: ;6C5A
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, Track_LevelIntro.c4
.c2 ;6C65
	dw .c1s1
:	dw .c1s2
	dw .c1s3
	musJUMP :-
.c1 ;6C6F
	dw .c2s1
:	dw .c2s2
	musJUMP :-
.c3 ;6C77
	dw .c3s1
:	dw .c3s2
	musJUMP :-
	
.c1s1 ;6C7F
	musLoadNoteData $f7, $0, $80
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $a
	musNoteLengthFromTable $8
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c2s1 ;6C8B
	musLoadNoteData $e7, $0, $0
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $4
	musNote $18
	musSectionEnd
.c3s1 ;6C94
	musLoadNoteData $b3, $64, $20
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $a
	musSectionEnd
.c1s2 ;6C9D
	musLoadNoteData $f, $0, $80
	musNoteLengthFromTable $4
	musNote $c
	musSectionEnd
.c1s3 ;6CA4
	musLoadNoteData $a7, $0, $80
	musNoteLengthFromTable $5
	musNote $c
	musRepeatNote
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c2s2 ;6CAE
	musLoadNoteData $40, $0, $0
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $18
	musLoop
	musSectionEnd
.c3s2 ;6CB8
	musLoadNoteData $b3, $64, $40
	musSetLoop $20
	musNoteLengthFromTable $5
	musNote $a
	musLoop
	musSectionEnd
	
Track_Encounter: ;6CC2
	SongHeader 0, NotelengthTable40, .c1, .c2, .c3, BLANK_POINTER
.c1 ;6CCD
	dw LooseSection7
	dw .c1s1
	dw LooseSection8
	dw .c1s2 
	dw LooseSection7 
	dw .c1s1 
	dw LooseSection8
	dw .c1s2
	dw LooseSection2
	dw .c1s3 
	dw LooseSection4
	dw .c1s4 
	dw LooseSection2 
	dw .c1s5 
	dw LooseSection4
	dw .c1s6  
	dw LooseSection7
	dw .c1s1 
	dw LooseSection8 
	dw .c1s2 
	musJUMP .c1
.c2 ;6CF9
	dw .c2s1 
	dw LooseSection3
	dw .c2s2 
	dw .c2s1
	dw .c2s2 
	dw LooseSectionC 
	dw .c2s3
	dw .c2s4 
	dw LooseSectionC
	dw .c2s5
	dw .c2s4 
	dw .c2s1 
	dw LooseSection3 
	dw .c2s2 
	musJUMP .c2
.c3 ;6D19
	dw .c3s1 
	dw .c3s1 
	dw .c3s1 
	dw .c3s1  
	dw .c3s2 
	dw .c3s2 
	dw .c3s1 
	dw .c3s1 
	musJUMP .c3

.c1s1 ;6D2D
	musNoteLengthFromTable $4
	musNote $36
	musNote $38
	musSectionEnd
.c1s2 ;6D31
	musSetLoop $18
	musNoteLengthFromTable $2
	musNote $1e
	musLoop
	musSectionEnd
.c1s3 ;6D37
	musNoteLengthFromTable $5
	musNote $3c
	musNoteLengthFromTable $8
	musNote $3e
	musSectionEnd
.c1s4 ;6D3C
	musNoteLengthFromTable $3
	musNote $3e
	musSectionEnd
.c1s5 ;6D3F
	musNoteLengthFromTable $4
	musNote $3c
	musNoteLengthFromTable $5
	musNote $3e
	musNoteLengthFromTable $3
	musNote $3e
	musSectionEnd
.c1s6 ;6D46
	musNote $3e
	musSectionEnd

.c2s1 ;6D48
	musLoadNoteData $a0, $0, $0
	musSetLoop $8
	musNoteLengthFromTable $0
	musNote $44
	musNote $5c
	musLoop
	musSetLoop $8
	musNote $46
	musNote $5e
	musLoop
	musSectionEnd
.c2s2 ;6D58
	musLoadNoteData $60, $21, $80
	musNoteLengthFromTable $8
	musNote $38
	musNoteLengthFromTable $2
	musNote $36
	musNote $38
	musNoteLengthFromTable $8
	musNote $3a
	musNoteLengthFromTable $2
	musNote $38
	musNote $3a
	musNoteLengthFromTable $5
	musNote $3c
	musSectionEnd
.c2s3 ;6D69
	musNoteLengthFromTable $5
	musNote $32
	musNoteLengthFromTable $8
	musNote $34
	musSectionEnd
.c2s4 ;6D6E
	musLoadNoteData $47, $0, $0
	musNoteLengthFromTable $3
	musNote $34
	musSectionEnd
.c2s5 ;6D75
	musNoteLengthFromTable $4
	musNote $32
	musNoteLengthFromTable $5
	musNote $34
	musNoteLengthFromTable $3
	musNote $34
	musSectionEnd

.c3s1 ;6D7C
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musNote $28
	musRepeatNote
	musSetLoop $2
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musLoop
	musNote $28
	musRepeatNote
	musNote $28
	musRepeatNote
	musSetLoop $2
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musLoop
	musNote $28
	musRepeatNote
	musNote $28
	musRepeatNote
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musSectionEnd
.c3s2 ;6DA0
	musNoteLengthFromTable $1
	musNote $32
	musRepeatNote
	musNote $32
	musRepeatNote
	musSetLoop $2
	musNote $1a
	musRepeatNote
	musNote $32
	musRepeatNote
	musLoop
	musNote $32
	musRepeatNote
	musNote $32
	musRepeatNote
	musSetLoop $2
	musNote $1a
	musRepeatNote
	musNote $32
	musRepeatNote
	musLoop
	musNote $32
	musRepeatNote
	musNote $32
	musRepeatNote
	musNote $1a
	musRepeatNote
	musNote $32
	musRepeatNote
	musSectionEnd

Track_Ambient4WithIntro: ;6DC0
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER

.c1 ;6DCB
	dw Track_Ambient1WithIntro.c1s1
	dw Track_Ambient1WithIntro.c1s2
	dw Track_Ambient1WithIntro.c1s3
.l1	dw LooseSection6 
	dw .c1s1
	dw .c1s2
	dw .c1s3
	dw LooseSection3  
	dw .c1s4
	dw .c1s5
	dw LooseSection3
	dw .c1s6
	musJUMP .l1
.c2 ;6DE7
	dw Track_Ambient1WithIntro.c2s1
	dw Track_Ambient1WithIntro.c2s2 
	dw Track_Ambient1WithIntro.c2s3
.l2	dw LooseSection2 
	dw .c2s1
	dw .c2s2
	dw .c2s3
	dw LooseSection2
	dw .c2s4
	dw .c2s5
	dw LooseSection2
	dw .c2s6
	dw .c2s7
	dw LooseSection7  
	dw .c2s8
	dw .c2s9
	musJUMP .l2
.c3 ;6E0B
	dw Track_Ambient1WithIntro.c3s1  
.l3	dw .c3s1 
	dw .c3s1
	dw .c3s2
	dw .c3s3
	dw .c3s4
	musJUMP .l3
	
.c1s1 ;6E1B
	musNoteLengthFromTable $3
	musNote $32
	musNote $36
	musSetLoop $c
	musNoteLengthFromTable $2
	musNote $2c
	musLoop
	musSectionEnd
.c1s2 ;6E24
	musNoteLengthFromTable $3
	musNote $32
	musNote $36
	musSetLoop $c
	musNoteLengthFromTable $2
	musNote $2c
	musLoop
	musNoteLengthFromTable $3
	musNote $32
	musNote $36
	musNote $2c
	musNoteLengthFromTable $2
	musNote $3a
	musNoteLengthFromTable $4
	musNote $2c
	musNoteLengthFromTable $2
	musNote $3c
	musSetLoop $8
	musNote $3c
	musLoop
	musSectionEnd
.c1s3 ;6E3B
	musLoadNoteData $60, $81, $40
	musSetLoop $8
	musNoteLengthFromTable $1
	musNote $4a
	musNote $46
	musNote $38
	musNote $3c
	musLoop
	musSetLoop $b
	musNote $4a
	musNote $46
	musNote $38
	musNote $3c
	musLoop
	musSetLoop $7
	musNote $48
	musNote $44
	musNote $36
	musNote $3a
	musLoop
	musSectionEnd
.c1s4 ;6E56
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNote $38
	musNoteLengthFromTable $2
	musNote $3e
	musNote $42
	musNoteLengthFromTable $7
	musNote $4c
	musNoteLengthFromTable $2
	musNote $48
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNoteLengthFromTable $2
	musNote $46
	musNote $3c
	musSectionEnd
.c1s5 ;6E68
	musLoadNoteData $40, $0, $80
	musNoteLengthFromTable $3
	musNote $46
	musSectionEnd
.c1s6 ;6E6F
	musNoteLengthFromTable $5
	musNote $46
	musSectionEnd

.c2s1 ;6E72
	musNoteLengthFromTable $3
	musNote $3c
	musNote $40
	musNoteLengthFromTable $5
	musNote $36
	musNoteLengthFromTable $4
	musNote $36
	musSectionEnd
.c2s2 ;6E7A
	musNoteLengthFromTable $3
	musNote $3c
	musNote $40
	musNoteLengthFromTable $4
	musNote $36
	musNoteLengthFromTable $5
	musNote $36
	musNoteLengthFromTable $3
	musNote $3c
	musNote $40
	musNote $36
	musNoteLengthFromTable $2
	musNote $44
	musNoteLengthFromTable $6
	musNote $3a
	musNoteLengthFromTable $1
	musNote $36
	musNoteLengthFromTable $7
	musNote $40
	musNoteLengthFromTable $1
	musNote $40
	musNote $3c
	musNoteLengthFromTable $2
	musNote $4a
	musNoteLengthFromTable $8
	musNote $4a
	musNoteLengthFromTable $5
	musNote $4a
	musRepeatNote
	musSectionEnd
.c2s3 ;6E98
	musLoadNoteData $60, $81, $81
	musNoteLengthFromTable $1
	musNote $62
	musNote $66
	musNote $68
	musNote $66
	musNote $68
	musNote $66
	musNoteLengthFromTable $6
	musNote $6c
	musNoteLengthFromTable $1
	musNote $68
	musNote $5e
	musNote $62
	musSectionEnd
.c2s4 ;6EAA
	musNoteLengthFromTable $3
	musNote $66
	musNoteLengthFromTable $5
	musNote $66
	musSectionEnd
.c2s5 ;6EAF
	musLoadNoteData $80, $81, $80
	musNoteLengthFromTable $1
	musNote $62
	musNote $66
	musNote $68
	musNote $66
	musNote $68
	musNote $66
	musNoteLengthFromTable $6
	musNote $6c
	musNoteLengthFromTable $1
	musNote $68
	musNote $5e
	musNote $62
	musSectionEnd
.c2s6 ;6EC1
	musNoteLengthFromTable $5
	musNote $64
	musNoteLengthFromTable $8
	musNote $64
	musSectionEnd
.c2s7 ;6EC6
	musLoadNoteData $80, $24, $41
	musNoteLengthFromTable $3
	musNote $30
	musNote $34
	musNote $2a
	musNoteLengthFromTable $2
	musNote $30
	musNote $34
	musNoteLengthFromTable $7
	musNote $3e
	musNoteLengthFromTable $2
	musNote $3a
	musNoteLengthFromTable $3
	musNote $30
	musNote $34
	musNoteLengthFromTable $2
	musNote $38
	musNote $2e
	musSectionEnd
.c2s8 ;6EDC
	musNoteLengthFromTable $3
	musNote $38
	musSectionEnd
.c2s9 ;6EDF
	musLoadNoteData $80, $24, $41
	musNoteLengthFromTable $5
	musNote $38
	musSectionEnd

.c3s1 ;6EE6
	musLoadNoteData $a2, $5b, $20
	musNoteLengthFromTable $3
	musNote $1e
	musNote $22
	musSetLoop $4
	musNoteLengthFromTable $0
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musLoop
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNote $30
	musRepeatNote
	musSectionEnd
.c3s2 ;6F04
	musNoteLengthFromTable $3
	musNote $1e
	musNote $22
	musNoteLengthFromTable $0
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNoteLengthFromTable $2
	musNote $26
	musNote $24
	musNoteLengthFromTable $0
	musNote $c
	musRepeatNote
	musNote $24
	musRepeatNote
	musNote $24
	musRepeatNote
	musNote $c
	musRepeatNote
	musNote $24
	musRepeatNote
	musNote $24
	musRepeatNote
	musNote $c
	musRepeatNote
	musNote $24
	musRepeatNote
	musSetLoop $3
	musNote $2a
	musRepeatNote
	musNote $2a
	musRepeatNote
	musNote $12
	musRepeatNote
	musNote $2a
	musRepeatNote
	musNote $12
	musRepeatNote
	musLoop
	musNote $2a
	musRepeatNote
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c3s3 ;6F37
	musLoadNoteData $a2, $5b, $40
	musSetLoop $5
	musNoteLengthFromTable $0
	musNote $5a
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musNoteLengthFromTable $0
	musNote $58
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musLoop
	musNoteLengthFromTable $0
	musNote $5a
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musSetLoop $e
	musNoteLengthFromTable $0
	musNote $56
	musRepeatNote
	musNote $52
	musRepeatNote
	musLoop
	musSectionEnd
.c3s4 ;6F56
	musLoadNoteData $a2, $5b, $40
	musNoteLengthFromTable $3
	musNote $2a
	musNote $2e
	musNote $24
	musNote $22
	musNote $20
	musNote $2c
	musNote $2a
	musNote $22
	musSetLoop $6
	musNote $24
	musLoop
	musSectionEnd
	
Track_Ambient4: ;6F68
	SongHeader 0, NotelengthTable80, Track_Ambient4WithIntro.l1, Track_Ambient4WithIntro.l2, Track_Ambient4WithIntro.l3, BLANK_POINTER
	
Track_Ambient3: ;6F73
	SongHeader 0, NotelengthTable80, Track_Ambient3WithIntro.l1, Track_Ambient3WithIntro.l2, Track_Ambient3WithIntro.l3, BLANK_POINTER
	
Track_Ambient3WithIntro: ;6F7E
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER
.w1 ;6F89
	db $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA, $00, $00, $00, $00, $00, $00, $00, $00
.c1 ;6F99
	dw Track_Ambient1WithIntro.c1s1  
	dw Track_Ambient1WithIntro.c1s2  
	dw Track_Ambient1WithIntro.c1s3 
.l1	dw .c1s1  
	musJUMP .l1
.c2 ;6FA5
	dw Track_Ambient1WithIntro.c2s1 
	dw Track_Ambient1WithIntro.c2s2 
	dw Track_Ambient1WithIntro.c2s3  
.l2	dw .c2s1  
	musJUMP .l2
.c3 ;6FB1
	dw Track_Ambient1WithIntro.c3s1 
.l3	dw .c3s1 
	musJUMP .l3
	
.c1s1 ;6FB9
	musLoadNoteData $80, $41, $81
	musSetLoop $10
	musNoteLengthFromTable $2
	musNote $30
	musNote $34
	musLoop
	musSetLoop $10
	musNote $32
	musNote $36
	musLoop
	musSectionEnd
.c2s1 ;6FC9
	musLoadNoteData $c0, $81, $81
	musSetLoop $2
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNoteLengthFromTable $2
	musNote $38
	musNoteLengthFromTable $1
	musNote $38
	musNote $3e
	musNoteLengthFromTable $5
	musNote $38
	musNoteLengthFromTable $3
	musRepeatNote
	musLoop
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNote $38
	musNoteLengthFromTable $2
	musNote $3e
	musNote $42
	musNoteLengthFromTable $7
	musNote $4c
	musNoteLengthFromTable $2
	musNote $48
	musNoteLengthFromTable $3
	musNote $3e
	musNote $42
	musNoteLengthFromTable $2
	musNote $46
	musNote $3c
	musNoteLengthFromTable $5
	musNote $46
	musNoteLengthFromTable $8
	musRepeatNote
	musSectionEnd
.c3s1 ;6FF2
	musLoadWaveData .w1, $20
	musSetLoop $10
	musNoteLengthFromTable $0
	musNote $48
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNote $4c
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musLoop
	musSetLoop $8
	musNote $4a
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNote $4e
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musLoop
	musNoteLengthFromTable $2
	musRepeatNote
	musSetLoop $2
	musNoteLengthFromTable $0
	musNote $6c
	musRepeatNote
	musNote $6a
	musRepeatNote
	musNote $6c
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musLoop
	musNote $6c
	musRepeatNote
	musNote $6a
	musRepeatNote
	musNote $6c
	musRepeatNote
	musNote $74
	musRepeatNote
	musSetLoop $3
	musNote $6c
	musRepeatNote
	musNote $6a
	musRepeatNote
	musNote $6c
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musLoop
	musNote $6c
	musRepeatNote
	musNote $6a
	musRepeatNote
	musNote $6c
	musRepeatNote
	musNote $74
	musRepeatNote
	musNote $6c
	musRepeatNote
	musNote $6a
	musRepeatNote
	musSectionEnd
	
Track_Boss: ;703B
	SongHeader 4, NotelengthTable80, Track_FinalMission.c1, Track_FinalMission.c2, Track_FinalMission.c3, BLANK_POINTER
	
Track_Scientist: ;7046
	SongHeader 0, NotelengthTable60, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1 ;7051
	dw .c1s1 
	musJUMP .c1
.c2 ;7057
	dw .c2s1 
:	dw .c2s2
	musJUMP :-
	
.c1s1 ;705F
	musLoadNoteData $61, $0, $80
	musNoteLengthFromTable $2
	musNote $7a
	musNote $6c
	musNote $70
	musNote $7e
	musNote $6c
	musNote $70
	musSectionEnd
.c2s1 ;706B
	musLoadNoteData $41, $81, $40
	musNoteLengthFromTable $6
	musRepeatNote
.c2s2 ;7071
	musNoteLengthFromTable $2
	musNote $7a
	musNote $6c
	musNote $70
	musNote $7e
	musNote $6c
	musNote $70
	musSectionEnd
	
Track_Imposter: ;7079
	SongHeader 0, NotelengthTable60, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1 ;7084
	dw .c1s1
	musEND
.c2 ;7088
	dw .c2s1
	musEND

.c1s1 ;708C
	musLoadNoteData $61, $0, $80
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $7a
	musNote $6e
	musNote $70
	musNote $7c
	musNote $6e
	musNote $70
	musLoop
	musNoteLengthFromTable $1
	musRepeatNote
	musSetLoop $a
	musNoteLengthFromTable $8
	musRepeatNote
	musLoop
	musNoteLengthFromTable $0
	musRepeatNote
	musSectionEnd
.c2s1 ;70A4
	musLoadNoteData $41, $81, $40
	musNoteLengthFromTable $6
	musRepeatNote
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $7a
	musNote $6e
	musNote $70
	musNote $7c
	musNote $6e
	musNote $70
	musLoop
	musNoteLengthFromTable $8
	musRepeatNote
	musLoadNoteData $61, $0, $80
	musNoteLengthFromTable $3 ;totaka's song starts here!
	musNote $4a
	musNoteLengthFromTable $1
	musNote $4a
	musNote $4e
	musNoteLengthFromTable $3
	musNote $52
	musNoteLengthFromTable $2
	musNote $4e
	musNoteLengthFromTable $7
	musNote $4a
	musNote $58
	musNote $52
	musNote $62
	musNoteLengthFromTable $8
	musNote $58
	musNoteLengthFromTable $3
	musNote $58
	musNoteLengthFromTable $1
	musNote $58
	musNote $5a
	musNoteLengthFromTable $3
	musNote $58
	musNoteLengthFromTable $2
	musNote $56
	musNoteLengthFromTable $8
	musNote $50
	musNoteLengthFromTable $7
	musNote $4e
	musNoteLengthFromTable $0
	musNote $56
	musNoteLengthFromTable $8
	musNote $58
	musNoteLengthFromTable $5
	musNote $4a
	musSectionEnd
	
Track_Eerie: ;70DE
	SongHeader 0, NotelengthTable80, .c1, .c2, Track_LevelIntro.c3, .c4
.c1 ;70E9
	dw .c1s1
:	dw .s3 
	dw .c1s2 
	dw .c1s2  
	dw .s4
	dw .c1s2
	dw .s5
	dw .c1s2 
	dw .s6
	dw .c1s2 
	dw .s5
	dw .c1s2  
	dw .s4
	dw .c1s2  
	musJUMP :-
.c2 ;7109
	dw .c2s1
:	dw .s3 
	dw .c2s2 
	dw .c2s2 
	dw .s4
	dw .c2s2 
	dw .s5 
	dw .c2s2 
	dw .s6 
	dw .c2s2 
	dw .s5
	dw .c2s2 
	dw .s4 
	dw .c2s2 
	musJUMP :-
.c4 ;7129
	dw .c4s1 
	musJUMP Track_LevelIntro.c4
	
.c1s1 ;712F
	musLoadNoteData $f6, $0, $0
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $a
	musSetLoop $4
	musRepeatNote
	musLoop
	musSectionEnd

.c2s1 ;713C
	musLoadNoteData $f6, $0, $40
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $18
	musSetLoop $4
	musRepeatNote
	musLoop
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd

.c4s1 ;714B
	musNoteLengthFromTable $2
	musRepeatNote
	musNoteLengthFromTable $5
	musNote $24
	musSectionEnd

.c1s2 ;7050
	musSetLoop $8
	musNoteLengthFromTable $0
	musNote $16
	musLoop
	musSectionEnd

.c2s2 ;7156
	musSetLoop $8
	musNoteLengthFromTable $0
	musNote $18
	musLoop
	musSectionEnd

.s3 ;715C
	musLoadNoteData $26, $0, $80
	musSectionEnd
.s4 ;7161
	musLoadNoteData $36, $0, $80
	musSectionEnd
.s5 ;7166
	musLoadNoteData $46, $0, $80
	musSectionEnd
.s6 ;716B
	musLoadNoteData $56, $0, $80
	musSectionEnd
	
Track_TunnelTraining: ;7170
	SongHeader 0, NotelengthTable60, .c1, .c2, .c3, .c4
.c1 ;717B
	dw .s1
	dw .c1s2
	dw .c1s2
	dw .c1s3 
:	dw .c1s4
	musJUMP :-
.c2 ;7189
	dw .s1 
	dw .c2s2  
	dw .c2s2 
	dw .c2s3
:	dw .c2s4
	musJUMP :-
.c3 ;7197
	dw .s1
	dw .c3s2 
	dw .c3s2 
	dw .c3s3
:	dw .c3s4
	musJUMP :-
.c4 ;71A5
	dw .c4s1
:	dw .c4s2
	musJUMP :-

.s1 ;71AD
	musNoteLengthFromTable $3
	musRepeatNote
	musSectionEnd
.c4s1 ;71B0
	musNoteLengthFromTable $3
	musRepeatNote
	musSectionEnd
.c1s2 ;71B3
	musLoadNoteData $a0, $0, $40
	musNoteLengthFromTable $1
	musNote $32
	musNote $3a
	musNote $2c
	musNote $32
	musNote $36
	musNote $3e
	musNote $30
	musNote $36
	musLoadNoteData $61, $0, $0
	musNote $48
	musNote $48
	musNote $60
	musNote $48
	musNote $60
	musNote $60
	musNote $48
	musNote $60
	musNote $6a
	musNote $70
	musNote $66
	musNote $6a
	musNote $60
	musNote $66
	musNote $5c
	musNote $60
	musNote $48
	musNote $48
	musNote $60
	musNote $48
	musNote $60
	musNote $78
	musNote $48
	musNote $60
	musLoadNoteData $a0, $0, $40
	musNote $32
	musNote $3a
	musNote $2c
	musNote $32
	musNote $36
	musNote $3e
	musNote $30
	musNote $36
	musLoadNoteData $81, $0, $0
	musSetLoop $2
	musNote $48
	musNote $48
	musRepeatNote
	musNote $48
	musRepeatNote
	musNote $4e
	musNote $52
	musNote $58
	musLoop
.c1s3 ;71F7
	musNote $3e
	musRepeatNote
	musNote $3e
	musNote $3e
	musNote $44
	musNote $48
	musRepeatNote
	musNote $3e
	musSectionEnd
.c2s2 ;7200
	musLoadNoteData $80, $0, $80
	musNoteLengthFromTable $3
	musNote $40
	musNote $44
	musNoteLengthFromTable $5
	musNote $3a
	musNoteLengthFromTable $4
	musNote $3a
	musNoteLengthFromTable $3
	musNote $40
	musNoteLengthFromTable $6
	musNote $44
	musNoteLengthFromTable $0
	musNote $40
	musNote $44
	musNoteLengthFromTable $5
	musNote $3a
.c2s3 ;7214
	musNoteLengthFromTable $4
	musNote $36
	musSectionEnd
.c3s2 ;7217
	musLoadWaveData LooseWave1, $20
	musNoteLengthFromTable $2
	musNote $1e
	musNoteLengthFromTable $1
	musNote $36
	musRepeatNote
	musNoteLengthFromTable $2
	musNote $22
	musNoteLengthFromTable $1
	musNote $3a
	musRepeatNote
	musSetLoop $6
	musNoteLengthFromTable $2
	musNote $14
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $2
	musNote $14
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musLoop
.c3s3 ;7235
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $10
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musLoop
	musSectionEnd
.c4s2 ;723E
	musNoteLengthFromTable $1
	musNote $15
	musNote $47
	musNoteLengthFromTable $2
	musNote $4c
	musNoteLengthFromTable $1
	musNote $1a
	musNote $47
	musNoteLengthFromTable $2
	musNote $4c
	musSectionEnd
.c1s4 ;7249
	musLoadNoteData $60, $81, $41
	musNoteLengthFromTable $3
	musNote $40
	musNote $46
	musNote $4a
	musNoteLengthFromTable $2
	musNote $40
	musNoteLengthFromTable $3
	musNote $46
	musNote $4a
	musNoteLengthFromTable $2
	musNote $40
	musNoteLengthFromTable $3
	musNote $46
	musNote $4a
	musNote $3c
	musNote $40
	musNote $44
	musNoteLengthFromTable $2
	musNote $3c
	musNoteLengthFromTable $3
	musNote $40
	musNote $44
	musNoteLengthFromTable $2
	musNote $3c
	musNoteLengthFromTable $3
	musNote $40
	musNote $44
	musNote $46
	musNote $4a
	musNote $4e
	musNoteLengthFromTable $2
	musNote $46
	musNoteLengthFromTable $3
	musNote $4a
	musNote $4e
	musNoteLengthFromTable $2
	musNote $46
	musNoteLengthFromTable $3
	musNote $4a
	musNote $4e
	musNote $54
	musNote $58
	musNote $5c
	musNoteLengthFromTable $2
	musNote $54
	musNoteLengthFromTable $3
	musNote $58
	musNote $5c
	musNoteLengthFromTable $2
	musNote $54
	musNote $4a
	musNote $54
	musNote $4e
	musNote $46
	musSectionEnd
.c2s4 ;7284
	musLoadNoteData $61, $0, $80
	musNoteLengthFromTable $2
	musNote $66
	musNote $62
	musNote $66
	musNoteLengthFromTable $1
	musNote $6c
	musNoteLengthFromTable $2
	musNote $66
	musNoteLengthFromTable $1
	musNote $66
	musNoteLengthFromTable $2
	musNote $62
	musNote $66
	musNote $6c
	musSectionEnd
.c3s4 ;7297
	musSetLoop $8
	musNoteLengthFromTable $2
	musNote $1a
	musNoteLengthFromTable $1
	musNote $32
	musRepeatNote
	musLoop
	musSetLoop $4
	musNoteLengthFromTable $2
	musNote $1e
	musNoteLengthFromTable $1
	musNote $36
	musRepeatNote
	musLoop
	musSetLoop $4
	musNoteLengthFromTable $2
	musNote $10
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musLoop
	musSectionEnd

Track_Credits: ;72B0
	SongHeader 0, NotelengthTable50, .c1, .c2, .c3, BLANK_POINTER
.c1 ;72BB
	dw .c1s1
	dw .c1s2
	dw .c1s2 
	dw .c1s2 
	dw .c1s2
	dw .c1s3 
	dw .c1s2
	dw .c1s2
	dw .c1s3
	dw .c1s2
	dw .c1s2
	dw .c1s4 
	dw .c1s3 
	dw .c1s2 
	dw .c1s2 
	dw .c1s3 
	dw .c1s2
	dw .c1s2 
	dw .c1s5 
	dw .c1s2
	dw .c1s5
	dw .c1s6 
	musEND
.c2 ;72E9
	dw .c2s1
	dw .c2s2 
	dw .c2s3 
	dw Track_LevelIntro.c2s1 
	dw .c2s3 
	dw .c2s4
	dw .c2s3
	dw Track_LevelIntro.c2s1
	dw .c2s3
	dw Track_LevelIntro.c2s1
	dw .c2s5
	dw .c2s5 
	dw .c2s6
	musEND
.c3 ;7305
	dw .c3s1
	dw .c3s2 
	dw .c3s2 
	dw .c3s2
	dw .c3s2
	dw .c3s3 
	dw .c3s2 
	dw .c3s2
	dw .c3s2 
	dw .c3s3
	dw .c3s2 
	dw .c3s4 
	dw .c3s2
	dw .c3s2 
	dw .c3s3
	dw .c3s2 
	dw .c3s2
	dw .c3s2
	dw .c3s3
	dw .c3s2
	dw .c3s5 
	dw .c3s2
	dw .c3s5 
	dw .c3s6
	musEND

.c1s1 ;7337
	musLoadNoteData $e0, $0, $40
	musNoteLengthFromTable $1
	musNote $50
	musNote $68
	musNote $38
	musLoadNoteData $70, $0, $40
	musNote $50
	musNote $68
	musNote $38
	musLoadNoteData $50, $0, $40
	musNote $50
	musNote $68
	musNote $38
	musLoadNoteData $30, $0, $40
	musNote $50
	musNote $68
	musNote $38
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musNoteLengthFromTable $7
	musRepeatNote
	musSectionEnd
.c2s1 ;735A
	musLoadNoteData $e0, $0, $40
	musNoteLengthFromTable $1
	musNote $20
	musNote $38
	musNote $8
	musLoadNoteData $70, $0, $40
	musNote $20
	musNote $38
	musNote $8
	musLoadNoteData $50, $0, $40
	musNote $20
	musNote $38
	musNote $8
	musLoadNoteData $30, $0, $40
	musNote $20
	musNote $38
	musNote $8
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musNoteLengthFromTable $7
	musRepeatNote
	musSectionEnd
.c3s1 ;737D
	musNoteLengthFromTable $5
	musRepeatNote
	musRepeatNote
	musRepeatNote
	musNoteLengthFromTable $2
	musRepeatNote
	musSectionEnd

.c1s2 ;7384
	musLoadNoteData $e1, $0, $40
	musNoteLengthFromTable $3
	musNote $1a
	musNoteLengthFromTable $2
	musNote $1a
	musNoteLengthFromTable $7
	musNote $1a
	musNote $1a
	musNoteLengthFromTable $3
	musNote $1a
	musNoteLengthFromTable $2
	musNote $1a
	musSectionEnd
.c1s3 ;7394
	musLoadNoteData $90, $0, $1
	musNoteLengthFromTable $8
	musNote $3a
	musNote $3c
	musNote $40
	musNote $3c
	musLoadNoteData $a0, $21, $1
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $52
	musNoteLengthFromTable $1
	musNote $54
	musNote $52
	musNoteLengthFromTable $2
	musNote $4e
	musNote $44
	musNote $48
	musNote $4a
	musNote $48
	musNoteLengthFromTable $1
	musNote $4a
	musNote $48
	musNoteLengthFromTable $2
	musNote $44
	musNote $48
	musNote $4a
	musNote $4e
	musLoop
	musLoadNoteData $e1, $0, $40
	musSetLoop $2
	musNoteLengthFromTable $3
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1c
	musNoteLengthFromTable $7
	musNote $1c
	musNote $1c
	musNoteLengthFromTable $3
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1c
	musLoop
	musSectionEnd
.c1s5 ;73CA
	musLoadNoteData $d0, $0, $1
	musNoteLengthFromTable $7
	musNote $50
	musNote $54
	musNote $4a
	musNoteLengthFromTable $6
	musNote $50
	musNote $54
	musNoteLengthFromTable $4
	musNote $5e
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $6
	musNote $5a
	musNoteLengthFromTable $7
	musNote $50
	musNote $54
	musNoteLengthFromTable $2
	musNote $58
	musNote $4e
	musNoteLengthFromTable $4
	musNote $58
	musNoteLengthFromTable $8
	musNote $58
	musSectionEnd
.c1s6 ;73E6	
	musLoadNoteData $c1, $0, $0
	musSetLoop $c
	musNoteLengthFromTable $2
	musNote $a
	musLoop
	musSetLoop $18
	musNote $a
	musLoop
	musSetLoop $18
	musNote $a
	musLoop
	musSetLoop $18
	musNote $a
	musLoop
	musSetLoop $18
	musNote $a
	musLoop
	musSetLoop $18
	musNote $a
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $1
	musNote $56
	musLoop
	musSetLoop $6
	musNote $58
	musLoop
	musSetLoop $12
	musNoteLengthFromTable $2
	musNote $a
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $1
	musNote $56
	musLoop
	musSetLoop $6
	musNote $58
	musLoop
	musSetLoop $12
	musNoteLengthFromTable $2
	musNote $a
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $1
	musNote $56
	musLoop
	musSetLoop $6
	musNote $58
	musLoop
	musSetLoop $12
	musNoteLengthFromTable $2
	musNote $a
	musLoop
	musLoadNoteData $a0, $0, $40
	musNoteLengthFromTable $8
	musNote $c
	musNote $c
	musLoadNoteData $c0, $81, $0
	musNoteLengthFromTable $1
	musNote $4a
	musNote $4e
	musNote $44
	musNote $4a
	musNote $4e
	musNote $58
	musNote $54
	musNote $4a
	musNote $4e
	musNote $52
	musNote $5c
	musNote $66
	musNote $70
	musNote $74
	musNote $6a
	musNote $70
	musNote $74
	musNote $7e
	musNote $7a
	musNote $70
	musNote $74
	musNote $5c
	musNote $8c
	musNote $90
	musLoadNoteData $e0, $0, $40
	musNoteLengthFromTable $1
	musNote $82
	musLoadNoteData $10, $0, $40
	musNoteLengthFromTable $4
	musNote $82
	musNoteLengthFromTable $6
	musRepeatNote
	musSectionEnd

.c2s2 ;7460
	musLoadNoteData $62, $0, $80
	musSetLoop $4
	musNoteLengthFromTable $3
	musNote $28
	musNoteLengthFromTable $2
	musNote $28
	musNoteLengthFromTable $7
	musNote $28
	musNote $28
	musNoteLengthFromTable $3
	musNote $28
	musNoteLengthFromTable $2
	musNote $28
	musLoop
	musSectionEnd
.c2s3 ;7473
	musLoadNoteData $e0, $21, $41
	musNoteLengthFromTable $7
	musNote $4a
	musNoteLengthFromTable $2
	musNote $4a
	musNote $40
	musNote $4a
	musNoteLengthFromTable $7
	musNote $4e
	musNote $58
	musNote $52
	musNoteLengthFromTable $2
	musNote $52
	musNote $54
	musNote $52
	musNoteLengthFromTable $8
	musNote $4e
	musSetLoop $2
	musNoteLengthFromTable $7
	musNote $62
	musNoteLengthFromTable $2
	musNote $54
	musNote $58
	musNote $5c
	musNoteLengthFromTable $8
	musNote $58
	musLoop
	musLoadNoteData $c0, $0, $81
	musNoteLengthFromTable $8
	musNote $46
	musNote $3c
	musNoteLengthFromTable $7
	musNote $40
	musNote $4a
	musNote $54
	musNote $5e
	musNoteLengthFromTable $8
	musNote $58
	musNote $58
	musNoteLengthFromTable $4
	musRepeatNote
	musSectionEnd
.c2s5 ;74A4
	musLoadNoteData $a0, $0, $0
	musNoteLengthFromTable $2
	musNote $42
	musNote $38
	musNote $42
	musNote $46
	musNote $3c
	musNote $46
	musNote $3c
	musNote $32
	musNote $3c
	musNote $48
	musNote $3c
	musNote $48
	musNote $54
	musNote $50
	musNote $46
	musNoteLengthFromTable $7
	musNote $50
	musNoteLengthFromTable $2
	musNote $42
	musNote $46
	musNote $4a
	musNote $4e
	musNote $50
	musNote $54
	musNote $4e
	musNote $44
	musNoteLengthFromTable $4
	musNote $4e
	musNoteLengthFromTable $8
	musNote $4e
	musRepeatNote
	musRepeatNote
	musSectionEnd
.c2s6 ;74CA
	musLoadNoteData $60, $0, $81
	musSetLoop $4
	musNoteLengthFromTable $8
	musRepeatNote
	musLoop
	musNote $18
	musNoteLengthFromTable $4
	musNote $18
	musNoteLengthFromTable $2
	musNote $14
	musNote $18
	musNoteLengthFromTable $8
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $18
	musNote $1a
	musNoteLengthFromTable $8
	musNote $1c
	musNoteLengthFromTable $4
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1e
	musNote $1c
	musNoteLengthFromTable $8
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $1e
	musNote $1a
	musNoteLengthFromTable $8
	musNote $18
	musNoteLengthFromTable $4
	musNote $18
	musNoteLengthFromTable $2
	musNote $14
	musNote $18
	musNoteLengthFromTable $8
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $18
	musNote $1a
	musNoteLengthFromTable $8
	musNote $1c
	musNoteLengthFromTable $4
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1e
	musNote $1c
	musNoteLengthFromTable $8
	musNote $1a
	musNote $1a
	musLoadNoteData $80, $0, $1
	musNoteLengthFromTable $7
	musNote $48
	musNote $4a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $18
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1a
	musNote $1c
	musNoteLengthFromTable $4
	musNote $1e
	musNoteLengthFromTable $2
	musNote $1c
	musNote $1e
	musNoteLengthFromTable $7
	musNote $48
	musNote $4a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $18
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1a
	musNote $1c
	musNoteLengthFromTable $4
	musNote $1e
	musNoteLengthFromTable $2
	musNote $1c
	musNote $1e
	musNoteLengthFromTable $7
	musNote $48
	musNote $4a
	musNoteLengthFromTable $4
	musNote $1a
	musNoteLengthFromTable $2
	musNote $18
	musNote $1a
	musNoteLengthFromTable $4
	musNote $1c
	musNoteLengthFromTable $2
	musNote $1a
	musNote $1c
	musNoteLengthFromTable $4
	musNote $1e
	musNoteLengthFromTable $2
	musNote $1c
	musNote $1e
	musLoadNoteData $a0, $0, $40
	musNoteLengthFromTable $8
	musNote $1a
	musNote $1a
	musLoadNoteData $c0, $81, $40
	musNoteLengthFromTable $1
	musNote $1a
	musNote $1e
	musNote $14
	musNote $1a
	musNote $1e
	musNote $28
	musNote $24
	musNote $1a
	musNote $1e
	musNote $22
	musNote $2c
	musNote $36
	musNote $40
	musNote $44
	musNote $3a
	musNote $40
	musNote $44
	musNote $4e
	musNote $4a
	musNote $40
	musNote $44
	musNote $2c
	musNote $5c
	musNote $60
	musLoadNoteData $f0, $0, $0
	musNoteLengthFromTable $1
	musNote $3a
	musLoadNoteData $10, $0, $0
	musNoteLengthFromTable $4
	musNote $3a
	musNoteLengthFromTable $6
	musRepeatNote
	musSectionEnd
.w1 ;7573
	db $03, $7B, $FF, $F7, $00, $FF, $BB, $77, $46, $40, $46, $40, $46, $40, $46, $40

.c3s2 ;7583
	musLoadWaveData .w1, $20
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $1a
	musRepeatNote
	musNote $2
	musRepeatNote
	musNote $1a
	musRepeatNote
	musNote $1a
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1a
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1a
	musRepeatNote
	musNote $2
	musRepeatNote
	musNote $1a
	musRepeatNote
	musLoop
	musSectionEnd
.c3s3 ;75A2
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $1c
	musRepeatNote
	musNote $4
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1c
	musRepeatNote
	musNote $4
	musRepeatNote
	musNote $1c
	musRepeatNote
	musLoop
	musSectionEnd
.c3s5 ;75BD
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $7
	musNote $32
	musNote $28
	musNote $2a
	musNote $12
	musNote $28
	musNote $1a
	musNote $24
	musNote $2e
	musSectionEnd
.c3s6 ;75CB
	musSetLoop $12
	musNoteLengthFromTable $1
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $22
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musLoop
	musSetLoop $4
	musNoteLengthFromTable $8
	musNote $c
	musLoop
	musNoteLengthFromTable $1
	musNote $22
	musNoteLengthFromTable $4
	musRepeatNote
	musNoteLengthFromTable $6
	musRepeatNote
	musSectionEnd

.c1s4 ;75F1
	musLoadNoteData $40, $81, $80
	musSetLoop $f
	musNoteLengthFromTable $3
	musNote $58
	musLoop
	musNote $5c
	musNote $5c
	musNote $5c
	musNote $5a
	musNote $5a
	musNote $5a
	musLoadNoteData $60, $21, $40
	musNoteLengthFromTable $2
	musNote $4a
	musNote $50
	musNote $56
	musNote $5c
	musNote $50
	musNote $56
	musNote $60
	musNote $52
	musNote $56
	musNoteLengthFromTable $7
	musNote $5a
	musNoteLengthFromTable $2
	musNote $56
	musNote $58
	musNote $56
	musNote $52
	musNote $4e
	musNote $4c
	musNoteLengthFromTable $2
	musNote $56
	musNote $60
	musNote $64
	musNote $66
	musNote $64
	musNote $66
	musNote $60
	musNote $66
	musNote $78
	musNote $72
	musNote $74
	musNote $78
	musLoadNoteData $80, $21, $40
	musNote $72
	musNote $6a
	musNote $6e
	musNote $72
	musNote $74
	musNote $78
	musNote $7c
	musNote $78
	musNote $74
	musNote $74
	musNote $72
	musNote $6e
	musLoadNoteData $90, $0, $40
	musNoteLengthFromTable $1
	musNote $20
	musNote $26
	musNote $2c
	musNote $34
	musNote $38
	musNote $3e
	musNote $44
	musNote $4c
	musNote $50
	musNote $56
	musNote $5c
	musNote $64
	musNote $68
	musNote $64
	musNote $5c
	musNote $56
	musNote $50
	musNote $4c
	musNote $44
	musNote $3e
	musNote $38
	musNote $34
	musNote $2c
	musNote $26
	musNoteLengthFromTable $2
	musNote $44
	musNote $3e
	musNote $42
	musNote $44
	musNote $48
	musNote $4c
	musNote $4e
	musNote $5a
	musNote $4c
	musNote $56
	musNote $48
	musNote $52
	musNoteLengthFromTable $1
	musNote $1c
	musNote $22
	musNote $2a
	musNote $30
	musNote $34
	musNote $3a
	musNote $42
	musNote $48
	musNote $4c
	musNote $52
	musNote $5a
	musNote $60
	musNote $64
	musNote $60
	musNote $5a
	musNote $52
	musNote $4c
	musNote $48
	musNote $42
	musNote $3a
	musNote $34
	musNote $30
	musNote $2a
	musNote $22
	musNoteLengthFromTable $2
	musNote $42
	musNote $3a
	musNote $3e
	musNote $42
	musNote $44
	musNote $48
	musNote $4c
	musNote $56
	musNote $48
	musNote $52
	musNote $44
	musNote $4c
	musLoadNoteData $a0, $21, $40
	musNoteLengthFromTable $2
	musNote $56
	musNote $44
	musNote $42
	musNote $3e
	musNote $42
	musNote $44
	musNote $48
	musNote $48
	musNote $44
	musNote $42
	musNote $44
	musNote $48
	musNote $4c
	musNote $4c
	musNote $48
	musNote $44
	musNote $48
	musNote $4c
	musNote $4e
	musNote $4e
	musNote $4c
	musNote $4e
	musNote $52
	musNote $56
	musLoadNoteData $60, $0, $80
	musNoteLengthFromTable $5
	musNote $52
	musNote $52
	musLoadNoteData $c0, $81, $80
	musNoteLengthFromTable $2
	musNote $4e
	musNote $4c
	musNote $48
	musNote $44
	musNote $42
	musNote $3e
	musNote $3a
	musNote $36
	musLoadNoteData $90, $0, $81
	musNoteLengthFromTable $8
	musNote $34
	musNote $36
	musNote $3a
	musNote $36
	musLoadNoteData $a0, $21, $0
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $64
	musNoteLengthFromTable $1
	musNote $66
	musNote $64
	musNoteLengthFromTable $2
	musNote $60
	musNote $56
	musNote $5a
	musNote $5c
	musNoteLengthFromTable $2
	musNote $5a
	musNoteLengthFromTable $1
	musNote $5c
	musNote $5a
	musNoteLengthFromTable $2
	musNote $56
	musNote $5a
	musNote $5c
	musNote $60
	musLoop
	musLoadNoteData $90, $0, $81
	musNoteLengthFromTable $8
	musNote $34
	musNote $36
	musNote $3a
	musNote $36
	musLoadNoteData $a0, $21, $0
	musSetLoop $2
	musNoteLengthFromTable $2
	musNote $64
	musNoteLengthFromTable $1
	musNote $66
	musNote $64
	musNoteLengthFromTable $2
	musNote $60
	musNote $56
	musNote $5a
	musNote $5c
	musNoteLengthFromTable $2
	musNote $5a
	musNoteLengthFromTable $1
	musNote $5c
	musNote $5a
	musNoteLengthFromTable $2
	musNote $56
	musNote $5a
	musNote $5c
	musNote $60
	musLoop
	musLoadNoteData $c2, $0, $40
	musNoteLengthFromTable $3
	musNote $16
	musNoteLengthFromTable $2
	musNote $16
	musNoteLengthFromTable $7
	musNote $16
	musNote $16
	musNoteLengthFromTable $3
	musNote $16
	musNoteLengthFromTable $2
	musNote $16
	musLoadNoteData $80, $81, $0
	musNoteLengthFromTable $2
	musNote $4a
	musNote $40
	musNote $4a
	musNote $52
	musNote $4a
	musNote $52
	musNote $5c
	musNote $54
	musNote $5c
	musNote $66
	musNote $60
	musNote $66
	musNote $64
	musNoteLengthFromTable $1
	musNote $66
	musNote $64
	musNoteLengthFromTable $2
	musNote $5c
	musNote $52
	musNote $4c
	musNote $44
	musNote $4c
	musNote $44
	musNote $3a
	musNote $44
	musNote $3a
	musNote $34
	musLoadNoteData $c1, $0, $40
	musNoteLengthFromTable $3
	musNote $14
	musNoteLengthFromTable $2
	musNote $14
	musNoteLengthFromTable $7
	musNote $14
	musNote $14
	musNoteLengthFromTable $3
	musNote $14
	musNoteLengthFromTable $2
	musNote $14
	musNoteLengthFromTable $3
	musNote $14
	musNoteLengthFromTable $2
	musNote $14
	musNoteLengthFromTable $7
	musNote $14
	musNote $14
	musNoteLengthFromTable $2
	musNote $14
	musNote $16
	musNote $18
	musSectionEnd
.c2s4 ;7747
	musLoadNoteData $e0, $21, $0
	musNoteLengthFromTable $4
	musRepeatNote
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $28
	musNote $26
	musNote $28
	musNoteLengthFromTable $7
	musNote $36
	musNoteLengthFromTable $2
	musNote $28
	musNote $26
	musNote $28
	musNoteLengthFromTable $7
	musNote $3a
	musNoteLengthFromTable $2
	musNote $28
	musNote $26
	musNote $28
	musNoteLengthFromTable $4
	musNote $3c
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $6
	musNote $3a
	musNoteLengthFromTable $7
	musNote $36
	musNoteLengthFromTable $2
	musNote $32
	musNote $36
	musNote $3a
	musNoteLengthFromTable $7
	musNote $36
	musNoteLengthFromTable $2
	musNote $30
	musNote $32
	musNote $36
	musNoteLengthFromTable $7
	musNote $32
	musNoteLengthFromTable $2
	musNote $2c
	musNote $30
	musNote $32
	musNoteLengthFromTable $5
	musNote $30
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $44
	musNote $3e
	musNote $44
	musNoteLengthFromTable $7
	musNote $42
	musNoteLengthFromTable $2
	musNote $3a
	musNote $3e
	musNote $42
	musNoteLengthFromTable $7
	musNote $46
	musNoteLengthFromTable $2
	musNote $46
	musNote $48
	musNote $4c
	musNoteLengthFromTable $7
	musNote $4e
	musNote $3e
	musNote $42
	musNote $56
	musNote $52
	musNote $60
	musNote $5c
	musNote $64
	musLoadNoteData $f0, $0, $1
	musNoteLengthFromTable $8
	musNote $64
	musNote $56
	musNoteLengthFromTable $4
	musNote $56
	musNoteLengthFromTable $3
	musRepeatNote
	musNote $60
	musNote $5c
	musNote $5a
	musNoteLengthFromTable $8
	musNote $60
	musNote $52
	musNoteLengthFromTable $4
	musNote $52
	musNoteLengthFromTable $3
	musRepeatNote
	musNote $60
	musNote $5c
	musNote $5a
	musLoadNoteData $e0, $21, $80
	musNoteLengthFromTable $7
	musNote $3e
	musNoteLengthFromTable $2
	musNote $36
	musNote $3a
	musNote $3e
	musNoteLengthFromTable $7
	musNote $42
	musNoteLengthFromTable $2
	musNote $3a
	musNote $3e
	musNote $42
	musNoteLengthFromTable $7
	musNote $44
	musNoteLengthFromTable $2
	musNote $3e
	musNote $42
	musNote $44
	musNoteLengthFromTable $7
	musNote $48
	musNoteLengthFromTable $2
	musNote $48
	musNote $4c
	musNote $4e
	musLoadNoteData $e0, $0, $41
	musNoteLengthFromTable $7
	musNote $6a
	musNote $6e
	musNote $60
	musNoteLengthFromTable $6
	musNote $6a
	musNote $6e
	musNoteLengthFromTable $8
	musNote $78
	musNote $7c
	musLoadNoteData $c0, $0, $1
	musNoteLengthFromTable $3
	musNote $5c
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $5c
	musNote $52
	musNote $5c
	musNoteLengthFromTable $7
	musNote $60
	musNote $6a
	musNoteLengthFromTable $3
	musNote $64
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $64
	musNote $66
	musNote $64
	musNoteLengthFromTable $8
	musNote $60
	musSetLoop $2
	musNoteLengthFromTable $7
	musNote $74
	musNoteLengthFromTable $2
	musNote $66
	musNote $6a
	musNote $6e
	musNoteLengthFromTable $4
	musNote $6a
	musNoteLengthFromTable $2
	musNote $6a
	musRepeatNote
	musLoop
	musNoteLengthFromTable $3
	musNote $5c
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $5c
	musNote $52
	musNote $5c
	musNoteLengthFromTable $7
	musNote $60
	musNote $6a
	musNoteLengthFromTable $3
	musNote $64
	musNoteLengthFromTable $2
	musRepeatNote
	musNote $64
	musNote $66
	musNote $64
	musNoteLengthFromTable $8
	musNote $60
	musSetLoop $2
	musNoteLengthFromTable $7
	musNote $74
	musNoteLengthFromTable $2
	musNote $66
	musNote $6a
	musNote $6e
	musNoteLengthFromTable $4
	musNote $6a
	musNoteLengthFromTable $2
	musNote $6a
	musRepeatNote
	musLoop
	musLoadNoteData $a0, $0, $41
	musNoteLengthFromTable $8
	musNote $58
	musNote $4e
	musNoteLengthFromTable $7
	musNote $52
	musNote $5c
	musNote $66
	musNote $70
	musNoteLengthFromTable $8
	musNote $6a
	musNote $6a
	musSetLoop $4
	musRepeatNote
	musLoop
	musSectionEnd
.c3s4 ;782E
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musNote $28
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $28
	musRepeatNote
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musLoop
	musNote $28
	musRepeatNote
	musNote $10
	musRepeatNote
	musNote $28
	musRepeatNote
	musNote $28
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNote $e
	musRepeatNote
	musNote $26
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $22
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $20
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $20
	musRepeatNote
	musNote $8
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $36
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $34
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNote $e
	musRepeatNote
	musNote $26
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNote $30
	musRepeatNote
	musNote $30
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $3a
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $36
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $34
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNote $34
	musRepeatNote
	musNote $34
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $22
	musRepeatNote
	musNote $a
	musRepeatNote
	musNote $22
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $8
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $20
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $20
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $20
	musRepeatNote
	musNote $8
	musRepeatNote
	musNote $20
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1e
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1e
	musRepeatNote
	musNote $6
	musRepeatNote
	musNote $1e
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNote $4
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $1c
	musRepeatNote
	musNote $4
	musRepeatNote
	musNote $1c
	musRepeatNote
	musNote $26
	musRepeatNote
	musNote $e
	musRepeatNote
	musNote $26
	musRepeatNote
	musNote $26
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $26
	musRepeatNote
	musNote $e
	musRepeatNote
	musNote $26
	musRepeatNote
	musSetLoop $8
	musNote $30
	musRepeatNote
	musNote $18
	musRepeatNote
	musNote $30
	musRepeatNote
	musLoop
	musSetLoop $6
	musNoteLengthFromTable $2
	musNote $a
	musNote $22
	musLoop
	musNoteLengthFromTable $1
	musNote $a
	musRepeatNote
	musNote $52
	musRepeatNote
	musNote $4e
	musRepeatNote
	musNote $4c
	musRepeatNote
	musNote $48
	musRepeatNote
	musNote $44
	musRepeatNote
	musNote $42
	musRepeatNote
	musNote $3e
	musRepeatNote
	musNote $3a
	musRepeatNote
	musNote $36
	musRepeatNote
	musNote $34
	musRepeatNote
	musNote $30
	musRepeatNote
	musSetLoop $8
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNote $14
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNote $14
	musRepeatNote
	musNote $2c
	musRepeatNote
	musLoop
	musNote $2e
	musRepeatNote
	musNote $16
	musRepeatNote
	musNote $2e
	musRepeatNote
	musNote $2e
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2e
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2e
	musRepeatNote
	musNote $16
	musRepeatNote
	musNote $2e
	musRepeatNote
	musNoteLengthFromTable $7
	musNote $2c
	musNote $24
	musNote $18
	musNote $22
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNote $14
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNote $14
	musRepeatNote
	musNote $2c
	musRepeatNote
	musLoop
	musNote $2c
	musRepeatNote
	musNote $14
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $2c
	musRepeatNote
	musNoteLengthFromTable $3
	musRepeatNote
	musNoteLengthFromTable $1
	musNote $14
	musRepeatNote
	musNote $16
	musRepeatNote
	musNote $18
	musRepeatNote
	musSectionEnd
	
Track_BriefingIntro: ;799C
	SongHeader 0, NotelengthTable60, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1 ;79A7
	dw .c1s1
	musEND
.c2 ;79AB
	dw .c2s1
	musEND

.c1s1 ;79AF
	musLoadNoteData $d0, $0, $0
	musNoteLengthFromTable $9
	musNote $2c
	musNote $18
	musLoadNoteData $50, $0, $0
	musNote $2c
	musNote $18
	musLoadNoteData $30, $0, $0
	musNote $2c
	musNote $18
	musLoadNoteData $10, $0, $0
	musNote $2c
	musNote $18
	musNoteLengthFromTable $a
	musRepeatNote
	musRepeatNote
	musLoadNoteData $10, $0, $0
	musSetLoop $2
	musNoteLengthFromTable $0
	musNote $1c
	musNote $24
	musNote $2c
	musNote $34
	musNote $3c
	musNote $44
	musNote $4c
	musNote $54
	musNote $5c
	musNote $64
	musNote $6c
	musNote $74
	musNote $7c
	musNote $74
	musNote $6c
	musNote $64
	musNote $5c
	musNote $54
	musNote $4c
	musNote $44
	musNote $3c
	musNote $34
	musNote $2c
	musNote $24
	musLoop
	musLoadNoteData $20, $0, $0
	musNote $1c
	musNote $24
	musNote $2c
	musNote $34
	musNote $3c
	musNote $44
	musNote $4c
	musNote $54
	musNote $5c
	musNote $64
	musNote $6c
	musNote $74
	musNote $7c
	musNote $74
	musNote $6c
	musNote $64
	musNote $5c
	musNote $54
	musNote $4c
	musNote $44
	musNote $3c
	musNote $34
	musNote $2c
	musNote $24
	musLoadNoteData $40, $0, $0
	musNote $1c
	musNote $24
	musNote $2c
	musNote $34
	musNote $3c
	musNote $44
	musNote $4c
	musNote $54
	musNote $5c
	musNote $64
	musNote $6c
	musNote $74
	musNote $7c
	musNote $74
	musNote $6c
	musNote $64
	musNote $5c
	musNote $54
	musNote $4c
	musNote $44
	musNote $3c
	musNote $34
	musNote $2c
	musNote $24
	musLoadNoteData $80, $0, $0
	musNote $1c
	musNote $24
	musNote $2c
	musNote $34
	musNote $3c
	musNote $44
	musNote $4c
	musNote $54
	musNote $5c
	musNote $64
	musNote $6c
	musNote $74
	musNote $7c
	musNote $74
	musNote $6c
	musNote $64
	musNote $5c
	musNote $54
	musNote $4c
	musNote $44
	musNote $3c
	musNote $34
	musNote $2c
	musNote $24
	musSectionEnd

.c2s1 ;7A40
	musLoadNoteData $f0, $81, $40
	musNoteLengthFromTable $a
	musNote $36
	musLoadNoteData $70, $81, $40
	musNote $36
	musLoadNoteData $50, $81, $40
	musNote $36
	musLoadNoteData $30, $81, $40
	musNote $36
	musNoteLengthFromTable $a
	musRepeatNote
	musRepeatNote
	musLoadNoteData $10, $0, $80
	musSetLoop $2
	musNoteLengthFromTable $0
	musNote $60
	musNote $62
	musNote $64
	musNote $66
	musNote $68
	musNote $6a
	musNote $6c
	musNote $6e
	musNote $70
	musNote $72
	musNote $74
	musNote $76
	musNote $78
	musNote $7a
	musNote $7c
	musNote $7e
	musNote $80
	musNote $82
	musNote $84
	musNote $86
	musNote $88
	musNote $8a
	musNote $8c
	musNote $8e
	musLoop
	musLoadNoteData $20, $0, $80
	musNote $60
	musNote $62
	musNote $64
	musNote $66
	musNote $68
	musNote $6a
	musNote $6c
	musNote $6e
	musNote $70
	musNote $72
	musNote $74
	musNote $76
	musNote $78
	musNote $7a
	musNote $7c
	musNote $7e
	musNote $80
	musNote $82
	musNote $84
	musNote $86
	musNote $88
	musNote $8a
	musNote $8c
	musNote $8e
	musLoadNoteData $40, $0, $80
	musNote $60
	musNote $62
	musNote $64
	musNote $66
	musNote $68
	musNote $6a
	musNote $6c
	musNote $6e
	musNote $70
	musNote $72
	musNote $74
	musNote $76
	musNote $78
	musNote $7a
	musNote $7c
	musNote $7e
	musNote $80
	musNote $82
	musNote $84
	musNote $86
	musNote $88
	musNote $8a
	musNote $8c
	musNote $8e
	musLoadNoteData $80, $0, $80
	musNote $60
	musNote $62
	musNote $64
	musNote $66
	musNote $68
	musNote $6a
	musNote $6c
	musNote $6e
	musNote $70
	musNote $72
	musNote $74
	musNote $76
	musNote $78
	musNote $7a
	musNote $7c
	musNote $7e
	musNote $80
	musNote $82
	musNote $84
	musNote $86
	musNote $88
	musNote $8a
	musNote $8c
	musNote $8e
	musSectionEnd
	
Track_Shanty: ;7ACD, shanty?
	SongHeader 0, NotelengthTable50, .c1, .c2, Track_LevelIntro.c3, .c4
.c1 ;7AD8
	dw .c1s1
	musJUMP .c1
.c2 ;7ADE
	dw .c2s1 
	musJUMP .c2
.c4 ;7AE4
	dw .c4s1
	musJUMP .c4

.c1s1 ;7AEA
	musLoadNoteData $60, $81, $40
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $8
	musLoop
	musSectionEnd
.c2s1 ;7AF4
	musLoadNoteData $a1, $0, $80
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $8
	musNote $8
	musNote $8
	musNoteLengthFromTable $7
	musNote $8
	musNote $8
	musNoteLengthFromTable $2
	musNote $8
	musNote $8
	musNote $8
	musLoop
	musSectionEnd
.c4s1 ;7B07
	musSetLoop $20
	musNoteLengthFromTable $2
	musNote $47
	musNoteLengthFromTable $1
	musNote $47
	musNote $47
	musNoteLengthFromTable $2
	musNote $47
	musNoteLengthFromTable $7
	musNote $47
	musNote $47
	musNoteLengthFromTable $2
	musNote $47
	musNoteLengthFromTable $1
	musNote $47
	musNote $47
	musNoteLengthFromTable $2
	musNote $47
	musLoop
	musSectionEnd

Track_PlaceCrystal: ;7B1C
	SongHeader 0, NotelengthTable60, .c1, .c2, Track_LevelIntro.c3, Track_LevelIntro.c4
.c1 ;7B27
	dw .c1s1 
	dw .c1s1
	dw .c1s1
	dw .c1s1 
:	dw .c1s2
	musJUMP :-
.c2 ;7B35
	dw .c2s1
	dw .c2s1
	dw .c2s1
	dw .c2s2 
:	dw .c2s3
	musJUMP :-
	
.c1s1 ;7B43
	musLoadNoteData $40, $0, $43
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $82
	musLoop
	musSectionEnd
.c2s1 ;7B4D
	musLoadNoteData $40, $0, $0
	musSetLoop $20
	musNoteLengthFromTable $0
	musNote $82
	musLoop
	musSectionEnd
.c2s2 ;7B57
	musSetLoop $1f
	musNote $82
	musLoop
	musSectionEnd
.c1s2 ;7B5C
	musLoadNoteData $20, $81, $83
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $1c
	musNote $4c
	musNote $4
	musNote $34
	musNote $4
	musLoop
	musLoadNoteData $50, $81, $83
	musNote $1c
	musNote $4c
	musNote $4
	musNote $34
	musNote $4
	musLoadNoteData $80, $81, $83
	musNote $1c
	musNote $4c
	musNote $4
	musNote $34
	musNote $4
	musLoadNoteData $50, $81, $83
	musNote $1c
	musNote $4c
	musNote $4
	musNote $34
	musNote $4
	musSectionEnd
.c2s3 ;7B85
	musLoadNoteData $20, $81, $0
	musSetLoop $2
	musNoteLengthFromTable $1
	musNote $1c
	musNote $4c
	musNote $34
	musNote $34
	musNote $4
	musNote $4c
	musNote $64
	musNote $4
	musNote $64
	musNote $34
	musLoop
	musLoadNoteData $50, $81, $0
	musNote $1c
	musNote $4c
	musNote $34
	musNote $34
	musNote $4
	musNote $4c
	musNote $64
	musNote $4
	musNote $64
	musNote $34
	musLoadNoteData $80, $81, $0
	musNote $1c
	musNote $4c
	musNote $34
	musNote $34
	musNote $4
	musNote $4c
	musNote $64
	musNote $4
	musNote $64
	musNote $34
	musLoadNoteData $50, $81, $0
	musNote $1c
	musNote $4c
	musNote $34
	musNote $34
	musNote $4
	musNote $4c
	musNote $64
	musNote $4
	musNote $64
	musNote $34
	musSectionEnd

Track_07WithIntro: ;7BC2
	SongHeader 0, NotelengthTable60, .c1, .c2, .c3, Track_LevelIntro.c4
.c1 ;7BCD
	dw .c1s1
	musJUMP Track_07.c1 
.c2 ;7BD3
	dw .c2s1 
	musJUMP Track_07.c2 
.c3 ;7BD9
	dw .c3s1
	musJUMP Track_07.c3
	
.c1s1 ;7BDF
	musLoadNoteData $a0, $81, $3
	musNoteLengthFromTable $d
	musNote $7c
	musNote $6e
	musNote $72
	musNote $76
	musNote $68
	musNote $6c
	musLoadNoteData $80, $81, $3
	musNote $70
	musNote $62
	musNote $66
	musNote $6a
	musNote $5c
	musNote $60
	musLoadNoteData $60, $81, $3
	musNote $64
	musNote $56
	musNote $5a
	musNote $5e
	musNote $50
	musNote $54
	musNote $58
	musNote $4a
	musNote $4e
	musNote $52
	musNote $44
	musNote $48
	musNote $4c
	musNote $3e
	musNote $42
	musSectionEnd
.c2s1 ;7C08
	musLoadNoteData $a0, $81, $40
	musNoteLengthFromTable $d
	musNote $4c
	musNote $3e
	musNote $42
	musNote $46
	musNote $38
	musNote $3c
	musLoadNoteData $80, $81, $40
	musNote $40
	musNote $32
	musNote $36
	musNote $3a
	musNote $2c
	musNote $30
	musLoadNoteData $60, $81, $40
	musNote $34
	musNote $26
	musNote $2a
	musNote $2e
	musNote $20
	musNote $24
	musNote $28
	musNote $1a
	musNote $1e
	musNote $22
	musNote $14
	musNote $18
	musNote $1c
	musNote $e
	musNote $12
	musSectionEnd
.c3s1 ;7C31
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $2
	musRepeatNote
	musSectionEnd
	
Track_Fanfare: ;7C36
	SongHeader 0, NotelengthTable60, .c1, .c2, .c3, BLANK_POINTER
.c1 ;7C41
	dw .c1s1
	musEND
.c2 ;7C45
	dw .c2s1
	musEND
.c3 ;7C49
	dw .c3s1
	musEND
	
.c1s1 ;7C4D
	musLoadNoteData $a0, $21, $0
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $4
	musNote $48
	musNote $46
	musNoteLengthFromTable $3
	musNote $54
	musNote $56
	musNoteLengthFromTable $6
	musNote $48
	musNote $4c
	musLoadNoteData $a0, $0, $0
	musNoteLengthFromTable $8
	musNote $50
	musLoadNoteData $a0, $0, $80
	musNoteLengthFromTable $1
	musNote $30
	musNote $38
	musNote $40
	musNote $42
	musNote $48
	musNote $50
	musNote $58
	musNote $5a
	musLoadNoteData $d0, $81, $0
	musNoteLengthFromTable $6
	musNote $54
	musNote $4a
	musLoadNoteData $f0, $0, $0
	musNoteLengthFromTable $5
	musNote $54
	musRepeatNote
	musSectionEnd
.c2s1 ;7C7E
	musLoadNoteData $c0, $21, $1
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $3
	musNote $56
	musNote $5a
	musNote $50
	musNoteLengthFromTable $2
	musNote $56
	musNote $5a
	musNoteLengthFromTable $7
	musNote $64
	musNoteLengthFromTable $2
	musNote $60
	musNoteLengthFromTable $7
	musNote $56
	musLoadNoteData $c0, $0, $1
	musNoteLengthFromTable $3
	musNote $5a
	musNoteLengthFromTable $5
	musNote $5a
	musLoadNoteData $f0, $81, $1
	musNoteLengthFromTable $6
	musNote $5e
	musNote $54
	musLoadNoteData $f0, $0, $1
	musNoteLengthFromTable $5
	musNote $5e
	musRepeatNote
	musSectionEnd
.c3s1 ;7CA8
	musLoadWaveData Track_TitleScreen.w1, $20
	musNoteLengthFromTable $5
	musRepeatNote
	musNoteLengthFromTable $4
	musNote $34
	musNote $30
	musNoteLengthFromTable $3
	musNote $2e
	musNote $38
	musNoteLengthFromTable $7
	musNote $2a
	musNoteLengthFromTable $3
	musNote $24
	musNoteLengthFromTable $5
	musNote $24
	musNote $20
	musNoteLengthFromTable $7
	musNote $20
	musNoteLengthFromTable $5
	musRepeatNote
	musSectionEnd
	
Track_Ambient5WithIntro: ;7CC0
	SongHeader 0, NotelengthTable80, .c1, .c2, .c3, BLANK_POINTER
.c1 ;7CCB
	dw Track_Ambient1WithIntro.c1s1
	dw Track_Ambient1WithIntro.c1s2
	dw Track_Ambient1WithIntro.c1s3
.l1	dw .c1s1 
:	dw .c1s2
	musJUMP :-
.c2 ;7CD9
	dw Track_Ambient1WithIntro.c2s1 
	dw Track_Ambient1WithIntro.c2s2
	dw Track_Ambient1WithIntro.c2s3
.l2	dw .c2s1 
	musJUMP .l2
.c3 ;7CE5
	dw Track_Ambient1WithIntro.c3s1
.l3	dw .c3s1 
:	dw .c3s2
	musJUMP :-

.c1s1 ;7CEF
	musNoteLengthFromTable $2
	musRepeatNote
	musSectionEnd
.c1s2 ;7CF2
	musLoadNoteData $40, $0, $81
	musNoteLengthFromTable $4
	musNote $36
	musNote $38
	musNote $3a
	musNote $38
	musSectionEnd
.c2s1 ;7CFC
	musLoadNoteData $60, $0, $41
	musNoteLengthFromTable $7
	musNote $36
	musNoteLengthFromTable $1
	musNote $34
	musNote $36
	musNoteLengthFromTable $7
	musNote $38
	musNoteLengthFromTable $1
	musNote $36
	musNote $38
	musNoteLengthFromTable $7
	musNote $3a
	musNoteLengthFromTable $1
	musNote $3c
	musNote $3a
	musNoteLengthFromTable $7
	musNote $38
	musNoteLengthFromTable $1
	musNote $3a
	musNote $38
	musSectionEnd
.c3s1 ;7D15
	musNoteLengthFromTable $1
	musRepeatNote
	musNoteLengthFromTable $0
	musRepeatNote
.c3s2 ;7D19
	musLoadWaveData Track_Ambient3WithIntro.w1, $43
	musNoteLengthFromTable $4
	musNote $4e
	musNote $50
	musNote $52
	musNote $50
	musSectionEnd

Track_Ambient5: ;7D23
	SongHeader 0, NotelengthTable80, Track_Ambient5WithIntro.l1, Track_Ambient5WithIntro.l2, Track_Ambient5WithIntro.l3, BLANK_POINTER

Track_Training: ;7D2E
	SongHeader 0, NotelengthTable80, .c1, .c2, Track_LevelIntro.c3, BLANK_POINTER
.c1 ;7D39
	dw .c1s1 
:	dw .s2 
	dw .s3 
	musJUMP :-
.c2 ;7D43
	dw .c2s1 
	dw .s2
	dw .s3
	dw .c2s4 
	dw .s2 
	dw .c2s5 
	dw .s3
	dw .c2s6
	dw .s2
	dw .s3
	dw .c2s5 
	dw .s2
	dw .c2s4 
	dw .s3
	musJUMP .c2

.c2s1 ;7D63
	musLoadNoteData $40, $41, $0
	musSectionEnd
.c2s4 ;7D68
	musLoadNoteData $50, $41, $0
	musSectionEnd
.c2s5 ;7D6D
	musLoadNoteData $60, $41, $0
	musSectionEnd
.c2s6 ;7D72
	musLoadNoteData $80, $41, $0
	musSectionEnd
.c1s1 ;7D77
	musLoadNoteData $10, $0, $40
	musNoteLengthFromTable $1
	musRepeatNote
	musSectionEnd
.s2 ;7D7E
	musNoteLengthFromTable $1
	musNote $56
	musNote $5a
	musNote $50
	musNote $56
	musNote $5a
	musNote $64
	musNote $60
	musNote $56
	musNote $5a
	musNote $5e
	musNote $54
	musNote $62
	musNote $70
	musNote $74
	musNote $66
	musNote $6a
	musNote $6e
	musNote $64
	musNote $72
	musNote $6a
	musNote $60
	musNote $56
	musNote $5e
	musNote $6c
	musNote $6a
	musNote $78
	musNote $6e
	musNote $62
	musSectionEnd
.s3 ;7D9C
	musNote $58
	musNote $4c
	musNote $44
	musNote $46
	musNote $4e
	musNote $5a
	musNote $52
	musNote $58
	musNote $62
	musNote $68
	musNote $5e
	musNote $6c
	musNote $7a
	musNote $7e
	musNote $74
	musNote $6a
	musNote $60
	musNote $64
	musNote $68
	musNote $46
	musNote $68
	musNote $72
	musNote $7c
	musNote $76
	musNote $6c
	musNote $62
	musNote $58
	musNote $4e
	musNote $52
	musSectionEnd
	
Track_Training2: ;7DBA
	SongHeader 0, NotelengthTable80, Track_Training.c1, .c2, Track_LevelIntro.c3, BLANK_POINTER
.c2 ;7DC5
	dw Track_Training.c2s1
	dw Track_Training.s2
	dw Track_Training.s3 
	musJUMP .c2
;7DCF
	
;blank until...

SECTION "Bank 6.20", ROMX[$7FF0], BANK[6]
JumpToUpdateSound: ;7FF0
	jp UpdateSound.entry
JumpToInitSound: ;7FF3
	jp InitSound
JumpToResetSound: ;7FF6
	jp ResetSound
;7FF9