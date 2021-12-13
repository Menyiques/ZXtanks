dim debug as ubyte
debug=0
dim tanks(10,5) as integer:' 0=tipo, 1=X, 2=Y, 3=dir, 4=speed, shoot counter
dim shoots(10,4)as integer:' 0=tipo, 1=X, 2=Y, 3=dir, 4=speed 
dim efecto(4,4) as ubyte: ' x,y,estado(04)
dim lives,level,newlevel as ubyte 
dim escx,escy as ubyte
dim etanks,nshoots,maxshoots,maxefectos,maxtanks as ubyte
dim points , maxscore as uinteger
dim lastkey as ubyte
dim p1, p2, p3, dx1,dx2,dy1,dy2,dx3,dy3, emptyp as byte
dim n as ubyte
dim ex,ey,eudg,tile as ubyte
dim startingposxy(8,1) as ubyte => {{3,3},{3,14},{3,27},{27,3},{27,14},{27,27},{11,15},{19,11},{19,19}}
dim tankspeed(3) as ubyte => {4,5,6,7}
dim appearing as ubyte
dim ku,kd,kl,kr,kf as ubyte
dim punt(4) as ubyte
dim keys as string
dim kempstonpresent as ubyte

if in(31)=255
	kempstonpresent=0
else
	kempstonpresent=1
end if

#include "tank_libraries.bas"
#include "tank_sound.bas"
#include "buffer.bas"
#include "chaos.bas"
ku=code("q"):kd=code("a"):kl=code("o"):kr=code("p"):kf=code(" ")
maxscore=0
maxtanks=4
maxefectos=4
pushMapa()

menu:

level=0
border 0
paper 0
ink 4
cls

pushpopmarquee(1)
bigstring("1:START"   ,11,10,4,6)
bigstring("2:REDEFINE",10,12,4,6)
keys=bigchr(kl)+bigchr(kr)+bigchr(ku)+bigchr(kd)+bigchr(kf)
bigstring(keys,12,14,4,6)
bigstring("HIGH:SCORE:"+format5(maxscore),8,18,7,7)
bigstring("[2021:MENYIQUES:SOFT",5,20,3,4)
bigstring("MUSIC:BY:MARC:ALEXANDER",4,22,7,4)


tileFast(14,6,@graficos+32*7,$40)

do 
chaos()
readkeyboard()
if lastkey=50
	bigstring(":::PRESS:LEFT::",7,12,4,6)
	readkeyboardwait():kl=lastkey
	bigstring(":::PRESS:RIGHT",7,12,4,6)
	readkeyboardwait():kr=lastkey
	bigstring(":::PRESS:UP:::",7,12,4,6)
	readkeyboardwait():ku=lastkey
	bigstring(":::PRESS:DOWN",7,12,4,6)
	readkeyboardwait():kd=lastkey
	bigstring(":::PRESS:FIRE",7,12,4,6)
	readkeyboardwait():kf=lastkey
	goto menu
end if
loop until lastkey=49 or (kempstonpresent=1 and kempston() bAND 16)>0
sound(3)
fadeout()
cls

start:

lives=3

points=0
nshoots=0
maxshoots=5
maxefectos=4
etanks=0
appearing=0

for n=0 to 10
	tanks(n,0)=0
next n

for n=0 to 4
	efecto(n,2)=0
next n 

popMapa()

nextlive:

for y=0 to 23
print at y,0;ink 5;"########################"
next y

for n=0 to maxshoots
	shoots(n,0)=0
next n

bigstring("BATTLE",25,0,4,6)
bigstring("CITY",26,2,4,6)

bigstring("LEVEL",26,10,3,6)
bigstring(str(level),28,12,3,6)

bigstring("SCORE",26,15,4,6)
bigstring(format5(points),26,17,4,6)
bigstring("LIVES",26,20,2,6)
bigstring(str(lives),28,22,2,6)

plot 206,153:draw 35,0:draw 0,-35:draw -35,0:draw 0,35
plot 204,155:draw 39,0:draw 0,-39:draw -39,0:draw 0,39
print at 5,26;paper 6;ink 0;"    "
print at 6,26;paper 6;ink 0;"    "
print at 7,26;paper 6;ink 0;"    "
print at 8,26;paper 6;ink 0;"    "


if debug=0 

	for xx=16 to 0 step -1
		poke $7c08,xx
		poke $7c09,xx
		pintaescenario(@mapa)
		pintabuffer()
	next xx
	tileFast(5,5,@graficos+32*8,$40)
	notes()
end if

randomize peek(23672)+peek(23673)*256

tanks(0,0)=1:'tipo (1=player, 2345=enemy)
tanks(0,1)=24:'x
tanks(0,2)=24:'y
tanks(0,3)=1:'dir
tanks(0,4)=8:'speed
tanks(0,5)=0:'Contador metralleta



MainLoop
if tanks(0,5)<100 
	tanks(0,5)=tanks(0,5)+1:'temporizador anti metralleta
end if

 if (etanks<level+1) and appearing=0 and int(rnd*100)>80 and etanks<maxtanks
	dim d as ubyte
	d=firstfreetank()

	if d<255
		tanks(d,0)=6:' el tipo se pondrá al aparecer
		newtankxy(d)
		tanks(d,3)=int(rnd*4):'dir
		'la velocidad se pone al aparecer el tanke
		dim e as ubyte
		e=firstfreeefect()
		if e=255 then e=0
		efecto(e,0)=tanks(d,1)
		efecto(e,1)=tanks(d,2)
		efecto(e,2)=11:'Apparition
		efecto(e,3)=d
		appearing=1
	end if
end if

for n=0 to maxtanks
	if tanks(n,0)>0 and tanks(n,0)<6
    	deletetile(tanks(n,1)/8,tanks(n,2)/8)
    	dim x,y as ubyte
		x=tanks(n,1)
		y=tanks(n,2)

		if n=0
			if lastkey=kr or (kempstonpresent=1 and kempston() bAND 1)>0
				'    ************  P
				tanks(0,3)=1
				x=tanks(0,1)+tanks(0,4)
				sound(4)
			else if lastkey=kl or (kempstonpresent=1 and kempston() bAND 2)>0 
				'    ************  O
				tanks(0,3)=3
				x=tanks(0,1)-tanks(0,4)
				sound(4)
			else if lastkey=kd or (kempstonpresent=1 and kempston() bAND 4)>0
				'    ************  Q
				tanks(0,3)=2
				y=tanks(0,2)+tanks(0,4)
				sound(4)
			else if lastkey=ku or (kempstonpresent=1 and kempston() bAND 8)>0
				'    ************  A
				tanks(0,3)=0
				y=tanks(0,2)-tanks(0,4)
				sound(4)
			else if (lastkey=kf  or (kempstonpresent=1 and kempston() bAND 16)>0) and tanks(0,5)>5
				'    ************  SPACE
				d=firstfreeshoot()
				
				if d<maxshoots
					shoots(d,0)=1:'tiro jugador'
					shoots(d,1)=tanks(0,1)
					shoots(d,2)=tanks(0,2)
					shoots(d,3)=tanks(0,3):'dir
					shoots(d,4)=8:'speed
					tanks(0,5)=0
					sound(2)
					nshoots=nshoots+1
				end if
			endif
			lastkey=255
		else
			if tanks(n,3)=0
				y=tanks(n,2)-tanks(n,4)
				x=tanks(n,1)
			else if	tanks(n,3)=1
				x=tanks(n,1)+tanks(n,4)
				y=tanks(n,2)
			else if	tanks(n,3)=2
				y=tanks(n,2)+tanks(n,4)
				x=tanks(n,1)
			else if	tanks(n,3)=3
				x=tanks(n,1)-tanks(n,4)
				y=tanks(n,2)
			end if
		end if

		emptyp1p2(x/8,y/8,tanks(n,3))
	
		if emptyp
			tanks(n,1)=x
			tanks(n,2)=y
		else	
			if n>0
				' es un tanque enemigo que ha chocado con algo
				if peek 23672 mod 15=1
					tanks(n,3)=rumbo(n)
				else
					tanks(n,3)=int(rnd*4)
				end if
			
			end if
		end if
		drawtile(tanks(n,1)/8,tanks(n,2)/8,n)
	end if	
next n

readkeyboard()


for n=1 to etanks
	if tanks(n,0)>0 and tanks(n,0)<6
			if peek 23672 mod 30=n*5
				tanks(n,3)=rumbo(n)
			end if
			dim rand as uinteger
			rand=int(rnd*1000)
			if rand>(980-level*10)
				d=firstfreeshoot()
				if d<maxshoots 
					shoots(d,0)=2:'tiro enemigo'
					shoots(d,1)=tanks(n,1)
					shoots(d,2)=tanks(n,2)
					shoots(d,3)=tanks(n,3):'dir
					shoots(d,4)=tanks(n,4)+2:'speed
					sound(0)
					nshoots=nshoots+1
				end if
			end if
	end if
next n

'********************* DESPL PANTALLA *************************'

if tanks(0,1)/8<9
	escx=0
else if tanks(0,1)/8>21
	escx=12
else 
	escx=tanks(0,1)/8-9
end if

if tanks(0,2)/8<9
	escy=0
else if tanks(0,2)/8>21
	escy=12
else 
	escy=tanks(0,2)/8-9
end if

'********************* SHOOTS *************************'

if nshoots>0
	for n=0 to maxshoots
		if shoots(n,0)>0
			if shoots(n,3)=0
				y=shoots(n,2)-shoots(n,4)
				x=shoots(n,1)
			else if	shoots(n,3)=1
				x=shoots(n,1)+shoots(n,4)
				y=shoots(n,2)
			else if	shoots(n,3)=2
				y=shoots(n,2)+shoots(n,4)
				x=shoots(n,1)
			else if	shoots(n,3)=3
				x=shoots(n,1)-shoots(n,4)
				y=shoots(n,2)
			end if
		
			emptyp1p2(x/8,y/8,shoots(n,3))

			if not emptyp
				if shoots(n,0)>0 and (not((shoots(n,0)=1 and p3=20) or (shoots(n,0)=2 and p3>20)))
					e=firstfreeefect
					if e<255
						efecto(e,0)=x+dx3
						efecto(e,1)=y+dy3
						efecto(e,2)=1						
					end if
		
					if p3=1 or p3=2
	    				pon(x/8+dx3,y/8+dy3,0)
	    			else if p3>8 and p3<13
	    				'aguila
	    				for zz=escy to 12
							poke $7c08,zz
							poke $7c09,escx
							escy=zz
							pintaescenario(@mapa)
							pintatanques()
							pintabuffer()
						next zz
						print at 17,17-escx;paper 6;ink 0;"  "
						print at 18,17-escx;paper 6;ink 0;"  "
						tileFast(17-escx,17,@graficos+960,$40)
						gameover(1)
						goto menu

	    			else if p3=20

	    				efecto(e,3)=99
	    				tanks(0,0)=0

						deletetile(tanks(0,1)/8,tanks(0,2)/8)	
						lives=lives-1
	    				if lives =255
	    					gameover(0)
	    					goto menu
	    				else
	    					bigstring(str(lives),28,22,2,6)
	    				end if

	    			else if p3>20
	    				' 15,16,17,18
	    				dim i as ubyte
	    				etanks=etanks-1
	    				i=p3-20
	    				points=points+(6-cast(uinteger,tanks(i,0)))*20
	    				
						bigstring(format5(points),26,17,4,6)

	    				tanks(i,0)=0
	    				dim ix,iy as ubyte
	    				ix=tanks(i,1)/8+208
	    				iy=152-tanks(i,2)/8
	    				deletetile(tanks(i,1)/8,tanks(i,2)/8)
	    				newlevel=points / 1000
	    				if points>maxscore 
	    					maxscore=points
	    				end if
	    				if newlevel>level
	    					level=newlevel
							
							for zz=0 to 6
								beep .08,zz*2
								if zz mod 2=0
									bigstring(str(level),28,12,3,6)
								else
									bigstring(":",28,12,3,6)
								end if
							next zz	
						end if
	    			end if
	
	    			if shoots(n,0)=1
	    				tanks(0,5)=6:'reset temporizador disparo
	    			end if
	    			shoots(n,0)=0: 'Desaparece el disparo'
	    			nshoots=nshoots - 1
	    		end if
	    	end if
	    	shoots(n,1)=x
			shoots(n,2)=y	
		end if
	next n
end if	
poke $7c08,escy: ' y
poke $7c09,escx: ' x
pintaescenario(@mapa)

deleteminimap()

pintatanques()

for n=1 to maxshoots
	if shoots(n-1,0)>0
		ex=shoots(n-1,1)/8-escx+2
		ey=shoots(n-1,2)/8-escy+2
		printUDG4(ex,ey,shoots(n-1,3),$e5)
	end if 
next n

for n=0 to 4
	if efecto(n,2)>0
		'explode
		if efecto(n,2)=1 or efecto(n,2)=3 
			tile=0
		else if efecto(n,2)=2 or efecto(n,2)=4
			tile=1
		else if efecto(n,2)=5 	 
			tile=2
		end if
		'appear
		if efecto(n,2)>=11 and efecto(n,2)<30
			if efecto(n,2) mod 2=0
				plot paper 6;ink 0;(efecto(n,0)/8)+208,150-(efecto(n,1)/8)
			end if
			tile=(efecto(n,2) mod 3) + 23
			beep .003,(efecto(n,2) mod 5)*10
		end if
	
		ex=efecto(n,0)/8-escx+2
		ey=efecto(n,1)/8-escy+2
		eudg=4+tile
		printUDG4(ex,ey,eudg,$e5)
	
		if efecto (n,2)=1
			sound(1)
		else if efecto (n,2)=29
			sound(3)
		end if

		efecto(n,2)=efecto(n,2)+1

		if efecto(n,3)=99
			sound(1)
		end if

		if efecto(n,2)=6 
			efecto(n,2)=0
			if efecto(n,3)=99
				efecto(n,3)=0
				fadeout()
				goto nextlive
			end if
		else if	efecto(n,2)=30
			efecto(n,2)=0
			tanks(efecto(n,3),0)=int(rnd*4)+2:'tipo 
			tanks(efecto(n,3),4)=tankspeed(tanks(efecto(n,3),0)-2)
			etanks=etanks+1
			appearing=0

		end if	
	
	end if
next n


'****************************************************'
pintabuffer()
readkeyboard()
'****************************************************'

goto MainLoop

9999 rem FIN








