
ARG REGISTRY=""
FROM ${REGISTRY}hadoop-base:latest

#ENV HIVE_VERSION=2.3.2
ENV HIVE_VERSION=3.1.2
ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH

WORKDIR /opt

RUN apt-get update && apt-get install -y wget procps && \
	wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
	tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
	mv apache-hive-$HIVE_VERSION-bin hive && \
	wget https://jdbc.postgresql.org/download/postgresql-42.2.12.jar -O $HIVE_HOME/lib/postgresql-jdbc.jar && \
	rm apache-hive-$HIVE_VERSION-bin.tar.gz


RUN	mkdir xlib && \
	wget https://repo1.maven.org/maven2/org/apache/hive/hive-hbase-handler/3.1.2/hive-hbase-handler-3.1.2.jar -O xlib/hive-hbase-handler-3.1.2.jar && \
	wget https://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper/3.4.10/zookeeper-3.4.10.jar -O xlib/zookeeper-3.4.10.jar && \
	wget https://repo1.maven.org/maven2/org/apache/hbase/hbase/0.94.27/hbase-0.94.27.jar -O xlib/hbase-0.94.27.jar

RUN rm /opt/hive/lib/guava-19.0.jar && \
	cp /opt/hadoop-3.2.1/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/hive/lib

RUN apt-get --purge remove -y wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /opt/scripts
COPY scripts /opt/scripts

EXPOSE 10000
EXPOSE 9083

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh
