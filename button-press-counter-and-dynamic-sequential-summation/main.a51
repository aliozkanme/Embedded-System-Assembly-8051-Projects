; =============================================================================
; Project Name      : Button Press Counter and Dynamic Summation
; Author            : Ali Ozkan
; Hardware          : ADuC841
; Description       : Counts negative pulses on P2.2 and stores in RAM 10h. 
;                     Upon P2.3 trigger, sums integers from BS count to 1.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

; -----------------------------------------------------------------------------
; INITIALIZATION SECTION
; -----------------------------------------------------------------------------
INIT:
    MOV P0, #00h                ; Initialize Port 0 (LEDs OFF)
    MOV 10h, #00h               ; Clear Button Press (BS) count at RAM 10h
    MOV A, #00h                 ; Clear Accumulator for summation

; -----------------------------------------------------------------------------
; PULSE DETECTION (P2.2 - BT3)
; -----------------------------------------------------------------------------
PUSH_CONTROL:
    JB P2.2, PUSH_CONTROL       ; Wait until BT3 (P2.2) is pressed (Logic 0)
    
PULL_CONTROL:    
    JNB P2.2, PULL_CONTROL      ; Wait until BT3 (P2.2) is released (Logic 1)
    
    INC 10h                     ; Increment BS count at RAM 10h after each pulse
    JB P2.3, PUSH_CONTROL       ; Continue counting until Sum Button (P2.3) is pressed

; -----------------------------------------------------------------------------
; SUMMATION LOGIC (Recursive Total)
; -----------------------------------------------------------------------------
    MOV R0, 10h                 ; Load BS count into R0 for the loop
    MOV A, #00h                 ; Reset Accumulator before starting summation

SUM_LOOP:
    ADD A, R0                   ; Add current count (R0) to total (A)
    DJNZ R0, SUM_LOOP           ; Decrement R0 and repeat until R0 = 0

; -----------------------------------------------------------------------------
; OUTPUT AND RESET
; -----------------------------------------------------------------------------
    MOV P0, A                   ; Display final summation result on Port 0 LEDs
    MOV 10h, #00h               ; Reset BS count for the next cycle

STOP:
    SJMP STOP                   ; Infinite loop to hold the result

END