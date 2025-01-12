# Схема Товара (product):
```
{
  "id": 105,
  "name": "Молоко",
  "price_with_discount": 1.99,
  "group": "Молочные продукты",
  "char_code": "SHP0001",
  "count_of_warehouse": 1000
}
```
# Схема Заказа (order):
```
{
  "id": 123,
  "client_id": 456,
  "status": "new",
  "order_date": "2024-12-30",
  "total_price": 100.5,
  "products": []
}
```
