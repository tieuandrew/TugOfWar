# Tug of War Game

This project implements a digital **Tug of War game** in SystemVerilog for the Intel/Altera DE1-SoC FPGA board.  
Two players press buttons to “pull” a light toward their side; the first player to reach the edge wins, and their number is displayed on the 7-segment HEX0 display.

# Features
 **Two players** using KEY[3] (Left) and KEY[0] (Right).
- **Reset** switch (SW[9]) to restart the game at any point.
- **Synchronizer** and **Edge Detector** modules to handle metastability and ensure button presses last exactly one clock cycle.
- **Light chain** of 9 LEDs (LEDR[9:1]) that shift left or right based on player input.
- **Victory module**:
  - Displays `1` if the left player wins.
  - Displays `2` if the right player wins.
  - Freezes the game state until reset.

# Structure
├── TugOfWar.sv          # Top-level module

├── Synchronizer.sv

├── EdgeDetector.sv

├── NormalLight.sv

├── CenterLight.sv

├── EdgeLight.sv

├── Victory.sv

# Usage
1.	Clone this repository.
2.	Open the project in Intel Quartus Prime.
3.	Compile and program to the DE1-SoC FPGA board.
4.	Play:
  •	 Press KEY[3] for Player 1 (Left).
  •	Press KEY[0] for Player 2 (Right).
  •	Watch the LEDs shift like a tug-of-war rope.
  •	When one side reaches the edge, HEX0 displays the winner.
  •	Flip SW[9] to reset.

# Simulation
Test benches are provided using the naming format *_tb.sv. You can simulate using:
  iverilog  -g2012 -o test.vvp filename.sv filename_tb.sv
  vvp test.vvp
  gtkwave dump.vcd

 
