# ###############################
# rmctl Area
# ###############################
function check_trash_user() {
  grep -q '^trash:' /etc/passwd || {
    # create trash user
    sudo groupadd -g ${TRASH_GID} ${TRASH_USER} \
      && sudo useradd -g ${TRASH_USER} -u ${TRASH_UID} -s /bin/bash -Md ${TRASH_HOME} ${TRASH_USER}
  }
  # check dir and chmod
  [ ! -d ${TRASH_HOME} ] \
    && (mkdir -p ${TRASH_HOME} && sudo chown ${TRASH_USER}:${TRASH_GROUP} ${TRASH_HOME})
  sudo chmod ${TRASH_HOME_PERM} ${TRASH_HOME}
}


  # # 检查依赖
  # check_deps
  # check_trash_user
  # # 决策trash目录
  # sudo touch $TRASH_HOME/