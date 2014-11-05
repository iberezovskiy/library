!#/bin/bash

/usr/local/bin/trove-taskmanager --config-file=$TROVE_CONF_DIR/trove-taskmanager.conf --debug 2>&1 | tee $TROVE_LOG_DIR/trove-taskmanager.log
