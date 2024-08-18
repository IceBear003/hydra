
`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "my_transaction.sv"

class my_driver extends uvm_driver;
    virtual my_if vif;
    int vr;
    int time_stamp;
    `uvm_component_utils(my_driver);
    function new(string name = "my_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("my_driver","build_phase is called",UVM_LOW);
        if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
            `uvm_fatal("my_driver","virtual interface must be set for vif!");
        if(!uvm_config_db#(int)::get(this,"","vr",vr))
            `uvm_fatal("my_driver","virtual interface must be set for vif!");
        //if(!uvm_config_db#(int)::get(this,"","time_stamp",time_stamp))
        //    `uvm_fatal("my_driver","virtual interface must be set for vif!");
    endfunction

    extern virtual task main_phase(uvm_phase phase);
    extern virtual task drive_one_pkt(my_transaction tr);
    
endclass

task my_driver::drive_one_pkt(my_transaction tr);
    `uvm_info("my_driver","begin to drive one pkt",UVM_LOW);
    //$display("vif.clk = %d %d",vif.clk,time_stamp);
    vif.time_stamp = tr.ctrl[47:16];
    @(posedge vif.clk); vif.wr_sop <= 1;
    @(posedge vif.clk); vif.wr_sop <= 0;
    @(posedge vif.clk);
    vif.wr_vld <= 1;
    vif.wr_data <= tr.ctrl;
    //vif.wr_data[6:0] <= $random;
    //$display("data_size = %d",tr.ctrl);
    for(int i=0; i<tr.ctrl[15:7]; i=i+1) begin
        while(vif.pause) begin
            @(posedge vif.clk);
        end
        @(posedge vif.clk);
        vif.wr_vld <= 1;
        vif.wr_data <= i;
    end
    @(posedge vif.clk); vif.wr_vld <= 0;
    @(posedge vif.clk); vif.wr_eop <= 1;
    @(posedge vif.clk); vif.wr_eop <= 0;
    @(posedge vif.clk);
    //pull the data to vif
    `uvm_info("my_driver","end drive one pkt",UVM_LOW);
endtask

task my_driver::main_phase(uvm_phase phase);
    my_transaction tr;
    bit [9:0] len;
    phase.raise_objection(this);
    while(!vif.rst_n) begin
        time_stamp = time_stamp + 1;
        @(posedge vif.clk);
    end
    fork
        while(1) begin
            time_stamp = time_stamp + 1;
            @(posedge vif.clk);
        end
        for(int i = 0; i < 100; i = i + 1) begin
            while(vr[3:0] != (time_stamp[4:0] >> 1)) begin
                @(posedge vif.clk);
            end
            len = $random;
            $display("port in number = %d %d %d",vr,i,time_stamp[4:0]);
            tr = new("tr");
            tr.ctrl = len;
            tr.vld = 0;
            if(len < 31) len = 31;
            if(len > 1023) len = 1023;
            tr.ctrl[15:7] = len;
            /*if(vr < 7) begin
                //tr.ctrl[6:4] = 1;
                tr.ctrl[3:0] = 1;
            end else if(vr < 14) begin
                tr.ctrl[3:0] = 2;
            end*/
            tr.ctrl[47:16] = time_stamp;
            drive_one_pkt(tr);
            
        end
    join
    //#1000
    //phase.drop_objection(this);
    
endtask

`endif 
