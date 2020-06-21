FROM debian:9

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      openjdk-8-jdk \
      net-tools \
      curl \
      netcat \
      gnupg \
    && rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/
RUN curl -O https://dist.apache.org/repos/dist/release/hadoop/common/KEYS
RUN gpg --import KEYS

ENV HADOOP_VERSION 2.6.0
ENV HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
RUN curl -LO https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
		tar xzf hadoop-$HADOOP_VERSION.tar.gz && \
		rm hadoop-$HADOOP_VERSION.tar.gz && \
		mv hadoop-$HADOOP_VERSION $HADOOP_HOME

RUN ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
RUN mkdir /opt/hadoop-$HADOOP_VERSION/logs
RUN mkdir /hadoop-data
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_HOME/bin/:$PATH
ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


RUN apt-get update && apt-get install -y wget procps
ENV PIGLIBS=/pig-libs

RUN mkdir /pig-libs && \
		wget https://repo1.maven.org/maven2/com/twitter/elephantbird/elephant-bird-pig/4.17/elephant-bird-pig-4.17.jar -O $PIGLIBS/elephant-bird-pig-4.17.jar && \
		wget https://repo1.maven.org/maven2/com/twitter/elephantbird/elephant-bird-hadoop-compat/4.17/elephant-bird-hadoop-compat-4.17.jar -O $PIGLIBS/elephant-bird-hadoop-compat-4.17.jar && \
		wget https://repo1.maven.org/maven2/com/twitter/elephantbird/elephant-bird-core/4.17/elephant-bird-core-4.17.jar -O $PIGLIBS/elephant-bird-core-4.17.jar && \
		wget https://repo1.maven.org/maven2/com/twitter/elephantbird/elephant-bird-cascading-protobuf/4.17/elephant-bird-cascading-protobuf-4.17.jar -O $PIGLIBS/elephant-bird-cascading-protobuf-4.17.jar
ADD pig-twitter-udfs-1.0-SNAPSHOT.jar /pig-libs
RUN apt-get --purge remove -y wget && \
		apt-get clean && \
		rm -rf /var/lib/apt/lists/*


ENV PIG_VERSION=0.17.0
ENV PIG_HOME=/pig-$PIG_VERSION
RUN curl -LO http://archive.apache.org/dist/pig/pig-$PIG_VERSION/pig-$PIG_VERSION.tar.gz && \
		tar xzf pig-$PIG_VERSION.tar.gz && \
		rm pig-$PIG_VERSION.tar.gz
ENV PATH $PATH:/pig-$PIG_VERSION/bin

ENV HBASE_VERSION 1.6.0
ENV HBASE_HOME=/hbase-$HBASE_VERSION
ENV HBASE_URL http://archive.apache.org/dist/hbase//$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
RUN set -x && \
		curl -fSL "$HBASE_URL" -o /tmp/hbase-$HBASE_VERSION.tar.gz && \
		curl -fSL "$HBASE_URL.asc" -o /tmp/hbase-$HBASE_VERSION.tar.gz.asc && \
		tar -xvf /tmp/hbase-$HBASE_VERSION.tar.gz -C / && \
		rm /tmp/hbase-$HBASE_VERSION.tar.gz*

RUN mkdir -p /etc/hbase/conf
ENV CLASSPATH $CLASSPATH:/etc/hadoop
ENV PIG_CLASSPATH=$PIG_CLASSPATH:/etc/hadoop
ENV HADOOP_USER_CLASSPATH_FIRST=true
ENV HBASE_CONF_DIR=/etc/hadoop
COPY hbase-site.xml /etc/hadoop

RUN mkdir /scripts
ADD scripts/* /scripts/