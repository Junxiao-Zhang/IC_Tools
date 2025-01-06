//===============================================================
// File Name        : mvt_clk_sequence
// Description      :
// Package Name     : mvt_clk_pkg
// Name             : zhangjunxiao
// File Created     : 01/06/2025 @ 05:18 PM
// Copyright        :
//===============================================================
// NOTE: Please Don't Remove Any Comments or //--- Given Below
//===============================================================

`ifndef INC_MVT_CLK_SEQUENCE_SV
`define INC_MVT_CLK_SEQUENCE_SV

//---------------------------------------------------------------
// Class: mvt_clk_sequence
// 
//---------------------------------------------------------------

class mvt_clk_sequence extends uvm_sequence #(mvt_clk_sequence_item_base);
 //------------------------------------------
 // Data Members
 //------------------------------------------

 //------------------------------------------
 // Constraints
 //------------------------------------------

 //------------------------------------------
 // Methods
 //------------------------------------------

 // -----------------
 // Standard UVM Methods
 // -----------------
 extern function       new(string name="mvt_clk_sequence");
 extern virtual task   body();

 // -----------------
 // User Defined APIs
 // -----------------

 // -----------------
 // UVM Factory Registration
 // -----------------
 `uvm_object_utils(mvt_clk_sequence)
endclass: mvt_clk_sequence


//---------------------------------------------------------------
// Function: new
// 
//---------------------------------------------------------------

function mvt_clk_sequence::new(string name="mvt_clk_sequence");
 super.new(name);
endfunction: new


//---------------------------------------------------------------
// Task: body
// 
//---------------------------------------------------------------

task mvt_clk_sequence::body();
 super.body();
endtask: body

`endif //INC_MVT_CLK_SEQUENCE_SV
