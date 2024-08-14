`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV
`include "uvm_macros.svh"

import uvm_pkg::*;

class my_transaction extends uvm_sequence_item;
    /*rand bit sop;
    rand bit eop;
    rand bit vld;
    rand bit [15:0] data[];
    constraint data_cons{
        data.size >= 32;
        data.size <= 512;
    }*/
    logic [47:0] ctrl;
    bit vld;
    bit rd_ready;
    //...
    `uvm_object_utils(my_transaction);
    function new(string name = "my_transaction");
        super.new(name);
    endfunction
endclass

`endif