#!/bin/bash

/opt/hbase-$HBASE_VERSION/bin/hbase-daemon.sh start thrift -p 9090
/opt/hbase-$HBASE_VERSION/bin/hbase-daemon.sh start rest -p 8081
/opt/hbase-$HBASE_VERSION/bin/hbase master start
