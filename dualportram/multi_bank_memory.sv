`include "ram8x8.sv"
module multi_bank_memory #(
	parameter READ_LATENCY = 2,
	parameter WRITE_LATENCY = 2
	)
	(
	input logic [4:0]i_addra,[4:0]i_addrb,input logic [7:0]dina,[7:0]dinb,
	input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
	output logic [7:0]o_douta,[7:0]o_doutb
	);
    logic [4:0] bank_sela [READ_LATENCY-1:0];
	logic [4:0] bank_selb [READ_LATENCY-1:0];
	logic wea_r [READ_LATENCY-1:0];
	logic web_r [READ_LATENCY-1:0];
	reg [3:0] ena;
	reg [3:0] enb;
	reg [7:0] douta [3:0];
	reg [7:0] doutb [3:0];
	logic error;
	assign error = ((i_addra == i_addrb) && (i_wea & i_web));

	ram8x8 #(.READ_LATENCY(READ_LATENCY), .WRITE_LATENCY(WRITE_LATENCY)) d1 (error,dina,dinb,i_addra[2:0],i_addrb[2:0],i_clka,i_clkb,ena[0],enb[0],i_wea,i_web,douta[0],doutb[0]);

	ram8x8 #(.READ_LATENCY(READ_LATENCY), .WRITE_LATENCY(WRITE_LATENCY)) d2(error,dina,dinb,i_addra[2:0],i_addrb[2:0],i_clka,i_clkb,ena[1],enb[1],i_wea,i_web,douta[1],doutb[1]);

	ram8x8 #(.READ_LATENCY(READ_LATENCY), .WRITE_LATENCY(WRITE_LATENCY)) d3(error,dina,dinb,i_addra[2:0],i_addrb[2:0],i_clka,i_clkb,ena[2],enb[2],i_wea,i_web,douta[2],doutb[2]);

	ram8x8 #(.READ_LATENCY(READ_LATENCY), .WRITE_LATENCY(WRITE_LATENCY)) d4(error,dina,dinb,i_addra[2:0],i_addrb[2:0],i_clka,i_clkb,ena[3],enb[3],i_wea,i_web,douta[3],doutb[3]);

  always @(posedge i_clka) begin
	bank_sela[0] <= i_addra;
	wea_r[0] <= i_wea;
	for (int i=1;i<=(READ_LATENCY-1);i++)
	begin
		bank_sela[i] <= bank_sela[i-1];
		wea_r[i] <= wea_r[i-1];
    end
  end

  always @(posedge i_clkb) begin
	bank_selb[0] <= i_addrb;
    web_r[0] <= i_web;
	for (int i=1;i<= (READ_LATENCY-1);i++)
	begin
		bank_selb[i] <= bank_selb[i-1];
		web_r[i] <= web_r[i-1];
	end
  end

	always_comb begin //demux
		ena=4'd0;
		case(i_addra[4:3])
			2'b00: ena[0] = i_ena;
			2'b01: ena[1] = i_ena;
			2'b10: ena[2] = i_ena;
			2'b11: ena[3] = i_ena;
			default:ena=0;
		endcase
	end
	always_comb begin  //demux
		enb=4'd0;
		case(i_addrb[4:3])
			2'b00: enb[0] = i_enb;
			2'b01: enb[1] = i_enb;
			2'b10: enb[2] = i_enb;
			2'b11: enb[3] = i_enb;
			default:enb=0;
		endcase
	end

	assign o_doutb = web_r[READ_LATENCY-1] ? o_doutb : doutb[bank_selb[READ_LATENCY-1][4:3]];
	assign o_douta = wea_r[READ_LATENCY-1] ? o_douta : douta[bank_sela[READ_LATENCY-1][4:3]];

endmodule


