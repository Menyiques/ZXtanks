sub fastcall notes()
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
end sub


sub fastcall sound(a as ubyte)
asm

  
  ld hl,sfxData0
  cp 0 
  jr z, play
  ld hl,sfxData1
  cp 1
  jr z, play
  ld hl,sfxData2
  cp 2
  jr z, play
  ld hl,sfxData3
  cp 3
  jr z, play
  ld hl,sfxData4
  cp 4
  jr z, play
  ld hl,sfxData5
  cp 5
  jr z, play
  ld hl,sfxData6

play:
  ld a,0
  di
  push ix
  push iy

  ld b,0
  ld c,a
  add hl,bc
  add hl,bc
  ld e,(hl)
  inc hl
  ld d,(hl)
  push de
  pop ix      ;put it into ix

  ld a,(23624)  ;get border color from BASIC vars to keep it unchanged
  rra
  rra
  rra
  and 7
  ld (sfxRoutineToneBorder  +1),a
  ld (sfxRoutineNoiseBorder +1),a
  ld (sfxRoutineSampleBorder+1),a


readData:
  ld a,(ix+0)   ;read block type
  ld c,(ix+1)   ;read duration 1
  ld b,(ix+2)
  ld e,(ix+3)   ;read duration 2
  ld d,(ix+4)
  push de
  pop iy

  dec a
  jr z,sfxRoutineTone
  dec a
  jr z,sfxRoutineNoise
  dec a
  jr z,sfxRoutineSample
  pop iy
  pop ix
  ei
  ret

  

;play sample

sfxRoutineSample:
  ex de,hl
sfxRS0:
  ld e,8
  ld d,(hl)
  inc hl
sfxRS1:
  ld a,(ix+5)
sfxRS2:
  dec a
  jr nz,sfxRS2
  rl d
  sbc a,a
  and 16
sfxRoutineSampleBorder:
  or 0
  out (254),a
  dec e
  jr nz,sfxRS1
  dec bc
  ld a,b
  or c
  jr nz,sfxRS0

  ld c,6
  
nextData:
  add ix,bc   ;skip to the next block
  jr readData



;generate tone with many parameters

sfxRoutineTone:
  ld e,(ix+5)   ;freq
  ld d,(ix+6)
  ld a,(ix+9)   ;duty
  ld (sfxRoutineToneDuty+1),a
  ld hl,0

sfxRT0:
  push bc
  push iy
  pop bc
sfxRT1:
  add hl,de
  ld a,h
sfxRoutineToneDuty:
  cp 0
  sbc a,a
  and 16
sfxRoutineToneBorder:
  or 0
  out (254),a

  dec bc
  ld a,b
  or c
  jr nz,sfxRT1

  ld a,(sfxRoutineToneDuty+1)  ;duty change
  add a,(ix+10)
  ld (sfxRoutineToneDuty+1),a

  ld c,(ix+7)   ;slide
  ld b,(ix+8)
  ex de,hl
  add hl,bc
  ex de,hl

  pop bc
  dec bc
  ld a,b
  or c
  jr nz,sfxRT0

  ld c,11
  jr nextData



;generate noise with two parameters

sfxRoutineNoise:
  ld e,(ix+5)   ;pitch

  ld d,1
  ld h,d
  ld l,d
sfxRN0:
  push bc
  push iy
  pop bc
sfxRN1:
  ld a,(hl)
  and 16
sfxRoutineNoiseBorder:
  or 0
  out (254),a
  dec d
  jr nz,sfxRN2
  ld d,e
  inc hl
  ld a,h
  and 31
  ld h,a
sfxRN2:
  dec bc
  ld a,b
  or c
  jr nz,sfxRN1

  ld a,e
  add a,(ix+6)  ;slide
  ld e,a

  pop bc
  dec bc
  ld a,b
  or c
  jr nz,sfxRN0

  ld c,7
  jr nextData

sfxData0:
;DISPARO ENEMIGO ******************
SoundEffectsData0:
  defw SoundEffect0Data0
SoundEffect0Data0:
  defb 1 ;tone 
  defw 5,1000,11,64,128
  defb 0

sfxData1:
;EXPLOSION ******************
SoundEffectsData1:
  defw SoundEffect0Data1
SoundEffect0Data1:
  defb 2 ;noise
  defw 5,1000,23
  defb 0

sfxData2:
;SHOOT PLAYER ******************
SoundEffectsData2:
  defw SoundEffect0Data2
SoundEffect0Data2:
  defb 2 ;noise
  defw 5,1000,1054
  defb 0

sfxData3:
;NEW ENEMY ******************
SoundEffectsData3:
  defw SoundEffect0Data3
SoundEffect0Data3:
  defb 1 ;tone
  defw 5,1000,123,32,194
  defb 0

sfxData4:
;PLAYER MOVE ******************
SoundEffectsData4:
  defw SoundEffect0Data4
SoundEffect0Data4:
  defb 2 ;noise
  defw 10,10,100
  defb 0

sfxData5:
;EXPLOSION ******************
SoundEffectsData5:
  defw SoundEffect0Data5
SoundEffect0Data5:
  defb 2 ;noise
  defw 5,2000,23
  defb 0

sfxData6:
SoundEffectsData6:
  defw SoundEffect0Data6
SoundEffect0Data6:
  defb 2 ;noise
  defw 130,1000,765
  defb 0


end asm
end sub
