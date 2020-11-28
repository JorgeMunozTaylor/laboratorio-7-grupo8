/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

`timescale 1 ns / 1 ps


/*
Module that read constantly the axis Y and Z of the 
Nexys 4 DDR accelerometer.
*/
module accelerometer_reader
(
    input clk,
    input reset,
    input MISO,
    
    output MOSI,
    output SCLK,
    output CS,
    output [15:0] Y_value,
    output [15:0] Z_value
);




endmodule