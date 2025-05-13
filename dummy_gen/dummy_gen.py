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
#    0.1    |  2025-03-20 |  Junxiao |  Initial version
#   -------------------------------------------------------------------------------------

# 从 __future__ 模块导入绝对导入和打印函数，确保兼容性
from __future__ import absolute_import
from __future__ import print_function
import sys
import os
# 导入字符串模板模块，用于生成 Verilog 代码模板
from string import Template
import argparse

# 导入 pyverilog 库，用于解析 Verilog 文件
import pyverilog
from pyverilog.vparser.parser import parse

# 定义带有参数的 Verilog 模块模板
template = Template("""
module $module_name #(
$parameter_list_string
)(
$declared_list_string
);

$assign_list_string

endmodule
""")

# 定义无参数的 Verilog 模块模板
template_noparam = Template("""
module $module_name (
$declared_list_string
);

$assign_list_string

endmodule
""")

# 定义一个函数，用于根据输入字符串生成表达式
def generate_expression(input_str):
    # 去除输入字符串的括号并按空格分割
    parts = input_str.strip('()').split()
    
    # 检查分割后的部分数量是否为 3
    if len(parts) != 3:
        return "Invalid input format"
    
    # 解包分割后的部分
    operation, variable, value = parts
    
    # 根据不同的操作类型生成相应的表达式
    if operation == "Minus":
        return f"{variable}-{value}"
    elif operation == "Divide":
        return f"{variable}/{value}"
    elif operation == "Plus":
        return f"{variable}+{value}"
    else:
        return "Unsupported operation"

# 定义一个函数，用于获取命令行参数解析器
def get_parser():
    # 创建一个参数解析器对象
    parser = argparse.ArgumentParser()
    # 添加输入文件参数
    parser.add_argument("-i", "--input_file", type=str, help="input RTL file, which will be converted to dummy file")
    # 添加输出文件参数
    parser.add_argument("-o", "--output_file", type=str, help="output file name")
    # 解析命令行参数
    args = parser.parse_args()
    return args

# 定义主函数，程序的入口点
def main():
    # 初始化一个空列表，用于存储文件列表
    filelist = []

    # 获取命令行参数
    args = get_parser()
    # 将输入文件添加到文件列表中
    filelist.append(args.input_file)

    # 使用 pyverilog 解析文件列表，得到抽象语法树和指令列表
    ast, directives = parse(filelist)
    
    # 初始化空列表，用于存储声明列表、参数列表和赋值列表
    declared_list = []
    parameter_list = []
    assign_list = []

    # 遍历抽象语法树的子节点
    for c in ast.children():
        
        # 获取模块名称
        module_name =  c.children()[0].name

        # 遍历模块的参数列表
        for i in c.children()[0].paramlist.params:
            # 获取参数名称
            param_name = i.children()[0].name
            # 获取参数值
            param_value = i.children()[0].value.var
            # 生成参数声明字符串
            parameter_string = f"parameter {param_name} = {param_value}"
            # 将参数声明字符串添加到参数列表中
            parameter_list.append(parameter_string)

        # 遍历模块的端口列表
        for i in c.children()[0].portlist.ports:
            # 获取端口名称
            port_name = i.first.name
            # 检查端口是否有宽度信息
            if i.first.width is not None:
                # 检查端口宽度的最高位是否包含特定操作
                if "Minus" in str(i.first.width.msb) or "Divide" in str(i.first.width.msb) or "Plus" in str(i.first.width.msb):
                    # 生成端口宽度的最高位表达式
                    msb_string = generate_expression(str(i.first.width.msb))
                else:
                    # 直接使用端口宽度的最高位值
                    msb_string = i.first.width.msb 
                # 获取端口宽度的最低位值
                lsb_string = i.first.width.lsb
                # 生成端口宽度字符串
                width_string = f"[{msb_string}:{lsb_string}]"
            else:
                # 若端口无宽度信息，则宽度字符串为空
                width_string = ""

            # 获取端口类型的名称
            type_string = type(i.first).__name__ 

            # 若端口类型为 Output
            if type_string == "Output":
                # 生成赋值语句字符串
                assign_string = "assign" + " " + port_name + " = " + "'h0" + ";" 
                # 将赋值语句字符串添加到赋值列表中
                assign_list.append(assign_string)
            # 若端口类型为 Inout
            elif type_string == "Inout":
                # 生成赋值语句字符串
                assign_string = "assign" + " " + port_name + " = " + "'h0" + ";" 
                # 将赋值语句字符串添加到赋值列表中
                assign_list.append(assign_string)
                
            # 生成端口声明字符串
            decl_string = f"{type_string.lower()} {width_string} {port_name}"
            # 将端口声明字符串添加到声明列表中
            declared_list.append(decl_string)

    # 将参数列表转换为以逗号和换行分隔的字符串
    parameter_list_string = ",\n".join(parameter_list)
    # 将声明列表转换为以逗号和换行分隔的字符串
    declared_list_string = ",\n".join(declared_list)
    # 将赋值列表转换为以换行分隔的字符串
    assign_list_string = "\n".join(assign_list)

    # 检查参数列表是否为空
    if len(parameter_list) == 0:
        # 若参数列表为空，则使用无参数模板生成伪文件内容
        dummy_file = template_noparam.substitute(module_name=module_name, declared_list_string=declared_list_string, assign_list_string=assign_list_string)
    else:
        # 若参数列表不为空，则使用带参数模板生成伪文件内容
        dummy_file = template.substitute(module_name=module_name, parameter_list_string=parameter_list_string, declared_list_string=declared_list_string, assign_list_string=assign_list_string)

    # 打开输出文件并写入生成的伪文件内容
    with open(args.output_file, "w") as f:
        f.write(dummy_file)


if __name__ == '__main__':
    # 调用主函数
    main()