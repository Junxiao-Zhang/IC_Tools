// ======================================================================
// 自研 LPDDR5 monitor VIP 包文件：按依赖序 include 全部类
// 使用 UVM-1.2（VCS -ntb_opts uvm-1.2）
// ======================================================================
package lpddr5_mon_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "lpddr5_mon_transaction.svh"
  `include "lpddr5_mon_config.svh"
  `include "lpddr5_mon_monitor.svh"
  `include "lpddr5_mon_agent.svh"
  `include "lpddr5_mon_env.svh"

endpackage : lpddr5_mon_pkg
