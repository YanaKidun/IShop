# Авторизация через Bearer Token (JWT)

## Пример запроса на аутентификацию
Для получения токена аутентификации выполните запрос на эндпоинт `/login`.

### Пример запроса:
```bash
curl -X POST "https://virtserver.swaggerhub.com/STABROVSKAYAYA/Iba/1.0.0/login" \
-H "Content-Type: application/json" \
-d '{
  "username": "example@example.com",
  "password": "password"
}'
