--Представление "Расписание" (отношение "Маршруты" с указанием времени прибытия). 
drop VIEW timetable;
select * from public.timetable;

CREATE OR REPLACE VIEW timetable
AS SELECT *, dep_time+duration AS arr_time
FROM routes;

UPDATE timetable
SET duration = '60:00:00'
WHERE rid = 1;

DELETE FROM timetable
WHERE duration = '00:00:00'; 

INSERT INTO timetable VALUES(13, 'Москва', 'Воронеж', '12:20', '18:00', 'ED', 1000);

--Представление "Средняя загруженность маршрутов": 
--номер маршрута – количество рейсов – количество проданных билетов / количество мест всего.
drop VIEW workload;
select * from public.workload;

CREATE OR REPLACE VIEW workload
AS SELECT routes.rid, (SELECT count(*)
					       FROM voyages
					       WHERE routes.rid = voyages.rid) AS number_voyages, 
					   (SELECT sum(voyages.tickets) FROM voyages
						   WHERE routes.rid = voyages.rid) AS solved_tickets,
						(SELECT sum(transport.capacity) FROM transport, drivers, voyages
						   WHERE routes.rid = voyages.rid
						   AND voyages.did = drivers.did
						   AND transport.license_number = drivers.license_number) AS all_seats
FROM routes
GROUP BY routes.rid;

UPDATE workload
SET number_voyages = 2
WHERE rid = 1;

DELETE FROM workload
WHERE rid = 1; 

INSERT INTO workload VALUES(12, 2, 10, 10);

--Представление "Рейсы на сегодня, на которые все билеты проданы".
drop VIEW routes_today;
select * from public.routes_today;

CREATE OR REPLACE VIEW routes_today
AS SELECT voyages.dep_date, voyages.rid, sum(voyages.tickets) AS solved_tickets
FROM voyages, routes
WHERE voyages.rid = routes.rid
AND (SELECT sum(voyages.tickets) FROM voyages 
	    WHERE voyages.dep_date = current_date AND voyages.rid = routes.rid) = (
		                      SELECT sum(transport.capacity) FROM transport, drivers, routes
			                     WHERE routes.rid = voyages.rid 
			                     AND voyages.did = drivers.did 
			                     AND voyages.dep_date = current_date 
                                 AND transport.license_number = drivers.license_number)
GROUP BY voyages.dep_date, voyages.rid;

UPDATE routes_today
SET solved_tickets = 2
WHERE rid = 1;

DELETE FROM routes_today
WHERE rid = 1; 

INSERT INTO routes_today VALUES(12, 2, 10, 10);
					  
INSERT INTO VOYAGES VALUES(3, '28-02-21', '5', 20);
INSERT INTO VOYAGES VALUES(3, '01-03-21', '3', 20);
INSERT INTO VOYAGES VALUES(5, '28-02-21', '9', 40);
INSERT INTO VOYAGES VALUES(5, '01-03-21', '9', 40);