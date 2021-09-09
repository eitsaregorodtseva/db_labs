--1.Триггер, проверяющий, что количество проданных на рейс билетов не превышает количество мест в автобусе.
DROP TRIGGER check_tickets ON voyages;
DROP FUNCTION tickets; 
CREATE OR REPLACE FUNCTION tickets() RETURNS TRIGGER AS $$
BEGIN  
     IF (NEW.tickets > (SELECT DISTINCT tr.capacity FROM transport tr, drivers d WHERE NEW.did = d.did AND tr.license_number = d.license_number))
     THEN 
	     RAISE EXCEPTION 'Количество проданных билетов не может быть больше количества мест!';
     ELSE
	     RETURN NEW;
	 END IF;
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

CREATE TRIGGER check_tickets
BEFORE INSERT or UPDATE ON voyages
FOR EACH ROW
EXECUTE FUNCTION tickets();

INSERT INTO voyages VALUES (1, '2021-12-12', '4', 10);
INSERT INTO voyages VALUES (1, '2020-12-15', '4', 100);
UPDATE voyages SET tickets = 1000
       WHERE rid = 1;
--2.Проверка значений всех полей отношения "Маршруты", для которых могут быть определены домены: 
--                          пункт отправления не равен пункту прибытия; 
--                          время в пути не менее получаса; 
--                          цена билета – от 50 до 1500 рублей.
DROP TRIGGER check_domens ON routes;
DROP FUNCTION routes_checker; 
CREATE OR REPLACE FUNCTION routes_checker() RETURNS TRIGGER AS $$
BEGIN  
     CASE 
	     WHEN (NEW.departure = NEW.arrival)
         THEN 
	         RAISE EXCEPTION 'Пункт отправления равен пункту прибытия!';
	     WHEN (NEW.duration <= '00:30:00'::TIME)
         THEN 
	         RAISE EXCEPTION 'Время в пути менее получаса!';
	     WHEN (NEW.price < 50) OR (NEW.price > 1500)
         THEN 
             RAISE EXCEPTION 'Цена билета не лежит в промежутке от 50 до 1500 рублей!';
         ELSE
	         RETURN NEW;
	 END CASE; 
END;
$$ LANGUAGE plpgsql
RETURNS NULL ON NULL INPUT;

CREATE TRIGGER check_domens
BEFORE INSERT or UPDATE ON routes
FOR EACH ROW
EXECUTE FUNCTION routes_checker();

INSERT INTO routes VALUES (15, 'Чебоксары', 'Чебоксары', '13:00', '00:30:00', 'TU', 600);
INSERT INTO routes VALUES (16, 'Чебоксары', 'Киров', '13:00', '00:29:00', 'TU', 600);
INSERT INTO routes VALUES (17, 'Москва', 'Киров', '13:00', '1:00', 'TU', 2000);
INSERT INTO routes VALUES (19, 'Смоленск', 'Киров', '13:00', '15:00', 'TU', 800);
