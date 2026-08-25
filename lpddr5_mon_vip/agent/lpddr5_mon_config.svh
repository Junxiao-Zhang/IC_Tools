// ======================================================================
// 配置对象：持有 virtual interface 句柄（slave_agent 风格）
// ======================================================================
class lpddr5_mon_config extends uvm_object;

  virtual lpddr5_mon_jedec_chip_if vif;

  `uvm_object_utils(lpddr5_mon_config)

  function new(string name = "lpddr5_mon_config");
    super.new(name);
  endfunction

  // 从 config_db 读取本组件下的配置；取不到则创建默认
  static function lpddr5_mon_config get_config(uvm_component c, string name = "cfg");
    lpddr5_mon_config cfg;
    if (!uvm_config_db#(lpddr5_mon_config)::get(c, "", name, cfg)) begin
      cfg = lpddr5_mon_config::type_id::create(name);
    end
    return cfg;
  endfunction

endclass : lpddr5_mon_config
