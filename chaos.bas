
sub fastcall chaos()
asm
; *****************************************************************************
; * The Music Box Player Engine
; *
; * Based on code written by Mark Alexander for the utility, The Music Box.
; * Modified by Chris Cowley
; *
; * Produced by Beepola v1.08.01
; ******************************************************************************
 
STARTC:
                          LD    HL,MUSICDATAC         ;  <- Pointer to Music Data. Change
                                                     ;     this to play a different song
                          LD   A,(HL)                         ; Get the loop start pointer
                          LD   (PATTERN_LOOP_BEGINC),A
                          INC  HL
                          LD   A,(HL)                         ; Get the song end pointer
                          LD   (PATTERN_LOOP_ENDC),A
                          INC  HL
                          LD   (PATTERNDATAC1C),HL
                          LD   (PATTERNDATAC2C),HL
                          LD   A,254
                          LD   (PATTERN_PTRC),A                ; Set the pattern pointer to zero
                          DI
                          CALL  NEXT_PATTERNC
NEXTNOTEC:
                          CALL  PLAYNOTEC
                          XOR   A
                          IN    A,($FE)
                          AND   $1F
                          CP    $1F
                          JR    Z,NEXTNOTEC                   ; Play next note if no key pressed

                          EI
                          RET                                 ; Return from playing tune

PATTERN_PTRC:              DEFB 0
NOTE_PTRC:                 DEFB 0


; ********************************************************************************************************
; * NEXT_PATTERNC
; *
; * Select the next pattern in sequence (and handle looping if we've reached PATTERN_LOOP_ENDC
; * Execution falls through to PLAYNOTEC to play the first note from our next pattern
; ********************************************************************************************************
NEXT_PATTERNC:
                          LD   A,(PATTERN_PTRC)
                          INC  A
                          INC  A
                          DEFB $FE                           ; CP n
PATTERN_LOOP_ENDC:         DEFB 0
                          JR   NZ,NO_PATTERN_LOOPC
                          DEFB $3E                           ; LD A,n
PATTERN_LOOP_BEGINC:       DEFB 0
NO_PATTERN_LOOPC:          LD   (PATTERN_PTRC),A
			                    DEFB $21                            ; LD HL,nn
PATTERNDATAC1C:             DEFW $0000
                          LD   E,A                            ; (this is the first byte of the pattern)
                          LD   D,0                            ; and store it at TEMPOC
                          ADD  HL,DE
                          LD   E,(HL)
                          INC  HL
                          LD   D,(HL)
                          LD   A,(DE)                         ; Pattern TEMPOC -> A
	                	      LD   (TEMPOC),A                      ; Store it at TEMPOC

                          LD   A,1
                          LD   (NOTE_PTRC),A

PLAYNOTEC: 
			                    DEFB $21                            ; LD HL,nn
PATTERNDATAC2C:             DEFW $0000
                          LD   A,(PATTERN_PTRC)
                          LD   E,A
                          LD   D,0
                          ADD  HL,DE
                          LD   E,(HL)
                          INC  HL
                          LD   D,(HL)                         ; Now DE = Start of Pattern data
                          LD   A,(NOTE_PTRC)
                          LD   L,A
                          LD   H,0
                          ADD  HL,DE                          ; Now HL = address of note data
                          LD   D,(HL)
                          LD   E,1

; IF D = $0 then we are at the end of the pattern so increment PATTERN_PTR by 2 and set NOTE_PTRC=0
                          LD   A,D
                          AND  A                              ; Optimised CP 0
                          JR   Z,NEXT_PATTERNC

                          PUSH DE
                          INC  HL
                          LD   D,(HL)
                          LD   E,1

                          LD   A,(NOTE_PTRC)
                          INC  A
                          INC  A
                          LD   (NOTE_PTRC),A                   ; Increment the note pointer by 2 (one note per chan)

                          POP  HL                             ; Now CH1 freq is in HL, and CH2 freq is in DE

                          LD   A,H
                          DEC  A
                          JR   NZ,OUTPUT_NOTEC

                          LD   A,D                            ; executed only if Channel 2 contains a rest
                          DEC  A                              ; if DE (CH1 note) is also a rest then..
                          JR   Z,PLAY_SILENCEC                 ; Play silence

OUTPUT_NOTEC:              LD   A,(TEMPOC)
                          LD   C,A
                          LD   B,0
                          LD   A,0
                          EX   AF,AF'
                          LD   A,0                 ; So now BC = TEMPOC, A and A' = BORDER_COL
                          LD   IXH,D
                          LD   D,$10
EAE5C:                     NOP
                          NOP
EAE7C:                     EX   AF,AF'
                          DEC  E
                          OUT  ($FE),A
                          JR   NZ,EB04C

                          LD   E,IXH
                          XOR  D
                          EX   AF,AF'
                          DEC  L
                          JP   NZ,EB0BC

EAF5C:                     OUT  ($FE),A
                          LD   L,H
                          XOR  D
                          DJNZ EAE5C

                          INC  C
                          JP   NZ,EAE7C

                          RET

EB04C:
                          JR   Z,EB04C
                          EX   AF,AF'
                          DEC  L
                          JP   Z,EAF5C
EB0BC:
                          OUT  ($FE),A
                          NOP
                          NOP
                          DJNZ EAE5C
                          INC  C
                          JP   NZ,EAE7C
                          RET

PLAY_SILENCEC:
                          LD   A,(TEMPOC)
                          CPL
                          LD   C,A
SILENCE_LOOPC2C:            PUSH BC
                          PUSH AF
                          LD   B,0
SILENCE_LOOPC:             PUSH HL
                          LD   HL,0000
                          SRA  (HL)
                          SRA  (HL)
                          SRA  (HL)
                          NOP
                          POP  HL
                          DJNZ SILENCE_LOOPC
                          DEC  C
                          JP   NZ,SILENCE_LOOPC
                          POP  AF
                          POP  BC
                          RET


; *** DATA ***
TEMPOC:                    DEFB 250

MUSICDATAC:
                    DEFB 8   ; Loop start point * 2
                    DEFB 40   ; Song Length * 2
PATTERNDATAC:       DEFW      PAT0C
                    DEFW      PAT0C
                    DEFW      PAT1
                    DEFW      PAT2
                    DEFW      PAT3
                    DEFW      PAT12
                    DEFW      PAT4
                    DEFW      PAT5
                    DEFW      PAT6
                    DEFW      PAT13
                    DEFW      PAT7
                    DEFW      PAT8
                    DEFW      PAT9
                    DEFW      PAT14
                    DEFW      PAT10
                    DEFW      PAT11
                    DEFW      PAT15
                    DEFW      PAT15
                    DEFW      PAT16
                    DEFW      PAT17

; *** Pattern data consists of pairs of frequency values CH1,CH2 with a single $0 to
; *** Mark the end of the pattern, and $01 for a rest
PAT0C:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 76,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 102,1
             DEFB 180,1
             DEFB 102,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 102,1
             DEFB 180,1
             DEFB 102,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 91,1
             DEFB 180,1
             DEFB 81,1
             DEFB 180,1
             DEFB 81,1
         DEFB $0
PAT1:
         DEFB 250  ; Pattern TEMPOC
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 76,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 102,1
             DEFB 227,1
             DEFB 102,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 102,1
             DEFB 227,1
             DEFB 102,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 91,1
             DEFB 227,1
             DEFB 81,1
             DEFB 227,1
             DEFB 81,1
         DEFB $0
PAT2:
         DEFB 250  ; Pattern TEMPOC
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 76,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 102,1
             DEFB 203,1
             DEFB 102,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 102,1
             DEFB 203,1
             DEFB 102,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 91,1
             DEFB 203,1
             DEFB 81,1
             DEFB 203,1
             DEFB 81,1
         DEFB $0
PAT3:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 180,180
             DEFB 40,1
             DEFB 180,1
             DEFB 40,1
             DEFB 91,1
             DEFB 40,1
             DEFB 91,1
             DEFB 40,1
             DEFB 180,180
             DEFB 38,1
             DEFB 180,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 180,180
             DEFB 40,1
             DEFB 180,1
             DEFB 40,1
             DEFB 91,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 51,1
             DEFB 91,1
             DEFB 51,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 51,1
             DEFB 91,1
             DEFB 51,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 40,1
             DEFB 91,1
             DEFB 40,1
         DEFB $0
PAT4:
         DEFB 250  ; Pattern TEMPOC
             DEFB 227,227
             DEFB 45,1
             DEFB 227,1
             DEFB 45,1
             DEFB 114,1
             DEFB 45,1
             DEFB 114,1
             DEFB 45,1
             DEFB 227,227
             DEFB 40,1
             DEFB 227,1
             DEFB 40,1
             DEFB 114,1
             DEFB 40,1
             DEFB 114,1
             DEFB 40,1
             DEFB 227,227
             DEFB 38,1
             DEFB 227,1
             DEFB 38,1
             DEFB 114,1
             DEFB 38,1
             DEFB 114,1
             DEFB 38,1
             DEFB 227,227
             DEFB 40,1
             DEFB 227,1
             DEFB 40,1
             DEFB 114,1
             DEFB 38,1
             DEFB 114,1
             DEFB 38,1
             DEFB 227,227
             DEFB 45,1
             DEFB 227,1
             DEFB 45,1
             DEFB 114,1
             DEFB 45,1
             DEFB 114,1
             DEFB 45,1
             DEFB 227,227
             DEFB 45,1
             DEFB 227,1
             DEFB 45,1
             DEFB 114,1
             DEFB 51,1
             DEFB 114,1
             DEFB 51,1
             DEFB 227,227
             DEFB 45,1
             DEFB 227,1
             DEFB 45,1
             DEFB 114,1
             DEFB 51,1
             DEFB 114,1
             DEFB 51,1
             DEFB 227,227
             DEFB 45,1
             DEFB 227,1
             DEFB 45,1
             DEFB 114,1
             DEFB 40,1
             DEFB 114,1
             DEFB 40,1
         DEFB $0
PAT5:
         DEFB 250  ; Pattern TEMPOC
             DEFB 203,203
             DEFB 45,1
             DEFB 203,1
             DEFB 45,1
             DEFB 102,1
             DEFB 45,1
             DEFB 102,1
             DEFB 45,1
             DEFB 203,203
             DEFB 40,1
             DEFB 203,1
             DEFB 40,1
             DEFB 102,1
             DEFB 40,1
             DEFB 102,1
             DEFB 40,1
             DEFB 203,203
             DEFB 38,1
             DEFB 203,1
             DEFB 38,1
             DEFB 102,1
             DEFB 38,1
             DEFB 102,1
             DEFB 38,1
             DEFB 203,203
             DEFB 40,1
             DEFB 203,1
             DEFB 40,1
             DEFB 102,1
             DEFB 38,1
             DEFB 102,1
             DEFB 38,1
             DEFB 203,203
             DEFB 45,1
             DEFB 203,1
             DEFB 45,1
             DEFB 102,1
             DEFB 45,1
             DEFB 102,1
             DEFB 45,1
             DEFB 203,203
             DEFB 45,1
             DEFB 203,1
             DEFB 45,1
             DEFB 102,1
             DEFB 51,1
             DEFB 102,1
             DEFB 51,1
             DEFB 203,203
             DEFB 45,1
             DEFB 203,1
             DEFB 45,1
             DEFB 102,1
             DEFB 51,1
             DEFB 102,1
             DEFB 51,1
             DEFB 203,203
             DEFB 45,1
             DEFB 203,1
             DEFB 45,1
             DEFB 102,1
             DEFB 40,1
             DEFB 102,102
             DEFB 40,1
         DEFB $0
PAT6:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 180,180
             DEFB 40,34
             DEFB 180,1
             DEFB 40,34
             DEFB 91,1
             DEFB 40,34
             DEFB 91,1
             DEFB 40,34
             DEFB 180,180
             DEFB 38,30
             DEFB 180,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 180,180
             DEFB 40,30
             DEFB 180,1
             DEFB 40,30
             DEFB 91,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 51,40
             DEFB 91,1
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 51,40
             DEFB 91,1
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 40,34
             DEFB 91,1
             DEFB 40,34
         DEFB $0
PAT7:
         DEFB 250  ; Pattern TEMPOC
             DEFB 227,227
             DEFB 45,38
             DEFB 227,1
             DEFB 45,38
             DEFB 114,1
             DEFB 45,38
             DEFB 114,1
             DEFB 45,38
             DEFB 227,227
             DEFB 40,34
             DEFB 227,1
             DEFB 40,34
             DEFB 114,1
             DEFB 40,34
             DEFB 114,1
             DEFB 40,34
             DEFB 227,227
             DEFB 38,30
             DEFB 227,1
             DEFB 38,30
             DEFB 114,1
             DEFB 38,30
             DEFB 114,1
             DEFB 38,30
             DEFB 227,227
             DEFB 40,30
             DEFB 227,1
             DEFB 40,30
             DEFB 114,1
             DEFB 38,30
             DEFB 114,1
             DEFB 38,30
             DEFB 227,227
             DEFB 45,38
             DEFB 227,1
             DEFB 45,38
             DEFB 114,1
             DEFB 45,38
             DEFB 114,1
             DEFB 45,38
             DEFB 227,227
             DEFB 45,38
             DEFB 227,1
             DEFB 45,38
             DEFB 114,1
             DEFB 51,40
             DEFB 114,1
             DEFB 51,40
             DEFB 227,227
             DEFB 45,38
             DEFB 227,1
             DEFB 45,38
             DEFB 114,1
             DEFB 51,40
             DEFB 114,1
             DEFB 51,40
             DEFB 227,227
             DEFB 45,38
             DEFB 227,1
             DEFB 45,38
             DEFB 114,1
             DEFB 40,34
             DEFB 114,1
             DEFB 40,34
         DEFB $0
PAT8:
         DEFB 250  ; Pattern TEMPOC
             DEFB 203,203
             DEFB 45,38
             DEFB 203,1
             DEFB 45,38
             DEFB 102,1
             DEFB 45,38
             DEFB 102,1
             DEFB 45,38
             DEFB 203,203
             DEFB 40,34
             DEFB 203,1
             DEFB 40,34
             DEFB 102,1
             DEFB 40,34
             DEFB 102,1
             DEFB 40,34
             DEFB 203,203
             DEFB 38,30
             DEFB 203,1
             DEFB 38,30
             DEFB 102,1
             DEFB 38,30
             DEFB 102,1
             DEFB 38,30
             DEFB 203,203
             DEFB 40,30
             DEFB 203,1
             DEFB 40,30
             DEFB 102,1
             DEFB 38,30
             DEFB 102,1
             DEFB 38,30
             DEFB 203,203
             DEFB 45,38
             DEFB 203,1
             DEFB 45,38
             DEFB 102,1
             DEFB 45,38
             DEFB 102,1
             DEFB 45,38
             DEFB 203,203
             DEFB 45,38
             DEFB 203,1
             DEFB 45,38
             DEFB 102,1
             DEFB 51,40
             DEFB 102,1
             DEFB 51,40
             DEFB 203,203
             DEFB 45,38
             DEFB 203,1
             DEFB 45,38
             DEFB 102,1
             DEFB 51,40
             DEFB 102,1
             DEFB 51,40
             DEFB 203,203
             DEFB 45,38
             DEFB 203,1
             DEFB 45,38
             DEFB 102,1
             DEFB 40,34
             DEFB 102,102
             DEFB 40,34
         DEFB $0
PAT9:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 180,180
             DEFB 40,34
             DEFB 180,20
             DEFB 40,34
             DEFB 91,20
             DEFB 40,34
             DEFB 91,20
             DEFB 40,34
             DEFB 180,180
             DEFB 38,30
             DEFB 180,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 180,180
             DEFB 40,30
             DEFB 180,20
             DEFB 40,30
             DEFB 91,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,25
             DEFB 51,40
             DEFB 91,25
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,25
             DEFB 51,40
             DEFB 91,25
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,20
             DEFB 40,34
             DEFB 91,20
             DEFB 40,34
         DEFB $0
PAT10:
         DEFB 250  ; Pattern TEMPOC
             DEFB 227,227
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 114,23
             DEFB 45,38
             DEFB 114,23
             DEFB 45,38
             DEFB 227,227
             DEFB 40,34
             DEFB 227,20
             DEFB 40,34
             DEFB 114,20
             DEFB 40,34
             DEFB 114,20
             DEFB 40,34
             DEFB 227,227
             DEFB 38,30
             DEFB 227,19
             DEFB 38,30
             DEFB 114,19
             DEFB 38,30
             DEFB 114,19
             DEFB 38,30
             DEFB 227,227
             DEFB 40,30
             DEFB 227,20
             DEFB 40,30
             DEFB 114,19
             DEFB 38,30
             DEFB 114,19
             DEFB 38,30
             DEFB 227,227
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 114,23
             DEFB 45,38
             DEFB 114,23
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 114,25
             DEFB 51,40
             DEFB 114,25
             DEFB 51,40
             DEFB 227,227
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 114,25
             DEFB 51,40
             DEFB 114,25
             DEFB 51,40
             DEFB 227,227
             DEFB 45,38
             DEFB 227,23
             DEFB 45,38
             DEFB 114,20
             DEFB 40,34
             DEFB 114,20
             DEFB 40,34
         DEFB $0
PAT11:
         DEFB 250  ; Pattern TEMPOC
             DEFB 203,203
             DEFB 45,38
             DEFB 203,23
             DEFB 45,38
             DEFB 102,23
             DEFB 45,38
             DEFB 102,23
             DEFB 45,38
             DEFB 203,203
             DEFB 40,34
             DEFB 203,20
             DEFB 40,34
             DEFB 102,20
             DEFB 40,34
             DEFB 102,20
             DEFB 40,34
             DEFB 203,203
             DEFB 38,30
             DEFB 203,19
             DEFB 38,30
             DEFB 102,19
             DEFB 38,30
             DEFB 102,19
             DEFB 38,30
             DEFB 203,203
             DEFB 40,30
             DEFB 203,20
             DEFB 40,30
             DEFB 102,19
             DEFB 38,30
             DEFB 102,19
             DEFB 38,30
             DEFB 203,203
             DEFB 45,38
             DEFB 203,23
             DEFB 45,38
             DEFB 102,23
             DEFB 45,38
             DEFB 102,23
             DEFB 45,38
             DEFB 203,203
             DEFB 45,38
             DEFB 203,23
             DEFB 45,38
             DEFB 102,25
             DEFB 51,40
             DEFB 102,25
             DEFB 51,40
             DEFB 203,203
             DEFB 45,38
             DEFB 203,23
             DEFB 45,38
             DEFB 102,25
             DEFB 51,40
             DEFB 102,25
             DEFB 51,40
             DEFB 203,203
             DEFB 45,38
             DEFB 203,23
             DEFB 45,38
             DEFB 102,20
             DEFB 40,34
             DEFB 102,102
             DEFB 40,34
         DEFB $0
PAT12:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 180,180
             DEFB 40,1
             DEFB 180,1
             DEFB 40,1
             DEFB 91,1
             DEFB 40,1
             DEFB 91,1
             DEFB 40,1
             DEFB 180,180
             DEFB 38,1
             DEFB 180,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 180,180
             DEFB 40,1
             DEFB 180,1
             DEFB 40,1
             DEFB 91,1
             DEFB 38,1
             DEFB 91,1
             DEFB 38,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 91,1
             DEFB 45,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 51,1
             DEFB 91,1
             DEFB 51,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 51,1
             DEFB 91,1
             DEFB 51,1
             DEFB 180,180
             DEFB 45,1
             DEFB 180,1
             DEFB 45,1
             DEFB 91,1
             DEFB 40,1
             DEFB 91,180
             DEFB 40,1
         DEFB $0
PAT13:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 180,180
             DEFB 40,34
             DEFB 180,1
             DEFB 40,34
             DEFB 91,1
             DEFB 40,34
             DEFB 91,1
             DEFB 40,34
             DEFB 180,180
             DEFB 38,30
             DEFB 180,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 180,180
             DEFB 40,30
             DEFB 180,1
             DEFB 40,30
             DEFB 91,1
             DEFB 38,30
             DEFB 91,1
             DEFB 38,30
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 91,1
             DEFB 45,38
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 51,40
             DEFB 91,1
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 51,40
             DEFB 91,1
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,1
             DEFB 45,38
             DEFB 91,1
             DEFB 40,34
             DEFB 91,180
             DEFB 40,34
         DEFB $0
PAT14:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 180,180
             DEFB 40,34
             DEFB 180,20
             DEFB 40,34
             DEFB 91,20
             DEFB 40,34
             DEFB 91,20
             DEFB 40,34
             DEFB 180,180
             DEFB 38,30
             DEFB 180,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 180,180
             DEFB 40,30
             DEFB 180,20
             DEFB 40,30
             DEFB 91,19
             DEFB 38,30
             DEFB 91,19
             DEFB 38,30
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 91,23
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,25
             DEFB 51,40
             DEFB 91,25
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,25
             DEFB 51,40
             DEFB 91,25
             DEFB 51,40
             DEFB 180,180
             DEFB 45,38
             DEFB 180,23
             DEFB 45,38
             DEFB 91,20
             DEFB 40,34
             DEFB 91,180
             DEFB 40,34
         DEFB $0
PAT15:
         DEFB 250  ; Pattern TEMPOC
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 180,180
             DEFB 38,45
             DEFB 180,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
             DEFB 91,91
             DEFB 38,45
         DEFB $0
PAT16:
         DEFB 250  ; Pattern TEMPOC
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 114,114
             DEFB 38,45
             DEFB 114,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
             DEFB 57,91
             DEFB 38,45
         DEFB $0
PAT17:
         DEFB 250  ; Pattern TEMPOC
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,45
             DEFB 121,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 61,91
             DEFB 38,45
             DEFB 121,121
             DEFB 38,14
             DEFB 121,15
             DEFB 38,18
             DEFB 61,21
             DEFB 38,27
             DEFB 61,36
             DEFB 38,43
         DEFB $0
end asm
end sub