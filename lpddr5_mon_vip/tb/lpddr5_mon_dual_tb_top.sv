// ======================================================================
// 自研 LPDDR5 monitor VIP 双通道自测台（非 UVM）
// 验证双通道接口层次：channel_a_if / channel_b_if 各自独立解码，
// 复用同一时钟、共享 reset_n，A 通道发 MRW-1 的同时 B 通道发 NOP。
// 激励方式与单通道 tb 一致：信号在边沿后 2ps 建立（接口在边沿 0 delay
// 采样，与 golden 边沿采样对齐，校准确定），命令末尾拉低 cs_p 插入空闲
// 周期，避免伪解码破坏保持字段。
// ======================================================================
`include "lpddr5_mon_dual_chan_jedec_chip_if.svi"

module lpddr5_mon_dual_tb_top;

  // ck_c 仅由 assign 连续赋值驱动（声明处初始化会与 assign 冲突，VCS ICPSD_INIT）
  logic ck_t = 0, ck_c, cs_p_a = 0, cs_p_b = 0, reset_n = 0;
  logic [6:0] ca_a = 7'b0, ca_b = 7'b0;
  int error_cnt = 0;

  lpddr5_mon_dual_chan_jedec_chip_if dut_dual (.ck_t_a(ck_t), .ck_c_a(ck_c),
                                               .ck_t_b(ck_t), .ck_c_b(ck_c),
                                               .cs_p_a(cs_p_a), .cs_p_b(cs_p_b),
                                               .ca_a(ca_a), .ca_b(ca_b),
                                               .reset_n(reset_n));
  assign ck_c = ~ck_t;

  // 2ns 周期时钟（两通道共享）
  initial begin
    forever #1000ps ck_t = ~ck_t;
  end

  // A 通道发送一个单周期命令：f=第一半 ca，s=第二半 ca
  // 时序约定：信号在边沿后 2ps 建立（接口在边沿 0 delay 采样，与 golden
  // 边沿采样对齐，校准确定）；命令末尾
  // 拉低 cs_p 插入空闲周期，保证每个 negedge 解码的 (第一半,第二半) 都是
  // 同一命令的配对，避免伪解码破坏保持字段
  task send_a(input logic [6:0] f, input logic [6:0] s);
    @(negedge ck_t); #2ps; cs_p_a = 1'b1; ca_a = f;    // 第一半
    @(posedge ck_t); #2ps; ca_a = s;                   // 第二半
    @(negedge ck_t); #2ps; cs_p_a = 1'b0; ca_a = 7'b0; // 空闲（cs 拉低）
  endtask

  task send_b(input logic [6:0] f, input logic [6:0] s);
    @(negedge ck_t); #2ps; cs_p_b = 1'b1; ca_b = f;    // 第一半
    @(posedge ck_t); #2ps; ca_b = s;                   // 第二半
    @(negedge ck_t); #2ps; cs_p_b = 1'b0; ca_b = 7'b0; // 空闲（cs 拉低）
  endtask

  initial begin
    #3ns reset_n = 1'b1;
    #2ns;
    // A 通道发 MRW-1（f=物理位序 {CA6..CA0}，模式 1_000_1101 的重排），
    // B 通道同时发 NOP
    fork
      send_a(7'b1011000, 7'b0001010);
      send_b(7'b0000000, 7'b0000000);
    join
    // 正确解码在任务返回前已完成（negedge+1ps 解码，任务在 negedge+2ps 返回），
    // #1ps 后读取即可
    #1ps;
    // 命令命名与 golden 一致；MRW-1 不更新任何地址字段（col 保持 z）
    if (dut_dual.channel_a_if.cmd_string() != "MRW_1") begin
      $display("[FAIL] channel_a 期望 MRW_1 实际 %s", dut_dual.channel_a_if.cmd_string());
      error_cnt++;
    end
    if (dut_dual.channel_a_if.col_addr !== 32'hz) begin
      $display("[FAIL] channel_a col 期望 0x%0h 实际 0x%0h", 32'hz, dut_dual.channel_a_if.col_addr);
      error_cnt++;
    end
    if (dut_dual.channel_b_if.cmd_string() != "NOP") begin
      $display("[FAIL] channel_b 期望 NOP 实际 %s", dut_dual.channel_b_if.cmd_string());
      error_cnt++;
    end
    $display("==== 双通道自测结束：%0d 项失败 ====", error_cnt);
    if (error_cnt == 0) $display("PASS");
    else                $display("FAIL");
    $finish;
  end

  // FSDB 波形转储（run 脚本编译时 +define+WAVES_FSDB 并链接 Verdi PLI 时启用）
  `ifdef WAVES_FSDB
  initial begin
    $fsdbDumpfile("lpddr5_mon_dual_tb_top.fsdb");
    $fsdbDumpvars(0, lpddr5_mon_dual_tb_top);
  end
  `endif

endmodule
