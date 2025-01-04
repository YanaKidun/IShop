from kafka import KafkaConsumer, TopicPartition
import json

# Настройка параметров консьюмера
consumer = KafkaConsumer(
    bootstrap_servers='localhost:9094',
    auto_offset_reset='earliest',  # Чтение с начала, если смещения отсутствуют
    enable_auto_commit=True,
    group_id='partition_reader_group-0',  # Группа консьюмеров
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))  # Десериализация значения из JSON
)

# Назначение чтения из первой партиции
partition = 0  # Номер партиции
consumer.assign([TopicPartition('Topic2', partition)])

print("Чтение сообщений из первой партиции:")
for message in consumer:
    if message.partition == partition:
        print(f"Сообщение из партиции {message.partition}: {message.value}")
        # Здесь можно обработать сообщение

consumer.close()
