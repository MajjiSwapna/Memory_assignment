`include "hamming_encoder.sv"
module tb_hamming;

  // Define the data width you want to test
  parameter TB_DATA_WIDTH = 8;
  parameter EVEN = 0;

  // Calculate the expected total width in the testbench to size your local signals
  localparam TB_PARITY_WIDTH = $clog2(TB_DATA_WIDTH + $clog2(TB_DATA_WIDTH) + 1);
  localparam TB_TOTAL_WIDTH = TB_DATA_WIDTH + TB_PARITY_WIDTH;

  // Testbench Signals
  reg  [TB_DATA_WIDTH-1:0] data_in;
  wire [ TB_TOTAL_WIDTH:1] code_out;

  // Device Under Test (DUT) Instantiation
  hamming_encoder #(
      .DATA_WIDTH(TB_DATA_WIDTH),  // You ONLY pass DATA_WIDTH here!
      .EVEN(EVEN)
  ) dut (
      .data_in (data_in),
      .code_out(code_out)
  );

  initial begin
    // Stimulus goes here...
    data_in = 8'b10101100;
    #10;
    data_in = 8'b10111011;
    $display("Data In: %b, Code Out: %b", data_in, code_out);
    #100 $finish;

  end

endmodule
