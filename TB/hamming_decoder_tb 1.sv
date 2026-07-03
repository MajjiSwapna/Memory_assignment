`include "hamming_decoder.sv"
module tb_hamming_decoder;

  // Define the data width you want to test
  parameter TB_DATA_WIDTH = 8;
  parameter EVEN = 0;

  // Calculate the expected total width in the testbench to size your local signals
  localparam TB_PARITY_WIDTH = $clog2(TB_DATA_WIDTH + $clog2(TB_DATA_WIDTH) + 1);
  localparam TB_TOTAL_WIDTH = TB_DATA_WIDTH + TB_PARITY_WIDTH;

  // Testbench Signals
  reg  [ TB_TOTAL_WIDTH:1] code_in;
  wire [TB_DATA_WIDTH-1:0] data_out;

  // Device Under Test (DUT) Instantiation
  hamming_decoder #(
      .DATA_WIDTH(TB_DATA_WIDTH),  // You ONLY pass DATA_WIDTH here!
      .EVEN(EVEN)
  ) dut (
      .code_in (code_in),
      .data_out(data_out)
  );

  initial begin
    // Stimulus goes here...
    // code_in = 7'b1011011;
    //code_in = 7'b1011011;
    #10;
    code_in = 12'b101001011110;
    $display("Data In: %b, Code Out: %b", code_in, data_out);
    #100 $finish;

  end

endmodule
