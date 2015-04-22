#!/bin/bash

username=$1
if [ -z "${username}" ]; then
  echo "Specify username for gerrit"
  exit 1
fi
proj_file=${2:-"projects.txt"}
branch=${3:-"openstack-ci/fuel-6.1/2014.2"}
build_project=${4:-"openstack-build"}
vm_name="Package-tests"

VM_MAC_ADDR=$(virsh dumpxml ${vm_name} | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/g")
VM_IP=$(arp -n | grep ${VM_MAC_ADDR} | awk '{print $1}')

project_without_tests=

scripts_dir="$(pwd)/runtests-scripts"
mkdir ${scripts_dir}

for i in $(cat $proj_file); do
  project="${i}-build"
  dir=`mktemp -d`
  pushd ${dir}
  git clone ssh://${username}@review.fuel-infra.org:29418/${build_project}/${project}
  pushd ${project}
  git checkout ${branch}
  popd
  if [ ! -f ${project}/tests/runtests.sh ]; then
    echo "Test doesn't exist for project: ${project}"
    project_without_tests="${project_without_tests} ${project}"
  else
    cp ${project}/tests/runtests.sh ${scripts_dir}/"${i}-tests.sh"
  fi
  [ -f ${scripts_dir}/${i}.list ] && rm ${scripts_dir}/${i}.list
  for package in $(cat ${project}/trusty/debian/control | grep -E "^Package: .*" | awk '{print $2}'); do
    echo "${package}" >> ${scripts_dir}/${i}.list
  done
  popd
  rm -rf ${dir}
done

if [ -n "${project_without_tests}" ]; then
  echo "Projects without tests: ${project_without_tests}"
fi
