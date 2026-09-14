####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

FROM cs511p1-common

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Main hosts the NameNode and a DataNode; create their storage before script COPYs.
# setup-main.sh can use these paths in hdfs-site.xml.
RUN mkdir -p /var/lib/hadoop/hdfs/namenode /var/lib/hadoop/hdfs/datanode

COPY ./setup-main.sh ./setup-main.sh
RUN /bin/bash setup-main.sh

COPY ./start-main.sh ./start-main.sh
CMD ["/bin/bash", "start-main.sh"]
