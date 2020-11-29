/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

`timescale 1 ns / 1 ps

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
	wire MISO;
	wire MOSI;
	wire CS;  //Active low
	wire SCLK;

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
