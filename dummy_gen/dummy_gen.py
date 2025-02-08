########################################################################################
#  Copyright 2024 Junxiao.Zhang(junxiaozhang95@gmail.com)
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
########################################################################################
#    Rev    |  Date       |  Author  |  Change Description
#   -------------------------------------------------------------------------------------
#    0.1    |  2024-12-10 |  Junxiao |  Initial version

import argparse
from pyverilog.vparser.parser import parse
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, help="input verilog file")
    parser.add_argument("-o", "--output", type=str, help="output verilog file")
    args = parser.parse_args()
    return args


def generate_stub_module(verilog_file, output_file):
    # 解析 Verilog 文件并生成 AST
    ast, _ = parse([verilog_file])

    # 遍历 AST，找到模块定义
    for child in ast.children():
        if child.__class__.__name__ == "ModuleDef":
            module_def = child
            break
    else:
        raise ValueError("No module definition found in the file")

    # 清空模块内部逻辑，只保留端口声明和参数
    module_def.items = [
        item
        for item in module_def.items
        if item.__class__.__name__ in ("Decl", "Parameter", "Localparam")
    ]

    # 生成新的 Verilog 代码
    codegen = ASTCodeGenerator()
    stub_code = codegen.visit(ast)

    # 写入输出文件
    with open(output_file, "w") as f:
        f.write(stub_code)


if __name__ == "__main__":
    args = get_parser()
    print(args)
    input_name = args.input
    output_name = args.output

    generate_stub_module(input_name, output_name)
    print(f"Successfully generated stub module: ")
