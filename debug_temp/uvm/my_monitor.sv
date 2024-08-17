`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
`include "uvm_macros.svh"
`include "my_transaction.sv"

import uvm_pkg::*;

class my_monitor extends uvm_monitor;
    virtual my_if vif;
    uvm_analysis_port#(my_transaction) ap;
    
    `uvm_component_utils(my_monitor);
    function new(string name = "my_monitor",uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap",this);
        if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
            `uvm_fatal("my_driver","virtual interface must be set for vif!");
    endfunction
    
    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(my_transaction tr);
        
endclass
        
task my_monitor::main_phase(uvm_phase phase);
    //phase.raise_objection(this);
    my_transaction tr,tr_out;
    fork
        while(1) begin
            tr = new("tr");
            collect_one_pkt(tr);
            ap.write(tr);
        end
    join
    //phase.drop_objection(this);
endtask

task my_monitor::collect_one_pkt(my_transaction tr);
    logic wr_done = 0;

    while(1) begin
        @(posedge vif.clk);
        if(vif.wr_vld && wr_done == 0) begin
            `uvm_info("my_monitor","begin to collect one pkt",UVM_LOW);
            tr.ctrl = vif.wr_data;
            tr.vld = 1;
            tr.ctrl[47:16] = vif.time_stamp;
            $display("time_stamp = %d",vif.time_stamp);
            ap.write(tr);
            @(posedge vif.clk);
            tr.vld = 0;
            //ap.write(tr);
            wr_done = 1;
            `uvm_info("my_monitor","end collect one pkt",UVM_LOW);
        end else if(vif.wr_eop)
            wr_done = 0;
        ap.write(tr);
    end
    
    //collect only the data
    /*while(1) begin
        @(posedge vif.clk);
        if(vif.wr_eop) break;
    end*/
    //tr.my_print();//print out the data
endtask

class my_monitor_out extends uvm_monitor;
    virtual my_if vif;
    uvm_analysis_port#(my_transaction) ap;
    
    `uvm_component_utils(my_monitor_out);
    function new(string name = "my_monitor_out",uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap",this);
        if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
            `uvm_fatal("my_driver","virtual interface must be set for vif!");
    endfunction
    
    extern task main_phase(uvm_phase phase);
    extern task collect_one_pkt(my_transaction tr);
        
endclass
        
task my_monitor_out::main_phase(uvm_phase phase);
    //phase.raise_objection(this);
    my_transaction tr;
    while(1) begin
        tr = new("tr");
        collect_one_pkt(tr);
        ap.write(tr);
    end
    //phase.drop_objection(this);
endtask

task my_monitor_out::collect_one_pkt(my_transaction tr);
    logic [8:0] len;
    logic cnt_sop = 0;
    fork
        while(1) begin
            @(posedge vif.clk);
            if(vif.ready) begin
                tr.rd_ready = 1;
                ap.write(tr);
                @(posedge vif.clk);
                tr.rd_ready = 0;
                //ap.write(tr);
            end //TO FIX：sop follows tightly after ready
            ap.write(tr);
        end
        while(1) begin
            @(posedge vif.clk);
            if(vif.rd_vld) begin
                `uvm_info("my_monitor_out","begin to collect one pkt",UVM_LOW);
                tr.ctrl = vif.rd_data;
                tr.vld = 1;
                //ap.write(tr);
                len = 2;
                @(posedge vif.clk);
                tr.vld = 0;
                //ap.write(tr);
                while(1) begin
                    @(posedge vif.clk);
                    if(vif.rd_vld)
                        len = len + 1;
                    //ap.write(tr);    
                    if(vif.rd_eop) break;
                end
                if(len - 1 != tr.ctrl[15:7]) begin
                    $display("len = %d %d %d",len - 1,tr.ctrl[15:7],tr.ctrl);
                    `uvm_fatal("my_monitor_out","length not right!");
                end
                `uvm_info("my_monitor_out","end collect one pkt",UVM_LOW);
            end
            //ap.write(tr);
        end
    join
    //collect only the data
    //tr.my_print();//print out the data
endtask

`endif