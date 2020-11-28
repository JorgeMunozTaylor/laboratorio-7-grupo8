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

		// Put 8 irq on the CPU
		repeat (100) @(posedge clk);
		resetn <= 1;
		repeat (1000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
		repeat (5000) @(posedge clk);
		irq <= 1;
		repeat (10) @(posedge clk);
		irq <= 0;
	end

	wire trap;
	wire [7:0] out_byte;
	wire out_byte_en;
	reg irq = 0; // Reg that set a IRQ.



	system uut (
		.clk        (clk        ),
		.resetn     (resetn     ),
		.irq        (irq        ),
		.trap       (trap       ),
		.out_byte   (out_byte   ),
		.out_byte_en(out_byte_en)
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
