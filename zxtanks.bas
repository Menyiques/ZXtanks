
border 2
cls
dim escx,escy as ubyte

dim tankf(4,2)as float: rem x,y,speed son float
dim tankdir(4)as ubyte: rem dirección (0 norte, 1 este, 2 sur, 3 oeste, 4 nada)
dim shootf(4,2)as float: rem x,y,speed
dim shootdir(4)={4,4,4,4,4}

dim n as ubyte

tank
tankf(0,0)=1
tankf(0,1)=1
tankf(0,2)=1

tankf(1,0)=21: rem x
tankf(1,1)=20: rem y
tankf(1,2)=0.4: rem speed
tankdir(1)=0: rem direccion

tankf(2,0)=21: rem x
tankf(2,1)=18: rem y
tankf(2,2)=0.8: rem speed
tankdir(2)=1: rem direccion

tankdir(3)=4: rem direccion
tankdir(4)=4: rem direccion
music2()
drawtile(tankf(0,0),tankf(0,1),2,0)


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


mainloop:

for n=0 to 4
if shootdir(n)<4
	drawtile(shootf(n,0),shootf(n,1),4,1)
	if shootdir(n)=0
		if empty(shootf(n,0),shootf(n,1)-shootf(n,2))
			shootf(n,1)=shootf(n,1)-shootf(n,2)
		else	
			drawtile(shootf(n,0),shootf(n,1),4,1)
			shootdir(n)=4
		end if
	else if	shootdir(n)=2
		if empty(shootf(n,0),shootf(n,1)+shootf(n,2))
			shootf(n,1)=shootf(n,1)+shootf(n,2)
		else	
			drawtile(shootf(n,0),shootf(n,1),4,1)
			shootdir(n)=4
		end if
	else if	shootdir(n)=1
		if empty(shootf(n,0)+shootf(n,2),shootf(n,1))
			shootf(n,0)=shootf(n,0)+shootf(n,2)
		else	
			drawtile(shootf(n,0),shootf(n,1),4,1)
			shootdir(n)=4	
		end if	
	else if	shootdir(n)=3
		if empty(shootf(n,0)-shootf(n,2),shootf(n,1))
			shootf(n,0)=shootf(n,0)-shootf(n,2)
		else	
			drawtile(shootf(n,0),shootf(n,1),4,1)
			shootdir(n)=4	
		end if	
	end if	
	drawtile(shootf(n,0),shootf(n,1),shootdir(n),2)
end if

next n

	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)


for n=1 to 4
if tankdir(n)<4
	drawtile(tankf(n,0),tankf(n,1),4,1)
	if tankdir(n)=0
		if empty(tankf(n,0),tankf(n,1)-tankf(n,2))
			tankf(n,1)=tankf(n,1)-tankf(n,2)
		else
			tankdir(n)=rnd*4
		end if
	else if	tankdir(n)=2
		if empty(tankf(n,0),tankf(n,1)+tankf(n,2))
			tankf(n,1)=tankf(n,1)+tankf(n,2)
		else
			tankdir(n)=rnd*4	
		end if
	else if	tankdir(n)=1
		if empty(tankf(n,0)+tankf(n,2),tankf(n,1))
			tankf(n,0)=tankf(n,0)+tankf(n,2)
		else
			tankdir(n)=rnd*4	
		end if	
	else if	tankdir(n)=3
		if empty(tankf(n,0)-tankf(n,2),tankf(n,1))
			tankf(n,0)=tankf(n,0)-tankf(n,2)
		else
			tankdir(n)=rnd*4	
		end if	
	end if	
	drawtile(tankf(n,0),tankf(n,1),tankdir(n),1)
end if
next n


if tankf(0,0)<9
	escx=0
else if tankf(0,0)>16
	escx=8
else 
	escx=tankf(0,0)-9
end if

if tankf(0,1)<9
	escy=0
else if tankf(0,1)>16
	escy=8
else 
	escy=tankf(0,1)-9
end if

poke $7c08,escy: rem y
poke $7c09,escx: rem x
a=peek(23672)

pintaescenario()
print at 0,0; peek(23672)-a;"  "

if inkey$="p" and tankf(0,0)<26 
	drawtile(tankf(0,0),tankf(0,1),4,0)
	if empty(tankf(0,0)+tankf(0,2),tankf(0,1))
		tankf(0,0)=tankf(0,0)+tankf(0,2)
	end if
	tankdir(0)=1
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

if inkey$="o" and tankf(0,0)>0 
	drawtile(tankf(0,0),tankf(0,1),4,0)
	if empty(tankf(0,0)-tankf(0,2),tankf(0,1))
		tankf(0,0)=tankf(0,0)-tankf(0,2)
	end if
	tankdir(0)=3
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if


if inkey$="a" and tankf(0,1)<26 
	drawtile(tankf(0,0),tankf(0,1),4,0)
	if empty(tankf(0,0),tankf(0,1)+tankf(0,2))
		tankf(0,1)=tankf(0,1)+tankf(0,2)
	end if
	tankdir(0)=2
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

if inkey$="q" and tankf(0,1)>0
	drawtile(tankf(0,0),tankf(0,1),4,0)
	if empty(tankf(0,0),tankf(0,1)-tankf(0,2))
		tankf(0,1)=tankf(0,1)-tankf(0,2)
	end if
	tankdir(0)=0
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

if inkey$=" " 
	shootdir(0)=tankdir(0)
	shootf(0,0)=tankf(0,0)
	shootf(0,1)=tankf(0,1)
	shootf(0,2)=1.5: rem bullet speed 
end if
goto mainloop


sub drawtile(x as ubyte, y as ubyte, dir as ubyte,tile as ubyte)

if dir=0
	poke @mapa+cast(uinteger,28)*(y)+x,10+(tile*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,11+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,12+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,13+(tile*16)
else if dir=1
	poke @mapa+cast(uinteger,28)*(y)+x,14+(tile*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,15+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,16+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,17+(tile*16)
else if dir=2
	poke @mapa+cast(uinteger,28)*(y)+x,18+(tile*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,19+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,20+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,21+(tile*16)
else if dir=3
	poke @mapa+cast(uinteger,28)*(y)+x,22+(tile*16)
	poke @mapa+cast(uinteger,28)*(y)+x+1,23+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x,24+(tile*16)
	poke @mapa+cast(uinteger,28)*(y+1)+x+1,25+(tile*16)
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

;arriba bala
defb 00110000b,0,0,0,0,0,0,0,1,00110000b,0,0,0,0,0,0,0,128
defb 00110000b,1,0,0,0,0,0,0,0,00110000b,128,0,0,0,0,0,0,0
;derecha bala
defb 00110000b,0,0,0,0,0,0,0,1,00110000b,0,0,0,0,0,0,0,128
defb 00110000b,1,0,0,0,0,0,0,0,00110000b,128,0,0,0,0,0,0,0
;abajo bala
defb 00110000b,0,0,0,0,0,0,0,1,00110000b,0,0,0,0,0,0,0,128
defb 00110000b,1,0,0,0,0,0,0,0,00110000b,128,0,0,0,0,0,0,0
;izquierda bala
defb 00110000b,0,0,0,0,0,0,0,1,00110000b,0,0,0,0,0,0,0,128
defb 00110000b,1,0,0,0,0,0,0,0,00110000b,128,0,0,0,0,0,0,0



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
