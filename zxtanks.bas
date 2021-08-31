
border 2
cls
dim escx,escy,tankx,tanky,tank2d as ubyte

dim tank2x,tank2y,tank2s as float

tankx=1
tanky=1

tank2x=21
tank2y=20
tank2d=0
tank2s=0.4
drawtank(tankx,tanky,2,0)


function libre(x as ubyte,y as ubyte) as ubyte
	dim librereturn,xx1,xx2,yy1,yy2 as ubyte
	librereturn = 0
	xx1=peek(@mapa+cast(uinteger,28)*y+x)
	xx2=peek(@mapa+cast(uinteger,28)*y+x+1)
	yy1=peek(@mapa+cast(uinteger,28)*(y+1)+x)
	yy2=peek(@mapa+cast(uinteger,28)*(y+1)+x+1)
	if xx1=0 and xx2=0 and yy1=0 and yy2=0
		librereturn=1
	end if 
	return librereturn
end function


hola:

drawtank(tank2x,tank2y,4,0)
if tank2d=0
	if libre(tank2x,tank2y-tank2s)
		tank2y=tank2y-tank2s
	else
		tank2d=rnd*4
	end if
else if	tank2d=2
	if libre(tank2x,tank2y+tank2s)
		tank2y=tank2y+tank2s
	else
		tank2d=rnd*4	
	end if
else if	tank2d=1
	if libre(tank2x+tank2s,tank2y)
		tank2x=tank2x+tank2s
	else
		tank2d=rnd*4	
	end if	
else if	tank2d=3
	if libre(tank2x-tank2s,tank2y)
		tank2x=tank2x-tank2s
	else
		tank2d=rnd*4	
	end if	
end if	
drawtank(tank2x,tank2y,tank2d,1)

if tankx<9
	escx=0
else if tankx>16
	escx=8
else 
	escx=tankx-9
end if

if tanky<9
	escy=0
else if tanky>16
	escy=8
else 
	escy=tanky-9
end if

poke $7c08,escy: rem y
poke $7c09,escx: rem x
a=peek(23672)

pintaescenario()
print at 0,0; peek(23672)-a;"  "

if inkey$="p" and tankx<26 
	drawtank(tankx,tanky,4,0)
	if libre(tankx+1,tanky)
		tankx=tankx+1
	end if
	drawtank(tankx,tanky,1,0)
end if

if inkey$="o" and tankx>0 
	drawtank(tankx,tanky,4,0)
	if libre(tankx-1,tanky)
		tankx=tankx-1
	end if
	drawtank(tankx,tanky,3,0)
end if


if inkey$="a" and tanky<26 
	drawtank(tankx,tanky,4,0)
	if libre(tankx,tanky+1)
		tanky=tanky+1
	end if
	drawtank(tankx,tanky,2,0)
end if

if inkey$="q" and tanky>0
	drawtank(tankx,tanky,4,0)
	if libre(tankx,tanky-1)
		tanky=tanky-1
	end if
	drawtank(tankx,tanky,0,0)
end if

goto hola


sub drawtank(x as ubyte, y as ubyte, dir as ubyte,tank as ubyte)

if dir=0
	poke @mapa+cast(uinteger,28)*(y)+x,10+(tank*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,11+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,12+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,13+(tank*16)
else if dir=1
	poke @mapa+cast(uinteger,28)*(y)+x,14+(tank*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,15+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,16+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,17+(tank*16)
else if dir=2
	poke @mapa+cast(uinteger,28)*(y)+x,18+(tank*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,19+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,20+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,21+(tank*16)
else if dir=3
	poke @mapa+cast(uinteger,28)*(y)+x,22+(tank*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,23+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,24+(tank*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,25+(tank*16)
else if dir=4
	poke @mapa+cast(uinteger,28)*(y)+x,0
	poke @mapa+cast(uinteger,28)*(y)+x+1,0
	poke @mapa+cast(uinteger,28)*(y+1)+x,0
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,0
end if

end sub

function fastcall pintaescenario()
poke uinteger $7c00,@mapa
poke uinteger $7c02,@udg
poke uinteger $7c04,@dfloc
poke uinteger $7c06,@attloc
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
	add a,$58
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
	add a,$40
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
defb 00110000b,0,0,0,0,32,0,0,0; 0
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

end asm
end function

function fastcall attloc()
asm
	ld a,b
	sra a
	sra a
	sra a
	add a,$58
	ld h,a
	ld a,b
	and 7
	rrca
	rrca
	rrca
	add a,c
	ld l,a
	push de
	ld de,40960
	add hl,de
	pop de
end asm
end function

function fastcall dfloc()
asm
	ld a,b
	and $f8
	add a,$40
	ld h,a
	ld a,b
	and 7
	rrca
	rrca
	rrca
	add a,c
	ld l,a
	push de
	ld de, 40960
	add hl,de
	pop de
end asm
end function
