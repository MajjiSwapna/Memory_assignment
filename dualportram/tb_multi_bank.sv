`include "multi_bank_memory.sv"
module tb_multi_bank ();
parameter READ_LATENCY = 2;
parameter WRITE_LATENCY = 2;
  logic [4:0] i_addra;
  logic [7:0] i_dina;
  logic i_clka, i_ena, i_wea;
  logic [7:0] o_douta;
  logic [4:0] i_addrb;
  logic [7:0] i_dinb;
  logic i_clkb, i_enb, i_web;
  logic [7:0] o_doutb;
  multi_bank_memory #(
	  .READ_LATENCY(READ_LATENCY),
	  .WRITE_LATENCY(WRITE_LATENCY)
	  ) uut (
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
    end

    always #5 i_clka = ~i_clka;
    always #5 i_clkb = ~i_clkb;
    always @(posedge i_clka) i_addra = $random;
    always @(posedge i_clkb) i_addrb = $random;
    always @(posedge i_clka) i_dina = $random;
    always @(posedge i_clkb) i_dinb = $random;
 endmodule


