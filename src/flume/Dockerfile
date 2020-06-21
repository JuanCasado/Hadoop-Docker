
ARG REGISTRY=""
FROM ${REGISTRY}hadoop-base:latest


ADD apache-flume-1.7.0-SNAPSHOT-bin.tar.gz /usr/local/apache-flume/
RUN ln -s /usr/local/apache-flume/apache-flume-1.7.0-SNAPSHOT-bin /usr/local/apache-flume/current && \
  rm -f /tmp/apache-flume-1.7.0-SNAPSHOT-bin.tar.gz

ADD zookeeper-3.5.2-alpha.tar.gz /usr/local/apache-zookeeper/
RUN ln -s /usr/local/apache-zookeeper/zookeeper-3.5.2-alpha /usr/local/apache-zookeeper/current && \
  rm -f /tmp/zookeeper-3.5.2-alpha.tar.gz

ENV FLUME_HOME="/usr/local/apache-flume/current"
ENV ZK_HOME="/usr/local/apache-zookeeper/current"

RUN ln -s /usr/local/apache-flume/apache-flume-1.7.0-SNAPSHOT-bin/ /app && \
  ln -s /usr/local/apache-flume/apache-flume-1.7.0-SNAPSHOT-bin/conf /config

ADD flume-init /app/bin/
ADD flume-cicle /app/bin/
ADD flume-env.sh /config/

ADD conf/* /config/
ADD flume-twitter-source-1.0-SNAPSHOT.jar /app/lib

RUN rm /app/lib/guava-11.0.2.jar && \
	cp /opt/hadoop-3.2.1/share/hadoop/hdfs/lib/guava-27.0-jre.jar /app/lib
