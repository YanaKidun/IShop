from kafka import KafkaProducer
import json
from datetime import datetime

# Настройка параметров продюсера
producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    key_serializer=str.encode,  # Сериализация ключа в байты
    value_serializer=lambda v: json.dumps(v).encode('utf-8')  # Сериализация значения в JSON
)

# Данные для отправки
messages = [
    {"id": 21, "fio": "Ivanov II", "topic": "Жалоба", "text": "Zakaz ne priexal", "date": "2024-01-12-00:30"},
    {"id": 22, "fio": "Karpov II", "topic": "Благодарность", "text": "Good", "date": "2024-01-12-00:30"},
    {"id": 24, "fio": "Kapustin II", "topic": "Вопрос", "text": "Whats time to open?", "date": "2024-01-12-00:30"}
]

# Отправка сообщений с распределением по партициям по ключу (теме)
for msg in messages:
    key = msg["topic"]  # Ключ для распределения по партициям
    value = {
        "id": msg["id"],
        "fio": msg["fio"],
        "topic": msg["topic"],
        "text": msg["text"],
        "date": msg["date"],
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    # Отправка сообщения
    producer.send('Topic1', key=key, value=value)

# Ожидание завершения отправки сообщений
producer.flush()

print("Все сообщения отправлены!")

producer.close()