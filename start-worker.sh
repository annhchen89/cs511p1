#!/bin/bash

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

/etc/init.d/ssh start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shared_rsa

# Apply the supplied timing before the student service-start commands below.
# No Hadoop installation is expected in the unfinished Part 0 starter.
if command -v hdfs >/dev/null 2>&1; then
    python3 /configure-heartbeats.py || exit 1
fi

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

set -euo pipefail
mkdir -p /var/lib/hadoop/hdfs/datanode /var/log/hadoop /var/run/hadoop

# The DataNode retries connecting if main is still starting. Foreground execution
# keeps the container alive and allows Docker to stop the service cleanly.
exec hdfs datanode
