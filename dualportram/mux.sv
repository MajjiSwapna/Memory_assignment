module mux_4to1(input logic [7:0]a,[7:0]b,[7:0]c,[7:0]d,[1:0]sel,output logic [7:0]out);
always @(*) begin
case(sel)
2'b00:out = a;
2'b01:out = b;
2'b10:out = c;
2'b11:out = d;
default:out=0;
endcase
end
endmodule
