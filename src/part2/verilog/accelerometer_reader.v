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
`define SOFT_RESET_REG 8'h1F
`define POWER_CTL_REG  8'h2D

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

    initial SCLK = 0;
    initial CS   = 1;

    // Reg address of the accelerometer Y and Z axis
    reg [7:0 ] init_addr      = `Y_LSB;
    reg [7:0 ] read           = `READ;
    reg [7:0 ] write          = `WRITE;
    reg [5:0 ] sclk_counter   = 0;
    reg [15:0] y_data         = 0;
    reg [15:0] z_data         = 0;
    reg [2:0 ] selector       = 3'b000; 
    reg [7:0 ] soft_reset_reg = `SOFT_RESET_REG;
    reg [7:0 ] power_ctl_reg  = `POWER_CTL_REG;
    reg        retain         = 0; // Used for retain CS to 0 after CS fall
    reg [1:0]  retain2        = 0;
    reg        init_cs        = 0; // Used only on power up to mantain CS=1 for one clk cycle


    /* CS management */
    always @( posedge clk )
    begin
        if ( init_cs == 1 )
        begin
            if ( CS == 1 ) CS <= 0; 
            if ( retain2 == 2) CS = 1;
        end

        else
            init_cs <= 1;
    end

    /* SCLK management */
    always @( posedge clk )
    begin
        if ( selector != 3'b100 )
        begin
            if ( CS == 0 && sclk_counter != 24 )
                SCLK <= !SCLK;

            else
                SCLK <= 0;
        end

        else begin
            if ( CS == 0 && sclk_counter != 48 )
                SCLK <= !SCLK;

            else
                SCLK <= 0;
        end
    end

    /* Y_value and Z_value management */
    always @( posedge CS )
    begin
        Y_value <= y_data;
        Z_value <= z_data;
    end

    /* selector mangement */
    always @( negedge CS )
    begin
        if ( selector == 3'b000 ) selector <= 3'b001; 
        if ( selector == 3'b001 ) selector <= 3'b010;
        if ( selector == 3'b010 ) selector <= 3'b100;
    end // Always end


    /* retain2 management */
    always @( posedge clk )
    begin
        if ( selector != 3'b100)
        begin
            if ( sclk_counter == 23 ) retain2 <= retain2+1;
            else retain2 <= 0;
        end        
        else
        begin
            if ( sclk_counter == 47 ) retain2 <= retain2+1;
            else retain2 <= 0;
        end

        if ( retain2 == 2 ) retain2 <= 0;
    end


    /* sclk_counter management */
    always @( posedge clk )
    begin

        // Soft reset and measurement modes
        if ( selector != 3'b100 )
        begin
            if ( SCLK == 1 ) sclk_counter <= sclk_counter+1;
            if ( sclk_counter == 24 ) sclk_counter <= 0;
        end

        // Measure Y and Z axis
        else if ( selector == 3'b100 )
        begin
            if ( SCLK == 1 ) begin
                if ( retain == 1 && sclk_counter == 24 ) sclk_counter <= 0;
                else sclk_counter <= sclk_counter+1;
            end
            if ( sclk_counter == 48 ) sclk_counter <= 0;
        end

    end // Always end














    /* */
    always @( posedge SCLK )
    begin
            /* write */
        if ( selector != 3'b100 )
        begin
            if ( sclk_counter == 0 )
                MOSI <= write[7];
            else if ( sclk_counter == 1 )
                MOSI <= write[6];
            else if ( sclk_counter == 2 )
                MOSI <= write[5];   
            else if ( sclk_counter == 3 )
                MOSI <= write[4];
            else if ( sclk_counter == 4 )
                MOSI <= write[3]; 
            else if ( sclk_counter == 5 )
                MOSI <= write[2];
            else if ( sclk_counter == 6 )
                MOSI <= write[1]; 
            else if ( sclk_counter == 7 )
                MOSI <= write[0];

            else if ( sclk_counter == 8 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[7]:power_ctl_reg[7];
            else if ( sclk_counter == 9 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[6]:power_ctl_reg[6];
            else if ( sclk_counter == 10 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[5]:power_ctl_reg[5];   
            else if ( sclk_counter == 11 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[4]:power_ctl_reg[4];
            else if ( sclk_counter == 12 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[3]:power_ctl_reg[3]; 
            else if ( sclk_counter == 13 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[2]:power_ctl_reg[2];
            else if ( sclk_counter == 14 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[1]:power_ctl_reg[1]; 
            else if ( sclk_counter == 15 )
                MOSI <= ( selector==3'b001 )? soft_reset_reg[0]:power_ctl_reg[0];

            else if ( sclk_counter == 16 )
                MOSI <= 0;
            else if ( sclk_counter == 17 )
                MOSI <= ( selector==3'b001 )? 1:0;
            else if ( sclk_counter == 18 )
                MOSI <= 0;
            else if ( sclk_counter == 19 )
                MOSI <= ( selector==3'b001 )? 1:0;
            else if ( sclk_counter == 20 )
                MOSI <= 0;
            else if ( sclk_counter == 21 )
                MOSI <= 0;
            else if ( sclk_counter == 22 )
                MOSI <= 1;
            else if ( sclk_counter == 23 )
                MOSI <= 0;                    
        end

        /* read */
        else if ( selector == 3'b100 )
        begin
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
        end
    end // Always end


    /* Data read from accelerometer */
    always @( negedge SCLK )
    begin
        if ( selector == 3'b100)
        begin
                if ( sclk_counter == 16 )
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
    end // Always end

endmodule