# POST /login

## Описание
Эндпоинт для аутентификации пользователя.

## Тело запроса и ответа
```json
{
  "request": {
    "username": "example@example.com",
    "password": "password"
  },
  "response": {
    "token": "Bearer eyJ0eXAiOiJKV1Qi..."
  }
}
