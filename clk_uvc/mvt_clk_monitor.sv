//===============================================================
// File Name        : mvt_clk_monitor
// Description      :
// Package Name     : mvt_clk_pkg
// Name             : zhangjunxiao
// File Created     : 01/06/2025 @ 05:18 PM
// Copyright        :
//===============================================================
// NOTE: Please Don't Remove Any Comments or //--- Given Below
//===============================================================

`ifndef INC_MVT_CLK_MONITOR_SV
`define INC_MVT_CLK_MONITOR_SV

//---------------------------------------------------------------
// Class: mvt_clk_monitor
// 
//---------------------------------------------------------------

class mvt_clk_monitor extends uvm_monitor;
 //------------------------------------------
 // Data Members
 //------------------------------------------

 //------------------------------------------
 // Interface Instantiation
 //------------------------------------------

 //------------------------------------------
 // Agent Configuration Instantiation
 //------------------------------------------

 //------------------------------------------
 // Constraints
 //------------------------------------------

 //--------------------------------------------
 // Port Declaration
 //--------------------------------------------

 //------------------------------------------
 // Methods
 //------------------------------------------

 // -----------------
 // Standard UVM Methods
 // -----------------
 extern function              new(string name= "mvt_clk_monitor", uvm_component parent);
 extern virtual function void build_phase(uvm_phase phase);
 extern virtual function void connect_phase(uvm_phase phase);
 extern virtual function void end_of_elaboration_phase(uvm_phase phase);
 extern virtual function void start_of_simulation_phase(uvm_phase phase);
 extern virtual task          run_phase(uvm_phase phase);
 extern virtual function void extract_phase(uvm_phase phase);
 extern virtual function void check_phase(uvm_phase phase);
 extern virtual function void report_phase(uvm_phase phase);
 extern virtual function void final_phase(uvm_phase phase);

 // -----------------
 // User Defined APIs
 // -----------------

 // -----------------
 // UVM Factory Registration
 // -----------------
 `uvm_component_utils_begin(mvt_clk_monitor)
  // -----------------
  // Add field configurations
  // -----------------
  // -----------------
 `uvm_component_utils_end
endclass :mvt_clk_monitor


//---------------------------------------------------------------
// Function: new
// 
//---------------------------------------------------------------

function mvt_clk_monitor::new(string name = "mvt_clk_monitor", uvm_component parent);
 super.new(name, parent);
endfunction :new


//---------------------------------------------------------------
// Function: build_phase
// 
// Create and configure of testbench structure
//---------------------------------------------------------------

function void mvt_clk_monitor::build_phase(uvm_phase phase);
 super.build_phase(phase);
`uvm_info(get_type_name(), "In build_phase...!!", UVM_DEBUG);

 // -----------------
 // Port Construction
 // -----------------

 // -----------------
 // Get configuration
 // -----------------

 // Get Agent Configuration

 // -----------------
 // Construct children
 // ------------------

 // ------------------
 // Configure children
 // ------------------
endfunction: build_phase


//---------------------------------------------------------------
// Function: connect_phase
// 
// Establish cross-component connections
//---------------------------------------------------------------

function void mvt_clk_monitor::connect_phase(uvm_phase phase);
 super.connect_phase(phase);
`uvm_info(get_type_name(), "In connect_phase...!!", UVM_DEBUG);
endfunction: connect_phase


//---------------------------------------------------------------
// Task: run_phase
// 
// Stimulate the DUT
//---------------------------------------------------------------

task mvt_clk_monitor::run_phase(uvm_phase phase);
 super.run_phase(phase);
`uvm_info(get_type_name(), "In run_phase...!!", UVM_DEBUG);
endtask: run_phase


//---------------------------------------------------------------
// Function: end_of_elaboration_phase
// 
// Fine-tune the testbench
//---------------------------------------------------------------

function void mvt_clk_monitor::end_of_elaboration_phase(uvm_phase phase);
 super.end_of_elaboration_phase(phase);
`uvm_info(get_type_name(), "In end_of_elaboration_phase...!!", UVM_DEBUG);
endfunction: end_of_elaboration_phase


//---------------------------------------------------------------
// Function: start_of_simulation_phase
// 
// Get ready for DUT to be simulated
//---------------------------------------------------------------

function void mvt_clk_monitor::start_of_simulation_phase(uvm_phase phase);
 super.start_of_simulation_phase(phase);
`uvm_info(get_type_name(), "In start_of_simulation_phase...!!", UVM_DEBUG);
endfunction: start_of_simulation_phase


//---------------------------------------------------------------
// Function: extract_phase
// 
// Extract data from different points of the verification environment
//---------------------------------------------------------------

function void mvt_clk_monitor::extract_phase(uvm_phase phase);
 super.extract_phase(phase);
`uvm_info(get_type_name(), "In extract_phase...!!", UVM_DEBUG);
endfunction: extract_phase


//---------------------------------------------------------------
// Function: check_phase
// 
// Check for any unexpected conditions in the verification environment
//---------------------------------------------------------------

function void mvt_clk_monitor::check_phase(uvm_phase phase);
 super.check_phase(phase);
`uvm_info(get_type_name(), "In check_phase...!!", UVM_DEBUG);
endfunction: check_phase


//---------------------------------------------------------------
// Function: report_phase
// 
// Report results of the test
//---------------------------------------------------------------

function void mvt_clk_monitor::report_phase(uvm_phase phase);
 super.report_phase(phase);
`uvm_info(get_type_name(), "In report_phase...!!", UVM_DEBUG);
endfunction: report_phase


//---------------------------------------------------------------
// Function: final_phase
// 
// Tie up loose ends. All Simulation activities are done.
// 
// Closing files, Ending co-simulation engines etc.
//---------------------------------------------------------------

function void mvt_clk_monitor::final_phase(uvm_phase phase);
 super.final_phase(phase);
`uvm_info(get_type_name(), "In final_phase...!!", UVM_DEBUG);
endfunction: final_phase


`endif //INC_MVT_CLK_MONITOR_SV
