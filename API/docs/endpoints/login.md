# POST /login

## Описание
Эндпоинт для аутентификации пользователя.

## Тело запроса
```json
{
  "username": "example@example.com",
  "password": "password"
}```

## Тело ответа
```json
{
  "token": "Bearer eyJ0eXAiOiJKV1Qi..."
}```
