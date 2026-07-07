////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File name              :  ramport.sv                                                                           //
//                                                                                                                //
// Port names             : Inputs : din,addr,clk,en,we                                                           //
//                          Output : dout                                                                         //
//                                                                                                                //
// Description            : This a RAM memory module having an input data,address,clock,enable,write enable(we).  //
//                          This has 08 memory locations and 8 bit data width can be stored in each location.     //
//                          when en and we are high data can be stored in a location and when we is low read can  //
//                          be done and stored in dout.                                                           //
//                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ramport (
    input logic[7:0] din,
    input logic[2:0] addr,
    input clk,
    en,
    we,
    output logic[7:0] dout
);
  reg [7:0] ram_block[7:0];
  always @(posedge clk) begin
    if (en && we) begin
      ram_block[addr] <= din;   //din data is stored in addr given in ram_block
    end else if (en && !we) begin
      dout <= ram_block[addr];    //dout reads the data in that addr
    end
  end
endmodule

