
function empty(x as ubyte,y as ubyte) as ubyte
	dim emptyreturn,xx1,xx2,yy1,yy2 as ubyte
	emptyreturn = 0
	xx1=peek(@mapa+cast(uinteger,32)*y+x)
	xx2=peek(@mapa+cast(uinteger,32)*y+x+1)
	yy1=peek(@mapa+cast(uinteger,32)*(y+1)+x)
	yy2=peek(@mapa+cast(uinteger,32)*(y+1)+x+1)
	if xx1=0 and xx2=0 and yy1=0 and yy2=0
		emptyreturn=1
	end if 
	return emptyreturn
end function




function quehay(x as ubyte, y as ubyte) as ubyte
	return peek(@mapa+cast(uinteger,32)*cast(uinteger,y)+cast(uinteger,x))
end function

sub pon(x as ubyte, y as ubyte, ch as ubyte)
	poke @mapa+cast(uinteger,32)*cast(uinteger,y)+cast(uinteger,x), ch
end sub

function fastcall pintaescenario()
poke uinteger $7c00,@mapa
poke uinteger $7c02,@udg
rem $7c08 es y
rem $7c09 es x

asm
	di
	push ix 
	push iy
	ld ixh, 0; Y = ixh = filas
	ld ixl,0 ; X = ixl = colum
	
	;iy tiene la addr del mapa

	ld iy,($7c00)

	ld bc,64

	ld a,($7c08)
	add a,ixh
	or a
	jr z,l4
l1:
	add iy,bc
	dec a
	cp 0
	jr nz, l1
l4:	
	;Sumar a iy, ixl

	ld b,0
	ld a,($7c09)
	add a,ixl
	ld c,a
	add iy,bc
	add iy,bc
	
	;iy tiene la addr del chr

fil:
	ld ixl,0
	call attloc
	push hl
	call dfloc
	push hl


col:
	
	ld a,(iy+0)
	; en a tengo el tipo de chr
	
	ld de,($7c02)
	or a
	jr z,l5; si a es cero no sumes nada

	ex de,hl; hl guardado en de
	ld bc,9
l2:
	add hl,bc
	dec a
	jr nz, l2
	ex de, hl
l5:
	
	;en de tengo el ppio del bitmap del char
	call pintachar
	pop bc
	pop hl
	ld a,(de)
	ld (hl),a
	inc hl
	push hl
	push bc


l6:
	pop hl
	inc hl
	push hl

	inc iy; next chr on map

	inc ixl
	ld a,20
	cp ixl
	jr nz, col

	pop hl
	pop hl

	ld bc,12
	add iy,bc

	inc ixh
	cp ixh
	jr nz, fil	

	jp endd




pintachar: 
;	de=addr udg
;	hl=addr pantalla
	ld b,8
loop:
	;296 tstates 
	ld a,(de)
	ld (hl),a
	inc h
	inc de
	djnz loop
	ret

attloc:	
	inc ixh
	inc ixl
	inc ixh
	inc ixl
	ld a,ixh
	sra a
	sra a
	sra a
	add a,$e8;58 
	ld h,a
	ld a,ixh
	and 7
	rrca
	rrca
	rrca
	add a,ixl
	ld l,a
	dec ixh
	dec ixl
	dec ixh
	dec ixl
	ret

; col=ixl filas=ixh
dfloc:  
	inc ixh
	inc ixl
	inc ixh
	inc ixl
	ld a,ixh
	and $f8
	add a,$d0;40 
	ld h,a
	ld a,ixh
	and 7
	rrca
	rrca
	rrca
	add a,ixl
	ld l,a
	dec ixh
	dec ixl
	dec ixh
	dec ixl
	ret	
endd:
pop iy
pop ix
ei
end asm
end function




function fastcall mapa()
asm
defb 5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6
defb 7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8
defb 5,6,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,4,4,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,4,4,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,1,1,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,1,1,3,5,6
defb 7,8,3,4,4,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,4,4,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,1,1,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,0,1,1,1,1,0,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,7,8
defb 5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6
defb 7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8

end asm
end function

function fastcall udg()
asm
defb 0,0,0,0,32,0,2,0,00110000b
defb 11111111b,01000000b,01000000b,01000000b,11111111b,00000010b,00000010b,00000010b,00010000b
defb 126,129,131,129,131,129,171,126,00100000b
defb 00000001b,01000101b,00000001b,00000001b,00000001b,01000101b,00000001b,11111111b,00111000b
defb 01111110b,10000001b,10000001b,10000001b,10000001b,10000001b,10000001b,01111110b,00100000b
defb 10001100b,00000111b,00011000b,00100000b,01000000b,11000000b,01100000b,01010000b,01100000b
defb 00001000b,10001000b,11110000b,01110000b,00101101b,00110110b,00101000b,00101100b,00100000b
defb 00101010b,00011111b,00000111b,00000110b,00001011b,01110000b,10001100b,00001000b,00100000b
defb 01101000b,11001100b,10001010b,00000101b,11100011b,00010000b,00001001b,00001010b,00100000b
defb 255,255,255,255,255,255,255,255,00000000b


;tplayer
defb 1,1,1,1,5,237,125,251,00110000b
defb 128,128,128,128,224,247,254,255,00110000b
defb 119,247,123,251,123,252,127,247,00110000b
defb 254,255,254,255,254,63,254,239,00110000b
defb 170,255,255,255,127,255,223,223,00110000b
defb 160,224,224,192,224,240,240,255,00110000b
defb 223,223,227,124,255,255,255,170,00110000b
defb 255,128,112,224,192,224,224,160,00110000b
defb 247,127,255,123,251,123,247,119,00110000b
defb 239,254,255,254,255,254,255,254,00110000b
defb 251,125,237,5,1,1,1,1,00110000b
defb 255,190,247,224,128,128,128,128,00110000b
defb 5,7,7,3,7,15,13,255,00110000b
defb 85,255,255,255,254,255,255,255,00110000b
defb 255,1,14,7,3,7,7,5,00110000b
defb 255,255,199,62,255,255,255,85,00110000b
;t1
defb 1,1,1,245,109,253,123,247,00110000b
defb 128,128,128,231,246,255,254,255,00110000b
defb 118,246,118,247,119,248,127,239,00110000b
defb 126,127,126,255,254,63,246,247,00110000b
defb 170,255,255,127,255,223,223,216,00110000b
defb 168,248,248,232,240,248,248,255,00110000b
defb 216,223,223,224,63,255,255,170,00110000b
defb 255,192,184,112,224,248,248,168,00110000b
defb 239,111,255,119,247,118,246,118,00110000b
defb 247,254,255,254,255,126,127,126,00110000b
defb 247,123,253,109,229,1,1,1,00110000b
defb 255,254,223,182,239,128,128,128,00110000b
defb 21,31,31,7,15,29,27,255,00110000b
defb 85,255,255,252,255,255,255,31,00110000b
defb 255,3,29,14,23,31,31,21,00110000b
defb 31,255,255,7,254,255,255,85,00110000b
;t2
defb 0,1,1,1,1,13,125,251,00110000b
defb 0,128,128,128,128,240,254,255,00110000b
defb 118,246,123,251,123,252,119,0,00110000b
defb 126,127,254,255,254,63,238,0,00110000b
defb 42,127,127,127,63,127,95,92,00110000b
defb 128,192,192,192,224,224,224,254,00110000b
defb 92,95,99,60,127,127,127,42,00110000b
defb 254,128,96,224,192,192,192,128,00110000b
defb 0,119,255,123,251,123,246,118,00110000b
defb 0,238,255,254,255,254,127,126,00110000b
defb 251,125,13,1,1,1,1,0,00110000b
defb 223,190,240,128,128,128,128,0,00110000b
defb 1,3,3,3,7,7,6,127,00110000b
defb 84,254,254,254,252,254,254,62,00110000b
defb 127,1,6,7,3,3,3,1,00110000b
defb 62,254,198,60,254,254,254,84,00110000b
;t3
defb 0,0,1,1,1,13,125,59,00110000b
defb 0,0,128,128,128,240,254,252,00110000b
defb 118,54,123,59,123,60,119,0,00110000b
defb 126,124,254,252,254,60,238,0,00110000b
defb 128,85,127,127,63,127,127,92,00110000b
defb 0,64,192,192,224,224,192,252,00110000b
defb 92,95,99,60,127,127,85,0,00110000b
defb 252,224,224,224,192,192,64,0,00110000b
defb 0,119,63,123,59,123,54,118,00110000b
defb 0,238,252,254,252,254,124,126,00110000b
defb 59,125,13,1,1,1,0,0,00110000b
defb 252,158,240,128,128,128,0,0,00110000b
defb 0,2,3,3,7,5,5,63,00110000b
defb 0,170,254,254,252,254,254,62,00110000b
defb 63,1,6,7,3,3,2,0,00110000b
defb 62,254,198,60,254,254,170,0,00110000b
;t4
defb 0,0,1,1,1,1,55,55,00110000b
defb 0,0,128,128,128,128,236,236,00110000b
defb 62,62,63,63,55,51,0,0,00110000b
defb 124,124,252,252,236,204,0,0,00110000b
defb 0,0,63,63,15,31,63,60,00110000b
defb 0,0,192,192,0,192,192,252,00110000b
defb 60,63,31,15,63,63,0,0,00110000b
defb 252,192,192,0,192,192,0,0,00110000b
defb 0,0,51,55,63,63,62,62,00110000b
defb 0,0,204,236,252,252,124,124,00110000b
defb 55,55,1,1,1,1,0,0,00110000b
defb 236,236,128,128,128,128,0,0,00110000b
defb 0,0,3,3,0,3,3,63,00110000b
defb 0,0,252,252,240,248,252,60,00110000b
defb 63,3,3,0,3,3,0,0,00110000b
defb 60,252,248,240,252,252,0,0,00110000b
;explosiones
defb 00000000b,00110111b,01011000b,01100110b,10101000b,10100000b,10111111b,11000110b,00110000b
defb 00000000b,11100000b,10101000b,01110100b,01011010b,01010100b,10011000b,11110100b,00110000b
defb 10000000b,01001100b,01000011b,00111000b,01000111b,01000010b,00100010b,00011100b,00110000b
defb 01110010b,01100010b,01110010b,11010010b,00101100b,11011000b,00000000b,00000000b,00110000b
defb 00000000b,00000000b,00000000b,00000101b,00001010b,00010010b,00010011b,00001100b,00110000b
defb 00000000b,00000000b,00110000b,11001000b,01000100b,10100100b,00011000b,10010000b,00110000b
defb 00010001b,00001010b,00001001b,00010110b,00010000b,00001111b,00000001b,00000000b,00110000b
defb 01101000b,01001000b,10010000b,01100000b,10010000b,00010000b,00100000b,11000000b,00110000b
defb 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000011b,00000100b,00110000b
defb 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,10000000b,01000000b,00110000b
defb 00000010b,00000001b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00110000b
defb 01000000b,10000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00110000b
defb 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000011b,00000100b,00110000b
defb 00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,10000000b,01000000b,00110000b
defb 00000010b,00000001b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00110000b
defb 01000000b,10000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00000000b,00110000b

;disparo
defb 0,0,0,0,0,0,1,1,00110000b
defb 0,0,0,0,0,0,128,128,00110000b
defb 1,1,1,0,1,0,0,1,00110000b
defb 128,128,128,0,128,0,0,128,00110000b
defb 0,0,0,0,0,0,0,151,00110000b
defb 0,0,0,0,0,0,0,192,00110000b
defb 151,0,0,0,0,0,0,0,00110000b
defb 192,0,0,0,0,0,0,0,00110000b
defb 1,0,0,1,0,1,1,1,00110000b
defb 128,0,0,128,0,128,128,128,00110000b
defb 1,1,0,0,0,0,0,0,00110000b
defb 128,128,0,0,0,0,0,0,00110000b
defb 0,0,0,0,0,0,0,3,00110000b
defb 0,0,0,0,0,0,0,233,00110000b
defb 3,0,0,0,0,0,0,0,00110000b
defb 233,0,0,0,0,0,0,0,00110000b

end asm
end function




function fastcall pintabuffer()
asm

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

end asm
end function



function fastcall notes()
asm
call START
jp endd2

; *****************************************************************************
; * The Music Box Player Engine
; *
; * Based on code written by Mark Alexander for the utility, The Music Box.
; * Modified by Chris Cowley
; *
; * Produced by Beepola v1.08.01
; ******************************************************************************
 
START:
                          LD    HL,MUSICDATA         ;  <- Pointer to Music Data. Change
                                                     ;     this to play a different song
                          LD   A,(HL)                         ; Get the loop start pointer
                          LD   (PATTERN_LOOP_BEGIN),A
                          INC  HL
                          LD   A,(HL)                         ; Get the song end pointer
                          LD   (PATTERN_LOOP_END),A
                          INC  HL
                          LD   (PATTERNDATA1),HL
                          LD   (PATTERNDATA2),HL
                          LD   A,254
                          LD   (PATTERN_PTR),A                ; Set the pattern pointer to zero
                          DI
                          CALL  NEXT_PATTERN
NEXTNOTE:
                          CALL  PLAYNOTE
                          JR    NEXTNOTE                    ; Play next note

                          EI
                          RET                                 ; Return from playing tune

PATTERN_PTR:              DEFB 0
NOTE_PTR:                 DEFB 0


; ********************************************************************************************************
; * NEXT_PATTERN
; *
; * Select the next pattern in sequence (and handle looping if we've reached PATTERN_LOOP_END
; * Execution falls through to PLAYNOTE to play the first note from our next pattern
; ********************************************************************************************************
NEXT_PATTERN:
                          LD   A,(PATTERN_PTR)
                          INC  A
                          INC  A
                          DEFB $FE                           ; CP n
PATTERN_LOOP_END:         DEFB 0
                          JR   NZ,NO_PATTERN_LOOP
                          DEFB $3E                           ; LD A,n
PATTERN_LOOP_BEGIN:       DEFB 0
                          POP  HL
                          EI
                          RET
NO_PATTERN_LOOP:          LD   (PATTERN_PTR),A
			                    DEFB $21                            ; LD HL,nn
PATTERNDATA1:             DEFW $0000
                          LD   E,A                            ; (this is the first byte of the pattern)
                          LD   D,0                            ; and store it at TEMPO
                          ADD  HL,DE
                          LD   E,(HL)
                          INC  HL
                          LD   D,(HL)
                          LD   A,(DE)                         ; Pattern Tempo -> A
	                	      LD   (TEMPO),A                      ; Store it at TEMPO

                          LD   A,1
                          LD   (NOTE_PTR),A

PLAYNOTE: 
			                    DEFB $21                            ; LD HL,nn
PATTERNDATA2:             DEFW $0000
                          LD   A,(PATTERN_PTR)
                          LD   E,A
                          LD   D,0
                          ADD  HL,DE
                          LD   E,(HL)
                          INC  HL
                          LD   D,(HL)                         ; Now DE = Start of Pattern data
                          LD   A,(NOTE_PTR)
                          LD   L,A
                          LD   H,0
                          ADD  HL,DE                          ; Now HL = address of note data
                          LD   D,(HL)
                          LD   E,1

; IF D = $0 then we are at the end of the pattern so increment PATTERN_PTR by 2 and set NOTE_PTR=0
                          LD   A,D
                          AND  A                              ; Optimised CP 0
                          JR   Z,NEXT_PATTERN

                          PUSH DE
                          INC  HL
                          LD   D,(HL)
                          LD   E,1

                          LD   A,(NOTE_PTR)
                          INC  A
                          INC  A
                          LD   (NOTE_PTR),A                   ; Increment the note pointer by 2 (one note per chan)

                          POP  HL                             ; Now CH1 freq is in HL, and CH2 freq is in DE

                          LD   A,H
                          DEC  A
                          JR   NZ,OUTPUT_NOTE

                          LD   A,D                            ; executed only if Channel 2 contains a rest
                          DEC  A                              ; if DE (CH1 note) is also a rest then..
                          JR   Z,PLAY_SILENCE                 ; Play silence

OUTPUT_NOTE:              LD   A,(TEMPO)
                          LD   C,A
                          LD   B,0
                          LD   A,0
                          EX   AF,AF'
                          LD   A,0                   ; So now BC = TEMPO, A and A' = BORDER_COL
                          LD   IXH,D
                          LD   D,$10
EAE5:                     NOP
                          NOP
EAE7:                     EX   AF,AF'
                          DEC  E
                          OUT  ($FE),A
                          JR   NZ,EB04

                          LD   E,IXH
                          XOR  D
                          EX   AF,AF'
                          DEC  L
                          JP   NZ,EB0B

EAF5:                     OUT  ($FE),A
                          LD   L,H
                          XOR  D
                          DJNZ EAE5

                          INC  C
                          JP   NZ,EAE7

                          RET

EB04:
                          JR   Z,EB04
                          EX   AF,AF'
                          DEC  L
                          JP   Z,EAF5
EB0B:
                          OUT  ($FE),A
                          NOP
                          NOP
                          DJNZ EAE5
                          INC  C
                          JP   NZ,EAE7
                          RET

PLAY_SILENCE:
                          LD   A,(TEMPO)
                          CPL
                          LD   C,A
SILENCE_LOOP2:            PUSH BC
                          PUSH AF
                          LD   B,0
SILENCE_LOOP:             PUSH HL
                          LD   HL,0000
                          SRA  (HL)
                          SRA  (HL)
                          SRA  (HL)
                          NOP
                          POP  HL
                          DJNZ SILENCE_LOOP
                          DEC  C
                          JP   NZ,SILENCE_LOOP
                          POP  AF
                          POP  BC
                          RET


; *** DATA ***
TEMPO:                    DEFB 234

MUSICDATA:
                    DEFB 0   ; Loop start point * 2
                    DEFB 2   ; Song Length * 2
PATTERNDATA:        DEFW      PAT0

; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $0 to
; *** Mark the end of the pattern, and $01 for a rest
PAT0:
         DEFB 234  ; Pattern tempo
             DEFB 45,1
             DEFB 40,1
             DEFB 38,1
             DEFB 45,1
             DEFB 40,1
             DEFB 38,1
             DEFB 38,1
             DEFB 34,1
             DEFB 30,1
             DEFB 38,1
             DEFB 34,1
             DEFB 30,1
             DEFB 34,1
             DEFB 30,1
             DEFB 27,1
             DEFB 34,1
             DEFB 30,1
             DEFB 27,1
             DEFB 28,1
             DEFB 25,1
             DEFB 23,1
             DEFB 28,1
             DEFB 25,1
             DEFB 23,1
             DEFB 23,1
             DEFB 1,1
             DEFB 1,1
             DEFB 23,1
             DEFB 23,1
             DEFB 23,1
             DEFB 23,1
         	 DEFB $0

endd2:
end asm
end function