--Примечание: в таблице "Маршруты" изменить тип поля "время отправления" на INTERVAL.
ALTER TABLE routes
ALTER COLUMN dep_time TYPE INTERVAL;

--1.Функция, принимающая два параметра – дату и периодичность рейса (ежедн., четн., нечет., день недели). 
--Функция должна возвращать null, если на указанную дату нет рейса (в соответствии с периодичностью), или исходную дату, 
--если рейс есть.
DROP FUNCTION check_route; 
CREATE OR REPLACE FUNCTION check_route(date_ DATE, period_ CHAR(10)) RETURNS DATE AS $$
BEGIN     
     IF period_ NOT IN ('ED', 'EN', 'ON', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU') --обозначения из лр
     THEN 
	     RAISE EXCEPTION 'Некорректный формат периодичности рейса!';
     ELSE
	     CASE 
		 WHEN (period_ = 'ED') THEN RETURN date_;
	     WHEN (period_ = 'EN' AND CAST(EXTRACT(DAY FROM DATE(date_)) AS INTEGER) % 2 = 0) THEN RETURN date_;
	     WHEN (period_ = 'ON' AND CAST(EXTRACT(DAY FROM DATE(date_)) AS INTEGER) % 2 <> 0) THEN RETURN date_;
	   	 WHEN (period_ = 'MO' AND (EXTRACT(ISODOW FROM DATE(date_))) = 1) THEN RETURN date_;
	     WHEN (period_ = 'TU' AND (EXTRACT(ISODOW FROM DATE(date_))) = 2) THEN RETURN date_;
	 	 WHEN (period_ = 'WE' AND (EXTRACT(ISODOW FROM DATE(date_))) = 3) THEN RETURN date_;
	   	 WHEN (period_ = 'TH' AND (EXTRACT(ISODOW FROM DATE(date_))) = 4) THEN RETURN date_;
	   	 WHEN (period_ = 'FR' AND (EXTRACT(ISODOW FROM DATE(date_))) = 5) THEN RETURN date_;
	   	 WHEN (period_ = 'SA' AND (EXTRACT(ISODOW FROM DATE(date_))) = 6) THEN RETURN date_;
	   	 WHEN (period_ = 'SU' AND (EXTRACT(ISODOW FROM DATE(date_))) = 7) THEN RETURN date_;
	   	 ELSE RETURN NULL;
	   	 END CASE;
	 END IF;
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

SELECT check_route('2020-12-12', 'ED');
SELECT check_route('2020-12-12', 'EN');
SELECT check_route('2020-12-12', 'ON');
SELECT check_route('2020-12-13', 'EN');
SELECT check_route('2020-12-13', 'ON');
SELECT check_route('2021-04-19', 'MO');
SELECT check_route('2021-04-19', 'WE');
SELECT check_route('2020-12-13', 'MONDAY');
SELECT check_route('2020-12-13', '');
SELECT check_route(NULL, '');
SELECT check_route('2020-12-13', NULL);

--2.Функция, формирующая таблицу «Рейсы» на будущий период. Параметр – дата, из которой берется год и месяц, 
--на который надо составить расписание. Этот месяц должен относиться к будущему времени 
--(например, в апреле можно составить расписание на май). Поле "Номер маршрута" берется из таблицы "Маршруты", 
--"Дата выезда" вычисляется на основании периодичности рейса с помощью ранее созданной функции. 
--Поле "Водитель" остается пустым, количество проданных билетов равно 0. 
--Функция не должна добавлять (или изменять) те рейсы, которые уже есть в таблице.
DROP TABLE new_voyages;
CREATE TABLE new_voyages (
	route_id NUMERIC(4, 0), 
	departure_date DATE, 
	driver_id CHAR(10) DEFAULT NULL, 
	sold_tickets INTEGER DEFAULT NULL);

DROP FUNCTION future_voyages; 	
CREATE OR REPLACE FUNCTION future_voyages(date_ DATE) RETURNS VOID AS $$
DECLARE
       start_date DATE;
	   end_date DATE;
	   counter DATE;
	   function_result DATE;
	   i NUMERIC(4, 0);
BEGIN  
     DELETE FROM new_voyages;
     IF (date_ <= current_date) OR 
	    ((EXTRACT(MONTH FROM DATE(date_)) = EXTRACT(MONTH FROM DATE(current_date))) AND 
		 (EXTRACT(YEAR FROM DATE(date_)) <= EXTRACT(YEAR FROM DATE(current_date))))
     THEN 
	     RAISE EXCEPTION 'Введена некорректная дата!';
	 ELSE
	     start_date := (date_trunc('MONTH', date_::DATE))::DATE; --первый день месяца
		 end_date := (date_trunc('MONTH', date_::DATE) + INTERVAL '1 MONTH - 1 day')::DATE; --последний день месяца
	     FOR i IN 
		         (SELECT rid FROM routes) --цикл по маршрутам
		 LOOP
		     counter := start_date;
		     WHILE counter < end_date --цикл по датам
		     LOOP
			     function_result:= check_route(counter, (SELECT rperiod FROM routes WHERE rid = i)); --проверка рейса
			     IF function_result IS NOT NULL
		         THEN
				     INSERT INTO new_voyages VALUES (i, function_result); --заполнение таблицы
				 END IF;
				 counter := counter + 1;
		     END LOOP;
		 END LOOP;
	END IF;	 
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

--Для теста ошибки
SELECT future_voyages('2020-03-13');
SELECT future_voyages('2020-07-14');
SELECT future_voyages('2021-04-13');
SELECT future_voyages('2021-07-13');
SELECT future_voyages('2022-07-13');
SELECT future_voyages('2022-04-13');

--Для теста функции
SELECT future_voyages('2021-07-13');
SELECT * FROM new_voyages
ORDER BY 1, 2;
SELECT future_voyages('2020-07-13');
SELECT * FROM new_voyages
ORDER BY 1, 2;
SELECT future_voyages('2021-04-13');
SELECT * FROM new_voyages
ORDER BY 1, 2;
SELECT future_voyages(NULL);
SELECT * FROM new_voyages
ORDER BY 1, 2;