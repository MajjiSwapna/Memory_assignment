`include "hamming_encoder.sv"
`include "hamming_decoder.sv"
module dram_with_ham (
	input logic error,input logic [7:0]i_dina,[7:0]i_dinb,input logic [2:0]i_addra,[2:0]i_addrb,
	input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
	output logic [7:0]o_douta,[7:0]o_doutb
	);
reg [11:0] ram [7:0];
logic [11:0]i1a_ham;
logic [11:0] i2a_ham;
logic [11:0]i1b_ham;
logic [11:0] i2b_ham;
hamming_encoder h1a(i1a_ham,1'b1,i_dina);
hamming_decoder h2a(o_douta,1'b1,i2a_ham);
hamming_encoder h1b(i1b_ham,1'b1,i_dinb);
hamming_decoder h2b(o_doutb,1'b1,i2b_ham);
always @(posedge i_clka) begin
	if(i_ena) begin
  		if(i_wea) begin
			if(!(error && i_web)) begin
				ram[i_addra] <= i1a_ham;
		   end
        end
		else begin
			i2a_ham <= ram[i_addra];
			end
	end
end

always @(posedge i_clkb) begin
	if(i_enb) begin
		if(i_web) begin
            if(!(error && i_wea)) begin
				ram[i_addrb] <= i1b_ham;
		     end
        end
		else begin
			i2b_ham <= ram[i_addrb];
			end
	end
end
endmodule

