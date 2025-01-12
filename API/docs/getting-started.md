# Установка и настройка API

## Как подключиться к API
Для подключения к API вы можете использовать инструменты, такие как [Postman](https://www.postman.com/) или `curl`. 

### Требования для работы с API:
- Токен аутентификации (JWT) требуется для защищённых запросов.
- Доступ к базовым URL серверам API.

## Базовые URL сервера:
- `https://virtserver.swaggerhub.com/STABROVSKAYAYA/Iba/1.0.0`

---

## Пример запроса для тестирования

Для тестирования API можно использовать следующий `curl`-запрос:

```bash
curl -X POST "https://virtserver.swaggerhub.com/STABROVSKAYAYA/Iba/1.0.0/login" \
-H "Content-Type: application/json" \
-d '{
  "username": "example@example.com",
  "password": "password"
}'
