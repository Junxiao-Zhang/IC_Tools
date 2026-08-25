#!/bin/bash
# 自研 LPDDR5 monitor VIP 独立自测：编译 + 运行（-kdb，FSDB 波形转储）
set -e
cd "$(dirname "$0")"

# Verdi FSDB 波形转储（需 VERDI_HOME，环境已配置）
VERDI_HOME="${VERDI_HOME:-/opt/Synopsys/verdi/V-2023.12-SP2}"
FSDB_PLI="-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a"

vcs -full64 -sverilog -timescale=1ps/1fs -debug_access+all -R -kdb \
  ${FSDB_PLI} +define+WAVES_FSDB \
  +incdir+../if \
  -l vcs.log \
  lpddr5_mon_tb_top.sv
