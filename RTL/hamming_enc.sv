module hamming_encoder #(
    parameter DATA_WIDTH = 4,
    parameter EVEN = 1,
    localparam PARITY_WIDTH = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH) + 1)
) (
    input [DATA_WIDTH-1:0] data_in,
    output reg [(DATA_WIDTH + PARITY_WIDTH):1] code_out
);
  // The inner $clog2 provides a close estimate of 'r', adding it to DATA_WIDTH
  // ensures the outer $clog2 allocates enough bits to satisfy: 2^r >= k + r + 1
  localparam TOTAL_WIDTH = DATA_WIDTH + PARITY_WIDTH;

  // Internal register
  reg [TOTAL_WIDTH:1] mixed_vector;
  // pragma coverage off
  reg [$clog2(DATA_WIDTH):0] index;
  reg [$clog2(DATA_WIDTH)+1:0] j;
  reg [$clog2(PARITY_WIDTH):0] pt;

  // pragma coverage on
  always_comb begin
    index = 1;
    pt = 1;
    //Placing the databits in the temp output at respective positions
    for (int i = 1; i <= TOTAL_WIDTH; i = i + 1) begin
      if ((i & (i - 1)) == 0) begin
        mixed_vector[TOTAL_WIDTH-i+1] = 1'b0;
        //$display("Data written: %b", mixed_vector[TOTAL_WIDTH-i]);
      end else begin
        mixed_vector[TOTAL_WIDTH-i+1] = data_in[DATA_WIDTH-index];
        index = index + 1;
        //$display("else Data written: %b", mixed_vector[TOTAL_WIDTH-i]);

      end
    end

    // Calc the Parity bits
    for (int p = 1; p <= TOTAL_WIDTH; p = p + 1) begin
      if ((p & (p - 1)) == 0) begin
        for (j = 1; j <= TOTAL_WIDTH; j = j + 1) begin
          if (j[pt-1] == 1'b1) begin
            mixed_vector[TOTAL_WIDTH -p+1] = mixed_vector[TOTAL_WIDTH -p+1]^mixed_vector[TOTAL_WIDTH - j+1 ];
          end
        end
        if (EVEN == 0) begin
          mixed_vector[TOTAL_WIDTH-p+1] = ~mixed_vector[TOTAL_WIDTH-p+1];
        end
        pt = pt + 1'b1;

      end

     end  // parity
    code_out = mixed_vector;
  end  //always

endmodule
