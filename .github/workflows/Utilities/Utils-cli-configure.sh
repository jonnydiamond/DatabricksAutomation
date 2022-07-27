echo $DATABRICKS_HOST
echo $DATABRICKS_TOKEN
echo $DATABRICKS_ORDGID
echo $DATABRICKS_CLUSTER_ID

pip install databricks-connect


databricks-connect configure <<EOF
y 
$DATABRICKS_HOST
$DATABRICKS_TOKEN
$DATABRICKS_CLUSTER_ID
$DATABRICKS_ORDGID
15001
EOF

databricks-connect test

echo "Second Attempt"
echo "y
'"$DATABRICKS_HOST"'
$DATABRICKS_TOKEN
$DATABRICKS_CLUSTER_ID
$DATABRICKS_ORDGID
15001" | databricks-connect configure