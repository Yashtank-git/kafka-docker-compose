#!/bin/sh

# Wait for Kafka to be ready
echo "Waiting for Kafka to start..."
while ! nc -z kafka-1 19093; do
  sleep 1
done

# Create Kafka topics
echo "Creating Kafka topics..."
/opt/kafka/bin/kafka-topics.sh --create --topic first-topic --partitions 3 --replication-factor 1 --bootstrap-server kafka-1:19093 --command-config /client.properties
/opt/kafka/bin/kafka-topics.sh --create --topic test-topic --partitions 3 --replication-factor 1 --bootstrap-server kafka-2:19093 --command-config /client.properties
echo "Kafka topics created."
