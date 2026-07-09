# IC_Tools

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

IC 设计与验证中开发的一些实用工具集，涵盖 RTL 层次路径生成、Warning 过滤、Dummy 模块生成、终态检查、覆盖率报告等场景。

## 目录

- [1. RTL Hierarchy PATH Generator](#1-rtl-hierarchy-path-generator)
- [2. Warning / Lint Filter](#2-warning--lint-filter)
- [3. Dummy Block Generation](#3-dummy-block-generation)
- [4. End of Test Checker（终态检查）](#4-end-of-test-checker终态检查)
- [5. Coverage Report Generation](#5-coverage-report-generation)

## 依赖环境

各工具依赖如下，按需安装：

| 工具 | Python 库 | 系统 / EDA 工具 |
|------|----------|-----------------|
| `dummy_gen` | `pyverilog` | `iverilog`（`sudo apt install iverilog`） |
| `gen_cov_report` | `openpyxl` | Synopsys `urg`（需在 PATH 中） |
| `unicode_string` | `pyfiglet` | — |
| 其他 | 标准库即可 | — |

---

## 1. RTL Hierarchy PATH Generator

基于 Verdi 导出的设计层次文件，生成 `define` 宏定义 PATH，用于取代绝对层次路径，提升跨项目复用性。

**目录结构：**

```
rtl_hier_gen/
  ├── rtl_hier_gen.py
  ├── content.txt          # 示例输入：Verdi 导出的层次文件
  ├── demo.sv              # 示例输出
  └── README.md
```

**使用方法：**

1. 通过 Verdi GUI 导出 Hierarchy：
   
   ![导出 Hierarchy](.assets/Figure_001)
   
   导出后的文件内容如下：
   
   ![导出文件内容](.assets/Figure_002)

2. 执行脚本：

   ```bash
   python3 rtl_hier_gen.py -f content.txt -o demo.sv
   ```

3. 生成结果：

   ![生成结果](.assets/Figure_003)

   同名不同路径的模块会自动追加后缀（`_0`、`_1` …）加以区分：

   ![同名区分-1](.assets/image-20241211011517988.png)
   ![同名区分-2](.assets/image-20241211011547438.png)

---

## 2. Warning / Lint Filter

基于 VCS 编译仿真 log，通过正则表达式过滤 Warning 和 Lint 信息，生成分类报告。

**使用方法：**

1. 将脚本复制到目标目录下。
2. 修改脚本中的 `target_file` 和 `waive_list` 列表：
   
   ![配置截图](./.assets/image-20250122000756660.png)

3. 执行：

   ```bash
   python3 warning_lint_filter.py
   ```

**功能特性（2025-01-22 更新）：**

- 递归搜索当前目录及子目录中的目标文件（`vcs.log` / `simv.log`）
- 提取所有 `Warning-*` 块并自动去重，输出到 `warning.log`
- 支持 waive list：命中 waive 关键字的内容单独输出到 `waive.log`，方便后续 review

---

## 3. Dummy Block Generation

基于 [pyverilog](https://github.com/PyHDI/Pyverilog) 库解析 Verilog RTL 的 AST 语法树，提取 module name 和 port 信息，自动生成对应的 stub 模块：
- `input` 端口悬空
- `output` 端口 tie 0（`'h0`）
- `inout` 端口 tie 0（`'h0`）

**依赖安装：**

```bash
sudo apt install iverilog
pip3 install pyverilog
```

**运行示例：**

```bash
# 带 parameter 的模块
python3 dummy_gen.py -i demo.v -o demo_stub.v

# 不带 parameter 的模块
python3 dummy_gen.py -i demo1.v -o demo1_stub.v
```

---

## 4. End of Test Checker（终态检查）

基于输入的 CSV 检查列表，自动生成 SystemVerilog 终态检查模块 `eot_checker.sv`，在仿真结束时检查指定信号的期望值。

- 通过 `$test$plusargs("DISABLE_EOT_CHECKER")` 控制检查开关，默认为开启，方便异常场景下关闭检查
- 支持断言报错级别控制（`$error` / `$warning` / `$info`）

**用法：**

```bash
python3 eot_gen.py -h
```

```
usage: eot_gen.py [-h] [-f INPUT_FILE] [-o OUTPUT_NAME] [-v VERBOSITY]

optional arguments:
  -h, --help            show this help message and exit
  -f INPUT_FILE, --input_file INPUT_FILE
                        input csv file to generate eot file
  -o OUTPUT_NAME, --output_name OUTPUT_NAME
                        output file name
  -v VERBOSITY, --verbosity VERBOSITY
                        verbosity level: 0:Error, 1:Warning, 2:Info
```

**CSV 输入格式：**

![CSV 格式示例](./.assets/image.png)

| 列名 | 说明 |
|------|------|
| `name` | 断言名称 |
| `hierarchy` | 信号层次路径（推荐使用绝对路径） |
| `signal` | 待检查的信号名 |
| `expect_value` | 仿真结束时信号的期望值 |
| `error_info` | 断言失败时的辅助定位信息（可选，不填则自动生成默认语句） |

生成 `eot_checker.sv` 后，在 Testbench 顶层直接例化即可使用。

---

## 5. Coverage Report Generation

基于 Synopsys `urg` 工具和 `.vdb` 覆盖率数据库，生成格式化的 Excel 覆盖率报告，列出各覆盖类型的未覆盖点。

**用法：**

```bash
python3 gen_coverage_rpt.py -h
```

```
usage: gen_coverage_rpt.py [-h] -m M

Extract coverage data from VDB databases

optional arguments:
  -h, --help  show this help message and exit
  -m M        Module name to extract
```

**运行示例：**

```bash
# 在包含 simv.vdb/ 的目录下执行
python3 gen_coverage_rpt.py -m uart_tx
```

**处理流程：**

1. 调用 `urg -dir *.vdb -format text` 生成文本覆盖率报告
2. 解析 `urgReport/modinfo.txt`，按模块拆分
3. 按覆盖类型（Line / Cond / Toggle / FSM）进一步拆分
4. 生成 `.xlsx` 报告，包含各类型的未覆盖项及对应的源码行号 / 表达式

**输出目录结构：**

```
output/
  ├── trace.log                     # 处理日志
  ├── module/<module>.txt           # 按模块拆分后的原始报告
  ├── module_split/<module>_line.txt
  ├── module_split/<module>_cond.txt
  ├── module_split/<module>_toggle.txt
  ├── module_split/<module>_fsm.txt
  └── <module>.xlsx                 # 最终 Excel 报告
```
