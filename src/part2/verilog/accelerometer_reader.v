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
    reg [7:0] axis_addr = 8'h0F; // 0x10-1

    reg [7:0] read  = `READ;
    reg [7:0] write = `WRITE;

    reg        counter      = 0;
    reg [4:0 ] sclk_counter = 0;
    reg [15:0] y_data;
    reg [15:0] z_data;
    reg [7:0 ] temp_data;
    

    /**/
    always @(CS)
    begin
        if (CS == 1)
        begin
            if ( axis_addr != `Z_MSB )
                axis_addr <= axis_addr+1;
            else
                axis_addr <= `Y_LSB;
        end
    end


    /**/
    always @(posedge clk)
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


    /**/
    always @( posedge clk )
    begin
        if ( CS == 0 )
            SCLK <= !SCLK;
        else
            SCLK <= 1;
    end


    /**/
    always @( CS )
    begin
        case ( axis_addr )
            `Y_LSB: y_data [7:0 ] = temp_data; 
            `Y_MSB: y_data [15:8] = temp_data;
            `Z_LSB: z_data [7:0 ] = temp_data;
            `Z_MSB: z_data [15:8] = temp_data;
            default: y_data = 0;
        endcase
    end


    /**/
    always @( posedge CS )
    begin
        if ( axis_addr == `Y_MSB)
            Y_value = y_data;

        else if ( axis_addr == `Z_MSB)
            Z_value = z_data;
    end


    /**/
    always @( posedge SCLK )
    begin
        if ( CS == 0 && sclk_counter != 24 )
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
                MOSI <= axis_addr[7];
            else if ( sclk_counter == 9 )
                MOSI <= axis_addr[6];
            else if ( sclk_counter == 10 )
                MOSI <= axis_addr[5];   
            else if ( sclk_counter == 11 )
                MOSI <= axis_addr[4];
            else if ( sclk_counter == 12 )
                MOSI <= axis_addr[3]; 
            else if ( sclk_counter == 13 )
                MOSI <= axis_addr[2];
            else if ( sclk_counter == 14 )
                MOSI <= axis_addr[1]; 
            else if ( sclk_counter == 15 )
                MOSI <= axis_addr[0];

            else if ( sclk_counter == 16 )
                temp_data[7] <= MISO;
            else if ( sclk_counter == 17 )
                temp_data[6] <= MISO;
            else if ( sclk_counter == 18 )
                temp_data[5] <= MISO;
            else if ( sclk_counter == 19 )
                temp_data[4] <= MISO;
            else if ( sclk_counter == 20 )
                temp_data[3] <= MISO;
            else if ( sclk_counter == 21 )
                temp_data[2] <= MISO;
            else if ( sclk_counter == 22 )
                temp_data[1] <= MISO;
            else if ( sclk_counter == 23 )
                temp_data[0] <= MISO;    
        end
            
        else
            sclk_counter <= 0;
    end

endmodule