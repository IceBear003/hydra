`include "uvm_macros.svh"

import uvm_pkg::*;

`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"

class my_env extends uvm_env;
    my_agent i_agt [16];
    my_agent o_agt [16];
    my_model mdl;
    my_scoreboard scb[16];
    uvm_tlm_analysis_fifo#(my_transaction) agt_mdl_fifo[16];
    uvm_tlm_analysis_fifo#(my_transaction) agt_scb_fifo[16];
    uvm_tlm_analysis_fifo#(my_transaction) agt_sbd_fifo[16];
    uvm_tlm_analysis_fifo#(my_transaction) mdl_sbd_fifo[16];
    uvm_tlm_analysis_fifo#(my_transaction) mdl_scb_fifo[16];
    uvm_tlm_analysis_fifo#(my_transaction) agt_o_mdl_fifo[16];

    function new(string name = "my_env", uvm_component parent);
        super.new(name,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        for(int i=0; i<16; i=i+1) begin
            i_agt[i] = my_agent::type_id::create($sformatf("i_agt[%0d]", i),this);
            o_agt[i] = my_agent::type_id::create($sformatf("o_agt[%0d]", i),this);
            i_agt[i].is_active = UVM_ACTIVE;
            o_agt[i].is_active = UVM_PASSIVE;
            agt_mdl_fifo[i] = new($sformatf("agt_mdl_fifo[%0d]", i),this);
            agt_scb_fifo[i] = new($sformatf("agt_scb_fifo[%0d]", i),this);
            agt_sbd_fifo[i] = new($sformatf("agt_sbd_fifo[%0d]", i),this);
            mdl_sbd_fifo[i] = new($sformatf("mdl_sbd_fifo[%0d]", i),this);
            mdl_scb_fifo[i] = new($sformatf("mdl_scb_fifo[%0d]", i),this);
            agt_o_mdl_fifo[i] = new($sformatf("agt_o_mdl_fifo[%0d]", i),this);
            scb[i] = new($sformatf("scb[%0d]", i),this);
        end
        mdl = new("mdl",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        for(int i=0; i<16; i=i+1) begin
            i_agt[i].mon.ap.connect(agt_mdl_fifo[i].analysis_export);
            mdl.port[i].connect(agt_mdl_fifo[i].blocking_get_export);
            o_agt[i].mon_out.ap.connect(agt_o_mdl_fifo[i].analysis_export);
            mdl.ready[i].connect(agt_o_mdl_fifo[i].blocking_get_export);
            o_agt[i].mon_out.ap.connect(agt_scb_fifo[i].analysis_export);
            scb[i].act_port.connect(agt_scb_fifo[i].blocking_get_export);
            mdl.ap[i].connect(agt_sbd_fifo[i].analysis_export);
            scb[i].exp_port.connect(agt_sbd_fifo[i].blocking_get_export);
            mdl.ap_1[i].connect(mdl_scb_fifo[i].analysis_export);
            scb[i].exp_port_1.connect(mdl_scb_fifo[i].blocking_get_export);
            scb[i].ap.connect(mdl_sbd_fifo[i].analysis_export);
            mdl.act_port[i].connect(mdl_sbd_fifo[i].blocking_get_export);
        end
    endfunction
    `uvm_component_utils(my_env);
endclass