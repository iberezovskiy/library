!#/bin/bash

/usr/local/bin/trove-api --config-file=$TROVE_CONF_DIR/trove.conf --debug 2>&1 | tee $TROVE_LOG_DIR/trove-api.log
