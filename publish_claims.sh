. ./set_env.sh

echo $INSCO_CLUSTER_API_KEY 
echo $INSCO_CLUSTER_API_SECRET 
echo $INSCO_CLUSTER_BOOTSTRAP_SERVER_URL 
echo $INSCO_CLAIMS_SCHEMA_ID 
echo $SR_ENDPOINT_URL 
echo $SR_CLUSTER_API_KEY 
echo $SR_CLUSTER_API_SECRET


cat ./ins_co/insuranceco_claim_records.txt | confluent kafka topic produce claims \
    --api-key $INSCO_CLUSTER_API_KEY \
    --api-secret $INSCO_CLUSTER_API_SECRET \
    --bootstrap $INSCO_CLUSTER_BOOTSTRAP_SERVER_URL \
    --schema $INSCO_CLAIMS_SCHEMA_ID \
    --value-format "jsonschema" \
    --schema-registry-endpoint $SR_ENDPOINT_URL \
    --schema-registry-api-key $SR_CLUSTER_API_KEY \
    --schema-registry-api-secret $SR_CLUSTER_API_SECRET