--2.Посчитать общую стоимость проданных билетов на конкретную дату.
SELECT dep_date, routes.price*voyages.tickets AS summary
FROM routes, voyages
WHERE voyages.dep_date = '2020-04-13' AND voyages.rid = routes.rid;
				 

--5.Создать упорядоченный список маршрутов, по которым нет рейсов.
--1
SELECT *
FROM routes
WHERE rid NOT IN (SELECT rid
				 FROM voyages)
ORDER BY 1;


--5.Создать упорядоченный список маршрутов, по которым нет рейсов.
--2
SELECT *
FROM routes
WHERE NOT EXISTS (SELECT * FROM voyages 
				  WHERE routes.rid = voyages.rid)
ORDER BY 1;


--1.Проверить, что у одного водителя не более 3-х рейсов в день.
SELECT dep_date, COUNT(*)
FROM voyages
WHERE did = '9' 
GROUP BY dep_date
HAVING COUNT(*) > 3;


--3.Создать упорядоченный список маршрутов из определенного пункта отправления.
SELECT *
FROM routes
WHERE departure = 'Москва'
ORDER BY 1;


--4.Создать упорядоченный список рейсов, выполненных определенным водителем.
SELECT *
FROM voyages
WHERE did = '9'
ORDER BY 1;


--Для формы
SELECT dep_date, dep_time, departure, dep_time + duration AS arr_time, arrival,d.license_number, fio, capacity
FROM voyages v, routes r, drivers d, transport t
WHERE v.rid = r.rid AND v.did = d.did AND d.license_number = t.license_number;

