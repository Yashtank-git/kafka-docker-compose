# Kafka docker compose up and topics creation

docker-compose -f /home/cloud_user/kafka-docker-compose/docker-compose.yml up -d

docker-compose exec kafka-1 bash -c 'while ! nc -z kafka-1 9092; do sleep 1; done; echo "Bootstrap server kafka-1 is connected"'

docker-compose exec kafka-1 bash -c 'sleep 1; ./opt/kafka/bin/kafka-topics.sh --bootstrap-server kafka-1:9092 --topic first-topic --create --partitions 3 --replication-factor 1'

