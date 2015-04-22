#!/bin/bash

proj_file=${1:-"projects.txt"}
runtests_script_dir=${2:-"runtests-scripts"}

vm_name="Package-tests"
snapshot_name="main-snapshot"

VM_MAC_ADDR=$(virsh dumpxml ${vm_name} | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/g")
VM_IP=$(arp -n | grep ${VM_MAC_ADDR} | awk '{print $1}')

list_failed_to_install=
list_failed_to_test=
list_failed_to_remove=

package_pin() {
  # $1 - package name
  echo -e "Package: $1
Pin: release Trusty
Pin-Priority: 1000" > tmp_file
  scp tmp_file root@${VM_IP}:/etc/apt/preferences.d/pref-$1
  rm tmp_file
}

install_package() {
  # $1 - package name
  package_pin "rabbitmq-server"
  package_pin "python-mysqldb"
  ssh root@${VM_IP} -C "apt-get install $1 -y --force-yes"
  if [ $? -ne '0' ]; then
    list_failed_to_install="${list_failed_to_install} $1"
    return 1
  fi
  return 0
}

test_package() {
  # $1 - project name
  # $2 - package name
  ssh root@${VM_IP} -C "bash $1-tests.sh $2"
  rc=$?
  if [ $rc -ne '0' ]; then
    list_failed_to_test="${list_failed_to_test} $2"
    return 1
  fi
  return 0
}

remove_package() {
  # $1 - package name
  ssh root@$VM_IP -C "apt-get remove $1 -y --force-yes"
  if [ $? -ne '0' ]; then
    list_failed_to_remove="${list_failed_to_remove} $1"
    return 1
  fi
  return 0
}

for project in $(cat ${proj_file}); do
  if [ -f "${runtests_script_dir}/${project}-tests.sh" -a -f "${runtests_script_dir}/${project}.list" ]; then
    for package in $(cat ${runtests_script_dir}/${project}.list); do
      virsh resume ${vm_name}
      scp runtests-scripts/${project}-tests.sh root@${VM_IP}:
      install_package ${package}
      [ $? -eq '0' ] && test_package ${project} ${package}
      [ $? -eq '0' ] && remove_package ${package}
      virsh suspend ${vm_name}
      virsh snapshot-revert ${vm_name} ${snapshot_name}
    done
  fi
done

if [ -n "${list_failed_to_install}" ]; then
  echo "List failed to install packages: ${list_failed_to_install}"
fi

if [ -n "${list_failed_to_test}" ]; then
  echo "List failed to test packages: ${list_failed_to_test}"
fi

if [ -n "$list_failed_to_remove" ]; then
  echo "List failed to remove packages: ${list_failed_to_remove}"
fi
