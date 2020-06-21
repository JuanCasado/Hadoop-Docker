#!/bin/bash

hadoop fs -rm -f -r /input/*
hadoop fs -rm -f -r /output
hadoop fs -copyFromLocal /student.txt /input

$HADOOP_HOME/bin/hadoop jar $JAR_FILEPATH $CLASS_TO_RUN $PARAMS

hadoop fs -cat /output/*
