echo $DATABRICKS_HOST
echo $DATABRICKS_API_TOKEN
echo $DATABRICKS_ORDGID
echo $DATABRICKS_CLUSTER_ID

pip install databricks-connect


databricks-connect configure <<EOF
y 
https://adb-1330140498858410.10.azuredatabricks.net
$DATABRICKS_API_TOKEN
$DATABRICKS_CLUSTER_ID
$DATABRICKS_ORDGID
15001
EOF

databricks-connect test

echo "y
'"$DATABRICKS_HOST"'
$DATABRICKS_API_TOKEN
$DATABRICKS_CLUSTER_ID
$DATABRICKS_ORDGID
15001" | databricks-connect configure

databricks-connect test