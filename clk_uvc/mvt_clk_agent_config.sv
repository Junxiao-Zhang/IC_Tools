//===============================================================
// File Name        : mvt_clk_agent_config
// Description      :
// Package Name     : mvt_clk_pkg
// Name             : zhangjunxiao
// File Created     : 01/06/2025 @ 05:18 PM
// Copyright        :
//===============================================================
// NOTE: Please Don't Remove Any Comments or //--- Given Below
//===============================================================

`ifndef INC_MVT_CLK_AGENT_CONFIG_SV
`define INC_MVT_CLK_AGENT_CONFIG_SV

//---------------------------------------------------------------
// Class: mvt_clk_agent_config
// 
//---------------------------------------------------------------

class mvt_clk_agent_config extends uvm_object;
 //------------------------------------------
 // Data Members
 //------------------------------------------
 rand uvm_active_passive_enum is_active = UVM_ACTIVE;

 //------------------------------------------
 // Agent Interface Instantiation
 //------------------------------------------

 //------------------------------------------
 // Agent Monitor Knobs
 //------------------------------------------

 //------------------------------------------
 // Agent Driver Knobs
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
 extern function       new(string name="mvt_clk_agent_config");

 // -----------------
 // User Defined APIs
 // -----------------

 // -----------------
 // UVM Factory Registration
 // -----------------
 `uvm_object_utils_begin(mvt_clk_agent_config)
  // -----------------
  // Add field configurations
  // -----------------
  // -----------------
 `uvm_object_utils_end
endclass: mvt_clk_agent_config


//---------------------------------------------------------------
// Function: new
// 
//---------------------------------------------------------------

function mvt_clk_agent_config::new(string name="mvt_clk_agent_config");
 super.new(name);

 // -----------------
 // Get configuration
 // -----------------


 // -----------------
 // Construct children
 // ------------------


 // ------------------
 // Configure children
 // ------------------
endfunction: new

`endif //INC_MVT_CLK_AGENT_CONFIG_SV
