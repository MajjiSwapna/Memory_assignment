module hamming_decoder( output reg [7:0] data,input even, [11:0] parity);
  reg [3:0]code;
  reg [11:0] out;
  always_comb begin
  // parity = {1'b0,1'b0,data[7],1'b0,data[6:4],1'b0,data[3:0]};
  code[0] = (parity[11] ^ parity[9] ^ parity[7] ^ parity[5] ^ parity[3] ^ parity[1]) == 0 ? (even ? 0 : 1): (even ? 1 : 0);
  code[1] = (parity[10] ^ parity[9] ^ parity[6] ^ parity[5] ^ parity[2] ^ parity[1]) == 0 ? (even ? 0 : 1): (even ? 1 : 0);
  code[2] = (parity[8]  ^ parity[7] ^ parity[6] ^ parity[5] ^ parity[0]) == 0 ? (even ? 0 : 1): (even ? 1 : 0);
  code[3] = (parity[4]  ^ parity[3] ^ parity[2] ^ parity[1] ^ parity[0]) == 0 ? (even ? 0 : 1): (even ? 1 : 0);

  if ( code == 0)
  	data = {parity[9],parity[7:5],parity[3:0]};
  else 
  begin  	
	out = parity;
	out[12- code] = ~out[12 - code];
	data = {out[9],out[7:5],out[3:0]};
  end
  end
endmodule

module hd_tb;
  wire [7:0] data;
  reg even;
  reg [11:0] parity ;

  hamming_decoder h2 (data,even,parity);

  initial begin
  even = 0;
  parity = 12'b111001101011;
  #50 ;
  even = 1;
  parity = 12'b001101111011;
  #50;
  even = 0;
  parity = 12'b111001101001;
  #50 ;
  even = 1;
  parity = 12'b001101111001;
  #50;
  even = 0;
  parity = 12'b101001101011;
  #50 ;
  even = 1;
  parity = 12'b101101111011;


  end

  endmodule
