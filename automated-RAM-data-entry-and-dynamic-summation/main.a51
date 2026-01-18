; =============================================================================
; Project Name      : RAM Data Logging and Dynamic Summation
; Author            : Ali Ozkan
; Hardware          : ADuC841
; Description       : Writes values 1-10 to RAM 10h-19h and calculates their 
;                     sum using indirect addressing, outputting result to P2.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

; -----------------------------------------------------------------------------
; INITIALIZATION & DATA ENTRY PHASE
; -----------------------------------------------------------------------------
INIT:
    MOV A, #00h                 ; Initialize Accumulator A with value 00h
    MOV B, #0Ah                 ; Initialize Register B with value 0Ah
    MOV R0, #19h                ; Initialize Register R0 with address 19h

WRITE_DATA:
    MOV @R0, B                  ; Move the value of Register B to the address pointed by R0
    DEC R0                      ; Decrement the value of Register R0 by 1
    DEC B                       ; Decrement the value of Register B by 1
    CJNE A, B, WRITE_DATA       ; Continue WRITE_DATA loop until A and B are equal

; -----------------------------------------------------------------------------
; DYNAMIC SUMMATION PHASE
; -----------------------------------------------------------------------------
SUM_DATA:
    INC R0                      ; Increment the value of Register R0 by 1
    MOV B, @R0                  ; Move value at address pointed by R0 to Register B
    ADD A, B                    ; Add values of A and B, store result in Accumulator A
    CJNE R0, #1Ah, SUM_DATA     ; Continue SUM_DATA loop until R0 reaches address 1Ah

; -----------------------------------------------------------------------------
; OUTPUT & TERMINATION
; -----------------------------------------------------------------------------
	MOV P2, A                   ; Output the final result in Accumulator A to Port 2

STOP:
    SJMP STOP                   ; Infinite loop to maintain the result display on P2

END