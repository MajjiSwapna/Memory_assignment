`include "dram_with_ham.sv"
module bank_memory #(
	parameter READ_LATENCY = 3,
	parameter WRITE_LATENCY = 2
	)
	(
	input logic [4:0]i_addra,[4:0]i_addrb,input logic [7:0]dina,[7:0]dinb,
	input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
	output logic [7:0]o_douta,[7:0]o_doutb
	);
	logic [4:0] bank_sela [READ_LATENCY-1:0];
	logic [4:0] bank_selb [READ_LATENCY-1:0];
	logic [4:0] dbank_a [WRITE_LATENCY-1:0];
	logic [4:0] dbank_b [WRITE_LATENCY-1:0];
	logic [7:0] dina_pipe [WRITE_LATENCY-1:0];
	logic [7:0] dinb_pipe [WRITE_LATENCY-1:0];
	logic [4:0] radd_a;
	logic [4:0] radd_b;
	reg [3:0] ena;
	reg [3:0] enb;
	reg [7:0] douta [3:0];
	reg [7:0] doutb [3:0];
	logic pipe_wea [WRITE_LATENCY-1:0];
	logic pipe_web [WRITE_LATENCY-1:0];
	logic read_wea [READ_LATENCY-1:0];
	logic read_web [READ_LATENCY-1:0];
	logic w_wea;
	logic w_web;
	logic r_wea;
	logic r_web;
	logic error;
	assign error = (i_addra == i_addrb);

	dram_with_ham d1(error,dina_pipe[WRITE_LATENCY-1],dinb_pipe[WRITE_LATENCY-1],radd_a[2:0],radd_b[2:0],i_clka,i_clkb,ena[0],enb[0],pipe_wea[WRITE_LATENCY-1],read_wea[READ_LATENCY-1],w_web,douta[0],doutb[0]);

	dram_with_ham d2(error,dina_pipe[WRITE_LATENCY-1],dinb_pipe[WRITE_LATENCY-1],radd_a[2:0],radd_b[2:0],i_clka,i_clkb,ena[1],enb[1],pipe_wea[WRITE_LATENCY-1]: read_wea[READ_LATENCY-1],douta[1],doutb[1]);

	dram_with_ham d3(error,dina_pipe[WRITE_LATENCY-1],dinb_pipe[WRITE_LATENCY-1],radd_a[2:0],radd_b[2:0],i_clka,i_clkb,ena[2],enb[2],w_wea,w_web,douta[2],doutb[2]);

	dram_with_ham d4(error,dina_pipe[WRITE_LATENCY-1],dinb_pipe[WRITE_LATENCY-1],radd_a[2:0],radd_b[2:0],i_clka,i_clkb,ena[3],enb[3],w_wea,w_web,douta[3],doutb[3]);

	assign radd_a = i_wea ? dbank_a[WRITE_LATENCY-1][4:0] : bank_sela[READ_LATENCY-1][4:0];
	assign radd_b = i_web ? dbank_b[WRITE_LATENCY-1][4:0] : bank_selb[READ_LATENCY-1][4:0];
	//assign w_wea = i_wea ? pipe_wea[WRITE_LATENCY-1]: read_wea[READ_LATENCY-1];
	//assign w_web = i_web ? pipe_web[WRITE_LATENCY-1]: read_web[READ_LATENCY-1];

	always @(posedge i_clka) begin
		dbank_a[0] <= i_addra;
        dina_pipe[0] <= dina;
		pipe_wea[0] <= i_wea;
		for (int a=1;a <= (WRITE_LATENCY-1);a++)
		begin
			dbank_a[a] <= dbank_a[a-1];
			dina_pipe[a] <= dina_pipe[a-1];
			pipe_wea[a] <= pipe_wea[a-1];
		end
	end

	always @(posedge i_clkb) begin
		dbank_b[0] <= i_addrb;
		dinb_pipe[0] <= dinb;
		pipe_web[0] <= i_web;
		for (int a=1;a <= (WRITE_LATENCY-1);a++)
		begin
			dbank_b[a] <= dbank_b[a-1];
			dinb_pipe[a] <= dinb_pipe[a-1];
			pipe_web[a] <= pipe_web[a-1];
		end
	end

	always_comb begin
		ena=4'd0;
		case(radd_a[4:3])
			2'b00: ena[0] = i_ena;
			2'b01: ena[1] = i_ena;
			2'b10: ena[2] = i_ena;
			2'b11: ena[3] = i_ena;
			default:ena=0;
		endcase
	end
	always_comb begin
		enb=4'd0;
		case(radd_b[4:3])
			2'b00: enb[0] = i_enb;
			2'b01: enb[1] = i_enb;
			2'b10: enb[2] = i_enb;
			2'b11: enb[3] = i_enb;
			default:enb=0;
		endcase
	end

    always @(posedge i_clka) begin
		//if(!i_wea) begin
			bank_sela[0] <= i_addra;
			read_wea [0] <= i_wea;
			for(int i=1;i < READ_LATENCY;i++)
			begin
				bank_sela[i] <= bank_sela[i-1];
				read_wea[i] <= read_wea[i-1];
			end
		//end
	end

	always @(posedge i_clkb) begin
	//	if(!i_web) begin
			bank_selb[0] <= i_addrb;
			read_web[0] <= i_web;
			for(int i=1;i < READ_LATENCY;i++)
			begin
				bank_selb[i] <= bank_selb[i-1];
				read_web[i] <= read_web[i-1];
			end
		//end
	end

	always_comb begin
			case(bank_sela[READ_LATENCY-1][4:3])
				2'b00:o_douta = douta[0];
				2'b01:o_douta = douta[1];
				2'b10:o_douta = douta[2];
				2'b11:o_douta = douta[3];
			endcase
		end

     always_comb begin
			case(bank_selb[READ_LATENCY-1][4:3])
				2'b00:o_doutb = doutb[0];
             	2'b01:o_doutb = doutb[1];
                2'b10:o_doutb = doutb[2];
                2'b11:o_doutb = doutb[3];
			endcase
		end
endmodule


