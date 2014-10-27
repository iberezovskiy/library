===========================================
Scripts to install MongoDB on jenkins slave

Need to copy setup_mongo.pp and setup_mongo.sh files on slaves. Then:

* to deploy HA Mongo cluster:

1. Configure some secondary nodes:

.. sourcecode:: bash

  primare=false node_ip=172.18.168.1 mongo_hosts="'172.18.168.1'" bash setup_mongo.sh
  primare=false node_ip=172.18.168.2 mongo_hosts="'172.18.168.2'" bash setup_mongo.sh

2. Configure primary node

.. sourcecode:: bash

  primare=true node_ip=172.18.168.3 mongo_hosts="'172.18.168.1' '172.18.168.2' '172.18.168.3'" bash setup_mongo.sh

* to deploy single Mongo:

.. sourcecode:: bash

  primare=false node_ip=172.18.168.1 mongo_hosts="'172.18.168.1'" bash setup_mongo.sh
