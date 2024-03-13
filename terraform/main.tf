terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.65.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret

  schema_registry_id = var.schema_registry_id
  schema_registry_rest_endpoint = var.schema_registry_rest_endpoint
  schema_registry_api_key = var.schema_registry_api_key
  schema_registry_api_secret = var.schema_registry_api_secret
}

resource "confluent_environment" "team-amer" {
  display_name = "team-amer"

  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_kafka_cluster" "CHP_Sanjay" {
  display_name = "CHP_Sanjay"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-west-2"
  basic {}

  environment {
    id = confluent_environment.team-amer.id
  }
}


resource "confluent_kafka_cluster" "InsuranceCo_Sanjay" {
  display_name = "InsuranceCo_Sanjay"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-west-2"
  basic {}

  environment {
    id = confluent_environment.team-amer.id
  }
}

resource "confluent_service_account" "flink-demo-sa" {
  display_name = "flink-demo-sa"
  description  = "Service Account for the Flink demo"
}

resource "confluent_api_key" "chp-kafka-api-key" {
  display_name = "chp-kafka-api-key"
  description  = "Kafka API Key for the CHP cluster"
  
  owner {
    id          = confluent_service_account.flink-demo-sa.id
    api_version = confluent_service_account.flink-demo-sa.api_version
    kind        = confluent_service_account.flink-demo-sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.CHP_Sanjay.id
    api_version = confluent_kafka_cluster.CHP_Sanjay.api_version
    kind        = confluent_kafka_cluster.CHP_Sanjay.kind

    environment {
      id = confluent_environment.team-amer.id
    }
  }
}

output chp-kafka-api-key{
  value = confluent_api_key.chp-kafka-api-key.id
}

output chp-kafka-api-key-secret{
  value = confluent_api_key.chp-kafka-api-key.secret
  sensitive = true
}

resource "confluent_api_key" "insuranceco-kafka-api-key" {
  display_name = "insuranceco-kafka-api-key"
  description  = "Kafka API Key for the Insurance cluster"

  owner {
    id          = confluent_service_account.flink-demo-sa.id
    api_version = confluent_service_account.flink-demo-sa.api_version
    kind        = confluent_service_account.flink-demo-sa.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.InsuranceCo_Sanjay.id
    api_version = confluent_kafka_cluster.InsuranceCo_Sanjay.api_version
    kind        = confluent_kafka_cluster.InsuranceCo_Sanjay.kind

    environment {
      id = confluent_environment.team-amer.id
    }
  }
}

output insuranceco-kafka-api-key{
  value = confluent_api_key.insuranceco-kafka-api-key.id
}

output insuranceco-kafka-api-key-secret{
  value = confluent_api_key.insuranceco-kafka-api-key.secret
  sensitive = true
}

resource "confluent_role_binding" "flink-demo-kafka-cluster-CHP_Sanjay" {
  principal   = "User:${confluent_service_account.flink-demo-sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.CHP_Sanjay.rbac_crn
}

resource "confluent_role_binding" "flink-demo-kafka-cluster-InsuranceCo_Sanjay" {
  principal   = "User:${confluent_service_account.flink-demo-sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.InsuranceCo_Sanjay.rbac_crn
}

resource "confluent_kafka_acl" "flink-demo-sa-delete-incidents-topic-chp-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.CHP_Sanjay.id
  }
  resource_type = "TOPIC"
  resource_name = "incidents"
  pattern_type  = "PREFIXED"
  principal     = "User:${confluent_service_account.flink-demo-sa.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.CHP_Sanjay.rest_endpoint
  credentials {
    key    = confluent_api_key.chp-kafka-api-key.id
    secret = confluent_api_key.chp-kafka-api-key.secret
  }
}

resource "confluent_kafka_acl" "flink-demo-sa-delete-claims-topic-insuranceco-cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.InsuranceCo_Sanjay.id
  }
  resource_type = "TOPIC"
  resource_name = "claims"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.flink-demo-sa.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.InsuranceCo_Sanjay.rest_endpoint
  credentials {
    key    = confluent_api_key.insuranceco-kafka-api-key.id
    secret = confluent_api_key.insuranceco-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "incidents" {
  kafka_cluster {
    id = confluent_kafka_cluster.CHP_Sanjay.id
  }
  topic_name         = "incidents"
  rest_endpoint      = confluent_kafka_cluster.CHP_Sanjay.rest_endpoint

  credentials {
    key    = confluent_api_key.chp-kafka-api-key.id
    secret = confluent_api_key.chp-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "claims" {
  kafka_cluster {
    id = confluent_kafka_cluster.InsuranceCo_Sanjay.id
  }
  topic_name         = "claims"
  rest_endpoint      = confluent_kafka_cluster.InsuranceCo_Sanjay.rest_endpoint

  credentials {
    key    = confluent_api_key.insuranceco-kafka-api-key.id
    secret = confluent_api_key.insuranceco-kafka-api-key.secret
  }
}

resource "confluent_schema" "incidents-value" {
    subject_name = "incidents-value"
    format = "JSON"
    schema = file("../chp/incidents-value.json")

}

resource "confluent_schema" "claims-value" {
    subject_name = "claims-value"
    format = "JSON"
    schema = file("../ins_co/claims-value.json")  
}
