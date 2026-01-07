# Tug of War Game

A **Tug of War LED game** implemented in **SystemVerilog** for the **Intel/Altera DE1-SoC FPGA board**.  
A human player competes against a computer opponent to pull a single lit LED to their side of a 9-LED “rope.”

---

## Overview
- The rope is represented by **9 LEDs** (`LEDR[9:1]`)
- The game starts with the **center LED lit**
- Each pull moves the light **one position**
- If the light reaches an edge, that side **wins the round**
- After a win:
  - The rope resets to the center
  - The winner’s score increments
- Scores persist until a hard reset

---

## Controls

### Inputs
| Signal | Description |
|------|------------|
| `CLOCK_50` | 50 MHz system clock |
| `KEY[3]` | Left (human) pull button *(active-low)* |
| `SW[9]` | Hard reset |
| `SW[8:0]` | Computer behavior input |

### Outputs
| Signal | Description |
|------|------------|
| `LEDR[9:1]` | Rope LED display |
| `HEX5` | Left player score (0–7) |
| `HEX0` | Right player score (0–7) |

---

## Computer Opponent Logic

The right player is controlled by hardware logic rather than a button:

- A **9-bit LFSR** generates pseudo-random values
- A **9-bit adder** computes:
- The adder’s **carry-out (`Cout`)** determines the computer pull

**If `Cout == 1`, the computer pulls right for that turn.**

Changing `SW[8:0]` adjusts how frequently the computer pulls, effectively changing its difficulty.

---

## Timing & Clocking

- The design uses a **clock-enable pulse**, not a derived clock
- `ClockDivider.sv` generates `CE`
- `CE` pulses **once every 2^DIV cycles**
- `DIV_FACTOR = 19` in `TopLevel.sv`

All game logic updates only when `CE` is asserted, keeping timing safe and human-readable.

## File Structure

├── TopLevel.sv        # Board I/O + clock-enable generation
├── TugOfWar.sv        # Main game integration
├── ClockDivider.sv    # Clock-enable generator
├── Synchronizer.sv    # Button synchronization
├── EdgeDetector.sv    # One-cycle pulse generation
├── LFSR.sv            # Pseudo-random generator
├── NineBitAdder.sv    # Computer pull decision logic
├── CenterLight.sv     # Center LED FSM
├── NormalLight.sv     # Interior LED FSMs
├── EdgeLight.sv       # Edge LED FSMs + win detection
├── Counter.sv         # Score counter + HEX output


# Usage
1.	Clone this repository.
2.	Open the project in Intel Quartus Prime.
3.	Compile and program to the DE1-SoC FPGA board.
4.	Play:
   * Press `KEY[3]` to pull left
   * Watch the computer pull right automatically
   * Scores update on `HEX5` and `HEX0`
   * Reset anytime with `SW[9]`

# Simulation
Test benches are provided using the naming format *_tb.sv. You can simulate using:
1. iverilog  -g2012 -o test.vvp filename.sv filename_tb.sv
2. vvp test.vvp
3. gtkwave dump.vcd

 
