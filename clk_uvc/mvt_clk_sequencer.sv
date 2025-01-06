//===============================================================
// File Name        : mvt_clk_sequencer
// Description      :
// Package Name     : mvt_clk_pkg
// Name             : zhangjunxiao
// File Created     : 01/06/2025 @ 05:18 PM
// Copyright        :
//===============================================================
// NOTE: Please Don't Remove Any Comments or //--- Given Below
//===============================================================

`ifndef INC_MVT_CLK_SEQUENCER_SV
`define INC_MVT_CLK_SEQUENCER_SV

//---------------------------------------------------------------
// Class: mvt_clk_sequencer
// 
//---------------------------------------------------------------

class mvt_clk_sequencer extends uvm_sequencer #(mvt_clk_sequence_item_base);

 // Standard UVM Methods
 extern function       new   (string name= "mvt_clk_sequencer", uvm_component parent);
 extern function void  build_phase(uvm_phase phase);

 // User Defined APIs

 // UVM Factory Registration Macro
`uvm_component_utils(mvt_clk_sequencer)
endclass: mvt_clk_sequencer


//---------------------------------------------------------------
// Function: new
// 
//---------------------------------------------------------------

function mvt_clk_sequencer::new(string name = "mvt_clk_sequencer", uvm_component parent);
 super.new(name, parent);
endfunction: new


//---------------------------------------------------------------
// Function: build_phase
// 
// Create and configure of testbench structure
//---------------------------------------------------------------

function void mvt_clk_sequencer::build_phase(uvm_phase phase);
 super.build_phase(phase);
`uvm_info(get_type_name(), "In build_phase...!!", UVM_DEBUG);
endfunction: build_phase

`endif //INC_MVT_CLK_SEQUENCER_SV
