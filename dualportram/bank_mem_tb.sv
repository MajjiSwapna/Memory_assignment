`include "bank_memory.sv"
module bank_mem_tb ();
  logic [4:0] i_addra;
  logic [4:0] i_addrb;
  logic [7:0] dina;
  logic [7:0] dinb;
  logic i_clka, i_clkb, i_ena, i_enb, i_wea, i_web;
  logic [7:0] o_douta;
  logic [7:0] o_doutb;
  bank_memory uut (
      i_addra,
      i_addrb,
      dina,
      dinb,
      i_clka,
      i_clkb,
      i_ena,
      i_enb,
      i_wea,
      i_web,
      o_douta,
      o_doutb
  );

  always #2 i_clka = ~i_clka;
  always #3 i_clkb = ~i_clkb;
  initial begin
    i_clka = 0;
    i_clkb = 0;
    @(posedge i_clka);
    i_ena = 1;
    i_enb = 1;
    i_wea = 1;
    i_web = 1;
    @(posedge i_clka);
    i_addra = 5'b00000;
    dina = 8'd0;
    dinb = 8'd31;
    i_addrb = 5'b11111;
    @(posedge i_clka);
	i_addra = 5'b00001;
    dina = 8'd1;
    dinb = 8'd30;
    i_addrb = 5'b11110;
    @(posedge i_clka);
	i_wea = 0;
	i_web = 0;
    i_addra = 5'b00010;
    dina = 8'd2;
    dinb = 8'd22;
    i_addrb = 5'b10110;
    @(posedge i_clka);
    i_addra = 5'b01011;
    dina = 8'd11;
    dinb = 8'd18;
    i_addrb = 5'b10010;
    @(posedge i_clka);
    i_addra = 5'b11000;
    dina = 8'd24;
    dinb = 8'd20;
    i_addrb = 5'b10100;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b10000;
    dina = 8'd16;
    dinb = 8'd14;
    i_addrb = 5'b01110;
    repeat (3) @(posedge i_clka);
    i_addra = 5'd3;
    dina = 8'd3;
    i_addrb = 5'd4;
    dinb = 8'd4;
    @(posedge i_clka);
	i_wea = 1;
	i_web = 1;
    i_addra = 5'd5;
    dina = 8'd5;
    i_addrb = 5'd6;
    dinb = 8'd6;
    @(posedge i_clka);
    i_addra = 5'd7;
    dina = 8'd7;
    i_addrb = 5'd8;
    dinb = 8'd8;
    @(posedge i_clkb);
    i_addrb = 5'd9;
    dinb = 8'd10;
    repeat (3) @(posedge i_clka);
    i_addra = 5'd11;
    dina = 8'd11;
    i_addrb = 5'd12;
    dinb = 8'd12;
    repeat (3) @(posedge i_clka);
    i_addra = 5'd15;
    dina = 8'd15;
    i_addrb = 5'd27;
    dinb = 8'd27;
    repeat (3) @(posedge i_clkb);
    i_addra = 5'd29;
    dina = 8'd29;
    i_addrb = 5'd26;
    dinb = 8'd51;
    repeat (1) @(posedge i_clka);
    i_wea = 0;
    i_web = 0;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b11000;
    i_addrb = 5'b10100;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b10000;
    i_addrb = 5'b01110;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b00001;
    i_addrb = 5'b11110;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b00000;
    i_addrb = 5'b11111;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b00010;
    i_addrb = 5'b10110;
    repeat (3) @(posedge i_clka);
    i_addra = 5'b01010;
    i_addrb = 5'b10100;
     end
  initial begin
    $monitor("addra= %d;addrb=%d;odouta=%d;odoutb=%d;", i_addra, i_addrb, o_douta, o_doutb);
  end
endmodule




