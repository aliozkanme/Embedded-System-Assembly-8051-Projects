; =============================================================================
; Project Name		: Automated Multiplication Table Generator
; Author			: Ali Ozkan
; Hardware			: ADuC841 (Internal RAM Processing)
; Description		: Calculates multiplication tables for 2, 3, and 4.
;              		  Results are mapped to RAM addresses 09h through 23h.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

INIT:
    MOV R0, #09h                ; Initialize R0 as a Pointer starting at RAM 09h
    MOV R2, #02h                ; R2 = Base multiplier (Starts with table of 2)

; -----------------------------------------------------------------------------
; OUTER LOOP: Iterates through Base Multipliers (2, 3, and 4)
; -----------------------------------------------------------------------------
OUTER_LOOP:
    MOV R3, #01h                ; R3 = Current step multiplier (1 to 9)

; -----------------------------------------------------------------------------
; INNER LOOP: Calculates and stores individual table results
; -----------------------------------------------------------------------------
INNER_CALC_LOOP:
    MOV A, R2                   ; Load base multiplier into Accumulator
    MOV B, R3                   ; Load current step into B register
    MUL AB                      ; Perform Multiplication (A * B)
    
    MOV @R0, A                  ; Store the result in RAM pointed by R0
    INC R0                      ; Increment Pointer to the next RAM address
    
    INC R3                      ; Increment step multiplier
    CJNE R3, #0Ah, INNER_CALC_LOOP ; Repeat until 9 steps are completed (1-9)

    INC R2                      ; Move to the next base multiplier (e.g., 2 -> 3)
    CJNE R2, #05h, OUTER_LOOP   ; Repeat until tables for 2, 3, and 4 are done

; -----------------------------------------------------------------------------
; TERMINATION
; -----------------------------------------------------------------------------
STOP:
    SJMP STOP                   ; End of processing: Infinite loop

END