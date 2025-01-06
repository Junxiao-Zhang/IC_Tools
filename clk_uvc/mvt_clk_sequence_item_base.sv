//===============================================================
// File Name        : mvt_clk_sequence_item_base
// Description      :
// Package Name     : mvt_clk_pkg
// Name             : zhangjunxiao
// File Created     : 01/06/2025 @ 05:18 PM
// Copyright        :
//===============================================================
// NOTE: Please Don't Remove Any Comments or //--- Given Below
//===============================================================

`ifndef INC_MVT_CLK_SEQUENCE_ITEM_BASE_SV
`define INC_MVT_CLK_SEQUENCE_ITEM_BASE_SV

//---------------------------------------------------------------
// Class: mvt_clk_sequence_item_base
// 
//---------------------------------------------------------------

class mvt_clk_sequence_item_base extends uvm_sequence_item;
 //------------------------------------------
 // Data Members
 //------------------------------------------
 //------------------------------------------

 //------------------------------------------
 // Constraints
 //------------------------------------------
 //------------------------------------------

 //------------------------------------------
 // Methods
 //------------------------------------------
 //------------------------------------------

 // -----------------
 // Standard UVM Methods
 // -----------------
 extern function       new(string name="mvt_clk_sequence_item_base");

 // -----------------
 // User Defined APIs
 // -----------------

 // -----------------
 // UVM Factory Registration
 // -----------------
 `uvm_object_utils_begin(mvt_clk_sequence_item_base)
 // -----------------
 // Add field configurations
 // -----------------
 // -----------------
 `uvm_object_utils_end
endclass: mvt_clk_sequence_item_base


//---------------------------------------------------------------
// Function: new
// 
//---------------------------------------------------------------

function mvt_clk_sequence_item_base::new(string name="mvt_clk_sequence_item_base");
 super.new(name);
endfunction: new

`endif //INC_MVT_CLK_SEQUENCE_ITEM_BASE_SV
