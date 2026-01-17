# Sequential LED Control via Button Interrupts with ADuC841

<p align="left">
  <img src="https://img.shields.io/badge/Architecture-8051 Instruction Set-blue?style=flat-square" alt="8051">
  <img src="https://img.shields.io/badge/IDE-Keil_uVision_5-red?style=flat-square" alt="Keil">
  <img src="https://img.shields.io/badge/Language-Assembly-yellowgreen?style=flat-square" alt="Assembly">
</p>

---

## 📝 Overview
This project focuses on interfacing digital input and output peripherals using the ADuC841 microcontroller. The system is designed to control an 8-LED array sequentially using a single push-button (BT1). 
Initially, all LEDs are off. Upon each button press, the system shifts the active light to the next LED in the sequence (from LED1 to LED8). The implementation emphasizes efficient input polling and output port management, utilizing a modular subroutine structure to minimize the code footprint.

## 🎯 Objectives
* **Digital Input Management:** Implement an efficient polling mechanism to detect button presses from BT1.
* **Sequential Logic:** Create a shifting logic that activates exactly one LED at a time in a specific order (LED1 to LED8).
* **Port Manipulation:** Control an 8-bit LED array connected to a specific output port (Port 2 or Port 0, depending on the board's mapping).
* **Code Optimization:** Develop the firmware using the minimum possible instruction lines as per the project requirements.
* **Subroutine Architecture:** Utilize a modular "Button Control" subroutine to handle the input logic independently from the main loop.

## ⚙️ Hardware Configuration & Pin Mapping

The system interfaces with the ADuC841 development board's integrated peripherals. The button state is polled via digital inputs, while the LEDs are driven through an 8-bit output port.

| Component | Pin / Port | Function | Description |
| :--- | :--- | :--- | :--- |
| **Push Button (BT1)** | **P3.2 (INT0)** | Digital Input | Primary trigger used to cycle through the LEDs. |
| **LED Array (LED1-8)** | **Port 2 (P2.0 - P2.7)** | Digital Output | 8-bit LED group driven in sequence (Active Low or High). |
| **ADuC841 MCU** | Core | Processor | Handles polling and bit-shifting logic. |

### Memory Mapping
* **Register `R1`**: Used as a temporary storage to track the current LED bit position.
* **Accumulator `A`**: Utilized for bit-shifting operations (`RL` or `RR`) during the button press event.

## 🕹️ System Operation & Logic

The project follows a state-dependent execution logic where the output changes only upon a valid input trigger (button press). The operational flow is as follows:

1.  **Initial State**: 
    * Upon reset, the system ensures all LEDs are turned OFF by clearing the designated output port.
    * The system enters a continuous polling loop, waiting for a signal from **BT1**.

2.  **Button Press Detection (BT1)**:
    * The system monitors **P3.2** for a transition.
    * Once a press is detected, a **Debounce Delay** (optional but recommended for hardware) or a "Wait for Release" logic is executed to prevent multiple triggers from a single press.

3.  **Sequential Shifting**:
    * The system starts the sequence by lighting **LED1**.
    * On each subsequent press, the active bit is shifted to the next position (e.g., using the `RL A` or `RR A` instructions) to move the light from LED1 through LED8.
    * The logic is designed to cycle: after LED8, the next press returns the sequence to LED1 or turns all off, depending on the specific implementation.

4.  **Efficiency and Subroutines**:
    * The button check is handled within a dedicated subroutine to keep the main loop clean.
    * The code is optimized for the **minimum number of instructions** by using bit-wise rotations instead of multiple comparison statements.

## ⏱️ Timer & Peripheral Specifications

This project primarily utilizes the high-speed I/O capabilities of the **ADuC841** rather than internal timing peripherals. The focus is on the synchronization between human input (button) and machine output (LEDs).

### 1. GPIO Port Management
* **Output Port (Port 2)**: Configured as a push-pull output to drive the 8-segment LED array. The port reacts instantly to bit-shifting instructions in the accumulator.
* **Input Port (Port 3)**: High-impedance input mode is used for **P3.2** to ensure stable detection of the BT1 button state.

### 2. External Interrupt Logic (Optional/Polling)
* **Polling Method**: The system continuously checks the state of the button pin. This is chosen to keep the code footprint at the "minimum possible lines" as requested.
* **Signal Stability**: Logic is implemented to detect the transition from high-to-low (or low-to-high) to ensure the LED only shifts once per physical click.

### 3. Execution Speed
* **Instruction Cycle**: Operating at the ADuC841's core frequency, the LED shift occurs in microseconds, providing an instantaneous visual response to the user.

## 🏗️ Program Structure

The software is architected to be as lightweight as possible while maintaining a clear separation between the main application logic and peripheral control.

* **`INITIALIZATION`**: Sets up the stack pointer and clears the LED port to ensure a clean start state where all LEDs are off.
* **`MAIN_POLLING_LOOP`**: A continuous loop that calls the button control subroutine and manages the transition between LED states.
* **`BTN_CONTROL` (Subroutine)**: The core logic block that:
    * Scans the state of **BT1**.
    * Handles the "wait-for-release" logic to ensure single-step execution.
    * Executes the bit-rotation logic to determine the next LED to be activated.
* **`LED_UPDATE`**: A minimal instruction block that moves the calculated pattern from the accumulator directly to the output port.

## 💻 Source Code

> [!IMPORTANT]
> The following code is developed in 8051 Assembly for the Keil µVision environment. It follows the standard 8051 instruction set.

<details>
  <summary><b>📜 Click to View Source Code</b></summary>
  <br>

```assembly
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
```

</details>

## 🧪 Simulation & Testing (Keil µVision)

To verify the sequential LED logic in a virtual environment, use the Keil Simulator with the following steps:

1.  **Enter Debug Mode**: Start the session by clicking **Debug -> Start/Stop Debug Session** (or `Ctrl+F5`).
2.  **Open Peripheral Windows**:
    * Go to **Peripherals -> I/O Ports -> Port 0** (to monitor LED outputs).
    * Go to **Peripherals -> I/O Ports -> Port 2** (to simulate the BT1 button).
3.  **Simulate Button Press**:
    * Find bit **P2.0** in the Port 2 window.
    * **Click once** to set it LOW (simulates pressing the button).
    * **Click again** to set it HIGH (simulates releasing the button).
4.  **Observe Output**:
    * Check the **Port 0** window. You should see the bits shifting (`01h -> 02h -> 04h ... -> 80h`) with each full press-release cycle.
    * Verify that the sequence restarts at `01h` after the 8th LED (`80h`).
	
## 🛠 Installation & Execution

Follow these instructions to deploy the code on the ADuC841 development board:

1.  **Hardware Connection**: Connect your ADuC841 development board to your PC using the RS232 or USB-Serial interface.
2.  **Compile**: Open the project in **Keil µVision 5.0** and press `F7` to build. Ensure `Project2.hex` is generated.
3.  **Flash the Firmware**:
    * Use the **Windows Serial Downloader (WSD)** tool.
    * Select the generated `.hex` file.
    * Press the **Reset** button on the board while clicking 'Download' on the software.
4.  **Operation**: 
    * Once programmed, observe that all LEDs are initially OFF.
    * Press **BT1** repeatedly to cycle the light through **LED1** to **LED8**.