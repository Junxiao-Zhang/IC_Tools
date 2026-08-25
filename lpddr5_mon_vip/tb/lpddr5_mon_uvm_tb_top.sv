// UVM 冒烟自测台：同一组激励经 monitor 收集后与期望序列比对
`include "lpddr5_mon_jedec_chip_if.svi"
`include "lpddr5_mon_agent_pkg.sv"

// smoke_test 类位于文件作用域，UVM 的 import 必须也在文件作用域
// （模块内 import 不影响文件作用域类声明）
import uvm_pkg::*;
`include "uvm_macros.svh"
import lpddr5_mon_pkg::*;

`include "lpddr5_mon_smoke_test.svh"

module lpddr5_mon_uvm_tb_top;

  // ck_c 仅由 assign 连续赋值驱动（声明处初始化会与 assign 冲突，VCS ICPSD_INIT）
  logic ck_t = 0, ck_c, cs_p = 0, reset_n = 0;
  logic [6:0] ca = 7'b0;

  lpddr5_mon_jedec_chip_if dut_if (.ck_t(ck_t), .ck_c(ck_c), .cs_p(cs_p),
                                   .ca(ca), .reset_n(reset_n));
  assign ck_c = ~ck_t;

  initial begin
    forever #1000ps ck_t = ~ck_t;
  end

  // 发送一个单周期命令：f=第一半 ca，s=第二半 ca
  // 时序约定：信号在边沿后 2ps 建立（接口在边沿 0 delay 采样，与 golden
  // 边沿采样对齐，校准确定）；命令末尾
  // 拉低 cs_p 插入空闲周期，保证每个 negedge 解码的 (第一半,第二半) 都是
  // 同一命令的配对，避免伪解码破坏保持字段
  task send_cmd(input logic [6:0] f, input logic [6:0] s);
    @(negedge ck_t); #2ps; cs_p = 1'b1; ca = f;    // 第一半
    @(posedge ck_t); #2ps; ca = s;                 // 第二半
    @(negedge ck_t); #2ps; cs_p = 1'b0; ca = 7'b0; // 空闲（cs 拉低）
  endtask

  // 把 casez 模式（位序 {CS,CA0..CA6}）转为物理 ca[6:0]（{CA6..CA0}）
  function automatic logic [6:0] enc_first(input logic [7:0] p);
    return {p[0], p[1], p[2], p[3], p[4], p[5], p[6]};
  endfunction

  // 激励：MRW-1 → ACT-1 → ACT-2 → WR-1 → RD-1（与 smoke_test 期望一致）
  initial begin
    reset_n = 1'b0;
    uvm_test_done.raise_objection(null);   // 保持 run_phase 存活到激励完成
    #3ns reset_n = 1'b1;
    #2ns;
    send_cmd(enc_first('b1_000_1101), 7'b0001010);   // MRW-1 addr=10
    send_cmd(enc_first('b1_111_0000), 7'b1011100);   // ACT-1 row[17:11]=5 ba=12 bg=3
    send_cmd(enc_first('b1_110_0010), 7'b0001011);   // ACT-2 row[10:0]=523
    send_cmd(enc_first('b1_011_1010), 7'b0110110);   // WR-1 col=23 ba=6 bg=1
    send_cmd(enc_first('b1_100_1101), 7'b0011010);   // RD-1 col=43；8B 模式 s[3]=1
                                                     // 为 B4，bank={1'b0,s[2:0]}=2
                                                     // （修复轮 1 校准，非 ba=10）
    @(negedge ck_t); #2ns;
    uvm_test_done.drop_objection(null);    // 激励完成，进入 check_phase
    #100ns;                                 // 等 UVM 各 phase 收尾
    $finish;
  end

  initial begin
    uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::set(null, "uvm_test_top.env",
      "lpddr5_mon_vif_0", dut_if);
    uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::set(null, "uvm_test_top.env",
      "lpddr5_mon_vif_1", dut_if);
    run_test("lpddr5_mon_smoke_test");
  end

  // FSDB 波形转储（run 脚本编译时 +define+WAVES_FSDB 并链接 Verdi PLI 时启用）
  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("lpddr5_mon_uvm_tb_top.fsdb");
    $fsdbDumpvars(0, lpddr5_mon_uvm_tb_top);
  end
  `endif

endmodule
