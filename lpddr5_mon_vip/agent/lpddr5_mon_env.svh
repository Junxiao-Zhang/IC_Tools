// ======================================================================
// 环境：例化两个 agent（多 rank 环境对应 rank 0/1，2ch 环境对应 channel a/b）
// ======================================================================
class lpddr5_mon_env extends uvm_env;

  `uvm_component_utils(lpddr5_mon_env)

  lpddr5_mon_agent agent_0;
  lpddr5_mon_agent agent_1;

  virtual lpddr5_mon_jedec_chip_if vif_0;
  virtual lpddr5_mon_jedec_chip_if vif_1;

  function new(string name = "lpddr5_mon_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::get(this, "", "lpddr5_mon_vif_0", vif_0))
      `uvm_fatal(get_name(), "未提供 lpddr5_mon_vif_0（多 rank: rank 0；2ch: channel_a）");
    if (!uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::get(this, "", "lpddr5_mon_vif_1", vif_1))
      `uvm_fatal(get_name(), "未提供 lpddr5_mon_vif_1（多 rank: rank 1；2ch: channel_b）");
    agent_0 = lpddr5_mon_agent::type_id::create("agent_0", this);
    agent_1 = lpddr5_mon_agent::type_id::create("agent_1", this);
    uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::set(this, "agent_0", "vif", vif_0);
    uvm_config_db#(virtual lpddr5_mon_jedec_chip_if)::set(this, "agent_1", "vif", vif_1);
  endfunction

endclass : lpddr5_mon_env
