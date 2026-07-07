`include "ramport.sv"
module tb_ramports ();
  logic clk, en, we;
  logic [7:0] din;
  logic [2:0] addr;
  logic [7:0] dout;
  ramport uut (
      din,
      addr,
      clk,
      en,
      we,
      dout
  );
  always #2 clk = ~clk;
  initial begin
    clk  = 0;
    din  = 0;
    addr = 0;
    en   = 0;
    we   = 0;
    repeat (4) @(posedge clk);
    clk  = 1;
    din  = 8'd23;
    addr = 3'd3;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd3;
    addr = 3'd2;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd45;
    addr = 3'd1;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd66;
    addr = 3'd5;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd21;
    addr = 3'd4;
    en   = 0;
    we   = 1;
    repeat (4) @(posedge clk);
    addr = 3'd3;
    en   = 1;
    we   = 0;
    repeat (4) @(posedge clk);
    addr = 3'd1;
    en   = 1;
    we   = 0;
    repeat (4) @(posedge clk);
    addr = 3'd5;
    en   = 1;
    we   = 0;
    @(posedge clk);
  end
endmodule




