/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

`timescale 1 ns / 1 ps

`define READ  8'h0B //Read instruction
`define WRITE 8'h0A //Write instruction
`define Y_LSB 8'h10
`define Y_MSB 8'h11
`define Z_LSB 8'h12
`define Z_MSB 8'h13

/*
Module that read constantly the axis Y and Z of the 
Nexys 4 DDR accelerometer.
*/
module accelerometer_reader
(
    input clk,
    input reset,
    input MISO,
    
    output reg MOSI,
    output reg SCLK, 
    output reg CS,  // Chip select, select the slave
    output reg [15:0] Y_value,
    output reg [15:0] Z_value
);
    // Reg address of the accelerometer Y and Z axis
    reg [7:0] init_addr = `Y_LSB;

    reg [7:0] read  = `READ;
    reg [7:0] write = `WRITE;

    reg        counter      = 0;
    reg [5:0 ] sclk_counter = 0;
    reg [15:0] y_data       = 0;
    reg [15:0] z_data       = 0;
    reg [2:0 ] selector     = 3'b000; 
    
    /**/
    always @(posedge clk)
    begin

        if ( selector == 3'b100 )
        begin
            if ( sclk_counter == 48 )
            begin
                CS      <= 1; // Stop transfer
                counter <= 0;
            end

            if ( counter != 0 )
            begin
                // Begin the instruction transfer
                CS <= 0;
            end

            else if ( counter == 0 )
            begin
                CS      <= 1;
                counter <= counter+1;
            end
        end

        else
        begin
            if ( sclk_counter == 24 )
            begin
                CS      <= 1; // Stop transfer
                counter <= 0;
            end

            if ( counter != 0 )
            begin
                // Begin the instruction transfer
                CS <= 0;
            end

            else if ( counter == 0 )
            begin
                CS      <= 1;
                counter <= counter+1;
            end            
        end

    end


    /**/
    always @( posedge clk )
    begin
        if ( CS == 0 )
            SCLK <= !SCLK;
        else
            SCLK <= 1;
    end


    /**/
    always @( posedge CS )
    begin
        if ( selector == 3'b100 )
        begin
            Y_value = y_data;
            Z_value = z_data;
        end
    end


    /**/
    always @( posedge SCLK )
    begin

        if ( selector == 3'b100 )
        begin
            if ( CS == 0 && sclk_counter != 48 )
            begin
                sclk_counter <= sclk_counter+1;

                if ( sclk_counter == 0 )
                    MOSI <= read[7];
                else if ( sclk_counter == 1 )
                    MOSI <= read[6];
                else if ( sclk_counter == 2 )
                    MOSI <= read[5];   
                else if ( sclk_counter == 3 )
                    MOSI <= read[4];
                else if ( sclk_counter == 4 )
                    MOSI <= read[3]; 
                else if ( sclk_counter == 5 )
                    MOSI <= read[2];
                else if ( sclk_counter == 6 )
                    MOSI <= read[1]; 
                else if ( sclk_counter == 7 )
                    MOSI <= read[0];

                else if ( sclk_counter == 8 )
                    MOSI <= init_addr[7];
                else if ( sclk_counter == 9 )
                    MOSI <= init_addr[6];
                else if ( sclk_counter == 10 )
                    MOSI <= init_addr[5];   
                else if ( sclk_counter == 11 )
                    MOSI <= init_addr[4];
                else if ( sclk_counter == 12 )
                    MOSI <= init_addr[3]; 
                else if ( sclk_counter == 13 )
                    MOSI <= init_addr[2];
                else if ( sclk_counter == 14 )
                    MOSI <= init_addr[1]; 
                else if ( sclk_counter == 15 )
                    MOSI <= init_addr[0];

                else if ( sclk_counter == 16 )
                    y_data[7] <= MISO;
                else if ( sclk_counter == 17 )
                    y_data[6] <= MISO;
                else if ( sclk_counter == 18 )
                    y_data[5] <= MISO;
                else if ( sclk_counter == 19 )
                    y_data[4] <= MISO;
                else if ( sclk_counter == 20 )
                    y_data[3] <= MISO;
                else if ( sclk_counter == 21 )
                    y_data[2] <= MISO;
                else if ( sclk_counter == 22 )
                    y_data[1] <= MISO;
                else if ( sclk_counter == 23 )
                    y_data[0] <= MISO;    

                else if ( sclk_counter == 24 )
                    y_data[15] <= MISO;
                else if ( sclk_counter == 25 )
                    y_data[14] <= MISO;
                else if ( sclk_counter == 26 )
                    y_data[13] <= MISO;
                else if ( sclk_counter == 27 )
                    y_data[12] <= MISO;
                else if ( sclk_counter == 28 )
                    y_data[11] <= MISO;
                else if ( sclk_counter == 29 )
                    y_data[10] <= MISO;
                else if ( sclk_counter == 30 )
                    y_data[9] <= MISO;
                else if ( sclk_counter == 31 )
                    y_data[8] <= MISO;

                else if ( sclk_counter == 32 )
                    z_data[7] <= MISO;
                else if ( sclk_counter == 33 )
                    z_data[6] <= MISO;
                else if ( sclk_counter == 34 )
                    z_data[5] <= MISO;
                else if ( sclk_counter == 35 )
                    z_data[4] <= MISO;
                else if ( sclk_counter == 36 )
                    z_data[3] <= MISO;
                else if ( sclk_counter == 37 )
                    z_data[2] <= MISO;
                else if ( sclk_counter == 38 )
                    z_data[1] <= MISO;
                else if ( sclk_counter == 39 )
                    z_data[0] <= MISO;    

                else if ( sclk_counter == 40 )
                    z_data[15] <= MISO;
                else if ( sclk_counter == 41 )
                    z_data[14] <= MISO;
                else if ( sclk_counter == 42 )
                    z_data[13] <= MISO;
                else if ( sclk_counter == 43 )
                    z_data[12] <= MISO;
                else if ( sclk_counter == 44 )
                    z_data[11] <= MISO;
                else if ( sclk_counter == 45 )
                    z_data[10] <= MISO;
                else if ( sclk_counter == 46 )
                    z_data[9] <= MISO;
                else if ( sclk_counter == 47 )
                    z_data[8] <= MISO;
            end   
            else
                sclk_counter <= 0;
        end

        else
        begin
            
            if ( CS == 0 && sclk_counter != 48 )
            begin
                sclk_counter <= sclk_counter+1;

                if ( sclk_counter == 0 )
                    MOSI <= read[7];
                else if ( sclk_counter == 1 )
                    MOSI <= read[6];
                else if ( sclk_counter == 2 )
                    MOSI <= read[5];   
                else if ( sclk_counter == 3 )
                    MOSI <= read[4];
                else if ( sclk_counter == 4 )
                    MOSI <= read[3]; 
                else if ( sclk_counter == 5 )
                    MOSI <= read[2];
                else if ( sclk_counter == 6 )
                    MOSI <= read[1]; 
                else if ( sclk_counter == 7 )
                    MOSI <= read[0];

                else if ( sclk_counter == 8 )
                    MOSI <= init_addr[7];
                else if ( sclk_counter == 9 )
                    MOSI <= init_addr[6];
                else if ( sclk_counter == 10 )
                    MOSI <= init_addr[5];   
                else if ( sclk_counter == 11 )
                    MOSI <= init_addr[4];
                else if ( sclk_counter == 12 )
                    MOSI <= init_addr[3]; 
                else if ( sclk_counter == 13 )
                    MOSI <= init_addr[2];
                else if ( sclk_counter == 14 )
                    MOSI <= init_addr[1]; 
                else if ( sclk_counter == 15 )
                    MOSI <= init_addr[0];

                else if ( sclk_counter == 16 )
                    y_data[7] <= MISO;
                else if ( sclk_counter == 17 )
                    y_data[6] <= MISO;
                else if ( sclk_counter == 18 )
                    y_data[5] <= MISO;
                else if ( sclk_counter == 19 )
                    y_data[4] <= MISO;
                else if ( sclk_counter == 20 )
                    y_data[3] <= MISO;
                else if ( sclk_counter == 21 )
                    y_data[2] <= MISO;
                else if ( sclk_counter == 22 )
                    y_data[1] <= MISO;
                else if ( sclk_counter == 23 )
                    y_data[0] <= MISO;    

                else if ( sclk_counter == 24 )
                    y_data[15] <= MISO;
                else if ( sclk_counter == 25 )
                    y_data[14] <= MISO;
                else if ( sclk_counter == 26 )
                    y_data[13] <= MISO;
                else if ( sclk_counter == 27 )
                    y_data[12] <= MISO;
                else if ( sclk_counter == 28 )
                    y_data[11] <= MISO;
                else if ( sclk_counter == 29 )
                    y_data[10] <= MISO;
                else if ( sclk_counter == 30 )
                    y_data[9] <= MISO;
                else if ( sclk_counter == 31 )
                    y_data[8] <= MISO;

                else if ( sclk_counter == 32 )
                    z_data[7] <= MISO;
                else if ( sclk_counter == 33 )
                    z_data[6] <= MISO;
                else if ( sclk_counter == 34 )
                    z_data[5] <= MISO;
                else if ( sclk_counter == 35 )
                    z_data[4] <= MISO;
                else if ( sclk_counter == 36 )
                    z_data[3] <= MISO;
                else if ( sclk_counter == 37 )
                    z_data[2] <= MISO;
                else if ( sclk_counter == 38 )
                    z_data[1] <= MISO;
                else if ( sclk_counter == 39 )
                    z_data[0] <= MISO;    

                else if ( sclk_counter == 40 )
                    z_data[15] <= MISO;
                else if ( sclk_counter == 41 )
                    z_data[14] <= MISO;
                else if ( sclk_counter == 42 )
                    z_data[13] <= MISO;
                else if ( sclk_counter == 43 )
                    z_data[12] <= MISO;
                else if ( sclk_counter == 44 )
                    z_data[11] <= MISO;
                else if ( sclk_counter == 45 )
                    z_data[10] <= MISO;
                else if ( sclk_counter == 46 )
                    z_data[9] <= MISO;
                else if ( sclk_counter == 47 )
                    z_data[8] <= MISO;
            end   
            else
                sclk_counter <= 0;

        end

    end

endmodule