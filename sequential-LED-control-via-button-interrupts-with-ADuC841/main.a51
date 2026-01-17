; =============================================================================
; Project Name	: Sequential LED Control via Button Interrupts
; Author		: Ali Ozkan
; Hardware		: ADuC841 Development Board
; Description	: This program cycles through 8 LEDs (LED1-LED8) connected to Port 0
;              	  each time the BT1 button (P2.0) is pressed and released.
; =============================================================================

#include <ADUC841.H>

ORG 0000h

; -----------------------------------------------------------------------------
; INITIALIZATION SECTION
; -----------------------------------------------------------------------------
INIT:
    CLR P2.3                        ; Enable Port 0 for LED output on the board
    MOV P0, #00h                    ; Initialize Port 0: Ensure all LEDs are OFF
    MOV A, #01h                     ; Load pattern 00000001b to ignite the first LED

; -----------------------------------------------------------------------------
; MAIN SEQUENTIAL LOGIC
; -----------------------------------------------------------------------------
MAIN_LOOP:
    ACALL BT1_CONTROL               ; Execute subroutine to handle button polling
    MOV P0, A                       ; Output the current bit pattern to the LED Port
    RL A                            ; Circular shift left to prepare the next LED bit
    SJMP MAIN_LOOP                  ; Repeat the sequence indefinitely

; -----------------------------------------------------------------------------
; SUBROUTINE: BT1 CONTROL & DEBOUNCE
; -----------------------------------------------------------------------------
BT1_CONTROL:
    ; Wait for Button Press (Active Low detection)
WAIT_FOR_PRESS:
    JB P2.0, WAIT_FOR_PRESS         ; Poll P2.0 (BT1) until the pin goes LOW

    ; Software Debounce Logic
    MOV R0, #20h                    ; Load delay constant to filter mechanical noise
DEBOUNCE_DELAY:
    DJNZ R0, DEBOUNCE_DELAY         ; Decrement until delay period elapses

    ; Wait for Button Release
WAIT_FOR_RELEASE:
    JNB P2.0, WAIT_FOR_RELEASE      ; Poll P2.0 (BT1) until the pin goes HIGH again
RET                                 ; Return to the main sequence

END