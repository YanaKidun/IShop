use iba_3;
-- -----------------------------------------------------
-- Триггер на вставку автоматическую вставку стоимости товара client_order_detail.product_price_with_discount при вставке данных в эту таблицу.
-- -----------------------------------------------------

DELIMITER //

CREATE TRIGGER set_product_price_with_discount
BEFORE INSERT ON `IBA_3`.`client_order_detail`
FOR EACH ROW
BEGIN
    DECLARE product_discount_price DECIMAL(8,2);  -- Объявляем переменную, в которую будем записывать стоимость товара `price_with_discount` из таблицы `product`
    
    SELECT `price_with_discount` INTO product_discount_price
    FROM `IBA_3`.`product`
    WHERE `product_id` = NEW.`product_id`; --  NEW.`product_id`- это значение product_id новой записи
    
    SET NEW.`product_price_with_discount` = product_discount_price; -- Записываем ранее забранное значение `product_price_with_discount` в новое (NEW) значение для вставки
END //

DELIMITER ;

-- -----------------------------------------------------
-- Проверяем работу триггера
-- Стоимость вставилась автоматически, без указания в коде insert
-- -----------------------------------------------------

INSERT INTO `IBA_3`.`client_order` (`client_cart_id`, `client_id`, `client_cart_status_id`, `client_cart_sum`, `update_time`, `create_time`)
VALUES
(3, 1, default, default, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO `IBA_3`.`client_order_detail` (`client_cart_id`, `product_id`, `product_count`, `update_time`)
VALUES (3, 1, 5, CURRENT_TIMESTAMP);

select  cod.client_cart_id, cod.product_price_with_discount, p.price_with_discount
from client_order_detail AS cod
join product AS p
on cod.product_id = p.product_id; 

-- -------------------------------------------
-- Создадим триггерную функцию, которая будет обновлять общую сумму заказа на основе деталей заказа.
-- Шаг 1. Функция
-- -------------------------------------------
DELIMITER //

CREATE FUNCTION summ_cart_sum(cart_id INT) -- создаем функцию
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    DECLARE total_sum DECIMAL(8,2);
   
    SELECT COALESCE(SUM(amount_product_sum), 0) INTO total_sum  -- Вычисляем сумму по полю amount_product_sum для данного client_cart_id
    FROM `IBA_3`.`client_order_detail`
    WHERE client_cart_id = cart_id;
    
    RETURN total_sum;
END //

DELIMITER ;

-- -------------------------------------------
-- Создадим триггер для функции
-- Шаг 2. Триггер
-- -------------------------------------------
DELIMITER //

CREATE TRIGGER after_insert_client_order_detail
AFTER INSERT ON `IBA_3`.`client_order_detail`
FOR EACH ROW
BEGIN
    UPDATE `IBA_3`.`client_order`
    SET client_cart_sum = summ_cart_sum(NEW.client_cart_id)  -- Вызываем функцию summ_cart_sum и обновляем поле client_cart_sum в client_order
    WHERE client_cart_id = NEW.client_cart_id;
END //

DELIMITER ;

-- -----------------------------------------------------
-- Проверим как отрабатывает триггер + функция 
-- -----------------------------------------------------

INSERT INTO `IBA_3`.`client_order` (`client_cart_id`, `client_id`, `client_cart_status_id`, `client_cart_sum`, `update_time`, `create_time`)
VALUES
(5, 1, default, default, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO `IBA_3`.`client_order_detail` (`client_cart_id`, `product_id`, `product_count`, `update_time`)
VALUES (5, 1, 5, CURRENT_TIMESTAMP);

SELECT * FROM  client_order
WHERE client_cart_id = 4;

INSERT INTO `IBA_3`.`client_order_detail` (`client_cart_id`, `product_id`, `product_count`, `update_time`)
VALUES (5, 2, 2, CURRENT_TIMESTAMP);

SELECT * FROM  client_order_detail
WHERE client_cart_id = 5;

-- -------------------------------------------
-- Добавим триггеры на обновления заказа и удаление заказа, что бы в заказе изменялась сумма
-- реиспользуя функцию  summ_cart_sum
-- -------------------------------------------

-- Триггер для пересчета суммы при обновлении
DELIMITER //

CREATE TRIGGER update_client_order_detail
AFTER UPDATE ON `IBA_3`.`client_order_detail`
FOR EACH ROW
BEGIN
    UPDATE `IBA_3`.`client_order`
    SET client_cart_sum = calculate_cart_sum(NEW.client_cart_id)
    WHERE client_cart_id = NEW.client_cart_id;
END; //

DELIMITER ;

-- Триггер для пересчета суммы при удалении
DELIMITER //

CREATE TRIGGER delete_client_order_detail
AFTER DELETE ON `IBA_3`.`client_order_detail`
FOR EACH ROW
BEGIN
    UPDATE `IBA_3`.`client_order`
    SET client_cart_sum = calculate_cart_sum(OLD.client_cart_id) -- OLD.client_cart_id значение client_cart_id из удаляемой строки в таблице client_order_detail
    WHERE client_cart_id = OLD.client_cart_id; -- 
END;//

DELIMITER ;


-- -------------------------------------------
-- Обновление суммы выкупа клиента в таблице client когда изменяется статус заказа на  'Paid' (id=6) и 'Returned'(id =7)
-- -------------------------------------------
DELIMITER //

CREATE TRIGGER new_client_amout_order
AFTER UPDATE ON `IBA_3`.`client_order`
FOR EACH ROW
BEGIN
  
    IF NEW.client_cart_status_id = 6 THEN   -- Проверка: если новый статус заказа 6, добавляем сумму заказа
        UPDATE `IBA_3`.`client`
        SET client_amout_order = client_amout_order + NEW.client_cart_sum
        WHERE client_id = NEW.client_id;
        
    ELSEIF NEW.client_cart_status_id = 7 THEN -- Проверка: если новый статус заказа 7, отнимаем сумму заказа
        UPDATE `IBA_3`.`client`
        SET client_amout_order = client_amout_order - OLD.client_cart_sum
        WHERE client_id = NEW.client_id;
    END IF;
END //

DELIMITER ;

-- Проверим как отрабатывает триггер. Создадим заказы, а после обновим их статус. 
SELECT * FROM client_order;

INSERT INTO `IBA_3`.`client_order` (`client_cart_id`, `client_id`, `client_cart_status_id`, `client_cart_sum`, `update_time`, `create_time`)
VALUES
(7, 1, default, default, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO `IBA_3`.`client_order_detail` (`client_cart_id`, `product_id`, `product_count`, `update_time`)
VALUES 
(7, 2, 5, CURRENT_TIMESTAMP),
(7, 10, 20, CURRENT_TIMESTAMP);

UPDATE IBA_3.client_order
SET 
    client_cart_status_id = 6
WHERE client_cart_id = 6;

SELECT * FROM  client;

-- -------------------------------------------
-- Пример процедуры, которая будет обновлять начальную (start_price) стоимость товара в зависимости от скидки
-- -------------------------------------------

DELIMITER //

CREATE PROCEDURE Update_Prdut_Price_WD(IN productId INT, IN discount DECIMAL(5,2))
BEGIN
    UPDATE IBA_3.product
    SET start_price = start_price - (start_price * discount / 100)
    WHERE product_id = productId;
END //

DELIMITER ;

-- вызов функции
CALL Update_Prdut_Price_WD(1, 10.00); -- (product_id, % скидки)

SELECT* FROM product;
CALL Update_Prdut_Price_WD(15, 50.00); -- (product_id, % скидки)


-- -------------------------------------------
-- Пример процедуры, которая будет обновлять статус клиента на вип, при условии выкупа на больше, чем 500р
-- -------------------------------------------

DELIMITER //
CREATE PROCEDURE update_client_status(IN clientid INT)
BEGIN
    DECLARE amount_order DECIMAL(8,2);
   
    SELECT client_amout_order INTO amount_order  -- забираем текущее значение client_amout_order для клиента (общая сумма выкупа)
    FROM IBA_3.client
    WHERE client_id = clientid;

    IF amount_order > 500 THEN -- Проверяем сумму выкупа        
        UPDATE IBA_3.client -- Обновляем статус клиента на 5 "ВИП"
        SET client_status_id = 5,
            update_time = CURRENT_TIMESTAMP
        WHERE client_id = clientid;

        SELECT 'Статус клиента изменен на ВИП' AS result;
    ELSE
        SELECT 'Общая сумма выкупа меньше или равна 500р, статус ВИП недосупен' AS result;
    END IF;
END //
DELIMITER ;

CALL update_client_status(10);  -- укажи client_id



