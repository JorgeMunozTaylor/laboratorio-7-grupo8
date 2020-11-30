/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

`timescale 1 ns / 1 ps

module system (
	input            clk,
	input            resetn,
	output           trap,
	output reg [7:0] out_byte,
	output reg       out_byte_en,
	output     [7:0] catodes,
	output     [7:0] anodes,

	// Accelerometer interface
	input INT1,
	input INT2,
	input MISO,

	output MOSI,
	output CS,  //Active low
	output SCLK
);
	// set this to 0 for better timing but less performance/MHz
	parameter FAST_MEMORY = 1;

	// 4096 32bit words = 16kB memory
	parameter MEM_SIZE = 4096;

	wire mem_valid;
	wire mem_instr;
	reg mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	reg [31:0] mem_rdata;

	wire mem_la_read;
	wire mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [3:0] mem_la_wstrb;

	picorv32 #(
		// Enable the irq handler of picorv32 core
		.ENABLE_IRQ       (1),
		.LATCHED_IRQ      (0),
		.ENABLE_IRQ_QREGS (0),
		.PROGADDR_IRQ     (32'h0000_0010)
	)	
	picorv32_core (
		.clk         (clk         ),
		.resetn      (resetn      ),
		.trap        (trap        ),
		.mem_valid   (mem_valid   ),
		.mem_instr   (mem_instr   ),
		.mem_ready   (mem_ready   ),
		.mem_addr    (mem_addr    ),
		.mem_wdata   (mem_wdata   ),
		.mem_wstrb   (mem_wstrb   ),
		.mem_rdata   (mem_rdata   ),
		.mem_la_read (mem_la_read ),
		.mem_la_write(mem_la_write),
		.mem_la_addr (mem_la_addr ),
		.mem_la_wdata(mem_la_wdata),
		.mem_la_wstrb(mem_la_wstrb)
		//.irq		 ( {28'b0, irq, 3'b0} )
	);

	reg [31:0] memory [0:MEM_SIZE-1];

`ifdef SYNTHESIS
    initial $readmemh("../firmware/firmware.hex", memory);
`else
	initial $readmemh("firmware.hex", memory);
`endif

	reg [31:0] m_read_data;
	reg m_read_en;


	// ******************************************
	// Store the num to display in the nexys 4 DDR (LEDS or 7-segment ).
	reg [31:0] num_to_display;

	seven_segment_hex DISPLAYS_HEX
	(
		.clk            ( clk            ), // Main clock of the circuit.
		.num_to_display ( num_to_display ), // 32 bit number that will show on the displays.
		.reset          ( resetn         ), // Reset the circuit to 0's.
		.catodes        ( catodes        ), // 7 segment code of digit for the display.
		.anodes         ( anodes         )  // Select display that turn on.
	);

	// ******************************************
	// Accelerometer reader module instantiation
	// ******************************************

    wire MISO;
    wire MOSI;
    wire SCLK; 
    wire CS;  // Chip select, select the slave
    wire [15:0] Y_value;
    wire [15:0] Z_value;

	accelerometer_reader ACCELEROMETER
	(
		.clk     ( clk     ),
		.reset   ( resetn  ),
		.MISO    ( MISO    ),
		.MOSI    ( MOSI    ),
		.SCLK    ( SCLK    ), 
		.CS      ( CS      ),  
		.Y_value ( Y_value ),
		.Z_value ( Z_value )
	);
	// ******************************************


	generate if (FAST_MEMORY) begin
		always @(posedge clk) begin
			mem_ready <= 1;
			out_byte_en <= 0;
			mem_rdata <= memory[mem_la_addr >> 2];
			if (mem_la_write && (mem_la_addr >> 2) < MEM_SIZE) begin
				if (mem_la_wstrb[0]) memory[mem_la_addr >> 2][ 7: 0] <= mem_la_wdata[ 7: 0];
				if (mem_la_wstrb[1]) memory[mem_la_addr >> 2][15: 8] <= mem_la_wdata[15: 8];
				if (mem_la_wstrb[2]) memory[mem_la_addr >> 2][23:16] <= mem_la_wdata[23:16];
				if (mem_la_wstrb[3]) memory[mem_la_addr >> 2][31:24] <= mem_la_wdata[31:24];
			end
			else

			// Put the irq count on the outbyte output
			if (mem_la_write && mem_la_addr == 32'h1000_0000) begin
				out_byte_en    <= 1;
				out_byte 	   <= mem_la_wdata;
				num_to_display <= mem_la_wdata;
			end

			else if (mem_la_read && mem_la_addr == 32'h2000_0000 && CS) begin
				mem_rdata <= Y_value;
			end

			else if (mem_la_read && mem_la_addr == 32'h3000_0000 && CS) begin
				mem_rdata <= Z_value;
			end
		end
	end else begin
		always @(posedge clk) begin
			m_read_en <= 0;
			mem_ready <= mem_valid && !mem_ready && m_read_en;

			m_read_data <= memory[mem_addr >> 2];
			mem_rdata <= m_read_data;

			out_byte_en <= 0;

			(* parallel_case *)
			case (1)
				mem_valid && !mem_ready && !mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					m_read_en <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && (mem_addr >> 2) < MEM_SIZE: begin
					if (mem_wstrb[0]) memory[mem_addr >> 2][ 7: 0] <= mem_wdata[ 7: 0];
					if (mem_wstrb[1]) memory[mem_addr >> 2][15: 8] <= mem_wdata[15: 8];
					if (mem_wstrb[2]) memory[mem_addr >> 2][23:16] <= mem_wdata[23:16];
					if (mem_wstrb[3]) memory[mem_addr >> 2][31:24] <= mem_wdata[31:24];
					mem_ready <= 1;
				end
				mem_valid && !mem_ready && |mem_wstrb && mem_addr == 32'h1000_0000: begin
					out_byte_en <= 1;
					out_byte <= mem_wdata;
					mem_ready <= 1;
				end
			endcase
		end
	end endgenerate
endmodule
