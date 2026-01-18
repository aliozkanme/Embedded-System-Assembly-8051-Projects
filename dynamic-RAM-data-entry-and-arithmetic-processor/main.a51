; =============================================================================
; Project Name      : Dynamic RAM Data Entry and Arithmetic Processor
; Author            : Ali Ozkan
; Hardware          : ADuC841
; Description       : Automates RAM population (11h-1Ah) and calculates the 
;                     difference between half-sums of odd and even addresses.
; =============================================================================

#include <ADUC841.H>

ORG 0000h

; -----------------------------------------------------------------------------
; PHASE 1: DATA ENTRY (RAM POPULATION)
; -----------------------------------------------------------------------------
    MOV A,  #128d           ; Load decimal 128 into Accumulator
    MOV R0, #1Ah            ; Set pointer to the last RAM address (1Ah)
    MOV R1, #05h            ; Set loop counter for 5 pairs (10 bytes total)

PROCESS1:
    MOV @R0, A              ; Store current value (e.g., 128) to RAM address in R0
    DEC R0                  ; Decrement RAM pointer
    RR A                    ; Rotate right (effectively divide by 2)
    RR A                    ; Rotate right again (effectively divide by 4 total)
    MOV @R0, A              ; Store modified value (e.g., 32) to next RAM address
    DEC R0                  ; Decrement RAM pointer
    RL A                    ; Rotate left once to prepare next sequence start
    DJNZ R1, PROCESS1       ; Repeat until RAM block 11h-1Ah is populated

; -----------------------------------------------------------------------------
; PHASE 2: ARITHMETIC CALCULATION
; -----------------------------------------------------------------------------
    MOV A, #00h             ; Clear Accumulator for summation
    MOV R1, #1Bh            ; Set pointer just above the top address (1Ah)
    MOV R0, #05h            ; Set loop counter for 5 pairs

PROCESS2:
    DEC R1                  ; Point to odd address (1Ah, 18h, etc.)
    ADD A, @R1              ; Sum odd address values
    DEC R1                  ; Point to even address (19h, 17h, etc.)
    SUBB A, @R1             ; Subtract even address values
    DJNZ R0, PROCESS2       ; Repeat for all pairs

    RR A                    ; Divide the final result by 2 (Right Shift)
    MOV P0, A               ; Output the final result to Port 0

END