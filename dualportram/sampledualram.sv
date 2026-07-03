`include "hamming_decoder.sv"
`include "hamming_encoder.sv"
module sampledualram #(parameter READ_LATENCY = 2,
	parameter WRITE_LATENCY = 4
	)
	(
	input logic error,input logic[7:0]i_dina,[7:0]i_dinb,input logic [2:0]i_addra,[2:0]i_addrb,
	input logic i_clka,i_clkb,i_ena,i_enb,i_wea,i_web,
	output logic [7:0]o_douta,[7:0]o_doutb
	);
	logic [2:0] write_a [WRITE_LATENCY-1:0];  //an array of 3 bit width and parameterized location of address to store
	logic [11:0] data_a [WRITE_LATENCY-1:0];       //an array of 8 bit width and parameterized location of data to store
	logic [11:0] data_b [WRITE_LATENCY-1:0];
	logic [2:0] write_b [WRITE_LATENCY-1:0];
	logic [11:0] read_a [READ_LATENCY-1:0];           //an array of 8 bit width and parameterized location to store read data
	logic [11:0] read_b [READ_LATENCY-1:0];
	reg [11:0] ram [7:0];                  //a register named as ram with 8 bit width data and 8 address locations
	integer i;
	logic [11:0] i1a_ham;
	logic [11:0] i2a_ham;
	logic [11:0] i1b_ham;
	logic [11:0] i2b_ham;
	hamming_encoder h1a(i1a_ham,1'b1,i_dina);
	hamming_decoder h2a(o_douta,1'b1,i2a_ham);
	hamming_encoder h1b(i1b_ham,1'b1,i_dinb);
	hamming_decoder h2b(o_doutb,1'b1,i2b_ham);
	always@(posedge i_clka) begin
		if(i_ena) begin
			if (i_wea) begin
				write_a[0] <= i_addra;        //address is stored in first bit of write_a
				data_a[0] <= i1a_ham;             //data bits are stored in data_a
				for(i=1;i<=WRITE_LATENCY-1;i++) begin    //a for loop is given to store the data to next bits till the latency completes
					write_a[i]<=write_a[i-1];
				    data_a[i]<= data_a[i-1];
				end
				if(!error) begin   //when addresses of port A and port B are not equal
					ram[write_a[WRITE_LATENCY-1]] <= data_a[WRITE_LATENCY-1]; //assign the data into the address after latency completes
				end
			end
			else begin         //when wea=0
				read_a[0] <= ram[i_addra];      //to read data,address is given to 1st bit of read_a
				for(i=1;i <= READ_LATENCY-1 ;i++) begin  //till latency reaches the for loop iterates
					read_a[i] <= read_a[i-1]; //the past data value is assigned to next bit to store
				end
			end
		end
	end
	assign i2a_ham = read_a[READ_LATENCY-1]; //after latency completes,read_a assigns the value douta
	always @(posedge i_clkb) begin
		if(i_enb) begin
			if(i_web) begin
				write_b[0]<= i_addrb;  //address is stored in first bit of write_b
		       	data_b[0] <= i1b_ham;    //data bits are stored in data_b
				for(i=1;i<=WRITE_LATENCY-1;i++) begin //a for loop is given to store the data to next bits till the latency completes
					write_b[i]<=write_b[i-1];
					data_b[i]<= data_b[i-1];
				end
				if(!error) begin  //when addresses of port A and port B are not equal
					ram[write_b[WRITE_LATENCY-1]] <= data_b[WRITE_LATENCY-1]; //assign the data into the address after latency completes
				end
			end
			else begin      //when wea=0
				read_b[0] <= ram[i_addrb];     //to read data,address is given to 1st bit of read_b
				for(i=1;i<=READ_LATENCY-1;i++) begin   //till latency reaches the for loop iterates
					read_b[i] <= read_b[i-1];  //the past data value is assigned to next bit to store
				end
			end
		end
	end
	assign i2b_ham = read_b[READ_LATENCY-1];   //after latency completes,read_b assigns the value doutb
endmodule


