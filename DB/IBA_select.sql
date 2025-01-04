USE `IBA_3` ;

-- Выборка оплаченных заказов на конкретную дату
SELECT * 
FROM client_order
WHERE client_cart_status_id = 6 
AND DATE(update_time) = '2024-11-06';

-- выборка оплаченных заказов на даты в промежутке
SELECT * 
FROM client_order
WHERE client_cart_status_id = 6 
AND DATE(update_time) BETWEEN '2024-11-01' AND '2024-11-10';

-- Выборка оплаченных заказов на предыдущую неделю 
SELECT * 
FROM client_order
WHERE client_cart_status_id = 6 
AND update_time >= CURDATE() - INTERVAL 7 DAY;

-- Выборка оплаченных заказов за предыдущий месяц
SELECT * 
FROM client_order
WHERE client_cart_status_id = 6 
AND create_time >= CURDATE() - INTERVAL 1 MONTH;

-- Выборка оплаченных заказов за предыдущий год 
SELECT * 
FROM client_order
WHERE client_cart_status_id = 6 
AND create_time >= CURDATE() - INTERVAL 1 YEAR;

-- Выборка по суммам корзин клиентов больше среднего значения сумм корзин клиентов
SELECT 
    COUNT(*) AS total_count,  
    SUM(amount_product_sum) AS total_sum  
FROM 
    client_order_detail
WHERE 
    amount_product_sum > (
    SELECT AVG(amount_product_sum) 
    FROM client_order_detail);

--  Выборка по суммам и количеству оплаченных заказов больше среднего значения по оплаченным заказам 
SELECT 
    COUNT(*) AS total_count,
    SUM(amount_product_sum) AS total_sum  
FROM 
    client_order_detail AS cod
JOIN 
    client_order AS co 
    ON cod.client_cart_id = co.client_cart_id  
WHERE 
    cod.amount_product_sum > (
      SELECT AVG(amount_product_sum) 
      FROM client_order_detail)
    AND co.client_cart_status_id = 6;

-- Средняя сумма продаж для определенной категории товаров за указанный период 
SELECT 
    AVG(cod.amount_product_sum) AS avg_sale_amount  -- Средняя сумма продажи
FROM 
    client_order_detail AS cod
JOIN 
    client_order AS co 
    ON cod.client_cart_id = co.client_cart_id  -- Присоединение таблицы с заказами
JOIN 
    product p 
    ON cod.product_id = p.product_id  -- Присоединение таблицы с товарами
WHERE 
    p.product_group_id = 1  
    AND co.client_cart_status_id = 6
    AND co.update_time BETWEEN '2024-01-01' AND '2024-11-11'; 

--  Средняя сумма продаж для определенной категории товаров за указанный период
SELECT 
    pg.group_name, 
    AVG(cod.amount_product_sum) AS avg_sale_amount 
FROM 
    client_order_detail AS cod
JOIN 
    client_order AS co 
    ON cod.client_cart_id = co.client_cart_id  
JOIN 
    product p 
    ON cod.product_id = p.product_id  
JOIN 
    product_group AS pg
    ON p.product_group_id = pg.product_group_id  
WHERE 
    p.product_group_id = 1  
    AND co.client_cart_status_id = 6  
    AND co.update_time BETWEEN '2024-01-01' AND '2024-11-11'  
GROUP BY 
    pg.group_name;  

-- Средняя сумма продаж определенного товара за указанный период 
SELECT 
    p.product_name, AVG(cod.amount_product_sum) AS avg_sale_amount  
FROM 
    client_order_detail AS cod
JOIN 
    client_order AS co 
    ON cod.client_cart_id = co.client_cart_id  
JOIN 
    product p 
    ON cod.product_id = p.product_id  
WHERE 
    p.product_id = 1  
    AND co.client_cart_status_id = 6
    AND co.update_time BETWEEN '2024-01-01' AND '2024-11-11'
GROUP BY 
    p.product_name; 

-- Количество товарных наименований в каждой группе 
SELECT 
    pg.group_name,    
    COUNT(p.product_id) AS product_count 
FROM 
    product_group AS pg
LEFT JOIN 
    product AS p
    ON pg.product_group_id = p.product_group_id  
GROUP BY 
    pg.group_name; 

-- Выборка групп товаров, у которых нет товаров 
SELECT 
    pg.product_group_id,      
    pg.group_name             
FROM 
    product_group AS pg
LEFT JOIN 
    product AS p
    ON pg.product_group_id = p.product_group_id  
WHERE 
    p.product_id IS NULL; 

-- Вариант 2 
SELECT 
    pg.product_group_id,      
    pg.group_name            
FROM 
    product_group AS pg
WHERE 
     NOT EXISTS (         -- проверяет, что в подзапросе НЕТ ни одной строки
        SELECT 1
        FROM product AS p
        WHERE p.product_group_id = pg.product_group_id
    );
