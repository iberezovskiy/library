!#/bin/bash

/usr/local/bin/trove-conductor --config-file=$TROVE_CONF_DIR/trove-conductor.conf --debug 2>&1 | tee $TROVE_LOG_DIR/trove-conductor.log
