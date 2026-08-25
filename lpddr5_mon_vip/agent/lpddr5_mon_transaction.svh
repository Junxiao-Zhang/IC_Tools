// ======================================================================
// 命令事务：一条解码后的 CA 命令
// ======================================================================
class lpddr5_mon_transaction extends uvm_sequence_item;

  string       cmd;          // 命令名字符串（与 debug port cmd 一致）
  logic [31:0] row;
  logic [31:0] col;
  logic [3:0]  bank;
  logic [1:0]  bank_group;
  time         sample_time;  // 采样时刻

  `uvm_object_utils_begin(lpddr5_mon_transaction)
    `uvm_field_string(cmd,         UVM_ALL_ON)
    `uvm_field_int   (row,         UVM_ALL_ON | UVM_HEX)
    `uvm_field_int   (col,         UVM_ALL_ON | UVM_HEX)
    `uvm_field_int   (bank,        UVM_ALL_ON)
    `uvm_field_int   (bank_group,  UVM_ALL_ON)
    `uvm_field_int   (sample_time, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "lpddr5_mon_transaction");
    super.new(name);
  endfunction

  function string convert2string();
    return $psprintf("cmd=%0s row=0x%0h bank=0x%0h bg=0x%0h col=0x%0h",
                     cmd, row, bank, bank_group, col);
  endfunction

endclass : lpddr5_mon_transaction
