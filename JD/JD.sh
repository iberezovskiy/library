#!/bin/bash -x

# Instruction to configure ceilometer for vCenter support

CUR_DIR=$(pwd)
CONF="/etc/ceilometer/ceilometer.conf"

if [[ `cat /etc/*-release | head -n 1 | awk '{print $1}'` =~ Ubuntu ]]; then
   # If Ubuntu
   apt-get install openstack-ceilometer-compute -y --force-yes

   cd /usr/lib/python2.7/dist-packages/ceilometer/api/
   patch -i $CUR_DIR/diff_init __init__.py
   patch -i $CUR_DIR/diff_app app.py

   cd /usr/share/pyshared/ceilometer/api/
   patch -i $CUR_DIR/diff_init __init__.py
   patch -i $CUR_DIR/diff_app app.py

   cd /usr/share/pyshared/ceilometer/compute/virt/vmware/
   patch -i $CUR_DIR/diff_vsphere_operations vsphere_operations.py
   cd /usr/lib/python2.7/dist-packages/ceilometer/compute/virt/vmware/
   patch -i $CUR_DIR/diff_vsphere_operations vsphere_operations.py

else
   # If CentOS
   yum install openstack-ceilometer-compute -y

   cd /usr/lib/python2.6/site-packages/ceilometer/api/
   patch -i $CUR_DIR/diff_init __init__.py
   patch -i $CUR_DIR/diff_app app.py

   cd /usr/lib/python2.6/site-packages/ceilometer/compute/virt/vmware/
   patch -i $CUR_DIR/diff_vsphere_operations vsphere_operations.py
fi

# Common part

# Fix polling interval
sed -i "s/600/60/g"  /etc/ceilometer/pipeline.yaml

# Fix evaluating interval
sed -i "s/#evaluation_interval=.*/evaluation_interval=60/g" $CONF

# Set hypervisor inspector as vsphere
sed -i "s/#hypervisor_inspector=.*/hypervisor_inspector=vsphere/g" $CONF

# Set log levels
default_log_levels="amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,oslo.vmware=WARN"
sed -i "s/default_log_levels=.*/default_log_levels=$default_log_levels/g" $CONF

# Restart ceilometer services
for i in $(ls /etc/init.d/ | grep ceilometer);
do
   service $i restart
done
