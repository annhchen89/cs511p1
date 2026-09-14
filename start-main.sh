#!/bin/bash

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

# Exchange SSH keys.
/etc/init.d/ssh start
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/shared_rsa
for node in worker1 worker2; do
    ready=false
    for attempt in {1..60}; do
        if ssh-copy-id -i ~/.ssh/id_rsa.pub -o 'IdentityFile ~/.ssh/shared_rsa' \
                -o StrictHostKeyChecking=no -o ConnectTimeout=2 -f "$node"; then
            ready=true
            break
        fi
        sleep 1
    done
    if [ "$ready" = false ]; then
        echo "Could not exchange SSH keys with $node" >&2
        exit 1
    fi
done

# Apply the supplied timing before the student service-start commands below.
# No Hadoop installation is expected in the unfinished Part 0 starter.
if command -v hdfs >/dev/null 2>&1; then
    python3 /configure-heartbeats.py || exit 1
fi

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Format only a new NameNode; restarting must retain the namespace.
set -euo pipefail
mkdir -p /var/lib/hadoop/hdfs/namenode /var/lib/hadoop/hdfs/datanode \
    /var/log/hadoop /var/run/hadoop
if [ ! -f /var/lib/hadoop/hdfs/namenode/current/VERSION ]; then
    hdfs namenode -format -nonInteractive
fi
hdfs --daemon start namenode

# Wait for the NameNode RPC service before starting the local DataNode.
deadline=$((SECONDS + 60))
until hdfs dfsadmin -safemode get; do
    if [ "$SECONDS" -ge "$deadline" ]; then
        echo "NameNode did not become ready; see /var/log/hadoop." >&2
        exit 1
    fi
    sleep 1
done

# Each container owns its DataNode, so workers can restart independently.
# Run it in the foreground to keep the container alive and receive stop signals.
exec hdfs datanode
