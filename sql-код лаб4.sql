USE mgpu_ico_db_04;

-- Создание индекса
EXPLAIN
SELECT * FROM rooms WHERE price_per_night < 5000;

CREATE INDEX idx_price_per_night ON rooms(price_per_night);

-- Создание представления
CREATE VIEW v_free_rooms AS
SELECT 
    r.room_id,
    r.number AS room_number,
    r.price_per_night,
    rt.type_name,
    h.h_name AS hotel_name,
    h.h_city AS city
FROM rooms r
JOIN hotels h ON r.hotels_hotel_id = h.hotel_id
JOIN room_type rt ON r.room_type_room_type_id = rt.room_type_id
WHERE r.room_id NOT IN (
    SELECT rooms_room_id 
    FROM booking 
    WHERE CURRENT_DATE BETWEEN check_in_date AND check_out_date
);
SELECT * FROM v_free_rooms LIMIT 10;

-- Создание процедуры
DELIMITER //

CREATE PROCEDURE book_room(
    IN p_customer_id INT,
    IN p_room_id INT,
    IN p_check_in DATE,
    IN p_check_out DATE,
    IN p_guests_count INT
)
BEGIN
    DECLARE room_available INT DEFAULT 0;
    DECLARE room_capacity INT DEFAULT 0;
    DECLARE room_price DECIMAL(10,2) DEFAULT 0;
    DECLARE total_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE nights_count INT DEFAULT 0;
    DECLARE new_booking_id INT DEFAULT 0;
    DECLARE max_booking_id INT DEFAULT 0;
    DECLARE max_history_id INT DEFAULT 0;
    DECLARE confirmed_status_id INT DEFAULT 0;

    -- Проверка корректности дат
    IF p_check_in >= p_check_out THEN
        SELECT 'ОШИБКА: Дата выезда должна быть позже даты заезда!' AS result;
    
    -- Проверка существования клиента
    ELSEIF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SELECT 'ОШИБКА: Клиент не найден!' AS result;
    
    -- Проверка существования номера
    ELSEIF NOT EXISTS (SELECT 1 FROM rooms WHERE room_id = p_room_id) THEN
        SELECT 'ОШИБКА: Номер не найден!' AS result;
    
    -- Проверка количества гостей
    ELSEIF p_guests_count <= 0 THEN
        SELECT 'ОШИБКА: Количество гостей должно быть больше 0!' AS result;
    
    ELSE
        -- Проверка доступности номера на указанные даты
        SELECT COUNT(*) INTO room_available
        FROM booking b
        WHERE b.rooms_room_id = p_room_id
          AND b.check_out_date > p_check_in
          AND b.check_in_date < p_check_out
          AND EXISTS (
              SELECT 1 
              FROM booking_status_history bsh 
              JOIN booking_status bs ON bsh.booking_status_status_id = bs.status_id
              WHERE bsh.booking_booking_id = b.booking_id
                AND bs.status_name != 'отменено'
                AND bsh.status_date = (
                    SELECT MAX(status_date) 
                    FROM booking_status_history 
                    WHERE booking_booking_id = b.booking_id
                )
          );

        -- Получаем информацию о номере
        SELECT rt.capacity, r.price_per_night 
        INTO room_capacity, room_price
        FROM rooms r
        JOIN room_type rt ON r.room_type_room_type_id = rt.room_type_id
        WHERE r.room_id = p_room_id;

        -- Получаем ID статуса "подтверждено"
        SELECT status_id INTO confirmed_status_id 
        FROM booking_status 
        WHERE status_name = 'подтверждено';

        -- Проверка вместимости номера
        IF p_guests_count > room_capacity THEN
            SELECT CONCAT('ОШИБКА: Номер вмещает только ', room_capacity, ' гостей!') AS result;
        
        -- Проверка доступности номера
        ELSEIF room_available > 0 THEN
            SELECT 'ОШИБКА: Номер занят на указанные даты!' AS result;
        
        ELSE
            -- Получаем максимальный ID бронирования
            SELECT COALESCE(MAX(booking_id), 0) INTO max_booking_id FROM booking;
            SET new_booking_id = max_booking_id + 1;

            -- Получаем максимальный ID истории
            SELECT COALESCE(MAX(history_id), 0) INTO max_history_id FROM booking_status_history;
            SET max_history_id = max_history_id + 1;

            -- Расчет стоимости
            SET nights_count = DATEDIFF(p_check_out, p_check_in);
            SET total_cost = nights_count * room_price;

            -- Создаем бронирование
            INSERT INTO booking (
                booking_id,
                booking_date, 
                check_in_date, 
                check_out_date, 
                guest_count, 
                rooms_room_id, 
                customers_customer_id
            ) VALUES (
                new_booking_id,
                CURDATE(),
                p_check_in,
                p_check_out,
                p_guests_count,
                p_room_id,
                p_customer_id
            );

            -- Добавляем начальный статус "подтверждено"
            INSERT INTO booking_status_history (
                history_id,
                status_date,
                booking_booking_id,
                booking_status_status_id
            ) VALUES (
                max_history_id,
                CURDATE(),
                new_booking_id,
                confirmed_status_id
            );

            -- Минимальный вывод
            SELECT CONCAT('Бронирование ', new_booking_id, ' создано') AS result;

        END IF;
    END IF;
END//

DELIMITER ;