from kafka import KafkaProducer
import json
from datetime import datetime

# Настройка параметров продюсера
from kafka import KafkaProducer

producer = KafkaProducer(
    bootstrap_servers='92.255.110.199:9092',
    security_protocol="SASL_PLAINTEXT",
    sasl_mechanism="SCRAM-SHA-512",
    sasl_plain_username='gen_user',
    sasl_plain_password='TYGVi_c1iuh9V6')

# Данные для отправки
messages = [
    {"id": 21, "fio": "Ivanov II", "topic": "Жалоба", "text": "Zakaz ne priexal", "date": "2024-01-12-00:30"},
    {"id": 22, "fio": "Karpov II", "topic": "Благодарность", "text": "Good", "date": "2024-01-12-00:30"},
    {"id": 24, "fio": "Kapustin II", "topic": "Вопрос", "text": "Whats time to open?", "date": "2024-01-12-00:30"}
]

# Отправка сообщений в топик без учета партиций
for msg in messages:
    value = {
        "id": msg["id"],
        "fio": msg["fio"],
        "topic": msg["topic"],
        "text": msg["text"],
        "date": msg["date"],
        "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    # Отправка сообщения
    producer.send('message_topic', value=value)

# Ожидание завершения отправки сообщений
producer.flush()

print("Все сообщения отправлены!")

producer.close()
