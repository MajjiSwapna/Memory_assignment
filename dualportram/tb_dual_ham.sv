`include "dram_with_ham.sv"
module tb_dualham ();
  logic clka, clkb, ena, enb, wea, web;
  logic [7:0] dina;
  logic [7:0] dinb;
  logic [7:0] douta;
  logic [7:0] doutb;
  logic [2:0] addra;
  logic [2:0] addrb;
  logic error;
  dram_with_ham uut (
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
    error= 0;
    @(posedge clka);
    ena   = 1;
    enb   = 1;
    wea   = 1;
    web   = 1;
    dina  = 8'd45;
    dinb  = 8'd34;
    addra = 3'd2;
    addrb = 3'd7;
    repeat (2) @(posedge clka);
    addra = 3'd4;
    addrb = 3'd3;
    dina  = 8'd32;
    dinb  = 8'd66;
    repeat (2) @(posedge clka);
    addra = 3'd1;
    addrb = 3'd6;
    dina  = 8'd44;
    dinb  = 8'd88;
    repeat (2) @(posedge clka);
    addra = 3'd5;
    addrb = 3'd0;
    dina  = 8'd80;
    dinb  = 8'd60;
    repeat (20) @(posedge clka);
    wea = 0;
    web = 0;
    addra = 3'd5;
    addrb = 3'd3;
    @(posedge clka);
    addra = 3'd1;
    addrb = 3'd2;
    @(posedge clka);
    addra = 3'd0;
    addrb = 3'd7;
  end
endmodule



