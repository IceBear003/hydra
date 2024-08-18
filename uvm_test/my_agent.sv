`ifndef MY_AGENT__SV
`define MY_AGENT__SV
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "my_transaction.sv"
`include "my_driver.sv"
`include "hydra.sv" 
`include "my_monitor.sv"

class my_agent extends uvm_agent;
    my_driver drv;
    my_monitor mon;
    my_monitor_out mon_out;
    function new(string name,uvm_component parent = null);
        super.new(name,parent);
    endfunction
    
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    
    `uvm_component_utils(my_agent);

endclass

function void my_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv = my_driver::type_id::create("drv",this);
        mon = my_monitor::type_id::create("mon",this);
    end
    if(is_active == UVM_PASSIVE)
        mon_out = my_monitor_out::type_id::create("mon_out",this);
    //if(!uvm_config_db#(virtual my_if)::get(drv,"","vif",drv.vif))
    //    `uvm_fatal("my_driver","virtual interface must be set for vif!");
endfunction

function void my_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

`endif