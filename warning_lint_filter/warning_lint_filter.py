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
#    0.1    |  2024-12-12 |  Junxiao |  Initial version 
#    0.1.1  |  2024-01-20 |  Junxiao |  Fix the bug: use read() instead of readlines() 
#    0.2    |  2024-01-21 |  Junxiao |  add the feature: 
#                                          1.  Supports chcking for warnings in all matching files under the current path.
#                                          2.  Supports filtering duplicate warnings.     

import argparse
from string import Template
import re
import os

# if you want to add more target file, you can add the file name in the list
target_file = ["vcs.log", "simv.log"]

# if you want to waive some warning, you can add the warning content in the list
# eg. if you want to waive the warning "ICPSD_W", you can add "ICPSD_W" in the list
waive_list = ["ICPSD_W"]


# search the taget file in the directory, and extract the matching block
def extract_matching_blcok(directory, target_file):
    match_dir = {}
    match_block = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            for i in range(len(target_file)):
                if file == target_file[i]:
                    file_path = os.path.join(root, file)
                    print(f"Found target file: {file_path}")
                    with open(file_path, "r") as f:
                        text = f.read()
                        pattern = re.compile(r"Warning-.*?(?=\n\n)", re.DOTALL)
                        matches = pattern.findall(text)
                        match_dir[file_path] = matches
    return match_dir

# filter the duplicate warning
def gen_warning_lint_filter(match_dir):
    duplicate = []
    result = []
    for file_path in match_dir:
        for content in match_dir[file_path]:
            if content not in duplicate:
                duplicate.append(content)
                result.append(content)

    return result

def gen_warning_log(result):
    waive_content = []
    # generate the warning log, if the warning content is not in the waive list, it will be written in the warning.log
    with open("warning.log", "w") as f:
        for i in result:
            if check_elements_in_string(i, waive_list):
                f.writelines(i)
                f.writelines("\n----------------------------------\n")
            else:
                waive_content.append(i)

    # generate the waive log, to help you reivew the waived content
    with open("waive.log", "w") as f:
        for i in waive_content:
            f.writelines(i)
            f.writelines("\n----------------------------------\n")


# check the content is not in the waive list 
def check_elements_in_string(s, lst):
    for element in lst:
        if element in s:
            return False
    return True


def main():
    current_path = os.getcwd()
    match_dir = extract_matching_blcok(current_path, target_file)
    result = gen_warning_lint_filter(match_dir)
    gen_warning_log(result)

if __name__ == "__main__":
    main()
