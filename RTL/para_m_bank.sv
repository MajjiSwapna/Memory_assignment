 // =============================================================================
 //  para_m_bank.sv  —  Parameterized Multi-Bank Dual-Port Memory Controller
 //
 //  FUNCTION
 //    Implements a large dual-port memory by combining multiple smaller
 //    RAM banks (ram_para). The controller automatically selects the
 //    appropriate bank based on the input address and supports independent
 //    read/write operations on both ports.
 //
 //  ARCHITECTURE
 //    • Memory is divided into multiple banks of fixed BANK_DEPTH.
 //    • A generate loop instantiates NUM_BANKS RAM modules.
 //    • Upper address bits select the memory bank.
 //    • Lower address bits access locations within the selected bank.
 //    • Enable signals act as a demultiplexer for bank selection, while
 //      output data is selected through a multiplexer.
 //
 //  KEY FEATURES
 //    • Parameterized memory depth and data width
 //    • Independent dual-port read/write access
 //    • Configurable read and write latency
 //    • Address and write-enable pipelining for latency matching
 //    • Automatic bank generation using generate loops
 //    • Write collision detection for simultaneous writes to the same address
 //
 //  INTERFACE
 //    i_clka, i_clkb  – Independent clocks for Port-A and Port-B
 //    i_ena, i_enb    – Port enable signals
 //    i_wea, i_web    – Port write enable signals
 //    i_addra, i_addrb– Memory addresses
 //    i_dina, i_dinb  – Write data inputs
 //    o_douta, o_doutb– Read data outputs
 //
 //  NOTE
 //    This module serves as a memory bank controller. It manages bank
 //    selection, address pipelining, output multiplexing, and collision
 //    detection while using multiple ram_para instances as the actual
 //    storage elements.
 // =============================================================================


`include "ram_para.sv"
module para_m_bank #(
	parameter READ_LATENCY = 2,
	parameter WRITE_LATENCY = 2,
	parameter DATA_WIDTH = 8,           //data path width in bits
	parameter ADDR_WIDTH = $clog2(N_DEPTH),       //parameterized address width of a single RAM module
	parameter N_DEPTH = 32              //number of address locations for a controller bank memory
	)
	(

	input logic [ADDR_WIDTH-1:0]i_addra,[ADDR_WIDTH-1:0]i_addrb,
	input logic [DATA_WIDTH-1:0]i_dina, [DATA_WIDTH-1:0]i_dinb,
		//port A and B individual clock,enable,write_enable
	input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
		//Port A and B outputs
	output logic [DATA_WIDTH-1:0]o_douta,[DATA_WIDTH-1:0]o_doutb
	);

	// ----------------------------------------------------------------
	//
	// Parameterized for number of banks in memory controller
	//
	// ----------------------------------------------------------------

	localparam BANK_DEPTH = 8;                        //address locations inside a sigle bank
    localparam NUM_BANKS = N_DEPTH / BANK_DEPTH;      //number of banks required for creating the memory controller by doing total locations divide by single RAM locations
	localparam BANK_ADDR_WIDTH = $clog2(BANK_DEPTH);  //address lines for single RAM
    localparam BANK_SEL_WIDTH  = $clog2(NUM_BANKS);   //selection address lines for mux and demux operation to select which bank is selected

	//Pipelining addresses for selecting output at mux with READ_LATENCY value for read operation

    logic [ADDR_WIDTH-1:0] bank_sela [READ_LATENCY-1:0];
	logic [ADDR_WIDTH-1:0] bank_selb [READ_LATENCY-1:0];

	//Pipelining write_enable for read operation with READ_LATENCY

	logic wea_r [READ_LATENCY-1:0];           //pipelining write_enable of Port A
	logic web_r [READ_LATENCY-1:0];           //pipelining write_enable of Port B

	//Enables for port A and B to select a bank in the memory controller which acts as a demux

	reg [NUM_BANKS-1:0] ena;
	reg [NUM_BANKS-1:0] enb;

    //outputs from the memory controller

	reg [DATA_WIDTH-1:0] douta [NUM_BANKS-1:0];
	reg [DATA_WIDTH-1:0] doutb [NUM_BANKS-1:0];

	logic error;
	assign error = ((i_addra == i_addrb) && (i_wea & i_web));        //if the addresses of both A and B are equal and also if both write_enables are high then the error signal becomes high and prevents from writing data into that memory location

	genvar i;                    //generate variable

    //-----------------------------------------------------------------------------------
	//
	//generate loop to create banks inside the memory controller based upon the
	//parameterized NUM_BANKS value by instantiating single RAM module
	//
	//-----------------------------------------------------------------------------------

	generate
	for(i=0;i<NUM_BANKS;i++) begin

		ram_para #(READ_LATENCY,WRITE_LATENCY,DATA_WIDTH,BANK_ADDR_WIDTH) ram_i (error,i_dina,i_dinb,i_addra[BANK_ADDR_WIDTH-1:0],i_addrb[BANK_ADDR_WIDTH-1:0],i_clka,i_clkb,ena[i],enb[i],i_wea,i_web,douta[i],doutb[i]);

	end
    endgenerate

	// ---------------------------------------------------------------------------
	// Pipelining both port A and B address and write_enable for read operation
	// with READ-LATENCY
	// ---------------------------------------------------------------------------
  always @(posedge i_clka) begin
	bank_sela[0] <= i_addra;
	wea_r[0] <= i_wea;
	for (int i=1;i<=(READ_LATENCY-1);i++)
	begin
		bank_sela[i] <= bank_sela[i-1];
		wea_r[i] <= wea_r[i-1];
    end
  end

  always @(posedge i_clkb) begin
	bank_selb[0] <= i_addrb;
    web_r[0] <= i_web;
	for (int i=1;i<= (READ_LATENCY-1);i++)
	begin
		bank_selb[i] <= bank_selb[i-1];
		web_r[i] <= web_r[i-1];
	end
  end

  // --------------------------------------------------------------------------------
  //
  // demux operation for enables of Port A and B to select which bank should
  // be selected to store data
  //
  // --------------------------------------------------------------------------------

   always_comb begin
	   ena = '0;               //initializes to zero everytime
	   ena[i_addra[ADDR_WIDTH-1:BANK_ADDR_WIDTH]] = i_ena;   //parameterized selection address width of Port A based on number of banks where 4 banks make 2 selection lines and 8 banks make 3 selection lines
   end

   always_comb begin
	   enb = '0;
	   enb[i_addrb[ADDR_WIDTH-1:BANK_ADDR_WIDTH]] = i_enb;    //parameterized selection address width of Port B based on number of banks where 4 banks make 2 selection lines and 8 banks make 3 selection lines

   end

   // ----------------------------------------------------------------------------
   //
   // mux operation to select output from each bank is selected based on the
   // selection lines of both ports to read data
   //
   // ----------------------------------------------------------------------------

	assign o_doutb = web_r[READ_LATENCY-1] ? o_doutb : doutb[bank_selb[READ_LATENCY-1][ADDR_WIDTH-1:BANK_ADDR_WIDTH]];
	assign o_douta = wea_r[READ_LATENCY-1] ? o_douta : douta[bank_sela[READ_LATENCY-1][ADDR_WIDTH-1:BANK_ADDR_WIDTH]];

endmodule


