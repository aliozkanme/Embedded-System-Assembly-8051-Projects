; =============================================================================
; Project Name      : Bit-Level Memory Manipulation and LED Control
; Author            : Ali Ozkan
; Hardware          : ADuC841
; Description       : Manipulates RAM bit 23h.5 to drive P0.4 and maps 
;                     P2.4-P2.7 input bits into RAM address 08h (bits 0-3).
; =============================================================================

#include <ADUC841.H>

ORG 0000h

; -----------------------------------------------------------------------------
; PART A: BIT-ADDRESSABLE LED CONTROL
; -----------------------------------------------------------------------------
    MOV P0, #00h            ; Initialize Port 0 to clear all outputs
    SETB C                  ; Set Carry Flag to Logic 1 (Alternative to MOV PSW, #80h)
    MOV 1Ch, C              ; Move Carry to bit address 1Ch (corresponds to 23h.5)
    MOV P0, 23h             ; Update Port 0 with content of 23h (P0.4 becomes 1)

; -----------------------------------------------------------------------------
; PART B: PORT-TO-MEMORY NIBBLE MAPPING
; -----------------------------------------------------------------------------
    ANL P2, #0F0h           ; Mask lower nibble of P2, keeping only P2.4-P2.7
    MOV A, P2               ; Move P2 status to Accumulator
    SWAP A                  ; Swap nibbles: P2.4-P2.7 move to bits 0-3 positions
    MOV 08h, A              ; Store the re-mapped bits into RAM address 08h

END