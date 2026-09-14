#!/bin/bash
export JAVA_HOME=/opt/java/openjdk
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH"

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Setup HDFS/Spark worker here
mkdir -p "$HADOOP_HOME/etc/hadoop"
cat > "$HADOOP_HOME/etc/hadoop/core-site.xml" <<'EOF'
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://main:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/tmp/hadoop</value>
    </property>
</configuration>
EOF

cat > "$HADOOP_HOME/etc/hadoop/hdfs-site.xml" <<'EOF'
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/tmp/hdfs/datanode</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address</name>
        <value>main:9000</value>
    </property>
    <property>
        <name>dfs.namenode.http-address</name>
        <value>main:9870</value>
    </property>
    <property>
        <name>dfs.namenode.datanode.registration.ip-hostname-check</name>
        <value>false</value>
    </property>
</configuration>
EOF

mkdir -p "$SPARK_HOME/conf"
cat > "$SPARK_HOME/conf/spark-env.sh" <<'EOF'
export SPARK_MASTER_HOST=main
export SPARK_MASTER_PORT=7077
export SPARK_LOCAL_IP=$(hostname)
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1g
EOF
