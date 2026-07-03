module hamming_encoder( output [11:0] code,input even, [7:0] data);
  reg [11:0] parity;
  always_comb begin
  parity = {1'b0,1'b0,data[7],1'b0,data[6:4],1'b0,data[3:0]};
  parity[11] = (parity[9] ^ parity[7] ^ parity[5] ^ parity[3] ^ parity[1]) == 0 ? (even ? 0 : 1) : (even ? 1 : 0) ;
  parity[10] = (parity[9] ^ parity[6] ^ parity[5] ^ parity[2] ^ parity[1]) == 0 ? (even ? 0 : 1) : (even ? 1 : 0) ;
  parity[8]  = (parity[7] ^ parity[6] ^ parity[5] ^ parity[0]) == 0 ? (even ? 0 : 1) : (even ? 1 : 0) ;
  parity[4]  = (parity[3] ^ parity[2] ^ parity[1] ^ parity[0]) == 0 ? (even ? 0 : 1) : (even ? 1 : 0) ;
  end
  assign code = parity;
endmodule

module he_tb;
  wire [11:0] code;
  reg even;
  reg [7:0] data ;

  hamming_encoder h1(code,even,data);

  initial begin
  even = 1;
  data = 8'b10111011;
  #50 ;
  even = 0;
  data = 8'b10111011;
  end

  endmodule
