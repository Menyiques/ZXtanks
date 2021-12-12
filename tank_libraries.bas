function kempston() as ubyte
	dim k as ubyte
	k=in 31
	if k>31
		k=0
	end if
	return k
end function

function format5(number as uinteger) as string
dim s as string
dim l as ubyte
	s="00000"+str(number)
	l=len(s)
	s=s(l-5)+s(l-4)+s(l-3)+s(l-2)+s(l-1)
	return s
end function

sub pause0()
	wait (100)
pause0l:
	if inkey$()="" then goto pause0l
	border 0
end sub



sub pintatanques()
for n=0 to 4

    if tanks(n,0)>0 and tanks(n,0)<6 
       	plot over 1;paper 6;ink 0;(tanks(n,1)/8)+208,150-(tanks(n,2)/8)
    	drawtile(tanks(n,1)/8,tanks(n,2)/8,n)
    	ex=tanks(n,1)/8-escx+2
		ey=tanks(n,2)/8-escy+2
		eudg=(tanks(n,0)-1)*4+tanks(n,3)+7
    	printUDG4(ex,ey,eudg,$e5)
    end if
next n
end sub


function bigchr(cod as ubyte) as string
	dim cchr as ubyte
	cchr=59
	if cod>47 and cod<58
		cchr=cod
	end if
	if cod>96
		cchr=cod-32
	end if
	return chr(cchr)
end function


function rumbo(t as ubyte) as ubyte
dim px, py, r as integer
dim obx,oby as integer

if t=2 or t=3 
	obx=15*8
	oby=31*8
else
	obx=tanks(0,1)
	oby=tanks(0,2)
end if
px=obx-tanks(t,1)
py=oby-tanks(t,2)
if px>=0 and py<0
	if abs(px)>=abs(py)
		r=1
	else
		r=0
	end if
else if px<=0 and py<0
	if abs(px)>=abs(py)
		r=3
	else
		r=0
	end if
else if px<=0 and py>0
	if abs(px)>=abs(py)
		r=3
	else
		r=2
	end if
else if px>=0 and py>0
	if abs(px)>=abs(py)
		r=1
	else
		r=2
	end If 
End If
return r
end function

function firstfreetank() as ubyte

	dim z as ubyte
	z=1
floop2:
	if tanks(z,0)=0
		return z
	end if
	z=z+1
	if z=maxtanks+1
		return 255
	end if
	goto floop2
	return 0
end function

function firstfreeshoot() as ubyte

	dim z as ubyte
	z=0
floop:
	if shoots(z,0)=0 
		return z
	end if
	z=z+1
	if z=maxshoots
		return 255
	end if
	goto floop
	return 0
end function

function firstfreeefect() as ubyte
	dim z as ubyte
	z=0
eloop:
	if efecto(z,2)=0 
		return z
	end if
	z=z+1
	if z=maxefectos
		return 255
	end if
	goto eloop
	return 0
end function

sub fastcall deleteminimap()
asm
ld hl,16570
call linea
ld hl,16570+32
call linea
ld hl,16570+64
call linea
ld hl,18458
call linea
ret

linea:
	xor a
	ld b,8
loopminim:
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a
	dec hl
	dec hl
	dec hl
	inc h
	djnz loopminim
ret
end asm
end sub

function quehay(x as ubyte, y as ubyte) as ubyte
	return peek(@mapa+cast(uinteger,32)*cast(uinteger,y)+cast(uinteger,x))
end function

sub pon(x as ubyte, y as ubyte, ch as ubyte)
	poke @mapa+cast(uinteger,32)*cast(uinteger,y)+cast(uinteger,x), ch
end sub

sub fastcall pushMapa()
	poke uinteger $7c00,@mapa
	poke uinteger $7c02,@mapa2
	asm
		ld hl,($7c00)
		ld de,($7c02)
		ld bc, 1024
		ldir
		ret
	end asm
end sub

sub fastcall popMapa()
	poke uinteger $7c00,@mapa
	poke uinteger $7c02,@mapa2
	asm
		ld hl,($7c02)
		ld de,($7c00)
		ld bc, 1024
		ldir
		ret
	end asm
end sub

sub drawtile(x as ubyte, y as ubyte, tankIndex as ubyte)
	dim addr, addr2, addrtile as uinteger
	addr=@mapa+cast(uinteger,32)*(y)+x
	addr2=@mapa+cast(uinteger,32)*(y+1)+x
	addrtile=tankIndex+20
	poke addr,addrtile
	poke addr+1,addrtile
	poke addr2,addrtile
	poke addr2+1,addrtile
end sub

sub deletetile(x as ubyte, y as ubyte)
	dim addr, addr1 as uinteger
	addr=@mapa+cast(uinteger,32)*(y)
	addr1=@mapa+cast(uinteger,32)*(y+1)
	poke addr+x,0
	poke addr+x+1,0
	poke addr1+x,0
	poke addr1+x+1,0
end sub

sub bigstring(s as string,x as ubyte,y as ubyte, attr1 as ubyte, attr2 as ubyte)
	for bgs=0 to len(s)-1
		bigchar(s(bgs),x+bgs,y,attr1,attr2)
	next bgs
end sub

sub gameover(reason as ubyte)
	sound(6)
	fadeout()
	cls
	if reason=0
		bigstring("YOU:HAVE:NO:MORE:TANKS",5,8,4,6)
	else
		bigstring("YOUR:BASE:WAS:DESTROYED",5,8,4,6)
	end if
	bigstring("THE:GAME:IS:OVER",8,10,4,6)
	pause0
	wait(10)
	cls
	bigstring("WELL:DONE",11,9,4,6)
	bigstring("YOU:SCORED:"+format5(points),7,11,4,6)
	bigstring("SURE:YOU:CAN:DO:IT:BETTER",3,13,4,6)
	pause0
end sub

sub readkeyboard()
	lastkey=code(inkey$())
end sub

sub readkeyboardwait()
	wait(10)
	do
	lastkey=code(inkey$())
	loop until (lastkey>96 and lastkey<123) or lastkey=32 or (lastkey>50 and lastkey<58) or lastkey=48
	sound(2)
end sub



sub printUDG4(ex as ubyte,ey as ubyte,eudg as uinteger,addr as ubyte)
	if ex<22 and ey<22 and ex>0 and ey>0 then tileFast(ex,ey,@graficos+eudg*32,addr)
end sub

sub wait(tstates as uinteger)
dim a,b as uinteger
a=peek 23672+peek 23673*256
do
	b=peek 23672+peek 23673*256
loop until (b-a>tstates)
end sub


sub emptyp1p2(x as ubyte,y as ubyte,dir as ubyte)
	p1p2(x,y,dir)
	if p1=0 and p2=0
		emptyp= 1
	else 
		emptyp= 0
	end if
end sub

sub newtankxy(d as ubyte)
	dim ok as ubyte=0
	do
		dim r as ubyte =int(rnd*9)
		if quehay(startingposxy(r,0),startingposxy(r,1))=0
			tanks(d,1)=startingposxy(r,0)*8
			tanks(d,2)=startingposxy(r,1)*8
			ok=1
		end if
	loop until ok=1
end sub


sub p1p2(x as ubyte, y as ubyte, dir as ubyte)

	if dir=0
		p1=quehay(x,y):dx1=0:dy1=0
		p2=quehay(x+1,y):dx2=1:dy2=0
	else if dir=2
		p1=quehay(x,y+1):dx1=0:dy1=1
		p2=quehay(x+1,y+1):dx2=1:dy2=1
	else if dir=1
		p1=quehay(x+1,y):dx1=1:dy1=0
		p2=quehay(x+1,y+1):dx2=1:dy2=1
	else if dir=3
		p1=quehay(x,y):dx1=0:dy1=0
		p2=quehay(x,y+1):dx2=0:dy2=1	
	end if
	
	if (p1>p2) 
		p3=p1:dx3=dx1:dy3=dy1
	else
		p3=p2:dx3=dx2:dy3=dy2
	end if

end sub





sub bigchar(s as string,x as ubyte,y as ubyte,attr1 as ubyte, attr2 as ubyte)
	poke 22528+cast(uinteger,y)*32+x,attr1
	poke 22528+(cast(uinteger,y)+1)*32+x,attr2

	dim c as uinteger
	c=code(s)
	if c>=48 and c<60
		c=c-48
	else 
		c=c-53
	end if
	poke uinteger $7c08, @fonts+(c*16)
	poke $7c0a,x
	poke $7c0b,y
	asm
		ld de,($7c08)
		ld a,($7c0a)
		ld c,a
		ld a,($7c0b)
		ld b,a
		call dflocb
		push bc
		ld b,8
	loopf:
		ld a,(de)
		ld (hl),a
		inc de
		inc h
		djnz loopf
		pop bc
		inc b
		call dflocb
		ld b,8
	loopf2:
		ld a,(de)
		ld (hl),a
		inc de
		inc h
		djnz loopf2
		jr finbb
	dflocb:
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
		ret
	finbb:
	end asm 
end sub


sub tileFast(x as ubyte, y as ubyte, addr as uinteger,mem as ubyte)
poke $7c08,y
poke $7c09,x
poke uinteger $7c0a,addr
poke $7c0c,mem
asm
	ld hl,$7c08
	ld b,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	push bc
	call dfloct
	ld b,8

loopt:
	ld a,(de)
	or (hl)
	ld (hl),a
	inc hl
	inc de
	
	ld a,(de)
	or (hl)
	ld (hl),a
	dec hl
	inc h
	inc de
	djnz loopt
	pop bc
	inc b
	call dfloct
	ld b,8
loop2t:
	ld a,(de)
	or (hl)
	ld (hl),a
	inc hl
	inc de
	ld a,(de)
	or (hl)
	ld (hl),a
	dec hl
	inc h
	inc de
	djnz loop2t
	jp fint
dfloct:
	ld a,b
	and $f8
	ld hl,$7c0c
	add a,(hl);$e5
	ld h,a
	ld a,b
	and 7
	rrca
	rrca
	rrca
	add a,c
	ld l,a
	ret
fint:
end asm
end sub

sub  pintaescenario(addr as uinteger)
poke uinteger $7c00,addr
poke uinteger $7c02,@udg
'poke $7c08,y
'poke $7c09,x

asm
di
push ix 
push iy
ld ixh, 0; Y = ixh = filas
ld ixl,0 ; X = ixl = colum

;iy tiene la addr del mapa

ld iy,($7c00)

ld bc,32

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

cp 18
jr c, nobigger
ld a,0
nobigger:

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
;de=addr udg
;hl=addr pantalla
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
add a,$fd;58 
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
add a,$e5;40 
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
end sub


sub fastcall mapa()
asm
defb 5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6
defb 7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8
defb 5,6,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,2,1,0,0,2,1,0,0,2,1,4,4,2,1,0,0,2,1,0,0,2,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,1,1,4,4,1,1,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,5,6
defb 7,8,3,0,0,2,1,0,0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0,0,2,1,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,4,4,0,0,4,4,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,2,1,0,0,2,1,2,1,0,0,0,0,0,0,0,0,0,0,2,1,2,1,0,0,2,1,3,5,6
defb 7,8,3,4,4,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,4,4,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,2,1,0,0,2,1,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,1,1,2,1,1,1,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,2,1,0,0,2,1,0,0,2,1,1,1,2,1,0,0,2,1,0,0,2,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,2,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,2,1,0,0,2,1,0,0,0,0,0,0,0,0,0,0,2,1,0,0,2,1,0,0,3,5,6
defb 7,8,3,0,0,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,1,1,0,0,3,7,8
defb 5,6,3,0,0,1,1,0,0,1,1,0,0,0,1,1,1,1,0,0,0,2,1,0,0,2,1,0,0,3,5,6
defb 7,8,3,0,0,0,0,0,0,0,0,0,0,0,1,9,10,1,0,0,0,0,0,0,0,0,0,0,0,3,7,8
defb 5,6,3,0,0,0,0,0,0,0,0,0,0,0,1,11,12,1,0,0,0,0,0,0,0,0,0,0,0,3,5,6
defb 7,8,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,7,8
defb 5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6,5,6
defb 7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8
end asm
end sub


sub fastcall mapa2()
asm
defb 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3
defb 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
end asm
end sub

sub fastcall udg()
asm
defb 0,0,0,0,0,0,0,0,00110000b; (0)=suelo
defb 16,85,178,255,1,85,43,255,00010000b; (1)=ladrillo brillo 0
defb 16,85,178,255,1,85,43,255,01010000b; (2)=ladrillo brillo 1
defb 00000001b,01000101b,00000001b,00000001b,00000001b,01000101b,00000001b,11111111b,00111000b; (3)=borde ext
defb 1,43,87,43,87,43,127,255,00101000b; (4)=duro interior
defb 10001100b,00000111b,00011000b,00100000b,01000000b,11000000b,01100000b,01010000b,01100000b;(5)=arbol 1
defb 00001000b,10001000b,11110000b,01110000b,00101101b,00110110b,00101000b,00101100b,00100000b;(6)=arbol 2
defb 00101010b,00011111b,00000111b,00000110b,00001011b,01110000b,10001100b,00001000b,00100000b;(7)=arbol 3
defb 01101000b,11001100b,10001010b,00000101b,11100011b,00010000b,00001001b,00001010b,00100000b;(8)=arbol 4
defb 128,97,19,235,27,127,15,63,00110000b; (9)=aguila1
defb 3,12,208,174,176,252,224,252,00110000b; (10)=aguila 2
defb 15,31,31,59,195,69,10,0,00110000b; (11)=aguila 3
defb 224,240,240,184,134,68,160,0,00110000b; (12)=aguila 4
defb 130,68,40,16,40,68,130,1,00000101b; (13)=
defb 0,0,0,0,0,0,0,0,0
defb 0,0,0,0,0,0,0,0,0
end asm
end sub


sub fastcall fonts
asm 
defb 0,0,60,102,195,195,195,219,219,195,195,195,102,60,0,0; 0
defb 0,0,24,56,120,24,24,24,24,24,24,24,24,126,0,0
defb 0,0,126,195,3,6,12,24,48,96,192,192,195,255,0,0
defb 0,0,126,195,3,3,14,3,3,3,3,3,195,126,0,0
defb 0,0,6,14,30,54,102,198,255,6,6,6,6,15,0,0
defb 0,0,255,192,192,192,192,254,3,3,3,3,195,126,0,0
defb 0,0,56,96,192,192,254,195,195,195,195,195,195,126,0,0
defb 0,0,255,195,3,3,3,6,12,24,48,48,48,48,0,0
defb 0,0,126,195,195,195,195,126,195,195,195,195,195,126,0,0
defb 0,0,126,195,195,195,195,127,3,3,3,3,6,124,0,0
defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0; SPACE
defb 0,0,62,65,0,54,69,37,22,20,100,1,65,62,0,0

defb 0,0,16,56,108,198,198,198,254,198,198,198,198,198,0,0; A
defb 0,0,252,102,102,102,100,126,102,102,102,102,102,252,0,0
defb 0,0,60,102,194,192,192,192,192,192,192,194,102,60,0,0
defb 0,0,248,108,102,102,102,102,102,102,102,102,108,252,0,0
defb 0,0,254,102,98,96,104,120,104,96,96,98,102,254,0,0
defb 0,0,254,102,98,96,104,120,104,96,96,96,96,240,0,0
defb 0,0,60,102,194,192,192,192,222,198,198,198,102,58,0,0
defb 0,0,198,198,198,198,198,254,198,198,198,198,198,198,0,0
defb 0,0,60,24,24,24,24,24,24,24,24,24,24,60,0,0
defb 0,0,30,12,12,12,12,12,12,12,204,204,204,120,0,0
defb 0,0,230,102,102,102,108,120,120,108,102,102,102,230,0,0
defb 0,0,240,96,96,96,96,96,96,96,96,98,102,254,0,0
defb 0,0,195,231,255,255,219,195,195,195,195,195,195,195,0,0
defb 0,0,195,227,243,251,223,207,199,195,195,195,195,195,0,0
defb 0,0,60,102,195,195,195,195,195,195,195,195,102,60,0,0
defb 0,0,252,102,102,102,102,124,96,96,96,96,96,240,0,0
defb 0,0,60,102,195,195,195,195,195,195,195,203,110,62,6,7
defb 0,0,252,102,102,102,100,124,110,102,102,102,102,230,0,0
defb 0,0,124,198,198,96,56,12,6,6,6,198,198,124,0,0
defb 0,0,255,219,153,24,24,24,24,24,24,24,24,60,0,0
defb 0,0,195,195,195,195,195,195,195,195,195,195,195,126,0,0
defb 0,0,195,195,195,195,195,195,195,195,231,126,60,24,0,0
defb 0,0,195,195,195,195,195,195,195,219,219,255,102,102,0,0
defb 0,0,195,195,231,126,60,24,24,60,126,231,195,195,0,0
defb 0,0,195,195,195,231,126,60,24,24,24,24,24,60,0,0
defb 0,0,255,195,134,12,24,48,96,192,128,129,131,255,0,0; Z
defb 0,0,60,102,195,219,211,211,211,211,219,195,102,60,0,0; (C)
end asm
end sub



sub fastcall graficos
asm
;disparos
defb   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,128,  1,128
defb   1,128,  1,128,  1,128,  0,  0,  1,128,  0,  0,  0,  0,  1,128

defb   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,151,192
defb 151,192,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

defb   1,128,  0,  0,  0,  0,  1,128,  0,  0,  1,128,  1,128,  1,128
defb   1,128,  1,128,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

defb   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  3,233
defb   3,233,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0

;explosiones
defb  12,  4, 97,240,142, 72, 16,  4, 32,130, 64,  6, 98,  4, 96,  6
defb 118,146, 48, 18, 56, 58,189,125,159,184, 31,240, 35, 68, 16, 24

defb   0,  2, 24, 13,  8,201,227,181,164,138, 72, 72,  8, 24,  8,  8
defb  12, 80, 15, 48,  6,160, 27,216, 44, 36, 68, 36, 68, 56, 56,  0

defb   0,  0,  0,  0,  1,  0,  2, 48,  0, 48,  1,192, 50,100, 52, 32
defb   6, 32, 11, 64,  1,216, 24, 48, 28, 48,  8,128,  0,  0,  0,  0

;tank player

defb 1,128,1,128,1,128,57,156,79,242,125,190,90,90,117,174,86,106,119,238,91,218,123,222,92,58,127,254,79,242,61,188
defb 0,0,127,240,170,168,191,232,252,120,243,176,111,80,238,191,238,191,111,80,243,176,252,120,191,232,170,168,127,240,0,0
defb 61,188,79,242,127,254,92,58,123,222,91,218,119,238,86,106,117,174,90,90,125,190,79,242,57,156,1,128,1,128,1,128
defb 0,0,15,254,21,85,23,253,30,63,13,207,10,246,253,119,253,119,10,246,13,207,30,63,23,253,21,85,15,254,0,0

defb 3,192,49,140,73,146,121,158,79,242,125,190,90,90,119,238,87,234,119,238,87,234,119,238,87,234,120,30,79,242,61,188
defb 0,0,127,252,170,170,191,234,224,124,223,176,95,209,223,191,223,191,95,209,223,176,224,124,191,234,170,170,127,252,0,0
defb 61,188,79,242,120,30,87,234,119,238,87,234,119,238,87,234,119,238,90,90,125,190,79,242,121,158,73,146,49,140,3,192
defb 0,0,63,254,85,85,87,253,62,7,13,251,139,250,253,251,253,251,139,250,13,251,62,7,87,253,85,85,63,254,0,0


defb 1,128,1,128,1,128,49,156,79,242,125,190,90,90,119,238,87,234,119,238,91,218,123,222,93,186,126,126,79,242,61,188
defb 0,0,127,240,170,168,191,232,252,112,243,176,111,208,223,191,223,191,111,208,243,176,252,120,191,232,170,168,127,240,0,0
defb 61,188,79,242,126,126,93,186,123,222,91,218,119,238,87,234,119,238,90,90,125,190,79,242,57,140,1,128,1,128,1,128
defb 0,0,15,254,21,85,23,253,30,63,13,207,11,246,253,251,253,251,11,246,13,207,14,63,23,253,21,85,15,254,0,0


defb 1,128,1,128,1,128,49,140,79,242,125,190,90,90,119,238,87,234,119,238,91,218,124,62,95,250,59,220,0,0,0,0
defb 0,0,31,240,42,168,63,232,60,112,27,176,55,208,55,191,55,191,55,208,27,176,60,112,63,232,42,168,31,240,0,0
defb 0,0,0,0,59,220,95,250,124,62,91,218,119,238,87,234,119,238,90,90,125,190,79,242,49,140,1,128,1,128,1,128
defb 0,0,15,248,21,84,23,252,14,60,13,216,11,236,253,236,253,236,11,236,13,216,14,60,23,252,21,84,15,248,0,0

defb 0,0,1,128,1,128,1,128,29,184,63,252,42,84,59,220,43,212,59,220,45,180,62,124,47,244,27,216,0,0,0,0
defb 0,0,0,0,31,224,42,176,63,240,28,48,59,224,55,190,55,190,59,224,28,48,63,240,42,176,31,224,0,0,0,0
defb 0,0,0,0,27,216,47,244,62,124,45,180,59,220,43,212,59,220,42,84,63,252,29,184,1,128,1,128,1,128,0,0
defb 0,0,0,0,7,248,13,84,15,252,12,56,7,220,125,236,125,236,7,220,12,56,15,252,13,84,7,248,0,0,0,0
;appear1
;defb 1,0,1,0,1,0,1,0,1,0,1,0,1,128,3,255,255,192,1,128,0,128,0,128,0,128,0,128,0,128,0,128
;appear2
;defb 1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,249,159,128,0,128,0,128,0,128,0,128,0,0,0,0,0,128
;appear3
;defb 0,0,0,0,0,0,0,0,1,0,1,0,1,0,1,240,15,128,0,128,0,128,0,128,0,0,0,0,0,0,0,128
;aguila rota
defb $00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$05,$a0,$03,$c0,$7f,$e0,$07,$fe,$03,$c0,$05,$a0,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00
defb $00,$00,$00,$00,$20,$04,$10,$08,$08,$90,$04,$a0,$03,$c0,$0f,$c0,$03,$f0,$03,$c0,$05,$20,$09,$10,$10,$08,$20,$04,$00,$00,$00,$00
defb $00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$01,$00,$01,$00,$01,$e8,$17,$80,$00,$80,$00,$80,$00,$00,$00,$80,$00,$00,$00,$00,$00,$00
defb 0,8,0,28,0,60,3,110,7,198,27,130,127,224,205,224,191,248,175,224,127,176,159,240,63,184,203,134,85,68,10,160

end asm
end sub 


sub fastcall fadeout()
asm

	ld a,71
mloop:
	ld hl,22528
	ld b,24
rows:
	push bc
	ld b,32
srow:
	ld (hl),a
	inc hl
	djnz srow
	pop bc
	djnz rows
	halt
	halt	
	halt
	halt
	dec a
	cp 63
	jr z, endz
	jr mloop
endz:
end asm
end sub


