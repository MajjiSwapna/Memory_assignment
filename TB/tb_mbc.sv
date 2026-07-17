`include "para_m_bank.sv"

package mem_pkg;

  parameter READ_LATENCY = 3;
  parameter WRITE_LATENCY = 3;
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

  constraint ena {
    i_ena dist {
      0 := 10,
      1 := 90
    };
  }
  constraint enb {
    i_enb dist {
      0 := 10,
      1 := 90
    };
  }
  constraint wea {
    i_wea dist {
      0 := 40,
      1 := 60
    };
  }
  constraint web {
    i_web dist {
      0 := 40,
      1 := 60
    };
  }

  function void display(input string name);
    $display("(%s)	%0t	addr_a=%d	addr_b=%d	i_dina=%d	i_dinb=%d	o_douta=%d	o_doutb=%d", name, $time,
             i_addra, i_addrb, i_dina, i_dinb, o_douta, o_doutb);
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

  function new(mailbox#(transaction) mbx);
    this.mbx = mbx;
    trans = new();
  endfunction

  task run();
    for (int i = 0; i < 200; i++) begin
      trans.randomize();
      mbx.put(trans.copy);
      $display("[GEN]	DATA SENT");
      trans.display("GENERATOR");
    end
    ->stop;
  endtask

endclass

class driver;

  transaction data;
  mailbox #(transaction) mbx;
  virtual mem_if mif;

  function new(mailbox#(transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run();
    forever begin
      mbx.get(data);
      @(posedge mif.i_clka);
      mif.i_dina  <= data.i_dina;
      mif.i_addra <= data.i_addra;
      mif.i_ena   <= data.i_ena;
      mif.i_wea   <= data.i_wea;
      @(posedge mif.i_clkb);
      mif.i_dinb  <= data.i_dinb;
      mif.i_addrb <= data.i_addrb;
      mif.i_enb   <= data.i_enb;
      mif.i_web   <= data.i_web;
      $display("[DRV] INTERFACE TRIGGER");
      data.display("DRIVER");
    end
  endtask

endclass

class monitor;

  mailbox #(transaction) mon2scoA;
  mailbox #(transaction) mon2scoB;
  virtual mem_if mif;
  transaction tr;

  typedef struct {
    transaction tr;
    int delay;
  } pending_read_t;

  pending_read_t read_qA[$];
  pending_read_t read_qB[$];

  function new(mailbox#(transaction) mon2scoA, mailbox#(transaction) mon2scoB);
    this.mon2scoA = mon2scoA;
    this.mon2scoB = mon2scoB;
  endfunction

  task monitor_A();
    forever begin
      @(posedge mif.i_clka);
      tr = new();
      tr.i_addra = mif.i_addra;
      tr.i_ena = mif.i_ena;
      tr.i_dina = mif.i_dina;
      tr.i_wea = mif.i_wea;

      if (tr.i_ena && tr.i_wea) begin
        mon2scoA.put(tr);
        $display("[MON-A] WRITE SENT");
        tr.display("MONITOR-A");
      end

      if (tr.i_ena && !tr.i_wea) begin
        pending_read_t temp;
        temp.tr = tr;
        temp.delay = READ_LATENCY + 1;
        read_qA.push_back(temp);
      end

      for (int i = read_qA.size() - 1; i >= 0; i--) begin
        read_qA[i].delay--;

        if (read_qA[i].delay == 0) begin
          read_qA[i].tr.o_douta = mif.o_douta;
          mon2scoA.put(read_qA[i].tr);
          $display("[MON-A] READ SENT");
          read_qA[i].tr.display("MONITOR-A");
          read_qA.delete(i);
        end
      end

    end
  endtask

  task monitor_B();
    forever begin
      @(posedge mif.i_clkb);
      tr = new();
      tr.i_addrb = mif.i_addrb;
      tr.i_dinb = mif.i_dinb;
      tr.i_enb = mif.i_enb;
      tr.i_web = mif.i_web;

      if (tr.i_enb && tr.i_web) begin
        mon2scoB.put(tr);
        $display("[MON-B] WRITE SENT");
        tr.display("MONITOR-B");
      end

      if (tr.i_enb && !tr.i_web) begin
        pending_read_t temp;
        temp.tr = tr;
        temp.delay = READ_LATENCY + 1;
        read_qB.push_back(temp);
      end

      for (int i = read_qB.size() - 1; i >= 0; i--) begin
        read_qB[i].delay--;

        if (read_qB[i].delay == 0) begin
          read_qB[i].tr.o_doutb = mif.o_doutb;
          mon2scoB.put(read_qB[i].tr);
          $display("[MON-B] READ SENT");
          read_qB[i].tr.display("MONITOR-B");
          read_qB.delete(i);
        end
      end
    end
  endtask

  task run();
    fork
      monitor_A();
      monitor_B();
    join_none
  endtask
endclass

class scoreboard;

  mailbox #(transaction) mon2scoA;
  mailbox #(transaction) mon2scoB;

  transaction transA;
  transaction transB;

  virtual mem_if mif;

  //reference memory
  bit [7:0] ref_ram[31:0];

  typedef struct {
    transaction tr;
    int delay;
  } pending_write_t;
  pending_write_t write_qA[$];
  pending_write_t write_qB[$];

  function new(mailbox#(transaction) mon2scoA, mailbox#(transaction) mon2scoB);
    this.mon2scoA = mon2scoA;
    this.mon2scoB = mon2scoB;
  endfunction

  task check_A();
    forever begin
      logic [7:0] expected_a;
      mon2scoA.get(transA);

      //WRITE operation
      if (transA.i_ena && transA.i_wea) begin
        pending_write_t temp;
        temp.tr = new();
        temp.tr.i_addra = transA.i_addra;
        temp.tr.i_dina = transA.i_dina;
        temp.tr.i_wea = transA.i_wea;
        temp.tr.i_ena = transA.i_ena;

        temp.delay = WRITE_LATENCY;

        write_qA.push_back(temp);
        $display("%0t PUSH_A : Addr=%0d Data=%0d", $time, transA.i_addra, transA.i_dina);
      end

      //READ operation
      if (transA.i_ena && !transA.i_wea) begin
        expected_a = ref_ram[transA.i_addra];
        if (expected_a == transA.o_douta) begin  // Compare with DUT output
          $display("---------------------------------------");
          $display("PASS PORTA: %0t	Addr=%0d Expected=%0d Actual=%0d", $time, transA.i_addra,
                   expected_a, transA.o_douta);
          $display("---------------------------------------");
        end else begin
          $display("---------------------------------------");
          $display("FAIL PORTA : %0t	Addr=%0d Expected=%0d Actual=%0d", $time, transA.i_addra,
                   expected_a, transA.o_douta);
          $display("---------------------------------------");
        end
      end
    end
  endtask

  task update_A();
    forever begin
      @(posedge mif.i_clka);
      for (int i = write_qA.size() - 1; i >= 0; i--) begin
        write_qA[i].delay--;
        if (write_qA[i].delay == 0) begin
          ref_ram[write_qA[i].tr.i_addra] = write_qA[i].tr.i_dina;
          $display("%0t UPDATE_A : Addr=%0d Data=%0d Delay=%0d QueueSize=%0d", $time,
                   write_qA[i].tr.i_addra, write_qA[i].tr.i_dina, write_qA[i].delay,
                   write_qA.size());
          write_qA.delete(i);
        end
      end
    end
  endtask

  task check_B();
    forever begin
      logic [7:0] expected_b;
      mon2scoB.get(transB);

      if (transB.i_enb && transB.i_web) begin
        pending_write_t temp;
        temp.tr = new();
        temp.tr.i_addrb = transB.i_addrb;
        temp.tr.i_dinb = transB.i_dinb;
        temp.tr.i_web = transB.i_web;
        temp.tr.i_enb = transB.i_enb;

        temp.delay = WRITE_LATENCY;

        write_qB.push_back(temp);
        $display("%0t PUSH_B : Addr=%0d Data=%0d", $time, transB.i_addrb, transB.i_dinb);
      end

      //READ operation
      if (transB.i_enb && !transB.i_web) begin
        expected_b = ref_ram[transB.i_addrb];
        if (expected_b == transB.o_doutb) begin
          $display("---------------------------------------");
          $display("PASS PORTB: %0t	Addr=%0d Expected=%0d Actual=%0d", $time, transB.i_addrb,
                   expected_b, transB.o_doutb);
          $display("---------------------------------------");
        end else begin
          $display("---------------------------------------");
          $display("FAIL PORTB: %0t	Addr=%0d Expected=%0d Actual=%0d", $time, transB.i_addrb,
                   expected_b, transB.o_doutb);
          $display("---------------------------------------");
        end
      end
    end
  endtask

  task update_B();
    forever begin
      @(posedge mif.i_clkb);
      for (int i = write_qB.size() - 1; i >= 0; i--) begin
        write_qB[i].delay--;
        if (write_qB[i].delay == 0) begin
          ref_ram[write_qB[i].tr.i_addrb] = write_qB[i].tr.i_dinb;
          $display("%0t UPDATE_B : Addr=%0d Data=%0d Delay=%0d QueueSize=%0d", $time,
                   write_qB[i].tr.i_addrb, write_qB[i].tr.i_dinb, write_qB[i].delay,
                   write_qB.size());
          write_qB.delete(i);
        end
      end
    end
  endtask

  task run();
    fork
      check_A();
      check_B();
      update_A();
      update_B();
    join_none
  endtask
endclass


module tb_mbc ();

  mem_if mif ();
  generator gen;
  driver drv;
  transaction trans;
  monitor mon;
  scoreboard sco;
  event stop;

  mailbox #(transaction) mbx;
  mailbox #(transaction) mon2scoA;
  mailbox #(transaction) mon2scoB;

  para_m_bank #(
      .READ_LATENCY(READ_LATENCY),
      .WRITE_LATENCY(WRITE_LATENCY),
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .N_DEPTH(N_DEPTH)
  ) uut (
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
    mon2scoA = new();
    mon2scoB = new();
    drv = new(mbx);
    gen = new(mbx);
    mon = new(mon2scoA, mon2scoB);
    sco = new(mon2scoA, mon2scoB);
    drv.mif = mif;
    mon.mif = mif;
    sco.mif = mif;
    stop = gen.stop;

    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none
    wait (stop.triggered);
    $finish;
  end

endmodule


















