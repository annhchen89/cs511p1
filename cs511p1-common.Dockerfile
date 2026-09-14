####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

FROM eclipse-temurin:8-jdk-jammy

RUN apt update && \
    apt upgrade --yes && \
    apt install ssh openssh-server python3 --yes

COPY resources/configure-heartbeats.py /configure-heartbeats.py

# Setup common SSH key.
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/shared_rsa -C common && \
    cat ~/.ssh/shared_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Setup HDFS/Spark resources here
# (the PySpark skeleton of Part 3 also needs python3 on every node; Spark 3.4.1
#  supports Python 3.7-3.11, so do not install a newer interpreter)

# Keep package installation before application scripts so edits reuse this layer.
RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates curl tar gzip && \
    rm -rf /var/lib/apt/lists/*

ARG HADOOP_VERSION=3.3.6

# Download, verify, and unpack Hadoop once for both derived images.
RUN set -eux; \
    curl --fail --location --retry 3 \
        "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
        --output /tmp/hadoop.tar.gz; \
    curl --fail --location --retry 3 \
        "https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.sha512" \
        --output /tmp/hadoop.sha512; \
    expected="$(awk '{print $NF}' /tmp/hadoop.sha512)"; \
    echo "${expected}  /tmp/hadoop.tar.gz" | sha512sum --check -; \
    mkdir -p /opt/hadoop; \
    tar -xzf /tmp/hadoop.tar.gz --strip-components=1 -C /opt/hadoop; \
    rm /tmp/hadoop.tar.gz /tmp/hadoop.sha512

ENV HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    HADOOP_LOG_DIR=/var/log/hadoop \
    HADOOP_PID_DIR=/var/run/hadoop \
    HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${PATH}"

# SSH-launched daemons also need Java's location in Hadoop's environment file.
RUN printf '\nexport JAVA_HOME=/opt/java/openjdk\n' >> /opt/hadoop/etc/hadoop/hadoop-env.sh && \
    mkdir -p /var/log/hadoop /var/run/hadoop && \
    hdfs version
