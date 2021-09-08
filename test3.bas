#include "tank_libraries.bas"

a=peek(23672)

border 2
cls
dim escx,escy as ubyte

dim tankf(4,2)as float: rem x,y,speed son float
dim tankdir(4)as ubyte: rem dirección (0 norte, 1 este, 2 sur, 3 oeste, 4 nada)
dim shootf(4,2)as float: rem x,y,speed
dim shootdir(4)={4,4,4,4,4}

dim n as ubyte

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
rem music2()


drawtile(tankf(0,0),tankf(0,1),2,0)




mainloop:



REM gestiona disparos
REM shootf(,0)=x del disparo
REM shootf(,1)=y del disparo
REM shootf(,2)=speed del disparo


for n=0 to 4
rem 5 disparos máximo

if shootdir(n)<4
	rem 0=norte,1=este,2=sur,3=oeste,4=inactivo
	drawtile(shootf(n,0),shootf(n,1),4,1)
	rem borra el disparo
	
	if shootdir(n)=0
		if empty(shootf(n,0),shootf(n,1)-shootf(n,2))
			shootf(n,1)=shootf(n,1)-shootf(n,2)
			beep .01,0
		else	
			shootdir(n)=4
		end if
	else if	shootdir(n)=2
		if empty(shootf(n,0),shootf(n,1)+shootf(n,2))
			shootf(n,1)=shootf(n,1)+shootf(n,2)
			beep .01,0
		else	
			shootdir(n)=4
		end if
	else if	shootdir(n)=1
		if empty(shootf(n,0)+shootf(n,2),shootf(n,1))
			shootf(n,0)=shootf(n,0)+shootf(n,2)
			beep .01,0
		else	
			shootdir(n)=4	
		end if	
	else if	shootdir(n)=3
		if empty(shootf(n,0)-shootf(n,2),shootf(n,1))
			shootf(n,0)=shootf(n,0)-shootf(n,2)
			beep .01,0
		else	
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


REM Desplazamiento de pantalla
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

rem ***********************************************
poke $7c08,escy: rem y
poke $7c09,escx: rem x
pintaescenario()
pintabuffer()
print at 0,0; peek(23672)-a;"  "
a=peek(23672)
rem ***********************************************

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







