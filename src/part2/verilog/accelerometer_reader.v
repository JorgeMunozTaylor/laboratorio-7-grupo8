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
    output reg CS,  // Chip select, select the slave
    output [15:0] Y_value,
    output [15:0] Z_value
);
    reg [4:0] counter = 0;
    
    always @(posedge clk)
    begin
        
        if ( counter == 24 )
        begin
            CS      <= 1; // Stop transfer
            counter <= 0;
        end

        else if ( counter > 0 )
        begin
            // Begin the instruction transfer
            CS      <= 0;
            counter <= counter+1;
        end

        else if ( counter == 0 )
        begin
            CS      <= 1;
            counter <= counter+1;
        end

    end


endmodule