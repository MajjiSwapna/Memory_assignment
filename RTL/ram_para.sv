// =============================================================================
//  ram_para.sv  —  Parameterized Dual-Port RAM with Hamming ECC
//
//  FUNCTION
//    Implements a parameterized dual-port RAM with independent read and
//    write access on both ports. Data is protected using Hamming Error
//    Correcting Code (ECC), where data is encoded before storage and
//    decoded during read operations.
//
//  ARCHITECTURE
//    • Input data from both ports is first passed through a Hamming
//      encoder before being written into memory.
//    • Encoded data is stored in an internal RAM array.
//    • During read operations, encoded data is retrieved from memory
//      and passed through a Hamming decoder to reconstruct the original
//      data.
//    • Read and write addresses, data, enables, and control signals are
//      pipelined to support configurable READ_LATENCY and WRITE_LATENCY.
//
//  KEY FEATURES
//    • Parameterized data width and address width
//    • Independent dual-port read/write operation
//    • Configurable read and write latency
//    • Built-in Hamming ECC for data protection
//    • Address, data, and control signal pipelining
//    • Simultaneous read/write support on both ports
//    • Write collision prevention using external error signal
//
//  INTERFACE
//    i_clka, i_clkb  – Independent clocks for Port-A and Port-B
//    i_ena, i_enb    – Port enable signals
//    i_wea, i_web    – Port write enable signals
//    i_addra, i_addrb– Read/Write addresses
//    i_dina, i_dinb  – Input data
//    error           – Write collision/error indicator
//    o_douta, o_doutb– Decoded read data outputs
//
//  NOTE
//    The module stores Hamming-encoded data internally rather than raw
//    user data. The encoder operates during writes, while the decoder
//    reconstructs the original data during reads. Pipeline registers are
//    used to match the configured memory latency and support high-speed
//    operation.
// =============================================================================


`include "hamming_dec.sv"                  // Includes Hamming decoder module
`include "hamming_enc.sv"                  // Includes Hamming encoder module
module ram_para #(
	parameter READ_LATENCY = 2,
	parameter WRITE_LATENCY = 2,
	parameter DW = 8,                       //data width
	parameter ADDR = $clog2(DW))            //address width
	(
		input logic error,input logic [DW-1 :0]i_dina,[DW-1:0]i_dinb,          // Error signal and input data for Port A & Port B
		input logic [ADDR-1 :0]i_addra,[ADDR-1 :0]i_addrb,                     // Address inputs for Port A & Port B
		input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,                     // Clock, enable and write enable signals
		output logic [DW-1:0]o_douta,[DW-1:0]o_doutb                           // Read data outputs
		);

		localparam LOCATION = 8;
		localparam PARITY_WIDTH = $clog2(DW + $clog2(DW) + 1);                 //number of parity bits
		localparam TOTAL_WIDTH = DW + PARITY_WIDTH;                            //total encoded bit width


		logic [ADDR-1:0] write_a [WRITE_LATENCY-1:0];                          //parameterized pipeline registers for write address
    	logic [TOTAL_WIDTH-1:0] data_a [WRITE_LATENCY-1:0];                    // Pipeline registers for encoded Port A write data
	    logic [TOTAL_WIDTH-1:0] data_b [WRITE_LATENCY-1:0];                    // Pipeline registers for encoded Port B write data
	    logic [ADDR-1:0] write_b [WRITE_LATENCY-1:0];                          //parameterized pipeline registers for write address
	    logic [ADDR-1:0] read_a [READ_LATENCY-1:0];                            //pipelined registers for Port A read address
	    logic [ADDR-1:0] read_b [READ_LATENCY-1:0];                            //pipelined registers for Port B read address
        logic error_sig [WRITE_LATENCY-1:0];                                   //pipelined error signal

		//-------------------------------------------------------------------------------
		//
		// pipelined write path registers of enable and write_enable for Port
		// A and port B
		//
		//-------------------------------------------------------------------------------

	    logic wea_w [WRITE_LATENCY-1:0];
		logic ena_w [WRITE_LATENCY-1:0];
		logic web_w [WRITE_LATENCY-1:0];
		logic enb_w [WRITE_LATENCY-1:0];

		//------------------------------------------------------------------------------
		//
		//pipelined read path for enable and write_enable of read operation of
		//Port A and Port B
		//
		//------------------------------------------------------------------------------

		logic wea_r [READ_LATENCY-1:0];
		logic ena_r [READ_LATENCY-1:0];
		logic enb_r [READ_LATENCY-1:0];
		logic web_r [READ_LATENCY-1:0];

	    reg [TOTAL_WIDTH-1:0] ram [LOCATION-1:0];                  //RAM module storing hamming code data and numbe rof locations

		//------------------------------------------------------------------------------
		//
		//encoded data from hamming code encoder are supplied to hamming code
		//decoder for both Port A and Port B
		//
		//------------------------------------------------------------------------------
      	logic [TOTAL_WIDTH-1:0] i1a_ham;
	    logic [TOTAL_WIDTH-1:0] i2a_ham;
	    logic [TOTAL_WIDTH-1:0] i1b_ham;
	    logic [TOTAL_WIDTH-1:0] i2b_ham;

	    hamming_encoder #(DW,1) h1a(i_dina,i1a_ham);     //hamming encoder for Port A
	    hamming_decoder #(DW,1) h2a(i2a_ham,o_douta);    //hamming decoder for Port A
	    hamming_encoder #(DW,1) h1b(i_dinb,i1b_ham);     //hamming encoder for port B
	    hamming_decoder #(DW,1) h2b(i2b_ham,o_doutb);    //hamming decoder for port B

		//pipelining all input signals of Port A for write path registers

		always_ff @(posedge i_clka) begin
			write_a[0] <= i_addra;
			data_a[0] <= i1a_ham;
			error_sig[0] <= error;
			wea_w[0] <= i_wea;
			ena_w[0] <= i_ena;
			for(int i=1;i < WRITE_LATENCY;i++) begin
				write_a[i] <= write_a[i-1];
				data_a[i] <= data_a[i-1];
				error_sig[i] <= error_sig[i-1];
				wea_w[i] <= wea_w[i-1];
				ena_w[i] <= ena_w[i-1];
			end
		end

        //pipelining all input signals of Port B for write path registers

		always_ff @(posedge i_clkb) begin
			write_b[0] <= i_addrb;
			data_b[0] <= i1b_ham;
			error_sig[0] <= error;
			web_w[0] <= i_web;
			enb_w[0] <= i_enb;
			for(int i=1;i < WRITE_LATENCY;i++) begin
				write_b[i] <= write_b[i-1];
				data_b[i] <= data_b[i-1];
				error_sig[i] <= error_sig[i-1];
				web_w[i] <= web_w[i-1];
				enb_w[i] <= enb_w[i-1];
			end
		end

		//to generate write operation when WRITE_LATENCY is 1 for both port A and port B

		generate
		if(WRITE_LATENCY == 1) begin :wrt_l1
			always_ff @(posedge i_clka) begin
				if(i_wea && i_ena && !error) begin
					ram[i_addra] <= i1a_ham;
				end
			end

			always_ff @(posedge i_clkb) begin
				if(i_web && i_enb && !error) begin
					ram[i_addrb] <= i1b_ham;
				end
			end
		end
		endgenerate

		//write operation when WRITE_LATENCY is greater than 1

		always_ff @(posedge i_clka) begin
			if(ena_w[WRITE_LATENCY-2]) begin
				if(!error_sig[WRITE_LATENCY-2] && wea_w[WRITE_LATENCY-2]) begin  //when error signal is 0 and write_enable of port A is 1
					ram[write_a[WRITE_LATENCY-2]] <= data_a[WRITE_LATENCY-2];
				end
			end
		end

		always_ff @(posedge i_clkb) begin
			if(enb_w[WRITE_LATENCY-2]) begin
				if(!error_sig[WRITE_LATENCY-2] && web_w[WRITE_LATENCY-2]) begin  //when error signal is 0 and write_enable of port B is 1

					ram[write_b[WRITE_LATENCY-2]] <= data_b[WRITE_LATENCY-2];
				end
			end
		end

		//pipelining all input signals of Port A for read path registers

		always_ff @(posedge i_clka) begin
			read_a[0] <= i_addra;
			ena_r[0] <= i_ena;
			wea_r[0] <= i_wea;
			for(int k=1;k < READ_LATENCY;k++) begin
				read_a[k] <= read_a[k-1];
				ena_r[k] <= ena_r[k-1];
				wea_r[k] <= wea_r[k-1];
			end
		end

		//pipelining all input signals of Port B for read path registers

		always_ff @(posedge i_clkb) begin
			read_b[0] <= i_addrb;
			enb_r[0] <= i_enb;
			web_r[0] <= i_web;
			for(int k=1;k < READ_LATENCY;k++) begin
				read_b[k] <= read_b[k-1];
				enb_r[k] <= enb_r[k-1];
				web_r[k] <= web_r[k-1];
			end
		end

		//to generate read operation when READ_LATENCY is 1 for both port A and port B

		generate
		if(READ_LATENCY ==1) begin:rd_l1
			always_ff @(posedge i_clka) begin
				if(!i_wea && i_ena) begin
					i2a_ham <= ram[i_addra];
				end
			end
			always_ff @(posedge i_clkb) begin
				if(!i_web && i_enb) begin
					i2b_ham <= ram[i_addrb];
				end
			end
		end
		endgenerate

		//read operation for port A when READ_LATENCY is greater than 1

		always_ff @(posedge i_clka) begin:read_A
			if(ena_r[READ_LATENCY-2] && (!wea_r[READ_LATENCY-2])) begin
				i2a_ham <= ram[read_a[READ_LATENCY-2]];
			end
		end

		//read operation for port B when READ_LATENCY is greater than 1

		always_ff @(posedge i_clkb) begin:read_B
			if(enb_r[READ_LATENCY-2] && !web_r[READ_LATENCY-2]) begin
				i2b_ham <= ram[read_b[READ_LATENCY-2]];
			end
		end
endmodule










