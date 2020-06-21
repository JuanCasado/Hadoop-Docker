
# Hadoop stack

Using Hadoop 3.2.1 over debian 9 with JDK-8.
The stack deploys a multi node hadoop with the following components installed.

* Flume 1.7.0
* HBase 2.2.4
* Pig 0.17.0
* Hive 3.1.2
* PostgreSQL 12.2.0
* Zookeeper 3.4.10

## Setup

Before stating the compose or the swarm deployment the base container needs to be created.
This can be done by running:

```bash
./setup.sh
```

Then the rest of the images can be built with:

```bash
docker-compose build
```

For swarm to run docker-compose docker-machine are needed.

## Hadoop Compose single node

A fixed sized multi node node hadoop installation with just a single node.
Easy to use, manage and deploy with docker-compose.
New node managers or data nodes can be added manually to create a new fixed size deployment (not recommend, instead use swarm).

**Do not start both swarm and compose at the same time, namespaces may collide.**

### Starting containers

```bash
  docker-compose up
```

### Stopping the containers

```bash
  ^C
  docker-compose down
```

## Hadoop Swarm multi node

The full multi node hadoop potential is unleashed.
Each component can be replicated which will extend the number of instances of data nodes and node managers.

### Starting swarm

This will build the images needed for the swarm.
Also the containers can be build manually before starting the swarm.

```bash
  ./swarm.sh up
```

Swarm will start a swarm visualizer on port 8080.

### Stopping swarm

```bash
  ./swarm.sh down
```

## Accessing services

* Namenode: [http://localhost:9870/dfshealth.html#tab-overview](http://localhost:9870/dfshealth.html#tab-overview)
* History server: [http://localhost:8188/applicationhistory](http://localhost:8188/applicationhistory)
* Datanode: [http://localhost:9864/](http://localhost:9864/)
* Nodemanager: [http://localhost:8042/node](http://localhost:8042/node)
* Resource manager: [http://localhost:8088/](http://localhost:8088/)
* HBase: [http://localhost:16010/master-status](http://localhost:16010/master-status)

If swarm mode is used *localhost* needs to be changed for the IP that swarm creates for its entry point, that IP is printed when swarm up is run.
Also it can be checked with:

```bash
  docker-machine ls
```

It will be the IP of the master.

## Extracting data with flume

```bash
  docker-compose -f docker-compose-data.yml up flume
```

By modifying docker-compose-data.yml env.SOURCE parameter container execution can be changed.
Options are:

```yml
  SOURCE: "TwitterSpainpbKeywords"
  SOURCE: "TwitterSpainPB"
  SOURCE: "TwitterMadrid"
  SOURCE: "TwitterKeywords"
  SOURCE: "TwitterBarcelona"
```

To access the container:

```yml
  command: "bash"
```

## Moving data from hdfs to hbase with pig

```bash
  docker-compose -f docker-compose-data.yml up pig
```

By modifying docker-compose-data.yml command parameter container execution can be changed.
Options are:

```yml
  command: "pig -x local /scripts/analysis.pig"
  command: "pig -x mapreduce /scripts/analysis.pig"
```

To access the container:

```yml
  command: "bash"
```

## Exploiting Twitter

By following the Lambda architecture this hadoop installation can be used by performing the following actions:

1. Create Hbase and Hive tables if not yet created
2. Extract data from Twitter with Flume and save it on HDFS
3. Load that data from HDFS into Hbase
4. Delete the data from HDFS
5. Repeat from step 2

This actions have already been implemented leaving the data ready to use in Hive by running

```bash
  ./exploit.sh
```

## Configuring hadoop

The available configurations are:

* /etc/hadoop/core-site.xml CORE_CONF
* /etc/hadoop/hdfs-site.xml HDFS_CONF
* /etc/hadoop/yarn-site.xml YARN_CONF
* /etc/hadoop/httpfs-site.xml HTTPFS_CONF
* /etc/hadoop/kms-site.xml KMS_CONF
* /etc/hadoop/mapred-site.xml  MAPRED_CONF

If you need to extend some other configuration file, refer to base/entrypoint.sh bash script.
