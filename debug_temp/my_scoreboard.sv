`include "uvm_macros.svh"

import uvm_pkg::*;

`include "my_monitor.sv"
`include "my_transaction.sv"

class my_scoreboard extends uvm_scoreboard;
    logic [15:0] expect_queue[$];
    uvm_blocking_get_port#(my_transaction) exp_port;
    uvm_blocking_get_port#(my_transaction) act_port;
    extern function new(string name,uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    `uvm_component_utils(my_scoreboard)
endclass

function my_scoreboard::new(string name,uvm_component parent = null);
    super.new(name,parent);
endfunction

function void my_scoreboard::build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port",this);
    act_port = new("act_port",this);
endfunction

task my_scoreboard::main_phase(uvm_phase phase);
    my_transaction get_expect,get_actual;
    logic [15:0] tmp_tran;
    logic result;
    super.main_phase(phase);
    `uvm_info("my_scoreboard","begin to compare",UVM_LOW);
    fork
        while(1) begin
            //`uvm_info("my_scoreboard","getting expect",UVM_LOW);
            exp_port.get(get_expect);
            $display("expect = %d %d",get_expect.ctrl,get_expect.vld);
            if(get_expect.vld)
                expect_queue.push_back(get_expect.ctrl);
        end
        while(1) begin
            act_port.get(get_actual);
            if(expect_queue.size() > 0 && get_actual.vld) begin
                $display("acutal = %d %d",get_actual.ctrl,get_actual.vld);
                tmp_tran = expect_queue.pop_front();
                result = (get_actual.ctrl == tmp_tran);
                if(result) begin
                    `uvm_info("my_scoreboard","Compare SUCCESSFULLY",UVM_LOW);
                end else begin
                    `uvm_error("my_scoreboard","Compare FAILED");
                    $display("the expect pkt is %d",tmp_tran);
                    $display("the actural pkt is %d",get_actual.ctrl);
                end
            end else if(get_actual.vld) begin
                `uvm_error("my_scoreboard","Received from DUT, while Expected Queue is empty");
                $display("the unexpected pkt is %d",get_actual.ctrl);
            end
        end
    join
endtask