`include "para_m_bank.sv"

package mem_pkg;

	parameter READ_LATENCY = 2;
	parameter WRITE_LATENCY = 2;
	parameter DATA_WIDTH = 8;
	parameter N_DEPTH = 32;
	parameter ADDR_WIDTH = 5;

endpackage

import mem_pkg::*;


interface mem_if;

	logic [ADDR_WIDTH-1:0] i_addra;
    logic [DATA_WIDTH-1:0] i_dina;
  	logic i_clka, i_ena, i_wea;
  	logic [DATA_WIDTH-1:0] o_douta;
  	logic [ADDR_WIDTH-1:0] i_addrb;
  	logic [DATA_WIDTH-1:0] i_dinb;
  	logic i_clkb, i_enb, i_web;
  	logic [DATA_WIDTH-1:0] o_doutb;

endinterface

class transaction;

	rand bit [ADDR_WIDTH-1:0] i_addra;
	rand bit [ADDR_WIDTH-1:0] i_addrb;
	rand bit [DATA_WIDTH-1:0] i_dina;
	rand bit [DATA_WIDTH-1:0] i_dinb;
	rand bit i_ena;
	rand bit i_enb;
	rand bit i_wea;
	rand bit i_web;
	bit [DATA_WIDTH-1:0] o_douta;
	bit [DATA_WIDTH-1:0] o_doutb;

	constraint ena{
		i_ena dist {0:= 10 , 1:= 90};
		}
	constraint enb{
		i_enb dist {0:= 10 , 1:= 90};
		}
	constraint wea{
		i_wea dist {0:= 40 , 1:= 60};
		}
	constraint web{
		i_web dist {0:= 40 , 1:= 60};
		}

	function void display(input string name);
		$display("(%s)	addr_a=%d	addr_b=%d	i_dina=%d	i_dinb=%d	o_douta=%d	o_doutb=%d",name,i_addra,i_addrb,i_dina,i_dinb,o_douta,o_doutb);
	endfunction

	function transaction copy();
		copy = new();
		copy.i_addra = this.i_addra;
		copy.i_addrb = this.i_addrb;
		copy.i_dina = this.i_dina;
		copy.i_dinb = this.i_dinb;
		copy.o_douta = this.o_douta;
		copy.o_doutb = this.o_doutb;
		copy.i_ena = this.i_ena;
		copy.i_enb = this.i_enb;
		copy.i_wea = this.i_wea;
		copy.i_web = this.i_web;
	endfunction

endclass

class generator;

	transaction trans;
	mailbox #(transaction) mbx;
	event stop;

	function new(mailbox #(transaction) mbx);
		this.mbx = mbx;
		trans = new();
	endfunction

	task run();
		for(int i=0;i<200;i++) begin
			trans.randomize();
			mbx.put(trans.copy);
			$display("[GEN]	DATA SENT");
			trans.display("GENERATOR");
		end
		-> stop;
	endtask
endclass

class driver;

	transaction data;
	mailbox #(transaction) mbx;
	virtual mem_if mif;

	function new(mailbox #(transaction) mbx);
		this.mbx = mbx;
	endfunction

	task run();
		forever begin
			mbx.get(data);
			@(posedge mif.i_clka);
			mif.i_dina <= data.i_dina;
			mif.i_addra <= data.i_addra;
			mif.i_ena <= data.i_ena;
			mif.i_wea <= data.i_wea;
			@(posedge mif.i_clkb);
			mif.i_dinb <= data.i_dinb;
			mif.i_addrb <= data.i_addrb;
			mif.i_enb <= data.i_enb;
			mif.i_web <= data.i_web;
			$display("[DRV] INTERFACE TRIGGER");
			data.display("DRIVER");
		end
	endtask
endclass

class monitor;

	mailbox #(transaction) mon2sco;
	virtual mem_if mif;
	transaction trans;

	function new(mailbox #(transaction) mon2sco);
		this.mon2sco = mon2sco;
	endfunction

	task run();
		forever begin
			trans = new();
			@(posedge mif.i_clka);
			trans.i_addra = mif.i_addra;
			trans.i_ena = mif.i_ena;
			trans.i_dina = mif.i_dina;
			trans.i_wea = mif.i_wea;
			@(posedge mif.i_clkb);
			trans.i_addrb = mif.i_addrb;
			trans.i_dinb = mif.i_dinb;
			trans.i_enb = mif.i_enb;
			trans.i_web = mif.i_web;
			$display("DATA SENT TO MONITOR");
			mon2sco.put(trans);
			trans.display("MONITOR");
		end
	endtask
endclass




module tb_mbc();

mem_if mif();
generator gen;
driver drv;
transaction trans;
monitor mon;
event stop;

mailbox #(transaction) mbx;
mailbox #(transaction) mon2sco;

para_m_bank #(
	  .READ_LATENCY(READ_LATENCY),
	  .WRITE_LATENCY(WRITE_LATENCY),
	  .DATA_WIDTH(DATA_WIDTH),
	  .ADDR_WIDTH(ADDR_WIDTH),
	  .N_DEPTH(N_DEPTH)) uut (
      mif.i_addra,
      mif.i_addrb,
      mif.i_dina,
      mif.i_dinb,
      mif.i_clka,
      mif.i_clkb,
      mif.i_ena,
      mif.i_enb,
      mif.i_wea,
      mif.i_web,
      mif.o_douta,
      mif.o_doutb
  );

  initial begin
	  mif.i_clka <= 0;
	  mif.i_clkb <= 0;
  end

  always #1 mif.i_clka <= ~mif.i_clka;
  always #1 mif.i_clkb <= ~mif.i_clkb;

  initial begin
	  mbx = new();
	  mon2sco = new();
	  drv = new(mbx);
	  gen = new(mbx);
	  mon = new(mon2sco);
	  drv.mif = mif;
	  mon.mif = mif;
	  stop = gen.stop;

	  fork
		  gen.run();
		  drv.run();
		  mon.run();
	  join_none
	  wait(stop.triggered);
	  $finish;
  end

endmodule


















