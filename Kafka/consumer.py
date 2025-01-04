from kafka import KafkaConsumer
import json

# Настройка параметров консьюмера
consumer = KafkaConsumer(
    'Topic1',  # Название топика
    bootstrap_servers='localhost:9094',
    auto_offset_reset='earliest',  # Чтение с начала, если смещения отсутствуют
    enable_auto_commit=True,
    group_id='topic_reader_group',  # Группа консьюмеров
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))  # Десериализация значения из JSON
)

print("Чтение сообщений из топика:")
for message in consumer:
    print(f"Сообщение из партиции {message.partition}, смещение {message.offset}: {message.value}")
    # Здесь можно обработать сообщение

consumer.close()
