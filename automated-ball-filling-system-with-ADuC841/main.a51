; =============================================================================
; Project Name	: Automated Ball Filling System
; Author		: Ali Ozkan
; Hardware		: ADuC841 (8051 Architecture)
; Description	: Counts balls using Timer 0, compares with external reference,
;             	  and triggers a 0.5s LED alert using Timer 2 for 10 cycles.
; =============================================================================

#include <ADUC841.H>

ORG 0000h
SJMP INIT

; -----------------------------------------------------------------------------
; INITIALIZATION SECTION
; -----------------------------------------------------------------------------
INIT:
    MOV SP, #50h                ; Initialize Stack Pointer at address 50h
    CLR P1.0                    ; Ensure LD1 (P1.0) is OFF initially
    MOV P2, #0FFh               ; Configure Port 2 as Input for reference data
    MOV P3, #0FFh               ; Configure Port 3 as Input for sensor/reference

; -----------------------------------------------------------------------------
; MAIN PROGRAM LOOP
; -----------------------------------------------------------------------------
MAIN_LOGIC:
    ACALL TIMER_SETUP           ; Configure Timer 0 (Counter) and Timer 2 (Delay)
    ACALL REFERENCE_READ        ; Fetch target value from external pins
    MOV R0, #0Ah                ; Set Batch Counter to 10 (Process 10 boxes)
    MOV R2, #64h                ; Load delay multiplier for 0.5s (100 decimal)
    SETB TR0                    ; Enable Timer 0 to start counting sensor pulses

WAIT_FOR_TARGET:
    MOV A, TL0                  ; Fetch current ball count (BS) from Timer 0 Low Byte
    CJNE A, 20h, WAIT_FOR_TARGET ; Polling: Wait until BS equals Reference (stored in 20h)

    ACALL LED_NOTIFY            ; Target reached: Execute LED alert subroutine
    
    ; Resetting for the next box
    MOV TL0, #00h               ; Reset Timer 0 count
    MOV TH0, #00h               ; Clear High Byte for 16-bit consistency
    
    DJNZ R0, WAIT_FOR_TARGET    ; Repeat the process for the next box (up to 10)
    
    SJMP EXIT_PROC              ; Terminate after 10 boxes are filled

; -----------------------------------------------------------------------------
; SUBROUTINE: TIMER CONFIGURATION
; -----------------------------------------------------------------------------
TIMER_SETUP:
    ; TMOD: Set T0 to 16-bit Counter Mode (C/T=1, Mode 1)
    MOV TMOD, #05h              
    ; T2CON: Configure Timer 2 for Auto-Reload Mode
    MOV T2CON, #00h             
    
    ; Initialize Timer 0 (Counter) to 0
    MOV TL0, #00h
    MOV TH0, #00h
    
    ; Initialize Timer 2 for precise timing interval (5ms per overflow)
    ; Target 0.5s delay requires multiple overflows handled in LED_TIMER
    MOV TL2, #0FCh
    MOV TH2, #26h
    MOV RCAP2L, #0FCh
    MOV RCAP2H, #26h
RET

; -----------------------------------------------------------------------------
; SUBROUTINE: EXTERNAL REFERENCE READING
; -----------------------------------------------------------------------------
REFERENCE_READ:
    MOV A, P3                   ; Read Port 3 status
    ANL A, #1Eh                 ; Mask P3.1, P3.2, P3.3, and P3.4 bits
    RR A                        ; Align bits to retrieve 4-bit reference value
    MOV 20h, A                  ; Store the processed Reference value in RAM 20h
RET

; -----------------------------------------------------------------------------
; SUBROUTINE: LED ALERT CONTROL
; -----------------------------------------------------------------------------
LED_NOTIFY:
    SETB P1.0                   ; Turn ON LD1 LED
    ACALL DELAY_LOOP            ; Initiate 0.5s delay sequence
    CLR P1.0                    ; Turn OFF LD1 LED
RET

; -----------------------------------------------------------------------------
; SUBROUTINE: 0.5 SECOND DELAY (TIMER 2)
; -----------------------------------------------------------------------------
DELAY_LOOP:
    SETB TR2                    ; Start Timer 2

OVERFLOW_WAIT:
    JNB TF2, OVERFLOW_WAIT      ; Wait for Timer 2 Overflow Flag
    CLR TF2                     ; Clear Overflow Flag manually
    DJNZ R2, OVERFLOW_WAIT      ; Loop until 100 overflows occur (0.5s total)

    CLR TR2                     ; Stop Timer 2
    MOV R2, #64h                ; Reload R2 for the next box cycle
RET

EXIT_PROC:
    CLR TR0                     ; Stop all counters
    CLR TR2
    SJMP $                      ; End of program: Infinite loop

END