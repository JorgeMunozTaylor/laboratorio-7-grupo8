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


module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;

	reg resetn = 0;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end

		resetn <= 1;
	end

	wire trap;
	wire [7:0] out_byte;
	wire out_byte_en;
	wire INT1;
	wire INT2;
	reg  MISO;
	wire MOSI;
	wire CS;  //Active low
	wire SCLK;

    // Reg address of the accelerometer Y and Z axis
	reg [7:0] axis_addr; //Store the address
	reg [7:0] accelerometer_registers [0:19]; //Emulate some accelerometer regs

	reg [7:0] read  = `READ;
	reg [7:0] write = `WRITE;
	reg [7:0] read_write;
	reg [7:0] master_instruction;
	
	reg [5:0] counter = 0;
	

	system uut (
		.clk        ( clk        ),
		.resetn     ( resetn     ),
		.trap       ( trap       ),
		.out_byte   ( out_byte   ),
		.out_byte_en( out_byte_en),
	    .INT1       ( INT1       ),
	    .INT2       ( INT2       ),
	    .MISO       ( MISO       ),
	    .MOSI       ( MOSI       ),
	    .CS         ( CS         ), 
	    .SCLK       ( SCLK       )
	);

	/* Define accelerometer registers values */
	initial
	begin
		accelerometer_registers [0 ] = 0;
		accelerometer_registers [1 ] = 1;
		accelerometer_registers [2 ] = 2;
		accelerometer_registers [3 ] = 3;
		accelerometer_registers [4 ] = 4;
		accelerometer_registers [5 ] = 5;
		accelerometer_registers [6 ] = 6;
		accelerometer_registers [7 ] = 7;
		accelerometer_registers [8 ] = 8;
		accelerometer_registers [9 ] = 9;
		accelerometer_registers [10] = 10;
		accelerometer_registers [11] = 11;
		accelerometer_registers [12] = 12;
		accelerometer_registers [13] = 13;
		accelerometer_registers [14] = 14;
		accelerometer_registers [15] = 15;
		accelerometer_registers [16] = 16;
		accelerometer_registers [17] = 17;
		accelerometer_registers [18] = 18;
		accelerometer_registers [19] = 19;
	end

	/**/
	always @( posedge SCLK )
	begin
		if ( CS == 0 )
		begin	
			if (read_write != write ) 
			begin
				if (counter != 48)
					counter = counter+1;
			end

			else
			begin
				if (counter != 24)
					counter = counter+1;				
			end
		end

		else
			counter = 0;

		/**/
		if (counter==1)
			read_write [7] <= MOSI;
		
		else if (counter==2)
			read_write [6] = MOSI;
		
		else if (counter==3)
			read_write [5] = MOSI;
		
		else if (counter==4)
			read_write [4] = MOSI;
		
		else if (counter==5)
			read_write [3] = MOSI;
		
		else if (counter==6)
			read_write [2] = MOSI;
		
		else if (counter==7)
			read_write [1] = MOSI;
		
		else if (counter==8)
			read_write [0] = MOSI;
		
		/*******************************************/
		else if (counter==9)
			axis_addr [7] = MOSI;
		
		else if (counter==10)
			axis_addr [6] = MOSI;
		
		else if (counter==11)
			axis_addr [5] = MOSI;
		
		else if (counter==12)
			axis_addr [4] = MOSI;
		
		else if (counter==13)
			axis_addr [3] = MOSI;
		
		else if (counter==14)
			axis_addr [2] = MOSI;
		
		else if (counter==15)
			axis_addr [1] = MOSI;
		
		else if ( counter==16 )
			axis_addr [0] = MOSI;
		
	end


	/**/
	always @( negedge SCLK )
	begin	
		/*******************************************/
		if ( counter==17 )
		begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][7];
			else master_instruction [7] = MOSI; 
		end

		else if (counter==18) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][6];
			else master_instruction [6] = MOSI;
		end
		
		else if (counter==19) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][5];
			else master_instruction [5] = MOSI;
		end
		
		else if (counter==20) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][4];
			else master_instruction [4] = MOSI;
		end

		else if (counter==21) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][3];
			else master_instruction [3] = MOSI;
		end

		else if (counter==22) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][2];
			else master_instruction [2] = MOSI;
		end

		else if (counter==23) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][1];
			else master_instruction [1] = MOSI;
		end

		else if (counter==24) begin
			if( read_write == read ) MISO = accelerometer_registers [axis_addr][0];
			else master_instruction [0] = MOSI;
		end
	
		/*******************************************/
		else if (counter==25) begin
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][7]:0;
		end

		else if (counter==26)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][6]:0;
		
		else if (counter==27)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][5]:0;
		
		else if (counter==28)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][4]:0;
		
		else if (counter==29)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][3]:0;
		
		else if (counter==30)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][2]:0;
		
		else if (counter==31)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][1]:0;
		
		else if (counter==32)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+1][0]:0;

		/*******************************************/
		else if (counter==33)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][7]:0;
		
		else if (counter==34)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][6]:0;
		
		else if (counter==35)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][5]:0;
		
		else if (counter==36)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][4]:0;
		
		else if (counter==37)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][3]:0;
		
		else if (counter==38)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][2]:0;
		
		else if (counter==39)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][1]:0;
		
		else if (counter==40)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+2][0]:0;

		/*******************************************/
		else if (counter==41)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][7]:0;
		
		else if (counter==42)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][6]:0;
		
		else if (counter==43)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][5]:0;
		
		else if (counter==44)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][4]:0;
		
		else if (counter==45)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][3]:0;
		
		else if (counter==46)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][2]:0;
		
		else if (counter==47)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][1]:0;
		
		else if (counter==48)
			MISO = ( read_write == read )? accelerometer_registers [axis_addr+3][0]:0;
	end



	always @(posedge clk) begin
		if (resetn && out_byte_en) begin
			$write("%c", out_byte);
			$fflush;
		end
		if (resetn && trap) begin
			$finish;
		end
	end
endmodule
