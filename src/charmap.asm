NEWCHARMAP CHARS
	charmap "<NULL>", $00

	;charmap "を", $01
	;charmap "再",  $02 ;'sai'/again
	;charmap "ー", $03
	;charmap "あ", $04 ;same starting here
	;charmap "い", $05
	;charmap "う", $06
	;charmap "え", $07
	;charmap "お", $08
	;charmap "か", $09
	;charmap "き", $0A
	;charmap "く", $0B
	;charmap "け", $0C
	;charmap "こ", $0D
	;charmap "さ", $0E
	;charmap "し", $0F
	;charmap "す", $10
	;charmap "せ", $11
	;charmap "そ", $12
	;charmap "た", $13
	;charmap "ち", $14
	;charmap "つ", $15
	;charmap "て", $16
	;charmap "と", $17
	;charmap "な", $18
	;charmap "に", $19
	;charmap "ぬ", $1A
	;charmap "ね", $1B
	;charmap "の", $1C
	;charmap "８", $1D
	;charmap "９", $1E
	;charmap "面", $1F ;'men'/surface

	charmap "<NL>", $20 ;newline
	charmap "!", $21 ;italicized

	charmap "<22>", $22
	charmap "<LP>", $23 ;move cursor left a pixel
	charmap "$", $24 ;changes charset - followed by 31 makes katakana, 32 makes hiragana
	
	charmap "K", $31
	charmap "H", $32
	charmap "P", $33 ;for extra kanji??
	
	charmap "走", $25 ;'hashi'
	charmap "的", $26 ;'mato'/target
	charmap "進", $27 ;
	charmap "指", $28
	charmap "可", $29 ;'ka'
	charmap "周", $2a ;'shu'/lap
	charmap "？", $2b
	charmap "<2C>", $2C ;draws 面 and moves cursor back
	charmap "<2D>", $2d ;draws を and moves cursor back
	charmap "<2E>", $2e ;draws を and moves cursor back
	charmap "再", $2f ;draws 再
	
	charmap "０", $30
	charmap "１", $31
	charmap "２", $32
	charmap "３", $33
	charmap "４", $34
	charmap "５", $35
	charmap "６", $36
	charmap "７", $37
	charmap "８", $38
	charmap "９", $39

	charmap "接", $3a ;
	charmap "合", $3b ;'go'/combined
	charmap "<3C>", $3c ;draws 面 and moves cursor back
	charmap "<3D>", $3d ;draws 面 and moves cursor back
	charmap "<3E>", $3e ;draws を and moves cursor back
	charmap "<3F>", $3f ;draws を and moves cursor back

	charmap "小", $40 ;'ko'/small
	charmap "宇", $41 ;'sora'
	charmap "宙", $42 ;'chu'
	charmap "世", $43 ;'yo'/world
	charmap "紀", $44 ;'nori'/era
	charmap "X", $45 ;letter X for year
	charmap "年", $46 ;'toshi'/year
	charmap "人", $47 ;'hito'/person
	
	charmap "々", $48 ;kanji repeat
	charmap "新", $49 ;'shin'/new
	charmap "大", $4a ;'oo'/big
	charmap "地", $4b ;'ji'/ground
	charmap "未", $4c ;'mi'
	charmap "来", $4d ;'ki' ;this + ^ makes 'mirai'/future
	charmap "発", $4e ;
	charmap "見", $4f ;'mi' ;this + ^ makes discover
	
	charmap "成", $50 ;'nari'/success
	charmap "功", $51 ;'ko'/achievement
	charmap "使", $52 ;'shi'
	charmap "用", $53 ;this + ^ makes 'shiyou'/use
	charmap "施", $54
	charmap "設", $55 ;this + ^ makes 'shisetsu'/facility
	charmap "向", $56 ;'mukai'/direction
	charmap "船", $57 ;'fune'/ship
	
	charmap "行", $58 ;'gyou'
	charmap "方", $59
	charmap "不", $5a
	charmap "格", $5b
	charmap "破", $5c
	charmap "片", $5d
	charmap "作", $5e
	charmap "", $5f
	
	charmap "", $60
	charmap "", $61
	charmap "放", $62
	charmap "上", $63
	charmap "出", $64
	charmap "我", $65
	charmap "残", $66
	charmap "時", $67
	
	charmap "間", $68
	charmap "司", $69 ;
	charmap "会", $6a ;
	charmap "官", $6b ;
	charmap "「", $6c ;
	charmap "」", $6d ;
	charmap "、", $6e
	charmap "。", $6f
	
	charmap "・", $70
	charmap "君", $71 ;'kimi'/you
	charmap "私", $72 ;'watashi'/me
	charmap "任", $73
	charmap "務", $74 ;+^ = 'ninmu'/mission
	charmap "与", $75
	charmap "", $76
	charmap "回", $77
	
	charmap "収", $78
	charmap "祈", $79
	charmap "今", $7a ;'ima'/now
	charmap "照", $7b
	charmap "準", $7c
	charmap "前", $7d
	charmap "", $7e
	charmap "", $7f

	
;garbage before here?
	charmap "を", $a6
	charmap "ぁ", $a7
	charmap "ぃ", $a8
	charmap "ぅ", $a9
	charmap "ぇ", $aa
	charmap "ぉ", $ab

	charmap "ゃ", $AC
	charmap "ゅ", $AD
	charmap "ょ", $AE
	charmap "っ", $AF
	charmap "ー", $B0

	charmap "あ", $b1
	charmap "い", $b2
	charmap "う", $b3
	charmap "え", $b4
	charmap "お", $b5
	charmap "か", $b6
	charmap "き", $b7
	charmap "く", $b8
	charmap "け", $b9
	charmap "こ", $ba
	charmap "さ", $bb
	charmap "し", $bc
	charmap "す", $bd
	charmap "せ", $be
	charmap "そ", $bf
	charmap "た", $c0
	charmap "ち", $c1
	charmap "つ", $c2
	charmap "て", $c3
	charmap "と", $c4
	charmap "な", $c5
	charmap "に", $c6
	charmap "ぬ", $c7
	charmap "ね", $c8
	charmap "の", $c9
	charmap "は", $ca
	charmap "ひ", $cb
	charmap "ふ", $cc
	charmap "へ", $cd
	charmap "ほ", $ce
	charmap "ま", $cf
	charmap "み", $d0
	charmap "む", $d1
	charmap "め", $d2
	charmap "も", $d3
	charmap "や", $d4
	charmap "ゆ", $d5
	charmap "よ", $d6
	charmap "ら", $d7
	charmap "り", $d8
	charmap "る", $d9
	charmap "れ", $da
	charmap "ろ", $db
	charmap "わ", $dc
	charmap "ん", $dd
	charmap "ﾞ", $de
	charmap "ﾟ", $df

	charmap "", $e6
	charmap "", $e7
	charmap "", $e8
	charmap "", $e9
	charmap "", $ea
	charmap "", $eb
	charmap "", $ec
	charmap "", $ed
	charmap "", $ed
	charmap "", $ee
	charmap "", $ef
	charmap "", $f0
	charmap "", $f1
	charmap "", $f2
	charmap "", $f3
	charmap "", $f4
	charmap "", $f5
	charmap "", $f6
	charmap "", $f7
	charmap "", $f8
	charmap "", $f9
	charmap "", $fa
	charmap "", $fb
	charmap "", $fc
	charmap "", $fd
	charmap "", $fe
	charmap "", $ff
	
	;$K
	charmap "ァ", $A7
	charmap "ィ", $A8
	charmap "ゥ", $A9
	charmap "ェ", $AA
	charmap "ォ", $AB
	
	charmap "ャ", $AC
	charmap "ュ", $AD
	charmap "ョ", $AE
	charmap "ッ", $AF
	charmap "ー", $B0
	
	charmap "ア", $B1
	charmap "イ", $B2
	charmap "ウ", $b3
	charmap "エ", $b4
	charmap "オ", $b5
	charmap "カ", $b6
	charmap "キ", $b7
	charmap "ク", $b8
	charmap "ケ", $b9
	charmap "コ", $ba
	charmap "サ", $bb
	charmap "シ", $bc
	charmap "ス", $bd
	charmap "セ", $be
	charmap "ソ", $bf
	charmap "タ", $c0
	charmap "チ", $c1
	charmap "ツ", $c2
	charmap "テ", $c3
	charmap "ト", $c4
	charmap "ナ", $c5
	charmap "ニ", $c6
	charmap "ヌ", $c7
	charmap "ネ", $c8
	charmap "ノ", $c9
	charmap "ハ", $ca
	charmap "ヒ", $cb
	charmap "フ", $cc
	charmap "ヘ", $cd
	charmap "ホ", $ce
	charmap "マ", $cf
	charmap "ミ", $d0
	charmap "ム", $d1
	charmap "メ", $d2
	charmap "モ", $d3
	charmap "ヤ", $d4
	charmap "ユ", $d5
	charmap "ヨ", $d6
	charmap "ラ", $d7
	charmap "リ", $d8
	charmap "ル", $d9
	charmap "レ", $da
	charmap "ロ", $db
	charmap "ワ", $dc
	charmap "ン", $dd
	
	
	;$P (more kanji)
	charmap "下", $25
	
	charmap "Ｈ", $28
	charmap "Ｇ", $29
	charmap "Ｄ", $2A
	charmap "Ｍ", $2B
	
	charmap "　", $2F
	charmap "始", $30
	
	charmap "対", $34
	
	charmap "超", $37
	charmap "強", $38
	charmap "力", $39
	charmap "高", $3A
	charmap "押", $3B
	
	charmap "現", $40
	charmap "限", $41
	
	charmap "報", $43
	charmap "告", $44
	
	charmap "全", $46
	
	charmap "内", $48
	charmap "敵", $49
	charmap "攻", $4A
	charmap "兵", $4B
	charmap "器", $4C
	
	charmap "各", $4F
	charmap "彼", $50
	charmap "型", $51
	
	charmap "能", $53
	charmap "突", $54
	charmap "如", $55
	charmap "科", $56
	charmap "学", $57
	charmap "者", $58
	charmap "起", $59
	charmap "送", $5A
	charmap "同", $5B
	charmap "面", $5C
	charmap "示", $5D
	charmap "音", $5E
	
	charmap "本", $61
	charmap "<向alt>", $62 ;duplicate character, drawn different
	charmap "巨", $63
	charmap "化", $64
	charmap "虫", $65
	charmap "守", $66
	
	charmap "正", $68
	
	charmap "位", $6A
	charmap "置", $6B
	charmap "映", $6c
	charmap "像", $6d
	
	charmap "図", $70
	charmap "基", $71
	charmap "場", $72
	charmap "所", $73
	charmap "射", $74
	charmap "入", $75
	charmap "手", $76
	charmap "情", $77
	
	charmap "止", $7B
	
	charmap "変", $7D
	
	charmap "少", $B1
	charmap "中", $B2
	charmap "安", $B3
	
	charmap "給", $B7
	charmap "補", $B8
	
	charmap "知", $BA
	charmap "幼", $BB
	charmap "空", $BC
	charmap "法", $BD
	charmap "思", $BE
	charmap "生", $BF
	charmap "平", $C0
	charmap "和", $C1
	charmap "東", $C2 ;east
	charmap "西", $C3 ;west
	charmap "南", $C4 ;south
	charmap "北", $C5 ;north
	
	charmap "十", $C7 ;used for dpad
	
	charmap "完", $C9
	charmap "了", $CA
	charmap "右", $CB
	charmap "近", $CC
	charmap "開", $CD
	charmap "反", $CE
	charmap "応", $CF
	charmap "！", $D0
	charmap "Ｖ", $D1
	charmap "Ｉ", $D2
	charmap "Ｘ", $D3
	charmap "Ａ", $D4
	charmap "Ｂ", $D5
	charmap "Ｌ", $D6
	charmap "Ｏ", $D7
	charmap "Ｗ", $D8
	charmap "Ｅ", $D9
	charmap "Ｔ", $DA
	charmap "左", $DB
	charmap "字", $DC
	charmap "白", $DD
	charmap "央", $DE
