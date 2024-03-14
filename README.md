# flink-cc-demo

A simple demo for cross-cluster joins between two Kafka clusters using Flink on Confluent Cloud. This cross-cluster join is not possible with ksqlDB.

## Use Case:<br>
An Insurance company can validate the authenticity of the claims in real-time by cross-referencing (SQL join) data about traffic incidents (weather, road repairs, collisons etc) published by an organization like California Highway Patrol(CHP) here: https://cad.chp.ca.gov/traffic.aspx?ddlComCenter=BFCC . 

This data can be published to a Apache Kafka topic 'incidents' hosted by an organization like CHP. This data can be joined with another topic 'claims' hosyed by an insurance company that captures claims submitted to the insurance company with FlinkSQL joins to validate the authenticity of the claim in real-time .

Of course you will need to use another Confluent Cloud feature, the Stream Shares, https://docs.confluent.io/cloud/current/stream-sharing/index.html to expose topics across organizations. The scope of this demo does not include Stream Shares.

