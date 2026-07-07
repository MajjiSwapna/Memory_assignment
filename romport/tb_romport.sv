`include "romport.sv"
module tb_romport ();
  logic clk, en;
  logic [2:0] addr;
  logic [7:0] dout;
  romport uut (
      clk,
      addr,
      en,
      dout
  );
  always #2 clk = ~clk;
  initial begin
    clk  = 0;
    en   = 0;
    addr = 0;
    repeat (6) @(posedge clk);
    en   = 1;
    addr = 3'b000;
    @(posedge clk);
    addr = 3'b111;
    repeat (4) @(posedge clk);
    addr = 3'b010;
    @(posedge clk);

  end
endmodule

