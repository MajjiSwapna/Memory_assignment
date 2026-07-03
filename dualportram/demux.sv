module demux_1to4(input logic a,[1:0]sel,output logic [3:0]out);
always@(*) begin
 out=4'b0;
	case(sel)
		2'b00:out[0]= a;
		2'b01:out[1]= a;
		2'b10:out[2]= a;
		2'b11:out[3]= a;
		default:out=4'b0;
	endcase
end
endmodule

