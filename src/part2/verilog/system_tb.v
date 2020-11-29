/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

`timescale 1 ns / 1 ps

`define Y_LSB 8'h10
`define Y_MSB 8'h11
`define Z_LSB 8'h12
`define Z_MSB 8'h13


module system_tb;
	reg clk = 1;
	always #5 clk = ~clk;

	reg resetn = 0;
	initial begin
		if ($test$plusargs("vcd")) begin
			$dumpfile("system.vcd");
			$dumpvars(0, system_tb);
		end
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
	reg [7:0] reg_output;

	reg [7:0] read  = 8'h0B;
	reg [7:0] write = 8'h0A;
	reg [7:0] read_write;
	
	reg [4:0] counter = 0;


	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_byte_en(out_byte_en),
	    .INT1       ( INT1      ),
	    .INT2       ( INT2      ),
	    .MISO       ( MISO      ),
	    .MOSI       ( MOSI      ),
	    .CS         ( CS        ), 
	    .SCLK       ( SCLK      )
	);


	always @(*)
	begin
		if (counter == 16)
		begin
			if      ( axis_addr == `Y_LSB ) reg_output = 5; 
			else if ( axis_addr == `Y_MSB ) reg_output = 10;
			else if ( axis_addr == `Z_LSB ) reg_output = 15;
			else if ( axis_addr == `Z_MSB ) reg_output = 20;
		end
	end


	always @( posedge SCLK )
	begin
		if ( CS == 0 )
		begin	
			if (counter != 24)
				counter = counter+1;
		end

		else
			counter = 0;
	end


	always @(*)
	begin
		if (counter==1)
		begin
			read_write [7] = MOSI;
		end
		else if (counter==2)
		begin
			read_write [6] = MOSI;
		end
		else if (counter==3)
		begin
			read_write [5] = MOSI;
		end
		else if (counter==4)
		begin
			read_write [4] = MOSI;
		end
		else if (counter==5)
		begin
			read_write [3] = MOSI;
		end
		else if (counter==6)
		begin
			read_write [2] = MOSI;
		end
		else if (counter==7)
		begin
			read_write [1] = MOSI;
		end
		else if (counter==8)
		begin
			read_write [0] = MOSI;
		end

		else if (counter==9)
		begin
			axis_addr [7] = MOSI;
		end
		else if (counter==10)
		begin
			axis_addr [6] = MOSI;
		end
		else if (counter==11)
		begin
			axis_addr [5] = MOSI;
		end
		else if (counter==12)
		begin
			axis_addr [4] = MOSI;
		end
		else if (counter==13)
		begin
			axis_addr [3] = MOSI;
		end
		else if (counter==14)
		begin
			axis_addr [2] = MOSI;
		end
		else if (counter==15)
		begin
			axis_addr [1] = MOSI;
		end
		else if (counter==16)
		begin
			axis_addr [0] = MOSI;
			MISO = ( read_write == read )? reg_output[7]:0;
		end



		else if (counter==17)
		begin
			MISO = ( read_write == read )? reg_output[6]:0;
		end
		else if (counter==18)
		begin
			MISO = ( read_write == read )? reg_output[5]:0;
		end
		else if (counter==19)
		begin
			MISO = ( read_write == read )? reg_output[4]:0;
		end
		else if (counter==20)
		begin
			MISO = ( read_write == read )? reg_output[3]:0;
		end
		else if (counter==21)
		begin
			MISO = ( read_write == read )? reg_output[2]:0;
		end
		else if (counter==22)
		begin
			MISO = ( read_write == read )? reg_output[1]:0;
		end
		else if (counter==23)
		begin
			MISO = ( read_write == read )? reg_output[0]:0;
		end
		
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
