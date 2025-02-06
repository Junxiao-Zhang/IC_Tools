//  Copyright 2024 Junxiao.Zhang(junxiaozhang95@gmail.com)
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.//

//#######################################################################################
//    Rev    |  Date       |  Author  |  Change Description
//   -------------------------------------------------------------------------------------
//    0.1    |  2024-12-12 |  Junxiao |  Initial version 

// The Reference of GDDR6 SDRAM is JESD250D, which can be downloaded from JEDEC website(https://www.jedec.org/standards-documents/docs/jesd250d).

// Define Turth Tablel Command for GDDR6
`define NOP1 5'b00000
`define NOP2 5'b00001
`define NOP3 5'b00010
`define MRS 5'b00011
`define ACT 5'b00100
`define RD 5'b00101
`define RDA 5'b00110
`define LDFF 5'b00111
`define RDTR 5'b01000
`define WOM 5'b01001
`define WOMA 5'b01010
`define WDM 5'b01011
`define WDMA 5'b01100
`define WSM 5'b01101
`define WSMA 5'b01110
`define WRTR 5'b01111
`define PREpb 5'b10000
`define PREab 5'b10001 
`define REFpb 5'b10010 
`define REFab 5'b10011 
`define PDE 5'b10100
`define PDX 5'b10101
`define SRE 5'b10110 
`define SRX 5'b10111 
`define CAT 5'b11000 

// Define Bank Number
`define BANK_NUM 16

// Define Signal Level, improve readability
`define TRUE 1
`define FALSE 0
`define HIGH 1
`define LOW 0

// Define clock period : it is better to monitor the clock period in the simulation,but for simplicity, it is defined here.
// Assume the commnad freq is 800MHz, the clock period is 1.25ns
`define tCK 1.25 //ns 

// Define the AC timing parameter
`define tCCD_S 2
`define tCCD_L 4

// Define the bank relationship
`define SAME_BANK 2'b00
`define DIFF_BANK 2'b01
`define SAME_GROUP 2'b10
`define IGNORE 2'b11


module gddr6_channel_checker (
    // CA Clocks  
    input CLK_t,
    input CLK_c,
    // Reset
    input RESET_n,
    // Write Clocks
    input WCK0_t,
    input WCK0_c,
    input WCK1_t,
    input WCK1_c,
    // Clock Enable
    input CKE_n,
    // Command/Address
    input [10:0] CA,
    // CABI
    input CABI_n,
    // DQ 
    input [15:0] DQ,
    // DBI 
    input [1:0] DBI_n
);

    // use this to record the command issuse time
    real current_time;

    // It is best to check the MRS command to obtain the MR configuration. However, for simplicity, variables are used here directly.
    bit MR1_CABI_value;  // Mode Register 1 OP10: Command Address Bus Inversion
    bit [1:0] MR3_Bank_Group_value;  // Mode Register 3 OP10: Bank Group 

    // command address bus value sampled at rising and falling edge of CLK_t 
    logic [10:0] CA_rising, CA_falling;

    // command info decoded from command address bus
    logic [3:0] bank;
    logic [1:0] bank_group;
    logic [3:0] gddr_cmd;
    logic [7:0] col_addr;
    logic [14:0] row_addr;

    // command & pre command
    logic [4:0] gddr_command, pre_gddr_command;

    // record the command issue time, total 16 banks
    real  pre_read_command_time[`BANK_NUM];

    // declare the command event
    logic command_event;

    // declare the command flag
    logic rd_flag;

    // Command Decoder 
    always @(posedge CLK_t) begin
        // JESD250D, Page 19, Chapter 4.2 
        // Deconde command bus. If command address bus inversion is enabled, invert the command address bus.
        // if CABI_n == 1'b0, invert the command address bus. Otherwise, do not invert the command address bus.
        if (MR1_CABI_value == `TRUE && CABI_n == 1'b0) CA_rising = ~CA;
        else CA_rising = CA;
        @(negedge CLK_t)
        if (MR1_CABI_value == `TRUE && CABI_n == 1'b0) CA_falling = ~CA;
        else CA_falling = CA;
        // JEDEC JESD250D, Page 76， Chapter 7.1
        // refer to Command Truth Table: get command type, bank group, bank, row, column, etc.
        gddr_cmd = {CA_rising[9:8], CA_falling[9:8]};
        bank = CA_rising[7:4];
        bank_group = CA_rising[7:6];
        row_addr = {CA_rising[8], CA_falling[9:0], CA_rising[3:0]};  // only conside the density per channel is 8Gb
        col_addr = {CA_falling[2:0], CA_rising[3:0]};  // dont consider the PC mode 
    end

    // generate the command in normal operation
    // JESED250D, Table 30, Command Truth Table
    // This is a simple model, only consider the RD command
    always @(negedge CLK_t) begin
        current_time = $realtime;
        // JESD250D, Page 10, Chapter 3.1 & Page 22, Chapter 5.1 
        // it is better to conside the power-up sequence & CA training sequence, but to simplify the model, it is not considered here.
        // after the Command Address Training, the controller can issue the command to the SDRAM.(optional)
        if (gddr_cmd[3] != `LOW) begin
            case (gddr_cmd[3:0])
                4'b1101: begin
                    if (row_addr[8] == `LOW) gddr_command = `RD;
                end
                default: gddr_command = `NOP1;
            endcase
        end
        // trigger the command event
        if (gddr_command != `NOP1) begin
            @(posedge CLK_t) begin
                command_event <= `HIGH;
                command_event <= #(`tCK / 2) `LOW;
            end
        end
    end

    // if command event is triggered, check the relevant AC timing based on the command type.
    always @(posedge command_event) begin
        case (gddr_command)
            `RD: begin
                check_ac_timing(`SAME_BANK, `RD, `RD);
                rd_flag <= `HIGH;
                rd_flag <= #(`tCK / 2) `LOW;
            end
        endcase
    end

    // if rd_flag is triggered, record the read command issue time for each bank
    always @(posedge rd_flag) begin
      pre_read_command_time[bank] = $realtime; 
    end

    // check the AC timing task
    task check_ac_timing(input [1:0] bank_relationship, input [4:0] pre_gddr_command,input [4:0] gddr_command);
      begin
        case ({bank_relationship, pre_gddr_command, gddr_command})
          {`SAME_BANK, `RD, `RD} : begin
            // If clock cycles are used for checking, only fixed frequencies can be checked, and frequency switching cannot be tested. 
            // Therefore, using absolute time offers better adaptability.
            // Neet to conside the bank group feature, JESD250D, Table 21
            if (MR3_Bank_Group_value[1] == 1'b0) begin
              if ($realtime - pre_read_command_time[bank] < `tCCD_S * `tCK)
                $error("tCCD_S violation when bank group is disabled during read to read at %t, please refer to JESD250D Table21",current_time);
            end else begin
              if ($realtime - pre_read_command_time[bank] < `tCCD_L * `tCK)
                $error("tCCD_L violation when bank group is enabled during read to read at %t, please refer to JESD250D Table21",current_time);
            end
          end
        endcase
      end
    endtask

endmodule
