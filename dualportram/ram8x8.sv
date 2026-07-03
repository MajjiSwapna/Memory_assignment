`include "hamming_decoder.sv"
`include "hamming_encoder.sv"
module ram8x8 #(
	parameter READ_LATENCY = 2,
	parameter WRITE_LATENCY = 2
	)
	(
		input logic error,input logic [7:0]i_dina,[7:0]i_dinb,
		input logic [2:0]i_addra,[2:0]i_addrb,
		input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
		output logic [7:0]o_douta,[7:0]o_doutb
		);
		logic [2:0] write_a [WRITE_LATENCY-1:0];  //an array of 3 bit width and parameterized location of address to store
    	logic [11:0] data_a [WRITE_LATENCY-1:0];       //an array of 8 bit width and parameterized location of data to store
	    logic [11:0] data_b [WRITE_LATENCY-1:0];
	    logic [2:0] write_b [WRITE_LATENCY-1:0];
	    logic [2:0] read_a [READ_LATENCY-1:0];           //an array of 8 bit width and parameterized location to store read data
	    logic [2:0] read_b [READ_LATENCY-1:0];
        logic error_sig [WRITE_LATENCY-1:0];
	    logic wea_w [WRITE_LATENCY-1:0];
		logic ena_w [WRITE_LATENCY-1:0];
		logic web_w [WRITE_LATENCY-1:0];
		logic enb_w [WRITE_LATENCY-1:0];
		logic wea_r [READ_LATENCY-1:0];
		logic ena_r [READ_LATENCY-1:0];
		logic enb_r [READ_LATENCY-1:0];
		logic web_r [READ_LATENCY-1:0];

	    reg [11:0] ram [7:0];                  //a register named as ram with 8 bit width data and 8 address locations
      	logic [11:0] i1a_ham;
	    logic [11:0] i2a_ham;
	    logic [11:0] i1b_ham;
	    logic [11:0] i2b_ham;
	    hamming_encoder h1a(i1a_ham,1'b1,i_dina);
	    hamming_decoder h2a(o_douta,1'b1,i2a_ham);
	    hamming_encoder h1b(i1b_ham,1'b1,i_dinb);
	    hamming_decoder h2b(o_doutb,1'b1,i2b_ham);

		always @(posedge i_clka) begin
			write_a[0] <= i_addra;
			data_a[0] <= i1a_ham;
			error_sig[0] <= error;
			wea_w[0] <= i_wea;
			ena_w[0] <= i_ena;
			for(int i=1;i < WRITE_LATENCY;i++) begin
				write_a[i] <= write_a[i-1];
				data_a[i] <= data_a[i-1];
				error_sig[i] <= error_sig[i-1];
				wea_w[i] <= wea_w[i-1];
				ena_w[i] <= ena_w[i-1];
			end
		end

		always @(posedge i_clkb) begin
			write_b[0] <= i_addrb;
			data_b[0] <= i1b_ham;
			error_sig[0] <= error;
			web_w[0] <= i_web;
			enb_w[0] <= i_enb;
			for(int i=1;i < WRITE_LATENCY;i++) begin
				write_b[i] <= write_b[i-1];
				data_b[i] <= data_b[i-1];
				error_sig[i] <= error_sig[i-1];
				web_w[i] <= web_w[i-1];
				enb_w[i] <= enb_w[i-1];
			end
		end

		generate
		if(WRITE_LATENCY == 1) begin :wrt_l1
			always @(posedge i_clka) begin
				if(i_wea && i_ena && !error) begin
					ram[i_addra] <= i1a_ham;
				end
			end

			always @(posedge i_clkb) begin
				if(i_web && i_enb && !error) begin
					ram[i_addrb] <= i1b_ham;
				end
			end
		end
		endgenerate

		always @(posedge i_clka) begin
			if(ena_w[WRITE_LATENCY-2]) begin
				if(!error_sig[WRITE_LATENCY-2] && wea_w[WRITE_LATENCY-2]) begin
					ram[write_a[WRITE_LATENCY-2]] <= data_a[WRITE_LATENCY-2];
				end
			end
		end

		always @(posedge i_clkb) begin
			if(enb_w[WRITE_LATENCY-2]) begin
				if(!error_sig[WRITE_LATENCY-2] && web_w[WRITE_LATENCY-2]) begin
					ram[write_b[WRITE_LATENCY-2]] <= data_b[WRITE_LATENCY-2];
				end
			end
		end

		always @(posedge i_clka) begin
			read_a[0] <= i_addra;
			ena_r[0] <= i_ena;
			wea_r[0] <= i_wea;
			for(int k=1;k < READ_LATENCY;k++) begin
				read_a[k] <= read_a[k-1];
				ena_r[k] <= ena_r[k-1];
				wea_r[k] <= wea_r[k-1];
			end
		end
		always @(posedge i_clkb) begin
			read_b[0] <= i_addrb;
			enb_r[0] <= i_enb;
			web_r[0] <= i_web;
			for(int k=1;k < READ_LATENCY;k++) begin
				read_b[k] <= read_b[k-1];
				enb_r[k] <= enb_r[k-1];
				web_r[k] <= web_r[k-1];
			end
		end

		generate
		if(READ_LATENCY ==1) begin:rd_l1
			always @(posedge i_clka) begin
				if(!i_wea && i_ena) begin
					i2a_ham <= ram[i_addra];
				end
			end
			always @(posedge i_clkb) begin
				if(!i_web && i_enb) begin
					i2b_ham <= ram[i_addrb];
				end
			end
		end
		endgenerate


		always @(posedge i_clka) begin:read_A
			if(ena_r[READ_LATENCY-2] && (!wea_r[READ_LATENCY-2])) begin
				i2a_ham <= ram[read_a[READ_LATENCY-2]];
			end
		end

		always @(posedge i_clkb) begin:read_B
			if(enb_r[READ_LATENCY-2] && !web_r[READ_LATENCY-2]) begin
				i2b_ham <= ram[read_b[READ_LATENCY-2]];
			end
		end
endmodule










