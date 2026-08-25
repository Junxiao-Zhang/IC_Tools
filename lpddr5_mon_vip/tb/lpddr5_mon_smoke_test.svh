// UVM 冒烟自测：monitor 事务序列与地址字段检查
class lpddr5_mon_collector extends uvm_subscriber #(lpddr5_mon_transaction);

  `uvm_component_utils(lpddr5_mon_collector)

  lpddr5_mon_transaction seen[$];

  function new(string name = "lpddr5_mon_collector", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void write(lpddr5_mon_transaction t);
    seen.push_back(t);
  endfunction

endclass : lpddr5_mon_collector

class lpddr5_mon_smoke_test extends uvm_test;

  `uvm_component_utils(lpddr5_mon_smoke_test)

  lpddr5_mon_env       env;
  lpddr5_mon_collector col;

  function new(string name = "lpddr5_mon_smoke_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = lpddr5_mon_env::type_id::create("env", this);
    col = lpddr5_mon_collector::type_id::create("col", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    env.agent_0.monitor.ap.connect(col.analysis_export);
  endfunction

  function void check_phase(uvm_phase phase);
    // 命令命名与 golden 一致（Task 7 校准）；bk_org 默认 8B：
    // bg 保持 z，col = Micron_col << 5
    string expected[$] = '{"MRW_1", "ACTIVE_1", "ACTIVE_2", "WR", "RD"};
    super.check_phase(phase);
    if (col.seen.size() != expected.size()) begin
      `uvm_error(get_name(), $psprintf("事务数不匹配：期望 %0d，实际 %0d",
                   expected.size(), col.seen.size()))
      return;
    end
    foreach (expected[i]) begin
      if (col.seen[i].cmd != expected[i])
        `uvm_error(get_name(), $psprintf("第 %0d 个命令期望 %s 实际 %s",
                     i, expected[i], col.seen[i].cmd))
    end
    // 地址字段抽查（ACTIVE_1 只更新 bank；row/bg 8B 模式保持 z）
    if (col.seen[1].bank != 4'hC || col.seen[1].bank_group !== 2'bzz ||
        col.seen[1].row !== 32'hz)
      `uvm_error(get_name(), "ACTIVE_1 地址字段不匹配");
    if (col.seen[2].row != 32'h2A0B)
      `uvm_error(get_name(), "ACTIVE_2 合并 row 不匹配");
    // WR（8B）：Micron_col=0x17 → col=0x17<<5=0x2E0；bank=s[3:0]=6
    if (col.seen[3].col != 32'h2E0 || col.seen[3].bank != 4'h6)
      `uvm_error(get_name(), "WR 地址字段不匹配");
    // RD（8B，修复轮 1）：Micron_col=0x2B → col=0x2B<<5=0x560；s=0011010
    // 的 s[3]=1 是 B4（burst 位）非 bank 位 → bank={1'b0, s[2:0]}=2
    // （2ch diff_bl 校准：golden 1101->0101、1001->0001；修复前误报 0xA）
    if (col.seen[4].col != 32'h560 || col.seen[4].bank != 4'h2)
      `uvm_error(get_name(), "RD 地址字段不匹配");
  endfunction

endclass : lpddr5_mon_smoke_test
