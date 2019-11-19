#!/bin/bash
# 将所有脚本组合在一块


# ###############################
# Config Area
# ###############################
CUR_SCRIPT_DIR=$(pushd `dirname "$0"` >/dev/null; pwd; popd >/dev/null);
DST_SCRIPT_FILE=${CUR_SCRIPT_DIR}/../yh-xkit.sh


# 合并文件，这里代表方向，满足语意，不然和strcpy,strcat这些参数反了
function concat_file_to() {
  # 如果需要，这里可以添加：日期、亮丽的分隔线啥的
  cat "$1" >> "$dst_file"
  # 加2个空行
  for x in `seq 2`; do echo >> "$dst_file"; done
}

# 拼接一个目录下的所有shell脚本
function concat_dir() {
  dir=$1
  dst_file=$2
  filter=*.sh
  for x in $(ls ${dir}/${filter} | sort); do
    concat_file_to "$x" $dst_file
  done;
}

# main
function main() {
  true > ${DST_SCRIPT_FILE} # 置空文件
  concat_dir ${CUR_SCRIPT_DIR}/firmware ${DST_SCRIPT_FILE}
  concat_dir ${CUR_SCRIPT_DIR}/sub ${DST_SCRIPT_FILE}
  # 拼接主程序
  concat_file_to ${CUR_SCRIPT_DIR}/_def.env ${DST_SCRIPT_FILE}
  concat_file_to ${CUR_SCRIPT_DIR}/_usage.sh ${DST_SCRIPT_FILE}
  concat_file_to ${CUR_SCRIPT_DIR}/_main.sh ${DST_SCRIPT_FILE}
}


# ###############################
# Run Area
# ###############################
main
