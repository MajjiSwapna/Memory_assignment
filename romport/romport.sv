////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// File name              :  romport.sv                                                                           //
//                                                                                                                //
// Port names             : Inputs : addr,clk                                                                     //
//                          Output : dout                                                                         //
//                                                                                                                //
// Description            : This a ROM memory module having a address,clock.It can only read the data stored in   //
//                          the particular address location. This has 8 memory locations and 8 bit data width can //
//                          be stored in each location. Whenever a address is given it shows the data present in  //
//                          that location.                                                                        //
//                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module romport (
    input logic clk,
    logic [2:0] addr,
    en,
    output logic [7:0] dout
);
  always @(posedge clk) begin
    if (!en) begin
      dout <= 8'd0;
    end else
      case (addr)
        3'b000:  dout = 8'd3;
        3'b001:  dout = 8'd5;
        3'b010:  dout = 8'd98;
        3'b011:  dout = 8'd33;
        3'b100:  dout = 8'd43;
        3'b101:  dout = 8'd85;
        3'b110:  dout = 8'd34;
        3'b111:  dout = 8'd23;
        default: dout = 8'd0;
      endcase
  end
endmodule


