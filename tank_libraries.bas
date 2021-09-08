function empty(x as ubyte,y as ubyte) as ubyte
	dim emptyreturn,xx1,xx2,yy1,yy2 as ubyte
	emptyreturn = 0
	xx1=peek(@mapa+cast(uinteger,28)*y+x)
	xx2=peek(@mapa+cast(uinteger,28)*y+x+1)
	yy1=peek(@mapa+cast(uinteger,28)*(y+1)+x)
	yy2=peek(@mapa+cast(uinteger,28)*(y+1)+x+1)
	if xx1=0 and xx2=0 and yy1=0 and yy2=0
		emptyreturn=1
	end if 
	return emptyreturn
end function

function fastcall pintaescenario()
poke uinteger $7c00,@mapa
poke uinteger $7c02,@udg
rem $7c08 es y
rem $7c09 es x
rem $7c0A es udg del mapa 1


asm
visiblex 	equ 20
visibley 	equ 20
mapaxy 		equ 28
mapasize	equ 784
	
	ld b,0; b es la fila en y

filas:

	ld c,0 ; c es la columnas en x
	call dfloc

columnas:	
	push hl
	ld hl,($7c00)
	ld de,mapaxy ; 28=columnas del mapa completo
calcudgaddr:	
	ld a,($7c08); le sumo la 'y' a partir de la que quiero ver escenario
	add a,b

map1ca1:		
	jr z, map1ca2
	add hl,de
	dec a
	jr map1ca1
map1ca2:
	ld a,($7c09)
	add a,c
	ld d,0
	ld e,a
	add hl,de
	; aqui tenemos en hl la url del mapa
	ld a,(hl) ; a es el udg (0,1,2,...)	
	jp spp
	

	ld ($7c0a),a; guarda a
	;Calculamos la dirección del mapa2
	ld hl,($7c00)
	ld de,mapasize ; 784 (28x28)
	add hl,de
	ld de,visiblex ; 20=columnas del mapa visible
	ld a,b
	and a
map2ca1:		
	jr z, map2ca2	
	add hl,de
	dec a
	jr map2ca1
map2ca2:
	ld d,0
	ld e,c
	add hl,de
	; aqui tenemos en hl la addr del mapa2
	ld a,($7c0a); carga en a lo que había en mapa1
	cp (hl)
	jr z,loop2 ;el byte es igual que lo que había, no actualizar
	ld (hl),a ; actualiza el mapa2 con lo que vamos a pintar
spp:		
	ld hl,($7c02); hl tiene el primer byte de los udg
	and a
ca3:
	jr z, ca4
	ld de,9
	add hl,de
	dec a 
	jr ca3
ca4:	
	ld d,h
	ld e,l
	;de=primer byte del udg que toca por mapa direccion udg
	ld hl,($7c02)

	call attloc
	
	;carga el atributo
	ld a,(de)
	ld(hl),a
	inc de
	
	;call dfloc
	pop hl
	push hl
	push bc
	ld b,8
loop:
	;296 tstates
	ld a,(de)
	ld (hl),a
	inc h
	inc de
	djnz loop
	pop bc
loop2:
	pop hl
	inc hl
	inc c
	ld a,c
	cp visiblex
	jr nz, columnas
	inc b
	ld a,b
	cp visibley
	jr nz, filas

	ret

attloc:	
	inc b
	inc c
	inc b
	inc c
	ld a,b
	sra a
	sra a
	sra a
	add a,$e8; e8
	ld h,a
	ld a,b
	and 7
	rrca
	rrca
	rrca
	add a,c
	ld l,a
	dec b
	dec c
	dec b
	dec c
	ret

dfloc:
	inc b
	inc c
	inc b
	inc c
	ld a,b
	and $f8
	add a,$d0; d0
	ld h,a
	ld a,b
	and 7
	rrca
	rrca
	rrca
	add a,c
	ld l,a
	dec b
	dec c
	dec b
	dec c
	ret

end asm
end function



function fastcall mapa()
asm
defb 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
defb 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,4,4,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,4,4,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,4
defb 4,1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,1,1,4
defb 4,4,4,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,4,4,4
defb 4,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,1,1,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,1,1,0,0,1,1,0,0,0,1,1,1,1,0,0,0,1,1,0,0,1,1,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,4
defb 4,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,4
defb 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4



;copia
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
   
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
   
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
   
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255
defb 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255, 255,255,255,255,255


end asm
end function

function fastcall udg()
asm
defb 00110000b,0,0,0,0,32,0,1,0; 0
defb 00000010b,254,254,254,0,239,239,239,0;ladrillo 1
defb 00100000b,126,129,131,129,131,129,171,126; 2 
defb 00100000b,60,66,129,129,129,129,66,60; arbol 3 
defb 00100000b,01111110b,10000001b,10000001b,10000001b,10000001b,10000001b,10000001b,01111110b; lleno 4 
defb 00000000b,255,255,255,255,255,255,255,255; lleno 5 
defb 00000000b,255,255,255,255,255,255,255,255; lleno 6 
defb 00000000b,255,255,255,255,255,255,255,255; lleno 7 
defb 00000000b,255,255,255,255,255,255,255,255; lleno 8
defb 00000000b,255,255,255,255,255,255,255,255; lleno 9

;arriba
defb 00110000b,1,1,1,241,159,241,151,244
defb 00110000b,128,128,128,143,249,143,233,47; 10,11
defb 00110000b,153,249,148,244,146,243,159,240
defb 00110000b,153,159,41,47,73,207,249,15; 12,13
;derecha
defb 00110000b,255,170,170,255,67,76,112,99
defb 00110000b,248,168,168,248,16,208,80,127; 22,23
defb 00110000b,99,112,76,67,255,170,170,255
defb 00110000b,127,80,208,16,248,168,168,248; 24,25
;abajo
defb 00110000b,240,159,243,146,244,148,249,153
defb 00110000b,15,249,207,73,47,41,159,153; 14,15
defb 00110000b,244,151,241,159,241,1,1,1
defb 00110000b,47,233,143,249,143,128,128,128; 16,17
;izquierda
defb 00110000b,31,21,21,31,8,11,10,254
defb 00110000b,255,85,85,255,194,50,14,198; 18,19
defb 00110000b,254,10,11,8,31,21,21,31
defb 00110000b,198,14,50,194,255,85,85,255; 20,21

;arriba pequeño
defb 00110000b,0,1,1,121,73,127,73,127,00110000b,0,128,128,158,146,254,146,254
defb 00110000b,76,121,73,124,76,123,0,0,00110000b,50,158,146,62,50,222,0,0
;derecha pequeño
defb 00110000b,0,63,42,42,63,25,32,38,00110000b,0,248,168,168,248,160,160,254
defb 00110000b,38,32,25,63,42,42,63,0,00110000b,254,160,160,248,168,168,248,0
;abajo pequeño
defb 00110000b,0,0,120,75,124,76,121,73,00110000b,0,0,30,210,62,50,158,146
defb 00110000b,124,79,121,79,121,1,1,0,00110000b,62,242,158,242,158,128,128,0
;izquierda pequeño
defb 00110000b,0,31,21,21,31,5,5,125,00110000b,0,252,84,84,252,152,4,100
defb 00110000b,125,5,5,31,21,21,31,0,00110000b,100,4,152,252,84,84,252,0

;arriba bala
defb 00110000b,0,0,0,0,0,0,1,1,00110000b,0,0,0,0,0,0,128,128
defb 00110000b,1,1,1,0,1,0,0,1,00110000b,128,128,128,0,128,0,0,128
;derecha bala
defb 00110000b,0,0,0,0,0,0,0,151,00110000b,0,0,0,0,0,0,0,192
defb 00110000b,151,0,0,0,0,0,0,0,00110000b,192,0,0,0,0,0,0,0
;abajo bala
defb 00110000b,1,0,0,1,0,1,1,1,00110000b,128,0,0,128,0,128,128,128
defb 00110000b,1,1,0,0,0,0,0,0,00110000b,128,128,0,0,0,0,0,0
;izquierda bala
defb 00110000b,0,0,0,0,0,0,0,3,00110000b,0,0,0,0,0,0,0,233
defb 00110000b,3,0,0,0,0,0,0,0,00110000b,233,0,0,0,0,0,0,0

end asm
end function

function fastcall music()
asm

call music
jp endd:

music:
org 50000
defb $21,$25,$c4,$7e,$32,$7f,$c3,$23,$7e,$32,$7b,$c3,$23,$22,$87,$c3
defb $22,$9a,$c3,$3e,$fe,$32,$73,$c3,$f3,$cd,$75,$c3,$cd,$99,$c3,$18
defb $fb,$fb,$c9,$00,$35,$3a,$73,$c3,$3c,$3c,$fe,$02,$20,$05,$3e,$00
defb $e1,$fb,$c9,$32,$73,$c3,$21,$27,$c4,$5f,$16,$00,$19,$5e,$23,$56
defb $1a,$32,$24,$c4,$3e,$01,$32,$74,$c3,$21,$27,$c4,$3a,$73,$c3,$5f
defb $16,$00,$19,$5e,$23,$56,$3a,$74,$c3,$6f,$26,$00,$19,$56,$1e,$01
defb $7a,$a7,$28,$c1,$d5,$23,$56,$1e,$01,$3a,$74,$c3,$3c,$3c,$32,$74
defb $c3,$e1,$7c,$3d,$20,$04,$7a,$3d,$28,$3c,$3a,$24,$c4,$4f,$06,$00
defb $3e,$00,$08,$3e,$00,$dd,$62,$16,$10,$00,$00,$08,$1d,$d3,$fe,$20
defb $13,$dd,$5c,$aa,$08,$2d,$c2,$fb,$c3,$d3,$fe,$6c,$aa,$10,$ea,$0c
defb $c2,$db,$c3,$c9,$28,$fe,$08,$2d,$ca,$e9,$c3,$d3,$fe,$00,$00,$10
defb $d8,$0c,$c2,$db,$c3,$c9,$3a,$24,$c4,$2f,$4f,$c5,$f5,$06,$00,$e5
defb $21,$00,$00,$cb,$2e,$cb,$2e,$cb,$2e,$00,$e1,$10,$f2,$0d,$c2,$0f
defb $c4,$f1,$c1,$c9,$ea,$00,$02,$29,$c4,$ea,$5b,$01,$51,$01,$4c,$01
defb $5b,$01,$51,$01,$4c,$01,$4c,$01,$44,$01,$40,$01,$4c,$01,$44,$01
defb $40,$01,$39,$01,$33,$01,$2d,$01,$39,$01,$33,$01,$2d,$01,$01,$01
defb $01,$01,$01,$01,$01,$01,$2d,$01,$2d,$01,$2d,$01,$2d,$01,$00,$00
endd:
end asm
end function


function fastcall music2()
asm

call music
jp endd:

music:
org 50000
defb $f3,$d9, $e5,$cd ,$5c,$c3 ,$ed,$56, $e1,$d9,$fb,$c9,$cd,$99,$c5,$cd
defb $bf,$c5, $ed,$5e ,$3e,$39 ,$ed,$47, $21,$00,$c6,$5e,$23,$56,$23,$22
defb $c1,$c4, $ed,$53 ,$df,$c4 ,$ed,$73, $ba,$c5,$21,$a7,$c5,$22,$f5,$ff
defb $3e,$00, $32,$e8 ,$c3,$32 ,$f1,$c3, $32,$3c,$c4,$32,$45,$c4,$cd,$c0
defb $c4,$cd, $de,$c4 ,$0e,$01 ,$d9,$01, $01,$01,$fb,$76,$dc,$83,$c4,$78
defb $b7,$20, $35,$21 ,$00,$00 ,$7e,$b7, $fa,$fa,$c4,$cd,$b3,$c4,$32,$e1
defb $c3,$cb, $3f,$cb ,$3f,$cb ,$3f,$57, $32,$ec,$c3,$af,$32,$84,$c4,$3c
defb $32,$e3, $c3,$3a ,$e8,$c3 ,$f6,$18, $32,$e8,$c3,$23,$7e,$32,$d5,$c3
defb $23,$22, $a4,$c3 ,$06,$54 ,$18,$05, $3e,$03,$3d,$20,$fd,$15,$20,$14
defb $16,$3b, $3e,$07 ,$3d,$20 ,$fd,$3e, $00,$d3,$fe,$3e,$01,$3d,$20,$fd
defb $3e,$00, $d3,$fe ,$79,$b7 ,$20,$33, $21,$00,$00,$7e,$b7,$fa,$09,$c5
defb $cd,$b3, $c4,$32 ,$35,$c4 ,$cb,$3f, $cb,$3f,$32,$40,$c4,$5f,$af,$32
defb $9c,$c4, $3c,$32 ,$37,$c4 ,$3a,$3c, $c4,$f6,$18,$32,$3c,$c4,$23,$7e
defb $32,$28, $c4,$23 ,$22,$f9 ,$c3,$0e, $0e,$18,$05,$3e,$03,$3d,$20,$fd
defb $1d,$c2, $9c,$c3 ,$1e,$3b ,$3e,$02, $3d,$20,$fd,$3e,$18,$d3,$fe,$3e
defb $0d,$3d, $20,$fd ,$3e,$00 ,$d3,$fe, $c3,$9c,$c3,$e1,$7e,$32,$8a,$c4
defb $23,$c3, $a6,$c3 ,$e1,$7e ,$32,$a2, $c4,$23,$18,$9f,$e1,$3a,$e8,$c3
defb $e6,$07, $32,$e8 ,$c3,$c3 ,$cc,$c3, $e1,$3a,$3c,$c4,$e6,$07,$32,$3c
defb $c4,$c3, $1f,$c4 ,$e1,$c3 ,$cc,$c3, $e1,$c3,$1f,$c4,$e1,$cd,$c0,$c4
defb $c3,$a3, $c3,$3e ,$00,$3c ,$32,$84, $c4,$fe,$02,$38,$0e,$af,$32,$84
defb $c4,$21, $ec,$c3 ,$35,$28 ,$03,$21, $e3,$c3,$34,$3e,$00,$3c,$32,$9c
defb $c4,$fe, $04,$d8 ,$af,$32 ,$9c,$c4, $21,$40,$c4,$35,$28,$03,$21,$37
defb $c4,$34, $c9,$e5 ,$d5,$21 ,$ca,$c5, $5f,$16,$00,$19,$7e,$d1,$e1,$c9
defb $21,$00, $00,$5e ,$23,$56 ,$23,$7b, $b2,$20,$03,$c3,$b9,$c5,$22,$c1
defb $c4,$eb, $5e,$23 ,$56,$23 ,$22,$a4, $c3,$ed,$53,$f9,$c3,$c9,$21,$00
defb $00,$5e, $23,$56 ,$23,$22 ,$df,$c4, $ed,$53,$19,$c5,$7b,$b2,$c0,$5e
defb $23,$56, $eb,$18 ,$ec,$cd ,$de,$c4, $18,$1e,$23,$e5,$e6,$7f,$cd,$33
defb $c5,$7c, $c4,$4b ,$c4,$5c ,$c4,$74, $c4,$23,$e5,$e6,$7f,$cd,$33,$c5
defb $7c,$c4, $54,$c4 ,$68,$c4 ,$78,$c4, $21,$00,$00,$7e,$23,$4e,$23,$22
defb $19,$c5, $e6,$7f ,$cd,$33 ,$c5,$3c, $c5,$41,$c5,$54,$c5,$63,$c5,$7e
defb $c5,$98, $c5,$e1 ,$87,$85 ,$6f,$7e, $23,$66,$6f,$e9,$cd,$de,$c4,$18
defb $d7,$1e, $0a,$3e ,$00,$21 ,$00,$01, $ee,$18,$d3,$fe,$46,$10,$fe,$23
defb $1d,$20, $f5,$c9 ,$21,$5a ,$00,$7e, $b7,$c8,$e6,$18,$f6,$00,$d3,$fe
defb $23,$18, $f4,$21 ,$18,$0f ,$16,$0a, $46,$10,$fe,$3e,$18,$f6,$00,$d3
defb $fe,$23, $46,$10 ,$fe,$3e ,$00,$d3, $fe,$23,$15,$20,$eb,$c9,$1e,$3f
defb $16,$05, $43,$10 ,$fe,$3e ,$18,$f6, $00,$d3,$fe,$7b,$0f,$5f,$47,$10
defb $fe,$3e, $00,$d3 ,$fe,$15 ,$20,$ea, $c9,$21,$00,$39,$11,$01,$39,$01
defb $00,$01, $36,$ff ,$ed,$b0 ,$c9,$f5, $d5,$e5,$0d,$05,$d9,$0d,$cc,$18
defb $c5,$d9, $e1,$d1 ,$f1,$37 ,$fb,$ed, $4d,$31,$00,$00,$fb,$ed,$4d,$21
defb $ff,$ff, $36,$18 ,$21,$f4 ,$ff,$36, $c3,$c9,$fd,$ee,$e1,$d4,$c8,$bd
defb $b2,$a8, $9f,$96 ,$8e,$86 ,$7e,$77, $70,$6a,$64,$5e,$59,$54,$4f,$4b
defb $47,$43, $3f,$3b ,$38,$35 ,$32,$2f, $2c,$2a,$27,$25,$23,$21,$1f,$1d
defb $1c,$1b, $19,$17 ,$16,$15 ,$13,$12, $11,$10,$0f,$0e,$0d,$0c,$01,$00
defb $3c,$c6, $08,$c6 ,$00,$00 ,$02,$c6, $39,$c6,$12,$09,$14,$09,$15,$09
defb $12,$09, $14,$09 ,$15,$09 ,$15,$09, $17,$09,$18,$09,$15,$09,$17,$09
defb $18,$09, $1a,$09 ,$1c,$09 ,$1e,$09, $1a,$09,$1c,$09,$1e,$12,$1e,$12
defb $1e,$09, $1e,$09 ,$1e,$09 ,$1e,$12, $80,$83,$ea,$80,$42,$c6,$00,$00
defb $3c,$c6, $85,$ea ,$80
endd:
end asm
end function


function fastcall pintabuffer()
asm
halt

di

ld a,20
ld b,0

ld hl,53314
ld de,16450
ld c,a 
 ldir 

ld hl,53570
ld de,16706
ld c,a 
 ldir 

ld hl,53826
ld de,16962
ld c,a 
 ldir 

ld hl,54082
ld de,17218
ld c,a 
 ldir 

ld hl,54338
ld de,17474
ld c,a 
 ldir 

ld hl,54594
ld de,17730
ld c,a 
 ldir 

ld hl,54850
ld de,17986
ld c,a 
 ldir 

ld hl,55106
ld de,18242
ld c,a 
 ldir 

ld hl,53346
ld de,16482
ld c,a 
 ldir 

ld hl,53602
ld de,16738
ld c,a 
 ldir 

ld hl,53858
ld de,16994
ld c,a 
 ldir 

ld hl,54114
ld de,17250
ld c,a 
 ldir 

ld hl,54370
ld de,17506
ld c,a 
 ldir 

ld hl,54626
ld de,17762
ld c,a 
 ldir 

ld hl,54882
ld de,18018
ld c,a 
 ldir 

ld hl,55138
ld de,18274
ld c,a 
 ldir 

ld hl,53378
ld de,16514
ld c,a 
 ldir 

ld hl,53634
ld de,16770
ld c,a 
 ldir 

ld hl,53890
ld de,17026
ld c,a 
 ldir 

ld hl,54146
ld de,17282
ld c,a 
 ldir 

ld hl,54402
ld de,17538
ld c,a 
 ldir 

ld hl,54658
ld de,17794
ld c,a 
 ldir 

ld hl,54914
ld de,18050
ld c,a 
 ldir 

ld hl,55170
ld de,18306
ld c,a 
 ldir 

ld hl,53410
ld de,16546
ld c,a 
 ldir 

ld hl,53666
ld de,16802
ld c,a 
 ldir 

ld hl,53922
ld de,17058
ld c,a 
 ldir 

ld hl,54178
ld de,17314
ld c,a 
 ldir 

ld hl,54434
ld de,17570
ld c,a 
 ldir 

ld hl,54690
ld de,17826
ld c,a 
 ldir 

ld hl,54946
ld de,18082
ld c,a 
 ldir 

ld hl,55202
ld de,18338
ld c,a 
 ldir 

ld hl,53442
ld de,16578
ld c,a 
 ldir 

ld hl,53698
ld de,16834
ld c,a 
 ldir 

ld hl,53954
ld de,17090
ld c,a 
 ldir 

ld hl,54210
ld de,17346
ld c,a 
 ldir 

ld hl,54466
ld de,17602
ld c,a 
 ldir 

ld hl,54722
ld de,17858
ld c,a 
 ldir 

ld hl,54978
ld de,18114
ld c,a 
 ldir 

ld hl,55234
ld de,18370
ld c,a 
 ldir 

ld hl,53474
ld de,16610
ld c,a 
 ldir 

ld hl,53730
ld de,16866
ld c,a 
 ldir 

ld hl,53986
ld de,17122
ld c,a 
 ldir 

ld hl,54242
ld de,17378
ld c,a 
 ldir 

ld hl,54498
ld de,17634
ld c,a 
 ldir 

ld hl,54754
ld de,17890
ld c,a 
 ldir 

ld hl,55010
ld de,18146
ld c,a 
 ldir 

ld hl,55266
ld de,18402
ld c,a 
 ldir 

ld hl,55298
ld de,18434
ld c,a 
 ldir 

ld hl,55554
ld de,18690
ld c,a 
 ldir 

ld hl,55810
ld de,18946
ld c,a 
 ldir 

ld hl,56066
ld de,19202
ld c,a 
 ldir 

ld hl,56322
ld de,19458
ld c,a 
 ldir 

ld hl,56578
ld de,19714
ld c,a 
 ldir 

ld hl,56834
ld de,19970
ld c,a 
 ldir 

ld hl,57090
ld de,20226
ld c,a 
 ldir 

ld hl,55330
ld de,18466
ld c,a 
 ldir 

ld hl,55586
ld de,18722
ld c,a 
 ldir 

ld hl,55842
ld de,18978
ld c,a 
 ldir 

ld hl,56098
ld de,19234
ld c,a 
 ldir 

ld hl,56354
ld de,19490
ld c,a 
 ldir 

ld hl,56610
ld de,19746
ld c,a 
 ldir 

ld hl,56866
ld de,20002
ld c,a 
 ldir 

ld hl,57122
ld de,20258
ld c,a 
 ldir 

ld hl,55362
ld de,18498
ld c,a 
 ldir 

ld hl,55618
ld de,18754
ld c,a 
 ldir 

ld hl,55874
ld de,19010
ld c,a 
 ldir 

ld hl,56130
ld de,19266
ld c,a 
 ldir 

ld hl,56386
ld de,19522
ld c,a 
 ldir 

ld hl,56642
ld de,19778
ld c,a 
 ldir 

ld hl,56898
ld de,20034
ld c,a 
 ldir 

ld hl,57154
ld de,20290
ld c,a 
 ldir 

ld hl,55394
ld de,18530
ld c,a 
 ldir 

ld hl,55650
ld de,18786
ld c,a 
 ldir 

ld hl,55906
ld de,19042
ld c,a 
 ldir 

ld hl,56162
ld de,19298
ld c,a 
 ldir 

ld hl,56418
ld de,19554
ld c,a 
 ldir 

ld hl,56674
ld de,19810
ld c,a 
 ldir 

ld hl,56930
ld de,20066
ld c,a 
 ldir 

ld hl,57186
ld de,20322
ld c,a 
 ldir 

ld hl,55426
ld de,18562
ld c,a 
 ldir 

ld hl,55682
ld de,18818
ld c,a 
 ldir 

ld hl,55938
ld de,19074
ld c,a 
 ldir 

ld hl,56194
ld de,19330
ld c,a 
 ldir 

ld hl,56450
ld de,19586
ld c,a 
 ldir 

ld hl,56706
ld de,19842
ld c,a 
 ldir 

ld hl,56962
ld de,20098
ld c,a 
 ldir 

ld hl,57218
ld de,20354
ld c,a 
 ldir 

ld hl,55458
ld de,18594
ld c,a 
 ldir 

ld hl,55714
ld de,18850
ld c,a 
 ldir 

ld hl,55970
ld de,19106
ld c,a 
 ldir 

ld hl,56226
ld de,19362
ld c,a 
 ldir 

ld hl,56482
ld de,19618
ld c,a 
 ldir 

ld hl,56738
ld de,19874
ld c,a 
 ldir 

ld hl,56994
ld de,20130
ld c,a 
 ldir 

ld hl,57250
ld de,20386
ld c,a 
 ldir 

ld hl,55490
ld de,18626
ld c,a 
 ldir 

ld hl,55746
ld de,18882
ld c,a 
 ldir 

ld hl,56002
ld de,19138
ld c,a 
 ldir 

ld hl,56258
ld de,19394
ld c,a 
 ldir 

ld hl,56514
ld de,19650
ld c,a 
 ldir 

ld hl,56770
ld de,19906
ld c,a 
 ldir 

ld hl,57026
ld de,20162
ld c,a 
 ldir 

ld hl,57282
ld de,20418
ld c,a 
 ldir 

ld hl,55522
ld de,18658
ld c,a 
 ldir 

ld hl,55778
ld de,18914
ld c,a 
 ldir 

ld hl,56034
ld de,19170
ld c,a 
 ldir 

ld hl,56290
ld de,19426
ld c,a 
 ldir 

ld hl,56546
ld de,19682
ld c,a 
 ldir 

ld hl,56802
ld de,19938
ld c,a 
 ldir 

ld hl,57058
ld de,20194
ld c,a 
 ldir 

ld hl,57314
ld de,20450
ld c,a 
 ldir 

ld hl,57346
ld de,20482
ld c,a 
 ldir 

ld hl,57602
ld de,20738
ld c,a 
 ldir 

ld hl,57858
ld de,20994
ld c,a 
 ldir 

ld hl,58114
ld de,21250
ld c,a 
 ldir 

ld hl,58370
ld de,21506
ld c,a 
 ldir 

ld hl,58626
ld de,21762
ld c,a 
 ldir 

ld hl,58882
ld de,22018
ld c,a 
 ldir 

ld hl,59138
ld de,22274
ld c,a 
 ldir 

ld hl,57378
ld de,20514
ld c,a 
 ldir 

ld hl,57634
ld de,20770
ld c,a 
 ldir 

ld hl,57890
ld de,21026
ld c,a 
 ldir 

ld hl,58146
ld de,21282
ld c,a 
 ldir 

ld hl,58402
ld de,21538
ld c,a 
 ldir 

ld hl,58658
ld de,21794
ld c,a 
 ldir 

ld hl,58914
ld de,22050
ld c,a 
 ldir 

ld hl,59170
ld de,22306
ld c,a 
 ldir 

ld hl,57410
ld de,20546
ld c,a 
 ldir 

ld hl,57666
ld de,20802
ld c,a 
 ldir 

ld hl,57922
ld de,21058
ld c,a 
 ldir 

ld hl,58178
ld de,21314
ld c,a 
 ldir 

ld hl,58434
ld de,21570
ld c,a 
 ldir 

ld hl,58690
ld de,21826
ld c,a 
 ldir 

ld hl,58946
ld de,22082
ld c,a 
 ldir 

ld hl,59202
ld de,22338
ld c,a 
 ldir 

ld hl,57442
ld de,20578
ld c,a 
 ldir 

ld hl,57698
ld de,20834
ld c,a 
 ldir 

ld hl,57954
ld de,21090
ld c,a 
 ldir 

ld hl,58210
ld de,21346
ld c,a 
 ldir 

ld hl,58466
ld de,21602
ld c,a 
 ldir 

ld hl,58722
ld de,21858
ld c,a 
 ldir 

ld hl,58978
ld de,22114
ld c,a 
 ldir 

ld hl,59234
ld de,22370
ld c,a 
 ldir 

ld hl,57474
ld de,20610
ld c,a 
 ldir 

ld hl,57730
ld de,20866
ld c,a 
 ldir 

ld hl,57986
ld de,21122
ld c,a 
 ldir 

ld hl,58242
ld de,21378
ld c,a 
 ldir 

ld hl,58498
ld de,21634
ld c,a 
 ldir 

ld hl,58754
ld de,21890
ld c,a 
 ldir 

ld hl,59010
ld de,22146
ld c,a 
 ldir 

ld hl,59266
ld de,22402
ld c,a 
 ldir 

ld hl,57506
ld de,20642
ld c,a 
 ldir 

ld hl,57762
ld de,20898
ld c,a 
 ldir 

ld hl,58018
ld de,21154
ld c,a 
 ldir 

ld hl,58274
ld de,21410
ld c,a 
 ldir 

ld hl,58530
ld de,21666
ld c,a 
 ldir 

ld hl,58786
ld de,21922
ld c,a 
 ldir 

ld hl,59042
ld de,22178
ld c,a 
 ldir 

ld hl,59298
ld de,22434
ld c,a 
 ldir 

ld de,22530+32*2
ld hl,36864+22530+32*2
ld c,a
ldir

ld de,22530+32*3
ld hl,36864+22530+32*3
ld c,a
ldir

ld de,22530+32*4
ld hl,36864+22530+32*4
ld c,a
ldir

ld de,22530+32*5
ld hl,36864+22530+32*5
ld c,a
ldir
ld de,22530+32*6
ld hl,36864+22530+32*6
ld c,a
ldir
ld de,22530+32*7
ld hl,36864+22530+32*7
ld c,a
ldir
ld de,22530+32*8
ld hl,36864+22530+32*8
ld c,a
ldir
ld de,22530+32*9
ld hl,36864+22530+32*9
ld c,a
ldir
ld de,22530+32*10
ld hl,36864+22530+32*10
ld c,a
ldir
ld de,22530+32*11
ld hl,36864+22530+32*11
ld c,a
ldir
ld de,22530+32*12
ld hl,36864+22530+32*12
ld c,a
ldir
ld de,22530+32*13
ld hl,36864+22530+32*13
ld c,a
ldir
ld de,22530+32*14
ld hl,36864+22530+32*14
ld c,a
ldir
ld de,22530+32*15
ld hl,36864+22530+32*15
ld c,a
ldir
ld de,22530+32*16
ld hl,36864+22530+32*16
ld c,a
ldir
ld de,22530+32*17
ld hl,36864+22530+32*17
ld c,a
ldir
ld de,22530+32*18
ld hl,36864+22530+32*18
ld c,a
ldir
ld de,22530+32*19
ld hl,36864+22530+32*19
ld c,a
ldir
ld de,22530+32*20
ld hl,36864+22530+32*20
ld c,a
ldir
ld de,22530+32*21
ld hl,36864+22530+32*21
ld c,a
ldir
ei
halt

end asm
end function