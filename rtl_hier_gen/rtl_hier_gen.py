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


import argparse
from string import Template
import re

template = Template(
    """
    `ifdef ${macro_name}
    `undef ${macro_name}
    `define ${macro_name} ${macro_define}
    `endif 
"""
)

macro_name_list = []

def parse_hierarchy_to_string(text):
    lines = text.strip().split("\n")
    hierarchy = {}
    current_dict = hierarchy
    path = []

    for line in lines:
        if ("M:" in line) or ("N:" in line):
            level = (len(line) - len(line.lstrip())) // 4  
            name = line.strip()[2:]

            while level < len(path):
                path.pop()
                current_dict = path[-1][1] if path else hierarchy

            if name not in current_dict:
                current_dict[name] = {}

            path.append((name, current_dict[name]))
            current_dict = current_dict[name]

    return hierarchy


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--hier_file", type=str, help="input the regression list")
    parser.add_argument("-o", "--output_name", type=str, help="output file name")
    args = parser.parse_args()
    return args


def get_content(file):
    with open(file, "r") as f:
        content = f.read()
        return content


def get_keys_paths(hierarchy, current_path=None):
    if current_path is None:
        current_path = []

    paths = []
    for key, value in hierarchy.items():
        new_path = current_path + [key]
        paths.append(".".join(new_path))
        if isinstance(value, dict):
            paths.extend(get_keys_paths(value, new_path))

    return paths


def gen_macro(paths):
    output_content = []
    for path in paths:
        path = path.replace(" ", "")
        parts = path.split(".")
        macro_name = parts[-1].upper()
        macro_name = macro_name.strip(" ")
        macro_name = ensure_unique_elements(macro_name, macro_name_list)
        macro_name = re.sub(r'\(.*?\)', '', macro_name)
        macro_name = macro_name.replace('(','_')
        macro_name = macro_name.replace(')','')
        macro_name = macro_name.replace('[','_')
        macro_name = macro_name.replace(']','')
        macro_name = macro_name + '_PATH'
        path = re.sub(r'\(.*?\)', '', path)
        path = path.replace('(','_')
        path = path.replace(')','')
        path = path.replace('[','_')
        path = path.replace(']','')
        my_macro = template.substitute(macro_name=macro_name, macro_define=path)
        output_content.append(my_macro)
    return output_content

def gen_sv_file(output, output_file_name):
    with open(output_file_name, 'w') as f:
        for content in output: 
            f.writelines(content)


def ensure_unique_elements(var, existing_list):
    suffix = 0

    if var not in existing_list:
        existing_list.append(var)
        new_var = var
    else:
        new_var = var
        while new_var in existing_list:
            new_var = var + "_" + str(suffix)
            suffix = suffix + 1
        existing_list.append(new_var)
    return new_var


def main():
    args = get_parser()
    content = get_content(args.hier_file)
    hierarchy = parse_hierarchy_to_string(content)
    paths = get_keys_paths(hierarchy)
    output = gen_macro(paths)
    gen_sv_file(output, args.output_name)

if __name__ == "__main__":
    main()
