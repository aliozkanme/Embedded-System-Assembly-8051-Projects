; =============================================================================
; Project Name      : Internal RAM Data Block Transfer
; Author            : Ali Ozkan
; Hardware          : ADuC841
; Description       : Populates RAM 10h-19h with values and transfers them 
;                     to 30h-39h using indirect addressing and loop control.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

; -----------------------------------------------------------------------------
; PHASE 1: DATA INITIALIZATION (LOADING 10h-19h)
; -----------------------------------------------------------------------------
INIT:
    MOV R0, #19h            ; Set pointer to the end of source block (19h)
    MOV R1, #0Ah            ; Set loop counter for 10 bytes
    MOV A,  #2Ah            ; Initial value to be decremented and stored

LOAD:
    DEC A                   ; Decrement value
    MOV @R0, A              ; Store value in current RAM address pointed by R0
    DEC R0                  ; Move pointer to the previous address
    DJNZ R1, LOAD           ; Repeat until source block is populated

; -----------------------------------------------------------------------------
; PHASE 2: DATA TRANSFER (MIGRATION TO 30h-39h)
; -----------------------------------------------------------------------------
    MOV R0, #3Ah            ; Set destination pointer (starts from 39h via DEC)
    MOV R1, #19h            ; Set source pointer (starts from 19h)
    MOV R2, #0Ah            ; Set loop counter for 10 bytes

TRANSFER:
    DEC R0                  ; Decrement destination pointer (3Ah -> 39h...)
    MOV A, @R1              ; Read data from source address pointed by R1
    DEC R1                  ; Decrement source pointer (19h -> 18h...)
    MOV @R0, A              ; Write data to destination address pointed by R0
    DJNZ R2, TRANSFER       ; Repeat until all 10 bytes are transferred

END