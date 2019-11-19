# ###############################
# main usage Area
# ###############################

# 供主函数使用
SUB_CMD_LIST=foo|bar|archive|trash|rmctl

function showUsage() {
cat << EOF
${COPY_RIGHT}
sysinfo: ${OS_NAME}|${OS_R_NAME}|$(whoami)@$(hostname -s)
Usage: ${THIS_NAME} <cmd> [OPTION]

Options:

  -v, --version     output the version number
  -h, --help        output usage information

Commands:

  foo               foo desctriptin
  bar               bar description


EOF
}
