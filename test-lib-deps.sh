#!/bin/bash

test_script() {
  local rc=
  local package=$1

  if [ -n "$(ssh -p 29418 iberezovskiy@review.fuel-infra.org "gerrit ls-projects -b $branch" | grep "packages/trusty/$package")" ]; then
    dir=`mktemp -d`
    pushd $dir
    git clone ssh://iberezovskiy@review.fuel-infra.org:29418/packages/trusty/$package
    pushd $package
    git checkout $branch
    popd
    if [ -f "$package/tests/runtests.sh" ]; then
      scp $package/tests/runtests.sh root@$VM_IP:
      ssh root@$VM_IP -C "bash runtests.sh $package"
      rc=$?
    fi
    popd
    rm -rf $dir
    return $rc
  fi
  return 0
}


package_list_file="$1"

if [ -z "$package_list_file" -o ! -f "$package_list_file" ]; then
  echo "Need to specify file with package list"
  exit 1
fi

vm_name="Package-tests"
snapshot_name="main-snapshot"
branch="6.1"
list_broken_packages=
list_failed_to_test=

for i in $(cat $package_list_file); do
  virsh resume $vm_name

  echo "Testing $i package..."
  VM_MAC_ADDR=$(virsh dumpxml Package-tests | grep "mac address" | sed "s/.*'\(.*\)'.*/\1/g")
  VM_IP=$(arp -n | grep $VM_MAC_ADDR | awk '{print $1}')

  ssh root@$VM_IP -C "apt-get install $i -y --force-yes"
  if [ $? -ne '0' ]; then
    echo "Package $i has failed to install"
    list_broken_packages="$list_broken_packages $i"
  else
    test_script $i
    if [ "$?" -ne '0' ]; then
      echo "Package $i has failed to test"
      list_failed_to_test="$list_failed_to_test $i"
    fi
  fi

  virsh suspend $vm_name
  virsh snapshot-revert $vm_name $snapshot_name
done

if [ -n "$list_broken_packages" ]; then
  echo "List of broken packages: $list_broken_packages"
fi

if [ -n "$list_failed_to_test" ]; then
  echo "List failed to test packages: $list_failed_to_test"
fi

