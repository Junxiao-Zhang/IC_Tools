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
from __future__ import absolute_import
from __future__ import print_function
import sys
import os
from string import Template
import argparse

import pyverilog
from pyverilog.vparser.parser import parse

template = Template("""
module $module_name #(
$parameter_list_string
)(
$declared_list_string
);

$assign_list_string

endmodule
""")

template_noparam = Template("""
module $module_name (
$declared_list_string
);

$assign_list_string

endmodule
""")

def generate_expression(input_str):
    parts = input_str.strip('()').split()
    
    if len(parts) != 3:
        return "Invalid input format"
    
    operation, variable, value = parts
    
    if operation == "Minus":
        return f"{variable}-{value}"
    elif operation == "Divide":
        return f"{variable}/{value}"
    elif operation == "Plus":
        return f"{variable}+{value}"
    else:
        return "Unsupported operation"

def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_file", type=str, help="input RTL file, which will be converted to dummy file")
    parser.add_argument("-o", "--output_file", type=str, help="output file name")
    args = parser.parse_args()
    return args

def main():
    filelist = []

    args = get_parser()
    filelist.append(args.input_file)

    ast, directives = parse(filelist)
    
    declared_list = []
    parameter_list = []
    assign_list = []

    for c in ast.children():
        
        module_name =  c.children()[0].name

        for i in c.children()[0].paramlist.params:
            param_name = i.children()[0].name
            param_value = i.children()[0].value.var
            parameter_string = f"parameter {param_name} = {param_value}"
            parameter_list.append(parameter_string)

        for i in c.children()[0].portlist.ports:
            port_name = i.first.name
            if i.first.width is not None:
                if "Minus" in str(i.first.width.msb) or "Divide" in str(i.first.width.msb) or "Plus" in str(i.first.width.msb):
                    msb_string = generate_expression(str(i.first.width.msb))
                else:
                    msb_string = i.first.width.msb 
                lsb_string = i.first.width.lsb
                width_string = f"[{msb_string}:{lsb_string}]"
            else:
                width_string = ""

            type_string = type(i.first).__name__ 

            if type_string == "Output":
                assign_string = "assign" + " " + port_name + " = " + "'h0" + ";" 
                assign_list.append(assign_string)
            elif type_string == "Inout":
                assign_string = "assign" + " " + port_name + " = " + "'h0" + ";" 
                assign_list.append(assign_string)
                
            decl_string = f"{type_string.lower()} {width_string} {port_name}"
            declared_list.append(decl_string)

    parameter_list_string = ",\n".join(parameter_list)
    declared_list_string = ",\n".join(declared_list)
    assign_list_string = "\n".join(assign_list)

    if len(parameter_list) == 0:
        dummy_file = template_noparam.substitute(module_name=module_name, declared_list_string=declared_list_string, assign_list_string=assign_list_string)
    else:
        dummy_file = template.substitute(module_name=module_name, parameter_list_string=parameter_list_string, declared_list_string=declared_list_string, assign_list_string=assign_list_string)

    with open(args.output_file, "w") as f:
        f.write(dummy_file)


if __name__ == '__main__':
    main()