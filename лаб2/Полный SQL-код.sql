USE mgpu_ico_db_04;

-- Создание таблицы для отелей с указанием движка и кодировки

CREATE TABLE `Hotels` (

  `hotel_id` INT NOT NULL AUTO_INCREMENT,
  
  `name` VARCHAR(255) NOT NULL,
  
  `city` VARCHAR(255) NOT NULL,
  
  `stars` INT NOT NULL,
  
  PRIMARY KEY (`hotel_id`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Создание таблицы для номеров с указанием движка и кодировки

CREATE TABLE `Rooms` (

  `room_id` INT NOT NULL AUTO_INCREMENT,
  
  `hotel_id` INT NOT NULL,
  
  `room_number` VARCHAR(50) NOT NULL,
  
  `type` VARCHAR(255) NOT NULL,
  
  `price_per_night` DECIMAL(10, 2) NOT NULL,
  
  PRIMARY KEY (`room_id`),
  
  FOREIGN KEY (`hotel_id`) REFERENCES `Hotels`(`hotel_id`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Заполнение таблицы 'Hotels'

INSERT INTO `Hotels` (`name`, `city`, `stars`) VALUES ('Гранд Отель Европа', 'Санкт-Петербург', 5);
INSERT INTO `Hotels` (`name`, `city`, `stars`) VALUES ('Космос', 'Москва', 3);
INSERT INTO `Hotels` (`name`, `city`, `stars`) VALUES ('Амстердам', 'Москва', 4);
INSERT INTO `Hotels` (`name`, `city`, `stars`) VALUES ('Прибалтийская', 'Санкт-Петербург', 4);
INSERT INTO `Hotels` (`name`, `city`, `stars`) VALUES ('Волга', 'Ярославль', 3);

-- Заполнение таблицы 'Rooms'

INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (1, '101', 'Стандартный одноместный', 4500.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (1, '102', 'Стандартный двухместный', 5200.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (1, '201', 'Люкс', 8500.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (2, '101', 'Эконом одноместный', 2500.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (2, '102', 'Эконом двухместный', 2800.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (2, '103', 'Стандартный', 3200.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (3, '301', 'Бизнес-класс', 4200.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (3, '302', 'Стандартный', 2900.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (4, '501', 'С видом на море', 3800.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (4, '502', 'Стандартный', 2700.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (5, '201', 'Эконом', 2200.00);
INSERT INTO `Rooms` (`hotel_id`, `room_number`, `type`, `price_per_night`) VALUES (5, '202', 'Комфорт', 2600.00);

-- Вывести все номера с ценой за ночь менее 3000

SELECT * FROM `Rooms` WHERE `price_per_night` < 3000;