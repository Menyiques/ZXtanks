#include "tank_libraries.bas"

border 0
paper 0
cls
for x=0 to 23
for y=0 to 23
printudg(x,y,9)
next y
next x

'notes()
a=peek(23672)

dim escx,escy as ubyte

dim tankf(4,3)as float: ' x,y,speed son float
dim tankdir(4)as ubyte: ' dirección (0 norte, 1 este, 2 sur, 3 oeste, 4 nada)
dim shootf(10,3)as float: ' x,y,speed
dim shootdir(10)={4,4,4,4,4,4,4,4,4,4,4}
dim despx, despy as float
dim explosion(4,6): ' x,y,estado(04)
dim lastkey as ubyte


dim n as ubyte

tankf(0,0)=3
tankf(0,1)=3
tankf(0,2)=0.8
tankf(0,3)=0:'tanke jugador
tankdir(1)=4:tankdir(2)=4:tankdir(3)=4:tankdir(4)=4



mainloop:

for n=1 to 4

'disparos de los enenmigos*********************************************

if tankdir(n)<4 and rnd*50>48
		dim s as ubyte
		s=255
		do  :'busca el primer disparo libre
			s=s+1
		loop until shootdir(s)=4
	 
		if shootdir(s)=4 
			shootdir(s)=tankdir(n): ' direccion
			shootf(s,0)=tankf(n,0)
			shootf(s,1)=tankf(n,1)
			shootf(s,2)=1.0: ' bullet speed 
			beep .1,30
			n=4
		end if
	
end if

'Crea nuevos tanques**************************************************

if tankdir(n)=4 and rnd*100>90
	tankf(n,3)=int(rnd*4)+1
	tankf(n,2)=1-((4-tankf(n,3))*2/10)
	tankf(n,0)=21: ' x
	tankf(n,1)=14: ' y
	tankdir(n)=0: ' direccion
end if
	

next n
'*********************************************
' gestiona disparos
' shootf(,0)=x del disparo
' shootf(,1)=y del disparo
' shootf(,2)=speed del disparo
' shootf(,3)=(0,1) pintado
' shootdir()=dirección del disparo

for n=0 to 4
' 5 disparos máximo
readkeyboard()

if shootdir(n)<4
	' 0=norte,1=este,2=sur,3=oeste,4=inactivo

		'BORRA DISPAROS
		deletetile(shootf(n,0),shootf(n,1))

	if  shootdir(n)=0
		despy=-shootf(n,2)
		despx=0
	
	else if	shootdir(n)=1
		despx=shootf(n,2)
		despy=0
	
	else if	shootdir(n)=2
		despy=shootf(n,2)
		despx=0
	
	else if	shootdir(n)=3
		despx=-shootf(n,2)
		despy=0	
	end if

	shootf(n,0)=shootf(n,0)+despx
	shootf(n,1)=shootf(n,1)+despy

	' P1 | P2
	' -------
	' P3 | P4
	
	p1=quehay(shootf(n,0),shootf(n,1))
	p2=quehay(shootf(n,0)+1,shootf(n,1))
	p3=quehay(shootf(n,0),shootf(n,1)+1)
	p4=quehay(shootf(n,0)+1,shootf(n,1)+1)


	if shootdir(n)=0
		if p1=1
			p1=0 
			pon (shootf(n,0),shootf(n,1),0)
			shootdir(n)=4
		else if p2=1
			pon (shootf(n,0)+1,shootf(n,1),0)
			p2=0
			shootdir(n)=4
		else if solido(p2) or solido(p1)
			shootdir(n)=4	
		end if
	else if shootdir(n)=1	
		if p2=1 
			p2=0
			pon (shootf(n,0)+1,shootf(n,1),0)
			shootdir(n)=4
		else if p4=1
			p4=0
			pon (shootf(n,0)+1,shootf(n,1)+1,0)
			shootdir(n)=4
		else if solido(p4) or solido(p2)
			shootdir(n)=4	
		end if
	else if shootdir(n)=2
		if p3=1
			p3=0 
			pon (shootf(n,0),shootf(n,1)+1,0)
			shootdir(n)=4
		else if p4=1
			p4=0
			pon (shootf(n,0)+1,shootf(n,1)+1,0)
			shootdir(n)=4
		else if solido(p4) or solido(p3)
			shootdir(n)=4	
		end if
	else if shootdir(n)=3	
		if p1=1 
			p1=0
			pon (shootf(n,0),shootf(n,1),0)
			shootdir(n)=4		
		else if p3=1
			p3=0
			pon (shootf(n,0),shootf(n,1)+1,0)
			shootdir(n)=4
		else if solido(p1) or solido(p3)
			shootdir(n)=4
		end if
	end if

		
	if shootdir(n)<4
		drawtile(shootf(n,0),shootf(n,1),shootdir(n),6)

	else 
		' explosión
		explosion(0,0)=shootf(n,0)
		explosion(0,1)=shootf(n,1)
		explosion(0,2)=1


		if p1>31 or p2>31 or p3>31 or p4>31
			dim z as ubyte
			for z=1 to 4
				if abs(int(shootf(n,0))-int(tankf(z,0)))<=1 and abs(int(shootf(n,1))-int(tankf(z,1)))<=1
					tankdir(z)=4
					deletetile(tankf(z,0),tankf(z,1))

				end if 
			next z
		end if 



		if p1>10 then p1=0
		if p2>10 then p2=0
		if p3>10 then p3=0
		if p4>10 then p4=0
		
		explosion(0,3)=p1
		explosion(0,4)=p2
		explosion(0,5)=p3
		explosion(0,6)=p4
		beep .1,-20
	end if

end if

next n

REM gestiona explosiones ****************************************************
for n=0 to 4

readkeyboard()

if explosion(n,2)>0
	if explosion(n,2)=1 or explosion(n,2)=3 
		tile=0
	else if explosion(n,2)=2 or explosion(n,2)=4
		tile=1
	else 	 	 
		tile=2
	end if
	drawtile(explosion(n,0),explosion(n,1),tile,5)
	explosion(n,2)=explosion(n,2)+1
	if explosion(n,2)=6
		explosion(n,2)=0
		pon(explosion(n,0),explosion(n,1),explosion(n,3))
		pon(explosion(n,0)+1,explosion(n,1),explosion(n,4))
		pon(explosion(n,0),explosion(n,1)+1,explosion(n,5))
		pon(explosion(n,0)+1,explosion(n,1)+1,explosion(n,6))
	end if	
end if
next n

REM gestiona tankes **************************************************************

for n=1 to 4

readkeyboard()

if tankdir(n)<4

	deletetile(tankf(n,0),tankf(n,1))
	
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


	drawtile(tankf(n,0),tankf(n,1),tankdir(n),tankf(n,3))
end if
next n

readkeyboard()

' Desplazamiento de pantalla ************************************************************

if tankf(0,0)<9
	escx=0
else if tankf(0,0)>21
	escx=12
else 
	escx=tankf(0,0)-9
end if

if tankf(0,1)<9
	escy=0
else if tankf(0,1)>21
	escy=12
else 
	escy=tankf(0,1)-9
end if

readkeyboard()

drawtile(tankf(0,0),tankf(0,1),tankdir(0),0):' tile 0 es tanque propio

if lastkey=112
	deletetile(tankf(0,0),tankf(0,1))
	if empty(tankf(0,0)+tankf(0,2),tankf(0,1))
		tankf(0,0)=tankf(0,0)+tankf(0,2)
		beep .001,-20
	end if
	tankdir(0)=1
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

if lastkey=111
	deletetile(tankf(0,0),tankf(0,1))
	if empty(tankf(0,0)-tankf(0,2),tankf(0,1))
		tankf(0,0)=tankf(0,0)-tankf(0,2)
		beep .001,-20
	end if
	tankdir(0)=3
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if


if lastkey=97
	deletetile(tankf(0,0),tankf(0,1))
	if empty(tankf(0,0),tankf(0,1)+tankf(0,2))
		tankf(0,1)=tankf(0,1)+tankf(0,2)
		beep .001,-20
	end if
	tankdir(0)=2
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

if lastkey=113
	deletetile(tankf(0,0),tankf(0,1))
	if empty(tankf(0,0),tankf(0,1)-tankf(0,2))
		tankf(0,1)=tankf(0,1)-tankf(0,2)
		beep .001,-20
	end if
	tankdir(0)=0
	drawtile(tankf(0,0),tankf(0,1),tankdir(0),0)
end if

' sólo si no hay otro disparo en marcha y pulsa espacio

if lastkey=32 
	n=0
	do until n>4 
		if shootdir(n)=4 
			shootdir(n)=tankdir(0): ' direccion
			shootf(n,0)=tankf(0,0)
			shootf(n,1)=tankf(0,1)
			shootf(n,2)=1.0: ' bullet speed 
			beep .1,30
			n=4
		end if
	n=n+1	
	loop
end if




' ***********************************************
poke $7c08,escy: ' y
poke $7c09,escx: ' x
readkeyboard()
pintaescenario()
pintabuffer()
print at 0,0; ink 7; peek(23672)-a;"  "
a=peek(23672)
readkeyboard()
' ***********************************************

goto mainloop


sub drawtile(x as ubyte, y as ubyte, dir as ubyte,tile as ubyte)

if dir=0
	poke @mapa+cast(uinteger,32)*(y)+x,10+(tile*16)
	poke @mapa+cast(uinteger,32)*(y)+x+1,11+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x,12+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x+1,13+(tile*16)
else if dir=1
	poke @mapa+cast(uinteger,32)*(y)+x,14+(tile*16)
	poke @mapa+cast(uinteger,32)*(y)+x+1,15+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x,16+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x+1,17+(tile*16)
else if dir=2
	poke @mapa+cast(uinteger,32)*(y)+x,18+(tile*16)
	poke @mapa+cast(uinteger,32)*(y)+x+1,19+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x,20+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x+1,21+(tile*16)
else if dir=3
	poke @mapa+cast(uinteger,32)*(y)+x,22+(tile*16)
	poke @mapa+cast(uinteger,32)*(y)+x+1,23+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x,24+(tile*16)
	poke @mapa+cast(uinteger,32)*(y+1)+x+1,25+(tile*16)
end if

end sub

sub deletetile(x as ubyte, y as ubyte)
	poke @mapa+cast(uinteger,32)*(y)+x,0
	poke @mapa+cast(uinteger,32)*(y)+x+1,0
	poke @mapa+cast(uinteger,32)*(y+1)+x,0
	poke @mapa+cast(uinteger,32)*(y+1)+x+1,0
end sub

sub readkeyboard()
	lastkey=code(inkey$())
end sub

sub printudg(x as byte,y as byte,u as byte)
	addr=cast(uinteger,u)*9+@udg
	poke uinteger 23675,addr
	print at y,x;"\A"
	poke 22528+cast(uinteger,y)*32+x,peek(addr+8)
end sub




