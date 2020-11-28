/*
    Created by Jorge Munoz Taylor
    A53863
    Project 7
    Digital circuit laboratory I
    II-2020
*/


// Max number that can be displayed on the 7 segment displays.
`define MAX_NUM_TO_DISPLAY 32'b1111_1111_1111_1111_1111_1111_1111_1111 

// Delay for refresh the 7 segment displays.
`define LIMIT 100000


/*
    7 segment Hexadecimal.
*/
module seven_segment_hex 
(
    input clk,                  // Main clock of the circuit.
    input [31:0] num_to_display,// 32 bit number that will show on the displays.
    input reset,                // Reset the circuit to 0's.

    output reg [7:0] catodes,   // 7 segment code of digit for the display.
    output reg [7:0] anodes     // Select display that turn on.
);
    
    wire    [7:0]  number_catodes [7:0]; // Wire used to connect the output catodes with the correct code.
    integer        num_counter        = 0; // Counter used to activate every display, one by one.
    integer        catodes_to_display = 0; // Store the code of the catodes that will be ON.
    reg     [7:0]  an_init            = 8'b1111_1110; // Initial anode value to display.


    always @(posedge clk)
    begin

        if ( num_counter == `LIMIT )
        begin
           
            // Assign the correct code of the digit and anode to show.
            catodes = number_catodes[ catodes_to_display ];
            anodes  = an_init;

            // If the number to show need less displays turn them off.
            if ( num_to_display < 16)  anodes [7:1] = 7'b1111111;
            if ( num_to_display < 256) anodes [7:2] = 6'b111111;
            if ( num_to_display < 4096) anodes [7:3] = 5'b11111;
            if ( num_to_display < 65536) anodes [7:4] = 4'b1111;
            if ( num_to_display < 1048576) anodes [7:5] = 3'b111;
            if ( num_to_display < 16777216) anodes [7:6] = 2'b11;
            if ( num_to_display < 268435456) anodes [7] = 1'b1;

            // Circular left shift.
            an_init = { an_init [6:0] , an_init [7] };

            // If the catodes_to_display is 7 assign 0 to it.
            if ( catodes_to_display == 7 ) catodes_to_display = 0; 
            else                           catodes_to_display = catodes_to_display+1;
            
            // Re-init the num_counter (delay).
            num_counter = 0;

        end

        else num_counter = num_counter+1;

    end


    // Here the BCD stream is traduce to a stream of 7-segment codes.
    bcd_to_7seg DISPLAY_7 ( .BCD ( num_to_display [31:28] ), .number_catodes ( number_catodes[7] ) );
    bcd_to_7seg DISPLAY_6 ( .BCD ( num_to_display [27:24] ), .number_catodes ( number_catodes[6] ) );
    bcd_to_7seg DISPLAY_5 ( .BCD ( num_to_display [23:20] ), .number_catodes ( number_catodes[5] ) );
    bcd_to_7seg DISPLAY_4 ( .BCD ( num_to_display [19:16] ), .number_catodes ( number_catodes[4] ) );
    bcd_to_7seg DISPLAY_3 ( .BCD ( num_to_display [15:12] ), .number_catodes ( number_catodes[3] ) );
    bcd_to_7seg DISPLAY_2 ( .BCD ( num_to_display [11:8]  ), .number_catodes ( number_catodes[2] ) );
    bcd_to_7seg DISPLAY_1 ( .BCD ( num_to_display [7:4]   ), .number_catodes ( number_catodes[1] ) );
    bcd_to_7seg DISPLAY_0 ( .BCD ( num_to_display [3:0]   ), .number_catodes ( number_catodes[0] ) );

endmodule



/*
    Convert a BCD number to a 7-segment one.
*/
module bcd_to_7seg
(
    input  [3:0] BCD,               // BCD number that will be converted to a 7-segment one.
    output reg [7:0] number_catodes // Return catodes value
);

    // Return the 7-segment code of a digit from 0 to F.
    always @(BCD)
        case( BCD )      
            4'b0000: number_catodes = 8'b1100_0000; // C0 
            4'b0001: number_catodes = 8'b1111_1001; // F9
            4'b0010: number_catodes = 8'b1010_0100; // A4
            4'b0011: number_catodes = 8'b1011_0000; // 70
            4'b0100: number_catodes = 8'b1001_1001; // 99
            4'b0101: number_catodes = 8'b1001_0010; // 92
            4'b0110: number_catodes = 8'b1000_0010; // 82
            4'b0111: number_catodes = 8'b1111_1000; // F8
            4'b1000: number_catodes = 8'b1000_0000; // 80
            4'b1001: number_catodes = 8'b1001_0000; // 90

            // For Hex numbers
            4'b1010: number_catodes = 8'b1000_1000; // 10
            4'b1011: number_catodes = 8'b1000_0011; // 11
            4'b1100: number_catodes = 8'b1100_0110; // 12 
            4'b1101: number_catodes = 8'b1010_0001; // 13
            4'b1110: number_catodes = 8'b1000_0110; // 14
            4'b1111: number_catodes = 8'b1000_1110; // 15
            default: number_catodes = 8'b1000_0000; // 80         
        endcase      
        
endmodule