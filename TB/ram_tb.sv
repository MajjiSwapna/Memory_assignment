`include "ram_para.sv"
module ram_tb();
parameter READ_LATENCY = 5;
parameter WRITE_LATENCY = 3;
parameter DW = 8;
parameter ADDR = $clog2(DW);
  logic clka, clkb, ena, enb, wea, web;
  logic [DW-1:0] dina;
  logic [DW-1:0] dinb;
  logic [DW-1:0] douta;
  logic [DW-1:0] doutb;
  logic [ADDR-1:0] addra;
  logic [ADDR-1:0] addrb;
  logic error;
  ram_para #(READ_LATENCY,WRITE_LATENCY,DW,ADDR) uut (
      error,
      dina,
      dinb,
      addra,
      addrb,
      clka,
      clkb,
      ena,
      enb,
      wea,
      web,
      douta,
      doutb
  );
  always #2 clka = ~clka;
  always #2 clkb = ~clkb;
  initial begin
    clka = 0;
    clkb = 0;
    ena  = 0;
    enb  = 0;
    wea  = 0;
    web  = 0;
    error = 0;
    @(posedge clka);
    ena   = 1;
    enb   = 1;
    wea   = 1;
    web   = 1;
    dina  = 8'd45;
    addra = 3'd3;
    @(posedge clkb);
	dinb  = 8'd34;
    addrb = 3'd7;
    repeat (1) @(posedge clka);
    addra = 3'd4;
    dina  = 8'd32;
    repeat (1) @(posedge clkb);
	//ena = 0;
	//enb = 0;
	@(posedge clka);
    addrb = 3'd6;
    dinb  = 8'd88;
	@(posedge clkb);
    addra = 3'd5;
    dina  = 8'd80;
	@(posedge clka);
	addrb = 3'd2;
	dinb  = 8'd66;
	@(posedge clkb);
	addrb = 3'd3;
	wea = 0;
	web = 1;
	repeat(4) @(posedge clka);
    dina  = 8'd44;
    addra = 3'd1;
	@(posedge clkb);
	dinb = 8'd24;
	addrb = 3'd4;
	@(posedge clka);
	wea = 1;
	web = 1;
	//dina = 8'd88;
	//addra = 3'd2;
    repeat (1) @(posedge clkb);
    addrb = 3'd0;
    dinb  = 8'd60;
    repeat (20) @(posedge clka);
    wea = 0;
    web = 0;
    @(posedge clka);
    addra = 3'd3;
    @(posedge clkb);
    addrb = 3'd1;
	//ena =0;
	//enb=0;
    @(posedge clka);
    addra = 3'd0;
	@(posedge clkb);
    addrb = 3'd7;
	@(posedge clkb);
	addrb = 3'd5;
	@(posedge clka);
	addra = 3'd2;
end
endmodule
