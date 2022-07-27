#!/usr/bin/env bash

echo $DATABRICKS_HOST
echo $DATABRICKS_TOKEN
echo $DATABRICKS_ORDGID
echo $DATABRICKS_CLUSTER_ID
pip install databricks-cli --upgrade
#pip uninstall pyspark
#pip install -U databricks-connect=="10.4.0b0"
#apt install openjdk-8-jdk

databricks configure --token <<EOF
"https://adb-1330140498858410.10.azuredatabricks.net/"
"dapib19f5d0356fdd4be30b689cb27b4596c-3"
EOF



echo "Commands"
databricks -h 

databricks fs ls
databricks fs mkdirs dbfs:/tmp/new-dir


#databricks-connect configure <<EOF
#y 
#"$DATABRICKS_HOST"
#$DATABRICKS_TOKEN
#$DATABRICKS_CLUSTER_ID
#$DATABRICKS_ORDGID
#15001
#EOF
#databricks-connect configure
#databricks-connect test


#echo $DATABRICKS_HOST
#echo $DATABRICKS_TOKEN
#echo $DATABRICKS_ORDGID
#echo $DATABRICKS_CLUSTER_ID
#echo "Second Attempt"
#echo "y
#"$DATABRICKS_HOST"
#$DATABRICKS_TOKEN
#$DATABRICKS_CLUSTER_ID
#$DATABRICKS_ORDGID
#15001" | databricks-connect configure

