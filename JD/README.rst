Setup ceilometer compute agent on controller node
=================================================

JD.sh is a script to configure ceilometer compute agent on controller node.

You should login on your controller node and install git on your system:

Ubuntu:

.. sourcecode:: bash

  apt-get install git -y --force-yes

CentOS:

.. sourcecode:: bash

  yum install git -y

Then you should get and script for ceilometer agent compute setup:

.. sourcecode:: bash

  git clone https://github.com/iberezovskiy/library/
  cd library/JD
  bash -x JD.sh


Detailed description of script:

Install ceilometer compute agent:

Ubuntu:

.. sourcecode:: bash

  apt-get install ceilometer-agent-compute -y --force-yes

Centos:

.. sourcecode:: bash

  yum install openstack-ceilometer-compute -y

Depending on your OS type and Fuel version you should patch these files:

Ubuntu and Fuel 5.0:

.. sourcecode:: bash

  patch -i diff_init /usr/lib/python2.7/dist-packages/ceilometer/api/__init__.py
  patch -i diff_init /usr/share/pyshared/ceilometer/api/__init__.py
  patch -i diff_app /usr/lib/python2.7/dist-packages/ceilometer/api/app.py
  patch -i diff_app /usr/share/pyshared/ceilometer/api/app.py
  patch -i diff_vsphere_operations /usr/share/pyshared/ceilometer/compute/virt/vmware/vsphere_operations.py
  patch -i diff_vsphere_operations/usr/lib/python2.7/dist-packages/ceilometer/compute/virt/vmware/vsphere_operations.py

Ubuntu and Fuel 5.1:

.. sourcecode:: bash

  patch -i diff_vsphere_operations /usr/share/pyshared/ceilometer/compute/virt/vmware/vsphere_operations.py
  patch -i diff_vsphere_operations /usr/lib/python2.7/dist-packages/ceilometer/compute/virt/vmware/vsphere_operations.py

Centos and Fuel 5.0:

.. sourcecode:: bash

  patch -i diff_init /usr/lib/python2.6/site-packages/ceilometer/api/__init__.py
  patch -i diff_app /usr/lib/python2.6/site-packages/ceilometer/api/app.py
  patch -i diff_vsphere_operations /usr/lib/python2.6/site-packages/ceilometer/compute/virt/vmware/vsphere_operations.py

Centos and Fuel 5.1:

.. sourcecode:: bash

  patch -i diff_vsphere_operations /usr/lib/python2.6/site-packages/ceilometer/compute/virt/vmware/vsphere_operations.py

Patches (diff_init, diff_app and diff_vsphere_operations) could be found in https://github.com/iberezovskiy/library/tree/master/JD

Then you need to change ceilometer polling interval:

.. sourcecode:: bash

  sed -i "s/600/60/g"  /etc/ceilometer/pipeline.yaml

Fix evaluating interval:

.. sourcecode:: bash

  sed -i "s/#evaluation_interval=.*/evaluation_interval=60/g" /etc/ceilometer/ceilometer.conf

Set hypervisor inspector as vsphere

.. sourcecode:: bash

  sed -i "s/#hypervisor_inspector=.*/hypervisor_inspector=vsphere/g" /etc/ceilometer/ceilometer.conf

Set log levels

.. sourcecode:: bash

  default_log_levels="amqp=WARN,amqplib=WARN,boto=WARN,qpid=WARN,sqlalchemy=WARN,suds=INFO,iso8601=WARN,requests.packages.urllib3.connectionpool=WARN,oslo.vmware=WARN"
  sed -i "s/#default_log_levels=.*/default_log_levels=$default_log_levels/g" /etc/ceilometer/ceilometer.conf

Then restart all ceilometer services:

.. sourcecode:: bash

  for i in $(ls /etc/init.d/ | grep ceilometer); do service $i restart; done
