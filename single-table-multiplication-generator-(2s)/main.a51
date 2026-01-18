; =============================================================================
; Project Name		: Multiplication Table of 2 (RAM Mapping)
; Author			: Ali Ozkan
; Hardware			: ADuC841 (Internal RAM Processing)
; Description		: Calculates 2x1 through 2x9 and stores results in RAM 00h-08h.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

; -----------------------------------------------------------------------------
; INITIALIZATION
; -----------------------------------------------------------------------------
INIT:
    MOV PSW, #08h               ; RS0=1, RS1=0: Select Register Bank 1
                                ; This moves R1 and R7 away from the 00h-07h range.
    MOV R1, #00h                ; Pointer for RAM address 00h
    MOV A, #02h                 ; First result: 2x1 = 2
    MOV R7, #09h                ; Loop counter for 9 iterations

; -----------------------------------------------------------------------------
; CALCULATION & STORAGE LOOP
; -----------------------------------------------------------------------------
PROCESS:
    MOV @R1, A                  ; Store result in RAM (Bank 0 area)
    ADD A, #02h                 ; Next multiple of 2
    INC R1                      ; Next RAM address
    DJNZ R7, PROCESS            ; Repeat. Counter R7 is now at address 0Fh, safe!

; -----------------------------------------------------------------------------
; TERMINATION (Infinite Loop)
; -----------------------------------------------------------------------------
STOP:
    SJMP STOP                   ; Stay in an infinite loop to preserve RAM data

END