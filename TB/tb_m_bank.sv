`include "para_m_bank.sv"
module tb_m_bank();
parameter READ_LATENCY = 2;
parameter WRITE_LATENCY = 2;
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = $clog2(N_DEPTH);
parameter N_DEPTH = 32;
  logic [ADDR_WIDTH-1:0] i_addra;
  logic [DATA_WIDTH-1:0] i_dina;
  logic i_clka, i_ena, i_wea;
  logic [DATA_WIDTH-1:0] o_douta;
  logic [ADDR_WIDTH-1:0] i_addrb;
  logic [DATA_WIDTH-1:0] i_dinb;
  logic i_clkb, i_enb, i_web;
  logic [DATA_WIDTH-1:0] o_doutb;
  para_m_bank #(
	  .READ_LATENCY(READ_LATENCY),
	  .WRITE_LATENCY(WRITE_LATENCY),
	  .DATA_WIDTH(DATA_WIDTH),
	  .ADDR_WIDTH(ADDR_WIDTH),
	  .N_DEPTH(N_DEPTH)) uut (
      i_addra,
      i_addrb,
      i_dina,
      i_dinb,
      i_clka,
      i_clkb,
      i_ena,
      i_enb,
      i_wea,
      i_web,
      o_douta,
      o_doutb
  );

  initial begin
    i_clka = 1; i_clkb = 1;
    i_dina = 0; i_dinb = 0;
    i_ena = 1; i_enb = 1;
    i_wea = 1; i_web = 1;
    i_addra = 0; i_addrb = 0;
    repeat(20) @(posedge i_clkb);
    i_wea = 1; i_web = 0;
    repeat(20) @(posedge i_clkb);
    i_wea = 0; i_web = 1;
    repeat(20) @(posedge i_clkb);
    i_wea = 0; i_web = 0;
	repeat(20) @(posedge i_clkb);
    i_wea = 1; i_web = 0;
    repeat(20) @(posedge i_clkb);
    i_ena = 0; i_enb = 0;
    repeat(20) @(posedge i_clkb);
    i_ena = 1; i_enb = 1;
	repeat(100) @(posedge i_clka);
    $finish;

    end

    always #5 i_clka = ~i_clka;
    always #5 i_clkb = ~i_clkb;
    always @(posedge i_clka) i_addra = $random;
    always @(posedge i_clkb) i_addrb = $random;
    always @(posedge i_clka) i_dina = $random;
    always @(posedge i_clkb) i_dinb = $random;
 endmodule


