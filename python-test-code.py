from kafka import KafkaProducer
 
# Create a Kafka producer instance
producer = KafkaProducer(
    bootstrap_servers='localhost:29094',  # Replace with your Kafka broker address
    security_protocol='SASL_PLAINTEXT',
    sasl_mechanism='PLAIN',  # Replace with your SASL mechanism
    sasl_plain_username='alice',  # Replace with your SASL username
    sasl_plain_password='alice-secret' # Replace with your SASL password

)
print(producer.bootstrap_connected())
# Produce a message to the Kafka topic
topic = "your_topic"  # Replace with your topic name
producer.send(topic, key=b'ping', value=b'yash')
producer.flush()
producer.close()
