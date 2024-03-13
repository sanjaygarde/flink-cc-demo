. ./set_env.sh

echo $CHP_CLUSTER_API_KEY 
echo $CHP_CLUSTER_API_SECRET 
echo $CHP_CLUSTER_BOOTSTRAP_SERVER_URL 
echo $CHP_INCIDENTS_SCHEMA_ID 
echo $SR_ENDPOINT_URL 
echo $SR_CLUSTER_API_KEY 
echo $SR_CLUSTER_API_SECRET

cat chp/chp_incident_records.txt | confluent kafka topic produce incidents \
 --api-key $CHP_CLUSTER_API_KEY \
 --api-secret $CHP_CLUSTER_API_SECRET \
 --bootstrap $CHP_CLUSTER_BOOTSTRAP_SERVER_URL \
 --schema $CHP_INCIDENTS_SCHEMA_ID \
 --value-format "jsonschema" \
 --schema-registry-endpoint $SR_ENDPOINT_URL \
 --schema-registry-api-key $SR_CLUSTER_API_KEY  \
 --schema-registry-api-secret $SR_CLUSTER_API_SECRET
