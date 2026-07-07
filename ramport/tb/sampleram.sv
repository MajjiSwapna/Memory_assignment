
module tb_ramport();
  logic clk, en, we;
  logic [7:0] din;
  logic [2:0] addr;
  logic [7:0] dout;
  ramport uut (
      din,
      addr,
      clk,
      en,
      we,
      dout
  );
  always #2 clk = ~clk;

  task tc1();
    clk  = 1;
    din  = 8'd23;
    addr = 3'd3;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd45;
    addr = 3'd1;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
endtask

task tc2();
    din  = 8'd3;
    addr = 3'd2;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
    din  = 8'd66;
    addr = 3'd5;
    en   = 1;
    we   = 1;
    repeat (4) @(posedge clk);
endtask

task tc3();
    din  = 8'd21;
    addr = 3'd4;
    en   = 0;
    we   = 1;
    repeat (4) @(posedge clk);
    addr = 3'd3;
    en   = 1;
    we   = 0;
    repeat (4) @(posedge clk);
    addr = 3'd1;
    en   = 1;
    we   = 0;
    repeat (4) @(posedge clk);
    addr = 3'd5;
    en   = 1;
    we   = 0;
endtask
initial begin
  $monitor("din %d,addr %d,dout %d",din,addr,dout);
end
initial begin
    clk  = 0;
    din  = 0;
    addr = 0;
    en   = 0;
    we   = 0;
	if($test$plusargs("TC1")) begin
		tc1();
	end
	if($test$plusargs("TC2")) begin
		tc2();
	end
	if($test$plusargs("TC3")) begin
		tc3();
	end
	if($test$plusargs("TC4")) begin
	    tc1();
		tc2();
	end
	if($test$plusargs("TC5")) begin
	    tc3();
		tc2();
	end
	if($test$plusargs("TC6")) begin
	    tc1();
		tc3();
	end
	if($test$plusargs("TC7")) begin
		tc1();
		tc2();
		tc3();
	end
	repeat(12) @(posedge clk);
	$finish;
   end
endmodule
